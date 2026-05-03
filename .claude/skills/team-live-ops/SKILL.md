---
name: team-live-ops
description: "Orchestrate the live-ops team for post-launch content planning. Coordinates live-ops-designer, monetization-designer, analytics-engineer, community-manager, and content-strategist to plan a season, event, or live update."
argument-hint: "[--type=season|event|update | --duration=Nweeks]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
agent: live-ops-designer
model: sonnet
---

# Team Live Ops

Post-launch planning is its own discipline. This skill coordinates the
five roles that turn telemetry, user feedback, and roadmap into a
shippable live-ops cycle (a season, an event, or a live content
update).

---

## Team Composition

- **live-ops-designer** — the cycle plan, content beats, pacing.
- **monetization-designer** — pricing experiments, paywall variants,
  promotion calendar.
- **analytics-engineer** — telemetry health, KPI targets, dashboards,
  experiment instrumentation.
- **community-manager** — communications, feedback loop, community
  events.
- **content-strategist** — copy direction, narrative continuity,
  cross-channel messaging.

Spawn each via Task. Run independent subagents in parallel where their
inputs are independent.

---

## Phase 1: Context Load

Read in parallel:

- `production/stage.txt` — confirm we are in `live-ops` or `release`.
- Latest milestone in `production/milestones/`.
- Latest release log in `production/releases/`.
- Latest `/balance-check` and `/perf-profile` artifacts.
- `production/qa/bugs/` for top user-facing pain points.
- Any analytics summary in `production/analytics/`.
- Any prior live-ops cycle plans in `production/live-ops/`.

Confirm with the user the cycle type and duration:

- season — typically 6-12 weeks of themed content.
- event — 3-14 days, narrowly scoped.
- update — feature drop or balance pass, no theme.

---

## Phase 2: Telemetry Snapshot via analytics-engineer

Spawn `analytics-engineer` via Task. Prompt template:

> Pull the last [N weeks] of data. Summarize: DAU/MAU, retention
> curves (D1, D7, D30), conversion funnel rates, ARPDAU, paid-user
> share, churn drivers, top crash signatures. Highlight any deltas
> vs the previous window. Identify segments worth special attention.

Render the analytics summary. Ask the user which 1-3 metrics this
cycle should move.

---

## Phase 3: Content Plan via live-ops-designer

Spawn `live-ops-designer` via Task. Prompt template:

> Cycle type: [type]. Duration: [N weeks]. KPI targets from analytics:
> [list]. Recent user feedback themes: [list]. Compose a content beat
> plan: weekly/daily beats, hero moments, evergreen content, lapsed-
> user re-engagement hooks. Identify what content production needs
> are upstream (assets, copy, code).

Render the plan. Use AskUserQuestion:

- `[A] Approve plan — proceed`
- `[B] Adjust scope`
- `[C] Cycle ambition is too high — descope`
- `[D] Cancel`

---

## Phase 4: Monetization Plan via monetization-designer

Spawn `monetization-designer` via Task in parallel with Phase 5.

Prompt template:

> Cycle plan: [reference]. Current pricing config:
> [paths]. Recent /balance-check report: [path]. Propose a monetization
> calendar for the cycle: paywall variants, promotional pricing
> windows, A/B tests to launch and to retire, kill-switch plan.

Pair the proposal with `/balance-check` to validate variants are
internally consistent.

---

## Phase 5: Community Plan via community-manager

Spawn `community-manager` via Task in parallel with Phase 4.

Prompt template:

> Cycle plan: [reference]. Compose a community calendar: announcement
> beats, AMA / livestream slots, social-media drumbeat, support staff
> brief, beta-tester comms (TestFlight / Play closed test). Identify
> any UGC or contest mechanics to coordinate with content-strategist.

---

## Phase 6: Content Direction via content-strategist

Spawn `content-strategist` via Task. Prompt template:

> Cycle plan: [reference]. Community calendar: [reference].
> Monetization calendar: [reference]. Set tone, narrative continuity,
> copy bible references, in-app messaging cadence, push notification
> rules of engagement (frequency caps, opt-out respect, localization
> requirements).

