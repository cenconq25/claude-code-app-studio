# Coding Standards

These standards apply across every framework supported by the template. The
path-scoped rules in `.claude/rules/` add framework-specific detail; this
file documents the universal expectations.

## Universal Code Rules

- Every public symbol (exported function, class, hook, screen) carries a
  doc comment that states its purpose, expected inputs, side effects, and
  any platform caveats.
- Every system has an ADR in `docs/architecture/`. New systems without an
  ADR are reviewed before merge — `lead-developer` blocks PRs that ship
  meaningful architecture without one.
- Configurable values live in data files or a typed config module, never
  inlined as magic numbers. UI copy lives in the localization catalogue,
  not in source.
- Public methods must be unit-testable. Prefer constructor or hook-based
  injection over global singletons.
- Commits reference the relevant PRD ID (`PRD-AUTH-003`), ADR
  (`ADR-0007`), or sprint story (`STORY-S5-12`). The `validate-commit.sh`
  hook surfaces commits without a reference.
- **Verification-driven development.** Logic ships with a unit test, UI
  ships with a screenshot or interaction recording, networking ships with
  a fixture-driven integration test. Every implementation has at least one
  artefact proving it works on the target platforms.

## TypeScript / React Native

- `strict: true` in `tsconfig.json`. No `any` outside generated code; use
  `unknown` and narrow it.
- Components are function components with explicit prop types. Avoid
  `React.FC` (it does not infer children correctly).
- Side effects use `useEffect` only when they cannot be expressed as a
  query (TanStack Query) or mutation. Network code is always cancelable.
- Hooks follow the `use*` prefix and obey the rules of hooks.
- Files are kebab-case (`profile-screen.tsx`); components inside are
  PascalCase. Each file exports one component.

## Swift / SwiftUI / iOS

- Swift 6 strict concurrency. Mark types `Sendable` where they cross actor
  boundaries; use `@MainActor` on view models that touch UI state.
- Avoid force unwraps (`!`) outside test fixtures and stable IBOutlets.
- Use `Result` and typed throws (`throws(MyError)`) where supported in 6.x
  for predictable error paths.
- SwiftUI views are stateless when possible; state lives in `@Observable`
  view models. No `@StateObject` for shared state — pass via environment.
- File and type naming: `FeatureNameView.swift`, `FeatureNameViewModel.swift`,
  `FeatureNameRepository.swift`.

## Kotlin / Jetpack Compose / Android

- `Kotlin 2.1+` with `explicit API mode` on shared modules.
- All threading flows through coroutines. Never block on `runBlocking` in
  app code; reserve it for tests.
- Compose: hoist state. `@Composable` functions either render inputs or
  delegate to a `ViewModel`; do not own mutable state directly.
- Use `StateFlow` / `Flow` for reactive streams; avoid `LiveData` in new
  code.
- Use Hilt (or Koin where chosen) for DI; never resort to service locators.
- File naming: `FeatureNameScreen.kt`, `FeatureNameViewModel.kt`,
  `FeatureNameRepository.kt`. Tests: `FeatureNameViewModelTest.kt`.

## Dart / Flutter

