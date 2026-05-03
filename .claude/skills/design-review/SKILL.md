---
name: design-review
description: "Reviews any design document — concept doc, design bible, flow spec, or other architecture-adjacent design artefact — for completeness, internal consistency, and implementability. Detects PRDs and routes them to /prd-review. Use this when the doc is NOT a PRD; for PRD validation, use /prd-review directly."
argument-hint: "<path-to-design-doc>"
user-invocable: true
allowed-tools: Read, Glob, Grep, Task
model: sonnet
---

# Design Review (Generic)

The general-purpose design-document validator. Use this when the artefact
is *not* a PRD — concept docs, design bibles, flow specs, journey maps,
narrative briefs, etc. For PRDs, route to `/prd-review` (this skill will
detect that case and tell you).

Read-only on the source doc. Outputs a verdict + blockers list.

---

## Boundary vs `/prd-review`

| Doc type | Use |
|---|---|
| `design/prd/*.md` | `/prd-review` (specialised PRD validator) |
| `design/concept.md` | `/design-review` (concept-doc rules) |
| `design/design-bible.md` | `/design-review` (visual-system rules) |
| `design/flows/*.md` | `/design-review` (flow-spec rules) |
| `design/ux/*.md` | `/ux-review` (defer there) |
| Anything else under `design/` | `/design-review` |

If the user invokes this skill on a `design/prd/*.md` path, Phase 1 detects
that and recommends `/prd-review` instead — does not duplicate the PRD
validator's work.

---

## Purpose / When to Run

Run when:
- A non-PRD design doc has been authored or revised and needs a sanity
  pass before downstream work depends on it.
- A concept doc was just produced by `/brainstorm`.
- A design bible was just produced by `/design-bible`.
- A flow spec was extracted via `/reverse-document`.

Always run in a fresh session — independent of authoring context.

---

## Inputs

- Path to the design doc.
- `design/concept.md` for cross-reference.
- `design/registry/entities.yaml` for entity consistency.
- `.claude/docs/technical-preferences.md` (constraints).
- For UI-related docs: `design/design-bible.md`.

---

## Outputs

- A printed verdict: APPROVED / APPROVED WITH NOTES / NEEDS REVISION /
  MAJOR REVISION.
- A blockers + warnings list with section references.
- Optional `<path>.review.md` snapshot.

---

## Phase 1: Detect Doc Type and Dispatch

Inspect the path and the file's first 30 lines:

- If path matches `design/prd/*.md` OR file contains a `## Detailed
  Requirements` section with `TR-` IDs → **this is a PRD**. Stop and
  recommend `/prd-review <path>`. Do not duplicate that skill's
  checks.
- If path matches `design/ux/*.md` OR file is a UX spec → recommend
  `/ux-review <path>`. Stop.
- If path is `design/concept.md` → use **concept-doc rules** (Phase 3a).
- If path is `design/design-bible.md` → use **design-bible rules**
  (Phase 3b).
- If path matches `design/flows/*.md` → use **flow-spec rules**
  (Phase 3c).
- Otherwise → use **generic design-doc rules** (Phase 3d) and warn the
  user that the rule set is not specialised.

The detection result drives Phase 3.

---

## Phase 2: Read Context

Always read:
- The target doc in full.
- `design/concept.md` (unless the target IS the concept doc).
- `design/registry/entities.yaml` for cross-reference.

For UI-bearing docs additionally read `design/design-bible.md`.

---

## Phase 3: Run Type-Specific Checks

### 3a: Concept doc rules

Required sections (per `/brainstorm`): Premise, Persona, JTBD, Pillars,
Anti-features, Primary Metric, Riskiest Assumption, Constraints.

Quality:
- Premise is one specific sentence (not vague aspiration).
- Persona has a name, a goal, and a current alternative.
- JTBD has when/who/alternative parts.
- Pillars are 3-5 specific design commitments.
- Anti-features list at least 3 things the product will NOT do.
- Primary Metric is measurable (not "engagement" — must be specific).
- Riskiest Assumption is the single thing that, if false, kills the
  product.

