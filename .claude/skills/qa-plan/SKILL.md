---
name: qa-plan
description: "Generate a QA test plan for a sprint or feature. Reads PRDs and stories, classifies stories by test type (Logic/Integration/Visual/UI/Config), and produces a plan covering automated tests, manual cases, smoke scope, device matrix, and sign-off rules. Run before sprint kickoff or when starting a major feature."
argument-hint: "[sprint-id | feature: <name>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion
model: sonnet
agent: qa-lead
---

# QA Plan

The contract that says: for this scope, here is what will be tested, how,
on which devices, and what defines done. Authored once at sprint start
and referenced by every QA action that follows.

---

## Phase 1: Resolve the Scope

Parse the argument:

- `sprint-NN` -> read `production/sprints/sprint-NN/` and every story
  inside.
- `feature: <name>` -> glob stories tagged for that feature/system.
- No argument -> read `production/session-state/active.md` for the
  current sprint, or ask the user.

Read each story file fully — title, ID, layer, type, acceptance criteria,
dependencies.

Read related PRDs from `design/prd/` to understand the feature context.

Confirm scope and story count with the user.

---

## Phase 2: Classify Each Story

For every story, assign a Test Type:

- **Logic** — pure functions, formulas, state machines, validation,
  pricing math.
- **Integration** — multi-module flows (e.g., sign-up triggers email
  triggers analytics event).
- **Visual/Feel** — animation, motion, haptics, transitions.
- **UI** — screens, navigation, forms, lists.
- **Config/Data** — pricing, feature flags, remote config, copy.

The default mapping when ambiguous:

- Story touches a screen file -> UI.
- Story touches an animation/motion module -> Visual/Feel.
- Story changes pricing/copy/flags only -> Config/Data.
- Story implements a calculation or validator -> Logic.
- Story crosses two modules with side effects -> Integration.

Surface ambiguous classifications via AskUserQuestion before continuing.

---

## Phase 3: Determine Required Evidence

Per Type, the evidence requirement:

| Type | Required evidence | Location |
|------|-------------------|----------|
| Logic | Unit test, must pass in CI | `tests/unit/[module]/` |
| Integration | Integration test or documented manual flow | `tests/integration/[module]/` |
| Visual/Feel | Screenshot or screen recording + lead sign-off | `production/qa/evidence/` |
| UI | Walkthrough doc OR Detox/Maestro/XCUITest/Espresso flow | `production/qa/evidence/` or `tests/e2e/` |
| Config/Data | Smoke check pass | `production/qa/smoke-[date].md` |

For each story, write its required Test Evidence path back into the story
file under `Test Evidence:`. Ask before each edit.

---

## Phase 4: Define the Device Matrix

Read `.claude/docs/technical-preferences.md` for Target Platforms. Propose
a tiered device matrix via AskUserQuestion:

- Tier A — must pass before any release (representative low-end + high-end
  per platform).
- Tier B — covered weekly during the sprint.
- Tier C — covered before milestone gates only.

Defaults if not configured:

- iOS Tier A: latest iPhone, an iPhone two generations old, latest iPad.
- iOS Tier B: an iPhone SE-class small screen, last iOS minor version.
- Android Tier A: a flagship Pixel, a representative mid-range, the
  oldest supported Android version.
- Android Tier B: a low-RAM device, a tablet.

Capture the matrix in the plan.

---

## Phase 5: Smoke Scope

List the critical paths that the smoke check must cover. Default seeds:

- Cold start within budget.
- Sign-in or guest entry succeeds.
- Primary CTA on home reaches its destination without crashing.
- Sign-out succeeds.
- Push notification received in foreground does not crash.
- Deep link from a known URL opens the right screen.

Add any sprint-specific smoke flows (e.g., "new paywall opens and
purchase test card succeeds").

---

## Phase 6: Manual QA Sessions

Estimate effort per Visual/Feel and UI story. Default 30 minutes per UI
story, 45 minutes per Visual/Feel story, plus 1 hour for cross-device
parity.

Render an Effort table:

| Story | Type | Effort | Tester | Devices |
|-------|------|--------|--------|---------|

Surface total manual hours and ask the user whether the sprint has the
capacity.

---

## Phase 7: Compose the Plan Document

```markdown
# QA Plan — [Sprint / Feature]

Author: qa-lead
Date: [date]
Scope: [N] stories
Status: Proposed

## Story Classification
| Story | Type | Evidence Path |

## Automated Test Requirements
- Logic stories needing unit tests: [list]
- Integration stories needing integration tests: [list]

## Manual QA Scope
| Story | Devices | Steps overview | Effort |

## Smoke Scope
[bulleted critical paths]

## Device Matrix
- Tier A: [list]
- Tier B: [list]
- Tier C: [list]

## Out of Scope
[explicit list — what is NOT being tested this cycle and why]

## Entry Criteria
- Smoke check PASS
- All Logic story tests are green in CI
- Build is signed and installable on Tier A devices

## Exit Criteria
- All in-scope stories closed (PASS or FAIL with bug filed)
- No S1 or S2 bugs open
- Test evidence in place per the table above

## Sign-Off
- QA Lead: [name]
- Producer: [name]
```

---

## Phase 8: Save and Update Stories

Ask before each write:

- Write the plan to `production/qa/qa-plan-[sprint]-[date].md`.
- For each story, edit the `Test Evidence:` field to match the table.

Append to `production/session-state/active.md`:

```
## QA Plan Created — [date]
- Plan: [path]
- Stories in scope: [N]
- Smoke scope: [N flows]
- Device matrix: [Tier A counts]
```

---

## Quality Gates / PASS-FAIL

- PASS — every story has a Type, required evidence path, and an
  estimated effort. Smoke scope and device matrix are non-empty.
- FAIL — any story is unclassified or missing an evidence path. Resolve
  before proceeding.

---

## Examples

**Example 1 — Sprint 4 plan:**
Scopes 11 stories. Classifies 5 Logic, 3 Integration, 2 UI, 1 Config.
Surface 1 ambiguous story to user, who reclassifies it Integration.
Writes plan, updates 11 stories. Total manual hours: 6.5.

**Example 2 — Feature plan for "Push Notifications":**
Scopes 4 stories. 2 Integration (server push -> device delivery), 1 UI
(notification settings screen), 1 Config (Firebase project ID swap).
Smoke flow added for foreground/background delivery.

---

## Next Steps

- Run `/test-evidence-review` mid-sprint to verify evidence is materializing.
- Run `/team-qa sprint-NN` at sprint end to execute the cycle.
