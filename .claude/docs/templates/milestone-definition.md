<!--
name: milestone-definition
purpose: Define a major milestone (Alpha, Beta, Store Submission, GA, etc.) with hard gates, soft gates, owners, and a demo plan.
consumed-by: /milestone-review, /launch-checklist, /gate-check, /sprint-plan
placeholders:
  - {{milestone_name}}
  - {{milestone_code}}
  - {{target_date}}
  - {{owner}}
  - {{stage}}
-->

# Milestone: {{milestone_name}} ({{milestone_code}})

| Field | Value |
|-------|-------|
| Stage | Concept / Pre-production / Production / Beta / Submission / GA / Live-Ops |
| Target date | {{target_date}} |
| Owner | {{owner}} |
| Status | Planning / On track / At risk / Slipped / Hit |

## Scope

What this milestone delivers, in user-visible terms. Bullet list.

- {{deliverable}}
- {{deliverable}}

## Hard Gates *(BLOCKING)*

The milestone CANNOT be declared hit unless all of these are true. No
exceptions without director-level sign-off.

- [ ] All P0 PRDs implemented and verified
- [ ] Crash-free session rate ≥ {{cfsr_threshold}} on beta cohort over 7 days
- [ ] No P0 bugs open
- [ ] iOS and Android builds installable on TestFlight / Play Internal
- [ ] Privacy nutrition labels (iOS) and Data Safety form (Play) drafted
- [ ] Accessibility audit passes WCAG AA
- [ ] All P0 stories have test evidence
- [ ] Architecture traceability matrix shows zero untraced P0 requirements

## Soft Gates *(ADVISORY)*

Strongly recommended; missing one prompts a discussion but is not auto-blocking.

- [ ] Performance budgets met (cold start ≤ {{cold_start_ms}}ms p95)
- [ ] Localization complete for {{locale_list}}
- [ ] Onboarding completion rate ≥ {{onboarding_pct}}% in beta
- [ ] App Store screenshots captured at all required sizes
- [ ] Marketing site / store listing draft ready

## Dependencies

| Dependency | Owner | Status |
|------------|-------|--------|
| Backend API v{{n}} live | | |
| Translations delivered | | |
| Legal review of new permissions | | |
| Store account & certs ready | | |

## Sprints Inside This Milestone

| Sprint | Goal | Status |
|--------|------|--------|
| | | |

## Demo Plan

How we will show this milestone to stakeholders. Specific, demoable, on-device.

- Audience: {{audience}}
- Devices: iPhone {{model}} + Pixel {{model}} (real, not simulator)
- Duration: ~{{minutes}} minutes
- Script:
  1. {{step}}
  2. {{step}}
  3. {{step}}
- Questions to answer for the audience: {{questions}}

## Risks

| Risk | Likelihood | Impact | Mitigation | Owner |
|------|------------|--------|------------|-------|
| | L / M / H | L / M / H | | |

## Go / No-go Decision

To be filled in at the gate review meeting.

- Decision: GO / NO-GO / DELAY by {{n}} days
- Decided by: {{name}}, {{name}}
- Rationale:
- Action items if NO-GO / DELAY:
