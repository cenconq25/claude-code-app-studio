---
name: test-setup
description: "Scaffold the test framework and CI pipeline for the project. Creates the tests/ directory structure, framework-specific test runner, and GitHub Actions or Bitrise workflow. Run once during Technical Setup before the first sprint."
argument-hint: "[--ci=github-actions|bitrise|circleci|none]"
user-invocable: true
allowed-tools: Read, Glob, Write, Edit, Bash, AskUserQuestion
model: sonnet
---

# Test Setup

One-shot scaffolding of a mobile project's test pyramid plus its CI runner.
Reads the pinned framework, generates the test directory tree, drops in a
runnable example test for each level, and writes a CI workflow file that
invokes the right runner.

---

## Phase 1: Read Project Context

Read these in parallel:

- `CLAUDE.md` — confirm project name and target platforms.
- `.claude/docs/technical-preferences.md` — pull Framework, Language,
  Naming Conventions, Testing Framework (if already chosen), and Target
  Platforms.
- `.claude/docs/coding-standards.md` — confirm the test naming and
  determinism rules.

If Framework is `[TO BE CONFIGURED]`, stop and tell the user:
"Run `/setup-framework` first; the test scaffolding depends on a pinned
framework."

---

## Phase 2: Pick the Test Stack

If the Testing Framework field is empty, propose a default per framework
via AskUserQuestion:

| Framework | Unit | Component / widget | E2E |
|-----------|------|---------------------|-----|
| React Native | Jest + React Native Testing Library | RNTL | Detox or Maestro |
| Flutter | `package:test` | `flutter_test` widget tests | `integration_test` + Maestro or Patrol |
| iOS native | XCTest | XCTest + ViewInspector (SwiftUI) | XCUITest or Maestro |
| Android native | JUnit5 + MockK | Compose UI test or Espresso | Espresso, UI Automator, or Maestro |

Confirm the choices with the user. Persist the answer back into
`.claude/docs/technical-preferences.md` under
`## Testing` as `Framework: [choices]`.

---

## Phase 3: Choose the CI Provider

Parse the `--ci` flag. If absent, ask:

- `[A] GitHub Actions` (default for OSS, free macOS minutes are limited)
- `[B] Bitrise` (mobile-first, simpler iOS signing)
- `[C] CircleCI`
- `[D] None — local only for now`

Capture the choice in technical-preferences as `CI: [provider]`.

---

## Phase 4: Create the Directory Tree

Confirm with the user:

