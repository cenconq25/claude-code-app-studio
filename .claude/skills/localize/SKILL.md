---
name: localize
description: "Full localization pipeline: scan for hardcoded strings, extract to string tables, validate translations, RTL test, locale QA, voiceover/audio localization, string freeze enforcement, and coverage reporting."
argument-hint: "[--scan | --extract | --validate | --freeze | --report]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---

# Localize

Localization is treated as a recurring pipeline, not a one-time chore.
This skill has five modes, each runnable independently. Together they
take an app from "English-only with hardcoded strings" through to "fully
translated, frozen for release, and verified on device".

---

## Phase 1: Pick the Mode

Parse the argument:

- `--scan` (default if omitted) — find hardcoded user-facing strings.
- `--extract` — move identified strings into the string table.
- `--validate` — verify completeness and quality of existing
  translations.
- `--freeze` — enforce the string-freeze policy ahead of release.
- `--report` — generate a coverage report.

Read project context:

- `.claude/docs/technical-preferences.md` — framework, target locales.
- Existing string tables — locations vary by stack:
  - RN: `src/locales/[lang].json` (typical for `i18next`,
    `react-intl`, `expo-localization`).
  - Flutter: `lib/l10n/intl_[lang].arb`, `app_localizations.dart`.
  - iOS native: `*.lproj/Localizable.strings`,
    `Localizable.stringsdict`.
  - Android native: `res/values-[lang]/strings.xml`.

If target locales are unset, prompt the user: which markets is the app
launching in?

---

## Phase 2: Scan Mode

Find every user-facing string that is not pulled from the table.

Per stack, the grep patterns are different:

- RN (i18next): match `>{[^{]*[A-Za-z][^}]*}<` outside `t()` calls.
  Also match raw string literals passed as `<Text>` children.
- Flutter: match `Text('...')` and `Text("...")` outside of test files.
- iOS Swift: match `Text("...")`, `Label("...")`, plain string literals
  passed to `setTitle`, `setText`. Cross-reference with `NSLocalizedString`.
- Android Kotlin: match `Text("...")` (Compose), `setText("...")`,
  hardcoded strings in `findViewById`. Cross-reference
  `getString(R.string.*)` calls.

Filter false positives:

- Logging calls (`console.log`, `print`, `os_log`, `Log.d`).
- Test files (`tests/`, `__tests__`, `_test.dart`, `*Tests.swift`).
- Constants for keys, identifiers, URLs, deep-link routes.
- Developer-facing diagnostic messages.

Render a table:

| File | Line | String | Suggested key |
|------|------|--------|---------------|

Include a confidence rating per row (high / medium / low). Confidence
high = clearly user-facing; low = ambiguous (developer message,
analytics label).

---

## Phase 3: Extract Mode

For each high-confidence row, propose the migration. Use AskUserQuestion
to batch decisions per cluster (auth strings, paywall strings, etc.).

Migration steps per stack:

- RN: add `"key.path": "Source string"` to `src/locales/en.json`,
  replace inline literal with `t('key.path')`.
- Flutter: add to `lib/l10n/intl_en.arb`, replace with
  `AppLocalizations.of(context)!.keyPath` (regenerate via
  `flutter gen-l10n`).
- iOS: add to `Localizable.strings`, replace literal with
  `NSLocalizedString("key.path", comment: "")` or SwiftUI
  `Text("key.path", bundle: .main)`.
- Android: add to `res/values/strings.xml`, replace literal with
  `getString(R.string.key_path)` or `stringResource(R.string.key_path)`.

Naming convention for keys:

- snake_case or dot.case grouped by feature: `paywall.cta.subscribe`,
  `auth.error.invalid_email`.
- Stable across translations — never include words from translated
  text in the key.

Always ask before writing. After extraction, run the framework's
generator (`flutter gen-l10n`, RN i18n compile, etc.) to ensure no
build break.

---

## Phase 4: Validate Mode

For the configured target locales, audit each translation file:

- [ ] Every key in the source locale exists in the target locale.
- [ ] No empty values.
- [ ] No untranslated values that match the source verbatim (unless
      the string is a brand name — maintain an allowlist at
      `assets/locale-allowlist.txt`).
- [ ] Placeholder counts and names match the source ({0}, {name},
      ICU plural forms).
