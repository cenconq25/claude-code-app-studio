# Tests

The test tree is a sibling of `src/`, not nested inside, so coverage
visibility is unambiguous and tooling can address suites by directory.

## Layout

```text
tests/
├── unit/             # Pure-logic tests, fast, deterministic
├── integration/      # Multi-module tests with fakes for transport
├── component/        # Single-component or single-widget render tests
├── e2e/              # End-to-end tests on a real or virtual device
├── fixtures/         # Shared factories, fixture builders, recorded payloads
├── helpers/          # Test utilities — assertions, matchers, mocks
└── README.md
```

## Per-Framework E2E Conventions

Pick one E2E runner per project (the choice goes in
`.claude/docs/technical-preferences.md`). Recommended defaults:

| Stack | E2E runner |
|---|---|
| React Native | Maestro (greenfield) or Detox (mature setups) |
| Flutter | Patrol (recommended) or `integration_test` |
| Native iOS | XCUITest (in-tree) or Maestro (cross-team) |
| Native Android | Espresso + UI Automator (in-tree) or Maestro |

Maestro tests live in `tests/e2e/maestro/[flow]/[step].yaml`. XCUITest
and Espresso tests live in their respective project test targets but
are mirrored here as Markdown manifests so the suite is discoverable
from Claude Code without opening the IDE.

## Pyramid

| Layer | What it covers | Runtime budget | Where it lives |
|---|---|---|---|
| Unit | Pure logic — formulas, validators, reducers, mappers | < 5 ms each | `tests/unit/[feature]/` |
| Integration | Repository + cache + offline queue together | < 200 ms each | `tests/integration/[feature]/` |
| Component / Widget | Single-component render + interaction | < 200 ms each | `tests/component/[feature]/` |
| E2E | Critical user paths on a real or virtual device | Minutes | `tests/e2e/` |

## Required Suites Per Story Type

| Story type | Required suite |
|---|---|
| Logic | At least one unit test that covers all acceptance criteria |
| Integration | Integration test or documented manual run with fixtures |
| UI | Component test or screenshot diff plus manual a11y walkthrough |
| Animation / Motion | Recorded clip plus `motion-designer` sign-off |
| Config / Remote | Smoke check of each variant |
| Accessibility | Audit run plus screen-reader walkthrough |

The matrix is enforced by `/story-done` and `/test-evidence-review`.

## Naming

- **TS / RN**: `[feature]-[capability].test.ts(x)` — e.g.,
  `sign-in-validation.test.ts`.
- **Swift**: `FeatureNameTests.swift` — e.g., `SignInTests.swift`.
- **Kotlin**: `FeatureNameTest.kt` — e.g., `SignInViewModelTest.kt`.
- **Dart**: `feature_name_test.dart` — e.g., `sign_in_test.dart`.

Test names describe behaviour: `signs in with valid credentials`, not
`testHandleSubmit`.

## Determinism

- Inject the clock; freeze it in tests.
- Inject the random source; seed it.
- Mock the network at the transport boundary.
- Mock the filesystem; use temp directories that get torn down.
- Never depend on test execution order.

Flaky tests go to `tests/quarantine/` via `/test-flakiness` and are fixed
within one sprint.

## CI

The pyramid runs in three CI stages:

1. **Per-PR** — unit + integration + component. Fast (< 5 minutes).
   Blocks merge.
2. **Per-PR (parallel)** — lint + type-check.
3. **Nightly** — E2E suite on a device matrix. Reports go to the
   release channel.

Per-framework runners are configured by `/test-setup`:

- **RN**: `yarn test --ci` (Jest), `yarn typecheck`, `yarn lint`,
  `maestro test tests/e2e/maestro` (nightly).
- **Flutter**: `flutter analyze`, `flutter test --coverage`,
  `patrol test --target tests/e2e/patrol` (nightly).
- **iOS**: `xcodebuild test -scheme App -destination ...`.
- **Android**: `./gradlew lint test connectedAndroidTest`.

## Coverage Floor

- Domain (pure logic, validators, formulas): **90%**.
- Repositories and services: **70%**.
- Overall: **50%**. Higher is welcome; 100% is not the goal.

UI and animation work is covered by component tests + screenshot diff
where helpful, plus manual review.

## What NOT to Test Here

- Real network calls — mock the transport.
- Real push delivery — verify handlers with fixtures; defer to TestFlight
  / Play internal track for end-to-end.
- Real IAP purchases — sandbox path only.
- Subjective qualities ("feels snappy") — covered by lead reviews and
  beta testing.
- Pixel-perfect rendering across every device — covered by device-farm
  runs, not by automated tests.
