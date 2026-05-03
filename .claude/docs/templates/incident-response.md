<!--
name: incident-response
purpose: Real-time incident timeline doc. Created at the moment something breaks (production crash spike, store rejection, data leak, payment outage) and updated continuously by the incident commander until resolution. Becomes input to the post-mortem afterwards.
consumed-by: /retrospective, /hotfix
placeholders:
  - {{incident_id}}
  - {{title}}
  - {{opened_at}}
  - {{commander}}
  - {{severity}}
-->

# INCIDENT INC-{{incident_id}}: {{title}}

> LIVE DOCUMENT — update in real time. Do NOT wait for the dust to settle.

| Field | Value |
|-------|-------|
| Severity | SEV-1 / SEV-2 / SEV-3 / SEV-4 |
| Opened | {{opened_at}} (UTC) |
| Commander | {{commander}} |
| Comms lead | |
| Scribe | |
| Status | Investigating / Identified / Mitigating / Monitoring / Resolved |
| Channels | Slack #inc-{{incident_id}} / Zoom {{link}} |

## Severity Definitions

| Level | Criteria |
|-------|----------|
| SEV-1 | Data loss, full outage, public security incident, store removal |
| SEV-2 | Core flow broken for a large cohort (login, payment, onboarding); crash rate ≥ 5x baseline |
| SEV-3 | Feature broken; workaround available; <5% of users affected |
| SEV-4 | Cosmetic / minor; backlog candidate |

## Current State

One sentence, updated every 15 minutes: what we know now, what we are doing,
when we will next update.

> {{current_status}}

Next update: **{{next_update_time}}**

## Impact

- Users affected (estimate): {{count}}
- Platforms: iOS {{versions}} / Android {{versions}} / build {{n}}
- First detected via: {{source}} (Crashlytics / Sentry / app store review / support / monitoring)
- Crash rate: {{baseline}} → {{current}}
- Revenue impact: {{estimate}}

## Timeline (UTC)

| Time | Event | By | Source |
|------|-------|----|--------|
| {{t}} | Incident opened. {{trigger_event}}. | {{name}} | |
| {{t}} | Commander assigned: {{name}}. | | |
| {{t}} | Hypothesis: {{hypothesis}}. | | |
| {{t}} | Action: {{what_we_did}}. | | |
| {{t}} | Result: {{what_happened}}. | | |
| {{t}} | Mitigation candidate: {{action}}. | | |
| {{t}} | Mitigation deployed. | | |
| {{t}} | Confirmed mitigation effective: {{evidence}}. | | |
| {{t}} | Resolved. | | |

## Current Hypothesis

What we currently think the cause is. Update when evidence shifts.

> {{hypothesis}}

## Actions Taken

| Action | Result | Reverted? |
|--------|--------|-----------|
| | | |

## Mitigation Options

Maintain a ranked list. Cross out as they are tried.

1. Roll back release ({{build_id}}) — {{eta}}
2. Disable feature flag `{{flag_name}}` server-side — {{eta}}
3. Push hotfix build — {{eta}}
4. Adjust phased rollout to 0% — {{eta}}

## Communications Log

| Time | Channel | Audience | Message |
|------|---------|----------|---------|
| | Status page / App Store reply / In-app banner / Support macro / Slack | | |

## Resolution

- Resolved at: {{resolved_at}}
- Mitigation that worked: {{what_fixed_it}}
- Permanent fix tracking: {{ticket}}
- Post-mortem owner: {{name}} — due within 5 business days

## Hand-off to Post-Mortem

Once resolved and stable for {{stability_window}}, create the post-mortem from
this document using `post-mortem.md` template. Copy the timeline verbatim.
