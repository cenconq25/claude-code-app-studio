#!/usr/bin/env bash
# Hook: session-stop.sh
# Event: Stop
# Purpose: Append a session-end record to production/session-logs/sessions.log.
# Useful for retrospectives and audit trails.

set -uo pipefail

LOG_DIR="production/session-logs"
mkdir -p "$LOG_DIR" 2>/dev/null || exit 0

LOG_FILE="$LOG_DIR/sessions.log"
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S%z")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "no-git")
HEAD_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "----")

# Try to read the active task from session-state if present
TASK_LINE=""
STATE_FILE="production/session-state/active.md"
if [ -f "$STATE_FILE" ]; then
  TASK_LINE=$(grep -m1 '^Task:' "$STATE_FILE" 2>/dev/null | sed 's/^Task:[[:space:]]*//')
fi

{
  echo "${TIMESTAMP} | session-end | branch=${BRANCH} | head=${HEAD_SHA} | task='${TASK_LINE}'"
} >> "$LOG_FILE" 2>/dev/null

exit 0
