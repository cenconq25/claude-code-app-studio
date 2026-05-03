---
name: hotfix
description: "Emergency fix workflow that bypasses normal sprint process while keeping a full audit trail. Creates the hotfix branch, tracks approvals, ensures backport to main, and produces release-store-ready notes. Use only for production-impacting S1 bugs or critical store-rejection issues."
argument-hint: "[BUG-ID | --rollback]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion
model: sonnet
---

# Hotfix

The break-glass procedure for shipping a fix outside a sprint. Trades
process for speed but keeps an audit trail tight enough to survive
post-incident review.

---

## Phase 1: Confirm This Is Actually a Hotfix

Hotfix is justified only when ALL of these hold:

- A production build is currently live and impacted.
- The issue is S1 OR a store-rejection blocker OR a security exposure.
- Waiting for the next sprint would cause further user harm.

Otherwise, route to `/bug-triage` for normal scheduling.

Ask the user via AskUserQuestion to confirm the trigger:

- `[A] Live S1 — users impacted right now`
- `[B] App Store / Play Store rejection — review board needs a fix`
- `[C] Security disclosure — needs immediate patch`
- `[D] Cancel — this is not a hotfix`

If [D], stop and recommend `/bug-report` or `/bug-triage`.

---

## Phase 2: Resolve the Bug Record

If `BUG-ID` is given, read `production/qa/bugs/BUG-[ID]-*.md`. If not,
prompt the user to file one via `/bug-report` first — every hotfix must
have a tracked bug.

Read:

- The bug record in full.
- Any related ADRs from the bug's "Related" section.
- The most recently shipped build's tag (via `git tag --sort=-creatordate`).

---

## Phase 3: Approval Gate

Hotfix bypasses sprint planning, so a higher approval bar applies. Use
AskUserQuestion to capture each:

- Engineering Lead approval (name)
- Producer approval (name)
- QA Lead approval (name)
- Release Manager approval (name)

If any approval is missing, stop. The audit trail requires all four for
a true hotfix. (The user can choose to proceed without a formal hotfix
process — but then it's a normal sprint fix.)

Record approvals into the hotfix log (created in Phase 8).

---

## Phase 4: Branch Strategy

Determine the source. Use Bash:

```
git fetch --tags
git tag --sort=-creatordate | head -n 5
```

Confirm with the user which release tag is currently live in production.

Create the hotfix branch from that tag:

```
git checkout -b hotfix/BUG-[ID]-[short-slug] [release-tag]
```

Ask before running. If the user prefers a different base (a release
branch, e.g., `release/2.5.x`), use that.

---

## Phase 5: Implement the Fix

Spawn the right specialist via Task. Routing matches `/dev-story`:

- Crash in core Logic -> `lead-developer` + framework specialist.
- UI regression -> `lead-developer` + framework UI specialist.
- Backend / sync / data -> `backend-engineer`.
- Security exposure -> `security-engineer`.

Pass:

- The bug record.
- The reproduction steps.
- The release tag the fix is based on.
- Explicit constraint: "Smallest possible diff. No refactors. No
  tangential improvements. The fix must be backportable to main."

The agent should:

- Create the minimal change.
- Add a regression test (this is non-negotiable for hotfix — see
  `/regression-suite --add-bug`).
- Document why the fix works in the bug's investigation log.

---

## Phase 6: Hotfix Verification

Run the smoke check against the hotfix branch via `/smoke-check`.

Run the regression suite via the project's test runner:

- `npx jest tests/regression`
- `flutter test test/regression`
- `xcodebuild test -only-testing:RegressionTests`
- `./gradlew testDebugUnitTest --tests "*regression*"`

Capture per-test results.

If anything fails, stop. The hotfix must not introduce new red.

For visual changes, also walk through the affected flow on at least one
Tier A device per platform with the user.

---

## Phase 7: Backport Plan

Hotfixes must land on both the release branch (or tag) AND main.

Capture the plan:

1. Merge the hotfix branch into the release branch (or create the
   release branch from the tag if none exists).
2. Cherry-pick the hotfix commit(s) onto main.
3. Resolve conflicts on main if main has diverged.
4. Open PRs for both targets.

If main has diverged so much that the cherry-pick is non-trivial, surface
that and consider a separate "main-equivalent fix" PR. Both must land.

Ask the user to confirm the PR destinations and reviewers before opening
PRs. (This skill does not push to remote — leave that to the user.)

---

## Phase 8: Compose the Hotfix Log

Write `production/releases/hotfixes/HOTFIX-[date]-BUG-[ID].md`:

```markdown
# Hotfix Log: BUG-[ID] — [Title]

**Date**: [date]
**Trigger**: [S1 / store rejection / security]
**Affected build**: [version]
**Hotfix build target**: [version]

## Approvals
- Engineering Lead: [name]
- Producer: [name]
- QA Lead: [name]
- Release Manager: [name]

## Timeline
- [time] Bug filed
- [time] Hotfix declared
- [time] Branch created from [tag]
- [time] Fix implemented in [commit]
- [time] Regression test added at [path]
- [time] Smoke check PASS
- [time] Regression suite PASS
- [time] Manual verification on [devices]
- [time] PR opened: [release branch URL]
- [time] PR opened: [main URL]

## Diff
- Files changed: [count]
- Lines: [+N / -M]
- Test added: [path]

## Risk Assessment
- Blast radius: [scope]
- Rollback path: [how to roll back]
- Expected user impact post-deploy: [statement]

## Rollback Plan
[explicit steps if the hotfix itself misbehaves]

## Post-Mortem Action
[link to scheduled retrospective or "Not required — minor scope"]
```

Ask before writing.

---

## Phase 9: Update State

Append to `production/session-state/active.md`:

```
## Hotfix — [date]
- Bug: BUG-[ID]
- Branch: hotfix/...
- Smoke: PASS
- Regression: PASS
- PRs open: [release], [main]
- Hotfix log: [path]
- Next: merge release PR, deploy expedited build, then merge main PR
```

Update the bug record:

- `Status: In Hotfix` while in flight.
- `Status: Closed` once both PRs are merged AND the hotfix build is
  live.

---

## Rollback Mode

If invoked with `--rollback`, the hotfix is being reversed. Workflow:

1. Confirm the hotfix tag is live and is causing harm.
2. Open a revert PR on the release branch.
3. Re-run smoke + regression on the reverted state.
4. Append a `## Rollback` block to the hotfix log capturing why.
5. Re-open the underlying bug as `Reopened` and re-triage via
   `/bug-triage`.

---

## Quality Gates / PASS-FAIL

- PASS — fix landed, regression test added, smoke + regression suite
  green, both PRs open, log written, all four approvals captured.
- FAIL — any of: missing approval, no regression test, smoke or
  regression red, log incomplete. Do not declare the hotfix shipped.

---

## Examples

**Example 1 — Live S1 crash on Android resume:**
Bug filed, approvals captured, branch off `v2.5.0`, fix is a 4-line
Compose change, regression test added, smoke + regression PASS, PRs
opened to `release/2.5.x` and `main`. Hotfix log written.

**Example 2 — Store rejection for ATT prompt timing:**
Apple rejects build for showing tracking dialog before main UI loads.
Hotfix delays the prompt to first relevant moment. Test added. Smoke
PASS. New build submitted with the hotfix log attached to the appeal.

---

## Next Steps

- Merge release PR, ship the hotfix build via `/team-release` (in
  expedited mode).
- Merge main PR.
- Schedule a post-mortem if the hotfix involved a regression caused by
  recent work — `/retrospective` after the next sprint.
