---
name: asset-spec
description: "Generates per-asset visual specifications and AI-generation prompts from PRDs and the design bible. Produces structured spec files and updates a master asset manifest. Use after design bible is approved and a UX spec or PRD identifies assets to produce. Output: design/assets/<asset>.md plus design/assets/manifest.md."
argument-hint: "[asset-name | system:<system> | screen:<screen> | app-icon | splash]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
model: sonnet
---

# Asset Spec

Bridges design and asset production. For each asset (icon, illustration, animation, app icon, splash, hero image), this skill produces a spec the asset producer (designer or AI tool) can act on, plus an AI-gen prompt seeded from the design bible.

Outputs:
- `design/assets/<asset-name>.md` — per-asset spec
- `design/assets/manifest.md` — running list of assets

---

## Purpose / When to Run

Run when:
- The design bible has been approved
- A UX spec or PRD calls for specific assets (illustrations, icons, hero images, animations)
- The team needs production-ready specs for a designer or for AI generation

## Inputs

- Asset name OR system/screen scope
- `design/design-bible.md` (required for tokens and style anchors)
- Source PRD or UX spec
- Existing manifest if any

## Outputs

- `design/assets/<asset-name>.md` per asset
- `design/assets/manifest.md` updated with new entries

---

## Phase 1: Resolve Scope

Argument forms:
- `<asset-name>` — single asset (e.g., `empty-state-projects`)
- `system:<system>` — all assets called out in a system PRD
- `screen:<screen>` — all assets in a UX spec
- `app-icon` — app icon spec (special case, full size matrix)
- `splash` — splash / launch screen spec

If no argument: ask via `AskUserQuestion`.

---

## Phase 2: Gather Sources

Read:
- The design bible (full — the asset spec must reference its tokens and style anchor)
- The relevant PRD or UX spec (full)
- Existing `design/assets/manifest.md` if it exists

If design bible is missing, stop:
> "No `design/design-bible.md` found. Asset specs without a bible drift from brand. Run `/design-bible` first."

---

## Phase 3: Inventory Assets

For `system:` / `screen:` modes, scan the source doc and identify every visual asset called out:
- Illustrations (empty states, onboarding visuals, hero images)
- Icons not from the system family (custom glyphs)
- Animations (Lottie / Rive / video)
- Photographs (if used)
- Decorative elements (patterns, textures)

For each, record: implied use, location in source doc.

For `app-icon` and `splash`, the asset list is fixed (one icon, one splash) but each has a per-platform size matrix.

---

## Phase 4: Author Per-Asset Specs

For each asset, write `design/assets/<asset-name>.md`:

```markdown
# Asset Spec: <Asset Name>

> **Status**: Spec
> **Used by**: <PRD or UX spec path + section>
> **Created**: <date>

## 1. Purpose
<one paragraph: what this asset communicates and where the user encounters it>

## 2. Style Anchor
<from design bible — illustration / photography / icon style>

## 3. Composition
<subject, framing, focal point, supporting elements>

## 4. Color Palette
- <token references from bible — never raw hex>
- <restricted palette if applicable>

## 5. Treatment
<flat / hand-drawn / isometric / 3D / photographic — match bible>

## 6. Size & Format
| Use | Size | DPR | Format | Notes |
|-----|------|-----|--------|-------|
| Default | <px @1x> | 1x, 2x, 3x | PNG / SVG / WebP | <note> |
| Dark mode variant | (same) | (same) | (same) | If different file |
| Animated variant | <px> | — | Lottie / Rive | (if applicable) |

For app icon, expand to full platform matrix:
- iOS: 1024×1024 master, plus all derived sizes the system generates
- Android: adaptive icon foreground (108×108dp safe zone 72dp), background, monochrome

## 7. AI-Generation Prompt

```
<one paragraph prompt seed using:
 - The bible's style anchor
 - The composition from Section 3
 - The color palette by name (and optionally hex)
 - "Mobile app illustration, target use: <use>, transparent background, vector-style ..."
