# Hooks Reference

This directory documents the **input/output contract** for every Claude
Code hook event used by this template, plus reference patterns for the
git-event hooks that ride alongside it.

The hook **scripts** themselves live in `app_dev/.claude/hooks/` and are
wired up in `app_dev/.claude/settings.json`. The docs in this directory
explain what payload each hook receives, what exit codes mean, what
mobile-specific concerns each hook should enforce, and how to extend the
defaults for a particular framework.

## How Claude Code hooks work (one-paragraph refresher)

Claude Code emits structured JSON events at well-defined points in a
session — when the session starts, before a tool runs, after a tool
returns, when the user submits a prompt, when the model is about to
compact, and so on. A hook is a script registered in `settings.json`
under one of the supported event keys. The script receives the event
payload on stdin, may print human-readable warnings on stderr, and
controls behavior with its exit code: `0` allows the action, `2`
blocks it (and stderr is surfaced back to the model). All other exit
codes are treated as a soft failure and logged.

## Why mobile apps need their own reference

The default hook patterns assume a generic Unix project. Mobile apps
add concerns that are easy to miss:

- App icons and splash screens have **density variants** that must all
  be present together, or the build silently falls back to the wrong
  asset.
- `.env*`, `local.properties`, signing certs, provisioning profiles,
  and keystores are each blessed-or-cursed depending on which platform
  you're building for. Committing the wrong one is a compliance event.
- A working `git push` on a mobile project should imply a green test
  matrix on **both** simulators that can be reasonably tested in CI.
- A "harmless" PNG dropped into `assets/` can balloon the install size
  past the cellular-download threshold and tank conversion.

Each doc in this directory translates the generic Claude Code contract
into mobile-specific obligations.

## Index

| Doc | What it covers |
|---|---|
| [hook-event-schemas.md](./hook-event-schemas.md) | JSON payload shape and field semantics for all 9 supported events with sample payloads |
| [validate-commit-hook.md](./validate-commit-hook.md) | Pre-commit checks (lint, type-check, secret scan, file-size guards) per framework |
| [validate-push-hook.md](./validate-push-hook.md) | Pre-push gate (full suite, E2E smoke, branch policy, app-size delta, perf regression) |
| [session-start-hook.md](./session-start-hook.md) | Session orientation output: branch, sprint, bugs, recovered state, framework detection |
| [post-merge-asset-validation.md](./post-merge-asset-validation.md) | Optional post-merge sweep for icon completeness, splash variants, density coverage, asset budgets |
| [git-event-hooks.md](./git-event-hooks.md) | Patterns for wrapping pre-commit, commit-msg, pre-push, post-merge, post-checkout |
| [retro-event-hooks.md](./retro-event-hooks.md) | Sprint-boundary and milestone-boundary hooks (e.g., auto-`/retrospective` on tag push) |

## Conventions used across these docs

- **Exit codes**: `0` = continue, `2` = block (stderr surfaced to the
  model). Any other non-zero exit is logged as a soft failure.
- **`set -uo pipefail`** is the default shell preamble for hooks. We
  deliberately omit `-e` because hooks run in messy environments
  (missing `jq`, missing `python3`, partial git states) and a hook
  that blocks the user because of a missing optional tool is worse
  than a hook that downgrades to "best effort".
- **stdin is JSON**. Read it with `jq` when available, fall back to
  `grep`/`sed` for the one or two fields you need. Every reference
  hook in `app_dev/.claude/hooks/` shows the dual-path pattern.
- **stderr is human**. The model and the user both see stderr from a
  blocking hook. Write it as you would write a code-review comment:
  short, actionable, with a path and a specific fix.
- **Mobile-aware paths**. Paths used in examples assume the directory
  layout in `.claude/docs/directory-structure.md` (Expo Router
  defaults for RN, `lib/` for Flutter, `App/` for iOS, `app/src/main/`
  for Android).

## Related documents

- `app_dev/.claude/docs/hooks-reference.md` — the top-level summary of
  which hooks are wired and when they fire (the index your `CLAUDE.md`
  links to).
- `app_dev/.claude/settings.json` — the canonical wiring of events to
  scripts.
- `app_dev/.claude/rules/` — path-scoped rules that overlap with
  several hooks (commit-message format, secret patterns, etc.).
