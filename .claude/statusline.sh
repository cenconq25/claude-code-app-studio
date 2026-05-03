#!/usr/bin/env bash
# Claude Code App Studios — Status Line
# Reads JSON from stdin and prints a single-line breadcrumb suitable for
# Claude Code's status line.
#
# Output format:
#   ctx: 32% | Sonnet | Sprint Dev | Onboarding > Sign-up > Email validation
#
# Sections (in order, separated by " | "):
#   1. Context window usage percentage
#   2. Model display name
#   3. Detected lifecycle stage
#   4. Optional Epic > Feature > Task breadcrumb (read from active.md)

set -uo pipefail

INPUT=$(cat)

# --- Parse the harness JSON ---
if command -v jq >/dev/null 2>&1; then
  MODEL=$(printf '%s' "$INPUT" | jq -r '.model.display_name // "Claude"')
  CTX_PCT=$(printf '%s' "$INPUT" | jq -r '.context_window.used_percentage // empty')
  CWD=$(printf '%s' "$INPUT" | jq -r '.workspace.current_dir // .cwd // ""')
else
  MODEL=$(printf '%s' "$INPUT" | grep -oE '"display_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"display_name"[[:space:]]*:[[:space:]]*"//;s/"$//')
  CTX_PCT=$(printf '%s' "$INPUT" | grep -oE '"used_percentage"[[:space:]]*:[[:space:]]*[0-9]+' | head -1 | sed 's/.*:[[:space:]]*//')
  CWD=$(printf '%s' "$INPUT" | grep -oE '"current_dir"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"current_dir"[[:space:]]*:[[:space:]]*"//;s/"$//')
  [ -z "$MODEL" ] && MODEL="Claude"
fi

CWD=${CWD:-.}
# Normalise Windows-style separators
CWD=$(printf '%s' "$CWD" | sed 's|\\|/|g')

# --- Context label ---
if [ -n "${CTX_PCT}" ]; then
  CTX_LABEL="ctx: ${CTX_PCT}%"
else
  CTX_LABEL="ctx: --"
fi

# --- Lifecycle stage detection ---
# Priority 1: explicit stage file
STAGE=""
STAGE_FILE="$CWD/production/stage.txt"
if [ -f "$STAGE_FILE" ]; then
  STAGE=$(head -1 "$STAGE_FILE" 2>/dev/null | tr -d '\r\n' || true)
fi

# Priority 2: derive from artefacts present
if [ -z "$STAGE" ]; then
  TECH_PREFS="$CWD/.claude/docs/technical-preferences.md"
  PRD_DIR="$CWD/design/prd"
  ARCH_DIR="$CWD/docs/architecture"
  SRC_DIR="$CWD/src"

  HAS_FRAMEWORK=false
  HAS_PRD=false
  HAS_ADR=false
  SRC_FILE_COUNT=0

  if [ -f "$TECH_PREFS" ]; then
    if grep -m1 '^- \*\*Framework\*\*:' "$TECH_PREFS" 2>/dev/null | grep -qv "TO BE CONFIGURED"; then
      HAS_FRAMEWORK=true
    fi
  fi

  if [ -d "$PRD_DIR" ]; then
    if find "$PRD_DIR" -maxdepth 2 -name '*.md' 2>/dev/null | head -1 | grep -q .; then
      HAS_PRD=true
    fi
  fi

  if [ -d "$ARCH_DIR" ]; then
    if find "$ARCH_DIR" -maxdepth 1 -name 'adr-*.md' 2>/dev/null | head -1 | grep -q .; then
      HAS_ADR=true
    fi
  fi

  if [ -d "$SRC_DIR" ]; then
    SRC_FILE_COUNT=$(find "$SRC_DIR" -type f \( \
      -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' \
      -o -name '*.swift' -o -name '*.kt' -o -name '*.kts' \
      -o -name '*.dart' \
    \) 2>/dev/null | wc -l | tr -d ' ')
  fi

  if [ "$SRC_FILE_COUNT" -ge 25 ]; then
    if [ -d "$CWD/production/qa" ] && find "$CWD/production/qa" -maxdepth 2 -name '*.md' 2>/dev/null | head -1 | grep -q .; then
      STAGE="QA & Beta"
    else
      STAGE="Sprint Dev"
    fi
  elif [ "$HAS_ADR" = true ]; then
    STAGE="Architecture"
  elif [ "$HAS_PRD" = true ]; then
    STAGE="Design"
  elif [ "$HAS_FRAMEWORK" = true ]; then
    STAGE="Framework Setup"
  else
    STAGE="Discovery"
  fi
fi

# --- Optional Epic > Feature > Task breadcrumb (Sprint Dev and later) ---
BREADCRUMB=""
case "$STAGE" in
  "Sprint Dev"|"QA & Beta"|"Release"|"Live Ops")
    ACTIVE="$CWD/production/session-state/active.md"
    if [ -f "$ACTIVE" ]; then
      epic="" feature="" task=""
      in_block=false
      while IFS= read -r line; do
        case "$line" in
          *"<!-- STATUS -->"*) in_block=true; continue ;;
          *"<!-- /STATUS -->"*) break ;;
        esac
        if [ "$in_block" = true ]; then
          case "$line" in
            Epic:*)    epic=$(printf '%s' "$line" | sed 's/^Epic:[[:space:]]*//') ;;
            Feature:*) feature=$(printf '%s' "$line" | sed 's/^Feature:[[:space:]]*//') ;;
            Task:*)    task=$(printf '%s' "$line" | sed 's/^Task:[[:space:]]*//') ;;
          esac
        fi
      done < "$ACTIVE"

      crumbs=""
      [ -n "$epic" ] && crumbs="$epic"
      [ -n "$feature" ] && crumbs="${crumbs:+$crumbs > }$feature"
      [ -n "$task" ] && crumbs="${crumbs:+$crumbs > }$task"
      [ -n "$crumbs" ] && BREADCRUMB=" | $crumbs"
    fi
    ;;
esac

printf '%s | %s | %s%s' "$CTX_LABEL" "$MODEL" "$STAGE" "$BREADCRUMB"
