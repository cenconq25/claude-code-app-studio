---
name: project-stage-detect
description: "Read-only audit that classifies the project's current stage (concept / design / architecture / sprint / beta / live-ops), identifies missing artifacts, and recommends the next sensible skill. Use when the user asks 'where are we', 'what stage are we in', or after pulling an unfamiliar branch."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Glob, Grep
model: haiku
---

# Project Stage Detection

Read-only. This skill never writes a file — it inspects what is on disk and produces a stage verdict plus a gap list. The user runs follow-up skills based on the recommendation.

---

## Purpose / When to Run

Run when:
- A new collaborator joins the project
- The user types "where are we", "what stage", or "audit"
- After a long break to re-orient before picking up work
- Before running `/adopt`, which goes deeper into format compliance

Distinct from `/adopt`: this skill checks **what exists**; `/adopt` checks **whether what exists is compatible** with the template's other skills.

## Inputs

- The entire repo on disk — globs and reads only

## Outputs

- A printed report. No files written.

---

## Phase 1: Inventory the Artifacts

Run these checks silently first. Build a fact table.

### 1a: Concept

- `design/concept.md` exists?
- Does it contain at least the eight sections from `/brainstorm`'s template? Grep for headings: `One-liner`, `Target User`, `Core Promise`, `MVP Scope`, `Primary Metric`, `Tone`, `Monetization Stance`, `Riskiest Assumption`.

### 1b: Framework setup

- Read `.claude/docs/technical-preferences.md`. Is the Framework field still `[TO BE CONFIGURED]`?
- Glob `docs/framework-reference/*/VERSION.md` — is a framework reference populated?
- Detect actual code: `package.json` (RN/JS), `pubspec.yaml` (Flutter), `*.xcodeproj` (iOS native), `app/build.gradle` (Android native).

### 1c: Design Bible

- `design/design-bible.md` exists?
- Does it list color, type, space, radius, elevation, motion tokens? Grep section headings.

### 1d: Systems / PRDs

- Count `design/prd/*.md`.
- `design/systems-index.md` exists?
- For each PRD, grep for the eight required PRD sections. Count incomplete ones.

### 1e: UX

- Count `design/ux/*.md`.
- For each, check for: Screen Goal, User Flow, Screen Layout, States, Empty/Loading/Error, Accessibility, Platform Notes, Implementation Hooks.

### 1f: Architecture

- `docs/architecture/architecture.md` exists?
- Count `docs/architecture/ADR-*.md`.
- For each ADR, grep for `## Status`. Count Accepted vs Proposed.
- `docs/architecture/control-manifest.md` exists?
- `docs/architecture/tr-registry.yaml` exists?

### 1g: Production

- Count `production/epics/*/EPIC.md`.
- Count story files: `production/epics/*/story-*.md`.
- For each story, grep `> **Status**:` — count Ready / In Progress / Blocked / Complete.
- Count sprint plans: `production/sprints/*.md`.
- Count milestone docs: `production/milestones/*.md`.

### 1h: Tests & evidence

- Count files in `tests/unit/`, `tests/integration/`.
- Glob `production/qa/evidence/*.md`.

### 1i: Live signal

- Glob `production/releases/*.md` for shipped releases.
- Glob `production/live-ops/` for any post-launch artifacts.

---

## Phase 2: Classify the Stage

Apply this decision ladder, top to bottom. Pick the **highest** stage where the entry criteria are fully met. If the criteria are partially met, the stage is "transitioning into" the next.

| Stage | Entry Criteria |
|---|---|
| **Empty** | No concept, no framework, no code |
| **Concept** | `design/concept.md` exists with most required sections |
| **Setup** | Concept exists AND framework is pinned in technical-preferences.md |
| **Design** | Setup complete AND `design/systems-index.md` exists AND ≥1 PRD is complete |
| **Architecture** | Design complete AND `docs/architecture/architecture.md` exists AND ≥1 Accepted ADR |
| **Pre-production** | Architecture complete AND `control-manifest.md` exists AND ≥1 UX spec |
| **Sprint / Production** | ≥1 epic decomposed into stories AND ≥1 story marked In Progress or Complete AND a sprint plan exists |
| **Beta** | Production stage AND ≥1 release artifact OR ≥1 beta-tagged sprint OR `TestFlight`/internal-track release noted |
| **Live-ops** | A release artifact in `production/releases/` exists AND files present in `production/live-ops/` |

---

## Phase 3: Identify Gaps

Within the determined stage, list:

- **Hard gaps** — required artifacts missing for the current stage
- **Soft gaps** — recommended artifacts missing
- **Forward gaps** — what is needed to advance to the next stage

Examples:
- Stage: Design. Hard gap: 2 of 5 PRDs are incomplete. Soft gap: no `design/design-bible.md`. Forward gap: no architecture doc yet.
- Stage: Sprint. Hard gap: 3 stories without ADR references. Soft gap: no test evidence written. Forward gap: no release plan.

---

## Phase 4: Print the Report

Output a single readable report:

```
# Project Stage Report

**Detected stage:** [name]
**Confidence:** [HIGH / MEDIUM — explain]

## What is in place
- [bullets — concept doc, 4 PRDs, 3 ADRs, etc.]

## Hard gaps (block the current stage)
- [bullets, each with a recommended skill]

## Soft gaps (recommended but not blocking)
- [bullets]

## To advance to [next stage]
- [bullets — specific skills to run, in order]

## Recommended next action
> Run `/[skill]` — [why]
```

The recommended next action must be the single most-valuable skill for the user to run right now. Pick exactly one. Do not list five.

---

## Phase 5: Suggest Deeper Audit If Needed

If the project has many artifacts but several PRDs/ADRs are incomplete, end with:
> "If you want to know whether existing files will actually work with the template's review skills (not just whether they exist), run `/adopt` next."

If the project is empty:
> "Run `/start` for guided onboarding."

If the project is mid-sprint:
> "Run `/sprint-status` for a fast progress snapshot."

---

## Quality Gates / Verdict

This skill produces a **stage** verdict, not pass/fail. Confidence is HIGH if every check in the stage's entry criteria is unambiguous; MEDIUM if any check was ambiguous (e.g., PRD exists but its sections are incomplete).

If confidence is MEDIUM, surface the specific ambiguity ("PRD `auth.md` exists but is missing 3 of 8 required sections — counted as 'incomplete' for this report").

---

## Examples

Empty repo: stage = Empty. Recommended next action: `/start`.

Repo with concept doc, framework pinned to React Native, two PRDs (one complete, one stub), no architecture doc: stage = Design (transitioning). Hard gaps: incomplete PRD, no `systems-index.md`. Recommended: `/map-systems` or `/design-system <stub-name>`.

Repo with full design and 4 ADRs but no stories: stage = Pre-production. Forward gap: no epics. Recommended: `/create-epics`.

---

## Constraints

- Read-only — never write, edit, or modify any file
- Never claim a stage that the criteria do not meet — if in doubt, downgrade and explain
- Do not duplicate `/adopt`'s job; if the user wants format-compliance checking, point them there
