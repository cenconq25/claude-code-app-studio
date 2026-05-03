---
name: milestone-review
description: "Comprehensive milestone progress review — feature completeness, quality metrics, risk assessment, and go/no-go recommendation. Use at milestone checkpoints (alpha, beta, RC) or when evaluating readiness for a milestone deadline."
argument-hint: "[milestone-name]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Task
model: sonnet
---

# Milestone Review

A milestone is bigger than a sprint and smaller than a release — it represents a meaningful checkpoint (alpha, internal beta, public beta, RC, GM). This skill assesses readiness across feature completeness, quality, store-readiness, and risk, then produces a go/no-go.

Read-only.

---

## Purpose / When to Run

Run when:
- A milestone deadline is approaching
- The team needs to decide alpha → beta → RC progression
- Stakeholders need a status pack
- A retrospective on a missed milestone is being prepared

Distinct from `/sprint-status` (one sprint) and `/launch-checklist` (final pre-release in the second skill set). This skill assesses **a milestone**, not a single sprint or a release.

## Inputs

- `production/milestones/<milestone>.md` if present
- All sprint plans up to now
- All epics
- All stories
- All PRDs and ADRs (for completeness checks)
- `production/qa/` (test evidence, bugs)
- `production/releases/` (any prior milestone artifacts)

## Outputs

- A printed structured review

---

## Phase 1: Resolve Milestone

If named, read `production/milestones/<name>.md`. If unnamed:
- Glob `production/milestones/*.md`. Pick the most recent (or the one with status Active).
- If none exist, ask the user to describe the milestone or run with the default "current state" framing.

A milestone doc typically contains: target date, success criteria, scope (epics in scope), exit criteria.

If there is no milestone doc, ask the user which milestone is being reviewed and capture an inline definition (target date + success criteria).

---

## Phase 2: Feature Completeness

For each epic in milestone scope:
- Total stories
- Stories Complete
- Stories In Progress
- Stories Blocked
- Stories Ready (not started)
- Untraced PRD requirements (from epic Section 6)

Compute % complete per epic. Flag any epic <80% complete with <2 weeks remaining.

For each PRD in scope:
- Are all v1 TR-IDs covered by stories?
- Are all stories Complete? If not, gap list.

---

## Phase 3: Quality Metrics

### Test coverage

Count automated tests per story type:
- Logic: required test files per story — count compliance
- Integration: required test files per story — count compliance
- Visual / UI: evidence files in `production/qa/evidence/` — count

Compliance rate = stories-with-required-evidence / stories-due-for-evidence.

### Bug count

Read `production/qa/bugs/` (if present). Categorize by severity (Critical / High / Medium / Low). Compare to last milestone.

### Crash-free rate

If the project has a release, ask the user for the current crash-free rate (or read from analytics export if integrated). Flag if below the milestone's target.

### Store-readiness checks

For beta or later milestones:
- Account deletion path implemented? (Apple guideline 5.1.1(v))
- Privacy nutrition labels / Play Data Safety prepared?
- ATT prompt implemented if needed?
- IAP receipt validation server-side?
- TestFlight / Internal Testing track configured?
- App icon and splash assets delivered for all sizes?
- Localization coverage at the milestone's target locales?

---

## Phase 4: Performance Budgets

Read `docs/architecture/architecture.md` Section 18 (Performance Budgets). For each:
- Cold start
- TTI per critical screen
- Frame rate
- App size
- Memory ceiling

Ask the user for current measured values (or run via the second-skill-set `/perf-profile` if integrated).

For each, mark PASS / FAIL relative to budget.

---

## Phase 5: Risk Register

Build a list of currently-open risks:
- Blocked stories
- Proposed ADRs gating critical work
- Untraced PRD requirements
- Open HIGH bugs
- Performance budgets at risk
- External dependencies (backend not ready, third-party SDK delays)
- Store policy risks (anything that might fail review)

