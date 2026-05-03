---
name: day-one-patch
description: "Prepare a day-one patch for launch. Scopes, prioritizes, implements, and QA-gates a focused patch addressing issues found between gold master and public launch. Treats the patch as a mini-sprint with its own QA gate and rollback plan."
argument-hint: "[--from=<release-tag> | --bug-list=<paths>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion
model: sonnet
---

# Day-One Patch

Between the build that went to certification and the build users see at
launch, problems show up — late-breaking telemetry, a cert reviewer
finding, a marketing copy change. This skill scopes a focused mini-
sprint patch, runs it through QA, and lands it on the user before they
even notice the gap.

---

## Phase 1: Source the Patch Scope

Resolve the source build:

- `--from=<release-tag>` -> read that tag.
- Otherwise consult `production/releases/release-checklist-*.md` for
  the latest release version and use its tag.

Source the candidate patch list from any of:

- `--bug-list=<paths>` -> explicit list.
- Recent BUG records filed since the release tag in
  `production/qa/bugs/`.
- Recent S1/S2 issues triaged in `production/qa/triage-*.md`.
- App Store / Play review feedback (if pasted by user).
- Late-breaking telemetry alerts (Sentry / Crashlytics digest).

Render the candidate list with severity, frequency (if known), and
origin source.

---

## Phase 2: Filter to Day-One Scope

Apply the day-one bar — only fixes that meet ALL of these qualify:

- Severity S1 or S2.
- Reproducible.
- Fix is small (< 2 days of engineering, ideally < 1).
- Fix is low-risk (touches a small, well-understood area).
- Fix has a regression test plan.

Any candidate failing the bar is either downgraded to a normal sprint,
escalated to `/hotfix`, or rejected.

Use AskUserQuestion to confirm scope:

```
question: "Day-one scope candidates (top severity first):"
options:
  - "Accept the proposed scope"
  - "Add: [user provides]"
  - "Drop: [user provides]"
  - "Cancel — these are not day-one items"
```

---

## Phase 3: Risk Assessment

For the agreed scope, run the patch-risk checklist:

- [ ] Each fix has a clear blast radius (which features, which user
      cohort).
- [ ] Combined diff stays under [project threshold, default 500 LOC].
- [ ] No fix changes the public API surface.
- [ ] No fix changes the on-disk data schema.
- [ ] No fix touches payment flow without a payments specialist on
      review.
- [ ] No fix touches auth flow without a security review.
- [ ] No fix is bundled with a feature change — patch is fixes only.

Surface any unchecked items and ask the user whether to proceed,
descope, or escalate to `/hotfix`.

---

## Phase 4: Branch and Schedule

Create the patch branch from the release tag:

```
git checkout -b release/[version]-d1-patch [release-tag]
```

Ask before running.

Estimate per-bug effort and assemble a patch sprint plan
(`production/sprints/d1-patch-[version].md`):

- Goals
- Stories (one per bug)
- Owner per story
- Estimated effort
- QA pass plan
- Submission deadline (typically the day before launch)

Ask before writing.

---

## Phase 5: Implement Each Story

For each scope item, run the per-story loop:

1. `/create-stories` if not already a story.
2. `/story-readiness` to validate the story is implementable.
3. `/dev-story` to spawn the right specialist and implement.
4. `/code-review` on the diff.
5. `/story-done` to verify ACs and close.

Each story must add a regression test (this is non-negotiable for a
day-one patch — see `/regression-suite --add-bug`).

Coordinate via Task subagents as needed:

- `lead-developer` for general patches.
- `security-engineer` for any security-touching fix.
- `qa-tester` for test scaffolding.

---

## Phase 6: Patch QA

Run a focused QA cycle scoped to the patch via `/team-qa feature: d1-patch`.

The cycle includes:

- Smoke check against the patch branch.
- Targeted manual walkthroughs for each fix.
- Regression suite (full).
- Soak run optional — typically required for memory or background
  fixes.

Record verdict. Day-one patch demands APPROVED (no conditions). Anything
less re-opens the scope.

---

## Phase 7: Rollback Plan

For each fix, capture how to roll back if it misbehaves in production:

- Revert the patch (delete the patch build, revert to the gold-master
  build).
- Per-feature rollback via remote-config kill switch (require these for
  any non-trivial fix).
- Pin the underlying flag default to OFF if telemetry shows damage.

Document at `production/releases/d1-patch-[version]-rollback.md`. Ask
before writing.

---

## Phase 8: Compose the Patch Log

```markdown
# Day-One Patch — [version]

Source build: [release tag]
Patch branch: [branch]
Submitted: [date]
Live: [date]

## Scope
| Story | Bug | Severity | Owner | Risk |

## Diff Summary
- Files changed: [N]
- LOC: [+P / -Q]
- Tests added: [N]

## QA Verdict
- Smoke: [verdict]
- Manual: [PASS/FAIL counts]
- Regression: [verdict]
- Soak: [verdict | not required]
- Sign-off: [verdict]

## Rollback Plan
[summary, link to full doc]

## Approvals
- Engineering Lead
- QA Lead
- Producer
- Release Manager

## Submission
- iOS build: [number]
- Android build: [number]
- Submitted to: [App Store Connect / Play Console]
- Expedited review requested: [yes/no with reason]
```

Ask before writing to `production/releases/d1-patch-[version].md`.

---

## Phase 9: Update State

Append to `production/session-state/active.md`:

```
## Day-One Patch — [date]
- Version: [version]
- Scope: [N fixes]
- QA verdict: [verdict]
- Rollback: [path]
- Patch log: [path]
- Next: submit, monitor 48h post-launch
```

---

## Quality Gates / PASS-FAIL

- PASS — every scope item shipped, regression tests added, QA
  APPROVED, rollback plan documented, all approvals captured.
- FAIL — any of: missing regression test, QA short of APPROVED, no
  rollback for a non-trivial fix, missing approval. Re-scope or
  escalate.

---

## Examples

**Example 1 — Pre-launch d1 patch:**
4 candidate bugs reviewed. 2 qualify (S2 paywall copy + S2 push
permission timing). Implemented over 2 days, QA APPROVED, rollback
flag added. Submitted day before launch with expedited review.

**Example 2 — Aborted d1 patch:**
Initial scope of 7 items violates the < 500 LOC threshold and includes
an auth-flow rewrite. Skill flags as risky. User descope: 2 items
ship as d1, the auth rewrite goes to next sprint.

---

## Next Steps

- Submit and request expedited review (App Store) or staged rollout
  (Play Console).
- Monitor crash + telemetry for 48 hours post-launch.
- If anomalies appear -> `/hotfix` flow with rollback plan invoked.
