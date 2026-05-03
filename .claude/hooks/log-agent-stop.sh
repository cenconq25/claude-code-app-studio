#!/usr/bin/env bash
# Hook: log-agent-stop.sh
# Event: SubagentStop
# Purpose: Pair with log-agent.sh — record the agent's completion (or
# failure) so the audit log can show full lifecycle.

set -uo pipefail

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  AGENT_NAME=$(printf '%s' "$INPUT" | jq -r '.agent_type // "unknown"' 2>/dev/null)
  SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // ""' 2>/dev/null)
  STATUS=$(printf '%s' "$INPUT" | jq -r '.status // "completed"' 2>/dev/null)
else
  AGENT_NAME=$(printf '%s' "$INPUT" | grep -oE '"agent_type"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | sed 's/"agent_type"[[:space:]]*:[[:space:]]*"//;s/"$//')
  [ -z "$AGENT_NAME" ] && AGENT_NAME="unknown"
  SESSION_ID=$(printf '%s' "$INPUT" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | sed 's/"session_id"[[:space:]]*:[[:space:]]*"//;s/"$//')
  STATUS=$(printf '%s' "$INPUT" | grep -oE '"status"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | sed 's/"status"[[:space:]]*:[[:space:]]*"//;s/"$//')
  [ -z "$STATUS" ] && STATUS="completed"
fi

LOG_DIR="production/session-logs"
mkdir -p "$LOG_DIR" 2>/dev/null

TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S%z")
{
  echo "${TIMESTAMP} | stop  | agent=${AGENT_NAME} | session=${SESSION_ID:-no-session} | status=${STATUS}"
} >> "$LOG_DIR/agent-audit.log" 2>/dev/null

exit 0
