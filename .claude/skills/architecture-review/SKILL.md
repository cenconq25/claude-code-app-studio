---
name: architecture-review
description: "Validates the architecture against all PRDs. Builds a traceability matrix from PRD requirements to ADRs, identifies coverage gaps, detects cross-ADR conflicts, and produces a PASS/CONCERNS/FAIL verdict. Run after Required ADRs are written; rerun whenever PRDs change. Read-only — never edits files."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Task
model: opus
---

# Architecture Review

Holistic check that every PRD requirement is covered by an ADR, that ADRs do not contradict each other, that the framework knowledge-cutoff risk is honored across all decisions, and that no architectural stance is silently broken.

Read-only. Outputs a structured verdict and traceability matrix.

---

## Purpose / When to Run

Run when:
- All P0 ADRs from the architecture's Required list are written
- A batch of PRDs changed (after `/propagate-design-change`)
- Before kicking off the first sprint
- Before a major release

Run in a **fresh session** — independent of any authoring context.

## Inputs

- `docs/architecture/architecture.md`
- All `docs/architecture/ADR-*.md`
- All `design/prd/*.md`
- `design/systems-index.md`
- `docs/framework-reference/<framework>/`
- `docs/architecture/architecture-registry.yaml` if present

## Outputs

- A printed report including a traceability matrix and verdict
- No file writes

---

## Phase 1: Pre-checks

- Confirm `docs/architecture/architecture.md` exists. Fail otherwise.
- Confirm at least 1 ADR with `Status: Accepted` exists. If none, run anyway but in degraded mode.

If running degraded, label the report header: "Degraded — no Accepted ADRs yet. This pass identifies coverage gaps only."

---

## Phase 2: Build the Traceability Index

For each PRD:
1. Extract all TR-IDs from Section 3 Detailed Requirements (`TR-<system>-NNN`)
2. Identify which ADRs reference each TR-ID by grepping `docs/architecture/ADR-*.md` for the TR-ID

Build a matrix:

```
| PRD | TR-ID | Requirement summary | Covered by | ADR Status |
|-----|-------|---------------------|------------|------------|
| auth.md | TR-auth-001 | OAuth login | ADR-0003 | Accepted |
| auth.md | TR-auth-002 | Token refresh | ADR-0003 | Accepted |
| auth.md | TR-auth-003 | Biometric unlock | — | UNCOVERED |
| paywall.md | TR-paywall-001 | Receipt validation | ADR-0009 | Proposed |
```

Categorize each row:
- **COVERED — Accepted** — TR-ID has at least one ADR with Status: Accepted addressing it
- **COVERED — Proposed** — TR-ID has an ADR but the ADR is still Proposed
- **UNCOVERED** — TR-ID has no ADR reference
- **OVER-COVERED** — TR-ID has multiple Accepted ADRs that may conflict

---

## Phase 3: Cross-ADR Conflict Detection

For each pair of Accepted ADRs in the same domain, scan for:
- **State ownership conflicts** — ADR-A claims `current_user` ownership; ADR-B also writes to it
- **Interface contradictions** — ADR-A defines event `userLoggedIn`; ADR-B uses `user_logged_in` for the same thing
- **Performance budget contradictions** — ADR-A claims 200ms cold start; ADR-B implies an SDK that adds 300ms
- **Deprecated-API references** — any ADR using an API listed in `docs/framework-reference/<framework>/breaking-changes.md` as deprecated

Each conflict becomes a finding.

---

## Phase 4: Architecture Doc Cross-Check

Verify every cross-cutting concern in `architecture.md` Sections 4-19 has either:
- An Accepted ADR, OR
- A pointer to a planned/Proposed ADR, OR
- An explicit deferral with reason ("not in v1")

Flag bare descriptions without ADRs in the architecture doc:
- "We use Sentry" with no ADR → MEDIUM finding (decision recorded only in arch doc, not as a tracked ADR)

---

## Phase 5: Framework Knowledge-Cutoff Audit

Read `docs/framework-reference/<framework>/VERSION.md` for the risk level.

If MEDIUM/HIGH:
- For every ADR, check the `Framework Compatibility` table
- Flag any ADR with empty or "Unknown" Verification Required for a HIGH-risk domain → HIGH finding
- Flag any ADR using post-cutoff APIs that are not listed in Framework Compatibility → HIGH finding

