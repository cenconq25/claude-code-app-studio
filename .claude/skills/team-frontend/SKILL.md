---
name: team-frontend
description: "Orchestrate the mobile UI build. Coordinates lead-developer, framework specialist (RN/Flutter/iOS/Android), state-management specialist, and animation-specialist to ship a feature's frontend layer end-to-end."
argument-hint: "[--feature=<name> | --epic=<slug>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
agent: lead-developer
model: sonnet
---

# Team Frontend

Front-end-of-the-mobile-app orchestrator. Once a design package and a
PRD exist, this skill coordinates the engineering roles that turn it
into screens, animations, and state plumbing. It does not build the
backend (see `/team-backend`).

---

## Team Composition

- **lead-developer** — feature owner, integration glue, sign-off on
  the diff.
- **framework specialist** — chosen per project: react-native-specialist,
  flutter-specialist, ios-specialist, or android-specialist (and
  their UI sub-specialists).
- **state-management specialist** — Redux / Zustand / Riverpod /
  Provider / Combine / MVI / Compose state.
- **animation-specialist** — motion + haptic implementation.

Spawn each via Task. Parallelize where dependencies allow.

---

## Phase 1: Resolve Feature Scope

Parse argument:

- `--feature=<name>` -> glob related stories.
- `--epic=<slug>` -> read `production/epics/[slug]/`.
- No argument -> ask the user which feature.

Read in parallel:

- The design package at `design/packages/[feature]-design.md` (if
  produced via `/team-design`).
- The PRD under `design/prd/`.
- Governing ADRs from `docs/architecture/`.
- Stories under the epic — read each story's status.
- `.claude/docs/technical-preferences.md` for framework + state
  conventions.

Confirm scope: "[N] stories under [epic]. Build front-end layer now?"

---

## Phase 2: Routing — Pick the Specialists

Read the framework. Resolve specialists:

| Framework | UI specialist | State specialist | Animation specialist |
|-----------|---------------|------------------|----------------------|
| React Native | rn-screens-specialist | redux-or-zustand-specialist | rn-reanimated-specialist |
| Flutter | flutter-widgets-specialist | riverpod-or-bloc-specialist | flutter-animation-specialist |
| iOS | swiftui-specialist | combine-specialist | swiftui-animation-specialist |
| Android | jetpack-compose-specialist | mvi-specialist | compose-animation-specialist |

If specialists are not declared in technical-preferences, fall back to
the umbrella framework specialist.

---

## Phase 3: Architecture Slice via lead-developer

Spawn `lead-developer` via Task. Prompt template:

> Feature: [name]. Design package: [path]. PRD: [path]. Plan the
> front-end architecture slice: directory layout, component
> boundaries, state shape, navigation entries, dependency injection
> wiring. Identify which stories must land before any UI can render
> ("foundation" stories). Identify any new shared component to extract
> for reuse.

Render the slice. Use AskUserQuestion to approve. The slice becomes
the implementation order for Phase 4-6.

---

## Phase 4: State Layer (parallel with Phase 5)

Spawn the state-management specialist via Task. Prompt template:

> Slice: [reference]. PRD: [reference]. Implement the state layer:
> the store / providers / view models, actions / reducers / events,
> selectors / derivations, side-effect handlers (sagas / thunks /
> effects / interactors). Wire to the data layer interface (the
> backend layer is implemented elsewhere — depend on the contract,
> not the implementation). Write unit tests for every reducer /
> selector / view-model.

Per-story Task spawns are independent and can run in parallel.

---

## Phase 5: UI Layer (parallel with Phase 4)

Spawn the framework UI specialist via Task. Prompt template:

> Slice: [reference]. Design package: [reference]. State contract:
> [interface or store shape]. Build the screens listed in the design
> package. Use existing pattern library where applicable; extract new
> shared components only when the slice plan calls for it. Wire
> accessibility: dynamic type ranges, contrast, screen reader, reduced
> motion. Write component-level tests.

Each screen story spawns its own Task. Run in parallel.

