---
name: release-checklist
description: "Pre-release validation: build verification, certification (App Store / Play Console), store metadata, screenshots, privacy nutrition labels, Play Data Safety, version numbering. Narrower than /launch-checklist — focused on the build and store submission."
argument-hint: "[--platform=ios|android|both]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash, AskUserQuestion
model: sonnet
---

# Release Checklist

The build-and-submit gate. Confirms the candidate build is signed,
versioned, certified, and ready for store review. This is the technical
twin of `/launch-checklist`.

---

## Phase 1: Read Project Context

Read in parallel:

- `CLAUDE.md` — project name, version baseline.
- `.claude/docs/technical-preferences.md` — framework, target
  platforms.
- Current milestone in `production/milestones/`.
- Any prior release log in `production/releases/`.

Capture target version from the user. Default convention: `MAJOR.MINOR.PATCH`
plus a build number that increments per submission.

---

## Phase 2: Code Health Sweep

Run quick scans via Bash:

- TODO / FIXME / HACK counts:
  `rg -c '\b(TODO|FIXME|HACK)\b' --no-heading | sort`
- Skipped tests: grep for `xtest`, `xit`, `test.skip`, `it.skip`,
  `@Disabled`, `@Ignore`.
- Unused dependencies (best-effort per stack):
  `npx depcheck` for RN/JS.
  `flutter pub deps` review for Flutter.
- Bundle / size deltas vs the previous release.

Report counts and list anything that increased significantly.

---

## Phase 3: Build the Checklist

```markdown
# Release Checklist — [version] — [platform]

Generated: [date]

## Codebase Health
- TODO count: [N]
- FIXME count: [N] — review each before release
- HACK count: [N]
- Skipped tests: [N] — confirm each has a tracking note

## Build Verification
- [ ] Clean build succeeds on every target platform.
- [ ] Zero warnings (or each warning is annotated as accepted).
- [ ] Build size within budget.
- [ ] Bundle / IPA / AAB produced from a tagged commit.
- [ ] Build is reproducible — same SHA -> same artifact hash.
- [ ] Source maps / dSYMs / mapping files archived.
- [ ] Build configured for production — no `debug`, `staging`, `mock`
      flags shipped.

## Versioning
- [ ] Version string matches the declared release.
- [ ] iOS `CFBundleShortVersionString` and `CFBundleVersion` set.
- [ ] Android `versionName` and `versionCode` set.
- [ ] React Native bundle and any OTA channel correctly named.
- [ ] Tag pushed to remote.

## Quality Gates
- [ ] QA sign-off APPROVED (or APPROVED WITH CONDITIONS resolved).
- [ ] Smoke check PASS on Tier A devices.
- [ ] Soak test PASS (if release-tier).
- [ ] No S1 / S2 bugs open.
- [ ] Performance budgets PASS.
- [ ] No memory leaks over the soak window.
- [ ] No crashes recorded during smoke + soak runs.
- [ ] Regression suite green.
```

Add platform-specific sections:

### iOS — App Store Connect

```markdown
## iOS Submission
- [ ] Distribution certificate valid and not within 30 days of expiry.
- [ ] Provisioning profile valid.
- [ ] App Store Connect record up to date.
- [ ] Build uploaded via Xcode / `altool` / `fastlane pilot`.
- [ ] Build processed without ITMS warnings.
- [ ] Export compliance answered correctly (encryption usage).
- [ ] Privacy nutrition labels match actual data collection.
- [ ] App Tracking Transparency declaration accurate; prompt timing
      complies with Apple guidelines.
- [ ] Sign In with Apple offered if any third-party social sign-in
      is offered.
- [ ] In-app purchases ready for review with screenshots.
- [ ] Age rating questionnaire complete.
- [ ] Privacy policy URL reachable.
- [ ] Support URL reachable.
- [ ] Marketing URL reachable.
- [ ] Demo account credentials provided to App Review.
- [ ] What's New text proofread, localized for every targeted locale.
- [ ] Release type chosen (manual / automatic / phased).
- [ ] TestFlight beta groups updated as desired.
```

