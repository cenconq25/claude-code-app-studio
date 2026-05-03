<!--
name: store-listing
purpose: App Store and Google Play listing copy and asset checklist for a release. One file per locale or per release, depending on team preference. Includes character-budget annotations and localization slots.
consumed-by: /release-checklist, /launch-checklist, /localize
placeholders:
  - {{app_name}}
  - {{version}}
  - {{author}}
  - {{date}}
  - {{primary_locale}}
-->

# Store Listing — {{app_name}} v{{version}}

| Field | Value |
|-------|-------|
| Author | {{author}} |
| Date | {{date}} |
| Primary locale | {{primary_locale}} |
| Localized for | {{locale_list}} |
| Status | Draft / In Review / Approved / Submitted |

## App Store Connect (iOS)

### Identity

| Field | Limit | Value |
|-------|-------|-------|
| App name | 30 chars | {{name}} |
| Subtitle | 30 chars | {{subtitle}} |
| Bundle ID | n/a | {{bundle_id}} |
| Primary category | 1 selection | |
| Secondary category | optional | |
| Age rating | from questionnaire | |

### Promotional text (170 chars, editable without re-review)

```
{{promo_text}}
```

### Description (4000 chars)

```
{{description_paragraph_1}}

{{description_paragraph_2}}

What's included:
• {{bullet}}
• {{bullet}}
• {{bullet}}

{{closing_paragraph}}
```

### Keywords (100 chars total, comma-separated, no spaces between)

```
{{keyword},{{keyword}},{{keyword}}
```

### What's New (4000 chars; first ~30 visible above fold)

```
{{whats_new}}
```

### Screenshots required

| Device family | Size | Required? | Status |
|---------------|------|-----------|--------|
| iPhone 6.9" (15 Pro Max class) | 1290×2796 | yes | |
| iPhone 6.7" | 1290×2796 / 1242×2688 | yes | |
| iPhone 6.5" | 1242×2688 | optional | |
| iPhone 5.5" | 1242×2208 | only if supporting older devices | |
| iPad 13" (M-class iPad Pro) | 2064×2752 | required if iPad-supported | |
| iPad 12.9" | 2048×2732 | required if iPad-supported | |

Each device size: minimum 2, maximum 10 screenshots.

### App Preview video (optional)

- 30 seconds max
- Captured on the actual device class (no upscale)
- 1080p minimum
- No external footage; in-app gameplay/UX only
- Localized version per locale where possible

### Privacy

- Privacy policy URL: {{url}}
- Privacy nutrition labels: filled in App Store Connect → matches `privacy/data-collected.md`

## Google Play Console (Android)

### Identity

| Field | Limit | Value |
|-------|-------|-------|
| App name | 30 chars | {{name}} |
| Short description | 80 chars | {{short_desc}} |
| Long description | 4000 chars | (see below) |
| Application ID | n/a | {{application_id}} |
| Category | 1 selection | |
| Tags | up to 5 | |
| Content rating | from IARC questionnaire | |

### Long description

```
{{long_description}}
```

### Release notes (per locale, 500 chars)

```
{{release_notes}}
```

### Graphics

| Asset | Size | Required? | Status |
|-------|------|-----------|--------|
| App icon | 512×512 PNG | yes | |
| Feature graphic | 1024×500 PNG / JPG | yes | |
| Phone screenshots | min 1080px short side, ≥2 ≤8 | yes | |
| 7" tablet screenshots | min 1080px short side | required if tablet-supported | |
| 10" tablet screenshots | min 1080px short side | required if tablet-supported | |
| Promo video | YouTube URL | optional | |

### Data Safety form

- All data types matched to actual SDK behaviour: {{date}}, verified by {{name}}
- Encryption in transit: yes
- Account deletion path declared: in-app at {{path}}

## Localization

### Locale slots

For each locale, provide a separate section. List the high-effort locales here.

| Locale | Status | Translator | Reviewed |
|--------|--------|------------|----------|
| en-US | source | — | — |
| es-MX | | | |
| pt-BR | | | |
| de-DE | | | |
| fr-FR | | | |
| ja-JP | | | |
| ko-KR | | | |
| zh-Hans | | | |
| ar-SA | | | RTL spot-check |

### Per-locale overrides

Some text must differ from a literal translation (cultural references,
keyword strategy, character limits). Note exceptions here.

| Locale | Field | Override | Reason |
|--------|-------|----------|--------|
| | | | |

## Compliance Quick-check

- [ ] Health / financial / dating / gambling / ATT / kids categorisation correct
- [ ] No use of "free" if subscription
- [ ] No mention of competitors by name
- [ ] No Apple / Google trademarks misused
- [ ] No screenshots of unimplemented features ("coming soon")

## Sign-off

| Role | Name | Approved |
|------|------|----------|
| Product | | |
| Marketing | | |
| Legal (privacy / terms changes) | | |