### 3b: Design-bible rules

Required sections (per `/design-bible`): Tone, Color, Typography,
Spacing, Iconography, Motion, Imagery, Voice, Component archetypes,
Density, Edge cases, Accessibility, Reference apps.

Quality:
- Color tokens have semantic names AND raw values.
- Typography defines a clear scale with line-heights.
- Motion section gives durations + easing curves.
- Accessibility section addresses contrast, hit targets, motion-reduce,
  dynamic type, color-blind safety.

### 3c: Flow-spec rules

Required: trigger, primary path (numbered steps), error paths, success
state, abandonment state, analytics events per step.

Quality:
- Each step names the screen and the user action.
- Every error path resolves to a recoverable state or an explicit
  unrecoverable terminal.
- No "user retries" without specifying retry behavior.

### 3d: Generic design-doc rules

For unknown doc types:
- Has a clear purpose stated up top.
- Sections are titled and numbered or otherwise navigable.
- Cross-references resolve (linked files exist).
- No `[TBD]` / `[TODO]` left.
- Terminology matches the project glossary (CLAUDE.md) and registry.

Warn the user that the rule set is non-specialised and recommend adding a
template for this doc type if it's a recurring artefact.

---

## Phase 4: Cross-Reference Checks (all types)

- Every entity referenced exists in the registry, OR is declared inside
  this doc.
- Every linked file exists.
- The doc does not contradict the concept's anti-features.
- Terminology aligns with the glossary in `app_dev/CLAUDE.md`.

---

## Phase 5: Optional Specialist Cross-Check

- Concept docs → optionally spawn `product-director` for strategic
  alignment.
- Design bibles → optionally spawn `visual-design-director`.
- Flow specs → optionally spawn `interaction-designer`.

The specialist returns findings; the reviewer integrates them.

---

## Phase 6: Verdict and Output

Tally FAIL and WARN:
- 0 FAIL, 0 WARN → APPROVED
- 0 FAIL, 1-5 WARN → APPROVED WITH NOTES
- 0 FAIL, > 5 WARN → NEEDS REVISION
- 1-3 FAIL → NEEDS REVISION
- 4+ FAIL → MAJOR REVISION

Output:

```
# Design Review: <doc>

**Doc type detected: <concept | design-bible | flow-spec | generic>**
**Verdict: <APPROVED / NEEDS REVISION / MAJOR REVISION>**

## Blockers (FAIL)
1. <issue> — Section <N>
   Fix: <action>

## Warnings (WARN)
- <list>

## Strengths
- <list>

## Recommended next steps
- <type-specific guidance>
```

---

## Phase 7: Snapshot

Ask: "Write this review to `<path>.review.md`?"

---

## Quality Gates

- Verdict matches tally — no soft passes if FAILs exist.
- Phase 1 detection is non-negotiable — if the doc is a PRD, the skill
  defers and does not run PRD checks itself.
- The reviewer never edits the doc.
- Always runs in a fresh session.

---

## Examples

**Example 1 — PRD detection:**
`/design-review design/prd/auth.md`
Phase 1 detects PRD shape. Output: "This file is a PRD. Run
`/prd-review design/prd/auth.md` instead." Stops.

**Example 2 — concept doc:**
`/design-review design/concept.md`
Phase 3a runs. 1 FAIL (Primary Metric is "engagement" — not measurable).
Verdict: NEEDS REVISION. Recommend rerunning `/brainstorm` to refine
Section 5.

**Example 3 — design bible:**
`/design-review design/design-bible.md`
Phase 3b runs. 0 FAIL, 2 WARN (motion durations missing easing curves;
contrast ratio not declared for tertiary text). Verdict: APPROVED WITH
NOTES.

---

## Constraints

- Read-only on the source doc.
- Always defers to `/prd-review` for PRDs and `/ux-review` for UX specs.
- The reviewer never silently fixes — surfaces issues for the author.
