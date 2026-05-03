#!/usr/bin/env bash
# Hook: validate-push.sh
# Event: PreToolUse (Bash)
# Purpose: When Claude is about to run `git push ...`, run heavier checks
# than the per-commit hook. Warn on push to main, missing tests for staged
# source changes, and remind to run the full suite when crossing the
# Sprint Dev → QA & Beta boundary.
#
# Best-effort: only blocks on push --force to a protected branch.

set -uo pipefail

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  COMMAND=$(printf '%s' "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -1 | sed 's/"command"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

# Only fire on git push
if ! printf '%s' "$COMMAND" | grep -qE '^[[:space:]]*git[[:space:]]+push'; then
  exit 0
fi

# Hard block on force push to main
if printf '%s' "$COMMAND" | grep -qE '(--force|--force-with-lease|-f[[:space:]]|-f$)'; then
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  case "$CURRENT_BRANCH" in
    main|master|release|release/*|production)
      echo "BLOCKED: refusing force push to protected branch '${CURRENT_BRANCH}'." >&2
      echo "If this is intentional, push from your shell directly." >&2
      exit 2
      ;;
  esac
fi

WARNINGS=""

# Warn when pushing to main directly
if printf '%s' "$COMMAND" | grep -qE 'origin[[:space:]]+main|origin[[:space:]]+master'; then
  WARNINGS="${WARNINGS}\nPUSH: pushing directly to main — confirm this is intentional"
fi

# Warn when source has changed but tests have not (in this push)
RANGE=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || echo "")
if [ -n "$RANGE" ]; then
  SRC_CHANGED=$(git diff --name-only "${RANGE}..HEAD" 2>/dev/null | grep -E '^src/.*\.(ts|tsx|swift|kt|dart)$' || true)
  TESTS_CHANGED=$(git diff --name-only "${RANGE}..HEAD" 2>/dev/null | grep -E '^(tests/|src/.*(test|Test|Tests|_test)\.)' || true)

  if [ -n "$SRC_CHANGED" ] && [ -z "$TESTS_CHANGED" ]; then
    WARNINGS="${WARNINGS}\nPUSH: source changed but no test files in this push — verify coverage with /test-evidence-review"
  fi
fi

# Surface stage-aware reminder
STAGE=""
if [ -f "production/stage.txt" ]; then
  STAGE=$(head -1 "production/stage.txt" 2>/dev/null | tr -d '\r\n')
fi

case "$STAGE" in
  "QA & Beta"|"Release")
    WARNINGS="${WARNINGS}\nPUSH: project is in ${STAGE} — run /smoke-check before merging to main"
    ;;
esac

if [ -n "$WARNINGS" ]; then
  printf '=== Push Validation Warnings ===%b\n================================\n' "$WARNINGS" >&2
fi

exit 0