> "I'd like to create the following:
> ```
> tests/
>   unit/                 — fast, deterministic, no I/O
>   integration/          — multi-module, may use in-memory DB
>   e2e/                  — full app on simulator/emulator
>   helpers/              — factories, mocks, shared assertions
>   fixtures/             — JSON / image fixtures
>   regression/           — bug regression tests
>   smoke/                — critical-path smoke tests
> Plus a runner config file and a CI workflow.
> May I proceed?"

On approval, create each directory with a `.gitkeep` (no other files yet).

---

## Phase 5: Drop In Runner Configuration

Write framework-specific configuration. Always ask before each write.

### React Native (Jest + RNTL + Detox or Maestro)

- `jest.config.js` — preset `react-native`, transform ignore patterns,
  setup file pointing to `tests/helpers/jest.setup.ts`, coverage threshold
  defaults (lines 70%, branches 60%).
- `tests/helpers/jest.setup.ts` — global mocks (AsyncStorage, native
  modules), fake timers helpers, RNTL `cleanup` hook.
- `.detoxrc.js` (if Detox) — iOS simulator and Android emulator targets.
- `tests/e2e/.maestro/login.yaml` (if Maestro) — placeholder flow.

### Flutter (test + flutter_test + Patrol)

- `dart_test.yaml` — tags for `unit`, `integration`, concurrency settings.
- `integration_test/app_test.dart` — placeholder integration test.
- `pubspec.yaml` dev_dependencies edits (suggest only — never silently
  edit the user's pubspec).

### iOS (XCTest + XCUITest)

- `*.xctestplan` — separate plans for unit, integration, ui.
- `tests/unit/SampleUnitTests.swift` — placeholder.
- `tests/e2e/SampleUITests.swift` — placeholder.

### Android (JUnit5 + Compose + Espresso)

- `build.gradle.kts` test source set additions (propose, don't auto-edit).
- `tests/unit/SampleUnitTest.kt`.
- `tests/e2e/SampleUiTest.kt`.

For each test stub, follow the project's naming convention:
`[module]_[feature]_test.[ext]` and `test_[scenario]_[expected]` for
function names.

---

## Phase 6: CI Workflow

Generate the workflow at the right path for the chosen provider.

### GitHub Actions

`.github/workflows/test.yml`:

- Trigger on `pull_request` and `push` to `main`.
- Job 1 — `unit` on `ubuntu-latest`: install deps, run unit tests.
- Job 2 — `integration` on `ubuntu-latest` for RN/Flutter, `macos-latest`
  for iOS/Android emulators when needed.
- Job 3 — `e2e` on `macos-latest` for iOS, `ubuntu-latest` for Android,
  with caching for the simulator/emulator boot.
- Coverage upload step (Codecov optional).

### Bitrise

`bitrise.yml`:

- `primary` workflow: cache restore, install deps, unit, integration,
  build for testing, run UI tests on simulator/emulator, cache save.
- `pr` workflow runs unit + integration only; full UI runs on `main`.

### CircleCI

`.circleci/config.yml`:

- `test` job using the appropriate orb (`react-native`, `flutter`,
  `ios`, `android`).

For all providers, document required secrets:

- `MATCH_PASSWORD` (iOS signing via fastlane match)
- `ANDROID_SIGNING_KEY` (base64-encoded)
- `APP_STORE_CONNECT_API_KEY`
- `PLAY_STORE_SERVICE_ACCOUNT`

---

## Phase 7: Smoke Suite Seed

Create `tests/smoke/critical-paths.md` listing the first set of smoke
scenarios. Defaults to:

- App cold-starts within budget on a baseline device.
- Sign-in (or guest entry) reaches the home screen.
- The primary CTA on home performs its action without a crash.

Each scenario gets a placeholder Maestro flow or test stub that the team
will fill in during the first sprint.

---

## Phase 8: Document the Setup

Append to `.claude/docs/coding-standards.md` under `## Testing`:

- Frameworks selected.
- CI provider and workflow path.
- Coverage thresholds.
- Required device matrix (defer to `/qa-plan` for full matrix).

Confirm with the user before writing.

---

## Quality Gates / PASS-FAIL

- PASS — directory tree exists, runner config compiles, sample tests run
  and pass, CI workflow file is syntactically valid.
- FAIL — any sample test fails on a clean checkout, or the CI workflow
  has lint errors. Surface the failures and stop.

Run a quick smoke validation via Bash:

- RN — `npx jest tests/unit/sample.test.tsx`
- Flutter — `flutter test test/unit/sample_test.dart`
- iOS — `xcodebuild test -scheme [scheme] -only-testing:UnitTests`
- Android — `./gradlew testDebugUnitTest --tests SampleUnitTest`

If the smoke run fails, surface the exact error and stop before proceeding.

---

## Examples

**Example 1 — Fresh React Native app, GitHub Actions:**
Creates `tests/unit/sample.test.tsx`, `jest.config.js`, `.detoxrc.js`, a
GHA workflow with three jobs, and a Maestro placeholder. Smoke run via
Jest passes.

**Example 2 — Flutter app, Bitrise:**
Creates `dart_test.yaml`, `integration_test/app_test.dart`, a
`bitrise.yml` with Patrol step, and a smoke flow. Confirms with
`flutter test` locally.

---

## Next Steps

- Run `/test-helpers` to seed the helper library.
- Run `/qa-plan sprint-01` once the first sprint is planned to flesh out
  the device matrix.
