---
name: team-release
description: "Orchestrate the release team: release-manager, qa-lead, mobile-devops, and producer. Drives a release from candidate through certification, rollout, and post-launch monitoring."
argument-hint: "[--version=<v> | --type=major|minor|patch|hotfix]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion
agent: release-manager
model: sonnet
---

# Team Release

Coordinate the four roles needed to take a build from "QA approved"
through to "live in users' hands". Spawns subagents in parallel where
possible, sequentially where causality requires.

---

## Team Composition

- **release-manager** — owns the release plan, version bumps, store
  submission, rollout pacing.
- **qa-lead** — final sign-off, post-deploy monitoring acceptance.
- **mobile-devops** — build pipeline, signing, certificates, store
  upload, infrastructure scale-up.
- **producer** — communications, sign-off chase, launch comms.

Spawn each via Task with `subagent_type: <role>`.

---

## Phase 1: Confirm Release Type and Scope

Parse `--type` (major / minor / patch / hotfix) and `--version`. If
either is missing, ask.

Read in parallel:

- Latest release log in `production/releases/`.
- Latest QA sign-off.
- Latest `/release-checklist` artifact for this version.
- Latest `/launch-checklist` artifact (if a major launch).
- `production/stage.txt`.

Render a one-line summary of the candidate release and ask the user to
confirm.

---

## Phase 2: Release Plan via release-manager

Spawn `release-manager` via Task. Prompt template:

> Compose a release plan for version [version]. Read the release
> checklist at [path] and the latest QA sign-off at [path]. Produce a
> staged plan covering: build prep, store submission, review window
> expectation, staged rollout percentages, monitoring window, and
> rollback triggers.

Render the plan. Use AskUserQuestion:

- `[A] Approve plan — proceed`
- `[B] Revise rollout pacing`
- `[C] Cancel — pre-conditions not met`

---

## Phase 3: Build and Sign via mobile-devops

Spawn `mobile-devops` via Task. Prompt template:

> Build and sign the release artifacts for version [version]. Confirm:
> certificates current, provisioning profiles match, Play App Signing
> configured, version strings and build numbers correct, source maps /
> dSYMs / mapping files archived. Use the project's CI release lane
> (`fastlane release`, `eas build`, `flutter build appbundle`, native
> Xcode archive, etc.). Output build IDs and artifact paths.

If signing certificates are within 30 days of expiry, surface as a
blocker.

Capture artifact paths and build IDs.

---

## Phase 4: Pre-Submission Verification

Run a final verification on the built artifact:

- iOS: `altool --validate-app` or Xcode "Validate App".
- Android: bundletool produce APKs from AAB and install on a Tier A
  emulator; confirm cold start.
- React Native / Flutter: confirm OTA channel naming (CodePush /
  Expo Updates) does not collide with prior releases.

Run the smoke check against the built artifact. PASS required.

---

## Phase 5: Final QA Sign-Off via qa-lead

Spawn `qa-lead` via Task. Prompt template:

> The release artifact for [version] is built and validated. Latest QA
> sign-off is at [path]. Final question: does the actual signed build
> match what QA approved? Run a smoke pass on the signed binary on
> Tier A devices, confirm or refuse final sign-off.

If qa-lead refuses, stop the release. Surface the gap.

---

## Phase 6: Store Submission via mobile-devops

Spawn `mobile-devops` to submit:

- iOS: upload via `altool` / `fastlane pilot upload` /
  `xcrun altool --upload-app`. Submit for review with the chosen
  release type (manual / automatic / phased).
- Android: upload AAB to the chosen track (internal -> closed -> open
  -> production with staged rollout %).

Capture submission references (App Store Connect submission ID, Play
Console release name).

---

## Phase 7: Producer Communications via producer

Spawn `producer` via Task. Prompt template:

> Release [version] is submitted to stores. Coordinate the launch
> comms: notify support, marketing, community managers; confirm press
> kit and announcement scheduled; schedule the on-call rotation for
> launch + 72h; ensure rollback approvers are reachable.

