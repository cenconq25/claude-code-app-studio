#!/usr/bin/env bash
# Hook: session-start.sh
# Event: SessionStart
# Purpose: Print orientation context at the beginning of every session —
# branch, recent commits, active sprint, open bugs, and a preview of any
# in-flight session state file. Receives no stdin payload.
#
# Failure mode: never block the session. Always exit 0.

set +e

echo "=== Claude Code App Studios — Session Context ==="

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$BRANCH" ]; then
  echo "Branch: $BRANCH"
  echo ""
  echo "Recent commits:"
  git log --oneline -5 2>/dev/null | while IFS= read -r line; do
    echo "  $line"
  done
fi

LATEST_SPRINT=$(ls -t production/sprints/sprint-*.md 2>/dev/null | head -1)
if [ -n "$LATEST_SPRINT" ]; then
  echo ""
  echo "Active sprint: $(basename "$LATEST_SPRINT" .md)"
fi

LATEST_RELEASE=$(ls -t production/releases/release-*.md 2>/dev/null | head -1)
if [ -n "$LATEST_RELEASE" ]; then
  echo "Active release: $(basename "$LATEST_RELEASE" .md)"
fi

# Open bug count across QA evidence
BUG_COUNT=0
if [ -d "production/qa/bugs" ]; then
  count=$(find production/qa/bugs -name 'BUG-*.md' 2>/dev/null | wc -l | tr -d ' ')
  BUG_COUNT=$((BUG_COUNT + count))
fi
if [ "$BUG_COUNT" -gt 0 ]; then
  echo "Open bugs: $BUG_COUNT"
fi

# Lightweight code health snapshot
if [ -d "src" ]; then
  TODOS=$(grep -rE 'TODO|FIXME' src/ 2>/dev/null | wc -l | tr -d ' ')
  if [ "${TODOS:-0}" -gt 0 ]; then
    echo ""
    echo "Code health: ${TODOS} TODO/FIXME marker(s) in src/"
  fi
fi

# --- Active session-state recovery ---
STATE_FILE="production/session-state/active.md"
if [ -f "$STATE_FILE" ]; then
  echo ""
  echo "=== ACTIVE SESSION STATE DETECTED ==="
  echo "A previous session left state at: $STATE_FILE"
  echo "Read this file to recover context and continue where you left off."
  echo ""
  echo "Most recent state (last 25 lines):"
  tail -25 "$STATE_FILE" 2>/dev/null
  TOTAL=$(wc -l < "$STATE_FILE" 2>/dev/null | tr -d ' ')
  if [ "${TOTAL:-0}" -gt 25 ]; then
    echo "  ... (${TOTAL} total lines — read the full file to continue)"
  fi
  echo "=== END SESSION STATE PREVIEW ==="
fi

echo "==================================="
exit 0
