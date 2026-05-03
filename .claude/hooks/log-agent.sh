#!/usr/bin/env bash
# Hook: log-agent.sh
# Event: SubagentStart
# Purpose: Audit-trail every subagent invocation. Reads JSON from stdin and
# extracts the agent_type field (the actual agent name in Claude Code's
# SubagentStart payload).
#
# Note: the field is `agent_type`, not `agent_name`. Reading the wrong key
# silently produces "unknown" for every entry.

set -uo pipefail

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  AGENT_NAME=$(printf '%s' "$INPUT" | jq -r '.agent_type // "unknown"' 2>/dev/null)
  SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // ""' 2>/dev/null)
else
  AGENT_NAME=$(printf '%s' "$INPUT" | grep -oE '"agent_type"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | sed 's/"agent_type"[[:space:]]*:[[:space:]]*"//;s/"$//')
  [ -z "$AGENT_NAME" ] && AGENT_NAME="unknown"
  SESSION_ID=$(printf '%s' "$INPUT" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | sed 's/"session_id"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

LOG_DIR="production/session-logs"
mkdir -p "$LOG_DIR" 2>/dev/null

TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S%z")
{
  echo "${TIMESTAMP} | start | agent=${AGENT_NAME} | session=${SESSION_ID:-no-session}"
} >> "$LOG_DIR/agent-audit.log" 2>/dev/null

exit 0