>
```

Negative prompts (what to avoid):
- <list — typically: brand-conflicting motifs, photorealism if style is illustrative, etc.>

## 8. Acceptance Checks
- Matches bible style anchor (visual judgment)
- Color palette matches bible tokens (verifiable)
- All required sizes delivered (verifiable)
- Dark-mode variant delivered if applicable (verifiable)
- Accessibility: any text within the asset is at AA contrast (verifiable)

## 9. Delivery
- File naming: <kebab-case + size suffix, e.g., `empty-projects@2x.png`>
- Destination: `<asset-pipeline-path>` (per framework)
- For RN: `assets/images/<name>.png` + RN packager picks up @2x/@3x
- For Flutter: `assets/images/<name>/<density>x/`
- For iOS native: `Assets.xcassets/<name>.imageset/`
- For Android native: `app/src/main/res/drawable-<density>/`

## 10. Source Files
- Master: <path or "TBD">
- Editable source: <Figma / Illustrator / etc. — link>
```

Spawn `visual-design-director` (Task) for any large-style asset (illustrations, icons family) to refine the AI prompt and validate composition. The art director's draft becomes the prompt seed; the user reviews.

---

## Phase 5: Update Manifest

`design/assets/manifest.md`:

```markdown
# Asset Manifest

> Auto-updated by `/asset-spec`.

| Asset | Spec | Used by | Status | Last updated |
|-------|------|---------|--------|--------------|
| empty-projects | design/assets/empty-projects.md | design/ux/projects.md | Spec | <date> |
| app-icon | design/assets/app-icon.md | (global) | Spec | <date> |
| splash | design/assets/splash.md | (global) | Spec | <date> |
```

Status values: `Spec`, `In Production`, `Delivered`, `Approved`, `Deprecated`.

Append rows for each new spec written; update existing rows when a spec is re-run.

---

## Phase 6: Special Case — App Icon

App icon needs its own structure:

```markdown
# Asset Spec: App Icon

## Identity Direction
<from design bible Section 10 chosen direction>

## Master Size
1024×1024px PNG / SVG, full bleed (no rounded corners — OS applies them)

## iOS Size Matrix
| Slot | Size | Notes |
|------|------|-------|
| App Store | 1024×1024 | non-transparent, no alpha |
| iPad Pro | 167×167 | 83.5pt @2x |
| iPhone | 180×180 | 60pt @3x |
| iPad | 152×152 | 76pt @2x |
| Settings | 87×87 | 29pt @3x |
| Spotlight | 120×120 | 40pt @3x |
| Notification | 60×60 | 20pt @3x |

## Android Adaptive Icon
- Foreground: 108×108dp, safe zone 72dp centered
- Background: solid color or pattern, full 108×108dp
- Monochrome: required for Android 13+ themed icons
- Legacy round / square: also required for older Android

## AI-Gen Prompt
<one paragraph with the chosen identity direction>

## Acceptance Checks
- Recognizable at 60×60 (test by squinting at 60px render)
- Works on both light and dark wallpapers
- Theme-aware monochrome reads correctly
- No fine text that disappears at small sizes
```

---

## Phase 7: Special Case — Splash / Launch

```markdown
# Asset Spec: Splash / Launch Screen

## iOS Launch Screen
- iOS 14+ uses storyboards; iOS 13- uses static images
- Background: <bible color token>
- Foreground: app logo at center, fixed size <e.g., 120pt>
- No animations beyond OS-controlled fade
- Dark mode: separate storyboard or asset

## Android Launch / Splash API
- Pre-Android 12: single launch theme color
- Android 12+ Splash Screen API:
  - Window background: <bible token>
  - Splash icon: 432×432dp foreground (288dp safe zone)
  - Branding image: optional bottom logo
- Animated icon: optional (Vector Drawable)
- Dark mode: defined in `values-night/`
```

---

## Phase 8: Hand Off

Print:
> "<N> asset specs written. Hand to designer (or your AI gen tool) for production. Update manifest status as each is delivered."

Use `AskUserQuestion`:
- **Options**:
  - `Run /asset-audit (in second skill set) to check delivery later`
  - `Spec the next batch — run /asset-spec system:<system>`
  - `Stop here`

---

## Quality Gates

- Every spec references at least one design-bible token by name
- Every spec has Section 6 size matrix filled
- App icon spec has full iOS + Android matrix
- Splash spec covers both pre-Android-12 and Android-12+ behavior
- AI-gen prompt is non-empty and references the bible style anchor
- Manifest updated with one row per new spec

---

## Examples

`/asset-spec system:onboarding`
- Inventories assets called for in `design/prd/onboarding.md`: 5 illustrations, 2 hero images
- Writes 7 spec files, updates manifest with 7 rows
- Each illustration spec has AI prompt anchored in bible style

`/asset-spec app-icon`
- Reads bible Section 10 chosen direction
- Writes `design/assets/app-icon.md` with full iOS + Android matrix and AI-gen prompt