### Android — Play Console

```markdown
## Android Submission
- [ ] Upload key and signing key configured (Play App Signing).
- [ ] App Bundle (AAB) built, signed, uploaded.
- [ ] Target API level meets the current Play requirement.
- [ ] Permissions match declarations in Data Safety.
- [ ] Data Safety form accurate (data types, sharing, deletion path).
- [ ] App content questionnaire complete (target audience, ads,
      government app status).
- [ ] Content rating (IARC) submitted.
- [ ] Privacy policy URL reachable.
- [ ] Categories and tags set.
- [ ] Pricing & distribution: countries, pricing, device categories.
- [ ] Pre-launch report passed (no critical crashes).
- [ ] Internal / closed / open testing tracks routed correctly.
- [ ] Staged rollout percentage chosen.
- [ ] What's New text localized.
```

### Store Metadata (both platforms)

```markdown
## Store Metadata
- [ ] App name approved by legal.
- [ ] Subtitle / short description proofread.
- [ ] Long description proofread, formatted, localized.
- [ ] Keywords (App Store): no trademark violations, optimal length.
- [ ] Promotional text within character limit.
- [ ] Screenshots: every required size; framed consistently; no
      placeholder devices.
- [ ] App preview / promo video: optional but uploaded if planned.
- [ ] App icon final (1024 iOS, 512 Android), correct colour profile.
- [ ] Localized metadata for every targeted market.
```

### Launch Operations

```markdown
## Launch Ops
- [ ] Crash reporting receiving from candidate build.
- [ ] Analytics receiving from candidate build.
- [ ] Remote config defaults safe for first launch.
- [ ] Feature flags reviewed for desired ON/OFF at launch.
- [ ] Backend on-call rotation set for launch + 72h.
- [ ] Day-one patch scoped (`/day-one-patch`) if needed.
- [ ] Rollback plan documented.
```

### Sign-Offs

```markdown
## Sign-Offs
- [ ] Engineering Lead
- [ ] QA Lead
- [ ] Release Manager
- [ ] Producer
- [ ] Design Lead (for store imagery)
```

---

## Phase 4: Walk the Checklist with the User

Section by section. Use AskUserQuestion to mark each section as
complete, partially complete (with list), or blocked.

For partially complete sections, capture the open item with owner and
due date.

---

## Phase 5: Render the Release Document

```markdown
# Release Checklist — [version] — [platform]

[Full checklist content from Phases 3-4]

## Open Items
| Item | Owner | Due |

## Verdict: READY / READY WITH CONDITIONS / NOT READY

Rationale: [paragraph]
```

Ask: "May I write this to `production/releases/release-checklist-[version].md`?"

---

## Phase 6: Update State

Append to `production/session-state/active.md`:

```
## Release Checklist — [date]
- Version: [version]
- Platform(s): [list]
- Verdict: [verdict]
- Open items: [count]
- Path: [path]
- Next: [/gate-check | /launch-checklist | /team-release]
```

---

## Quality Gates / PASS-FAIL

- READY — every check ticked, all sign-offs collected.
- READY WITH CONDITIONS — open items remain but each has a clear owner
  and due date prior to submission.
- NOT READY — quality gate failure or missing required submission
  artifact.

---

## Examples

**Example 1 — v1.2.0 both platforms:**
TODO count 4, FIXME 1 (with tracking story), QA APPROVED. Two open
items: privacy nutrition update needed for new analytics SDK; Play
Data Safety needs a refresh. Verdict: READY WITH CONDITIONS.

**Example 2 — patch release v1.2.1, iOS only:**
Hotfix release. Smoke PASS, regression PASS, no metadata changes.
Verdict: READY.

---

## Next Steps

- READY -> `/launch-checklist` for the wider readiness review, then
  `/team-release` to execute.
- READY WITH CONDITIONS -> resolve, re-run.
- NOT READY -> resolve, re-run.
