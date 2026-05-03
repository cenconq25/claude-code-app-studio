# `validate-commit.sh` Reference

The pre-commit-style hook fires on `PreToolUse(Bash)` whenever Claude is
about to run `git commit`. It runs the **fast** checks — anything that
should complete in under five seconds for a typical staged set — and
either blocks the commit (exit `2`) or warns and allows it (exit `0`).

The shipped script (`app_dev/.claude/hooks/validate-commit.sh`) keeps
its inline logic minimal and shells out to whatever lint/type/test
runner the chosen framework provides. The patterns below describe what
that runner should do for each framework.

## Universal checks (every framework)

| Check | Hard block? | Notes |
|---|---|---|
| Invalid JSON in any staged `.json` (excluding lockfiles) | Yes | A broken `app.json` / `tsconfig.json` will fail the next build anyway |
| `.env`, `.env.local`, `.env.*` staged | Yes | Secrets in git are an incident |
| Provisioning profile (`*.mobileprovision`, `*.p12`) staged | Yes | Distribution certs do not belong in source |
| Android keystore (`*.keystore`, `*.jks`) staged | Yes | Same reason |
| `local.properties` staged | Yes | Path leaks plus often holds keys |
| Files larger than 5 MB | Warn | Likely accidental binary; might be a real asset |
| Commit message missing PRD/ADR/STORY ref when `src/` changed | Warn | Surfaces traceability gaps |
| Hardcoded URLs in `src/` | Warn | Should live in config or remote-config |
| Ownerless `TODO`/`FIXME` | Warn | Use `TODO(name)` so it has a home |

The shipped script implements the soft warnings; the hard blocks are
either implemented inline or left to your CI of choice. Add hard blocks
case by case — see the framework-specific sections.

## React Native + TypeScript

| Tool | Command | Block / Warn |
|---|---|---|
| ESLint | `yarn lint --quiet $(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(ts|tsx|js|jsx)$')` | Block on errors, warn on warnings |
| TypeScript | `yarn typecheck` (runs `tsc --noEmit -p tsconfig.json`) | Block on type errors |
| Jest related-tests | `yarn jest --findRelatedTests --bail $(git diff --cached --name-only --diff-filter=ACM)` | Block on failure |
| Prettier | `yarn prettier --check $(git diff --cached --name-only --diff-filter=ACM)` | Block on diff |
| Secret scan | `gitleaks protect --staged --no-banner` | Block on any finding |
| No Hermes bundles | `git diff --cached --name-only \| grep -E '\\.hbc$'` | Block — bundles belong to release pipeline |
| No `.expo/`, no `ios/build/`, no `android/build/` | path filter | Block |

Snippet for a custom RN block:

```bash
HERMES=$(git diff --cached --name-only | grep -E '\.hbc$' || true)
if [ -n "$HERMES" ]; then
  echo "BLOCKED: do not commit Hermes bundles" >&2
  printf '%s\n' "$HERMES" >&2
  exit 2
fi
```

## Flutter + Dart

| Tool | Command | Block / Warn |
|---|---|---|
| Analyzer | `flutter analyze --no-pub` (scoped to changed files via `--no-fatal-infos`) | Block on errors |
| Formatter | `dart format --set-exit-if-changed $(git diff --cached --name-only --diff-filter=ACM \| grep '\.dart$')` | Block on diff |
| Unit tests | `flutter test --no-pub --reporter=compact $(directories of changed dart files)` | Block on failure |
| Secret scan | `gitleaks protect --staged --no-banner` | Block on any finding |
| No `.dart_tool/` | path filter | Block |
| No `.flutter-plugins`, `.flutter-plugins-dependencies` | path filter | Block |
| No `build/` | path filter | Block |

Snippet:

```bash
TOOL_LEAK=$(git diff --cached --name-only | grep -E '^(\.dart_tool|build)/' || true)
if [ -n "$TOOL_LEAK" ]; then
  echo "BLOCKED: build / .dart_tool artefacts must not be committed" >&2
  printf '%s\n' "$TOOL_LEAK" >&2
  exit 2
fi
```

## Native iOS (Swift / SwiftUI)

