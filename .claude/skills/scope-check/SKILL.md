---
name: scope-check
description: "Compares current sprint or feature scope against the original plan to detect scope creep. Quantifies bloat, names additions, recommends cuts. Use mid-sprint when the team feels overloaded, or before adding a 'small' new story to a running sprint."
argument-hint: "[sprint | feature <slug>]"
user-invocable: true
allowed-tools: Read, Glob, Grep
model: haiku
---

# Scope Check

Sprints accumulate. A story added Tuesday because "it's quick" plus another Wednesday becomes Friday's overrun. This skill measures the drift from the original plan and surfaces a recommendation.

Read-only. Outputs a snapshot + cut recommendations.

---

## Purpose / When to Run

Run when:
- The team feels overloaded mid-sprint
- A new story is being considered for an in-flight sprint
- Sprint status shows "At risk" and the cause is unclear
- A PM wants to confirm a feature has not silently expanded

Distinct from `/sprint-status` (current state) — this skill compares **planned vs. actual** scope.

## Inputs

- Mode: `sprint` (compare current sprint to its initial plan) or `feature <slug>` (compare an epic to its initial scope)
- The relevant sprint plan or epic file
- Mid-Sprint Update sections (added by `/sprint-plan update`)
- All current stories
- The git history if available — but the skill does not require it

## Outputs

- Printed snapshot. No file writes.

---

## Phase 1: Resolve Mode

If no argument: ask
- **Prompt**: "Check sprint scope or feature scope?"
- **Options**: `Active sprint`, `Specific feature (free text — epic slug)`

---

## Phase 2: Establish Baseline

For sprint mode:
- Read the active sprint plan
- Extract the **original Sprint Backlog table** (the one written when the plan was first created, before any `## Mid-Sprint Update` section)
- Extract the original sprint goal and Success Looks Like

For feature mode:
- Read the epic's `EPIC.md`
- Extract the original Story Backlog (Section 13 if it was filled before stories were added; else infer from the original PRD's TR-IDs)
- Extract the original scope from EPIC Section 8 (Out of Scope)

---

## Phase 3: Establish Current

Walk the same backlog now:
- For sprint mode: read the live story files for each story in the plan, plus any added via Mid-Sprint Updates
- For feature mode: list all stories under `production/epics/<slug>/story-*.md`

For each story now in scope, classify:
- **In original plan** — was there from day 1
- **Added** — appears in a Mid-Sprint Update section, or post-dates the original plan's create date
- **Expanded** — was in the plan but acceptance criteria have grown (count criteria; if the story file has more than the plan implied, mark as expanded)

For each story in the original plan:
- **Carried** — still here, on track
- **Removed** — not in the current list (deferred or killed)
- **Stuck** — still here but in Blocked or stalled In Progress for days

---

## Phase 4: Quantify

Numbers to surface:
- Original story count
- Current story count
- Net additions (positive number = creep)
- Acceptance-criteria additions (sum of expansion across stories)
- Stories Blocked or stalled (drag, not creep, but distorts capacity)

For sprint mode, also:
- Day in sprint vs. % complete — if 60% time elapsed but 30% complete, the math may be unwinnable even without creep

---

## Phase 5: Categorize Creep

For each Added story, classify:
- **Linked to goal** — directly serves the sprint goal or feature outcome (often justifiable)
- **Adjacent** — related but not on the critical path (cuttable)
- **Opportunistic** — "since we're touching this code anyway" (almost always cut)
- **External** — driven by external request mid-sprint (escalate to PM)

For each Expanded story, classify:
- **Discovered necessity** — turned out the original criteria were incomplete (acceptable; document)
- **Polish** — adds finish that wasn't in the original spec (cut or defer)
- **Edge cases** — surfaced during work; some essential, some defer-able (case by case)

---

## Phase 6: Output

```
# Scope Check: <sprint NNN | feature <slug>>

## Drift summary
- Original scope: <N stories, M acceptance criteria>
- Current scope: <N+x stories, M+y acceptance criteria>
- Net creep: +<x> stories, +<y> criteria (<z>% bloat)

## Additions
- [LINKED] story-NNN: <title> — added on <date>, justified by <reason>
- [ADJACENT] story-NNN: <title> — added on <date>, recommend cut
- [OPPORTUNISTIC] story-NNN: <title> — recommend cut
- [EXTERNAL] story-NNN: <title> — escalate to PM

## Expansions
- story-NNN: <title> — original 3 criteria, now 6. <classification>.

## Removals (carry-out)
- story-NNN: <title> — moved out on <date>, going to <sprint or backlog>

## Drag (separate from creep)
- story-NNN: <title> — Blocked on ADR-0007 (Proposed)
- story-MMM: <title> — In Progress 4 days, last touched <date>

## Recommendation
**<Cut / Hold / Continue>**

If Cut: remove <list of N stories>, defer <list of M criteria>. New backlog count: <N-x>.
If Hold: scope is borderline. Drop <list of K opportunistic adds> if you want a buffer.
If Continue: scope drift is justified by goal-linkage.

## Recommended next steps
- Run `/sprint-plan update` to formally remove cut stories
- For drag items, escalate blockers (talk to architect / PM)
- Re-run `/sprint-status` after cuts to confirm burndown improves
```

---

## Phase 7: Edge Cases

- **No Mid-Sprint Update sections** but story count is higher than the plan: stories were added without going through `/sprint-plan update`. Flag as a process gap.
- **Expansion without addition**: zero net adds, but criteria count up — quieter creep, often the dangerous kind.
- **Plan was never tightly scoped**: the original plan's Success Looks Like is vague. Flag — `/scope-check` cannot evaluate creep against a fuzzy baseline. Recommend tightening the next plan.

---

## Quality Gates

- Numbers are reproducible — running twice on the same state gives the same numbers
- Recommendation is one of Cut / Hold / Continue — never "it depends"
- Read-only — no file writes
- Output is skimmable in 30 seconds

---

## Examples

`/scope-check`
- Sprint 003: original 8 stories, 24 criteria. Current 11 stories, 33 criteria. Net +37%.
- 3 Added: 1 LINKED (justified), 1 OPPORTUNISTIC (cut), 1 EXTERNAL (escalate)
- 2 Expanded (1 polish, 1 edge case)
- 1 Drag (Blocked story)
- Recommendation: Cut. Remove the 1 OPPORTUNISTIC story and trim the 1 polish expansion. Net +1 story, manageable.

`/scope-check feature paywall`
- Epic paywall: original 12 stories from PRD. Current 17 stories.
- 5 Added: 4 ADJACENT (cuttable to v1.1), 1 LINKED
- Recommendation: Cut 4 adjacent stories. Defer to v1.1 epic.
