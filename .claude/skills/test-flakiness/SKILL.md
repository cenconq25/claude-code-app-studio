---
name: test-flakiness
description: "Detect non-deterministic tests by reading CI run history. Aggregates pass rates per test, identifies intermittent failures, recommends quarantine or fix, and maintains a flaky-test registry. Best run during Polish phase or after a CI run streak."
argument-hint: "[--days=N | --runs=N | --register-only]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---

# Test Flakiness

Locate tests whose result depends on timing, ordering, or hidden state
rather than on the system under test. Maintain a registry of known flakes
with quarantine status and fix targets.

---

## Phase 1: Source CI History

Determine where test history lives. Try in order:

1. `.test-history/` directory — JSON or JUnit XML reports stored locally.
2. `gh` CLI — fetch recent CI runs:
   `gh run list --workflow=test.yml --limit=N --json conclusion,databaseId`
3. Bitrise API — if configured, fetch recent builds.
4. CircleCI API — if configured.
5. Manual import — if none of the above, ask the user to drop JUnit XML
   files into `.test-history/` and rerun.

Default window: last 30 days OR last 50 runs, whichever yields more data.
Override via `--days` or `--runs`.

If history is unreachable, stop and tell the user how to enable it.

---

## Phase 2: Parse Results

For each retrieved run, extract:

- Run ID
- Date
- Branch
- Commit SHA
- Per-test result (`pass` / `fail` / `error` / `skipped`)
- Per-test duration

Aggregate per test:

- Total runs
- Pass count
- Fail count
- Pass rate
- Standard deviation of duration
- First failure date, last failure date

---

## Phase 3: Classify

Apply these thresholds:

| Class | Criterion |
|-------|-----------|
| HEALTHY | Pass rate 100% over the window. |
| FLAKY | Pass rate >= 50% but < 100%, with at least one fail and one pass on the same SHA. |
| BROKEN | Pass rate < 50% — likely a real regression, not flakiness. |
| SLOW | Duration std-dev > 2x median, even if pass rate is 100%. |
| DEAD | Skipped on every run in the window. |

Surface FLAKY first; that is the target of this skill.

---

## Phase 4: Gather Context for Each Flaky Test

For each FLAKY entry, read the test file and look for:

- Direct timing dependencies — `setTimeout`, `Thread.sleep`,
  `Future.delayed`, hardcoded animation duration waits.
- Real network or file I/O.
- Order-dependence — module-scope mutable state, missing teardown,
  reliance on previous test's side effects.
- Real device clock — `Date()`, `DateTime.now()`, `Date.now()` without
  injection.
- Real randomness — unseeded `Math.random`, `Random()`.
- Concurrency — uncontrolled `await Promise.all(...)`, async/await
  without explicit synchronization.
- E2E specific — fixed waits, hardcoded element coordinates, missing
  retry on flakey selectors.

Tag each flaky test with the most likely root cause.

---

## Phase 5: Recommendation

For each FLAKY test, propose one action via AskUserQuestion:

- `[A] Quarantine` — mark the test as flaky-known, exclude it from blocking
  CI gates but keep it running for visibility.
- `[B] Fix now` — open a follow-up story, assign to the original author.
- `[C] Delete` — the test is more harm than help and the AC has other
  coverage.
- `[D] Defer` — log and revisit next sprint.

For BROKEN tests: surface them prominently; do not quarantine. Recommend
a hotfix or revert.

---

## Phase 6: Maintain the Registry

Open or create `tests/flaky-registry.md` with this shape:

```markdown
# Flaky Test Registry

Last reviewed: [date]
Window: last [N] runs / [days]

## Quarantined
| Test | Pass rate | Likely cause | Owner | Quarantined since |
|------|-----------|--------------|-------|-------------------|
| tests/integration/sync/queue.test.ts > should retry | 73% | real timer | @ada | 2026-04-12 |

## Broken — Investigate
| Test | Pass rate | First failure | Likely cause |

## Recently Fixed
| Test | Fixed in commit | Date |

## Watch List (slow / borderline)
| Test | Pass rate | Duration p95 |
```

Ask before each registry edit.

---

## Phase 7: Quarantine Mechanics

When the user picks Quarantine, edit the test file (or framework config)
to apply the framework's skip-with-reason mechanism:

- Jest: rename to `it.skip` with a `// FLAKY: see flaky-registry.md` comment.
- Flutter: wrap in `skip: 'FLAKY: ...'` parameter.
- XCTest: prepend `func skip_test_...` plus a TODO comment, OR add to a
  separate test plan that runs non-blocking.
- JUnit: `@Disabled("FLAKY: ...")`.

For E2E flakes (Detox, Maestro), prefer a tag-based exclusion at the
runner level rather than commenting out flows.

Always include a back-link to the registry so the test is not silently
forgotten.

---

## Phase 8: Render Summary

```
## Flakiness Report — [date]

Window: [N] runs / [days]
- Healthy: [count]
- Flaky: [count] — actioned: [Q quarantined, F fixed, D deferred]
- Broken: [count] — needs immediate attention
- Slow: [count]
- Dead: [count]

### New flakes this window
[list]

### Quarantine reaching 30+ days
[list — these need a fix story]

### Recommended next actions
- Open story to fix [test name] — root cause: [cause]
- Investigate [broken test] — last green: [SHA]
```

---

## Quality Gates / PASS-FAIL

- PASS — flaky registry is current; no flaky test has been quarantined
  more than 30 days without a fix story; no BROKEN tests are unattended.
- FAIL — broken tests exist with no owner, OR more than 5% of the suite
  is flaky.

---

## Examples

**Example 1 — Polish-phase audit:**
Pulls last 50 GitHub Actions runs. Finds 4 flaky tests (3 fake-timer
issues, 1 order dependency). User quarantines all four and opens a
single fix story.

**Example 2 — Daily flake check via cron:**
Run with `--register-only` flag. Updates the registry but does not
prompt for action. The producer reads the registry weekly.

---

## Next Steps

- Open follow-up stories for any FIX recommendations via `/create-stories`.
- Quarantine entries older than 30 days should escalate to `/bug-triage`.
- Re-run this skill at the start of every polish-phase sprint.
