<!--
name: analytics-event-spec
purpose: A single analytics-event taxonomy entry. One event per file, so changes show up cleanly in PRs. Defines event name, typed properties, trigger, owner, sample payload, downstream usage, and consent metadata.
consumed-by: /design-system, /qa-plan, /story-readiness, /story-done
placeholders:
  - {{event_name}}
  - {{owner}}
  - {{added_in_version}}
  - {{date}}
naming-convention: snake_case verb + noun (e.g. paywall_viewed, subscription_purchased, deep_link_opened)
-->

# Event: `{{event_name}}`

| Field | Value |
|-------|-------|
| Owner | {{owner}} |
| Added in | v{{added_in_version}} |
| Last updated | {{date}} |
| Status | Proposed / Live / Deprecated |
| Source platforms | iOS / Android / both |

## Purpose

One sentence on what question this event answers.

> {{purpose}}

## Trigger

When exactly does this event fire? Be precise — "page load" vs. "page first
fully visible to user" matters for funnels.

- Trigger condition: {{description}}
- Source code reference: {{file_path}}:{{line}}
- Fired exactly once per: session / impression / action / lifetime
- De-dupe key: {{key_or_none}}

## Who Fires It

- Code path on iOS: {{module_or_class}}
- Code path on Android: {{module_or_class}}
- Code path on RN / Flutter (if cross-platform): {{module_or_class}}
- Server-side mirror (if any): {{service}}

## Properties

Strongly typed. Avoid free-form strings — use enums.

| Property | Type | Required? | Allowed values | Description |
|----------|------|-----------|----------------|-------------|
| `source` | enum | yes | `home`, `notification`, `deep_link`, `widget` | how user reached the trigger |
| `variant` | string | no | A/B test cell | |
| `value` | number | no | ≥ 0 | currency, count, score |
| `currency` | enum | conditional | ISO 4217 codes | required if `value` is monetary |
| `duration_ms` | integer | no | ≥ 0 | for timing events |
| `error_code` | string | no | snake_case | for failure events |

### Common automatic properties (added by SDK)

- `app_version`, `os_version`, `device_model`, `locale`, `network_type`
- `user_id` (if signed in and consent allows)
- `session_id`, `event_timestamp`

## Sample Payload

```json
{
  "event": "{{event_name}}",
  "properties": {
    "source": "home",
    "variant": "control",
    "value": 9.99,
    "currency": "USD",
    "duration_ms": 1420
  },
  "context": {
    "app_version": "{{added_in_version}}",
    "os_version": "iOS 17.4",
    "device_model": "iPhone 15 Pro",
    "locale": "en-US"
  }
}
```

## Downstream Usage

Where this event powers something. Keeping this list current prevents silent
breakage when names or schemas change.

| Surface | Use | Owner |
|---------|-----|-------|
| Dashboard | {{name}} | data team |
| Funnel | {{funnel}} | growth |
| Cohort | {{name}} | growth |
| Retention model | | data |
| Marketing platform export | Meta / TikTok / Adjust / AppsFlyer SAN | growth |

## Consent & Privacy

| Concern | Setting |
|---------|---------|
| ATT (iOS) requires permission? | yes / no — if yes, event is suppressed when user declines |
| Sent to ad attribution partner? | yes / no |
| Contains PII? | no — verified by privacy-engineer on {{date}} |
| Children's data (COPPA)? | excluded under 13 |
| GDPR special category? | no |
| Retention | {{days}} days raw / {{days}} days aggregated |

## Sampling

- Sample rate: 100% / {{percent}}% / dynamic by tier
- Rationale:

## Versioning Strategy

If properties change, follow these rules:

- Adding a new optional property: no version bump
- Removing or renaming a property: bump event suffix (`{{event_name}}_v2`)
  and run both for one full release cycle for funnel continuity
- Changing semantics of a property without renaming: forbidden — bump version

## Verification

- [ ] Manual fire on iOS with debug pipeline visible
- [ ] Manual fire on Android with debug pipeline visible
- [ ] Verified in BigQuery / Snowflake / data lake within 1 hour
- [ ] Schema check enabled in CI (rejects unknown properties)
