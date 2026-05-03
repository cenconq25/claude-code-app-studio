# Post-Merge Asset Validation (Optional Hook)

Mobile apps fail in spectacularly silent ways when assets are
incomplete. A missing icon variant ships a blank app launcher on one
specific Android density. A missing splash variant ships a blurry
launch experience on the iPhone Pro Max. A 3 MB hero PNG ships
unannounced into the install bundle and tanks store conversion.

This doc describes an **optional** hook that fires after `git merge`
(or after a `PostToolUse(Bash)` matching `git merge`) and sweeps the
asset tree for completeness, density coverage, naming compliance, and
budget compliance.

It is intentionally not wired by default — most projects want the
warnings during PR, not after merge — but the patterns here apply
equally to a pre-merge or pre-push hook. Adopt whichever timing
matches your team's workflow.

## When to fire

Three reasonable timings:

| Timing | Trigger | Why |
|---|---|---|
| Pre-PR | `validate-push.sh` extension | Stops bad assets from reaching the remote at all |
| Post-merge | `PostToolUse(Bash)` matching `git merge --` | Surfaces drift caused by the merge itself |
| CI-only | GitHub Actions on `pull_request` | Cheapest in dev-loop time |

The shipped `validate-assets.sh` already covers the **per-file write**
case. The post-merge hook is **per-tree**, sweeping the whole asset
directory at once.

## What it checks

### App icons

| Platform | Expected | What's checked |
|---|---|---|
| iOS | `ios/.../Assets.xcassets/AppIcon.appiconset/` with all variants in `Contents.json` | Every entry in `Contents.json` has a corresponding file present and dimensions match |
| Android | `android/app/src/main/res/mipmap-{m,h,xh,xxh,xxxh}dpi/ic_launcher.{png,xml}` plus adaptive `ic_launcher_foreground` and `ic_launcher_background` | All five densities present + adaptive components |
| PWA / web | `public/manifest.json` icons array | Each icon entry resolves to a file with declared dimensions |

### Splash screens

| Stack | Expected |
|---|---|
| iOS | `LaunchScreen.storyboard` referenced in `Info.plist` (`UILaunchStoryboardName`), or asset entries for the new Launch Screen Storyboard variants on iOS 17+ |
| Android | `windowSplashScreenBackground`, `windowSplashScreenAnimatedIcon` in the Android 12+ Splash Screen API, or a legacy splash activity layout |
| React Native | `react-native-bootsplash` config + assets in `assets/bootsplash/` |
| Flutter | `flutter_native_splash` config + generated assets in `lib/generated/` and platform folders |

### Image resolution variants

| Platform | Required variants |
|---|---|
| iOS | `@1x`, `@2x`, `@3x` for every named image referenced from code or `*.xcassets` |
| Android | `mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi` for every drawable referenced from code or layout |
| Cross-platform | If only one density exists, prefer SVG/Vector and warn about raster-only |

### Asset naming standards

| Stack | Convention | Bad | Good |
|---|---|---|---|
| React Native | camelCase | `Login Background.png` | `loginBackground.png` |
| Android (drawable/mipmap) | snake_case lowercase | `LoginBackground.png` | `login_background.png` |
| iOS (Assets.xcassets) | PascalCase imageset | `login_background.imageset` | `LoginBackground.imageset` |
| Flutter | snake_case | `LoginBackground.png` | `login_background.png` |

### File-size budgets

| Asset type | Budget | Rationale |
|---|---|---|
| App icons | < 200 KB per density | Bundled into the binary regardless of usage |
| Splash images | < 300 KB per variant | Must load before first frame |
| Hero photos / onboarding screenshots | < 500 KB per density | Frequently the biggest install-size offender |
| Decorative icons | SVG or vector drawable preferred | Scales without raster cost |
| Photographs | AVIF or WebP preferred over PNG/JPG | 30–60% size reduction at the same quality |

## Sample script

```bash
#!/usr/bin/env bash
# Hook: validate-assets-post-merge.sh
# Event: PostToolUse (Bash, matching "git merge")

set -uo pipefail

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
else
  COMMAND=$(printf '%s' "$INPUT" \
    | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -1 | sed 's/.*"command"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

# Only after a real merge
printf '%s' "$COMMAND" | grep -qE '^[[:space:]]*git[[:space:]]+merge' || exit 0

WARNINGS=""

# 1. iOS icon completeness
ICONSET="ios/App/Assets.xcassets/AppIcon.appiconset"
if [ -d "$ICONSET" ] && [ -f "$ICONSET/Contents.json" ]; then
  expected=$(jq -r '.images[].filename // empty' "$ICONSET/Contents.json" \
    | grep -v '^$')
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    [ ! -f "$ICONSET/$f" ] && \
      WARNINGS="${WARNINGS}\nICON: missing iOS icon variant ${f}"
  done <<< "$expected"
fi

# 2. Android density coverage
ANDROID_RES="android/app/src/main/res"
if [ -d "$ANDROID_RES" ]; then
  for d in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
    [ ! -f "$ANDROID_RES/mipmap-${d}/ic_launcher.png" ] && \
    [ ! -f "$ANDROID_RES/mipmap-${d}/ic_launcher.webp" ] && \
      WARNINGS="${WARNINGS}\nICON: missing Android mipmap-${d} launcher"
  done
  # Adaptive icon components
  [ ! -f "$ANDROID_RES/mipmap-anydpi-v26/ic_launcher.xml" ] && \
    WARNINGS="${WARNINGS}\nICON: missing Android adaptive launcher xml"
fi

# 3. PWA manifest
MANIFEST="public/manifest.json"
if [ -f "$MANIFEST" ]; then
  jq -r '.icons[]?.src' "$MANIFEST" | while IFS= read -r src; do
    [ -z "$src" ] && continue
    [ ! -f "public/${src#/}" ] && \
      echo "ICON: PWA manifest references missing ${src}" >&2
  done
fi

# 4. Naming + size sweep on raster assets
find assets -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.webp' \) 2>/dev/null \
  | while IFS= read -r f; do
      base=$(basename "$f")
      size=$(wc -c < "$f" | tr -d ' ')
      # Naming: forbid spaces in any asset
      if printf '%s' "$base" | grep -q ' '; then
        echo "ASSET: '${f}' contains spaces — rename to camelCase or snake_case" >&2
      fi
      # Size budget
      if [ "$size" -gt 500000 ]; then
        echo "ASSET: '${f}' is $((size/1024)) KB — consider AVIF/WebP" >&2
      fi
    done

if [ -n "$WARNINGS" ]; then
  printf '=== Post-Merge Asset Warnings ===%b\n=================================\n' "$WARNINGS" >&2
fi

exit 0
```

## Wiring (when you adopt it)

In `app_dev/.claude/settings.json`:

```jsonc
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/validate-assets-post-merge.sh" }
        ]
      }
    ]
  }
}
```

The hook silently exits `0` when the command isn't `git merge`, so it
won't slow down regular bash usage.

## What it deliberately does **not** check

- **Pixel-perfect rendering**. Run a screenshot test on device farms,
  not in a hook.
- **Brand colour accuracy**. Eyeball + design-director review.
- **A11y traits on icons**. That belongs to the screen-level a11y
  audit, not the asset sweep.
- **Localised images**. Multi-locale image directories
  (`drawable-en-rGB/`, `Resources/en.lproj/`) need their own pass —
  out of scope for this hook to keep the runtime under a second.

## See also

- `app_dev/.claude/hooks/validate-assets.sh` — the per-file write
  variant, fires on every Edit/Write to an asset path.
- `app_dev/.claude/docs/coding-standards.md` — accessibility and
  naming standards.
