---
name: create-epics
description: "Translates approved PRDs and architecture into epics — one epic per architectural module or major system. Each epic captures scope, governing ADRs, framework risk, and untraced requirements. Run after /architecture-review passes; do NOT decompose into stories — run /create-stories per epic afterward."
argument-hint: "[no arguments | <system-name>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion
model: sonnet
---

# Create Epics

An epic is the unit between architecture and stories. It groups related stories under a shared system or module, declares the governing ADRs, and surfaces the framework risk so the engineer knows what to verify before coding.

Output: `production/epics/<epic-slug>/EPIC.md` (one file per epic)

---

## Purpose / When to Run

Run when:
- `/architecture-review` returned PASS or CONCERNS (not FAIL)
- `/create-control-manifest` is written and dated
- The team is ready to plan stories

Do not decompose into stories here — `/create-stories <epic-slug>` does that.

## Inputs

- All `design/prd/*.md`
- All Accepted `docs/architecture/ADR-*.md`
- `docs/architecture/architecture.md`
- `docs/architecture/control-manifest.md`
- `docs/framework-reference/<framework>/`
- Optional `<system-name>` argument: only generate the epic for this system

## Outputs

- `production/epics/<epic-slug>/EPIC.md` — one per system in scope

---

## Phase 1: Pre-checks

- Confirm at least one Accepted ADR exists
- Confirm `docs/architecture/control-manifest.md` exists and read its Manifest Version
- If a previous epic for the same system exists, ask: `Refresh`, `Replace`, `Cancel`

If `<system-name>` argument given, scope to that system; else, do all in-scope MVP systems from the systems index.

---

## Phase 2: Read All Context

Read the inputs in full. Hold:
- Each PRD's Detailed Requirements (all TR-IDs)
- Each PRD's Acceptance Criteria
- Each ADR's PRD Requirements Addressed table
- Architecture Section 3 (Layers) and Section 20 (Required ADRs)
- Control manifest Required/Forbidden/Guardrail by layer

---

## Phase 3: Group TR-IDs into Epics

The mapping rule: one epic per system, with stories living inside.

Special cases:
- If a system is huge (>30 TR-IDs), split into 2-3 sub-epics (e.g., "Auth — Sign-in", "Auth — Account & Recovery")
- Foundation systems (state, navigation, networking) become epics if they need any user-visible scaffolding work
- Cross-cutting concerns (analytics, error reporting) become their own epics if they have ≥3 TR-IDs of dedicated work

Order epics by dependency: Foundation → Core → Features → Polish.

---

## Phase 4: Per-Epic Authoring

For each epic, write `production/epics/<slug>/EPIC.md`:

```markdown
# Epic: <System Name>

> **Status**: Ready for stories
> **Layer**: <Foundation / Core / Feature / Polish>
> **Manifest Version**: <date from control-manifest>
> **Created**: <date>

## 1. Goal
<one paragraph from the PRD's Overview + User Goal>

## 2. PRD Source
- `design/prd/<system>.md`

## 3. Governing ADRs

| ADR | Title | Status | Risk |
|-----|-------|--------|------|
| ADR-NNNN | <title> | Accepted | LOW / MED / HIGH |
| ADR-NNNN | <title> | Proposed | (BLOCKED until Accepted) |

## 4. Framework Risk

- Framework: <name + version>
- Knowledge risk: <LOW / MEDIUM / HIGH>
- Verification required (from ADRs): <list>
- Breaking-change touch points: <list or none>

## 5. Requirements Covered

| TR-ID | Requirement summary | Source ADR | Story slug (when created) |
|-------|---------------------|------------|---------------------------|
| TR-<sys>-001 | ... | ADR-NNNN | (pending) |
| ... | | | |

## 6. Untraced Requirements

| TR-ID | Why untraced | Resolution path |
|-------|--------------|-----------------|
| TR-<sys>-007 | No ADR covers this — Proposed only | Run `/architecture-decision` for <area> |

If empty, mark "None — all TR-IDs trace to an Accepted ADR."

## 7. Acceptance for Epic Done

- All TR-IDs in Section 5 implemented and verified
- All stories in this epic at Status: Complete
- All test evidence at the path specified in each story's manifest
- Smoke check passes for this system
- All P0 ADRs covering this epic remain Accepted (no regressions)

## 8. Out of Scope

- <items deliberately excluded — link to where they live (next epic, deferred PRD, v1.1 list)>

## 9. Implementation Notes

### Layer constraints
<from control manifest, copied verbatim — Required and Forbidden for each layer this epic touches>

### Performance budget
<from control manifest guardrails relevant to this epic>

### Test evidence

| Story type expected | Evidence required | Path |
|---------------------|-------------------|------|
| Logic | Automated unit test | tests/unit/<system>/<slug>_test.<ext> |
| Integration | Integration test or documented walkthrough | tests/integration/<system>/<slug>_test.<ext> |
| Visual / Feel | Screenshot + lead sign-off | production/qa/evidence/<slug>-evidence.md |
| UI | Manual walkthrough doc | production/qa/evidence/<slug>-evidence.md |
| Config / Data | Smoke check | production/qa/smoke-<date>.md |

## 10. Risks

- <list — engineering risks that could derail this epic>

## 11. Rollout & Feature Flag

- Feature flag controlling this epic (if any): `<flag_name>` from <provider>
- Rollout plan: <internal → beta → percentage → full>
- Kill switch: <yes / no>

## 12. Open Questions

- <list>

## 13. Story Backlog (filled by `/create-stories`)

[Initially empty. After `/create-stories <slug>`, this lists the story files.]
```

---

## Phase 5: Write & Confirm

Show the draft for the first epic. Ask: "Approve and write to `production/epics/<slug>/EPIC.md`?"

Loop for each in-scope epic. The user can approve all in batch or one-by-one.

---

## Phase 6: Update Indexes

After all epics are written:
- Update `design/systems-index.md` to set Status to `Epic created` for each affected system
- Update `production/session-state/active.md` with epic count and next-action pointer

---

## Phase 7: Hand Off

Print:
> "<N> epics written. Run `/create-stories <epic-slug>` for each in dependency order. Foundation epics first."

Use `AskUserQuestion`:
- `Run /create-stories for <first foundation epic>`
- `Run /sprint-plan` (after at least one story batch is created)
- `Stop here`

---

## Phase 8: Detect Untraced Requirements

If any epic has Section 6 entries (untraced requirements), warn loudly:
> "<N> requirements across <M> epics are untraced. Stories cannot be implemented safely against untraced requirements. Resolve by writing missing ADRs (`/architecture-decision`) or marking the requirement out of scope for v1."

---

## Quality Gates

- Every TR-ID from every in-scope PRD appears in either Section 5 (covered) or Section 6 (untraced) of some epic
- Every Governing ADR listed has Status verified — Proposed ADRs trigger BLOCKED labeling
- Manifest Version is recorded at epic creation time
- No epic has zero TR-IDs (else it is not a real epic — ask the user)

---

## Examples

`/create-epics`
- 8 in-scope systems → 9 epics (auth split into Sign-in and Account)
- 47 TR-IDs covered, 0 untraced
- Foundation epics: navigation-shell, auth-sign-in, persistence
- Output: 9 EPIC.md files

`/create-epics auth`
- Single-system run. 12 TR-IDs covered by ADR-0003 + ADR-0007. 1 untraced (biometric unlock — no ADR yet).
- Warning surfaces; user chooses to write ADR before story creation.
