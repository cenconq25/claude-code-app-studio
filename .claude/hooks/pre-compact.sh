#!/usr/bin/env bash
# Hook: pre-compact.sh
# Event: PreCompact
# Purpose: Snapshot a checkpoint before the harness compacts the session.
# Saves a copy of active.md (if present) and the recent agent-audit log so
# the user can recover decisions that might otherwise be summarised away.

set -uo pipefail

CHECKPOINT_DIR="production/session-state/checkpoints"
LOG_DIR="production/session-logs"

mkdir -p "$CHECKPOINT_DIR" "$LOG_DIR" 2>/dev/null || exit 0

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# Snapshot the active state file
STATE_FILE="production/session-state/active.md"
if [ -f "$STATE_FILE" ]; then
  cp "$STATE_FILE" "$CHECKPOINT_DIR/active-${TIMESTAMP}.md" 2>/dev/null || true
fi

# Snapshot the most recent 200 lines of the agent audit log
AUDIT_LOG="$LOG_DIR/agent-audit.log"
if [ -f "$AUDIT_LOG" ]; then
  tail -200 "$AUDIT_LOG" > "$CHECKPOINT_DIR/agent-audit-${TIMESTAMP}.log" 2>/dev/null || true
fi

# Note the compaction in the session log
{
  echo "${TIMESTAMP} | pre-compact | checkpoint written to ${CHECKPOINT_DIR}"
} >> "$LOG_DIR/sessions.log" 2>/dev/null

# Print a one-line reminder so Claude sees it
echo "=== PreCompact: checkpoint saved to ${CHECKPOINT_DIR}/active-${TIMESTAMP}.md ==="

exit 0
