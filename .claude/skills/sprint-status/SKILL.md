---
name: sprint-status
description: "Fast sprint status check — reads the active sprint plan, scans story files for status, and produces a concise progress snapshot with burndown read and emerging risks. Use any time during a sprint for situational awareness."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Glob, Grep
model: haiku
---

# Sprint Status

A fast read of the in-flight sprint. Where things stand, what is at risk, what blocks. Read-only. Should complete in seconds.

---

## Purpose / When to Run

Run when:
- The user asks "how is the sprint going" / "sprint status" / "where are we"
- Mid-sprint check-in
- Before standup, to prep
- After a story moves status, to confirm the snapshot updates

Distinct from `/scope-check` (which evaluates scope creep) and `/milestone-review` (broader scope).

## Inputs

- The active sprint plan at `production/sprints/`
- All story files in `production/epics/*/story-*.md`
- `production/session-state/active.md` (optional)

## Outputs

- Printed snapshot. No file writes.

---

## Phase 1: Find the Active Sprint

Glob `production/sprints/*.md` sorted by filename (sprint-001, sprint-002, ...). The active sprint is:
- The one with `Status: Active` in its header
- Else the most recently dated one

If none exist, stop:
> "No sprint plan found. Run `/sprint-plan new` to create one."

If multiple have `Status: Active`, surface the conflict and ask which to report on.

---

## Phase 2: Read Sprint Plan

Extract:
- Sprint number and slug
- Start and end dates
- Goal
- Backlog table with stories and statuses (the plan's view)
- Capacity
- Risks

---

## Phase 3: Refresh from Story Files

The sprint plan's backlog table may be stale if engineers moved story Status without touching the plan. Re-read each story listed in the backlog:
- Current Status (Ready / In Progress / Blocked / Complete)
- Whether it's been touched recently (file mtime)
- Whether it has a `## Implementation Notes` or `## Mid-Story Update` block (signals work in flight)

Build a fresh status tally:
- Total
- Complete
- In Progress
- Blocked
- Ready (not yet started)

---

## Phase 4: Burndown Read

Compute:
- Days elapsed in sprint
- Days remaining
- Stories complete vs. total
- Implied velocity: complete / days elapsed
- Implied finish: total / velocity (in days)

Compare implied finish to days remaining:
- If implied finish ≤ days remaining → **On track**
- If implied finish ≤ days remaining × 1.2 → **Tight**
- If implied finish > days remaining × 1.2 → **At risk**
- If multiple stories Blocked → **Blocked-heavy** (mention even if other numbers look OK)

---

## Phase 5: Detect Risks

Scan for:
- Stories `In Progress` for >2 days (file mtime suggests stall)
- Stories `Blocked` — list the blockers
- Stories whose governing ADR is `Proposed` (story should be Blocked but isn't yet)
- Stories whose Manifest Version is older than the current control-manifest version
- Sprint goal at risk: any story in the critical path Blocked or stalled

---

## Phase 6: Output

```
# Sprint <NNN>: <slug>

**Goal**: <goal>
**Status**: <On track / Tight / At risk / Blocked-heavy>
**Day**: <N> of <M> (<X> remaining)

## Progress
- Complete: <N> / <total> (<%>)
- In progress: <N>
- Blocked: <N>
- Not yet started: <N>

## Burndown
- Velocity so far: <N> stories / <X> days = <Y>/day
- Implied finish: <date>, vs. sprint end <date>

## Stories in motion
- [In Progress] story-NNN: <title> — engineer <name or unassigned>, last touched <date>
- [In Progress] story-NNN: <title> — STALLED (last touched <N> days ago)

## Blockers
- story-NNN: <title> — Blocked because <reason>. Action: <suggested fix>
- ...

## Risks emerging
- <list — stalled stories, manifest drift, scope creep signals>

## Recommended next actions
- For users picking up work: start with story-NNN (highest leverage)
- For PMs: <if at risk, suggest /scope-check; if blocked-heavy, schedule a blocker-clearance>
- For leads: <if any Manifest version drift, suggest re-running /create-control-manifest>
```

Keep the output to roughly 25-40 lines. This skill should be skimmable.

---

## Phase 7: Compare to Plan

If the plan's backlog table differs from the live story Status (e.g., plan says Ready but story says Complete), surface it:
> "Note: sprint plan's backlog table is stale — <X> stories have advanced beyond what the plan shows. Run `/sprint-plan update` to refresh."

---

## Quality Gates

- Output completes in seconds — no specialist spawns, no deep reads beyond story headers
- Status verdict matches the data (no "On track" when 5 of 8 are Blocked)
- Read-only

---

## Examples

`/sprint-status`
- Sprint 003, day 6 of 10
- 4 Complete, 2 In Progress, 1 Blocked, 1 Ready
- Velocity: 0.67/day → implied finish: 4 more days → on track
- Blocker: story-005 (biometric) — ADR Proposed, action: advance ADR-0007
- Recommended: pick up story-007 next (foundation for two downstream)

`/sprint-status` mid-sprint with stall
- Sprint 002, day 7 of 10
- 2 Complete, 4 In Progress (3 stalled >2 days), 0 Blocked
- Status: At risk — implied finish 6 more days vs. 3 remaining
- Recommended: immediate sprint review or scope reduction; run `/scope-check`