For Visual/Feel acceptance criteria, defer manual sign-off to
`/story-done` per the project's standard.

---

## Phase 6: Motion Layer

Spawn the animation specialist via Task. Prompt template:

> Slice: [reference]. Motion spec from design package: [reference].
> Implement transitions, microinteractions, haptic pairings, and
> reduced-motion fallbacks. Confirm performance: every animation
> within 16ms on Tier A devices and 33ms on Tier C. Surface any
> motion that risks the frame budget; propose a degraded-motion
> alternative if needed.

---

## Phase 7: Integration via lead-developer

Once Phases 4-6 complete, spawn `lead-developer` via Task to integrate:

- Wire UI to state.
- Wire navigation entries.
- Wire feature flags.
- Wire analytics events as defined in the PRD.
- Run a local smoke pass.

Render an integration verdict: CLEAN / FIXES NEEDED.

If fixes needed, loop back to the relevant specialist with the gap.

---

## Phase 8: Cross-Cutting Reviews

Spawn in parallel:

- `qa-tester` to confirm test seams exist for each story.
- The framework specialist to run a final architecture review.
- `accessibility-specialist` if the project includes one — to verify
  the accessibility checklist.

Aggregate findings.

---

## Phase 9: Per-Story Closeout

For each story in the epic, run `/story-done` (or simulate the same
checks inline if the orchestrator chooses to consolidate):

- AC verification.
- Code review pass via `/code-review`.
- Status update to Complete.

Only proceed to the next epic when every story closes.

---

## Phase 10: Compose the Build Report

```markdown
# Frontend Build Report — [feature]

Sprint(s) involved: [list]
Stories completed: [list]
Specialists engaged: [list]

## Architecture Slice
[summary]

## State Layer
- Files: [list]
- Tests: [count, all PASS]

## UI Layer
- Screens: [list]
- Component tests: [count]

## Motion Layer
- Transitions: [count]
- Microinteractions: [count]
- Reduced-motion fallbacks: [count]

## Accessibility
- Dynamic type tested: [yes/no]
- Screen reader walkthrough: [yes/no]
- Reduced motion: [yes/no]
- Contrast: [pass/fail]

## Performance
- Frame check on Tier A: [PASS/FAIL]
- Cold start delta: [+/-Nms]

## Verdict: COMPLETE / FIXES NEEDED
```

Ask before writing to `production/build/[feature]-frontend-build.md`.

---

## Phase 11: Update State

Append to `production/session-state/active.md`:

```
## Frontend Build — [date]
- Feature: [name]
- Stories: [count] — all Complete
- Tests: [count] PASS
- Verdict: [verdict]
- Build report: [path]
- Next: /team-backend if not run, then /team-qa, then integrate to main
```

---

## Error Recovery

If any subagent returns BLOCKED:

- state specialist blocked on missing data layer contract -> wait for
  `/team-backend` to land the contract.
- UI specialist blocked on missing design spec -> back to
  `/team-design`.
- Animation specialist blocked on frame budget -> propose simplified
  motion.
- Integration phase reveals contract mismatch -> loop to
  `/team-backend`.

---

## Quality Gates / PASS-FAIL

- COMPLETE — every story closed via `/story-done`, every test green,
  smoke pass clean, accessibility checks pass.
- FIXES NEEDED — at least one story open or one specialist surfaced a
  blocker.

---

## Examples

**Example 1 — paywall feature on RN:**
4 screens + 2 sheets + 3 transitions. 9 stories. State specialist
implements paywall reducer; RN specialist builds screens; animation
specialist adds the celebrate-success transition. lead-developer
integrates. All stories close.

**Example 2 — single-screen polish on Flutter:**
Single story. Just framework specialist + lead-developer. Skips state
layer changes. Closes via `/story-done`.

---

## Next Steps

- `/team-backend` for any uncompleted server-side dependency.
- `/team-qa` after frontend + backend land.
- `/perf-profile` if the feature added new heavy lists or animations.