- `analyzer: strict-casts: true; strict-inference: true; strict-raw-types: true`.
- Widgets are pure; state lives in the chosen state-management layer
  (Riverpod, Bloc, or Provider). No `setState` in feature widgets — only
  in leaf-level local UI controls (e.g., a custom slider's drag tracking).
- Async work uses `Future`/`Stream` with cancellation tokens where
  appropriate (e.g., `CancelToken` from `dio`).
- File naming: `snake_case.dart`. One widget per file unless the
  companion widget is private to its parent.

## PRD (Product Requirements Document) Standards

PRDs live in `design/prd/[feature-slug].md`. Every PRD has these sections:

1. **Overview** — one paragraph: what, why, success metric.
2. **User Goal & Job-To-Be-Done** — the user's intent in their words.
3. **Detailed Requirements** — unambiguous, numbered functional rules.
4. **Flows** — primary path plus error/edge paths, linked to
   `design/flows/`.
5. **Edge Cases** — explicitly enumerated weird states (offline, denied
   permission, expired token, low battery, locale fallback).
6. **Dependencies** — other PRDs, ADRs, third-party SDKs, backend endpoints.
7. **Tunables / Remote Config** — flags, thresholds, A/B knobs and their
   defaults.
8. **Acceptance Criteria** — testable, in `Given / When / Then` form.
9. **Analytics & Telemetry** — events emitted, properties, success metric.
10. **Accessibility** — WCAG/A11y requirements specific to this feature.
11. **Localization Notes** — pluralization, RTL, longest-string fitting,
    locale-specific formats.

## Test Evidence by Story Type

Every story must produce evidence appropriate to its type before `/story-done`
will close it.

| Story Type | Required Evidence | Location | Gate Level |
|---|---|---|---|
| **Logic** (validators, formulas, state machines, reducers) | Passing automated unit test | `tests/unit/[feature]/` | BLOCKING |
| **Integration** (API + cache, offline sync, push handling) | Passing integration test or documented manual run with fixtures | `tests/integration/[feature]/` | BLOCKING |
| **UI** (screens, components, gestures) | Component test or screenshot diff + lead sign-off | `production/qa/evidence/` | ADVISORY |
| **Animation / Motion** (transitions, micro-interactions) | Screen recording + motion-director sign-off | `production/qa/evidence/` | ADVISORY |
| **Config / Remote** (feature flags, A/B knobs) | Smoke check pass on each variant | `production/qa/smoke-[date].md` | ADVISORY |
| **Accessibility** | A11y audit run + screen reader walkthrough | `production/qa/evidence/a11y-` | BLOCKING |

## Automated Test Rules

- **Naming**: `[feature]-[capability].test.[ext]` for files;
  `test name should describe behaviour` (BDD-style) for assertions.
- **Determinism**: no random seeds, no clock-dependent assertions, no
  network calls. Inject clocks and randomness.
- **Isolation**: every test sets up and tears down its own state. Tests
  must pass when run alone or in any order.
- **No magic literals** in fixtures. Use factories or named constants.
  Boundary-value tests are exempt — the literal is the test.
- **No real I/O.** Mock the network, disk, and platform APIs.

## What NOT to Automate

- Pixel-perfect rendering across every device family (use device farms,
  not unit tests).
- Real push delivery (verify the handler with fixtures; defer end-to-end
  to a manual TestFlight/Play track).
- Real IAP purchase flows beyond the sandbox path.
- Subjective qualities — "feels snappy", "looks premium" — these belong
  in lead reviews and beta tests.

## Accessibility Standard

- WCAG 2.2 AA is the floor. Higher conformance is celebrated.
- Apple Accessibility: VoiceOver labels, traits, hints; rotor support for
  collections; reduce-motion respect.
- Android Accessibility: TalkBack labels, semantic roles, focus order;
  Switch Access; honour `Settings.System.ANIMATOR_DURATION_SCALE` 0.
- Hit targets: 44x44 pt (iOS), 48x48 dp (Android).
- Dynamic Type / font scale support up to system maximum.
- Colour contrast: 4.5:1 text, 3:1 large text and UI.

## CI / CD Rules

- The unit + integration suite runs on every push to `main` and every PR.
  Failed tests block merge.
- Skipping or disabling tests to make CI green is forbidden. Fix the test
  or fix the bug.
- Framework-specific runners:
  - **React Native**: `yarn test --ci`, `yarn lint`, `yarn typecheck`,
    `detox test --configuration ios.sim.release` on PR (nightly for full matrix).
  - **Flutter**: `flutter analyze`, `flutter test --coverage`,
    `flutter drive` for integration tests.
  - **iOS**: `xcodebuild test -scheme App -destination 'platform=iOS Simulator,name=iPhone 16'`.
  - **Android**: `./gradlew lint test connectedAndroidTest` (or `managedDevices` on CI).
- Release builds always run a clean install and a clean build cache.
  Reproducibility matters more than speed for shipping artefacts.
