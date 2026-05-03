---
name: dev-story
description: "Read a story file and implement it end-to-end. Loads PRD requirement, governing ADR, control manifest, and routes to the right framework specialist (RN/Flutter/iOS/Android). Use when a story has passed /story-readiness and is ready to be built."
argument-hint: "[story-path]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion
model: sonnet
---

# Dev Story

Turn a planned story into shipped code. This skill assembles every piece of
context an implementing agent needs (story file, current PRD requirement,
governing ADR, control manifest, framework conventions), routes the work to
the right mobile specialist, and supervises implementation through to test.

**Where this lives in the loop:**

```
/qa-plan sprint               -> define test bars before sprint starts
/story-readiness [path]       -> green-light the story
/dev-story [path]             -> THIS skill — implement + test
/code-review [files]          -> review the diff
/story-done [path]            -> verify ACs and close
```

**Output:** new or modified files in `src/`, plus a test file in `tests/`.

---

## Phase 1: Locate the Story

Resolve the story path:

- If a path argument is supplied, read it directly.
- If no argument, open `production/session-state/active.md` and look for a
  current story reference. Confirm with the user before proceeding.
- If neither path is available, glob `production/epics/**/story-*.md` and
  list every story whose `Status:` is `Ready`. Ask the user to pick one.

If the story file does not exist, stop and tell the user to run
`/create-stories` for the relevant epic.

---

## Phase 2: Assemble Full Context

Before writing a single line of code, validate that every required input
exists. These reads are independent — issue them in parallel.

| Artifact | Path | Missing handling |
|----------|------|------------------|
| TR registry | `docs/architecture/tr-registry.yaml` | STOP — tell the user to run `/create-epics`. |
| Governing ADR | path from story `ADR Governing Implementation:` field | STOP — tell the user to run `/architecture-decision` or fix the path. |
| Control manifest | `docs/architecture/control-manifest.md` | WARN — continue but note that layer rules are unchecked. |
| Framework prefs | `.claude/docs/technical-preferences.md` | WARN — framework routing falls back to "ask user". |

Mark the story `BLOCKED` in session state and abort if the TR registry or
governing ADR is missing.

### Read from the story file

Extract verbatim and hold in working memory:

- Title, ID, Layer (Foundation / Core / Feature / Polish)
- Story Type — `Logic`, `Integration`, `Visual/Feel`, `UI`, `Config/Data`
- TR-ID — the PRD requirement code
- Governing ADR reference
- Manifest Version stamp
- Acceptance Criteria — every checkbox, exactly as written
- Implementation Notes (the ADR-derived guidance)
- Out of Scope boundaries
- Test Evidence path (where the test must land)
- Dependencies (other story IDs that must be Done first)

### Read from the TR registry

Look up the story's TR-ID in `docs/architecture/tr-registry.yaml`. The
`requirement:` field is the live source of truth — the inline copy in the
story may be stale. If the story text and registry text disagree, surface the
delta to the user before proceeding.

### Read from the governing ADR

Pull these sections verbatim from `docs/architecture/[adr-file].md`:

- Decision
- Implementation Guidelines (this is what the implementing agent follows)
- Platform / Framework Compatibility (post-cutoff API risks, deprecations)
- Dependencies on other ADRs

### Read the control manifest

Find the rules block for this story's Layer. Capture:

- Required patterns (must use)
- Forbidden patterns (must not use)
- Performance guardrails (frame budget, allocation rules, async rules)

Compare the manifest's header date against the story's `Manifest Version:`
stamp. If they differ, use AskUserQuestion:

- Prompt: "Story was authored against manifest v[story-date]. Current is v[live-date]. Proceed how?"
- Options:
  - `[A] Bump story to current manifest and apply new rules (recommended)`
  - `[B] Implement under old rules — accept non-compliance risk`
  - `[C] Stop — let me review the manifest diff first`

For [A], edit the story's Manifest Version field before continuing. For [B],
record the mismatch in the final summary as a Deviation. For [C], abort.

### Validate dependencies

For each entry in the story's Dependencies list:

1. Glob `production/epics/**/*.md` to find the dependency story.
2. Read its Status.
3. If Status is not `Complete` or `Done`, ask the user via AskUserQuestion:
   - `[A] Proceed — accept the risk`
   - `[B] Stop — finish the dependency first`
   - `[C] Dependency is actually done — update its status and continue`

If [B], mark the current story BLOCKED and stop. If a dependency story file
cannot be found, warn but allow the user to proceed.

---

## Phase 3: Route to the Right Specialist

Read `.claude/docs/technical-preferences.md` to determine the configured
framework. Combine framework + Layer + Type to choose the implementing agent
via the Task tool.

### Config/Data shortcut

If Story Type is `Config/Data`, no specialist agent is needed. Skip Phase 3
and Phase 5 — go directly to Phase 4 and edit the data file yourself.

### Primary routing table

| Story context | Primary agent |
|---------------|---------------|
| Foundation layer (build config, dependency wiring) | `lead-developer` |
| Any layer — Type: UI | `lead-developer` (paired with framework UI specialist) |
| Any layer — Type: Visual/Feel (animation, haptics, motion) | `animation-specialist` |
| Core/Feature — backend/data/sync work | `backend-engineer` |
| Core/Feature — push/notification flow | `push-notification-specialist` |
| Core/Feature — general feature logic | `lead-developer` |

### Framework specialist (always paired for code stories)

Read the Framework Specialists section of `technical-preferences.md`. Spawn
the relevant specialist alongside the primary agent when:

- The story touches framework-specific APIs (lifecycle, navigation, state).
- The governing ADR carries HIGH framework-version risk.
- The story modifies build configuration (Gradle, Xcode, Metro, pubspec).

