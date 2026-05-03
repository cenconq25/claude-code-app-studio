# Docs Directory

Technical documentation lives here. The directory has four subtrees, each
with its own audience and authoring conventions.

## Subtrees

### `docs/architecture/`
The master architecture document, ADRs, and the control manifest. Owned
by `mobile-architect`. Use the ADR template under
`.claude/docs/templates/architecture-decision-record.md` for new
decisions.

**Required ADR sections**: Title, Status, Context, Decision, Consequences,
ADR Dependencies, Framework Compatibility, PRD Requirements Addressed.

**Status lifecycle**: `Proposed` → `Accepted` → `Superseded`. Stories
may not reference `Proposed` ADRs — `/story-readiness` blocks them.

**TR Registry**: `docs/architecture/tr-registry.yaml` — stable IDs that
link PRD requirements (`PRD-AUTH-003.REQ-2`) to ADRs and stories.
Append-only. Never renumber.

**Control Manifest**: `docs/architecture/control-manifest.md` — flat
programmer rules sheet (Required / Forbidden / Guarded per layer),
date-stamped. Stories embed the manifest version they were planned
against. `/story-done` flags stale-manifest stories.

Run `/architecture-review` after a batch of ADRs to validate that every
PRD requirement is covered and that ADRs do not contradict each other.

### `docs/framework-reference/`
Version-pinned snapshots of the chosen framework's APIs. Always check
here before using any framework API — the LLM's training data predates
the pinned version. Each framework has its own subdirectory with a
`VERSION.md` file documenting the pinned version and verified docs.

The currently active framework is recorded in
`.claude/docs/technical-preferences.md`. The corresponding
`docs/framework-reference/[framework]/VERSION.md` is the canonical
reference.

### `docs/registry/`
Cross-document entity registry — canonical names for screens, data
models, API endpoints, analytics events, and user-facing concepts. See
`docs/registry/README.md` for the schema.

When two PRDs disagree on a name, the registry wins; raise an issue
against the older PRD.

### `docs/examples/`
Reference snippets, example PRDs, example ADRs, and miniature
end-to-end flows for new contributors to learn from. Examples are not
contracts — do not copy them blindly.

## Top-level Docs

- `COLLABORATIVE-DESIGN-PRINCIPLE.md` — Question → Options → Decision →
  Draft → Approval. The interaction protocol every agent follows.
- `WORKFLOW-GUIDE.md` — Phase-by-phase walk through the full lifecycle
  from Discovery to Live Ops, with example skill invocations.

## Authoring Standards

- All docs use Markdown.
- Code samples in docs use fenced blocks with a language tag.
- Internal links use file-relative paths (`./architecture/adr-0001.md`),
  not absolute paths.
- Date-stamped docs (changelogs, release notes) include an ISO-8601 date
  in the frontmatter.
- All docs that reference the framework declare the version they assume
  in their preamble (e.g., "Verified against React Native 0.76, Expo SDK 52").
