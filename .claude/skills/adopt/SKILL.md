---
name: adopt
description: "Brownfield onboarding for an existing mobile-app codebase. Audits PRDs, ADRs, stories, UX specs, and architecture docs for compatibility with this template's review skills, classifies gaps by impact, and produces a numbered migration plan. Use when joining a project mid-flight or upgrading from an older template version."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
model: sonnet
---

# Adopt — Brownfield Onboarding

Where `/project-stage-detect` answers "what exists?", this skill answers "will what exists actually work with `/design-review`, `/architecture-review`, `/story-readiness`, etc.?" Files can be present and still fail compliance because they lack the structured sections those reviewers expect.

This skill writes one file: `production/migration-plan.md`. The user runs the migration steps separately.

---

## Purpose / When to Run

Run when:
- Pulling into an existing mobile-app project for the first time
- Migrating from an earlier version of this template
- The user has many artifacts but several review skills throw "missing section" errors
- Preparing to hand the project to a new contributor and wanting to know what is broken

Distinct from `/project-stage-detect` (existence check) and `/onboard` (per-role context summary).

## Inputs

- All design, architecture, production, and ux artifacts on disk
- `.claude/docs/technical-preferences.md` (framework pin)

## Outputs

- `production/migration-plan.md` — numbered, prioritized list of fixes
- A printed summary

---

## Phase 1: Inventory

Glob and read (sample, not full):
- `design/concept.md`
- `design/design-bible.md`
- `design/prd/*.md`
- `design/ux/*.md`
- `design/systems-index.md`
- `docs/architecture/architecture.md`
- `docs/architecture/ADR-*.md`
- `docs/architecture/control-manifest.md`
- `docs/architecture/tr-registry.yaml`
- `production/epics/*/EPIC.md`
- `production/epics/*/story-*.md`

Count each. Print the inventory before doing the audit.

---

## Phase 2: Compliance Audit

For each artifact type, check against the template's required structure. Compliance is **per-section** — partial credit is allowed. Classify gaps as:

- **CRITICAL** — review skills will crash or refuse to run
- **HIGH** — review skills will run but produce useless output (missing traceability)
- **MEDIUM** — degraded but usable
- **LOW** — cosmetic

### 2a: Concept doc (`design/concept.md`)

Required sections (grep): `One-liner`, `Target User`, `Core Promise`, `MVP Scope`, `Primary Metric`, `Tone`, `Monetization Stance`, `Riskiest Assumption`.
- Missing One-liner / Target User / Primary Metric: HIGH
- Missing other sections: MEDIUM

### 2b: PRDs (`design/prd/*.md`)

Required sections per PRD (grep): `Overview`, `User Goal`, `Detailed Requirements`, `Edge Cases`, `Dependencies`, `Configurable Values`, `Acceptance Criteria`, `Accessibility`.
- Missing Acceptance Criteria: CRITICAL (`/prd-review` and `/create-stories` cannot run)
- Missing Edge Cases / Dependencies: HIGH
- Missing Accessibility: HIGH for any UI-touching system, MEDIUM otherwise
- Each requirement should have a `TR-<system>-NNN` ID: missing IDs → HIGH (traceability lost)

### 2c: UX specs (`design/ux/*.md`)

Required sections: `Screen Goal`, `User Flow`, `Layout`, `States`, `Empty / Loading / Error`, `Accessibility`, `Platform Notes`, `Implementation Hooks`.
- Missing States or Empty/Loading/Error: HIGH (mobile apps live in these states)
- Missing Accessibility: HIGH (WCAG 2.2 AA + platform conventions are template requirements)

### 2d: Architecture (`docs/architecture/`)

- `architecture.md` exists with sections: `Overview`, `Layers`, `Cross-cutting Concerns`, `Data Flow`, `Required ADR List`. Missing Required ADR List: HIGH.
- Each `ADR-*.md` must have: `Status`, `Date`, `Framework Compatibility`, `ADR Dependencies`, `Context`, `Decision`, `Alternatives`, `Consequences`, `PRD Requirements Addressed`. Missing Status: CRITICAL. Missing Framework Compatibility: HIGH (knowledge-cutoff risk unknown). Missing PRD Requirements Addressed: HIGH (traceability lost).
- `control-manifest.md` exists: if missing and ≥3 Accepted ADRs exist, MEDIUM.
- `tr-registry.yaml` exists: if missing and stories exist, HIGH.

### 2e: Stories (`production/epics/*/story-*.md`)

Required for each story:
- `> **Status**:` line
- `> **Type**:` line (Logic / Integration / Visual / UI / Config)
- Embedded TR-ID reference
- Embedded ADR reference (or explicit "no ADR — quick design embedded")
- `## Acceptance Criteria`
- `## Test Evidence Path`

