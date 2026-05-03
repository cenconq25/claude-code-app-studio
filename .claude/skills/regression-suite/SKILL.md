---
name: regression-suite
description: "Map test coverage to PRD critical paths, identify fixed bugs without regression tests, flag coverage drift from new features, and maintain tests/regression-suite.md. Run after a bug fix or before a release gate."
argument-hint: "[--audit | --add-bug=BUG-ID | --add-path=<critical-path>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion
model: sonnet
---

# Regression Suite

A regression suite is the set of tests that must keep passing forever.
This skill maintains the explicit list, traces it back to PRD critical
paths and known-bug history, and surfaces gaps before release.

---

## Phase 1: Modes

Parse the argument:

- `--audit` (default): re-evaluate the whole suite, identify gaps, suggest
  fixes.
- `--add-bug=BUG-ID`: add a regression test entry for a specific bug.
- `--add-path=<name>`: add a regression entry for a critical-path PRD
  flow.

---

## Phase 2: Load the Sources of Truth

Read in parallel:

- All PRDs under `design/prd/` — extract every Acceptance Criteria block
  marked critical or revenue-affecting.
- `production/qa/bugs/` — every closed bug with severity S1 or S2.
- `tests/regression/` directory — existing regression test files.
- `tests/regression-suite.md` if present — the registry.
- `production/milestones/` — current milestone scope to know which paths
  are in active scope.

If `tests/regression/` does not exist, propose creating it.

---

## Phase 3: Build the Coverage Matrix

Construct a table mapping each entry to a test file:

| Source | Reference | Required | Test file | Status |
|--------|-----------|----------|-----------|--------|
| PRD | onboarding-flow.prd.md AC-3 | YES | tests/regression/onboarding/sign_up_test.ts | covered |
| PRD | paywall.prd.md AC-7 | YES | (none) | MISSING |
| Bug | BUG-042 (force logout) | YES | tests/regression/auth/refresh_token_test.ts | covered |
| Bug | BUG-051 (paywall double-charge) | YES | (none) | MISSING |

Detection rules:

- A PRD AC is critical if the AC is tagged `Critical:`, `P0:`, or its
  parent flow is on the launch checklist.
- A bug requires a regression test if its severity was S1 or S2 AND its
  closing comment did not explicitly waive a test.
- A test "covers" an entry only if it actually asserts the failing
  scenario (not just runs the code path). Confirm by reading the test.

---

## Phase 4: Identify Gaps

Three buckets:

1. **PRD critical paths without a regression test** — the highest-priority
   gap. Usually means a launch-blocking flow has no permanent guard.
2. **Closed S1/S2 bugs without a regression test** — the bug is fixed but
   the fix is not pinned, so it can re-emerge.
3. **Drift** — tests that reference removed code, fixtures from deleted
   features, or assertions about replaced UI strings.

For each drift entry, propose deletion or update.

---

## Phase 5: Recommend or Create Regression Tests

For each gap, render a recommendation:

```
### MISSING: BUG-051 — paywall double-charge
Source: production/qa/bugs/BUG-051-paywall-double-charge.md
Suggested test path: tests/regression/paywall/double_charge_test.ts
Assertion sketch:
  - Trigger purchase event twice within the debounce window.
  - Expect: exactly one billing API call.
Owner: assign to the engineer who closed the bug.
```

Use AskUserQuestion to batch decisions:

- `[A] Generate test stubs for all gaps`
- `[B] Generate stubs for top N`
- `[C] Open follow-up stories instead of writing stubs now`
- `[D] Skip — I'll handle it`

For [A] or [B], spawn a per-test plan: file path, function names, fixture
needs. Ask before each Write.

---

## Phase 6: Maintain `tests/regression-suite.md`

Render the registry:

```markdown
# Regression Suite

Last reviewed: [date]
Coverage: [P]% of PRD critical paths, [Q]% of closed S1/S2 bugs.

## PRD Critical Paths

| Path | PRD ref | Test |
|------|---------|------|
| Sign-up + email verify | onboarding-flow.prd.md AC-3 | tests/regression/onboarding/sign_up_test.ts |
| First paywall view | paywall.prd.md AC-7 | tests/regression/paywall/first_view_test.ts |

## Bug Regressions

| Bug | Title | Severity | Test |
|-----|-------|----------|------|
| BUG-042 | Force logout on token refresh fail | S1 | tests/regression/auth/refresh_token_test.ts |

## Drift / Stale
[list anything that needs deletion]

## How to add an entry
- After fixing an S1/S2 bug, run `/regression-suite --add-bug=BUG-NNN`.
- After approving a new PRD critical path, run `/regression-suite --add-path=<name>`.
```

Ask before writing.

---

## Phase 7: Output

Render:

```
## Regression Suite Audit — [date]

Coverage:
- PRD critical paths covered: [P]/[total]
- Closed S1/S2 bugs covered: [Q]/[total]

Gaps requiring action: [N]
- [list, each with suggested file path]

Drift: [M] entries to remove/update

Verdict: [HEALTHY | NEEDS WORK | BLOCKING — release would lose coverage]
```

---

## Quality Gates / PASS-FAIL

- HEALTHY — every PRD critical path and every closed S1/S2 bug has a
  regression test that actually asserts the failing scenario.
- NEEDS WORK — gaps exist but none are launch-blocking.
- BLOCKING — at least one PRD critical path on the current launch
  checklist has no regression test.

---

## Examples

**Example 1 — Pre-release audit:**
Finds 2 missing entries (1 paywall path, 1 bug). User accepts stub
generation; both files are created with TODO bodies. Two follow-up
stories are opened.

**Example 2 — Add a single bug:**
`/regression-suite --add-bug=BUG-051` generates a single stub at
`tests/regression/paywall/double_charge_test.ts` and adds a row to the
registry.

---

## Next Steps

- For each generated stub, run `/dev-story` against the follow-up story
  to flesh it out.
- Re-run `--audit` before every release as part of `/release-checklist`.
