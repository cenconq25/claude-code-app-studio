---
name: ux-design
description: "Section-by-section UX spec authoring for a single screen, flow, or HUD element. Reads concept, design bible, parent PRD, and platform conventions to produce design/ux/<screen-or-flow>.md. Run after the relevant PRD is approved and before stories cite UI behavior."
argument-hint: "<screen-or-flow-name>"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
model: sonnet
---

# UX Design — Per Screen / Flow

A UX spec sits between the PRD (what the system does) and the implementation (how it looks). It captures: layout, states, transitions, copy, accessibility, platform conventions, and the engineer-facing implementation hooks.

Output: `design/ux/<screen-or-flow>.md`

---

## Purpose / When to Run

Run when:
- A PRD has UI Requirements that need spec-level detail
- A specific screen or flow is heading into implementation
- A flow crosses two PRDs and needs its own UX spec to bridge them

Examples of UX-spec-worthy targets:
- A single screen (`home`, `settings-profile`, `paywall`)
- A flow across screens (`onboarding-flow`, `signup-flow`)
- A persistent HUD element (`mini-player`, `floating-action-button`)

## Inputs

- Screen / flow name (required)
- Parent PRD(s) — the skill detects from name or asks
- `design/design-bible.md` (required for tokens)
- `design/concept.md` (for tone)
- `.claude/docs/technical-preferences.md` (for platform conventions)

## Outputs

- `design/ux/<screen-or-flow>.md`

---

## Phase 1: Resolve Target

If no name passed, ask:
- **Prompt**: "Which screen or flow are we speccing?"
- Free text. Capture as kebab-case for filename.

Detect parent PRD: glob `design/prd/*.md`, search for the screen name in each. If multiple match, ask which is the parent. If none match, ask:
- "No PRD currently mentions this screen. Is this a missing PRD section, or is the screen genuinely new?"

If genuinely new, suggest authoring a PRD first.

---

## Phase 2: Read Context

- Read parent PRD (Sections 3 Detailed Requirements, 4 Edge Cases, 8 Accessibility relevant)
- Read `design/design-bible.md` — tokens to reference
- Read `design/concept.md` — tone anchor
- Read existing `design/ux/*.md` for screens that share a flow

---

## Phase 3: Skeleton

Write `design/ux/<name>.md`:

```markdown
# UX Spec: <Screen / Flow>

> **Status**: In Design
> **Parent PRD**: design/prd/<system>.md
> **Last Updated**: <date>

## 1. Screen Goal
[To be designed]

## 2. User Flow Context
[To be designed]

## 3. Layout & Composition
[To be designed]

## 4. States
[To be designed]

## 5. Empty / Loading / Error / Offline
[To be designed]

## 6. Transitions & Motion
[To be designed]

## 7. Copy & Tone
[To be designed]

## 8. Accessibility
[To be designed]

## 9. Platform Notes (iOS / Android)
[To be designed]

## 10. Implementation Hooks
[To be designed]

## 11. Open Questions
[To be designed]
```

Ask before write.

---

## Phase 4: Section Authoring

For each section, follow the cycle:

```
Context → Question(s) → Options → Decision → Draft → Approval → Write
```

### Section 1: Screen Goal

One sentence: what is the user trying to do here, and what is the screen optimizing for?

Example: "On Home, the user sees their next planned attempt and can start a session in one tap. Optimized for: speed-to-action."

### Section 2: User Flow Context

- How did the user arrive here? (entry points)
- Where can they go from here? (exits)
- Is this a step in a larger flow? Reference the flow doc

Spawn `ux-designer` (Task) for any flow with 2+ entry points to surface conflicts.

### Section 3: Layout & Composition

Describe the layout in structured prose (no images at this stage — that comes later in `/asset-spec` or via wireframes the team produces externally).

For each region:
- **Header / nav** — title, leading button, trailing button, tab placement
- **Body** — primary content area, secondary content
- **Footer / nav** — sticky CTA, tab bar
- **Floating** — FAB, mini-player, toast slot

Reference design-bible tokens by name. Never use raw colors or px values:
- "Header: 56pt height, `color.bg.primary`, title in `type.title.medium`."

### Section 4: States

Every screen has multiple states. List exhaustively:
- Default (the happy state)
- Loading (initial data fetch)
- Empty (user has no data yet)
- Partial (some data, some still loading)
- Error (request failed)
- Offline (no network)
- Stale (cached data shown while refreshing)
- Refreshing (pull-to-refresh active)
- Disabled / read-only (if relevant)
- Permission denied (if the screen requires a permission)

For each state, describe what the user sees and what they can do.

### Section 5: Empty / Loading / Error / Offline

