---
name: design-bible
description: "Section-by-section authoring of the Design Bible — the visual identity spec that gates all visual production. Defines tokens for color, type, space, radius, elevation, motion, plus app icon and splash spec. Run after /brainstorm and before /map-systems or any UX work."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion, WebSearch
model: sonnet
---

# Design Bible

The Design Bible is the single source of truth for tokens. Every UX spec, every component, every asset must reference its tokens — no inline color hexes, no inline spacing values. This skill produces that file.

Output: `design/design-bible.md`

---

## Purpose / When to Run

Run when:
- `design/concept.md` is approved and `design/design-bible.md` does not exist
- Visual identity needs to be tightened before UX work begins
- The user wants to refresh the bible after a rebrand

The bible should exist **before** `/map-systems` and any `/design-system` UI section, so PRDs reference real tokens, not placeholders.

## Inputs

- `design/concept.md` (required)
- `.claude/docs/technical-preferences.md` (for platform target — iOS HIG / Material 3 conventions affect token decisions)
- Optional: existing partial `design/design-bible.md`

## Outputs

- `design/design-bible.md` — token definitions and identity
- Optional: hands a token export task to `/asset-spec` for icon/splash generation prompts

---

## Phase 1: Context

Read concept.md. Extract Section 6 (Tone & Visual Anchor) and the named reference apps. If concept doc is missing, stop.

Identify platform target from technical-preferences:
- iOS only → use iOS HIG (`Apple Human Interface Guidelines`) sizing language
- Android only → Material 3 sizing language
- Both / cross-platform → describe both, with one canonical token system that maps to each

Optionally use `WebSearch` to fetch fresh visual reference for the named comp apps if their tone has shifted.

---

## Phase 2: Skeleton

Write `design/design-bible.md` skeleton:

```markdown
# Design Bible — <App Name>

> **Status**: In Design
> **Last Updated**: <date>
> **Platform target**: <iOS / Android / both>

## 1. Identity & Tone
[To be designed]

## 2. Color Tokens
[To be designed]

## 3. Typography Tokens
[To be designed]

## 4. Spacing & Layout
[To be designed]

## 5. Radius
[To be designed]

## 6. Elevation & Shadow
[To be designed]

## 7. Motion
[To be designed]

## 8. Iconography
[To be designed]

## 9. Imagery & Illustration
[To be designed]

## 10. App Icon
[To be designed]

## 11. Splash / Launch
[To be designed]

## 12. Dark Mode
[To be designed]

## 13. Accessibility
[To be designed]

## 14. Token Naming Conventions
[To be designed]
```

Ask: "May I create the skeleton at `design/design-bible.md`?"

---

## Phase 3: Section-by-Section Authoring

For each section, follow:

```
Context → Question(s) → Options → Decision → Draft → Approval → Write
```

### Section 1: Identity & Tone

Pull from concept.md tone direction. Ask:
- "Distill the brand into 3 adjectives." (free text)
- "What is one word the brand is **not**?" (free text — anti-tone is as useful as tone)
- "Pick a metaphor for the app's voice." (free text — e.g., "calm mentor", "playful teammate")

Spawn `visual-design-director` via Task to crystallize the tone into one paragraph plus 3-5 design principles (e.g., "favor whitespace over density"). Present specialist's draft for approval.

### Section 2: Color Tokens

Define semantic tokens (not raw colors):
- `color.bg.primary` / `bg.elevated` / `bg.muted`
- `color.fg.primary` / `fg.muted` / `fg.inverse`
- `color.brand.primary` / `brand.secondary` / `brand.accent`
- `color.semantic.success` / `warning` / `danger` / `info`
- `color.border.subtle` / `border.strong`

For each, capture:
- Light mode hex
- Dark mode hex (Section 12 covers nuance)
- WCAG AA contrast against primary background — verify before approving
- Source rationale (why this color, what it evokes)

Use `AskUserQuestion` to drive palette decisions:
- "Pick a brand-primary direction":
  - `Cool (blue/teal/violet)`
  - `Warm (orange/red/yellow)`
  - `Neutral with accent (greys + 1 pop)`
  - `Earthy (greens/browns)`
  - `Custom — describe`

After picking, propose 3-5 candidate brand primaries (with hex). Show contrast scores against white and black. User picks.

For dark mode, propose mirrored values; never copy light-mode hexes — dark mode needs lighter brand and softened backgrounds.

Spawn `visual-design-director` via Task to refine the candidate palette and recommend semantic mappings.

### Section 3: Typography Tokens

Capture:
- Display / heading / body / caption / mono — at minimum
- For each: family, weight, size (in pt or sp), line height, letter spacing
- iOS Dynamic Type / Android scaled text behavior — every size must support scaling

Ask about font family choice:
- `System (SF Pro / Roboto)` — recommended, accessible
- `Custom — name and load via app`
- `Mixed — system body + custom display`

Verify license for any custom font. Note in the bible.

Sizes (rough starting points — adjust per concept tone):
- Display: 32-48pt
- Heading 1-3: 24-30pt
- Body: 17pt iOS / 16sp Android (default per HIG / Material)
- Caption: 13-14pt
- Mono: only if shown to users (timestamps, codes)

### Section 4: Spacing & Layout

Define a base grid:
- Base unit: 4pt (most common — half-grid for fine-tuning)
- Tokens: `space.0` through `space.12` (`0`, `2`, `4`, `8`, `12`, `16`, `20`, `24`, `32`, `40`, `48`, `64`)
- Container max widths if applicable
- Safe area conventions (iOS notches, Android system bars)

