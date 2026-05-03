---
name: content-audit
description: "Audits PRD-specified content counts (screens, copy strings, images, supported locales, push categories, onboarding steps) against what is actually implemented. Identifies what is planned vs. what is built. Read-only."
argument-hint: "[no arguments | --strict]"
user-invocable: true
allowed-tools: Read, Glob, Grep
model: sonnet
---

# Content Audit

A PRD says "5 onboarding screens"; the codebase has 3. A PRD says "supported locales: en, es, ja"; the i18n bundle has only `en.json`. This skill quantifies that gap.

Read-only. Produces a printed report.

---

## Purpose / When to Run

Run when:
- Pre-release — confirm content matches plan before submitting to stores
- Mid-sprint — confirm a content-heavy feature is on track
- After a copy push — confirm strings landed
- The user types "content audit" or wants a quick "is the content done" check

Distinct from `/asset-audit` (in the second skill set, which checks assets specifically) — this skill checks **counts and presence**, not asset compliance.

## Inputs

- All `design/prd/*.md`
- Source code:
  - `src/` for RN/JS/TS
  - `lib/` for Flutter
  - `ios/` and Xcode project for iOS native
  - `app/src/main/` for Android native
- Localization bundles
- Asset directories (`assets/`, `Assets.xcassets`, `app/src/main/res/`)

## Outputs

- A printed report. No file writes.

---

## Phase 1: Inventory Planned Counts

Read every PRD. From each, extract count claims. Common patterns to grep:
- "<N> screens"
- "<N> onboarding steps"
- "supported locales: <list>"
- "push categories: <list>"
- "<N> illustrations"
- "<N> default templates"
- "feature flags: <list>"
- "tabs: <list>"

Build a planned-content table:

```
| Source PRD | Item | Planned count |
|------------|------|----------------|
| onboarding.md | screens | 5 |
| onboarding.md | locales | en, es, ja |
| paywall.md | tiers | 3 (monthly, annual, lifetime) |
| home.md | tabs | 4 |
| ... | ... | ... |
```

If a PRD makes vague claims ("a few", "several"), warn but do not error. List them as `unknown` and recommend tightening the PRD.

---

## Phase 2: Inventory Implemented Counts

Use globs and greps appropriate to the framework. The skill must be framework-aware — read `.claude/docs/technical-preferences.md` first.

### React Native / Expo

- Screens: glob `src/screens/**/*.{tsx,jsx}` or routes in `app/` (Expo Router)
- Onboarding screens: count screens under `src/screens/onboarding/` or matching pattern
- Locales: list files under `src/locales/`, `src/i18n/`, or `assets/locales/`
- Asset images: count under `assets/images/` and `src/assets/`
- Components: count under `src/components/`

### Flutter

- Screens: count `lib/features/**/screens/*.dart` or `lib/screens/`
- Locales: list under `lib/l10n/` or `assets/translations/`
- Assets: list under `assets/images/`, `assets/icons/`

### iOS native

- Screens: count `*View.swift` or `*ViewController.swift` files
- Locales: count `*.lproj` directories under `Resources/`
- Asset catalogs: count entries in `Assets.xcassets`

### Android native

- Screens: count `*Activity.kt`, `*Fragment.kt`, or Compose screens (`@Composable fun ...Screen()`)
- Locales: count `values-*` directories under `app/src/main/res/`
- Drawables: count under `res/drawable-*/`

For each PRD claim, find the corresponding implemented count.

---

## Phase 3: Compare and Classify

For each row:

- **MATCH** — planned count = implemented count (or planned ≤ implemented for "at least N" cases)
- **UNDER** — implemented count < planned count
- **OVER** — implemented count > planned count (often fine, but flag — may be unplanned scope)
- **UNKNOWN** — cannot determine implemented count (e.g., copy strings without a strings file)
- **PLAN MISSING** — implementation exists but no PRD claims it (potential undocumented feature)

Severity:
- **HIGH** — UNDER on a v1-critical item (locales, payment tiers, onboarding screens, account-deletion flow)
- **MEDIUM** — UNDER on a v1-deferrable item, OVER on anything
- **LOW** — UNKNOWN
- **INFO** — PLAN MISSING

---

## Phase 4: Report

```
# Content Audit

PRDs scanned: <N>
Items audited: <N>
Findings: <count by severity>

## HIGH
1. **Locales** — onboarding.md plans `en, es, ja`. Implementation has `en` only.
   Files: src/locales/en.json
   Action: source translations for `es` and `ja`, or update PRD to reflect ship-with-en-only.

2. **Onboarding screens** — onboarding.md plans 5 screens. Implementation has 3 (Welcome, Permissions, Profile).
   Action: implement Goals and FirstAction screens, or update PRD.

## MEDIUM
- Paywall tiers — paywall.md plans 3 (monthly, annual, lifetime). Implementation has 2 (monthly, annual). Consider whether lifetime is in v1 or v1.1.

## LOW (UNKNOWN)
- Copy strings — onboarding.md says "approximately 40 strings". No strings file found, only inline literals. Recommend extracting to enable localization.

## INFO (PLAN MISSING)
- Implemented but unmentioned: 2 screens under src/screens/debug/. Likely dev-only — confirm and document or remove from production builds.

## Summary
- Plan match rate: <N>%
- Under-implemented items: <count>
- Over-implemented items: <count>
- Unverified items: <count>
```

---

## Phase 5: Strict Mode

If `--strict` was passed, additionally flag:
- Inline string literals (no localization) — every screen using literal English strings instead of translation keys
- Missing accessibility labels on images (in framework-appropriate way: `accessibilityLabel`, `Semantics(label:)`, `contentDescription`)
- Missing dark-mode variants (color resources without dark-mode override)

These run as additional MEDIUM findings.

---

## Phase 6: Recommendations

```
## Recommended actions

For each HIGH:
- If the count gap is intentional: update the PRD to reflect reality (`/design-system retrofit ...`).
- If the gap is unintentional: implement the missing items.

For OVER items:
- Decide whether to deprecate the extras, or update the PRD to claim them.

For PLAN MISSING:
- Document via `/reverse-document --prd <area>` or remove from production builds.
```

---

## Edge Cases

- **No PRDs**: stop. There is nothing to audit. Recommend `/design-system` to author the first PRD.
- **Implementation does not match the framework declared in technical-preferences**: warn loudly. Either the framework pin is wrong or there is hybrid code.
- **Counts are subjective** (e.g., "a few"): list as UNKNOWN, do not guess.

---

## Quality Gates

- Every HIGH finding includes the source PRD path and the implementation path that was inspected.
- Counts in the report are reproducible — running the skill twice on the same project produces the same numbers.
- The skill never edits any file.

---

## Examples

`/content-audit`
- Plan: 5 onboarding screens, 3 locales (en/es/ja), 2 paywall tiers
- Impl: 3 onboarding screens, 1 locale (en), 2 paywall tiers
- Findings: 2 HIGH (locales, onboarding screens), 0 MEDIUM
- Verdict: Major content gap — pre-release blocker.

`/content-audit --strict`
- Adds: 17 screens use inline string literals instead of translation keys
- 4 images missing accessibility labels
- Verdict: HIGH localization risk; remediation needed before international launch.
