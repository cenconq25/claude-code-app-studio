#!/usr/bin/env bash
# Hook: detect-gaps.sh
# Event: SessionStart (runs after session-start.sh)
# Purpose: Surface common documentation and configuration gaps so the user
# is prompted to fix them rather than discovering them mid-sprint.
# Gaps detected:
#   - Fresh project (no framework, no PRD, no source) → suggest /start
#   - Code without a framework configured
#   - Substantial codebase without PRDs
#   - Source code without an architecture doc
#   - Prototypes without a README
#   - Large codebase without sprint planning artefacts

set +e

echo "=== Checking for Documentation Gaps ==="

# --- 0. Fresh-project heuristic ---
FRESH=true

if [ -f ".claude/docs/technical-preferences.md" ]; then
  if grep -m1 '^- \*\*Framework\*\*:' .claude/docs/technical-preferences.md 2>/dev/null | grep -qv 'TO BE CONFIGURED'; then
    FRESH=false
  fi
fi

if [ -d "design/prd" ] && find design/prd -maxdepth 2 -name '*.md' -not -name '.gitkeep' 2>/dev/null | head -1 | grep -q .; then
  FRESH=false
fi

if [ -d "src" ]; then
  src_check=$(find src -type f \( \
      -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' \
      -o -name '*.swift' -o -name '*.kt' -o -name '*.kts' \
      -o -name '*.dart' \
    \) 2>/dev/null | head -1)
  if [ -n "$src_check" ]; then
    FRESH=false
  fi
fi

if [ "$FRESH" = true ]; then
  echo ""
  echo "NEW PROJECT: no framework configured, no PRDs, no source code yet."
  echo "  Recommended next step: run /start"
  echo ""
  echo "(Run /project-stage-detect for a full audit at any time.)"
  echo "==================================="
  exit 0
fi

# --- 1. Code present but framework not configured ---
SRC_FILES=0
if [ -d "src" ]; then
  SRC_FILES=$(find src -type f \( \
      -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' \
      -o -name '*.swift' -o -name '*.kt' -o -name '*.kts' -o -name '*.dart' \
    \) 2>/dev/null | wc -l | tr -d ' ')
fi

if [ "${SRC_FILES:-0}" -gt 0 ]; then
  if [ -f ".claude/docs/technical-preferences.md" ]; then
    if grep -m1 '^- \*\*Framework\*\*:' .claude/docs/technical-preferences.md 2>/dev/null | grep -q 'TO BE CONFIGURED'; then
      echo "GAP: ${SRC_FILES} source file(s) but framework is not pinned"
      echo "    Suggested action: /setup-framework"
    fi
  fi
fi

# --- 2. Substantial codebase but sparse PRDs ---
PRD_FILES=0
if [ -d "design/prd" ]; then
  PRD_FILES=$(find design/prd -type f -name '*.md' -not -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ')
fi

if [ "${SRC_FILES:-0}" -gt 50 ] && [ "${PRD_FILES:-0}" -lt 3 ]; then
  echo "GAP: ${SRC_FILES} source files but only ${PRD_FILES} PRDs"
  echo "    Suggested action: /reverse-document prd src/"
fi

# --- 3. Code without architecture doc ---
ADR_COUNT=0
if [ -d "docs/architecture" ]; then
  ADR_COUNT=$(find docs/architecture -type f -name 'adr-*.md' 2>/dev/null | wc -l | tr -d ' ')
fi

if [ "${SRC_FILES:-0}" -gt 30 ] && [ "${ADR_COUNT:-0}" -lt 2 ]; then
  echo "GAP: ${SRC_FILES} source files but only ${ADR_COUNT} ADR(s) recorded"
  echo "    Suggested action: /architecture-decision (start with state, navigation, networking)"
fi

# --- 4. Undocumented prototypes ---
if [ -d "prototypes" ]; then
  proto_dirs=$(find prototypes -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
  if [ -n "$proto_dirs" ]; then
    while IFS= read -r dir; do
      dir=$(printf '%s' "$dir" | sed 's|\\|/|g')
      if [ ! -f "${dir}/README.md" ] && [ ! -f "${dir}/CONCEPT.md" ]; then
        echo "GAP: undocumented prototype: ${dir}"
        echo "    Suggested action: add README.md with hypothesis, success criterion, lifespan"
      fi
    done <<< "$proto_dirs"
  fi
fi

# --- 5. Large codebase without sprint planning ---
if [ "${SRC_FILES:-0}" -gt 100 ]; then
  if [ ! -d "production/sprints" ] || ! find production/sprints -maxdepth 1 -name 'sprint-*.md' 2>/dev/null | head -1 | grep -q .; then
    echo "GAP: ${SRC_FILES} source files but no sprint plan in production/sprints/"
    echo "    Suggested action: /sprint-plan new"
  fi
fi

# --- 6. Tests directory missing or empty ---
if [ "${SRC_FILES:-0}" -gt 20 ]; then
  TEST_FILES=0
  if [ -d "tests" ]; then
    TEST_FILES=$(find tests -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.swift' -o -name '*.kt' -o -name '*.dart' \) 2>/dev/null | wc -l | tr -d ' ')
  fi
  if [ "${TEST_FILES:-0}" -lt 5 ]; then
    echo "GAP: ${SRC_FILES} source files but only ${TEST_FILES} test files in tests/"
    echo "    Suggested action: /test-setup"
  fi
fi

echo ""
echo "(Run /project-stage-detect for a comprehensive audit.)"
echo "==================================="

exit 0
