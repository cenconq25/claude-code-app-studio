# `validate-push.sh` Reference

The pre-push hook fires on `PreToolUse(Bash)` whenever Claude is about
to run `git push`. It is the **slow** gate — the place to run the full
test matrix, run an E2E smoke pass, check app-size deltas, and enforce
branch policy. Acceptable runtimes are ~30 seconds to a few minutes;
anything longer should be deferred to CI proper.

The shipped script (`app_dev/.claude/hooks/validate-push.sh`) ships
with the following behaviour out of the box:

- **Hard block** on `git push --force` to a protected branch
  (`main`, `master`, `release`, `release/*`, `production`).
- **Warn** when pushing directly to `main`/`master` (PR expected).
- **Warn** when source files changed in this push but no test files
  did — encourages `/test-evidence-review`.
- **Stage-aware reminder** — once `production/stage.txt` reads
  `QA & Beta` or `Release`, the hook reminds the user to run
  `/smoke-check` before merging.

The patterns below describe how to extend it for each framework's full
gate.

## Universal checks (every framework)

| Check | Behavior | Notes |
|---|---|---|
| Force push to `main`/`master`/`release`/`production` | Block | Already shipped |
| Direct push to `main` | Warn | PR expected |
| No tests for source-only changes | Warn | Already shipped |
| Stage-aware smoke-check reminder | Warn | Already shipped |
| Full unit + integration suite green | Block | See per-framework |
| E2E smoke green (optional) | Warn | Maestro / Detox / XCUITest / Espresso |
| App size delta within budget | Warn | iOS `.ipa`, Android `.aab` |
| Cold-start regression | Warn | Run benchmark in CI; compare to baseline |
| Conventional Commit format on every commit being pushed | Block | See `git-event-hooks.md` |

## Branch policy

The shipped behaviour is intentionally permissive — it warns rather
than blocks pushes to `main`. Tighten it once the team is settled:

```bash
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
  echo "BLOCKED: direct push to ${CURRENT_BRANCH}." >&2
  echo "Open a PR from a feature branch instead." >&2
  echo "Hotfix? Use the dedicated hotfix workflow (/hotfix)." >&2
  exit 2
fi
```

## React Native + TypeScript

Run the full suite, plus an optional Detox smoke if simulators are
available:

```bash
yarn install --frozen-lockfile || { echo "BLOCKED: install failed" >&2; exit 2; }
yarn lint --max-warnings=0 || { echo "BLOCKED: lint" >&2; exit 2; }
yarn typecheck || { echo "BLOCKED: type errors" >&2; exit 2; }
yarn test --ci --coverage || { echo "BLOCKED: unit/integration suite" >&2; exit 2; }

if [ -n "${RUN_DETOX_ON_PUSH:-}" ]; then
  detox build --configuration ios.sim.release \
    && detox test --configuration ios.sim.release --record-logs all \
    || { echo "WARN: Detox smoke failed — fix before merge" >&2; }
fi
```

App-size delta (RN with EAS or fastlane producing an `.ipa`/`.aab`):

```bash
SIZE_LIMIT_IPA_MB=80
SIZE_LIMIT_AAB_MB=50
LATEST_IPA=$(ls -t builds/*.ipa 2>/dev/null | head -1)
[ -n "$LATEST_IPA" ] && size=$(du -m "$LATEST_IPA" | cut -f1) && \
  [ "$size" -gt "$SIZE_LIMIT_IPA_MB" ] && \
  echo "WARN: latest .ipa is ${size}MB (> ${SIZE_LIMIT_IPA_MB}MB threshold)" >&2
```

## Flutter + Dart

```bash
flutter pub get || { echo "BLOCKED: pub get failed" >&2; exit 2; }
flutter analyze --no-pub || { echo "BLOCKED: analyzer" >&2; exit 2; }
dart format --set-exit-if-changed lib test || { echo "BLOCKED: format" >&2; exit 2; }
flutter test --no-pub --coverage || { echo "BLOCKED: tests" >&2; exit 2; }

if [ -n "${RUN_INTEGRATION_ON_PUSH:-}" ]; then
  flutter test integration_test || { echo "WARN: integration suite failed" >&2; }
fi
```

