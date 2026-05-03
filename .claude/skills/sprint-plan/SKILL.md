---
name: sprint-plan
description: "Generates a new sprint plan or updates an existing one based on the current milestone, completed work, and team capacity. Pulls context from production docs and the story backlog. Run at sprint start, sprint mid-correction, or after a milestone shift."
argument-hint: "[new | update]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion
model: sonnet
---

# Sprint Plan

Builds the bridge between epic story backlogs and what gets worked on in the next 1-2 weeks. Decides which stories enter the sprint, who owns them (when team info is known), and what the sprint's outcome target is.

Output: `production/sprints/sprint-NNN-<slug>.md`

---

## Purpose / When to Run

Run when:
- The previous sprint just ended
- A new epic is ready to be tackled
- A milestone shift requires re-planning
- The team wants to update an in-flight sprint (`update` mode)

## Inputs

- All epics: `production/epics/*/EPIC.md`
- All stories: `production/epics/*/story-*.md`
- Existing sprints: `production/sprints/*.md`
- Optional `production/milestones/*.md`
- `design/concept.md` for primary metric context
- `production/session-state/active.md`

## Outputs

- `production/sprints/sprint-NNN-<slug>.md`

---

## Phase 1: Mode

If argument is `new`, create a new sprint. If `update`, edit the most recent in-flight sprint. If empty, ask:
- **Prompt**: "New sprint or update existing?"
- **Options**: `New sprint`, `Update existing`, `Show me current sprint first`

For `Show me current sprint first`: dispatch to `/sprint-status` and exit.

---

## Phase 2: Inventory Backlog & Capacity

### 2a: Story inventory

Glob `production/epics/*/story-*.md` and bucket by Status:
- Ready
- In Progress
- Blocked
- Complete

Print counts.

### 2b: Last-sprint signals

If a previous sprint exists, read it. Capture:
- Stories planned vs. completed
- Velocity (stories or rough hours)
- Carry-over

### 2c: Capacity

Use `AskUserQuestion`:
- **Prompt**: "How many engineering days are available for this sprint?"
- **Options**: `5 (1-week sprint, 1 dev)`, `10`, `15`, `20`, `Custom (free text)`

Convert to a rough story budget (e.g., 1 day = 1-2 stories of typical size). The user can override.

Use `AskUserQuestion`:
- **Prompt**: "How many designers / QA / data days available?"
- **Options**: `Solo dev (none)`, `Designer + QA shared`, `Full team`, `Free text`

This affects which story types can be parallelized.

---

## Phase 3: Pick Sprint Goal

Sprint goals must be a single sentence the team can rally around. Examples:
- "Ship the OAuth login flow end to end."
- "Make the Home screen feel responsive — no skeleton longer than 300ms."

Use `AskUserQuestion`:
- **Prompt**: "Which is the sprint's primary goal?"
- **Options**: derived from epics with the most Ready stories. If unclear, free text.

---

## Phase 4: Select Stories

Walk through Ready stories, prioritized by:
1. Foundation epics first
2. Critical path to the sprint goal
3. Stories that unblock multiple downstream stories
4. Stories not blocked by Proposed ADRs

For each candidate, present:
- Story slug + title
- Type
- Estimated effort (from `/estimate` if run, else rough)
- Dependencies on other Ready stories

User picks; capture into the plan.

Cap selection at the story budget. If the user wants more, surface scope creep:
> "Selected <N> stories — that exceeds your <M>-story budget by <X>. Want to remove some, or accept the over-commit?"

---

## Phase 5: Write the Plan

```markdown
# Sprint <NNN>: <slug>

> **Status**: Active
> **Start**: <date>
> **End**: <target date>
> **Capacity**: <days>
> **Manifest Version**: <date from control-manifest>

## Goal
<one sentence>

## Success Looks Like
- <observable end-of-sprint outcomes — e.g., "User can sign in with Apple and Google", "Crash-free rate ≥ 99.5% on internal builds">

## Sprint Backlog

| Story | Title | Epic | Type | Owner | Status |
|-------|-------|------|------|-------|--------|
| 001 | OAuth network call | auth-sign-in | Logic | <name or unassigned> | Ready |
| ... | | | | | |

## Out of Scope (carry to next sprint)
- <list — stories considered but not selected>

## Risks
- <list — engineering or external risks that could derail>

## Dependencies on Other Tracks
- Design: <list>
- Backend / API: <list>
- QA: <list>

## Daily Rhythm
- Standup: <time> (or "async via <channel>")
- Sprint review: <date>
- Retrospective: <date>

## Definition of Sprint Done
- [ ] All Sprint Backlog stories at Status: Complete
- [ ] Smoke check passes (`/smoke-check` in second skill set)
- [ ] No new control-manifest violations introduced
- [ ] Sprint demo deck (or video) prepared
- [ ] Retrospective scheduled

## Metrics to Watch
<from concept.md primary metric — note current baseline if known>

## Notes
- Review mode for the sprint: <full / lean / solo>
- Special calendar items: <holidays, on-call rotations>
```

Ask: "Approve and write to `production/sprints/sprint-NNN-<slug>.md`?"

---

## Phase 6: Update Story Headers

For each story selected, update its `Status: Ready` to `Status: In Sprint <NNN>` (or simply leave as Ready and let the sprint plan be the source of truth — pick one convention and stick with it).

Recommended: keep Story Status reflecting development progress (Ready / In Progress / Blocked / Complete) and let the sprint plan be the assignment doc. Engineers move Story Status as they work; the sprint plan stays static for the period.

---

## Phase 7: Update Active State & Hand Off

Update `production/session-state/active.md`:
- Active sprint: sprint-NNN-<slug>
- Sprint goal: <goal>
- Top story to start: <story-001>

Print:
> "Sprint plan written. Engineers can pick stories with `/story-readiness <path>` then `/dev-story <path>`. Run `/sprint-status` any time for a snapshot."

Use `AskUserQuestion`:
- `Run /story-readiness for the first story`
- `Run /scope-check on this sprint`
- `Stop here`

---

## Update Mode

If argument is `update`, read the latest active sprint and:
1. Show current state (stories by status, days remaining, burndown estimate)
2. Ask what is changing:
   - `Add stories (scope expansion)`
   - `Remove stories (scope reduction)`
   - `Reassign owners`
   - `Move dates`
   - `Update sprint goal`
3. Apply changes via Edit
4. Append a `## Mid-Sprint Update <date>` section recording what changed and why — never silently overwrite

If a story is being removed mid-sprint, ask whether it carries to next sprint or is killed.

---

## Quality Gates

- Sprint goal is one sentence, not a paragraph
- Success Looks Like is observable (not "improve quality")
- Backlog count fits within capacity, or over-commit is explicit
- Manifest Version is recorded
- Risks section is non-empty (a sprint without surfaced risks is unrealistic)

---

## Examples

`/sprint-plan new`
- Capacity: 10 dev-days, 1 designer half-time, 1 QA half-time
- Goal: "Ship sign-in end to end."
- Backlog: 8 stories from auth-sign-in epic (5 Logic, 2 UI, 1 Platform)
- Out of scope: account-recovery (next sprint)
- Risks: ADR-0007 (biometric) still Proposed; sign-in story 005 is Blocked until that lands

`/sprint-plan update`
- Adds 1 story (paywall copy quick-design)
- Removes 1 story (push token registration — pushed to next sprint)
- Logs change rationale in `## Mid-Sprint Update`
