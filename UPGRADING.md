# Upgrading the App Studios Template

This guide explains how to move a project from one version of the App
Studios template to the next without losing the work that lives on top
of it. The template is the *substrate*: agents, skills, hooks, rules,
and reference docs. Your project is the *product*: PRDs, ADRs, sprint
state, source code, design tokens, release artefacts. Upgrades are
designed so the substrate can change while the product survives intact.

If anything in this guide conflicts with the version-specific notes
below, the version-specific notes win — they exist precisely because
some upgrades break the universal rules.

## Versioning Policy

The template uses [Semantic Versioning](https://semver.org/) across
template releases:

- **MAJOR** (`x.0.0`) — incompatible changes that require manual work
  on the consuming project. Examples: agent roster restructured, skill
  contract changed, hook protocol bumped, file paths renamed,
  framework-reference layout changed.
- **MINOR** (`0.x.0`) — additive changes that are backwards compatible.
  New agents, new skills, new optional hook scripts, new doc sections,
  new template files. A consuming project can ignore them and keep
  working.
- **PATCH** (`0.0.x`) — bug fixes, doc clarifications, prompt tweaks
  that do not change behaviour contracts.

The current template version is recorded at the top of each version
section in this file. The Git tag matching that version is the
authoritative reference.

**Current version: `0.1.0`** — initial MVP rewrite of the studio
template, retargeted from games to mobile apps. Treat anything from
`0.x.0` as pre-stable: minor versions may carry small breakages until
`1.0.0` ships.

## Authority Model

Three classes of files exist in a project that uses this template.
Knowing which class a file belongs to determines what an upgrade is
allowed to do with it.

| Class | Owner | Behaviour on upgrade |
|---|---|---|
| **Template-owned** | The template repo | Replaced wholesale. User edits to these files do not survive an upgrade. If you need to override behaviour, do it via `CLAUDE.local.md`, a project ADR, or a path-scoped rule overlay. |
| **Project-owned** | Your team | Never touched by an upgrade. The template never reads from these and never writes to them. Yours forever. |
| **Co-owned** | Both | Section-merged manually by the team running the upgrade. The template may add/replace certain sections; the team merges its own edits back in. The migration notes for each version list exactly which sections changed. |

The full file ownership table lives in **File Ownership** below.

## How to Upgrade

The template is consumed as a read-only authority. You do not `git pull`
into your project; you compare the new template snapshot against your
current one and merge changes manually. The flow:

1. **Pin your current version.** Make sure the current version recorded
   in this file matches the tag you originally cloned from. If you have
   never upgraded before, that is `0.1.0`.
2. **Clone the new template version into a side directory.** Use a
   throwaway location — for example, `~/scratch/app-studios-vX.Y.Z/`.
   Never overlay it directly on the project.
3. **Read this file in the new version.** Find the migration section
   for the version you are moving *to*, plus every intermediate version
   you skipped. Migration notes are cumulative — apply them in order.
4. **Diff `.claude/` from old to new.** Use a directory diff tool
   (`diff -r`, `meld`, `kdiff3`, `git diff --no-index`). Walk through
   each changed file:
   - **Template-owned file changed**: copy the new version over.
   - **Co-owned file changed**: merge by hand. Look for your team's
     edits, port them into the new structure.
   - **Project-owned file changed**: ignore — the template should not
     have touched it. If it did, file an issue against the template.
5. **Diff `docs/framework-reference/`.** New template versions may pin
   newer framework versions. Decide whether to upgrade the framework
   alongside the template or stay pinned. If you stay pinned, keep your
   existing `VERSION.md`. If you upgrade the framework too, it is a
   separate ADR and a separate sprint risk.
6. **Re-run `detect-gaps.sh`.** The hook will surface any new
   `[TO BE CONFIGURED]` slots introduced by the upgrade — for example,
   a new performance budget that did not exist in the previous version.
7. **Run the smoke skills.** `/help`, `/sprint-status`, `/scope-check`,
   `/project-stage-detect`. If any of them fail, the upgrade has not
   landed cleanly. Fix or roll back.
8. **Commit the upgrade as a single PR.** Title: `Upgrade App Studios
   template to v[X.Y.Z]`. Body: link the migration notes followed.
   Reviewers: `lead-developer`, `mobile-architect`, `producer`.
9. **Bump the version pin.** Update the `Current version` line in this
   file's migration history to the new version.

> **Where do my own edits live?** Anything you want to keep across
> upgrades belongs either in `CLAUDE.local.md` (untracked, per-developer)
> or in a project-owned file. Do not edit template-owned files in place;
> the next upgrade will overwrite you.

## Per-Version Migration Notes

Migration notes are written from the perspective of the version they
introduce. To upgrade from version `A` to version `Z`, read every entry
between `A` (exclusive) and `Z` (inclusive) and apply them in order.

### v0.1.0 — Initial MVP

This is the first published version of the App Studios template. It was
forked from the Game Studios template and retargeted at mobile-app
development. There is no prior version to migrate from inside this
repository, but if you are arriving from the Game Studios template the
shape change is dramatic and you should treat the move as a *port*, not
an upgrade. Highlights of what shifted:

- **Domain swap.** Engine → framework, GDD → PRD, level → flow, player
  → user, balance → tunables. The domain glossary in `CLAUDE.md`
  documents the full mapping.
- **Agent roster.** The 53 agents were reorganised around mobile
  delivery: product-director, mobile-architect, lead-developer,
  lead-designer, producer, plus department leads and per-framework
  specialists (RN, Flutter, iOS, Android).
- **Reference docs.** `docs/engine-reference/` became
  `docs/framework-reference/`. Per-framework `VERSION.md` files replace
  the single engine pin.
- **Test taxonomy.** Story types extended with Animation/Motion and
  Accessibility categories, with their own evidence requirements.

If this is your first upgrade reading, you can stop here — there is no
older version to compare to. Future versions will append a section
above this one.

### Breaking Changes

None applicable at `0.1.0`. Future major bumps document their breakages
here with the steps required to remediate.

## File Ownership

This table is canonical. If a file is not listed, default to
**Template-owned** unless the file lives under a project-owned root
(`design/`, `docs/architecture/`, `production/`, `src/`, `tests/`).

| Path | Class | Notes |
|---|---|---|
| `CLAUDE.md` | Co-owned | Template owns the structure and the `@.claude/docs/...` includes; project owns the `## Technology Stack` choices and any custom appended sections. |
| `CLAUDE.local.md` | Project-owned | Untracked; per-developer overrides. Never written by the template. |
| `README.md` | Co-owned | Template owns the boilerplate intro; project replaces the intro with the real product description after launch. |
| `LICENSE` | Project-owned | The project picks its license. The template ships a permissive default. |
| `UPGRADING.md` (this file) | Template-owned | Do not edit in place — your edits are overwritten on upgrade. File issues against the template if a change is needed. |
| `.gitignore` | Co-owned | Template owns the universal mobile/IDE ignores; project may append project-specific ignores below the marker. |
| `.github/CODEOWNERS` | Co-owned | Template ships the agent-role pattern map; project replaces agent labels with real GitHub handles. |
| `.github/PULL_REQUEST_TEMPLATE.md` | Template-owned | If you need to extend it, add a project-specific section in `CLAUDE.local.md` and reference it. |
| `.github/ISSUE_TEMPLATE/*` | Template-owned | Same rule — extend via separate templates rather than editing in place. |
| `.claude/agents/**` | Template-owned | All 53 agent definitions ship with the template. Customise via path-scoped rules under `.claude/rules/`, not by editing agents. |
| `.claude/skills/**` | Template-owned | Skills are versioned with the template. Add project-specific skills under a `.claude/skills/project/` subfolder if needed. |
| `.claude/hooks/**` | Template-owned | Edits here do not survive upgrades. Add new hooks rather than editing existing ones. |
| `.claude/rules/**` | Co-owned | Template ships the universal rules; project may add new rule files for its own paths. |
| `.claude/docs/**` | Template-owned (most) | Exception: `technical-preferences.md` is co-owned — the template owns the structure, the project owns every value. |
| `.claude/settings.json` | Co-owned | Template owns hook wiring; project may append permissions and env vars. Never delete template entries. |
| `.claude/agent-memory/**` | Project-owned | Per-agent scratch. Gitignored. Survives upgrades by virtue of not being tracked. |
| `docs/framework-reference/**` | Co-owned | Template provides the layout; the project owns its actual `VERSION.md` pin and any project-specific reference notes appended to the framework folder. |
| `docs/architecture/**` | Project-owned | All ADRs and the master architecture doc belong to the team. |
| `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` | Template-owned | The protocol itself; do not edit. |
| `docs/WORKFLOW-GUIDE.md` | Template-owned | The workflow doc; do not edit. |
| `design/**` | Project-owned | PRDs, flows, and registries are written by your team. |
| `src/**` | Project-owned | Your app. The template only writes a `src/CLAUDE.md` framework convention file via `/setup-framework`; that file is co-owned. |
| `tests/**` | Project-owned | All tests written by your team are yours. |
| `production/sprints/**` | Project-owned | Sprint plans, retros, and history. |
| `production/qa/**` | Project-owned | Test plans, evidence, smoke results, bug reports. |
| `production/releases/**` | Project-owned | Release notes, store metadata, certification artefacts. |
| `production/session-state/**` | Project-owned | Gitignored. Live session checkpoint. |
| `production/session-logs/**` | Project-owned | Gitignored. Audit trail. |

## What We Do Not Migrate

The template upgrade pipeline is intentionally narrow. It will never
touch the following — they survive any template version change:

- **PRDs** under `design/prd/`. Product specs are yours, full stop.
- **ADRs** under `docs/architecture/`. Architecture decisions are
  history; we do not rewrite history during a tooling upgrade.
- **Master architecture doc** at `docs/architecture/architecture.md`.
- **Sprint history**: every plan and retro under `production/sprints/`
  is preserved verbatim. New skills may produce new files alongside
  them; old files remain untouched.
- **QA evidence**: screenshots, recordings, smoke check results, bug
  reports under `production/qa/`.
- **Release artefacts** under `production/releases/`.
- **Session state and logs**: `active.md`, audit trails. These are
  gitignored to begin with and are local to whichever machine they were
  produced on.
- **Source code and tests** under `src/` and `tests/`.
- **Design assets** the project has imported — typography files, brand
  assets, icon sets — even if they live somewhere unusual.
- **`CLAUDE.local.md`** — per-developer overrides are sacred; the
  template never reads or writes this file.

If a future upgrade ever proposes to touch any of the above, treat it
as a bug in the template and refuse the change.

## Upgrade Failure Recovery

If an upgrade lands and the project breaks (skills error out, hooks
fail, agents cannot find their references), recover in this order:

1. **Read `production/session-state/active.md`** for the most recent
   known-good context.
2. **Diff your `.claude/` against the previous template tag.** Look for
   files you forgot to bring forward, or co-owned sections that were
   accidentally replaced wholesale.
3. **Roll back the upgrade commit.** A single PR makes this trivial:
   `git revert <upgrade-commit>`.
4. **File an issue against the template.** Capture the failure mode and
   the file diff that caused it. The migration notes for that version
   should grow to cover whatever case bit you.
5. **Re-attempt the upgrade** after the migration notes are corrected,
   following the standard flow above.

## Questions

Open an issue on the template repository with:

- The version you are upgrading from and the version you are upgrading
  to.
- The full output of any failed skill or hook.
- A diff of the file that surprised you.
- Whether the upgrade succeeded after manual fix-up or whether you had
  to roll back.

Migration notes improve only when real-world upgrades report what hurt.
