#!/usr/bin/env bash
# Hook: validate-commit.sh
# Event: PreToolUse (Bash)
# Purpose: When Claude is about to run `git commit ...`, lint the staged
# files. Block on hard errors (invalid JSON in data files); warn on soft
# issues (PRDs missing required sections, source missing PRD/ADR
# references, hardcoded values, ownerless TODOs).
#
# Input schema:
#   { "tool_name": "Bash", "tool_input": { "command": "git commit ..." } }
#
# Exit 0 = allow; exit 2 = block (stderr surfaced to Claude).

set -uo pipefail

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  COMMAND=$(printf '%s' "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -1 | sed 's/"command"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

# Only fire on actual git commit invocations
if ! printf '%s' "$COMMAND" | grep -qE '^[[:space:]]*git[[:space:]]+commit'; then
  exit 0
fi

STAGED=$(git diff --cached --name-only 2>/dev/null || true)
[ -z "$STAGED" ] && exit 0

WARNINGS=""

# --- Hard block: invalid JSON ---
JSON_FILES=$(printf '%s\n' "$STAGED" | grep -E '\.(json)$' || true)
if [ -n "$JSON_FILES" ]; then
  PYTHON_CMD=""
  for cmd in python3 python py; do
    if command -v "$cmd" >/dev/null 2>&1; then
      PYTHON_CMD="$cmd"; break
    fi
  done

  while IFS= read -r file; do
    [ -z "$file" ] && continue
    [ ! -f "$file" ] && continue
    case "$file" in
      *package-lock.json|*yarn.lock) continue ;;
    esac
    if [ -n "$PYTHON_CMD" ]; then
      if ! "$PYTHON_CMD" -m json.tool "$file" >/dev/null 2>&1; then
        printf 'BLOCKED: %s is not valid JSON\n' "$file" >&2
        exit 2
      fi
    fi
  done <<< "$JSON_FILES"
fi

# --- Soft warnings: PRDs missing required sections ---
PRD_FILES=$(printf '%s\n' "$STAGED" | grep -E '^design/prd/.*\.md$' || true)
if [ -n "$PRD_FILES" ]; then
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    [ ! -f "$file" ] && continue
    for section in "Overview" "User Goal" "Detailed Requirements" "Flows" "Edge Cases" \
                   "Dependencies" "Tunables" "Acceptance Criteria" "Analytics" \
                   "Accessibility" "Localization"; do
      if ! grep -qi "$section" "$file" 2>/dev/null; then
        WARNINGS="${WARNINGS}\nPRD: ${file} missing required section: ${section}"
      fi
    done
  done <<< "$PRD_FILES"
fi

# --- Soft warnings: source files without a PRD/ADR/STORY reference in commit ---
COMMIT_MSG=""
COMMIT_MSG=$(printf '%s' "$COMMAND" | sed -nE 's/.*-m[[:space:]]+["'\'']([^"'\'']+)["'\''].*/\1/p')
if [ -n "$COMMIT_MSG" ]; then
  if ! printf '%s' "$COMMIT_MSG" | grep -qE '(PRD-[A-Z0-9-]+|ADR-[0-9]+|STORY-[A-Z0-9-]+)'; then
    SRC_TOUCHED=$(printf '%s\n' "$STAGED" | grep -E '^src/' | head -1 || true)
    if [ -n "$SRC_TOUCHED" ]; then
      WARNINGS="${WARNINGS}\nCOMMIT: src/ files staged but message has no PRD/ADR/STORY reference"
    fi
  fi
fi

# --- Soft warnings: hardcoded values in source ---
SRC_FILES=$(printf '%s\n' "$STAGED" | grep -E '^src/.*\.(ts|tsx|js|jsx|swift|kt|dart)$' || true)
if [ -n "$SRC_FILES" ]; then
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    [ ! -f "$file" ] && continue
    # Look for likely tunables hardcoded as integers
    if grep -nE '(timeout|retry|threshold|limit|cooldown|priceCents|rateLimit)[[:space:]]*[:=][[:space:]]*[0-9]+' "$file" >/dev/null 2>&1; then
      WARNINGS="${WARNINGS}\nCODE: ${file} appears to hardcode a tunable value — move to config"
    fi
    # Ownerless TODO/FIXME
    if grep -nE '(TODO|FIXME|HACK)[^(]' "$file" >/dev/null 2>&1; then
      WARNINGS="${WARNINGS}\nSTYLE: ${file} contains a TODO/FIXME without owner — use TODO(name)"
    fi
    # Hard-coded URLs to common domains
    if grep -nE 'https?://[a-zA-Z0-9.-]+/.*"' "$file" >/dev/null 2>&1; then
      if ! grep -qE 'localhost|example\.|test\.' "$file" 2>/dev/null; then
        WARNINGS="${WARNINGS}\nCODE: ${file} appears to contain a hardcoded URL — use config"
      fi
    fi
  done <<< "$SRC_FILES"
fi

# Print warnings (non-blocking) and allow commit
if [ -n "$WARNINGS" ]; then
  printf '=== Commit Validation Warnings ===%b\n=================================\n' "$WARNINGS" >&2
fi

exit 0