Expand Section 4 for the four critical states with copy and CTA:
- **Empty** — illustration token (from bible), headline copy, body copy, CTA label
- **Loading** — skeleton shape (mirrors final layout) or spinner; never both; never a blank screen for >300ms
- **Error** — what error, what action (retry / contact support / fall back)
- **Offline** — same look as cached / stale, with a non-modal banner explaining offline status

Mobile users encounter these states constantly. A spec without these is incomplete.

### Section 6: Transitions & Motion

For every state-to-state transition:
- Duration token (from bible — `motion.fast` etc.)
- Easing token
- Reduce-motion alternative (instant or fade)

For navigation transitions:
- iOS: push, modal, full-screen cover
- Android: forward, shared element, dialog

Default to platform conventions; note any deviations and justify.

### Section 7: Copy & Tone

Every visible string, exactly as it should appear.
- Title
- Subtitle
- Button labels
- Empty / error / loading copy
- Success / failure toast copy

For each, mark whether it is final or placeholder. Final strings are extracted to the localization bundle by `/extract` or i18n tooling.

If the project supports multiple locales, note any strings that need cultural review.

### Section 8: Accessibility

- VoiceOver / TalkBack reading order — list element-by-element in the order they should be read
- Each interactive element: label + role + hint (iOS) / contentDescription + role (Android)
- Dynamic Type / scaled text — confirm layout reflows
- Touch targets ≥ 44×44pt iOS / 48×48dp Android
- Color is not the only signal — verify each state has a non-color indicator
- Reduce motion respected (Section 6 cross-reference)
- Voice Control / Switch Control — every action reachable

Spawn `accessibility-specialist` (Task) to validate before finalizing.

### Section 9: Platform Notes

iOS HIG and Material 3 differ enough to warrant a per-platform delta when both are targets:
- Tab bar position (bottom on iOS, can be top or bottom on Android)
- Back button (iOS uses navigation gesture, Android has system back)
- Action sheet vs. bottom sheet
- Confirmation dialog conventions
- Date pickers (native picker vs. wheel)
- Swipe actions (iOS native, Android via library)
- Pull-to-refresh styling
- Long-press menus
- Accessibility shortcut differences

For single-platform projects, write "N/A — <platform> only" but still note any HIG / Material 3 conventions in play.

### Section 10: Implementation Hooks

Engineer-facing notes:
- Component file the implementation should live in (or anticipated path)
- ADR(s) governing the structural decision (state pattern, navigation pattern)
- TR-IDs covered (link to PRD)
- Any feature flag gating
- Analytics events emitted from this screen (with payload schema reference)
- Deep links that resolve to this screen

### Section 11: Open Questions

Capture anything raised during design that didn't fully resolve.

---

## Phase 5: Specialist Pass

After all sections are written, spawn `ux-designer` (Task) for a final synthesis:
- Layout / composition consistency with bible
- States completeness
- Copy tone alignment with concept doc
- Whether the screen is doing too much (recommend splitting)

Spawn `accessibility-specialist` for Section 8 validation.

---

## Phase 6: Update Cross-Refs and Hand Off

- Update parent PRD's "UI Requirements" section (or wherever it references screens) to link to this UX spec
- Update `production/session-state/active.md`

Print:
> "UX spec written. Run `/ux-review design/ux/<name>.md` (in a fresh session) to validate, or `/asset-spec` to generate visual specs and AI-gen prompts for the components on this screen."

Use `AskUserQuestion`:
- **Options**:
  - `Run /ux-review (in fresh session)`
  - `Run /asset-spec for components on this screen`
  - `Author the next screen — run /ux-design <name>`
  - `Stop here`

---

## Edge Cases

- **The screen has no business logic**: still spec it — empty / error / accessibility / platform notes still apply.
- **The flow spans 5+ screens**: split into one UX spec per screen + a flow-level spec that ties them together.
- **The screen is generated dynamically (e.g., feature-flagged variants)**: spec the dominant variant and note variants.

---

## Quality Gates

- All 11 sections are non-empty (or explicitly marked N/A with rationale)
- Every visible state listed in Section 4 has copy + behavior in Sections 5-7
- Accessibility section addresses screen reader + dynamic type + touch targets at minimum
- Platform Notes section is non-empty for cross-platform projects
- Every token reference is a real token from the design bible (verify by grep)

---

## Examples

`/ux-design home`
- Parent PRD: `design/prd/home.md`
- 11 sections written
- Lists 8 states (default, loading, empty, partial, error, offline, refreshing, disabled-during-sync)
- Identifies 12 distinct copy strings + 3 illustrations
- Specifies bottom tab on iOS, bottom nav on Android, with rationale

`/ux-design onboarding-flow`
- Parent PRD: `design/prd/onboarding.md`
- Flow-level spec linking to 5 per-screen UX specs (one per onboarding screen)
- Captures inter-screen transition behavior and the skip flow
