<!--
name: flow-spec
purpose: Per-screen or per-flow UX specification for a mobile app. Captures entry points, screen states, interactions, edge cases, accessibility, platform deltas (iOS HIG vs Material 3), and telemetry. Authored by ux-designer; consumed by mobile engineers and QA.
consumed-by: /ux-design, /ux-review, /create-stories, /qa-plan
placeholders:
  - {{flow_name}}
  - {{author}}
  - {{date}}
  - {{related_prd}}
-->

# Flow Spec — {{flow_name}}

| Field | Value |
|-------|-------|
| Flow | {{flow_name}} |
| Related PRD | {{related_prd}} |
| Author | {{author}} |
| Date | {{date}} |
| Status | Draft / Reviewed / Approved |
| Figma | {{figma_link}} |

## 1. Goal

One sentence on what this flow lets the user accomplish.

> {{goal}}

## 2. Entry Points

How does the user arrive at this flow?

| Entry | From | Trigger | Pre-conditions |
|-------|------|---------|----------------|
| Tab bar | Home | tap {{tab_name}} | signed in |
| Push notification | system | tap notification | deep link `{{scheme}}://...` |
| Universal Link / App Link | external | tap link | app installed; cold or warm |
| In-app banner | {{screen}} | tap CTA | {{condition}} |

## 3. Exit Points

| Exit | To | Trigger |
|------|----|----|
| Success | {{destination}} | flow completes |
| Cancel | {{previous}} | back button / swipe |
| Error → support | external | tap "contact support" |

## 4. Screens

For every screen in the flow, document each visual state.

### Screen: {{screen_name}}

#### States

| State | When shown | Visual ref |
|-------|------------|------------|
| Default | initial render with data | Figma frame {{n}} |
| Empty | no data yet | Figma frame {{n}} |
| Loading | while fetching | Figma frame {{n}} |
| Error | network / server failure | Figma frame {{n}} |
| Offline | airplane mode | Figma frame {{n}} |
| Success / confirmation | post-action | Figma frame {{n}} |

#### Interactions

| Element | Interaction | Result |
|---------|-------------|--------|
| {{element}} | tap | {{result}} |
| {{element}} | long press | {{result}} |
| {{element}} | swipe | {{result}} |

#### Validation rules (if input)

| Field | Rule | Inline error copy |
|-------|------|-------------------|
| | | |

## 5. Platform Notes

iOS and Android differ on navigation, modals, and system controls. Capture
deltas per screen.

| Concern | iOS (HIG) | Android (Material 3) |
|---------|-----------|----------------------|
| Navigation | UINavigationController back chevron in top-left | top-app-bar back arrow + system back gesture |
| Primary action placement | bottom-anchored when full screen, top-right when in nav bar | FAB or bottom-anchored button |
| Modal presentation | sheet (PageSheet / FormSheet); swipe to dismiss | bottom sheet or full-screen dialog |
| Confirmation | UIAlertController | Material AlertDialog |
| List dividers | inset on left of label | full-bleed |
| Pull-to-refresh | UIRefreshControl | SwipeRefreshLayout / `pullToRefresh` modifier |
| Date / time pickers | wheel pickers | Material date picker |
| Haptics | UIImpactFeedbackGenerator at success | `HapticFeedbackConstants.CONFIRM` |

## 6. Edge Cases

Reference the PRD's edge cases; specify visual / interaction handling here.

| Case | Handling |
|------|----------|
| Offline | Show offline banner; allow read-only |
| Slow network (>3s) | Skeleton state visible; cancel option after 10s |
| Session expired mid-flow | Re-auth modal; resume on success |
| Backgrounded mid-flow | Resume to same step on return |
| Permission denied | Show non-blocking explanation card; CTA to settings |
| Cold-start deep link | Show this screen first, do not flash home |
| Locale RTL | Mirror layout; test AR / HE |

## 7. Accessibility

Reference `accessibility-requirements.md` for full spec. Per-screen highlights:

- Heading levels: only one H1 per screen
- Reading order: top-to-bottom, left-to-right (mirrored in RTL)
- Live region for async results
- Focus restored to logical point after modal dismiss

## 8. Telemetry

Reference `analytics-event-spec.md` per event.

| Event | When | Properties |
|-------|------|------------|
| `{{flow}}_viewed` | screen impression | source, variant |
| `{{flow}}_action_tapped` | primary CTA tap | step, value |
| `{{flow}}_completed` | success state | duration_ms |
| `{{flow}}_abandoned` | exit before completion | last_step |

## 9. Open Questions

- [ ] {{question}}
