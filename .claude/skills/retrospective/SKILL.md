---
name: retrospective
description: "Generates a sprint or milestone retrospective by analyzing completed work, velocity, blockers, and patterns. Produces actionable insights for the next iteration. Use at sprint end, milestone close, or after a missed deadline."
argument-hint: "[sprint <NNN> | milestone <name>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion
model: sonnet
---

# Retrospective

A structured retro pulls signal from data the team already produced — sprint plan, story files, mid-sprint updates, bug counts — and turns it into actionable practice changes. This skill drafts the retro; the team confirms.

Output: `production/retros/sprint-<NNN>-retro.md` or `production/retros/milestone-<name>-retro.md`

---

## Purpose / When to Run

Run when:
- A sprint just ended
- A milestone closed (regardless of outcome)
- A deadline was missed and the team wants to learn from it
- A recurring pattern of failures shows up

## Inputs

- The sprint plan or milestone doc
- All stories in scope
- Any `## Mid-Sprint Update` sections
- `production/qa/bugs/` if present
- Previous retros (for continuity)

## Outputs

- A retro doc at `production/retros/<scope>-retro.md`

---

## Phase 1: Resolve Scope

If argument names a sprint or milestone, read it directly.

If empty, ask:
- **Prompt**: "Retro on what?"
- **Options**: `Last sprint`, `Specific sprint (free text)`, `Last milestone`, `Specific milestone (free text)`

For "Last sprint", glob `production/sprints/*.md` and pick the most recent.

---

## Phase 2: Gather Data

Read:
- The sprint plan or milestone doc — extract original goal, original scope, capacity
- All stories in scope — current Status, time-stamps, any in-story notes
- Mid-Sprint Update sections — additions, removals, reasons
- Bugs filed during the period (if present)
- Last retro (continuity check — were prior commitments met?)
- Concept doc Primary Metric — did the work move it?

Compute:
- Planned stories vs. completed
- Velocity (story-days)
- Carry-out
- Blocker count and total blocker duration
- Bug count by severity created during the period
- Bugs closed during the period

---

## Phase 3: Surface Patterns

Cross-reference data for patterns:

### Estimation accuracy
- Compare estimates (if `/estimate` was run) to actual time
- Flag stories that took >2x estimate as estimation outliers — useful signal

### Drag sources
- Stories Blocked >2 days — what blocked them?
- Common blocker categories: missing ADR, missing UX, missing backend, third-party SDK, store / device issues
- Group by category — the most-frequent blocker is the highest-leverage retro target

### Scope discipline
- Mid-sprint additions: how many, why, were they linked to the goal?
- Pull from `/scope-check` outputs if any were captured

### Quality signals
- Bug rate per story type (Logic / Integration / Visual / UI / Platform)
- Test compliance (stories with test evidence vs. stories due for it)
- Story types most associated with bugs — surface for next-sprint focus

### Process drift
- Stories without `/story-readiness` run before start
- Stories without code review (if the project tracks this)
- Stories with stale Manifest Version

### Continuity
- Did prior retro commitments land?
- If not, why? Were they too vague? Was the owner unclear?

---

## Phase 4: Capture the Team's View

The data is half the retro. The other half is what the team felt. Use `AskUserQuestion`:

### Tab 1 — What went well
- Free text. Capture 2-5 items.

### Tab 2 — What didn't go well
- Free text. 2-5 items. Encourage specificity ("we shipped on time" → "the auth epic landed on schedule despite the biometric ADR blocker").

### Tab 3 — What surprised us
- Free text. Surprises often hide the most useful learnings.

### Tab 4 — One change for next time
- Free text. The output of every retro should be 1-3 concrete changes, not a wishlist.

If the user is solo, accept all of these as plain-text answers.

---

## Phase 5: Draft the Retro

```markdown
# Retro: <sprint NNN | milestone <name>>

> **Date**: <today>
> **Period**: <start> to <end>
> **Goal**: <from the plan>
> **Outcome**: <ACHIEVED / PARTIALLY ACHIEVED / NOT ACHIEVED>

## At a glance

- Planned: <N> stories
- Completed: <N>
- Carry-out: <N>
- Velocity: <stories/day>
- Bugs filed: <by severity>
- Test compliance: <%>

## What went well
- <list — from team input + data signals>

## What didn't go well
- <list>

## What surprised us
- <list>

## Patterns from data

### Estimation
- <accuracy summary, outliers>

### Drag sources
- <Top blockers by frequency / duration>

### Scope discipline
- <additions, removals, scope creep%>

### Quality
- <bug rate by story type, test compliance>

### Process drift
- <e.g., 2 stories started without /story-readiness>

## Continuity check

Prior retro commitments:
- <commitment> — <met / partial / unmet>

## Action items for next iteration

| Action | Owner | Due |
|--------|-------|-----|
| <specific change> | <name or "the team"> | <next sprint or specific date> |
| <action> | <name> | <date> |

## Ratify

This retro's actions become the prior-retro reference for the next retro. The next retro must check whether each was met.

## Notes
- <freeform observations the data did not surface>
```

Show the draft. Ask:
- `Approve and write to production/retros/<filename>`
- `Make changes — describe`
- `Discard`

---

## Phase 6: Specialist Pass (optional)

For milestone retros, optionally spawn:
- `pm` — review action items for realism
- `mobile-architect` — review patterns for systemic root causes
- `qa-lead` — review quality signals

Findings integrate into the doc.

---

## Phase 7: Update Active State

After writing the retro:
- Update `production/session-state/active.md` with the retro pointer
- If actions are owned and dated, optionally surface them in the next sprint plan

Print:
> "Retro written. <N> action items captured. Run `/sprint-plan new` next to incorporate them."

---

## Phase 8: Anti-Patterns to Watch

The retro should never:
- Blame individuals — blame systems
- Be a feel-good summary — surface real problems
- Produce more than 3 action items — focus is the point
- Repeat last retro's actions verbatim — if a commitment didn't land, dig into why before re-stating it

If the retro draft starts looking generic ("communicate better"), pause and re-ask the user for specifics.

---

## Quality Gates

- At least one action item with a named owner and a due date
- Patterns section is data-driven, not vibes
- Continuity check is filled (or explicitly "no prior retro")
- Bugs and test compliance numbers are real, not estimated

---

## Examples

`/retrospective sprint 003`
- Goal: ship sign-in. Outcome: ACHIEVED.
- 8 planned, 8 completed, 0 carry-out
- Surprise: biometric ADR was unblocked faster than expected
- Pattern: 3 of 5 bugs were in Visual / Feel stories — manual evidence may be too lenient
- Action: tighten the manual-evidence template (owner: QA lead; due: next sprint)

`/retrospective milestone alpha`
- Outcome: PARTIALLY ACHIEVED — 5 of 7 epics complete
- Pattern: HIGH-risk framework decisions consistently took 1.5x estimated
- Action: add 1.5x multiplier to HIGH-risk story estimates by default
- Action: spike before any HIGH-risk story enters a sprint
