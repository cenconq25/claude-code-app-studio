<!--
name: paywall-design
purpose: Specification for a paywall surface — placement, trigger, plans, trial terms, restore-purchase UX, regulatory copy, A/B variants, and the success metric. Authored by product / monetisation; consumed by mobile engineers and QA.
consumed-by: /design-system, /ux-design, /qa-plan, /release-checklist
placeholders:
  - {{paywall_id}}
  - {{name}}
  - {{author}}
  - {{date}}
  - {{related_prd}}
-->

# Paywall Design — {{name}} ({{paywall_id}})

| Field | Value |
|-------|-------|
| Paywall ID | {{paywall_id}} |
| Author | {{author}} |
| Date | {{date}} |
| Related PRD | {{related_prd}} |
| Status | Draft / In Test / Live / Retired |

## Goal

Single sentence on what this paywall is meant to do.

> {{goal}}

## Placement & Trigger

| Field | Value |
|-------|-------|
| Surface | First-run / Onboarding / Hard wall / Soft wall / Feature gate / Limit reached |
| Triggered by | {{event}} |
| Position in user journey | session #N or action threshold |
| Frequency cap | once per user / once per N days / on every gated action |
| Dismissable? | yes (X in top-right, swipe-down) / no (hard wall) |
| Skip option | "Maybe later" link in legal-required size |

## Plans Offered

| Plan ID | Term | Price (USD) | Trial | Intro offer | Position |
|---------|------|-------------|-------|-------------|----------|
| {{id}}.weekly | 1 week | 4.99 | none | none | top |
| {{id}}.monthly | 1 month | 9.99 | 7-day free | none | middle (default) |
| {{id}}.yearly | 1 year | 49.99 | 7-day free | $24.99 first year | bottom (best value) |
| {{id}}.lifetime | one-time | 99.99 | none | none | optional |

### Regional pricing

Use App Store / Play tiers — do not hard-code. Pricing matrix lives in
`design/pricing/{{paywall_id}}-tiers.md`. Note overrides:

| Region | Override reason | Tier |
|--------|-----------------|------|
| | | |

## Trial Terms

For free-trial offers, copy MUST clearly state:

- Trial duration
- Price after trial
- Auto-renewal
- How to cancel (Settings path)
- Currency conversion is approximate

Example required copy (localize per locale):

> "{{plan_name}} starts free for 7 days, then {{price}}/month. Cancel anytime
> in Settings → Apple ID → Subscriptions / Google Play → Subscriptions."

## Restore Purchase

Apple and Google policy require a reachable restore action.

- Visible "Restore Purchases" link on every paywall
- Behaviour: invokes `Transaction.currentEntitlements` (iOS) /
  `BillingClient.queryPurchasesAsync` (Android)
- Loading state: spinner with cancel after 10s
- Success: dismiss paywall, show toast "{{copy}}"
- Failure: surface message, contact support link

## Regulatory & Store Copy

| Region | Requirement |
|--------|-------------|
| Apple App Store | Must show price, renewal terms, link to Terms and Privacy on the paywall itself; subscription length, content/services included, price per period |
| Google Play | Must show price, renewal terms, billing period |
| EU DMA | Disclose alternative payment options if implemented; link to external billing where allowed |
| Children-likely audience (<13) | No purchase prompts to known minors; if mixed, parental gate |
| California Auto-Renewal Law (ARL) | Conspicuous disclosure of terms; cancellation method clearly explained |

## Visual Spec

| State | Description | Figma |
|-------|-------------|-------|
| Default | initial render | |
| Plan selected | | |
| Loading (purchase in progress) | | |
| Success | | |
| Cancelled | | |
| Error | | |
| Already subscribed | | |
| Restore in progress | | |

## Accessibility

- All plan tiles are accessible buttons with full price + trial terms in label
- "Best value" badge announced as part of the tile label, not as a separate node
- Dynamic Type 200%: tiles stack vertically; CTA stays visible
- Reduce Motion: no looping animations; static hero
- Restore link minimum touch target

## A/B Variants

| Variant | Hypothesis | What changes | Allocation |
|---------|------------|--------------|------------|
| Control | — | current paywall | 50% |
| {{name}} | {{hypothesis}} | {{change}} | 25% |
| {{name}} | {{hypothesis}} | {{change}} | 25% |

Stop conditions: significance reached / fixed duration / safety guardrail.

## Success Metric

Primary: {{metric}} — e.g. trial_to_paid_conversion at 30 days.
Guardrails: {{metric}} — e.g. session_retention_d7 must not drop > 2%.

## Telemetry

| Event | When |
|-------|------|
| `paywall_viewed` | impression |
| `paywall_plan_tapped` | tile selection |
| `paywall_purchase_started` | tap CTA |
| `paywall_purchase_succeeded` | StoreKit / billing success |
| `paywall_purchase_failed` | with error_code |
| `paywall_restore_started` | tap restore |
| `paywall_dismissed` | tap close / swipe down |

## Risk & Compliance Sign-off

- [ ] Legal: trial / renewal copy approved
- [ ] Localization: copy localized for all shipping locales
- [ ] App Store reviewer instructions updated to reach paywall
- [ ] Sandbox & test purchase flow verified (StoreKit testing + Play license testers)
- [ ] Receipt validation server-side wired