Cross-check with `/localize --report` to confirm copy can ship in
every targeted locale within the cycle window.

---

## Phase 7: Risk and Capacity Review

Aggregate all four sub-plans. Ask the user via AskUserQuestion:

- `[A] All four plans align — proceed`
- `[B] Conflicts surface — surface them`
- `[C] Resource constraint — descope which plan?`

Common conflicts to look for:

- Monetization launches a paywall test the same day as a community
  AMA where the founder will demo the old paywall.
- Content beat depends on assets the live-ops plan does not budget
  for.
- Push frequency cap from content-strategist conflicts with
  community-manager's drum cadence.

---

## Phase 8: Compose the Cycle Document

```markdown
# Live-Ops Cycle — [name] — [from]..[to]

Type: [season / event / update]
Owner: live-ops-designer
Status: Planned

## KPI Targets
| Metric | Current | Target | Hypothesis |

## Content Plan
[from live-ops-designer]

## Monetization Plan
[from monetization-designer]

## Community Plan
[from community-manager]

## Content Direction
[from content-strategist]

## Telemetry Plan
[from analytics-engineer — events to add, dashboards to build]

## Dependencies
- Code changes: [list with story IDs]
- Assets: [list]
- Localized strings: [list]
- Backend changes: [list]

## Calendar
| Date | Beat | Owner | Channel |

## Risks and Mitigations
- [risk] -> [mitigation]

## Stop / Roll-back Conditions
- [if KPI X drops by Y%] -> revert variant Z
- [if support volume Z] -> pause campaign

## Approvals
- Producer
- Live-Ops Designer
- Monetization Designer
- Analytics Engineer
- Community Manager
- Content Strategist
```

Ask before writing to
`production/live-ops/[cycle-name]-cycle.md`.

---

## Phase 9: Story Breakdown

For every dependency identified in Phase 8, propose a story spec for
`/create-stories`. Use AskUserQuestion to confirm scope before
generating.

Stories typically include:

- Code: the new event mechanic, the new push-notification trigger,
  the new content collection.
- Backend: any new endpoint or remote-config schema change.
- Content: copy and asset stories per beat.
- Telemetry: the new analytics events and dashboards.

---

## Phase 10: Update State

Append to `production/session-state/active.md`:

```
## Live-Ops Cycle — [date]
- Cycle: [name]
- Window: [from]..[to]
- KPI targets: [list]
- Stories opened: [count]
- Cycle doc: [path]
- Next: /sprint-plan to fold dependencies into upcoming sprints
```

---

## Error Recovery

If any subagent returns BLOCKED:

1. Surface immediately.
2. If analytics-engineer is blocked (missing telemetry), the cycle
   targets are guesswork — pause and resolve telemetry first.
3. If monetization-designer is blocked (`/balance-check` shows P0
   issues), pause monetization plan until resolved.
4. Other roles: continue, note gap in the cycle document.

---

## Quality Gates / PASS-FAIL

- PASS — every sub-plan exists, no unresolved cross-plan conflicts,
  KPI targets quantified, dependencies surfaced as stories,
  rollback conditions defined.
- FAIL — unresolved conflict, no KPI quantification, or telemetry
  gap that prevents measurement.

---

## Examples

**Example 1 — 8-week season:**
Telemetry shows D7 retention slipping. Plan targets +3pp retention.
Live-ops weekly content beats; monetization adds a season pass A/B
test; community runs a launch livestream and weekly themed challenges;
content-strategist sets a "warmer" tone for in-app copy. 14 stories
opened.

**Example 2 — 5-day event:**
Tied to a holiday. Single content drop, single push wave, no
monetization changes (rules around holidays are tight). Community
plans 2 social posts. 3 stories opened.

---

## Next Steps

- Stories opened -> `/sprint-plan` to fold into upcoming sprint.
- During the cycle -> use `/sprint-status` and analytics-engineer
  weekly to compare actuals to plan.
- After the cycle -> `/retrospective` with telemetry review.
