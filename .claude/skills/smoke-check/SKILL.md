---
name: smoke-check
description: "Run the critical-path smoke gate before QA hand-off. Executes the automated suite, verifies the core user flows defined in the QA plan, and produces a PASS/FAIL report. A failed smoke check means the build is not ready for QA."
argument-hint: "[--build=<path> | --target=<sim|device>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash, AskUserQuestion
model: sonnet
---

# Smoke Check

A short, blocking gate that runs before manual QA invests time. If smoke
fails, manual QA stops and the build goes back to engineering.

---

## Phase 1: Confirm Build and Target

Parse `--build` (path to .ipa / .apk / app bundle) and `--target` (sim,
emulator, or attached device). If neither is given, infer:

- React Native: prompt to run `npx react-native run-ios` or `run-android`.
- Flutter: prompt to run `flutter run` against the target.
- iOS native: locate the most recent build under `~/Library/Developer/Xcode/DerivedData`.
- Android native: locate the most recent `app-debug.apk` under
  `app/build/outputs/apk/`.

Confirm with the user before launching anything.

---

## Phase 2: Read the Smoke Spec

Read `tests/smoke/critical-paths.md`. This file is authored by `/qa-plan`
and lists the smoke flows for the current sprint.

If missing, fall back to the default smoke set:

1. Cold start within the budgeted ms.
2. App reaches a stable home/landing screen.
3. Sign-in (or guest path) succeeds.
4. Primary CTA on home reaches its destination without a crash.
5. App backgrounds and foregrounds without state loss.
6. Sign-out completes cleanly.

Surface the spec to the user and confirm scope.

---

## Phase 3: Run the Automated Suite

Run the unit + integration test suite first. The smoke gate is "build is
shippable for manual QA", so a red automated suite is automatic FAIL.

Per framework via Bash:

- React Native: `npx jest --silent --reporters=default --bail=false`
- Flutter: `flutter test --machine`
- iOS: `xcodebuild test -scheme [scheme] -destination 'platform=iOS Simulator,name=[device]'`
- Android: `./gradlew testDebugUnitTest connectedAndroidTest`

Capture pass/fail counts and any failure output.

If the unit or integration suite fails, stop here with verdict FAIL and
list the failing tests.

---

## Phase 4: Run E2E Smoke Flows

For each smoke flow in the spec, run the corresponding automated flow:

- Maestro: `maestro test tests/smoke/.maestro/[flow].yaml`
- Detox: `detox test --configuration ios.sim.debug --testNamePattern smoke`
- XCUITest: `xcodebuild test -only-testing:UITests/SmokeUITests`
- Espresso: `./gradlew connectedAndroidTest -PtestFilter=SmokeTest`

Capture per-flow PASS / FAIL / TIMEOUT and the device the flow ran on.

If a smoke flow does not yet have automation, fall back to a manual
walkthrough. Use AskUserQuestion per flow:

```
question: "Smoke flow: [name]\n[steps]"
options:
  - "PASS — flow completed without issue"
  - "FAIL — describe what broke"
  - "BLOCKED — cannot reach this flow"
```

---

## Phase 5: Mobile Health Probes

While the build is on a target, capture quick mobile-health metrics:

- Cold start time on Tier A device (if instrumented).
- Memory after reaching home screen.
- App size on disk.
- Crash log presence — read the device's crash report directory and
  flag any crash dated within the smoke run window.
- Frame drops during the primary navigation path (if a perf marker is
  available).

Compare each value to the budget in
`.claude/docs/technical-preferences.md`. A red probe demotes the verdict
to FAIL even if every smoke flow passed.

---

## Phase 6: Render the Verdict

```
## Smoke Check — [build] — [date]

Target: [device + OS]
Tester: [name]

### Automated Suite
- Unit: [pass]/[total]
- Integration: [pass]/[total]
- E2E smoke: [pass]/[total]
[failures listed verbatim]

### Smoke Flows
| Flow | Result | Notes |
|------|--------|-------|
| Cold start | PASS | 1.6s on iPhone 14 |
| Sign-in | PASS |  |
| Foreground/background | FAIL | state lost on resume |

### Mobile Health
- Cold start: 1.6s (budget 2.0s) PASS
- Memory at home: 142 MB (budget 200 MB) PASS
- Crashes during run: 0
- App size on disk: 78 MB (budget 100 MB) PASS

### Verdict: PASS / PASS WITH WARNINGS / FAIL

[If not PASS, list specifically what must be fixed before re-running.]
```

Verdict rules:

- **PASS** — every automated suite is green, every smoke flow passes,
  every health probe is within budget.
- **PASS WITH WARNINGS** — automated suite green, all smoke flows pass,
  but a non-blocking health probe (e.g., memory usage trending upward
  but inside budget). Document and continue.
- **FAIL** — any of: red automated suite, failing smoke flow, crash
  during the run, or a health probe out of budget.

---

## Phase 7: Save Report and Update State

Ask before writing:

- `production/qa/smoke-[date].md` — the verdict report.

Append to `production/session-state/active.md`:

```
## Smoke Check — [date]
- Target: [device]
- Verdict: [verdict]
- Failing flows: [list or none]
- Next: [/team-qa | fix listed issues then re-run /smoke-check]
```

---

## Quality Gates / PASS-FAIL

This skill IS the gate. The verdict it emits is binding for downstream
QA work.

---

## Examples

**Example 1 — sprint-end smoke on iOS sim:**
Jest 124/124, smoke flows 6/6, cold start 1.4s on iPhone 14, no crashes.
Verdict: PASS. `/team-qa sprint-04` may proceed.

**Example 2 — pre-release smoke on physical Pixel:**
Jest 124/124, but Maestro flow `foreground-background` fails because the
app crashes on resume. Verdict: FAIL. Producer is told to fix before
manual QA starts.

---

## Next Steps

- PASS -> run `/team-qa [sprint]` to execute the manual cycle.
- FAIL -> open a bug via `/bug-report`, fix, re-run `/smoke-check`.
- PASS WITH WARNINGS -> note the warnings in the QA sign-off.