For each, note: probability, impact, mitigation.

---

## Phase 6: Optional Specialist Synthesis

Spawn `Task` to:
- `mobile-architect` — read everything; flag strategic concerns
- `qa-lead` — read test evidence; verdict on QA readiness
- `pm` — read milestone scope and risk register; surface stakeholder concerns

Integrate findings.

---

## Phase 7: Build the Verdict

Apply criteria to issue go/no-go:

**GO** (proceed past this milestone) when:
- Feature completeness ≥ 90% on critical-path epics
- 0 Critical bugs open
- ≤ 3 High bugs open with mitigation
- All performance budgets pass or have approved waivers
- Store-readiness items addressed (for beta or later)

**HOLD** when:
- Feature completeness 70-90% — possible to recover with focused sprint
- 1-2 Critical bugs but with active fixes
- Performance budgets borderline

**NO-GO** when:
- Feature completeness < 70%
- 3+ Critical bugs or 1 unfixable Critical
- Performance budgets failing significantly
- Store-readiness blockers unresolved

---

## Phase 8: Output

```
# Milestone Review: <name>

**Verdict: <GO / HOLD / NO-GO>**
**Target date**: <date> (in <X> days)
**Completion**: <%>

## Feature Completeness
| Epic | % Complete | Status |
|------|-----------|--------|
| auth-sign-in | 100% | DONE |
| onboarding | 75% | AT RISK |
| ... | | |

Untraced PRD requirements: <N>

## Quality
- Test compliance: <%>
- Open bugs: <C> Critical, <H> High, <M> Medium, <L> Low
- Crash-free rate: <%> (target <%>)

## Performance
| Budget | Target | Actual | Status |
|--------|--------|--------|--------|
| Cold start | < 1500ms | 1420ms | PASS |
| TTI Home | < 800ms | 1100ms | FAIL |
| ... | | | |

## Store-readiness (for beta+)
- Account deletion: <DONE / MISSING>
- Privacy labels: <DONE / MISSING>
- ATT prompt: <DONE / N/A / MISSING>
- IAP server-side validation: <DONE / N/A / MISSING>
- ...

## Risk Register
| Risk | Probability | Impact | Mitigation | Owner |
|------|------------|--------|-----------|-------|
| ADR-0007 still Proposed | HIGH | HIGH | Advance this week | <name> |
| ... | | | | |

## Recommended Actions
- For GO: lock scope; freeze risky changes; schedule release skills (`/release-checklist` next)
- For HOLD: focus next sprint on gap list; re-review in <X> days
- For NO-GO: descope <list> to v1.1; restage milestone date

## Recommended next skills
- `/sprint-plan` to schedule the gap-closing work
- `/scope-check` to verify nothing else expanded
- `/qa-plan` for the gap stories' verification
```

---

## Phase 9: Update Milestone Doc

Ask: "Append this review summary to `production/milestones/<name>.md`?"

If yes, append a `## Review <date>` section with the verdict and the gap list.

---

## Quality Gates

- Verdict matches the criteria — no soft pass when Critical bugs are open
- Every gap names a specific epic / story / item
- Performance section uses real measurements where possible
- Store-readiness section covers each item explicitly for beta+ milestones
- Read-only on inputs (the optional milestone doc append is the only write, with explicit approval)

---

## Examples

`/milestone-review beta`
- 7 epics in scope, 5 at 100%, 2 at 70-80%
- 1 Critical bug (paywall receipt loop), 4 High
- TTI Home failing (1100ms vs. 800ms target)
- ATT prompt not implemented yet
- Verdict: NO-GO
- Recommendation: 1 sprint focused on the Critical bug, ATT, and TTI; restage beta by 1 week

`/milestone-review alpha`
- 4 epics, all 100%
- 0 Critical, 2 High (planned for next sprint)
- All P0 ADRs Accepted
- Verdict: GO
- Recommend: lock scope; start beta-track work
