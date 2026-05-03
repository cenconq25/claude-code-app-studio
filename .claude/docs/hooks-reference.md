# Hooks Reference

Lifecycle hooks live in `.claude/hooks/` and are wired into Claude Code via
`.claude/settings.json`. Each hook is a bash script that reads any
provided JSON payload from stdin and exits 0 (allow) or 2 (block, with
stderr surfaced to Claude). Hooks fail gracefully when optional tools
(`jq`, `python3`) are not installed.

| Hook | Event | Purpose |
|---|---|---|
| `session-start.sh` | SessionStart | Print branch, recent commits, sprint, bug count, and preview `active.md` if it exists. |
| `session-stop.sh` | Stop | Append a session-end record to `production/session-logs/`. |
| `detect-gaps.sh` | SessionStart | Surface missing framework config, missing PRDs, undocumented prototypes, code without ADRs. |
| `pre-compact.sh` | PreCompact | Snapshot a checkpoint to `production/session-state/` before compaction. |
| `post-compact.sh` | PostCompact | Remind the user to read `active.md` after compaction. |
| `notify.sh` | Notification | Send a desktop notification when Claude needs attention. |
| `validate-commit.sh` | PreToolUse (Bash) | Lint commits — block on invalid JSON in data files; warn on missing PRD/ADR references, hardcoded values, ownerless TODOs. |
| `validate-push.sh` | PreToolUse (Bash) | Heavier checks before push — full suite or smoke check, depending on stage. |
| `validate-assets.sh` | PostToolUse (Write/Edit) | Validate app icon sizes, splash screens, and asset naming when those paths are touched. |
| `validate-skill-change.sh` | PostToolUse (Write/Edit) | Lint skill frontmatter when `.claude/skills/*.md` is changed. |
| `log-agent.sh` | SubagentStart | Append agent invocation to `production/session-logs/agent-audit.log`. |
| `log-agent-stop.sh` | SubagentStop | Append agent completion record. |

## Authoring a New Hook

1. Pick the right Claude Code event from
   [docs.claude.com/claude-code/hooks-reference](https://docs.claude.com/claude-code/hooks-reference).
2. Drop the script in `.claude/hooks/[name].sh` with `#!/usr/bin/env bash`
   and `set -euo pipefail`.
3. Wire it into `.claude/settings.json` under the matching event with a
   sensible timeout.
4. Test by triggering the event manually.
5. Document it in this file.

## Required Conventions

- All scripts start with `#!/usr/bin/env bash` and `set -euo pipefail`
  except where partial failure is intentional (use `set +e` only with a
  comment explaining why).
- Hooks must `exit 0` on success and `exit 2` on a blocking failure with
  the reason printed to stderr. Any other exit code is treated as a
  non-blocking warning.
- Hooks must not write to `~`, `/tmp`, or anywhere outside the project.
  Use `production/session-logs/` for audit, `production/session-state/`
  for state.
- Do not assume `jq` or `python3` are available; provide grep-based
  fallbacks where feasible.
- Cross-platform safety: prefer POSIX (`grep -E` not `grep -P`),
  normalise Windows backslashes, never assume `gnu` vs. `bsd` flag
  behaviour without a test.
- Keep timeouts short (5-15 s). A slow hook stalls every interaction.

## Disabling a Hook

Hooks are wired in `settings.json`. To disable one without losing the
file, comment its block out (JSON does not support comments — copy it to
`settings.local.json` instead, with the hook block removed). Do not
delete the script; another contributor may need it.
