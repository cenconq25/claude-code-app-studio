# Hook Event Schemas

Every Claude Code hook receives a JSON payload on stdin describing the
event that triggered it. This doc enumerates the **9 supported events**,
the fields each one delivers, sample payloads, and the patterns we use
across the mobile-app template.

## Quick reference table

| Event | When it fires | Key fields |
|---|---|---|
| `SessionStart` | At the very beginning of a Claude Code session | `cwd`, `session_id`, `transcript_path` |
| `SessionStop` | When the session is closed cleanly | `cwd`, `session_id`, `transcript_path`, `last_message_role` |
| `PreCompact` | Just before context compaction runs | `cwd`, `session_id`, `transcript_path`, `transcript_summary` |
| `PostCompact` | Immediately after context compaction completes | `cwd`, `session_id`, `transcript_path` |
| `PreToolUse` | Before any tool call (Bash, Edit, Write, Task, etc.) | `tool_name`, `tool_input`, `cwd`, `session_id` |
| `PostToolUse` | After a tool call returns | `tool_name`, `tool_input`, `tool_response`, `cwd`, `session_id` |
| `UserPromptSubmit` | When the user submits a new prompt | `prompt`, `cwd`, `session_id` |
| `Notification` | For agent-emitted notifications (e.g., `notify.sh`) | `message`, `cwd`, `session_id` |
| `Stop` | When the model decides it is done responding | `cwd`, `session_id`, `transcript_path` |

`cwd` is the working directory at the moment the event fired.
`session_id` is stable for the lifetime of one Claude Code session and
is what `log-agent.sh` keys its audit trail off.

## Common patterns

### Reading stdin with `jq` (preferred)

```bash
INPUT=$(cat)
TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
```

### Reading stdin without `jq` (fallback)

```bash
INPUT=$(cat)
TOOL_NAME=$(printf '%s' "$INPUT" \
  | grep -oE '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | head -1 | sed 's/"tool_name"[[:space:]]*:[[:space:]]*"//;s/"$//')
```

### Filtering for a specific tool

`PreToolUse` and `PostToolUse` fire for every tool. Always filter to the
tools your hook cares about, then early-exit `0` for everything else:

```bash
case "$TOOL_NAME" in
  Bash) ;;            # we handle this
  *) exit 0 ;;        # not our concern
esac
```

---

## SessionStart

Fires once when the session opens. No stdin payload is consumed by the
default `session-start.sh`, but the harness still emits one.

```json
{
  "cwd": "/Users/dev/projects/my-app",
  "session_id": "ses_01HZ8KFY8X8VVCMZ3VMGZBJ4XK",
  "transcript_path": "/Users/dev/.claude/transcripts/ses_01HZ8KFY8X8VVCMZ3VMGZBJ4XK.jsonl"
}
```

**Common patterns**: print branch, recent commits, sprint, open bugs,
preview `production/session-state/active.md`. See
[`session-start-hook.md`](./session-start-hook.md).

**Gotchas**: the working directory is whatever directory the user
launched Claude Code from. Resolve project-root relative paths with
care — use git rev-parse if you need the repo root.

---

## SessionStop

Fires when the session closes cleanly (user exits, harness shuts down).
Useful for log archival and audit-trail finalisation.

```json
{
  "cwd": "/Users/dev/projects/my-app",
  "session_id": "ses_01HZ8KFY8X8VVCMZ3VMGZBJ4XK",
  "transcript_path": "/Users/dev/.claude/transcripts/ses_01HZ8KFY8X8VVCMZ3VMGZBJ4XK.jsonl",
  "last_message_role": "assistant"
}
```

**Gotchas**: do not perform expensive work here — the user is waiting on
their shell prompt to come back. Tail the transcript asynchronously if
you need to do real archival.

---

## PreCompact

Fires immediately before the harness compacts the in-memory transcript.
The `transcript_summary` field is the model's draft of what it intends
to retain — you can read it to log what was preserved vs. dropped.

```json
{
  "cwd": "/Users/dev/projects/my-app",
  "session_id": "ses_01HZ8KFY8X8VVCMZ3VMGZBJ4XK",
  "transcript_path": "/Users/dev/.claude/transcripts/ses_01HZ8KFY8X8VVCMZ3VMGZBJ4XK.jsonl",
  "transcript_summary": "Working on PRD-AUTH-003 email sign-up; 4 sections written, currently drafting validation flow..."
}
```

**Common pattern**: snapshot `production/session-state/active.md` to
`production/session-logs/pre-compact-<timestamp>.md` so you can recover
state if the compacted summary loses key detail.

---

## PostCompact

Fires after compaction. By this point the transcript on disk has been
rewritten with the summary as the head.

```json
{
  "cwd": "/Users/dev/projects/my-app",
  "session_id": "ses_01HZ8KFY8X8VVCMZ3VMGZBJ4XK",
  "transcript_path": "/Users/dev/.claude/transcripts/ses_01HZ8KFY8X8VVCMZ3VMGZBJ4XK.jsonl"
}
```

**Common pattern**: re-print the most important orientation lines so the
freshly compacted session has the active sprint and active feature in
its visible context window.

