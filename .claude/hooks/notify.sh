#!/usr/bin/env bash
# Hook: notify.sh
# Event: Notification
# Purpose: Surface a desktop notification when Claude Code needs attention
# (input request, idle session, etc.). Best-effort; silently no-ops when
# the host has no notification command available.
#
# Reads a JSON payload like { "message": "..." }; falls back to a generic
# message when parsing fails.

set -uo pipefail

INPUT=$(cat 2>/dev/null || echo "")

MSG=""
if command -v jq >/dev/null 2>&1; then
  MSG=$(printf '%s' "$INPUT" | jq -r '.message // ""' 2>/dev/null)
fi
[ -z "$MSG" ] && MSG=$(printf '%s' "$INPUT" | grep -oE '"message"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | head -1 | sed 's/"message"[[:space:]]*:[[:space:]]*"//;s/"$//')
[ -z "$MSG" ] && MSG="Claude Code needs your attention."

TITLE="Claude Code App Studios"

# macOS
if command -v osascript >/dev/null 2>&1; then
  osascript -e "display notification \"$MSG\" with title \"$TITLE\"" >/dev/null 2>&1 &
  exit 0
fi

# Linux (notify-send)
if command -v notify-send >/dev/null 2>&1; then
  notify-send "$TITLE" "$MSG" >/dev/null 2>&1 &
  exit 0
fi

# Windows (PowerShell BurntToast or fallback msg)
if command -v powershell.exe >/dev/null 2>&1; then
  powershell.exe -NoProfile -Command \
    "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null; \
     [System.Windows.Forms.MessageBox]::Show('$MSG', '$TITLE')" >/dev/null 2>&1 &
  exit 0
fi

# No notifier available — log it and move on.
LOG_DIR="production/session-logs"
mkdir -p "$LOG_DIR" 2>/dev/null
echo "$(date +%Y-%m-%dT%H:%M:%S%z) | notify | $MSG" >> "$LOG_DIR/notifications.log" 2>/dev/null

exit 0