| Framework | Specialists available |
|-----------|-----------------------|
| React Native | `react-native-specialist`, `typescript-specialist`, `state-management-specialist` |
| Flutter | `flutter-specialist`, `dart-specialist`, `state-management-specialist` |
| iOS native (Swift/SwiftUI) | `ios-specialist`, `swift-specialist`, `swiftui-specialist` |
| Android native (Kotlin/Compose) | `android-specialist`, `kotlin-specialist`, `jetpack-compose-specialist` |

When framework version risk is HIGH, the framework specialist is mandatory
even for "boring" stories — they verify post-cutoff API usage.

---

## Phase 4: Implement

Spawn the chosen agent(s) via Task with a complete context payload. The Task
prompt must contain:

1. The full story file content
2. The live PRD requirement text (from TR registry, not the story copy)
3. The ADR Decision and Implementation Guidelines verbatim
4. Control manifest rules for this layer
5. Naming conventions and performance budgets from technical-preferences
6. Any framework compatibility caveats from the ADR
7. The required test file path
8. An explicit instruction: "Implement this story AND write its test."

The agent is responsible for:

- Creating or modifying files only in `src/` and within the story's Out of
  Scope boundaries.
- Following the ADR's guidelines (not silently substituting a "better" one).
- Adding doc comments on every public function, class, hook, or extension.
- Respecting frame budget and cold-start budget rules from the manifest.

### Config/Data path

For Type: Config/Data the orchestrator edits the relevant config file
(remote-config JSON, feature flag YAML, paywall plist, A/B test variant).
Record the before/after value pair in the Phase 6 summary.

### Visual/Feel path

Spawn `animation-specialist` to implement motion, easing, and haptics. The
"does it feel right" verdict is deferred — Visual/Feel ACs are confirmed
manually in `/story-done` against the recorded screen capture.

---

## Phase 5: Write the Test

For Logic and Integration stories, the test ships in the same change as the
implementation. State this to the implementing agent:

> "The test for this story belongs at `[Test Evidence path]`. The story
> cannot be closed via `/story-done` without it. Write the test alongside
> the implementation, not after."

Test rules from the project standards:

- File name: `[module]_[feature]_test.[ext]` (`.test.tsx`, `.test.dart`,
  `Tests.swift`, `Test.kt`).
- Function names: `test_[scenario]_[expected]`.
- Each acceptance criterion must be covered by at least one assertion.
- No real network, no real disk, no real time — inject everything.
- Cover boundary values from the PRD's Formulas / Pricing / Limits sections.

For Visual/Feel and UI stories: no automated test is required, but instruct
the agent to note in the summary which evidence doc must be produced —
`production/qa/evidence/[story-slug]-evidence.md` plus a screenshot or screen
recording attached.

For Config/Data: a smoke check stands in for the test.

---

## Phase 6: Collect, Verify, Summarise

After agents return, gather:

- All files created or modified, with paths.
- The test file path and the count of test functions.
- Any boundary the agent crossed against the Out of Scope list.
- Any open questions or blockers the agent surfaced.
- Any framework-version risks the specialist flagged.

Render a summary block:

```
## Implementation Complete: [Story Title]

**Files changed**:
- src/[path] — created/modified ([brief reason])
- tests/[path] — N test functions added

**Acceptance criteria coverage**:
- [x] [AC1] — implemented in [file:function]
- [x] [AC2] — covered by test [test_name]
- [ ] [AC3] — DEFERRED to /story-done (Visual/Feel)

**Deviations from scope**: [None | list]
**Framework risks flagged**: [None | specialist note]
**Blockers**: [None | description]

Next: /code-review [files] then /story-done [story-path]
```

---

## Phase 7: Update Session State

Append to `production/session-state/active.md` (create the file if it does
not exist):

```
## Session Extract — /dev-story [date]
- Story: [path] — [title]
- Files: [comma list]
- Test: [path | None — Visual/Feel/Config]
- Blockers: [None | description]
- Next: /code-review then /story-done
```

Confirm: "Session state updated."

---

## Quality Gates / PASS-FAIL

This skill is a workflow, not a verdict skill. Success conditions:

- All required context files were read before code was written.
- Implementation stayed inside Out of Scope boundaries.
- Test file exists for every Logic/Integration story.
- Acceptance criteria each map to either a code path or a deferred
  evidence note — no AC is silently skipped.

Failure modes that block progression:

- Missing TR registry or governing ADR.
- Dependency story not Done and user chose to stop.
- Manifest version mismatch the user refused to resolve.
- Implementing agent reported BLOCKED from Phase 4.

---

## Error Recovery

If a Task subagent returns BLOCKED:

1. Surface immediately: "[agent]: BLOCKED — [reason]".
2. Identify whether downstream phases need its output.
3. Offer options via AskUserQuestion: skip and gap-note, retry narrower,
   or stop and resolve.
4. Always write the partial summary — never discard partial work.

Common blockers and the right next step:

- Story missing -> `/create-stories`
- ADR Status `Proposed` -> `/architecture-decision`
- Story scope too large -> split via `/create-stories`
- ADR vs story conflict -> surface, do not guess
- Framework knowledge gap -> spawn the framework specialist with the
  WebSearch tool enabled

---

## Examples

**Example 1 — A login screen story (UI/Logic, React Native):**
Read story, load ADR-014 (auth flow), find biometric-auth requirement in TR
registry, confirm manifest version, route to `lead-developer` +
`react-native-specialist`, instruct them to write the screen plus a Detox
flow test, summarise.

**Example 2 — A pricing tier change (Config/Data):**
Read story, no agent spawn, edit `assets/data/pricing.json` to the new tier
values, record diff, point user at smoke check in `/story-done`.
