<!--
name: post-mortem
purpose: Blameless review of an incident or near-miss — production crash, bad release, store rejection, data leak, missed deadline. Focus on systems and process, not individuals.
consumed-by: /retrospective, /milestone-review
placeholders:
  - {{incident_id}}
  - {{title}}
  - {{incident_date}}
  - {{detected_at}}
  - {{resolved_at}}
  - {{severity}}
  - {{author}}
-->

# Post-Mortem: {{title}}

| Field | Value |
|-------|-------|
| Incident ID | {{incident_id}} |
| Severity | SEV-1 (data loss / outage) / SEV-2 (major degradation) / SEV-3 (minor) / SEV-4 (cosmetic) |
| Date | {{incident_date}} |
| Detected at | {{detected_at}} |
| Resolved at | {{resolved_at}} |
| Total user impact duration | {{duration}} |
| Author | {{author}} |
| Reviewers | |
| Status | Draft / Under Review / Final |

## TL;DR

Two sentences: what broke, who noticed, what we did, and what we are changing.

## Impact

- Users affected: {{count}} ({{percent}}% of MAU)
- Platforms affected: iOS {{versions}} / Android {{versions}}
- Sessions affected: {{count}}
- Revenue impact: {{amount}}
- Data loss: Yes / No — describe
- Store standing: any policy strikes? rejected build?
- Public communication: was a status post / patch note required?

## Timeline (UTC)

| Time | Event | Source |
|------|-------|--------|
| {{t}} | First commit / config change introducing fault | git |
| {{t}} | Build released to {{percent}}% rollout | App Store Connect / Play Console |
| {{t}} | First user report | support ticket #N / app store review |
| {{t}} | Crashlytics alert fired | Crashlytics |
| {{t}} | Engineer paged | PagerDuty |
| {{t}} | Mitigation deployed: {{action}} | |
| {{t}} | Full resolution confirmed | |
| {{t}} | All-clear posted | |

## What Went Well

- Detection: {{what_helped_us_find_it_fast}}
- Response: {{what_helped_us_fix_it_fast}}
- Communication: {{what_helped_users_or_stakeholders}}

## What Did Not Go Well

- {{problem}}
- {{problem}}

## Contributing Factors

A bulleted causal chain. Avoid "human error" as a leaf — keep asking why.

- Code change: {{description}} (commit {{sha}})
- Missing safeguard: {{what_would_have_caught_this}}
- Process gap: {{what_review_step_did_not_happen}}
- Tooling gap: {{what_would_have_warned_us}}
- Knowledge gap: {{what_we_did_not_realise}}

## Five Whys

1. Why did {{thing}} happen? Because {{cause_a}}.
2. Why did {{cause_a}} happen? Because {{cause_b}}.
3. Why did {{cause_b}} happen? Because {{cause_c}}.
4. Why did {{cause_c}} happen? Because {{cause_d}}.
5. Why did {{cause_d}} happen? Because {{cause_e}}.

## Action Items

| ID | Action | Owner | Due | Type | Status |
|----|--------|-------|-----|------|--------|
| AI-1 | | | | Prevent / Detect / Respond | Open |
| AI-2 | | | | | |

Each action item must:

- Be assigned to a single owner
- Have a hard due date
- Be tracked in the issue tracker (link)

## Lessons Learned

For the broader team — patterns to remember beyond this specific incident.

## Appendix

- Related runbooks
- Crashlytics / Sentry issue links
- Screenshots / logs
- Customer communications sent
