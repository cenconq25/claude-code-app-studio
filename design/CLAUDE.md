# Design Directory

Product design lives here. The directory has three subtrees, each with a
distinct owner and a distinct kind of artefact.

## Subtrees

### `design/prd/`
Product Requirements Documents — one per feature. Owned by
`product-designer` and authored via `/prd-create`. Every PRD has the 11
required sections defined in `.claude/rules/design-docs.md`. PRDs use
stable IDs (`PRD-AUTH-003`) and stable requirement tags (`REQ-1`,
`REQ-2`) so other artefacts can cite them.

The product brief at `design/prd/00-product-brief.md` is the master
document. Personas live at `design/prd/personas.md`. Both are
references, not features.

### `design/flows/`
User-journey documents — one per flow. Owned by `ux-designer` and
authored via `/flow-create`. A flow is a multi-step task the user can
accomplish: sign-in, checkout, create-listing, password-reset.

Each flow doc has eight required sections: entry points, primary path,
alternate paths, error paths, permissions, offline behaviour, exit
points, accessibility notes.

### `design/registry/`
Canonical names for screens, data models, API endpoints, analytics
events, and feature flags. The registry is the tiebreaker when two PRDs
disagree on a name. See `design/registry/README.md` for details.

## Adjacent Artefacts (Not Subtrees)

- `design/comps/` — visual comps from `visual-design-director`.
  Optional. Many teams keep comps in Figma and link from PRDs instead
  of duplicating them in the repo. If you keep them in-repo, organise by
  feature.
- `design/research/` — interview notes, usability test reports.
  Created by `user-researcher`. Stored as plain Markdown with one file
  per session.
- `design/content/` — content strategy assets: voice and tone guide,
  vocabulary list, banned terms, push notification copy templates.
  Owned by `content-strategist` and `content-designer`.
- `design/motion/` — motion specs and reference clips. Owned by
  `motion-designer`. Includes haptics patterns and audio cues.
- `design/brand/` — brand guidelines, logo system, marketing-vs-product
  alignment. Owned by `brand-director`.

These adjacent directories are created on demand. Do not pre-populate
them; create them when an artefact lands.

## Authoring Protocol

Every design artefact follows the collaborative pattern (see
`docs/COLLABORATIVE-DESIGN-PRINCIPLE.md`):

1. The agent asks clarifying questions.
2. The agent presents 2-4 options with trade-offs.
3. The user decides.
4. The agent drafts a section.
5. The user approves.
6. The agent writes to disk.
7. The agent updates `production/session-state/active.md` and proposes
   the next section.

Multi-section docs (PRDs, flows) use the **incremental writing**
pattern: write the skeleton first, then write each section as it is
approved. The conversation about completed sections can be safely
compacted; the decisions are on disk.

## Cross-References

PRDs cite ADRs (`See ADR-0007 for the session storage decision`).
ADRs cite PRDs by TR-ID (`Addresses TR-AUTH-001`). Stories cite both.
The graph is queryable: `/architecture-review` produces a traceability
matrix that maps every PRD requirement to at least one ADR and at least
one story.

## Review

Every PRD has a Review section that records gate verdicts:

```markdown
## Review

> **Product Director (PD-PRD)**: APPROVED 2026-05-12
> **Lead Designer (LD-PRD-DESIGN)**: APPROVED 2026-05-13
> **Accessibility (A11Y-AUDIT)**: APPROVED 2026-05-13 — see production/qa/evidence/a11y-prd-auth-003.md
```

Verdicts on artefacts are **the** record of approval. Do not rely on
chat history.
