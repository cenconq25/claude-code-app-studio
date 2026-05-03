---
name: asset-audit
description: "Audits app assets for naming conventions, file size budgets, format standards, app icon completeness, splash screens, and store-listing imagery. Identifies orphans (asset on disk but never referenced) and missing references (referenced but missing)."
argument-hint: "[--scope=app|store|icons|all]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---

# Asset Audit

Find every asset that violates naming, size, or format rules; flag
orphans and missing references; and confirm the store-listing pack is
complete and correctly sized for both App Store and Play Console.

---

## Phase 1: Read Standards

Read `.claude/docs/technical-preferences.md` and any
`assets/asset-standards.md`. Capture:

- Image formats allowed (default: PNG, WebP, SVG; JPG only for photos).
- Max bytes per category (icons, screen backgrounds, illustrations,
  store screenshots).
- Naming convention (kebab-case, snake_case, scoped by feature).
- Density / scale variants required.
- Vector vs raster policy.

Defaults if unconfigured:

- Raster max 200 KB; over 200 KB requires explanation.
- Naming: snake_case scoped by feature: `paywall_hero_dark@2x.png`.
- iOS: provide @1x, @2x, @3x.
- Android: provide hdpi, xhdpi, xxhdpi, xxxhdpi (or vector + density-
  specific only when needed).

---

## Phase 2: Inventory Assets on Disk

Glob asset roots:

- `assets/`, `src/assets/` — cross-platform.
- iOS: `*.xcassets/` Contents.json + image bundles.
- Android: `res/drawable*`, `res/mipmap*`.
- Flutter: paths declared in `pubspec.yaml` `flutter.assets`.

Capture per file: path, size, format, last-modified date, density (if
applicable).

---

## Phase 3: Inventory References in Code

Grep for asset references:

- RN: `require('./icon.png')`, `import icon from './icon.png'`,
  `Image source={{ uri }}`.
- Flutter: `AssetImage('...')`, `Image.asset('...')`,
  `SvgPicture.asset('...')`.
- iOS: `UIImage(named:)`, SwiftUI `Image("name")`.
- Android: `R.drawable.*`, `painterResource(R.drawable.*)`,
  Glide/Coil/Picasso load calls.

Map each reference to a path on disk.

---

## Phase 4: Find Orphans and Missing

- **Orphans** — files on disk with no reference in code or
  configuration (icons declared in xcassets and Info.plist count as
  references). Candidates for deletion.
- **Missing** — references in code that resolve to no file on disk.
  Build will break or runtime will crash.

Render two tables.

---

## Phase 5: Naming and Format Check

For each in-use asset:

- [ ] Name matches the configured convention.
- [ ] Format is allowed for the category.
- [ ] Size is within budget (or has an explanation note).
- [ ] Density variants are complete (no missing @2x or xxxhdpi).
- [ ] No transparent JPGs, no animated PNGs unless explicit.
- [ ] SVGs are sanitised (no embedded scripts) — grep `<script>` and
      `onload=` in `.svg` files.

Flag each violation with severity (low / medium / high).

---

## Phase 6: App Icon and Splash

iOS App Icons: read `Assets.xcassets/AppIcon.appiconset/Contents.json`.
Confirm every required slot is filled:

- iPhone 60pt @2x, @3x.
- iPad 76pt @1x, @2x; 83.5pt @2x.
- App Store 1024px @1x.
- Notification, Settings, Spotlight variants.

Android adaptive icon: confirm `mipmap-anydpi-v26/ic_launcher.xml`
references `foreground` and `background` layers, and that monochrome
layer (Android 13+) is present.

Splash / launch screen:

- iOS: confirm `LaunchScreen.storyboard` or SwiftUI launch UI is
  configured; not deprecated launch images.
- Android: confirm `SplashScreen` API usage on Android 12+.
- React Native: `react-native-bootsplash` config present; assets
  match.
- Flutter: `flutter_native_splash` config present; assets match.

---

## Phase 7: Store Listing Pack

For `--scope=store|all`, audit the store imagery bundle. Read
`production/store/[platform]/` if it exists.

App Store Connect requirements:

- Screenshots: 6.7" iPhone (3-10), 6.5" iPhone, 5.5" iPhone, 12.9" iPad
  (if iPad), Apple Watch (if watch app). PNG/JPG, sRGB.
- App Preview videos: optional, per device size.
- App icon (already covered in Phase 6).
- Promotional text, description, keywords (text, not assets, but flag
  presence).

Play Console requirements:

- Phone screenshots (2-8), 7" tablet, 10" tablet (if tablet support).
- Feature graphic 1024x500 PNG/JPG.
- App icon 512x512 PNG.
- Promo video (optional, YouTube link).

For each requirement, confirm presence and resolution. Flag missing
slots.

---

## Phase 8: Render Report

```markdown
# Asset Audit — [date]

## Inventory
- On disk: [N] files / [size sum]
- Referenced: [N]
- Orphans: [N]
- Missing: [N]

## Naming and Format Issues
| File | Issue | Severity |

## Size Budget Breaches
| File | Size | Budget | Over by |

## App Icon
- iOS: [PASS / missing slots: ...]
- Android: [PASS / missing layers: ...]

## Splash / Launch
- iOS: [PASS / FAIL]
- Android: [PASS / FAIL]

## Store Pack (if --scope includes store)
### App Store
- 6.7" screenshots: [N/3-10]
- 6.5" screenshots: [N/3-10]
- App icon 1024: [present | MISSING]

### Play Console
- Phone screenshots: [N/2-8]
- Feature graphic: [present | MISSING]
- App icon 512: [present | MISSING]

## Verdict: CLEAN / NEEDS WORK / BLOCKING (release-blocking gaps)
```

Ask before writing to `production/assets/asset-audit-[date].md`.

---

## Phase 9: Cleanup Plan

For each Orphan: ask "Delete now?" via AskUserQuestion. Batch similar
deletions.

For each Missing: ask "Open a story to source the asset?" If yes,
create a story spec for `/create-stories`.

For Size Budget Breaches: propose either a re-export at proper format
(SVG vs PNG, WebP vs PNG) or a story to redo the asset.

---

## Phase 10: Update State

Append to `production/session-state/active.md`:

```
## Asset Audit — [date]
- Orphans: [count] — [N deleted | tracked]
- Missing: [count] — [N stories opened]
- Size breaches: [count]
- Store pack: [status]
- Report: [path]
- Next: [/create-stories for missing, or /release-checklist if CLEAN]
```

---

## Quality Gates / PASS-FAIL

- CLEAN — zero missing references, zero size-budget breaches, complete
  app icon and splash, store pack complete for every targeted store.
- NEEDS WORK — orphans or low-severity issues remain but no blockers.
- BLOCKING — missing reference (build break) or missing required store
  imagery for a launch target.

---

## Examples

**Example 1 — Pre-release scope=all:**
Finds 12 orphans (old paywall variant assets), 2 missing references
(broken `require('./old-cta.png')`), 1 size breach (1.2 MB hero
illustration), Play Store feature graphic missing. Verdict: BLOCKING.

**Example 2 — Quarterly scope=app:**
Inventory only. Surfaces 8 orphans from a deleted onboarding flow.
User approves bulk delete. Verdict: CLEAN.

---

## Next Steps

- BLOCKING -> open stories, sourcing missing assets through design team.
- NEEDS WORK -> defer to next sprint via `/sprint-plan`.
- CLEAN -> include verdict in `/release-checklist`.
