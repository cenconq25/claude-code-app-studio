#!/usr/bin/env bash
# Hook: validate-skill-change.sh
# Event: PostToolUse (Write|Edit)
# Purpose: When a file under .claude/skills/ is written or edited, lint
# its YAML frontmatter for the required keys (name, description, model
# tier where applicable). Warn rather than block — authoring tools should
# stay friendly.

set -uo pipefail

INPUT=$(cat 2>/dev/null || echo "")

if command -v jq >/dev/null 2>&1; then
  FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)
else
  FILE_PATH=$(printf '%s' "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -1 | sed 's/"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

[ -z "$FILE_PATH" ] && exit 0

# Only inspect skill files
case "$FILE_PATH" in
  *.claude/skills/*.md|*/.claude/skills/*.md|.claude/skills/*.md) ;;
  *) exit 0 ;;
esac

[ ! -f "$FILE_PATH" ] && exit 0

WARNINGS=""

# Frontmatter must be the first thing in the file and be delimited by ---
FIRST_LINE=$(head -1 "$FILE_PATH" 2>/dev/null)
if [ "$FIRST_LINE" != "---" ]; then
  WARNINGS="${WARNINGS}\nSKILL: ${FILE_PATH} does not start with YAML frontmatter (---)"
else
  # Extract the frontmatter block
  FRONTMATTER=$(awk '/^---$/{n++; next} n==1{print}' "$FILE_PATH" 2>/dev/null)

  for key in "name" "description"; do
    if ! printf '%s' "$FRONTMATTER" | grep -qE "^${key}:" ; then
      WARNINGS="${WARNINGS}\nSKILL: ${FILE_PATH} is missing required frontmatter key: ${key}"
    fi
  done

  # Description length sanity check (must be >= 20 chars)
  DESC=$(printf '%s' "$FRONTMATTER" | grep -E '^description:' | head -1 | sed 's/^description:[[:space:]]*//')
  DESC_LEN=$(printf '%s' "$DESC" | wc -c | tr -d ' ')
  if [ -n "$DESC" ] && [ "${DESC_LEN:-0}" -lt 20 ]; then
    WARNINGS="${WARNINGS}\nSKILL: ${FILE_PATH} description is suspiciously short (${DESC_LEN} chars)"
  fi

  # Model tier — if present, must be haiku/sonnet/opus
  MODEL=$(printf '%s' "$FRONTMATTER" | grep -E '^model:' | head -1 | sed 's/^model:[[:space:]]*//')
  if [ -n "$MODEL" ]; then
    case "$MODEL" in
      haiku|sonnet|opus) ;;
      *) WARNINGS="${WARNINGS}\nSKILL: ${FILE_PATH} model: '${MODEL}' is not haiku/sonnet/opus" ;;
    esac
  fi
fi

if [ -n "$WARNINGS" ]; then
  printf '=== Skill Validation Warnings ===%b\n=================================\n' "$WARNINGS" >&2
fi

exit 0
