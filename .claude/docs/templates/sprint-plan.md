<!--
name: sprint-plan
purpose: A single sprint's goal, story list, capacity, and exit criteria. Authored by producer / engineering manager at sprint kickoff; consumed by every team member daily.
consumed-by: /sprint-plan, /sprint-status, /scope-check, /retrospective, /milestone-review
placeholders:
  - {{sprint_id}}
  - {{sprint_name}}
  - {{start_date}}
  - {{end_date}}
  - {{sprint_goal}}
  - {{capacity_points}}
  - {{milestone}}
-->

# Sprint {{sprint_id}}: {{sprint_name}}

| Field | Value |
|-------|-------|
| Dates | {{start_date}} → {{end_date}} ({{n_working_days}} working days) |
| Milestone | {{milestone}} |
| Capacity | {{capacity_points}} story points |
| Producer | |
| Tech lead | |

## Sprint Goal

One sentence. If we have to cut scope, this is the thing we will not cut.

> {{sprint_goal}}

## Success Looks Like

A demoable user-visible outcome at the end of the sprint. Phrase as something
a stakeholder can press buttons on, not a list of internal tasks.

> {{success_demo}}

## Story List

| ID | Title | Type | Owner | Points | Priority | Status |
|----|-------|------|-------|--------|----------|--------|
| STORY-NN | | Logic / Integration / Visual / UI / Config | | | P0 / P1 / P2 | Ready / In Progress / Review / Done / Blocked |

### Capacity

| Engineer | Allocated points | Notes |
|----------|------------------|-------|
| | | |

Sum of allocated points must be ≤ {{capacity_points}}.

## Cross-functional Tasks

| Task | Owner | Due | Done? |
|------|-------|-----|-------|
| Design tokens for new components | | | |
| Localization keys to translation vendor | | | |
| App Store screenshots for new feature | | | |
| Telemetry dashboard updated | | | |
| Beta build pushed to TestFlight / Play Internal | | | |

## Exit Criteria

The sprint is "done" when ALL of the following are true:

- [ ] Sprint goal demoable on a real device (not simulator-only)
- [ ] All P0 stories marked Done with required test evidence
- [ ] Smoke check passes on iOS and Android
- [ ] Crash-free session rate stays ≥ {{cfsr_threshold}} in beta
- [ ] No P0 / P1 bugs open against this sprint's stories
- [ ] Retrospective scheduled

## Risks

| Risk | Likelihood | Impact | Mitigation | Owner |
|------|------------|--------|------------|-------|
| | L / M / H | L / M / H | | |

## Dependencies

| Dependency | On whom | Needed by |
|------------|---------|-----------|
| | | |

## Out of Scope (this sprint)

Items deferred to a later sprint. Listed so stakeholders don't expect them.

- {{deferred_item}}

## Daily Stand-up Format

1. What did I finish since yesterday?
2. What am I working on today?
3. What is blocking me?
4. Anything the rest of the team should know?

## Retrospective Hook

After sprint end, run `/retrospective` and append outcomes to
`production/sprints/{{sprint_id}}/retrospective.md`.
