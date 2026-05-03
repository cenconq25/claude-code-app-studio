---
name: launch-checklist
description: "Full launch readiness across departments: code, content, store listings, marketing, community, infra, legal, privacy (ATT, Data Safety), accessibility, and sign-offs. Run before every public launch."
argument-hint: "[--platform=ios|android|both]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---

# Launch Checklist

The cross-functional readiness gate. `/release-checklist` covers code
and store metadata; this skill goes wider — marketing, legal, privacy,
support, community, infrastructure — so nothing important slips.

---

## Phase 1: Resolve Platform Scope

Default to both. If the project targets only iOS or only Android,
consult `.claude/docs/technical-preferences.md` for Target Platforms.

Ask the user the launch date and any soft-launch geography.

---

## Phase 2: Read Project Context

Read in parallel:

- `CLAUDE.md`, `.claude/docs/technical-preferences.md`.
- Current milestone in `production/milestones/`.
- Latest QA sign-off from `production/qa/qa-signoff-*.md`.
- Latest perf profile from `production/perf/perf-profile-*.md`.
- Latest security audit from `production/security/security-audit-*.md`.
- Latest asset audit from `production/assets/asset-audit-*.md`.
- Latest balance check from `production/balance/balance-check-*.md`.
- Latest localization report from `production/localization/loc-report-*.md`.
- Tech debt register from `docs/tech-debt.md`.