Capture the comms checklist as a section in the release log.

---

## Phase 8: Review Window Monitoring

Set expectations with the user:

- App Store review typical: 24-48 hours.
- Play Console review: hours to days depending on policy changes.

If the user wants to expedite (App Store), confirm the reason and
generate the expedite request text via release-manager.

While waiting, mobile-devops should:

- Verify crash reporting receives from the candidate build.
- Verify analytics receives from the candidate build.
- Verify remote config defaults are correct for first launch.

---

## Phase 9: Go-Live

Once approved, the rollout strategy:

- iOS: manual release / phased release across 7 days / immediate.
- Android: staged rollout (1% -> 5% -> 20% -> 50% -> 100%) over hours
  to days, monitoring metrics at each step.

Spawn release-manager to drive each rollout step. Between steps, check:

- Crash-free user rate within budget.
- Conversion / activation metrics within expectation.
- Support ticket volume normal.

If any metric breaches, halt rollout and prepare `/hotfix` or rollback.

---

## Phase 10: Post-Launch Watch (72 Hours)

Define a watch window. Spawn qa-lead and producer in parallel to:

- qa-lead: triage incoming bug reports, run `/bug-triage` daily.
- producer: aggregate user feedback from stores, social, support.

Capture daily summaries in
`production/releases/post-launch-watch-[version]-[day].md`.

---

## Phase 11: Compose the Release Log

```markdown
# Release Log — [version]

Type: [major / minor / patch / hotfix]
Submitted: [date]
Approved: [date]
Live: [date]

## Build
- iOS: [build number]
- Android: [build number]

## Plan
[reference to plan from Phase 2]

## Submission
- App Store: [submission ID]
- Play Console: [release name]

## Sign-Offs
| Role | Name | Date |

## Rollout
| Step | % | Date | Crash-free rate | Notes |

## Post-Launch Watch
| Day | Crash-free | New bugs | Notable feedback |

## Verdict: SHIPPED / SHIPPED WITH ISSUES / ROLLED BACK
```

Ask before writing to `production/releases/release-log-[version].md`.

---

## Phase 12: Update State

Append to `production/session-state/active.md`:

```
## Release — [date]
- Version: [version]
- Status: [submitted / approved / live / rolled back]
- Build IDs: iOS [N], Android [N]
- Watch window: [day X of 3]
- Log: [path]
- Next: monitor / d1 patch / next sprint planning
```

---

## Error Recovery

If any subagent returns BLOCKED:

- mobile-devops blocked on signing -> escalate immediately.
- qa-lead refuses sign-off -> halt; address the cited gap; re-run
  smoke and sign-off.
- producer reports comms not ready -> pause submission until comms
  are ready.

If post-launch crash-free dips below threshold -> halt rollout, run
`/hotfix` or revert to previous build, log the incident.

---

## Quality Gates / PASS-FAIL

This skill emits the binding "did the release ship?" verdict.

- SHIPPED — build is live, watch window completed, no rollback
  required, day-one patch (if any) shipped within 48h.
- SHIPPED WITH ISSUES — live but with documented issues that did not
  require rollback; next sprint includes follow-ups.
- ROLLED BACK — release was reverted; incident review scheduled via
  `/retrospective`.

---

## Examples

**Example 1 — minor v1.3.0 release:**
QA APPROVED, build signed, submitted, approved within 18 hours. Play
staged rollout 1% -> 5% -> 20% -> 100% over 3 days. Crash-free 99.7%
throughout. SHIPPED.

**Example 2 — hotfix v1.3.1 release:**
Hotfix log already exists. Skip planning, run build + sign + submit
with expedite. App Store approves in 14 hours. Play staged 50% -> 100%
in 12 hours. SHIPPED.

---

## Next Steps

- SHIPPED -> `/retrospective` after the watch window; plan next sprint.
- SHIPPED WITH ISSUES -> `/bug-triage` and possibly `/day-one-patch`.
- ROLLED BACK -> `/retrospective` immediately.