App-size delta:

```bash
flutter build appbundle --release --tree-shake-icons
size=$(du -m build/app/outputs/bundle/release/app-release.aab | cut -f1)
[ "$size" -gt 50 ] && echo "WARN: .aab is ${size}MB" >&2
```

## Native iOS

```bash
xcodebuild -workspace App.xcworkspace -scheme App \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  test | xcpretty || { echo "BLOCKED: XCTest" >&2; exit 2; }

# Optional XCUITest smoke
if [ -n "${RUN_UITESTS_ON_PUSH:-}" ]; then
  xcodebuild -workspace App.xcworkspace -scheme AppUITests \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    test | xcpretty || { echo "WARN: UI tests failed" >&2; }
fi

# Cold start: see Instruments xctrace for App Launch template
```

App-size delta — measure the optimised `.ipa` from the most recent
archive, not a debug build:

```bash
LATEST_IPA=$(ls -t build/*.ipa 2>/dev/null | head -1)
[ -n "$LATEST_IPA" ] && size=$(du -m "$LATEST_IPA" | cut -f1) && \
  [ "$size" -gt 80 ] && echo "WARN: .ipa is ${size}MB" >&2
```

## Native Android

```bash
./gradlew lint test connectedAndroidTest \
  || { echo "BLOCKED: gradle test suite" >&2; exit 2; }

if [ -n "${RUN_INSTRUMENTED_ON_PUSH:-}" ]; then
  ./gradlew connectedDebugAndroidTest \
    || { echo "WARN: instrumented tests failed" >&2; }
fi
```

App-size delta on `.aab`:

```bash
./gradlew :app:bundleRelease
AAB=$(ls -t app/build/outputs/bundle/release/*.aab | head -1)
size=$(du -m "$AAB" | cut -f1)
[ "$size" -gt 50 ] && echo "WARN: .aab is ${size}MB" >&2
```

## E2E smoke (optional, framework-agnostic)

Maestro is the cheapest cross-framework option. Place a smoke flow at
`tests/e2e/smoke.yaml` and gate the push on it:

```bash
if command -v maestro >/dev/null 2>&1 && [ -f tests/e2e/smoke.yaml ]; then
  maestro test tests/e2e/smoke.yaml \
    || { echo "WARN: Maestro smoke failed" >&2; }
fi
```

## Cold-start performance regression

Track a baseline in `production/perf/baseline.json`. Compare on push:

```bash
if [ -f production/perf/baseline.json ] \
   && [ -x tools/measure-cold-start.sh ]; then
  current=$(./tools/measure-cold-start.sh)  # outputs a number in ms
  baseline=$(jq -r '.cold_start_ms' production/perf/baseline.json)
  delta=$(( current - baseline ))
  if [ "$delta" -gt 200 ]; then
    echo "WARN: cold start ${current}ms vs baseline ${baseline}ms (+${delta}ms)" >&2
  fi
fi
```

## Bypassing for hotfixes

```text
$ git push origin hotfix/critical
=== Push Validation Warnings ===
PUSH: source changed but no test files in this push
PUSH: project is in Release — run /smoke-check before merging
================================
```

For genuine hotfixes (production crash, store rejection, security
incident):

1. Use the `/hotfix` skill — it documents the bypass with an audit
   trail, requires a backport plan, and tags the resulting commit so
   the next sprint plan can absorb the follow-up work.
2. As a last resort: `git push --no-verify` plus an immediate session
   log entry explaining why.

Never bypass for "tests are slow today" or "CI will catch it". Mobile
fixes are most expensive after they ship — every store has review
latency, and OTA updates have rollout windows.

## Where to read the shipped logic

`app_dev/.claude/hooks/validate-push.sh` — wiring in
`app_dev/.claude/settings.json` under `PreToolUse[Bash]`.
