<!--
name: release-checklist-template
purpose: The pre-flight checklist a build must pass before submission to the App Store and Google Play. Run before every external release (beta, store submission, GA).
consumed-by: /release-checklist, /launch-checklist, /team-release, /gate-check
placeholders:
  - {{version}}
  - {{build_number}}
  - {{release_manager}}
  - {{target_release_date}}
  - {{rollout_strategy}}
-->

# Release Checklist — v{{version}} ({{build_number}})

| Field | Value |
|-------|-------|
| Release manager | {{release_manager}} |
| Target submission date | {{target_release_date}} |
| Rollout | TestFlight / Play Internal / Phased {{percent}}% / Full |
| Previous version in production | {{prev_version}} |

## Build & Signing

### iOS

- [ ] Xcode version: {{xcode_version}}
- [ ] iOS deployment target unchanged from previous release (or change documented)
- [ ] Build configuration: Release
- [ ] Bitcode setting matches App Store Connect requirement
- [ ] Provisioning profile: App Store distribution, valid >30 days
- [ ] Distribution certificate valid >60 days
- [ ] Push notification certificate valid (or APNs auth key in use)
- [ ] dSYM uploaded to crash reporter (Crashlytics / Sentry)
- [ ] Build uploaded to App Store Connect; processing complete
- [ ] TestFlight build smoke-tested on real device

### Android

- [ ] AGP version: {{agp_version}} / Gradle: {{gradle_version}}
- [ ] minSdk / targetSdk policy compliant for current Play deadline
- [ ] Bundle (.aab) built with R8/Proguard
- [ ] Signing key: Play App Signing enrolled, upload key valid
- [ ] Mapping file uploaded for crash deobfuscation
- [ ] Bundle uploaded to Play Console; pre-launch report green
- [ ] Internal testing track installable on real device

## Versioning

- [ ] Marketing version bumped: `{{prev_version}}` → `{{version}}`
- [ ] iOS `CFBundleVersion` strictly greater than last submission
- [ ] Android `versionCode` strictly greater than last submission
- [ ] Tag created in git: `v{{version}}`
- [ ] Release branch: `release/{{version}}`

## Store Metadata

### App Store Connect

- [ ] What's New text written (≤ 4000 chars, ≤ 30 visible above fold)
- [ ] Screenshots uploaded for required device sizes (6.9", 6.7", 5.5", 12.9" iPad as applicable)
- [ ] App preview video (optional) within 30s, 1080p
- [ ] Localized metadata for each shipping locale
- [ ] Promotional text refreshed (170 chars)
- [ ] Keywords reviewed
- [ ] Age rating questionnaire current
- [ ] Export compliance flags (encryption) set

### Google Play Console

- [ ] Release notes per locale (≤ 500 chars)
- [ ] Phone screenshots (≥ 2, max 8) for primary locales
- [ ] Tablet screenshots (7" + 10") if tablet support declared
- [ ] Feature graphic 1024×500
- [ ] Localized listing for each shipping locale
- [ ] Content rating refreshed if features changed
- [ ] Target audience and content settings reviewed

## Privacy & Compliance

- [ ] iOS Privacy Nutrition Label: every data type collected matches actual code (verified by privacy-engineer)
- [ ] Play Data Safety form: every data type collected, purpose, sharing, encryption-in-transit confirmed
- [ ] ATT prompt copy reviewed and approved
- [ ] GDPR consent mechanism unchanged or change reviewed by legal
- [ ] COPPA compliance if app may be used by under-13
- [ ] EU DMA: alternative billing / sideloading copy correct (where applicable)
- [ ] Account deletion path discoverable per Play / App Store policy
- [ ] Privacy policy URL valid and reachable
- [ ] Terms of service URL valid

## Quality Gates

- [ ] Smoke check passes on iOS + Android
- [ ] Crash-free session rate ≥ {{cfsr_threshold}} on previous build over last 7 days
- [ ] No P0 / P1 bugs open
- [ ] All P0 stories in this release have test evidence
- [ ] Performance budgets met: cold start ≤ {{cold_start_ms}}ms p95, frame rate ≥ {{fps}} on minimum device
- [ ] Accessibility audit: VoiceOver and TalkBack flows verified
- [ ] Localization smoke: each shipping locale launches without crash, no overflowing strings spot-check

## Telemetry

- [ ] Analytics SDK initialised post-consent
- [ ] New event taxonomy documented in `design/analytics/`
- [ ] Crash reporter capturing this build
- [ ] Performance traces (cold start, key flows) emitting

## Rollout & Rollback

- [ ] Rollout strategy: {{rollout_strategy}}
- [ ] Phased release initial percentage: {{initial_pct}}%
- [ ] Halt criteria documented (CFSR drop, ANR rate, key funnel drop)
- [ ] Rollback plan documented (Play: halt rollout; App Store: expedited submission of previous + flag change)
- [ ] Server-side feature flags for new features ready to disable
- [ ] On-call schedule confirmed for first 72 hours post-release

## Sign-offs

| Role | Name | Date | Approved |
|------|------|------|----------|
| Release manager | | | |
| QA lead | | | |
| Tech lead | | | |
| Product | | | |
| Privacy / legal (if metadata changed) | | | |

## Submitted

- [ ] iOS submitted at {{datetime}} — Apple review status: {{status}}
- [ ] Android submitted at {{datetime}} — review status: {{status}}
