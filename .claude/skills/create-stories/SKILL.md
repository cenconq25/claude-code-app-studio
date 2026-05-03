---
name: create-stories
description: "Decomposes a single epic into implementable story files. Each story embeds its TR-ID, governing ADR, acceptance criteria, story type, and test-evidence path. Run after /create-epics for each epic, in dependency order. Stories are what developers pick up — epics are what architects define."
argument-hint: "<epic-slug | epic-path> [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Task, AskUserQuestion
model: sonnet
---

# Create Stories

A story is a single implementable behavior — small enough for one focused session, traceable to a TR-ID and an ADR. This skill produces story files that `/dev-story` and `/story-readiness` (in the second skill set) will read.

Output: `production/epics/<epic-slug>/story-NNN-<slug>.md`

---

## Phase 1: Parse Argument

Resolve review mode (`--review` or `production/review-mode.txt`, default `lean`).

Acceptable arg forms:
- `<epic-slug>` (e.g., `auth-sign-in`)
- Full path to `EPIC.md`
- Empty — list available epics and ask which

If no epics exist, stop and recommend `/create-epics`.

---

## Phase 2: Load the Epic & Its World

Read in full:
- `production/epics/<slug>/EPIC.md`
- The PRD listed in EPIC Section 2
- Each ADR listed in EPIC Section 3
- `docs/architecture/control-manifest.md` (note Manifest Version)

**ADR existence check**: confirm every governing ADR file exists on disk. If any is missing, halt:
> "Epic references ADR-NNNN but `docs/architecture/ADR-NNNN-...md` does not exist. Cannot decompose stories until that file is in place. Run `/architecture-decision` to create it."

Report: "Loaded epic <name>, PRD <file>, <N> governing ADRs, manifest version <date>."

---

## Phase 3: Classify Story Types

Mobile-app story types:

| Type | Use when criteria reference… |
|---|---|
| **Logic** | Calculations, validation rules, state transitions, business decisions |
| **Integration** | Two systems interacting (e.g., auth → push token registration) |
| **Visual / Feel** | Animation, transitions, motion, "feels responsive", micro-interactions |
| **UI** | Static screens, menus, settings forms, modals |
| **Config / Data** | Token / threshold / copy changes only — no new code logic |
| **Platform** | Framework-specific glue (push setup, biometrics, IAP plumbing) |

Mixed stories: pick the type that carries the highest implementation risk. The type determines the test-evidence requirement.

---

## Phase 4: Decompose

For each PRD Acceptance Criterion in scope:
1. Group related criteria that share a single implementation
2. Each group = one story
3. Order: Foundation behavior → Core → Edge cases → UI polish

Sizing rule: one story = ~2-4 hours. Larger groups split.

For each story, determine:
- **Title** (action-oriented, e.g., "Implement OAuth login network call")
- **TR-ID(s)** covered (from `tr-registry.yaml` if present, else `TR-<system>-NNN`)
- **Governing ADR**:
  - Accepted → embed
  - Proposed → set Status: Blocked with note "BLOCKED: ADR-NNNN is Proposed. Run `/architecture-decision` to advance."
- **Story type** (Phase 3)
- **Framework risk** from the ADR's Framework Compatibility table
- **Test evidence path** based on type

---

## Phase 5: QA Gate (Review Mode Dependent)

If review mode is `full`, spawn `qa-lead` (Task) to validate that decomposed stories' acceptance criteria are testable. Surface findings; iterate until all stories are ADEQUATE.

If review mode is `lean` or `solo`, skip and proceed.

For Logic and Integration stories, ask the qa-lead to produce concrete test specs in this format:

```
Test: <criterion text>
  Given: <precondition>
  When: <action>
  Then: <expected>
  Edge cases: <boundary values>
```

For Visual/Feel and UI, produce manual checks:
```
Manual check: <criterion>
  Setup: <how to reach state>
  Verify: <what to look for>
  Pass: <unambiguous pass>
```

These specs embed in each story's `## QA Test Cases` section.

---

## Phase 6: Present Stories Before Writing

```
## Stories for Epic: <name>

Story 001: Implement OAuth network call — Logic — ADR-0003
  Covers: TR-auth-001, TR-auth-002
  Test required: tests/unit/auth/oauth-call_test.<ext>

Story 002: Persist refresh token securely — Integration — ADR-0003 + ADR-0007
  Covers: TR-auth-003
  Test required: tests/integration/auth/token-storage_test.<ext>

Story 003: Login screen layout — UI — ADR-0009
  Covers: TR-auth-005, TR-auth-006
  UX spec: design/ux/login.md
  Evidence required: production/qa/evidence/login-walkthrough.md

[N stories total: <count by type>]
```

