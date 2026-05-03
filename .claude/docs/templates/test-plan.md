<!--
name: test-plan
purpose: Sprint or feature-level test plan. Classifies stories by type, lists automated coverage, manual cases, device matrix, smoke scope, and sign-off rules. Authored by qa-lead before implementation begins.
consumed-by: /qa-plan, /team-qa, /smoke-check, /test-evidence-review
placeholders:
  - {{plan_id}}
  - {{scope_name}}
  - {{author}}
  - {{date}}
  - {{sprint_or_feature}}
-->

# Test Plan: {{scope_name}}

| Field | Value |
|-------|-------|
| Plan ID | {{plan_id}} |
| Scope | Sprint {{sprint_id}} / Feature {{feature_name}} / Release {{version}} |
| Author (QA lead) | {{author}} |
| Date | {{date}} |
| Status | Draft / Approved / In Execution / Complete |

## Scope

What is in scope for this plan and what is explicitly out.

### In scope

- {{story_or_feature}}
- {{story_or_feature}}

### Out of scope

- {{deferred}}

## Story Classification

| Story | Type | Test Approach | Required Evidence | Gate |
|-------|------|---------------|--------------------|------|
| STORY-NN | Logic | Automated unit test | passing test in `tests/unit/` | BLOCKING |
| STORY-NN | Integration | Integration test or documented playthrough | `tests/integration/` or `production/qa/evidence/` | BLOCKING |
| STORY-NN | Visual | Screenshot + design lead sign-off | `production/qa/evidence/` | ADVISORY |
| STORY-NN | UI | Walkthrough doc or interaction test | `production/qa/evidence/` | ADVISORY |
| STORY-NN | Config | Smoke pass | `production/qa/smoke-{{date}}.md` | ADVISORY |

## Automated Coverage

### Unit tests

| System | Cases | File |
|--------|-------|------|
| | | `tests/unit/{{system}}/{{name}}_test.{{ext}}` |

### Integration tests

| Flow | Cases | File |
|------|-------|------|
| | | `tests/integration/{{flow}}/{{name}}_test.{{ext}}` |

### UI / interaction tests

| Surface | Tool | Cases |
|---------|------|-------|
| iOS | XCUITest / XCTest | |
| Android | Espresso / Compose UI Test | |
| RN | Detox / Maestro | |
| Flutter | `flutter_test` widget + integration_test | |

### Performance tests

- Cold start budget: {{ms}}ms p95 on {{device}}
- Frame budget: {{ms}}ms / 60fps
- Memory ceiling: {{mb}}MB sustained

## Manual Test Cases

| ID | Title | Pre-conditions | Steps | Expected | Priority |
|----|-------|----------------|-------|----------|----------|
| TC-1 | | | 1.<br>2.<br>3. | | P0 |

## Device Matrix

QA executes manual cases on every row of the matrix unless noted.

### iOS

| Device | OS | Notch / Dynamic Island | Notes |
|--------|----|-----------------------|-------|
| iPhone SE (3rd gen) | 16.x | No | minimum supported |
| iPhone 13 | 17.x | Notch | mid range |
| iPhone 15 Pro | 18.x | Dynamic Island | latest |
| iPad (10th gen) | 17.x | — | tablet smoke (if supported) |

### Android

| Device | OS | API | Notes |
|--------|----|-----|-------|
| Pixel 6a | 13 | 33 | mid range |
| Samsung Galaxy A15 | 14 | 34 | OEM skin (One UI) |
| Pixel 8 | 15 | 35 | latest |
| Foldable (Z Fold / Pixel Fold) | 14 | 34 | if foldable support claimed |

### Network conditions

- Wi-Fi (full)
- LTE good
- LTE poor (3G throttle)
- Airplane mode (offline)
- Captive portal (hotel Wi-Fi simulation)

## Smoke Test Scope

The minimum set that MUST pass before QA hand-off. Run after every nightly
build.

- [ ] App launches on iOS + Android without crash
- [ ] Cold start under {{ms}}ms on baseline device
- [ ] Sign-in flow completes
- [ ] Primary flow completes end-to-end
- [ ] Push notification received and deep-links correctly
- [ ] App resumes correctly after backgrounding
- [ ] Crash reporter captures forced crash
- [ ] Telemetry SDK fires startup event

## Accessibility Checks

- [ ] VoiceOver navigation through every new screen
- [ ] TalkBack navigation through every new screen
- [ ] Dynamic Type / Font Scale 200% layout passes spot check
- [ ] Reduce Motion respected
- [ ] Contrast on new components passes WCAG AA

## Localization Checks

- [ ] Strings rendered in {{locales}}
- [ ] No string overflow / truncation in DE / FR / RU / JA samples
- [ ] RTL layout (AR / HE) renders correctly
- [ ] Date / number formatting respects locale

## Sign-off

A story is complete when:

- All BLOCKING evidence rows for its type are present
- Automated tests pass on CI
- Manual cases executed and recorded in `production/qa/evidence/`
- QA lead recorded approval below

| Story | QA sign-off | Date |
|-------|-------------|------|
| | | |
