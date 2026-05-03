<!--
name: accessibility-requirements
purpose: Per-feature accessibility specification. Authored alongside the PRD by accessibility-specialist or designer; consumed by engineers and QA. Required before any UI story may be marked Ready.
consumed-by: /ux-design, /ux-review, /story-readiness, /qa-plan, /test-evidence-review
placeholders:
  - {{feature_name}}
  - {{author}}
  - {{date}}
  - {{related_prd}}
-->

# Accessibility Requirements — {{feature_name}}

| Field | Value |
|-------|-------|
| Feature | {{feature_name}} |
| Related PRD | {{related_prd}} |
| Author | {{author}} |
| Date | {{date}} |
| Compliance target | WCAG 2.2 AA + Apple Accessibility + Android Accessibility |
| Status | Draft / Reviewed / Approved |

## Reading Guide

Every requirement below is testable. If a row cannot be tested, rewrite it
until it can. "Looks reasonable" is not a requirement.

## Screen Reader (VoiceOver / TalkBack)

### Element labelling

| Element | Visible label | Accessibility label | Trait / role | Hint (if needed) |
|---------|---------------|---------------------|--------------|------------------|
| {{button_name}} | | | button | |
| {{decorative_image}} | (none) | (none — `accessibilityElementsHidden`) | — | |

### Reading order

Describe the intended sequence in which the screen reader visits elements,
top-to-bottom. Note any explicit reordering vs. visual layout.

1. Header → "{{title}}"
2. Status banner if present
3. Main content
4. Primary action
5. Secondary action

### Announcements

Dynamic content changes announced via `accessibilityAnnouncementDidFinish`
(iOS) / live region (Android Compose).

| Trigger | Announcement |
|---------|--------------|
| Form validation error | "Email field invalid. Use a valid format like name at example dot com." |
| Async load complete | "{{n}} results loaded." |
| Network error | "Connection lost. Retrying." |

### Walkthroughs to record

- [ ] iOS VoiceOver: full happy path
- [ ] iOS VoiceOver: error path
- [ ] Android TalkBack: full happy path
- [ ] Android TalkBack: error path

## Dynamic Type / Font Scale

- Minimum supported: iOS xSmall (.xSmall) / Android 0.85x
- Maximum supported: iOS Accessibility XXXL (`.accessibilityExtraExtraExtraLarge`) / Android 2.0x (200%)
- Behaviour at maximum: layout reflows; no truncation of essential content;
  buttons may stack vertically; horizontal scroll is acceptable for tables only

| Element | Behaviour at AX-XXXL | Notes |
|---------|----------------------|-------|
| Primary CTA | Wraps to 2 lines | |
| Form labels | Stay above field | |
| Modal dialog | Becomes scrollable | |

## Contrast

Target: WCAG AA — 4.5:1 body, 3:1 large (≥18pt regular or ≥14pt bold), 3:1
non-text UI.

| Element | Foreground | Background | Ratio | Pass |
|---------|------------|------------|-------|------|
| Body text | | | | Y / N |
| Disabled state | | | | Y / N (note: disabled is exempt from contrast) |
| Icon on button | | | | Y / N |

Verify in **light mode AND dark mode** for every entry.

## Touch Targets

| Element | Visible size | Hit area | Spacing to neighbour |
|---------|--------------|----------|----------------------|
| | | ≥ 44×44 pt (iOS) / ≥ 48×48 dp (Android) | ≥ 8 dp |

## Reduce Motion

Setting respected: iOS `UIAccessibility.isReduceMotionEnabled` /
Android `Settings.Global.ANIMATOR_DURATION_SCALE == 0`.

| Animation | Default behaviour | Reduce-motion behaviour |
|-----------|--------------------|--------------------------|
| Page transition | Slide | Cross-fade or none |
| Pull-to-refresh | Spinner bounce | Static spinner |
| Hero image parallax | Parallax on scroll | No parallax |

## Captions / Transcripts

Required for any video, audio, or VO content.

| Asset | Captions? | Transcript? | Language |
|-------|-----------|-------------|----------|
| | | | |

## Focus Order (keyboard / external switch / hardware keyboard)

For iPad, Android keyboard users, and switch control:

1. {{element}}
2. {{element}}
3. {{element}}

Trap-focus expected on modals; restored on dismiss.

## Voice Control / Voice Access

- All actionable elements must have a unique, speakable name.
- Avoid relying on icon-only buttons without labels (`accessibilityLabel`).

## Captions for Form Errors

- Errors announced via screen reader the moment they appear.
- Errors associated programmatically with the field (iOS:
  `accessibilityErrorMessage`; Android: `setError`).

## Verification Checklist

- [ ] Full VoiceOver walkthrough recorded and uploaded to evidence
- [ ] Full TalkBack walkthrough recorded and uploaded to evidence
- [ ] Dynamic Type / Font Scale 200% spot check passed
- [ ] Reduce Motion respected
- [ ] Contrast verified in light and dark mode
- [ ] Touch targets measured against grid
- [ ] Focus order verified with keyboard / switch
- [ ] Captions present for any audio/video