---

## PreToolUse

Fires before every tool call. The most-used hook event by far — every
guard rail (commit validation, push validation, dangerous-command
blocker) lives here.

```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "git commit -m 'feat: add email validation'",
    "description": "Commit the email validator implementation"
  },
  "cwd": "/Users/dev/projects/my-app",
  "session_id": "ses_01HZ8KFY8X8VVCMZ3VMGZBJ4XK"
}
```

For Edit/Write the `tool_input` shape is different:

```json
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/Users/dev/projects/my-app/src/features/auth/email-validator.ts",
    "content": "export function isValidEmail(s: string): boolean { ... }"
  },
  "cwd": "/Users/dev/projects/my-app",
  "session_id": "ses_01HZ8KFY8X8VVCMZ3VMGZBJ4XK"
}
```

**Common patterns**:
- Match `tool_input.command` against `git commit`, `git push`, `rm -rf`,
  `sudo`, etc.
- Match `tool_input.file_path` against `.env*`, `*.keystore`, `*.p12`,
  `*.mobileprovision`, `local.properties` — refuse to write secrets.
- Block writes to `production/session-state/active.md` outside an
  approved skill.

**Gotchas**: `tool_input` is tool-shaped — its keys differ between
`Bash`, `Write`, `Edit`, `Read`, `Task`, etc. Always read the
`tool_name` first and dispatch on it.

---

## PostToolUse

Fires after a tool returns. Used for log enrichment, asset validation,
and follow-up checks.

```json
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/Users/dev/projects/my-app/assets/icons/AppIcon.appiconset/Icon-1024.png"
  },
  "tool_response": {
    "ok": true,
    "bytes_written": 187234
  },
  "cwd": "/Users/dev/projects/my-app",
  "session_id": "ses_01HZ8KFY8X8VVCMZ3VMGZBJ4XK"
}
```

**Common patterns**: see [`post-merge-asset-validation.md`](./post-merge-asset-validation.md)
and `validate-assets.sh` — both react to writes inside icon, splash, and
drawable directories.

**Gotchas**: `tool_response` may be missing or partially populated when
the tool errored. Code defensively.

---

## UserPromptSubmit

Fires once per user-typed prompt. Useful for prompt logging and for
injecting reminders ("you are on `main`, did you mean to be?").

```json
{
  "prompt": "implement the email validator from PRD-AUTH-003",
  "cwd": "/Users/dev/projects/my-app",
  "session_id": "ses_01HZ8KFY8X8VVCMZ3VMGZBJ4XK"
}
```

**Common pattern**: scan the prompt for PRD/ADR/STORY IDs and pre-load
those files into the next response context (via stderr hint).

---

## Notification

Fires when a tool or skill emits a structured notification (used by
`notify.sh` to surface long-running results, by orchestration skills to
report parallel agent completion).

```json
{
  "message": "qa-tester: 3 of 12 cases failed on iOS simulator. See production/qa/smoke-2026-05-03.md",
  "cwd": "/Users/dev/projects/my-app",
  "session_id": "ses_01HZ8KFY8X8VVCMZ3VMGZBJ4XK"
}
```

**Common pattern**: forward to a desktop notifier (`osascript`,
`notify-send`) so the user sees it without watching the terminal.

---

## Stop

Fires when the model decides it has finished responding to the current
turn. Counterpart to `SessionStop` — `Stop` happens many times per
session, `SessionStop` happens once.

```json
{
  "cwd": "/Users/dev/projects/my-app",
  "session_id": "ses_01HZ8KFY8X8VVCMZ3VMGZBJ4XK",
  "transcript_path": "/Users/dev/.claude/transcripts/ses_01HZ8KFY8X8VVCMZ3VMGZBJ4XK.jsonl"
}
```

**Common pattern**: `log-agent-stop.sh` writes the final-turn summary to
`production/session-logs/`. Useful for reconstructing what an agent
attempted in a session that died before `SessionStop`.

**Gotchas**: do not block here. Returning `2` from `Stop` is supported
in newer harness versions but is rarely useful — by the time `Stop`
fires, the model has already produced its output.

---

## Field-presence summary

| Field | Sess Start | Sess Stop | Pre Compact | Post Compact | Pre Tool | Post Tool | User Prompt | Notif | Stop |
|---|---|---|---|---|---|---|---|---|---|
| `cwd` | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| `session_id` | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| `transcript_path` | yes | yes | yes | yes | no | no | no | no | yes |
| `tool_name` | no | no | no | no | yes | yes | no | no | no |
| `tool_input` | no | no | no | no | yes | yes | no | no | no |
| `tool_response` | no | no | no | no | no | yes | no | no | no |
| `prompt` | no | no | no | no | no | no | yes | no | no |
| `message` | no | no | no | no | no | no | no | yes | no |
| `last_message_role` | no | yes | no | no | no | no | no | no | no |
| `transcript_summary` | no | no | yes | no | no | no | no | no | no |

Always treat the schema as **additive** — newer harness versions may
add fields. Read what you need with defaults; never fail because an
unexpected field appears.
