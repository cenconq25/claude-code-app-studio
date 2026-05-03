---
paths:
  - "design/**"
---

# Design Document Rules

Owner: `product-designer` (PRDs), `lead-designer` (system-level docs),
`ux-designer` (flows). Reviewers: `lead-designer`, `accessibility-specialist`.

## Required Sections (PRDs)

Every PRD in `design/prd/` includes these eleven sections, in order. The
section headings must match exactly so cross-referencing tools can find
them. A PRD with missing sections fails `validate-commit.sh`.

1. **Overview** — one paragraph: what, why, success metric.
2. **User Goal & Job-To-Be-Done** — the user's intent in their words.
3. **Detailed Requirements** — unambiguous, numbered functional rules.
4. **Flows** — primary path plus error/edge paths, linked to
   `design/flows/[feature].md`.
5. **Edge Cases** — explicitly enumerated weird states (offline, denied
   permission, expired token, low battery, locale fallback).
6. **Dependencies** — other PRDs, ADRs, third-party SDKs, backend endpoints.
7. **Tunables / Remote Config** — flags, thresholds, A/B knobs and defaults.
8. **Acceptance Criteria** — testable, in `Given / When / Then` form.
9. **Analytics & Telemetry** — events emitted, properties, success metric.
10. **Accessibility** — WCAG/A11y requirements specific to this feature.
11. **Localization Notes** — pluralization, RTL, longest-string fitting,
    locale-specific formats.

## Required Sections (Flow Docs)

Every flow doc in `design/flows/` includes:

1. **Entry points** — every place this flow can begin from.
2. **Primary path** — the happy path step by step.
3. **Alternate paths** — branches the user might take.
4. **Error paths** — what happens at each failure mode.
5. **Permissions** — when each system permission is requested and why.
6. **Offline behaviour** — cache, queue, block, or degrade.
7. **Exit points** — where the user lands after success or cancellation.
8. **Accessibility notes** — focus order, screen-reader script.

## Required for All Design Docs

- Every PRD has a unique slug (`design/prd/[feature-slug].md`) and a
  stable ID in its frontmatter (`id: PRD-AUTH-003`).
- Cross-references use IDs (`PRD-AUTH-003`, `ADR-0007`,
  `STORY-S5-12`), never relative file links — IDs survive moves.
- Every numbered requirement gets a tag like `REQ-1`, `REQ-2` so stories
  can cite them.
- Acceptance criteria are individually testable and use the same format
  for every PRD: `Given X, when Y, then Z`.
- Requirements never describe implementation. ("The button uses a
  `Pressable`" is wrong; "the action confirms before destructive
  effect" is right.)

## Style

- One feature per PRD. Bundles produce ambiguity.
- Lead with the user's perspective; product-direction reasoning lives in
  Overview, not in Requirements.
- Use plain language. If a domain term is necessary, link it to a
  glossary entry in `design/registry/glossary.md`.
- Show tables when comparing variants, options, or platform behaviours.

## Forbidden

- Implementation details in Requirements. Implementation lives in ADRs
  and stories.
- Acceptance criteria like "the screen looks good" or "feels fast".
  Translate to measurable: contrast >= 4.5:1; cold start <= 1.5s.
- Speculation about the next feature. Future scope belongs in the
  product roadmap, not in a PRD.

## Review Trail

Every PRD ends with a Review section. Each gate adds a line:

```markdown
## Review

> **Product Director (PD-PRD)**: APPROVED 2026-05-12
> **Lead Designer (LD-PRD-DESIGN)**: APPROVED 2026-05-13 — design comps in design/comps/auth/
> **Accessibility (A11Y-AUDIT)**: APPROVED 2026-05-13
```
