---
name: estimate
description: "Estimates effort for a story, batch of stories, or epic by analyzing complexity, dependencies, historical velocity, and risk factors. Produces a structured estimate with confidence levels. Use before sprint planning or when sizing a new request."
argument-hint: "[story <path> | epic <slug> | batch <glob>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, AskUserQuestion
model: sonnet
---

# Estimate

Estimation in mobile work is risky because framework knowledge gaps, platform divergence, and store review cycles inflate timelines. This skill produces estimates with explicit reasoning and confidence levels, not a single number.

Read-only.

---

## Purpose / When to Run

Run when:
- Sizing a story before adding to a sprint
- Sizing an epic before committing to a milestone
- A new feature request needs a rough budget before deciding go / no-go

## Inputs

- A story path, epic slug, or glob of stories
- Recent sprint plans (for velocity baseline)
- Story files in scope (for complexity analysis)

## Outputs

- Printed estimate with low / mid / high bounds, confidence, and assumptions

---

## Phase 1: Resolve Scope

Argument forms:
- `story <path>` — one story
- `epic <slug>` — all stories under that epic
- `batch <glob>` — explicit list

If no argument, ask:
- **Prompt**: "Estimate what?"
- **Options**: `Single story`, `Whole epic`, `A list of stories`, `A new feature with no stories yet`

For "feature with no stories yet", switch to T-shirt mode (Phase 4 alternate).

---

## Phase 2: Establish Velocity Baseline

Read the last 2-3 sprint plans. From each:
- Stories planned vs. completed
- Capacity in dev-days
- Average story-days

Compute the rolling average story-day cost. If sprints don't exist yet, use the default heuristic:
- Logic story: 0.5-1 day
- Integration story: 1-2 days
- UI story: 1-2 days
- Visual / Feel story: 1-3 days
- Platform story (push, biometric, IAP, deep links): 2-4 days
- Config / Data story: 0.25-0.5 day

Document the baseline source ("Computed from sprints 001-003" or "Heuristic — no sprint history").

---

## Phase 3: Per-Story Complexity Analysis

For each story in scope, read it and score:

### Complexity factors (each adds time)

- **Type**:
  - Logic: base
  - Integration: +50%
  - UI: base or +25% if novel
  - Visual: +25-50%
  - Platform: +50-100%
  - Config: -50%
- **Framework risk** (from story header):
  - LOW: 0
  - MEDIUM: +25%
  - HIGH: +50% (verification work)
- **ADR status**:
  - Accepted: 0
  - Proposed: +100% (risk that decision changes mid-implementation, or block)
- **UX spec maturity** (UI stories):
  - Reviewed: 0
  - Authored not reviewed: +25%
  - Missing: BLOCKED — can't estimate
- **Acceptance criteria count**:
  - 1-3: 0
  - 4-6: +25%
  - 7+: +50% (story may be too big — recommend split)
- **Cross-platform**: if both iOS and Android target → +25-50%
- **Permission flow**: any story that asks for permissions → +0.25 day for denied-state UX
- **Backend integration**: if real backend not yet ready → +50% for stub/mock work
- **Store-review-affecting**: any IAP, deletion, or privacy change → +0.5 day for review-prep tasks

Produce a per-story estimate: low (best case), mid (likely), high (if all risks materialize).

---

## Phase 4: Aggregate

For epic / batch mode, sum the individual estimates:
- Sum lows, mids, highs separately
- Note the total confidence band (max / min ratio across stories)

For T-shirt mode (no stories yet):
- Ask: "Roughly how many user-visible behaviors? How many backend integrations? How many novel patterns vs. existing patterns?"
- Output a T-shirt size: XS (0.5-2 days), S (2-5), M (5-10), L (10-20), XL (20+) with reasoning

---

## Phase 5: Confidence Levels

For each estimate, attach a confidence:
- **HIGH** — similar work has been done in the project; baseline is solid; ADRs accepted; framework risk LOW
- **MEDIUM** — some unknowns; framework risk MEDIUM or one Proposed ADR
- **LOW** — multiple unknowns: HIGH framework risk, novel area, no UX, missing ADRs

Confidence is reported alongside the number. A LOW-confidence estimate is a budget for further investigation, not a delivery commitment.

---

## Phase 6: Surface Assumptions

The estimate is conditional on assumptions. List them:
- "Assumes ADR-0007 is Accepted by sprint start"
- "Assumes UX spec for login is reviewed before story-003"
- "Assumes backend `/auth/refresh` endpoint is available"
- "Assumes biometric works on the test device matrix listed in technical-preferences"
- "Excludes store-review wait time"

If any assumption is in doubt, add a note: "If this assumption fails, add 1-3 days."

---

## Phase 7: Output

```
# Estimate

**Scope**: <story / epic / batch>
**Stories estimated**: <N>

## Per-story breakdown
| Story | Type | Complexity | Low | Mid | High | Confidence |
|-------|------|-----------|-----|-----|------|-----------|
| 001 — OAuth call | Logic, MED risk | base + 25% | 0.5d | 1d | 1.5d | HIGH |
| 002 — Token storage | Integration, MED risk | base + 75% | 1d | 2d | 3d | MEDIUM |
| ... | | | | | | |

## Total
- Low: <X>d
- Mid: <Y>d
- High: <Z>d
- Confidence: <HIGH / MEDIUM / LOW> overall

## Assumptions
- <list>

## Risks
- <list — items most likely to push toward High>

## Recommendation
- For sprint planning: budget <Mid + 20% buffer> = <Y * 1.2>d
- If only the Mid is committed and any risk materializes, the sprint will overflow
- For a milestone commit: budget the High end
- For a stretch goal: budget the Mid

## Notes
- Velocity baseline: <source>
- Stories that should be re-decomposed (too big): <list>
- Stories that should be Blocked (missing ADR / UX): <list>
```

---

## Phase 8: Recommendations

Common patterns to surface:

- If a story is estimated 4+ days at Mid, recommend splitting before adding to a sprint
- If overall confidence is LOW, recommend a small spike or `/prototype` to retire the biggest unknown before committing
- If a story is BLOCKED on missing inputs, refuse to estimate — name the input and recommend the unblocking skill

---

## Quality Gates

- Every story in scope has Low, Mid, High estimates and a confidence
- Every assumption is named — no hidden hand-waving
- Recommendation is concrete — a number for sprint planning, plus what to commit vs. stretch
- Read-only

---

## Examples

`/estimate epic auth-sign-in`
- 8 stories, mid total: 14 days, high: 22, low: 9
- Confidence: MEDIUM (1 story BLOCKED, 1 with HIGH framework risk)
- Recommend: budget 17 dev-days for sprint commit; carry the HIGH-risk story to a follow-up sprint

`/estimate story production/epics/auth/story-005-biometric.md`
- Type: Platform, framework risk HIGH, ADR Proposed
- Mid: 3 days, High: 5
- Confidence: LOW
- Assumption: ADR-0007 advances to Accepted before story start
- Recommendation: do not include in next sprint until ADR is Accepted; add a 0.5-day spike to validate iOS biometric API on physical device first

`/estimate` (T-shirt mode)
- "How many user-visible behaviors?" — 3
- "Backend integrations?" — 1
- "Novel patterns?" — 0
- T-shirt: S (3-5 days)
- Confidence: MEDIUM, given no detailed PRD yet