Surface the freshness of each artifact ("QA sign-off is 11 days old —
re-run?").

---

## Phase 3: Build the Master Checklist

Render a structured checklist. Each line is a checkbox the user can
work through. The skill is a generator; signing off is the user's job.

### Code and Build

- [ ] Latest QA sign-off is APPROVED (or APPROVED WITH CONDITIONS that
      have been resolved).
- [ ] Smoke check PASS on each Tier A device.
- [ ] Soak test PASS for the chosen scenario set.
- [ ] Performance budgets all PASS (cold start, frame, memory, battery,
      app size).
- [ ] Security audit RELEASE OK or RELEASE WITH PLAN (every P0 has a
      tracked fix).
- [ ] Regression suite green.
- [ ] No open S1 / S2 bugs.
- [ ] Tech debt register reviewed; no externally-deadlined item is
      unscheduled.
- [ ] Release branch tagged and signed.
- [ ] Crash reporting (Crashlytics / Sentry) live and verified
      receiving from the candidate build.
- [ ] Analytics live and verified (events fire on candidate build).
- [ ] Remote config / feature flags reviewed for safe defaults.

### Content

- [ ] Final copy proofread on every screen (UX-design sign-off).
- [ ] No placeholder strings or developer copy ("Lorem ipsum",
      "TEST", "XXX").
- [ ] All hardcoded strings extracted (`/localize --scan` empty for
      high-confidence).
- [ ] Localization coverage at 100% for every targeted locale.
- [ ] String freeze active.
- [ ] Audio assets finalized; voiceover localized for targeted locales.
- [ ] Push notification copy reviewed and localized.

### Assets

- [ ] App icon complete on both platforms (every required slot).
- [ ] Adaptive icon foreground/background/monochrome (Android 13+).
- [ ] Splash / launch screen using current API.
- [ ] No orphaned assets bloating the bundle.

### Store Listings

#### App Store
- [ ] Screenshots for every required device size.
- [ ] App Preview videos optional but uploaded if planned.
- [ ] App icon 1024 PNG sRGB.
- [ ] Promotional text, description, keywords proofread, localized.
- [ ] Age rating questionnaire complete.
- [ ] Privacy policy URL valid.
- [ ] Privacy nutrition labels accurate (data collected vs declared).
- [ ] App Tracking Transparency prompt timing reviewed; matches
      Apple guidelines.
- [ ] In-app purchases declared and approved.
- [ ] Sign-In with Apple offered if any third-party social sign-in
      exists.
- [ ] Categories, content rights, contact info correct.

#### Play Console
- [ ] Phone screenshots (2-8); tablet screenshots if tablet supported.
- [ ] Feature graphic 1024x500.
- [ ] App icon 512.
- [ ] Short description, full description, what's new — localized.
- [ ] Content rating questionnaire complete (IARC).
- [ ] Privacy policy URL valid.
- [ ] Data Safety form accurate (matches actual SDK collection).
- [ ] Target API level meets current Play requirement.
- [ ] In-app products configured.
- [ ] Permissions declared with usage descriptions.

### Marketing and Community

- [ ] Landing page live and SEO-checked.
- [ ] Press kit assembled (logos, screenshots, fact sheet).
- [ ] Launch announcement scheduled (blog post, social, email).
- [ ] Influencer / press list contacted.
- [ ] Community channels live (Discord / forum / subreddit).
- [ ] Pre-registration / TestFlight / Play closed-test users notified.
- [ ] Launch-day on-call schedule for community management.

### Infrastructure

- [ ] Backend autoscaled and load-tested at projected launch volume.
- [ ] CDN cache primed for static assets.
- [ ] Database migrations completed and reversible.
- [ ] Secrets rotated from staging values.
- [ ] Monitoring alerts wired (error rate, latency, conversion).
- [ ] On-call rotation defined for first 72 hours.
- [ ] Rollback procedure documented and rehearsed.

### Legal and Privacy

- [ ] Terms of Service link present and reviewed by counsel.
- [ ] Privacy Policy link present and reviewed by counsel.
- [ ] EULA / age gate as required.
- [ ] GDPR compliance: cookie / tracking consent, data subject rights,
      data export and deletion paths.
- [ ] CCPA "Do Not Sell" if applicable.
- [ ] Children's privacy (COPPA) if app might appeal to children.
- [ ] Third-party SDK licenses attributed.
- [ ] Trademark and copyright clearance for logos and music.

### Accessibility

- [ ] VoiceOver / TalkBack passes navigation on every primary screen.
- [ ] Dynamic Type / font scaling does not break layouts up to the
      project's target size.
- [ ] Color contrast meets WCAG 2.1 AA on key flows.
- [ ] All actionable elements have accessibility labels.
- [ ] Captions / transcripts for any video content.
- [ ] Haptics use respects "Reduce Motion" setting.

### Support

- [ ] In-app support / contact path verified.
- [ ] Help center / FAQ live, covers known issues.
- [ ] Support team trained on day-one issues and known workarounds.
- [ ] Bug reporting path from in-app to backlog established.

### Day-One Patch Plan

- [ ] Day-one patch scope agreed (run `/day-one-patch`).
- [ ] Patch QA complete or scheduled.
- [ ] Rollback plan signed off.

### Sign-Offs

- [ ] Producer
- [ ] Engineering Lead
- [ ] Design Lead
- [ ] QA Lead
- [ ] Marketing Lead
- [ ] Legal / Privacy Counsel
- [ ] Release Manager
- [ ] Executive Sponsor

---

## Phase 4: Review Each Section with the User

Walk section-by-section. Use AskUserQuestion per section:

```
question: "[Section] — overall status?"
options:
  - "All checked — sign off"
  - "Mostly done — list outstanding"
  - "Major gaps — block until resolved"
  - "Skip this section (with reason)"
```

For each "list outstanding", capture the items — these become the
Open Items list at the bottom of the document.

---

## Phase 5: Compose the Document

```markdown
# Launch Checklist — [version] — [platform]

Generated: [date]
Launch target: [date]
Prepared by: [user]

[Full checklist content from Phase 3]

## Open Items (Blockers and TODOs)
| Item | Owner | Due | Status |

## Sign-Off Status
| Role | Name | Status | Date |

## Verdict
[GO | NO-GO | CONDITIONAL with conditions list]
```

Ask before writing to `production/releases/launch-checklist-[version].md`.

---

## Phase 6: Update State

Append to `production/session-state/active.md`:

```
## Launch Checklist — [date]
- Version: [version]
- Platform: [list]
- Open items: [count]
- Verdict: [GO / NO-GO / CONDITIONAL]
- Path: [path]
- Next: [/gate-check | resolve open items | /team-release]
```

---

## Quality Gates / PASS-FAIL

- GO — every required section signed off, zero blocker items, all
  upstream verdicts (QA, perf, security) green.
- CONDITIONAL — open items remain but each has an owner and a deadline
  before the launch target.
- NO-GO — at least one section has unresolved blockers or an upstream
  verdict is red.

---

## Examples

**Example 1 — public launch v1.0 on both stores:**
Walks every section. Surface 4 open items: 2 marketing assets, 1 ATT
prompt timing question, 1 Data Safety form mismatch. Verdict:
CONDITIONAL with deadlines.

**Example 2 — Android-only beta launch:**
Subset of checklist (skip App Store sections). 6 sign-offs collected
in one walk. Verdict: GO.

---

## Next Steps

- GO -> `/team-release` to execute deployment.
- CONDITIONAL -> resolve open items, re-run.
- NO-GO -> address blockers, re-run.