---

## Phase 6: Mobile Cross-Cutting Checks

These checks are mobile-specific and often skipped. Each absence is a finding.

- **Account deletion** — App Store guideline 5.1.1(v) and Play policy require an in-app deletion path. Is there a PRD or ADR addressing this?
- **App Tracking Transparency (iOS)** — if any tracking is described, is there an ADR for the ATT prompt timing and copy?
- **Play Data Safety / iOS Privacy nutrition labels** — is there a PRD section or ADR governing what data is collected and how it is declared?
- **Push token rotation** — does the push ADR address rotation?
- **Receipt validation** — for any IAP, is server-side validation specified?
- **Background task limits** — does the background ADR respect iOS BGTaskScheduler limits and Android Doze constraints?
- **Deep link auth gating** — does the navigation ADR specify what happens to deep links when the user is logged out?
- **Min OS** — are min OS versions consistent across PRDs and ADRs?
- **App size impact** — is the architecture aware of bundle size budget?

Each missing item: HIGH if regulatory / store-policy; MEDIUM otherwise.

---

## Phase 7: Optional Specialist Synthesis

Spawn `Task` to:
- `mobile-architect` — read the matrix and flag missed coverage or strategic concerns
- Framework specialist — validate post-cutoff API claims and breaking-changes entries

The reviewer integrates the findings.

---

## Phase 8: Verdict

Tally:
- **CRITICAL** — UNCOVERED v1 TR-ID, store-policy gap (account deletion missing), regulatory gap (data safety), framework-deprecated API in Accepted ADR
- **HIGH** — interface contradictions between Accepted ADRs, P0 ADR still Proposed, missing knowledge-cutoff verification
- **MEDIUM** — over-coverage requiring resolution, missing mobile cross-cutting addresses (push token rotation, etc.)
- **LOW** — cosmetic (naming inconsistency in ADR titles)

Verdict ladder:
- 0 CRITICAL, 0 HIGH → **PASS**
- 0 CRITICAL, ≤ 5 HIGH → **CONCERNS**
- 1+ CRITICAL or 6+ HIGH → **FAIL**

---

## Phase 9: Output

```
# Architecture Review

**Verdict: <PASS / CONCERNS / FAIL>**

## Coverage Summary
- Total PRD requirements: <N>
- Covered (Accepted): <N>
- Covered (Proposed): <N>
- Uncovered: <N>
- Over-covered: <N>

## Traceability Matrix
[abbreviated table — uncovered + Proposed-only rows highlighted]

## CRITICAL findings
1. <finding>
   Affecting: <PRD or ADR list>
   Fix: <specific action>

## HIGH findings
1. <finding>
   Fix: <action>

## MEDIUM findings
- <list>

## LOW findings
- <list>

## Strengths
- <what is well-covered>

## Recommended next steps
- For each CRITICAL: <action — e.g., write ADR for biometric unlock, address account deletion in a new PRD>
- After fixes: re-run `/architecture-review`
- For PASS: proceed to `/create-control-manifest` and then `/create-epics`
```

---

## Phase 10: Exit Notes

If PASS: tell the user the architecture is locked enough to proceed to epics. Suggest `/create-control-manifest` next.

If CONCERNS: list the 3 highest-leverage fixes the user should run, then re-run this skill.

If FAIL: refuse to proceed to epics; the team must close gaps first.

---

## Quality Gates

- Every uncovered v1 TR-ID is listed by ID and PRD
- Every conflict names both ADRs and the specific contradiction
- The verdict matches the tally rules
- Read-only — never modifies any file

---

## Examples

PASS run: 47 TR-IDs, 47 covered (44 Accepted, 3 Proposed in low-risk domains), 0 conflicts, 0 critical mobile gaps. Verdict: PASS. Recommend `/create-control-manifest`.

FAIL run: 47 TR-IDs, 41 covered, 6 uncovered (including biometric unlock and account deletion). 2 ADRs use deprecated APIs per breaking-changes.md. Verdict: FAIL. Recommend writing 4 missing ADRs and revising 2 existing ones.