| Tool | Command | Block / Warn |
|---|---|---|
| SwiftLint | `swiftlint lint --strict --quiet --use-script-input-files $(git diff --cached --name-only --diff-filter=ACM \| grep '\.swift$')` | Block on errors |
| SwiftFormat | `swiftformat --lint $(git diff --cached --name-only --diff-filter=ACM \| grep '\.swift$')` | Block on diff |
| XCTest changed test plans | `xcodebuild test-without-building -scheme App -only-testing:<changed-target>` | Block on failure |
| `.xcuserstate` not staged | path filter | Block |
| No merged provisioning profile | filter `*.mobileprovision` | Block |
| No `*.p12` / `*.cer` / `*.pem` | path filter | Block |
| Storyboard merge markers | `grep -l '<<<<<<<' *.storyboard` | Block |

Snippet:

```bash
USERSTATE=$(git diff --cached --name-only | grep -E '\.xcuserstate$' || true)
if [ -n "$USERSTATE" ]; then
  echo "BLOCKED: .xcuserstate is per-developer state; add it to .gitignore" >&2
  exit 2
fi
```

## Native Android (Kotlin / Compose)

| Tool | Command | Block / Warn |
|---|---|---|
| detekt | `./gradlew detektMain --auto-correct=false -PinputFiles="<staged>"` | Block on errors |
| KtLint | `./gradlew ktlintCheck` (or `ktlint $(git diff --cached --name-only \| grep '\.kt$')`) | Block on errors |
| JUnit related modules | `./gradlew :feature-auth:testDebugUnitTest` (one per affected module) | Block on failure |
| `local.properties` not staged | path filter | Block |
| No `*.keystore`, no `*.jks` | path filter | Block |
| No `release/output-metadata.json` from a local build | path filter | Block |
| Strings only changed in `values/` (not in `values-xx/`) | informational warn | Warn — likely missed locales |

Snippet:

```bash
LOCAL_PROPS=$(git diff --cached --name-only | grep -E '(^|/)local\.properties$' || true)
if [ -n "$LOCAL_PROPS" ]; then
  echo "BLOCKED: local.properties is per-developer; add to .gitignore" >&2
  exit 2
fi
```

## Cross-platform: PRD / ADR / STORY traceability

The shipped hook surfaces this as a soft warning. Promote it to a block
once the project is past Sprint Dev:

```bash
COMMIT_MSG=$(printf '%s' "$COMMAND" \
  | sed -nE 's/.*-m[[:space:]]+["'\'']([^"'\'']+)["'\''].*/\1/p')
SRC_TOUCHED=$(git diff --cached --name-only | grep -E '^src/' | head -1)

if [ -n "$SRC_TOUCHED" ] \
   && ! printf '%s' "$COMMIT_MSG" \
   | grep -qE '(PRD-[A-Z0-9-]+|ADR-[0-9]+|STORY-[A-Z0-9-]+)'; then
  echo "BLOCKED: src/ changes must reference PRD, ADR, or STORY in commit msg" >&2
  exit 2
fi
```

## Adding custom checks

The shipped script collects warnings into a `WARNINGS` shell variable
and prints them at the end. To add a new check:

1. Decide whether it's hard (block) or soft (warn).
2. For hard: write directly to stderr and `exit 2` after the bad
   condition is confirmed.
3. For soft: append to `WARNINGS` with `WARNINGS="${WARNINGS}\nLABEL: ..."`.
4. Keep the runtime under ~3 seconds for the typical staged set; expensive
   things belong in the **push** hook, not the commit hook.
5. Test with a deliberately broken commit before merging the new check.

## Failing case + bypass

```text
$ git commit -m 'fix navigation jank'
BLOCKED: src/ changes must reference PRD, ADR, or STORY in commit msg
```

To bypass: `git commit --no-verify -m '...'`.

**Bypass discouraged.** Pre-commit checks exist because mobile bugs are
expensive to ship — a broken JSON config crashes the app at launch on
millions of devices. If a check is wrong for your case, fix the check
or document an explicit exception in `.claude/rules/`. `--no-verify` is
a last resort, not a workflow.

## Where to read the shipped logic

`app_dev/.claude/hooks/validate-commit.sh` — see the file for the
exact warning messages it currently produces and the JSON-validation
hard block. Wiring is in `app_dev/.claude/settings.json` under
`PreToolUse[Bash]`.
