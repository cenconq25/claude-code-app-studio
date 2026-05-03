<!--
name: release-notes
purpose: Two-form release notes for a single version — internal (full detail for the team and support) and user-facing (concise, friendly, shippable to App Store / Play Store "What's New").
consumed-by: /release-checklist, /changelog, /patch-notes
placeholders:
  - {{version}}
  - {{build_number}}
  - {{release_date}}
  - {{previous_version}}
-->

# Release Notes — v{{version}} ({{build_number}})

| Field | Value |
|-------|-------|
| Released | {{release_date}} |
| Builds from | {{previous_version}} |
| Rollout | TestFlight / Play Internal / Phased / Full |

---

## Internal Notes

For the team, support, and on-call. Full detail. Lives in repo.

### What changed

#### Added

- {{feature}} — owner: {{name}} — story: STORY-NN

#### Changed

- {{change}} — owner: {{name}}

#### Fixed

- {{bug}} — issue: ISSUE-NN — root cause: {{summary}}

#### Security

- {{security_fix}} — CVE / advisory if public

#### Deprecated

- {{thing}} — removal target: v{{n}}

#### Removed

- {{thing}}

### Migration / Compatibility

- Minimum iOS version: {{min_ios}} (changed from {{previous}}? Y/N)
- Minimum Android API: {{min_android}} (changed from {{previous}}? Y/N)
- Backend API version required: {{api_version}}
- Database / persisted-state migrations: {{description}}
- Forced upgrade required for users on {{older_versions}}? Y/N
- Push notification format changes: {{description}}

### Known Issues Shipping in This Build

| Issue | Workaround | Tracked |
|-------|------------|---------|
| | | ISSUE-NN |

### Support Talking Points

For the support team, written in plain language without internal jargon.

- New: {{feature}} — where to find it, what it does
- Changed: {{change}} — what users will notice
- Fixed: {{bug_class}} — common past complaints this resolves

### Rollout Strategy

{{description}}

### Halt Criteria

If any of the following occurs in the first 24 hours:

- Crash-free session rate drops below {{threshold}}
- ANR rate above {{threshold}} on Android
- Key funnel drop > {{percent}}%

→ Halt the rollout. On-call commander: {{name}}.

---

## User-Facing Notes

For App Store / Play Store "What's New". Friendly, concrete, no jargon. Below
each platform's character limit. Localize before shipping.

### App Store (max 4000 chars; first 30 chars visible above fold)

```
{{app_store_text}}
```

Example shape:

```
What's new in {{version}}

{{headline_feature}} — {{one_sentence_benefit}}.

Also in this update:
• {{improvement}}
• {{improvement}}
• {{bug_fix_in_user_words}}

Thanks for using {{app_name}}! Tap → Settings → Send Feedback to tell us what
you'd like next.
```

### Google Play (max 500 chars)

```
{{play_text}}
```

### In-App Update Card (optional)

If the app shows a "what's new" sheet on first launch after update:

```
{{in_app_text}}
```

### Social / Marketing Snippet

One sentence safe to copy-paste into Twitter/X, Mastodon, or a launch email.

> {{social_blurb}}
