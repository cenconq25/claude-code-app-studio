---
name: bug-triage
description: "Read all open bugs, re-evaluate priority and severity, surface systemic trends, and assign each to a sprint or backlog. Run at sprint start or when the open bug count grows beyond comfort."
argument-hint: "[--sprint=<id> | --since=<date>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion
model: sonnet
---

# Bug Triage

Bring the bug backlog back under control. Read every open bug, refresh
priorities against current reality, group by symptom, and assign each
bug an owner and a sprint.

---

## Phase 1: Inventory

Glob `production/qa/bugs/BUG-*.md`. Read each whose Status is `Open`,
`In Progress`, or `Reopened`. Skip `Closed`, `WontFix`, `Duplicate`.

Capture per bug:

- ID, title
- Current severity, priority, status
- Affected platforms
- Affected build (and whether that build is still relevant)
- Frequency
- File date
- Suspected area / module
- Last update date

Optional argument `--since=<date>` filters to bugs filed after a date.

---

## Phase 2: Re-evaluate Each Bug

For every bug, ask whether the current severity/priority still fits.
Drivers of re-evaluation:

- **Build relevance** — if the affected build is now several releases
  old, can the bug still be reproduced? Surface for user to confirm.
- **Workaround stability** — if a documented workaround has stopped
  working, severity goes up.
- **Frequency drift** — telemetry numbers (Crashlytics, Sentry) may show
  the bug occurring more or less often than at filing time.
- **Business context** — paywall bugs near a marketing push, auth bugs
  near an enterprise rollout, push bugs near a re-engagement campaign
  all elevate priority.
- **Age** — open longer than 30 days at S2 or above is a smell.

Read recent telemetry summary if present
(`production/qa/telemetry-summary.md`) and use it to inform the calls.

For each bug, propose new severity/priority. Use AskUserQuestion in
batches:

```
question: "BUG-NNN: [title]\nCurrent: S[X]/P[Y] — proposed: S[A]/P[B]\nReason: [reason]"
options:
  - "Accept proposal"
  - "Keep current"
  - "Override — let me set values"
  - "Close — fixed / not reproducible / wontfix (specify)"
```

---

## Phase 3: Detect Systemic Trends

Cluster the open bugs:

- By module (auth, paywall, sync, push, navigation).
- By symptom (crash, ANR, freeze, layout, copy, network, payment).
- By platform (iOS-only, Android-only, both).
- By cause hypothesis (race condition, leaked subscription, missing
  null check, deprecated API).

If a cluster has 3+ bugs, flag it as a systemic trend and propose:

- An ADR or refactor story to address the root.
- A regression test family for the cluster.
- A specific subagent or specialist to drive the fix.

---

## Phase 4: Assign Sprints

For each open bug remaining, propose a sprint slot:

- P0 -> active sprint (interrupts current work).
- P1 -> active sprint or next sprint (capacity-permitting).
- P2 -> next sprint.
- P3 -> backlog with revisit-by date (default +60 days).

Read the active sprint plan to estimate available capacity. If a sprint
is full, flag overflow and ask the user to choose between bumping P3s,
deferring P2s, or expanding the sprint.

Use AskUserQuestion to confirm the schedule per cluster.

---

## Phase 5: Update Bug Files

For each bug whose severity, priority, or sprint changed, ask:
"May I update [bug path]?"

On approval, edit:

- `Severity: S[N]`
- `Priority: P[N]`
- `Status: [In Progress / Open / Closed / WontFix]`
- Append a `## Triage [date]` note with the reasoning.
- If assigned to a sprint, add `Sprint: [sprint-id]`.

For closed bugs, add a `## Resolution [date]` note with the closing
reason (Fixed in [commit], Not Reproducible, Duplicate of BUG-NNN,
WontFix because [reason]).

---

## Phase 6: Render the Triage Report

```markdown
# Bug Triage Report — [date]

Bugs reviewed: [N]
- Severity changes: [count]
- Priority changes: [count]
- Closed during triage: [count]
- New systemic trends flagged: [count]

## By Severity
| Severity | Open count | New since last triage |
|----------|------------|------------------------|
| S1 | 0 | 0 |
| S2 | 3 | 1 |
| S3 | 11 | 4 |
| S4 | 7 | 2 |

## Systemic Trends
- Cluster: [description] — [N] bugs — recommend [action]

## Sprint Assignments
| Bug | Title | Severity | Priority | Sprint |
|-----|-------|----------|----------|--------|

## Closed During Triage
| Bug | Reason |

## Backlog (P3)
[N] bugs, revisit by [date]

## Recommendations
- [action]
- [action]
```

Ask: "May I write this to `production/qa/triage-[date].md`?"

---

## Phase 7: Update Session State

Append to `production/session-state/active.md`:

```
## Bug Triage — [date]
- Reviewed: [N]
- Open S1/S2: [count]
- Trends flagged: [count]
- Triage report: [path]
- Next sprint impact: [N bugs added]
```

---

## Quality Gates / PASS-FAIL

- PASS — every Open bug has a current severity, priority, and either a
  sprint assignment or a backlog flag with a revisit date. No S1 is
  unassigned.
- FAIL — any S1 bug remains unassigned, or any bug older than 30 days
  has not been re-evaluated.

---

## Examples

**Example 1 — sprint-04 kickoff:**
Reads 22 open bugs. Closes 4 (3 not-reproducible, 1 duplicate). Promotes
2 to S2 due to telemetry spike. Detects an "Android keyboard insets"
cluster (4 bugs) and recommends ADR to standardize. Assigns 9 bugs to
sprint-04.

**Example 2 — backlog cleanup:**
`--since=2025-12-01` triages 38 stale entries. Closes 11 as
WontFix-due-to-rewrite, archives the rest with revisit dates.

---

## Next Steps

- Systemic trend -> `/architecture-decision` or refactor story.
- High-severity remaining -> `/hotfix [bug]`.
- Sprint-assigned bugs -> include in `/sprint-plan`.