Ask `AskUserQuestion`:
- `Yes — write all <N> stories`
- `Not yet — review or adjust first`

---

## Phase 7: Write Story Files

For each, write `production/epics/<slug>/story-NNN-<title>.md`:

```markdown
# Story NNN: <title>

> **Epic**: <epic name>
> **Status**: Ready
> **Layer**: <Foundation / Core / Feature / Polish>
> **Type**: <Logic | Integration | Visual/Feel | UI | Config/Data | Platform>
> **Manifest Version**: <date>

## Context

**PRD**: `design/prd/<system>.md`
**Requirement**: `TR-<system>-NNN`
*(Requirement text in `docs/architecture/tr-registry.yaml` — re-read at review time.)*

**ADR Governing Implementation**: ADR-NNNN: <title>
**ADR Decision Summary**: <1-2 sentence summary>

**Framework**: <name + version> | **Risk**: <LOW / MEDIUM / HIGH>
**Framework Verification Required**: <from ADR Framework Compatibility section>

**Control Manifest Rules (this layer)**:
- Required: <relevant required pattern>
- Forbidden: <relevant forbidden pattern>
- Guardrail: <relevant performance guardrail>

**UX Spec (UI stories)**: `design/ux/<screen>.md` — pinned to commit at story creation

## Acceptance Criteria

*From `design/prd/<system>.md`, scoped to this story:*

- **GIVEN** <state> **WHEN** <action> **THEN** <observable result>
- ...

## QA Test Cases

*Pre-written by `qa-lead` (in `full` review) or by you before implementing.*

[Logic / Integration: GIVEN-WHEN-THEN test specs]
[Visual/Feel / UI: manual verification steps]

## Test Evidence Path

- Type: <Logic | Integration | Visual/Feel | UI | Config/Data | Platform>
- Required path: <e.g., `tests/unit/auth/oauth-call_test.ts`>
- Pass condition: <what passing looks like>

## Mobile-Specific Considerations

- iOS: <if any platform-specific behavior>
- Android: <if any>
- Min OS: <floor>
- Permissions touched: <list or none>
- Analytics events emitted: <list or none>
- Feature flag gating: <flag name or none>

## Out of Scope (this story)

- <items deferred to other stories — link the story numbers when known>

## Definition of Done

- [ ] Implementation matches Acceptance Criteria
- [ ] Test evidence at the specified path passes
- [ ] No control-manifest violations introduced
- [ ] Code review passed (if applicable per review mode)
- [ ] Story status updated to Complete via `/story-done`

## Open Questions

- <any — should be resolved before starting>
```

---

## Phase 8: Update the Epic

Append to the epic's `## 13. Story Backlog` section:

```
## 13. Story Backlog

| Story | Title | Type | Status |
|-------|-------|------|--------|
| 001 | Implement OAuth network call | Logic | Ready |
| 002 | Persist refresh token securely | Integration | Ready |
| 003 | Login screen layout | UI | Ready |
| ... | | | |
```

Update Section 5 of the epic (Requirements Covered) — fill in the `Story slug` column.

---

## Phase 9: Hand Off

Print:
> "<N> stories written. Update sprint plan via `/sprint-plan` to assign these to a sprint, then start implementation with `/dev-story <story-path>`."

Use `AskUserQuestion`:
- `Run /sprint-plan now`
- `Run /create-stories for the next epic`
- `Run /story-readiness <first story>` to validate readiness
- `Stop here`

---

## Quality Gates

- Every story has Status, Type, Manifest Version, TR-ID, ADR reference, Acceptance Criteria, Test Evidence Path
- For UI stories with a UX spec, the UX path is pinned in the story
- Stories sized to ~2-4 hours; warn loudly if any story has 6+ acceptance criteria
- Every story's ADR is verified Accepted (else Status: Blocked)
- The epic's Story Backlog is updated atomically with the story writes

---

## Examples

`/create-stories auth-sign-in`
- 12 TR-IDs in epic
- 8 stories: 3 Logic, 2 Integration, 2 UI, 1 Platform
- Story 005 references ADR-0007 (biometric) which is Proposed → marked Blocked
- Output: 8 story files + updated EPIC.md