Missing Status or Acceptance Criteria: CRITICAL.
Missing Type: HIGH (`/story-done` cannot pick the right gate).
Missing TR-ID or ADR: HIGH (drift risk).

### 2f: Framework reference

- `.claude/docs/technical-preferences.md` Framework field still `[TO BE CONFIGURED]` AND code clearly uses a framework: HIGH.
- `docs/framework-reference/<name>/VERSION.md` missing while code uses that framework: MEDIUM.

---

## Phase 3: Classify and Group

Group findings by **artifact type** and **severity**. Within each severity tier, sort by:
1. Files referenced by other artifacts (a broken upstream PRD blocks downstream stories — fix first)
2. Files most-referenced by review skills

For each finding, record:
- File path
- Severity (CRITICAL / HIGH / MEDIUM / LOW)
- Specific gap (e.g., "missing `## Acceptance Criteria` heading")
- Suggested fix skill (e.g., `/design-system retrofit design/prd/auth.md`)

---

## Phase 4: Present Findings & Confirm Scope

Show the user a summary table:

```
## Compliance Audit Summary

| Artifact | Total | Compliant | Critical | High | Medium |
|----------|-------|-----------|----------|------|--------|
| Concept doc | 1 | 0 | 0 | 1 | 0 |
| PRDs | 5 | 2 | 1 | 2 | 0 |
| UX specs | 8 | 4 | 0 | 3 | 1 |
| ADRs | 4 | 1 | 1 | 2 | 0 |
| Stories | 23 | 18 | 2 | 3 | 0 |
| Framework ref | 0 | 0 | 0 | 1 | 0 |
```

Then list every CRITICAL and HIGH issue with file path + specific gap + recommended fix.

Use `AskUserQuestion`:
- **Prompt**: "Want a written migration plan covering these fixes?"
- **Options**:
  - `Yes — full plan (CRITICAL + HIGH + MEDIUM)`
  - `Yes — minimal plan (CRITICAL + HIGH only)`
  - `No — just show me the summary`

---

## Phase 5: Write Migration Plan

If the user said yes, write `production/migration-plan.md`:

```markdown
# Migration Plan

> Generated: [date]
> Scope: [Full / Minimal]
> Total fixes: [N]

## Phase A — Unblock review skills (CRITICAL)
Fixes here let `/prd-review`, `/architecture-review`, `/story-readiness`, and `/story-done` actually run.

1. **[file path]** — [gap]
   - Fix: `/design-system retrofit [path]` (or specific manual step)
   - Why: `/prd-review` will fail without `## Acceptance Criteria`.

[... numbered list ...]

## Phase B — Restore traceability (HIGH)
Fixes here let cross-document review (`/architecture-review`, `/review-all-prds`) produce useful output.

[... numbered list ...]

## Phase C — Polish (MEDIUM)
Quality-of-life fixes — not blocking.

[... numbered list ...]

## Recommended order

1. Run all of Phase A first.
2. After Phase A is clear, run `/review-all-prds` and `/architecture-review` to verify the fixes worked.
3. Then proceed with Phase B.
4. Phase C can be done lazily during normal work.
```

Ask: "May I write this plan to `production/migration-plan.md`?"

---

## Phase 6: Hand Off

After writing:
- Print: "Migration plan written. Start with Phase A item 1: run `[first fix command]`."
- Suggest running `/project-stage-detect` after Phase A is complete to confirm stage classification has improved.
- If framework was a HIGH finding: insist that `/setup-framework` runs first, since several review skills rely on the framework reference docs.

---

## Quality Gates

- The plan must list a **specific fix command** for every CRITICAL and HIGH item — never just "fix this manually" with no path.
- The plan must order Phase A by upstream-first (PRDs before stories that reference them).
- If no findings are CRITICAL or HIGH, output "Project is compatible with all template skills." and skip writing the plan.

---

## Examples

Project has 5 PRDs; one is missing `## Acceptance Criteria`. 23 stories; 2 have no `Status` line. ADRs all present but one lacks `Framework Compatibility`.

Audit verdict:
- 1 CRITICAL (missing Acceptance Criteria — `/prd-review` will fail)
- 1 CRITICAL (2 stories missing Status — `/story-done` cannot resolve them)
- 1 HIGH (ADR missing Framework Compatibility — knowledge-gap risk untracked)

Migration plan:
- Phase A.1: `/design-system retrofit design/prd/billing.md`
- Phase A.2: manually add `> **Status**: Ready` to the two stories
- Phase B.1: `/architecture-decision retrofit docs/architecture/ADR-0003-payment.md`
