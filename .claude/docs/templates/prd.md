<!--
name: prd
purpose: Product Requirements Document for a single mobile app feature, screen, or capability. Authored by product-manager / feature-owner; consumed by designers, engineers, and QA.
consumed-by: /design-system, /design-review, /prd-review, /create-stories, /create-epics, /qa-plan, /reverse-document
placeholders:
  - {{feature_name}}
  - {{prd_id}}
  - {{author}}
  - {{date}}
  - {{target_release}}
  - {{platform_targets}}
  - {{primary_persona}}
  - {{jtbd_statement}}
  - {{success_metric}}
  - {{success_threshold}}
  - {{out_of_scope_items}}
required-sections:
  - Overview
  - User Need (JTBD)
  - User Stories
  - Detailed Rules
  - Edge Cases
  - Dependencies
  - Acceptance Criteria
  - Tunable Knobs
-->

# PRD: {{feature_name}}

| Field | Value |
|-------|-------|
| **PRD ID** | {{prd_id}} |
| **Author** | {{author}} |
| **Date** | {{date}} |
| **Target Release** | {{target_release}} |
| **Platforms** | {{platform_targets}} (e.g. iOS 16+, Android 10+ / API 29+) |
| **Status** | Draft / In Review / Approved / Shipped |

## 1. Overview *(REQUIRED)*

One paragraph describing what this feature is, who it is for, and why we are
building it now. A skill scanning the PRD index uses this paragraph to decide
whether to read the full document — make it specific.

## 2. User Need (JTBD) *(REQUIRED)*

### Jobs-To-Be-Done

> When **{{situation}}**, I want to **{{motivation}}**, so I can **{{outcome}}**.

- **Primary persona**: {{primary_persona}} (link to `design/personas/`)
- **Secondary personas**: {{secondary_personas}}
- **Underserved need**: {{what_is_painful_today}}

### Why now

What changed in the market, the platform, or the product that makes this the
right moment to ship this work?

## 3. User Stories *(REQUIRED)*

| ID | As a... | I want to... | So that... | Priority |
|----|---------|--------------|------------|----------|
| US-1 | {{persona}} | {{action}} | {{outcome}} | P0 |
| US-2 | | | | P1 |
| US-3 | | | | P2 |

## 4. Detailed Rules *(REQUIRED)*

Unambiguous specification of behaviour. One bullet per rule. If you find
yourself writing a paragraph, split it.

- R-1: {{rule}}
- R-2: {{rule}}
- R-3: {{rule}}

### Platform-specific rules

| Concern | iOS | Android |
|---------|-----|---------|
| Navigation pattern | {{ios_nav}} (UINavigationController / NavigationStack) | {{android_nav}} (Navigation Component / Material 3) |
| Permission prompt | {{ios_permission}} (ATT / Photos / Notifications) | {{android_permission}} (runtime permission / POST_NOTIFICATIONS) |
| Deep-link scheme | {{ios_deep_link}} (Universal Links) | {{android_deep_link}} (App Links) |
| Background behaviour | {{ios_bg}} | {{android_bg}} |

## 5. Edge Cases *(REQUIRED)*

| Case | Expected behaviour |
|------|---------------------|
| Offline / airplane mode | |
| Low storage / quota exceeded | |
| User denies permission | |
| Slow network (>3s response) | |
| Server error / 5xx | |
| Token expired mid-action | |
| App backgrounded mid-flow | |
| Cold start vs. warm start entry | |
| Notification deep link | |
| Locale = RTL (Arabic / Hebrew) | |

## 6. Dependencies *(REQUIRED)*

- **Upstream services / APIs**: {{api_dependencies}}
- **SDKs**: {{sdk_dependencies}} (e.g. Firebase, RevenueCat, Sentry)
- **Other features**: {{feature_dependencies}}
- **Design tokens / system**: {{design_system_dependencies}}
- **Localization keys required**: {{l10n_keys}}

## 7. Acceptance Criteria *(REQUIRED)*

Testable conditions for "done". Each line should map cleanly to a story or test.

- [ ] AC-1: {{condition}}
- [ ] AC-2: {{condition}}
- [ ] AC-3: {{condition}}
- [ ] AC-4: All Edge Cases (section 5) handled
- [ ] AC-5: Telemetry events fire as specified (section 9)
- [ ] AC-6: Accessibility requirements met (section 10)

## 8. Tunable Knobs *(REQUIRED)*

Values that may be adjusted post-launch via remote config / feature flag /
server-side config. NEVER hardcode these in the app.

| Knob | Default | Range | Source | Notes |
|------|---------|-------|--------|-------|
| {{knob_name}} | {{default}} | {{min}}–{{max}} | Remote Config / Server | |

## 9. Telemetry

Events to capture. Reference `analytics-event-spec.md` per event.

| Event | When fired | Key properties | Funnel step |
|-------|------------|----------------|-------------|
| {{event_name}} | | | |

- Consent: ATT-required? GDPR-special-category? Children's data?
- Retention: {{retention_period}}

## 10. Accessibility Requirements

Reference `accessibility-requirements.md` for the full a11y spec. Required minimums:

- VoiceOver / TalkBack: every actionable element has a label and trait
- Dynamic Type / Font Scale: layout reflows up to 200%
- Contrast: WCAG AA (4.5:1 body, 3:1 large)
- Touch targets: ≥ 44pt (iOS) / 48dp (Android)
- Reduce Motion: animation respects user setting
- Captions: any video / audio content

## 11. Out-of-Scope

Explicit list of things this PRD does NOT cover. Prevents scope creep.

- {{out_of_scope_items}}

## 12. Glossary

| Term | Meaning |
|------|---------|
| | |

## Open Questions

- [ ] {{question}} — owner: {{name}} — needed by: {{date}}

## Sign-off

| Role | Name | Approved |
|------|------|----------|
| Product | | |
| Design | | |
| Engineering | | |
| QA | | |