- [ ] Plural / gender rules complete for languages that need them
      (Russian, Polish, Arabic).
- [ ] No HTML tags in plaintext strings.
- [ ] No leading/trailing whitespace inconsistencies.
- [ ] Length sanity — strings in target should be no more than 2.5x the
      source length (UI overflow risk).

For each problem, render:

| Locale | Key | Issue | Severity |
|--------|-----|-------|----------|

---

## Phase 5: RTL Audit (when targeting Arabic, Hebrew, Persian, Urdu)

If any RTL locale is in scope, walk through:

- [ ] Layout uses logical edge attributes (`Start`/`End`, leading/
      trailing) rather than `Left`/`Right`.
- [ ] Icons that should mirror (back arrows, navigation indicators)
      are configured to mirror via `autoMirror` (Compose),
      `flipsForRightToLeftLayoutDirection` (UIKit),
      `Directionality` (Flutter), `I18nManager.isRTL`-aware (RN).
- [ ] Numbers in non-Arabic RTL locales are still LTR-rendered when
      design requires.
- [ ] Date/time formatters use locale-correct output.

Provide a checklist for the tester to run on a device with system
language switched to Arabic.

---

## Phase 6: Voiceover and Audio Localization

If the app uses recorded audio (onboarding voiceover, character lines,
push notification audio):

- [ ] Audio files are organized per locale: `assets/audio/[lang]/...`.
- [ ] Default fallback locale is configured.
- [ ] Speech-rate / Voice-Over (iOS) and TalkBack (Android) labels are
      localized — accessibility labels follow the same pipeline as
      visible text.

Render a per-locale audio inventory and flag missing tracks.

---

## Phase 7: String Freeze Mode

When invoked with `--freeze`:

1. Snapshot the current `en` string table to
   `assets/locales/_freeze-[date].json`.
2. Add a CI check that fails if any new key is added or any source
   value is changed without a `freeze-override` annotation.
3. Notify the user: "String freeze active. New strings require
   localization-lead approval and a freeze-override flag."

This protects against last-minute changes that translators cannot
cover.

---

## Phase 8: Report Mode

Render coverage:

```markdown
# Localization Report — [date]

## Source
- Source locale: en — [count] keys

## Coverage
| Locale | Translated | Empty | Source-equivalent | Coverage % |
|--------|------------|-------|-------------------|------------|
| es | 412 | 0 | 3 (allowlisted) | 100% |
| fr | 410 | 2 | 0 | 99.5% |
| ar | 380 | 32 | 0 | 92% |

## Issues
- [locale]: [count] severity-high issues
- [locale]: [count] severity-medium issues

## Hardcoded String Status
- High-confidence remaining: [count] (paths)
- Low-confidence (probable false positives): [count]

## RTL Audit
- [PASS / FAIL with notes]

## String Freeze
- [Active since [date] / Not active]

## Recommendation
[release / hold / partial release on covered locales]
```

Ask before writing to `production/localization/loc-report-[date].md`.

---

## Phase 9: Update State

Append to `production/session-state/active.md`:

```
## Localize — [date] — mode=[mode]
- Hardcoded strings remaining: [count]
- Locales: [N covered]/[N target]
- Freeze: [status]
- Report: [path or N/A]
- Next: [extract | translate | validate | freeze | release]
```

---

## Quality Gates / PASS-FAIL

- PASS — every target locale at 100% coverage; no source-equivalent
  values outside allowlist; no high-confidence hardcoded strings; RTL
  audit passes if RTL locales are in scope; freeze is active before
  release.
- FAIL — any of the above is unmet for a locale on the launch list.

---

## Examples

**Example 1 — RN app entering Spanish + French:**
Scan finds 47 hardcoded strings, all extracted to `en.json`, `es.json`,
`fr.json`. Translators deliver `es.json` and `fr.json`. Validate
passes. Coverage 100% for both.

**Example 2 — Pre-release freeze:**
`/localize --freeze` snapshots en.json (412 keys), CI guardrail added.
Two days later a designer adds a new key without override; CI blocks
the PR.

---

## Next Steps

- Translators behind -> escalate to localization-lead, possibly defer
  the locale from launch.
- Extract done -> hand the new key list to translation vendor.
- Freeze active -> any string change must go through `/architecture-decision`-style approval log.
