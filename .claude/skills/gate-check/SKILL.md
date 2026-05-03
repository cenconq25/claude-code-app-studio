---
name: gate-check
description: "Validate readiness to advance between development phases. Synthesizes QA, perf, security, asset, balance, and localization verdicts into a single PASS/CONCERNS/FAIL with specific blockers and required artifacts. Use when asking 'are we ready to advance?'."
argument-hint: "[from-phase->to-phase | --auto]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
model: opus
---

# Gate Check

Phase advancement requires more than vibes. This skill collects every
recent verdict artifact, cross-checks them for staleness and
consistency, and emits a single PASS / CONCERNS / FAIL ruling. It is
intentionally cross-system synthesis — therefore Opus tier.

---

## Phase 1: Determine Source and Target Phase

Parse the argument:

- Explicit form: `prototype->preproduction`,
  `preproduction->production`, `production->polish`, `polish->release`,
  `release->live-ops`.
- `--auto` — read `production/stage.txt` and use the next standard
  transition.
- No argument — ask the user.

Each gate has a different artifact bar (see Phase 3).

---

## Phase 2: Inventory Recent Artifacts

Glob the latest of each artifact type:

- `production/qa/qa-signoff-*.md`
- `production/qa/smoke-*.md`
- `production/perf/perf-profile-*.md`
- `production/security/security-audit-*.md`
- `production/assets/asset-audit-*.md`
- `production/balance/balance-check-*.md`
- `production/localization/loc-report-*.md`
- `docs/tech-debt.md`
- `production/qa/soak/[date]/summary.md`
- `production/releases/release-checklist-*.md`
- `production/releases/launch-checklist-*.md`
- `docs/architecture/` for ADR statuses
- `production/qa/bugs/` for open S1/S2 counts

For each, capture: path, last modified date, verdict.

Apply staleness rule: any artifact older than 14 days is suspect for
a release-tier gate. Flag and surface.

---

## Phase 3: Apply the Gate-Specific Bar

### prototype -> preproduction

Required:

- Architecture artifacts present (`docs/architecture/master-architecture.md`,
  ADRs, control manifest).
- All MVP PRDs reviewed via `/review-all-prds` with PASS verdict.
- No `proposed` ADRs blocking.

### preproduction -> production

Required:

- `/test-setup` complete and CI runs green.
- Foundation epics done.
- First sprint plan approved.

### production -> polish

Required:

- All Critical / Must-Have features implemented per PRD.
- Latest QA sign-off APPROVED on the most recent sprint.
- Open S1/S2 bugs == 0.
- Tech debt register reviewed in last 30 days.

### polish -> release

Required:

- Latest perf profile HEALTHY.
- Latest security audit RELEASE OK.
- Soak test summary PASS.
- Localization 100% on every target locale.
- Asset audit CLEAN.
- Balance check BALANCED.
- Regression suite green.
- Open S1/S2 == 0; open S3 reviewed.

### release -> live-ops

Required:

- `/launch-checklist` GO.
- Day-one patch scoped or N/A.
- Crash + analytics live and verified post-deploy.
- On-call rotation defined.
- Rollback plan documented.

---

## Phase 4: Cross-Verdict Consistency

Look for contradictions between artifacts:

- QA sign-off says "no S1/S2" but `production/qa/bugs/` shows open
  S1 -> contradiction.
- Perf profile HEALTHY but soak summary lists memory growth -> recheck.
- Security RELEASE OK but tech debt register has a P0 deprecated-API
  with pending OS removal -> conflict.
- Asset audit CLEAN but localization report has missing locales for
  store screenshots -> partial.

Surface every contradiction. None can be silently passed through.

---

## Phase 5: Apply Severity Rules

Convert each artifact's status to a contribution:

- Verdict PASS / GREEN / APPROVED -> +1.
- Verdict WITH CONDITIONS / WARNINGS / NEEDS WORK -> 0 (note conditions).
- Verdict FAIL / RED / NOT APPROVED / BLOCKING -> -1.
- Stale (> 14 days) -> 0 with a note suggesting re-run.

Compute the gate result:

- All required-for-this-gate artifacts at +1, no contradictions -> PASS.
- Any -1 OR any required artifact missing OR any contradiction
  unresolved -> FAIL.
- Otherwise (mix of +1 and 0 with no -1) -> CONCERNS.

---

## Phase 6: Build Specific Blocker List

For FAIL verdicts, every -1 contributes a specific blocker line:

- "QA sign-off NOT APPROVED — sprint-04 build failed manual QA on
  paywall flow. Re-run `/team-qa` after fix."
- "Soak test FAIL — 12 MB/h leak after 4 hours. Open story to address
  before re-running soak."

For CONCERNS, every conditions/warnings entry contributes a recommended
follow-up.

---

## Phase 7: Render the Verdict

```markdown
# Gate Check: [from] -> [to]
Date: [date]
Tier: [PASS / CONCERNS / FAIL]

## Artifact Inventory
| Artifact | Date | Verdict | Stale? | Contribution |
|----------|------|---------|--------|--------------|
| QA sign-off (sprint-04) | 2026-04-29 | APPROVED | no | +1 |
| Perf profile | 2026-05-01 | HEALTHY | no | +1 |
| Security audit | 2026-04-12 | RELEASE WITH PLAN | borderline | 0 |
| Soak summary | (none) | MISSING | — | -1 |

## Cross-Verdict Conflicts
- [list, or "None"]

## Blockers
- [each -1 contribution as a one-line action]

## Concerns
- [each 0 contribution as a recommended follow-up]

## Required Artifacts Missing
- [list]

## Verdict: [PASS / CONCERNS / FAIL]

Rationale: [synthesis paragraph]

## Recommended Path
- [if PASS] Update `production/stage.txt` to [to] and proceed.
- [if CONCERNS] Either accept conditions or address top 1-2 concerns.
- [if FAIL] Address listed blockers in priority order; re-run gate
  after each.
```

Ask before writing to `production/gates/gate-[from-to]-[date].md`.

---

## Phase 8: Update Session State

Append to `production/session-state/active.md`:

```
## Gate Check — [date]
- Direction: [from] -> [to]
- Verdict: [PASS / CONCERNS / FAIL]
- Blockers: [count]
- Path: [path]
- Next: [advance | resolve and re-run]
```

If verdict is PASS and the user agrees, ask:
"May I update `production/stage.txt` to `[to]`?"

---

## Quality Gates / PASS-FAIL

This skill IS the gate. The verdict is binding for phase advancement.

---

## Examples

**Example 1 — polish -> release:**
QA APPROVED, perf HEALTHY, security RELEASE OK, soak PASS,
localization 100%, asset CLEAN, balance BALANCED, regression GREEN.
Verdict: PASS. Stage updated to `release`.

**Example 2 — production -> polish:**
QA APPROVED but 3 S2 bugs open in production/qa/bugs/. Verdict: FAIL
with one blocker: "Resolve open S2 bugs (BUG-104, BUG-109, BUG-117)
or document explicit deferral."

---

## Next Steps

- PASS -> proceed with stage transition.
- CONCERNS -> resolve top concerns, re-run if release-tier.
- FAIL -> drive blockers to closure; re-run.
