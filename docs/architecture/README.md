# Architecture

This directory holds the master architecture document, all Architecture
Decision Records (ADRs), the technical-requirements registry, and the
control manifest.

## Files

| File | Purpose |
|---|---|
| `architecture.md` | The master architecture document. One per project. Authored via `/setup-framework` plus `/architecture-decision` chain. |
| `adr-NNNN-[slug].md` | Architecture Decision Records, numbered sequentially from 0001. |
| `tr-registry.yaml` | Stable Technical-Requirement IDs. Append-only — never renumber. |
| `control-manifest.md` | Flat programmer rules sheet derived from accepted ADRs. Date-stamped. |

## Authoring an ADR

Use `/architecture-decision`. It walks through Context, Decision, and
Consequences section by section, drafts an ADR, and submits it for
review (gate `MA-ADR`).

ADR template fields:

- **Title** — one short sentence.
- **Status** — `Proposed` → `Accepted` → `Superseded`.
- **Date** — ISO-8601.
- **Author** — agent or human name.
- **Context** — the problem and the constraints.
- **Decision** — the chosen approach, in declarative voice.
- **Consequences** — positive, negative, and neutral implications.
- **Alternatives Considered** — at least two, with reasons rejected.
- **ADR Dependencies** — IDs of ADRs this depends on or contradicts.
- **Framework Compatibility** — pinned framework version + post-cutoff risk.
- **PRD Requirements Addressed** — TR-IDs from `tr-registry.yaml`.
- **Open Questions** — anything left unresolved with a decision date.

## TR Registry

`tr-registry.yaml` keeps stable IDs that survive renaming. Format:

```yaml
- id: TR-AUTH-001
  prd: design/prd/email-signin.md
  prd_req: REQ-2
  description: "Session expires after 14 days of inactivity"
  adrs: [ADR-0007]
  stories: [STORY-S1-12, STORY-S1-15]
- id: TR-AUTH-002
  prd: design/prd/email-signin.md
  prd_req: REQ-3
  description: "Refresh tokens stored in Keychain/Keystore"
  adrs: [ADR-0007, ADR-0011]
  stories: []
```

Append entries; never renumber. The registry is updated by
`/architecture-review` and read by `/story-readiness`.

## Control Manifest

`control-manifest.md` is a flat checklist derived from all accepted
ADRs, suitable for stamping into story files. Format:

```markdown
# Control Manifest
> Manifest Version: 2026-05-12-001

## Required (per layer)

### Domain
- All entities are immutable structs/data classes.
- ...

### Repository
- All repository methods are suspending/async.
- ...

## Forbidden

- Direct fetch in views.
- ...

## Guarded

- Adding a third-party SDK requires a new ADR.
- ...
```

Stories embed the manifest version they were planned against. When
`/story-done` runs against a story whose manifest version is older
than the latest, it surfaces drift and asks whether to re-plan.

## Validation

Run `/architecture-review` after each batch of ADRs. It produces:

1. A traceability matrix mapping every PRD requirement to at least one
   ADR.
2. A list of `Proposed` ADRs that are blocking stories.
3. A conflict report (two ADRs that contradict).
4. A framework-version risk report (ADRs touching post-cutoff APIs).
