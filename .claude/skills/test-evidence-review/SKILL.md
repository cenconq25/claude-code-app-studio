---
name: test-evidence-review
description: "Quality review of test files and manual evidence docs. Goes beyond existence checks — evaluates assertion coverage, edge cases, naming conventions, and evidence completeness. Verdict: ADEQUATE / INCOMPLETE / MISSING per story. Run before QA sign-off or on demand."
argument-hint: "[sprint-id | story-path | --all]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
model: sonnet
---

# Test Evidence Review

A test file existing is not the same as a test file being good. This skill
audits each in-scope story's test evidence against a fixed quality bar and
emits per-story verdicts.

---

## Purpose / When to Run

Run when:
- Before a `/team-qa` sign-off pass
- After `/dev-story` lands several stories and a sweep is needed
- When a sprint is in `In Review` and QA wants assurance the test evidence
  holds up
- On demand for a single story whose evidence is in dispute

Distinct from `/smoke-check` (runs the suite) and `/regression-suite`
(maps coverage to critical paths) — this skill judges *quality* of the
evidence already produced.

## Inputs

- Story files under `production/sprints/` or `production/epics/`
- Test files under `tests/unit/`, `tests/integration/`, `tests/e2e/`
- Manual evidence docs under `production/qa/evidence/`
- Smoke reports under `production/qa/smoke-*.md`

## Outputs

- A printed report keyed by story. Read-only — this skill writes nothing.

---

## Phase 1: Scope Resolution

Parse the argument:

- `sprint-NN` — read all stories in `production/sprints/sprint-NN/` (or
  the sprint folder under `production/epics/`).
- A story path — review just that story.
- `--all` — review every story whose Status is `In Review` or
  `Complete`.

Read each in-scope story file and capture:

- Story Type
- Acceptance Criteria
- Test Evidence path

---

## Phase 2: For Each Story, Run These Checks

### Logic stories — automated unit test required

Read the test file. Score:

- [ ] File exists at the declared path.
- [ ] File name matches `[module]_[feature]_test.[ext]`.
- [ ] Each AC has at least one named test function whose name implies
      the AC.
- [ ] Boundary values from the PRD's Formulas / Limits section are
      covered.
- [ ] Tests are deterministic — no `Math.random()` / `Random()` /
      `DateTime.now()` without injection.
- [ ] No real network, file I/O, or database — mocks are used.
- [ ] Each test asserts at least one observable outcome — no empty
      `it()` or `test()` blocks.
- [ ] Test count is reasonable (>= AC count; flag if 3x AC count, may
      be over-tested).

### Integration stories — integration test or playtest doc

Score:

- [ ] An integration test exists OR a playtest evidence doc exists.
- [ ] The test or doc exercises the full cross-module path described
      in the AC.
- [ ] Mocked seams are documented (which boundary is real, which is
      stubbed).
- [ ] If a doc, it carries date, tester, build version, and an
      explicit PASS/FAIL per AC.

### Visual/Feel stories — screenshot + lead sign-off

Score:

- [ ] Evidence doc exists at `production/qa/evidence/[slug]-evidence.md`.
- [ ] Doc references at least one screenshot or screen recording file
      that exists on disk.
- [ ] Doc includes the lead's name and date of sign-off.
- [ ] Each Visual/Feel AC is addressed by name in the doc.

### UI stories — manual walkthrough doc OR interaction test

Score:

- [ ] Walkthrough doc exists with numbered steps + expected outcomes.
- [ ] Doc covers the device matrix specified in the QA plan.
- [ ] If an interaction test exists (Detox, Maestro, XCUITest, Espresso),
      it covers the happy path at minimum.

### Config/Data stories — smoke check pass

Score:

- [ ] A smoke check report exists at `production/qa/smoke-[date].md`.
- [ ] The report covers the flow affected by the config change.
- [ ] Verdict in the report is PASS.

---

## Phase 3: Compute Per-Story Verdict

For each story, sum the checks. The verdict scale:

- **ADEQUATE** — all required checks pass, evidence holds up to scrutiny.
- **INCOMPLETE** — evidence exists but has gaps (e.g., test exists but
  misses 2 of 5 ACs, or doc lacks sign-off date).
- **MISSING** — evidence does not exist or the test file is empty.

---

## Phase 4: Detect Common Anti-Patterns

Grep across the test tree for red flags:

- `expect(true).toBe(true)` and equivalents — empty assertions.
- `xtest`, `xit`, `test.skip`, `it.skip`, `@Disabled`, `@Ignore` —
  permanently skipped tests.
- `setTimeout` or `Thread.sleep` directly in test bodies — flaky timing.
- Hardcoded production URLs, real API keys, real device tokens.
- Snapshot files older than 6 months — likely stale.
- Tests with no `assert`, `expect`, `XCTAssert*`, or `assertEquals`.

Each anti-pattern hit demotes the relevant story by one tier
(ADEQUATE -> INCOMPLETE, INCOMPLETE -> MISSING).

---

## Phase 5: Render the Report

```
## Test Evidence Review: [scope]

| Story | Type | Verdict | Notes |
|-------|------|---------|-------|
| [title] | Logic | ADEQUATE | 6 tests, all ACs covered |
| [title] | UI | INCOMPLETE | walkthrough missing iPad layout |
| [title] | Logic | MISSING | test file is empty |

### Anti-patterns found
- tests/unit/cart/discount.test.ts:42 — empty assertion
- tests/integration/sync/queue.test.ts:18 — Thread.sleep usage

### Coverage gaps
[Across the sprint, which ACs have no test mapping at all]

### Required Fixes Before Sign-Off
- [story] — write the boundary case test for AC 3
- [story] — attach iPad screenshot and lead sign-off

### Verdict: [ALL ADEQUATE | NEEDS FIXES | BLOCKING GAPS]
```

This skill writes nothing.

---

## Quality Gates / PASS-FAIL

- ALL ADEQUATE — every in-scope story passes; QA sign-off can proceed.
- NEEDS FIXES — at least one INCOMPLETE; sign-off may proceed with
  documented exceptions.
- BLOCKING GAPS — at least one MISSING; QA sign-off is blocked until the
  evidence is produced.

---

## Examples

**Example 1 — Sprint 4 review:**
Scopes 9 stories. 7 ADEQUATE, 1 INCOMPLETE (UI walkthrough missing the
landscape orientation), 1 MISSING (Logic story has a test file but no
assertions). Verdict: BLOCKING GAPS.

**Example 2 — Single story review post-fix:**
Story originally INCOMPLETE. The author added the missing boundary case
and re-ran. Verdict: ADEQUATE.

---

## Next Steps

- BLOCKING GAPS -> author the missing tests, then re-run this skill.
- NEEDS FIXES -> resolve fixes or document exceptions in the QA plan.
- ALL ADEQUATE -> run `/team-qa sprint-NN` for sign-off.
