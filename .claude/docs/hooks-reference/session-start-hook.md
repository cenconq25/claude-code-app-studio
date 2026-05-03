# `session-start.sh` Reference

Fires on the `SessionStart` event — once at the very beginning of every
Claude Code session. Its job is to give the model (and the human at the
keyboard) everything they need to pick up where the last session left
off, without burning a single tool call.

The shipped hook (`app_dev/.claude/hooks/session-start.sh`) is
deliberately conservative: it only reads files, never writes, and exits
`0` even when its checks fail. A failing orientation hook should never
prevent a session from starting.

## What it prints, in order

1. **A header banner** so the rendered output is identifiable in the
   transcript.
2. **Branch + recent commits.** `git rev-parse --abbrev-ref HEAD`
   followed by `git log --oneline -5`. This single block tells the
   model whether it's on `main`, on a feature branch, or in the middle
   of a stale rebase.
3. **Active sprint** — the most recent file matching
   `production/sprints/sprint-*.md`. The model uses this filename to
   decide which story files to read.
4. **Active release** — the most recent
   `production/releases/release-*.md`, if any. Indicates the project
   is in pre-release.
5. **Open bug count** — number of `BUG-*.md` files in
   `production/qa/bugs/`. A spike in this number is the cheapest
   signal that quality is slipping.
6. **Code-health snapshot** — `TODO`/`FIXME` count under `src/`.
7. **Active session-state preview** — if
   `production/session-state/active.md` exists, prints the **most
   recent 25 lines** with a header so the model knows it has state to
   recover.

## Sample output (mid-feature)

```text
=== Claude Code App Studios — Session Context ===
Branch: feature/email-validator

Recent commits:
  c4a18a7 STORY-S5-12 Add Zod schema for email validation
  9f12b03 PRD-AUTH-003 Draft email sign-up flow PRD
  2b0e4dd ADR-0014 Choose Zod over Yup for runtime validation
  4dc7e91 STORY-S5-11 Wire onboarding navigator
  88aab2a chore: bump expo to 54.0.6

Active sprint: sprint-2026-05-S5
Open bugs: 3

Code health: 18 TODO/FIXME marker(s) in src/

=== ACTIVE SESSION STATE DETECTED ===
A previous session left state at: production/session-state/active.md
Read this file to recover context and continue where you left off.

Most recent state (last 25 lines):
  ## Status
  Working on PRD-AUTH-003 email sign-up.
  Sections written:
  - [x] Overview
  - [x] User Goal
  - [x] Detailed Requirements
  - [ ] Flows  <- IN PROGRESS
  ...
=== END SESSION STATE PREVIEW ===
===================================
```

## Sample output (fresh project, no framework yet)

When `docs/framework-reference/[framework]/VERSION.md` does not exist
and there is no concept document, the hook should suggest `/start`:

```text
=== Claude Code App Studios — Session Context ===
Branch: main

Recent commits:
  e4c1bb9 chore: initial template scaffolding

No framework configured yet. Run /start to begin onboarding.
No active sprint. Run /create-epics once PRDs are approved.
===================================
```

The shipped script does not currently emit the framework hint — add it
by extending the bottom of the script with:

```bash
FRAMEWORK_DIR="docs/framework-reference"
HAS_FRAMEWORK=""
for f in react-native flutter ios android; do
  [ -f "$FRAMEWORK_DIR/$f/VERSION.md" ] && HAS_FRAMEWORK="$f" && break
done

if [ -z "$HAS_FRAMEWORK" ]; then
  echo ""
  echo "No framework configured. Run /start to onboard."
fi
```

## Brownfield vs greenfield

The hook does not need to distinguish brownfield from greenfield —
that's `/adopt`'s job. But it should provide enough surface area for
the model to **detect** which mode it's in:

| Signal | Likely state |
|---|---|
| `src/` empty + no `VERSION.md` + no PRDs | Greenfield, fresh template |
| `src/` populated + no `VERSION.md` | Brownfield needing `/adopt` |
| `src/` populated + `VERSION.md` exists + no `production/sprints/` | Pre-Sprint Dev |
| `src/` populated + sprint files + no release files | In Sprint Dev |
| `production/releases/release-*.md` exists | QA/Beta or Release |

The hook prints enough of these to make detection cheap. If you add
more state files to the project, extend the hook's detection block in
the same conservative style — short lines, no emojis, no decorations,
no slow shell calls.

## Recovery from session crashes

The most important behaviour of this hook is the **state preview**.
When a session dies ("prompt too long", harness crash, network
hiccup), the next session must be able to pick up without a human
re-explaining the state of the world.

The shipped script reads the **last** 25 lines because the most
recent state is at the bottom of `active.md` — append-only state
files end with the freshest content. That's why the section header
in `active.md` is at the top and the working notes are at the bottom.

Earlier versions of the template printed the **first** 25 lines and
broke recovery — fixed in commit `a1697d6`. Do not revert this.

## Failure modes

The hook never blocks the session. Every git invocation tolerates
failure (`2>/dev/null` on the exits, `|| true` on the pipes), and the
script ends with `exit 0`. If a corrupt repo, a missing
`production/`, or an in-progress merge would otherwise fail, the hook
just prints a short banner and lets the session start.

## Performance budget

`session-start.sh` runs synchronously before the model gets the first
turn. Keep it fast:

- Use `git log --oneline -5` not `git log` — bounded output, no pager.
- Use `find production/qa/bugs -name 'BUG-*.md' | wc -l`, not a
  recursive `grep`.
- Skip TODO grep on repos where `src/` is empty.
- Bail early if `git rev-parse --abbrev-ref HEAD` fails — the
  directory is not a git repo yet.

Target: **< 200 ms** from launch to banner. If your project grows
past that, move heavy checks into a separate skill (`/onboard`) that
runs on demand.

## Extending without breaking

Anything you add should follow these rules:

1. Read-only. Never write to `active.md` from this hook.
2. Best-effort. Failure of any check must not block the rest of the
   output.
3. Mobile-relevant. Add things the model would otherwise have to
   discover with a tool call: framework version, last successful
   build target, last test run timestamp.
4. Stable. The model relies on the format. Adding new lines is fine;
   reordering or renaming existing ones is a breaking change.

## Where to read the shipped logic

`app_dev/.claude/hooks/session-start.sh` — wired in
`app_dev/.claude/settings.json` under `SessionStart`.