### Section 5: Radius

Tokens: `radius.none`, `radius.sm`, `radius.md`, `radius.lg`, `radius.full` (pill).
Pick concrete values per the tone — minimal apps use 8-12, playful apps use 16-24.

### Section 6: Elevation & Shadow

iOS uses subtle shadows; Material 3 uses tonal elevation.
Tokens: `elevation.0` (flat), `elevation.1` (cards), `elevation.2` (sheets), `elevation.3` (modals), `elevation.4` (popovers).

For each, define iOS shadow params (color, offset, blur, opacity) and Material 3 tonal-elevation step.

### Section 7: Motion

Tokens:
- Durations: `motion.fast` (~150ms), `motion.medium` (~250ms), `motion.slow` (~400ms)
- Easing: `ease.standard`, `ease.emphasized`, `ease.linear`
- Reduce-motion alternative for every animated transition (Section 13 cross-references this)

### Section 8: Iconography

- Family: `SF Symbols` (iOS) / `Material Symbols` (Android) / custom set
- Stroke weight, fill behavior, sizes per token (`icon.sm`, `icon.md`, `icon.lg`)
- Anti-pattern callouts: never mix two icon families in the same screen

### Section 9: Imagery & Illustration

- Photography style (if any) — saturation, framing, mood
- Illustration style — flat, hand-drawn, isometric, 3D — pick one
- Empty-state illustration role: present? per-screen? canonical?
- AI-generation prompt seed (a 1-line style anchor used by `/asset-spec`)

### Section 10: App Icon

Spawn `visual-design-director` (Task) to propose 3-5 icon directions consistent with Sections 1-3. For each, capture:
- Concept (visual metaphor)
- Composition (centered glyph, gradient field, monogram, etc.)
- Color
- Size variants required (iOS: 1024×1024 master + many derived; Android: adaptive icon foreground + background + monochrome)

User picks one direction. The bible records the chosen direction and the production specs.

### Section 11: Splash / Launch

iOS: `Launch Screen` uses storyboards or asset catalogs — must be silent / non-functional, no animations beyond the OS-controlled fade.

Android: launch theme + (optional) splash screen API on Android 12+.

Capture: background token, logo size, centering, dark-mode variant.

### Section 12: Dark Mode

Confirm dark-mode strategy:
- `Mirrored` — every token has a dark variant
- `Lights-only at v1` — explicit deferral; PRDs must reference this
- `System-controlled only` — follows OS, no in-app override
- `User-toggleable` — settings switch

For mirrored mode, list every color token's dark hex (Section 2 cross-reference).

### Section 13: Accessibility

- WCAG 2.2 AA contrast verified for every fg/bg pair — list ratios
- Dynamic Type / scaled text supported up to at least Large (iOS) / 200% (Android)
- Reduce-motion alternatives for every motion token
- Touch target floor (44×44pt iOS / 48×48dp Android)
- VoiceOver / TalkBack: focus order, labels, hint conventions
- Color is never the only differentiator — every state has a non-color cue

### Section 14: Token Naming Conventions

Decide once:
- Casing: `kebab-case` / `dot.case` / `camelCase`
- Theme prefix: `--theme-color-bg-primary` or `--color-bg-primary` (no theme prefix)
- Export format: CSS variables / Swift constants / Compose Theme / Tailwind config / Style Dictionary

If the team uses Style Dictionary or similar, link the export config path.

---

## Phase 4: Specialist Validation

Spawn `visual-design-director` for a final visual pass once all sections are written. They validate:
- Tokens are internally consistent (motion / radius / spacing scales make sense together)
- Dark-mode pairs all pass contrast
- The identity captures the concept tone

Surface findings; user decides on changes.

For accessibility, optionally spawn `accessibility-specialist` to verify Section 13.

---

## Phase 5: Update Concept and Hand Off

After the bible is complete, ask: "Update `design/concept.md` Section 6 to point at the bible?" — replace the rough tone notes with a link.

Print:
> "Design Bible written. Run `/asset-spec app-icon` and `/asset-spec splash` to produce production specs and AI-gen prompts. Then `/map-systems` and `/design-system` PRDs can reference the bible's tokens directly."

Use `AskUserQuestion`:
- **Options**:
  - `Run /asset-spec app-icon`
  - `Run /asset-spec splash`
  - `Run /map-systems`
  - `Stop here`

---

## Quality Gates

- Every section is non-empty (no `[To be designed]` left)
- Every color pair listed in Section 2 has a verified contrast ratio in Section 13
- Token names follow the convention from Section 14 — no inline raw values used inside any other section
- Dark-mode strategy is explicit, not deferred without a date
- App icon and splash specs reference real tokens from Sections 2-3

---

## Examples

`/design-bible` for a calm-tone meditation app:
- Tokens use a single primary `slate-700` plus accent `lavender-400`; type ramp is two display sizes + three body sizes; motion budget is 200 ms standard / 400 ms emphasized; haptics are reserved for breath cues only.
- App icon spec: monochrome silhouette of a bowed leaf, full-bleed lavender background; meets iOS dark and tinted icon variants.
- Splash spec: lavender-400 background, leaf glyph centered, no copy.

`/design-bible` for a bouldering log:
- Bold high-contrast palette (`charcoal` background, `chalk` foreground, `accent-orange` for grade highlights); type ramp emphasizes numerals (V-grades) at display sizes; motion budget allows 600 ms celebrate animations on send.
- Iconography spec: thick-stroke line set; strokes scale with Dynamic Type / Font Scale.
