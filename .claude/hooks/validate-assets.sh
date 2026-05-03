#!/usr/bin/env bash
# Hook: validate-assets.sh
# Event: PostToolUse (Write|Edit)
# Purpose: Sanity-check mobile-specific assets — app icons, splash images,
# and asset naming — when those paths are touched. Warns rather than
# blocks so designers can iterate quickly.

set -uo pipefail

INPUT=$(cat 2>/dev/null || echo "")

# Pull the file path being written/edited
if command -v jq >/dev/null 2>&1; then
  FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)
else
  FILE_PATH=$(printf '%s' "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -1 | sed 's/"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

[ -z "$FILE_PATH" ] && exit 0

WARNINGS=""

case "$FILE_PATH" in
  *AppIcon.appiconset*|*ic_launcher*|*adaptive-icon*|*app-icon*)
    # Try to read the file with `file` if available
    if command -v file >/dev/null 2>&1 && [ -f "$FILE_PATH" ]; then
      kind=$(file -b "$FILE_PATH" 2>/dev/null || echo "")
      case "$FILE_PATH" in
        *.png) ;;
        *.svg) ;;
        *.webp) ;;
        *) WARNINGS="${WARNINGS}\nASSET: ${FILE_PATH} is an app icon path but extension is non-standard" ;;
      esac
      # Quick dimension hint via file output
      if printf '%s' "$kind" | grep -qE '[0-9]+ x [0-9]+'; then
        dims=$(printf '%s' "$kind" | grep -oE '[0-9]+ x [0-9]+' | head -1)
        echo "ASSET: ${FILE_PATH} dimensions: ${dims}" >&2
      fi
    fi
    ;;
  *splash*|*Splash*|*launch_screen*|*LaunchScreen*)
    case "$FILE_PATH" in
      *.png|*.webp|*.storyboard|*.xml) ;;
      *) WARNINGS="${WARNINGS}\nASSET: ${FILE_PATH} is a splash path but extension looks unusual" ;;
    esac
    ;;
esac

# Naming conventions: drawables and assets should be lowercased / snake-cased
case "$FILE_PATH" in
  *android*/res/drawable*/*)
    base=$(basename "$FILE_PATH")
    if printf '%s' "$base" | grep -qE '[A-Z]| '; then
      WARNINGS="${WARNINGS}\nASSET: Android drawable '${base}' should be lowercase_snake_case"
    fi
    ;;
esac

# Image weight warning — over 500 KB per image is suspicious for app assets
if [ -f "$FILE_PATH" ]; then
  case "$FILE_PATH" in
    *.png|*.jpg|*.jpeg|*.webp)
      size=$(wc -c < "$FILE_PATH" 2>/dev/null | tr -d ' ')
      if [ -n "$size" ] && [ "$size" -gt 500000 ]; then
        WARNINGS="${WARNINGS}\nASSET: ${FILE_PATH} is $((size / 1024)) KB — consider compressing"
      fi
      ;;
  esac
fi

if [ -n "$WARNINGS" ]; then
  printf '=== Asset Validation Warnings ===%b\n=================================\n' "$WARNINGS" >&2
fi

exit 0
