#!/usr/bin/env bash
# Hook: post-compact.sh
# Event: PostCompact
# Purpose: Remind Claude that durable state lives in active.md and prompt it
# to re-read the state file before continuing.

set -uo pipefail

STATE_FILE="production/session-state/active.md"

echo "=== PostCompact: Recover Context ==="
if [ -f "$STATE_FILE" ]; then
  echo "Active session state is at: $STATE_FILE"
  echo "Read this file before continuing — it holds the durable record of"
  echo "decisions, in-flight tasks, and open questions."
  TOTAL=$(wc -l < "$STATE_FILE" 2>/dev/null | tr -d ' ')
  echo "(${TOTAL:-0} lines)"
else
  echo "No active.md found. If work was in flight before compaction, look in"
  echo "production/session-state/checkpoints/ for the most recent snapshot."
fi
echo "==================================="

exit 0
