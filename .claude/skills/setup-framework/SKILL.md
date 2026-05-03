---
name: setup-framework
description: "Pins the project's mobile framework (React Native, Flutter, iOS native, Android native), captures the version, populates docs/framework-reference/<framework>/, and writes the Framework field to technical-preferences.md and CLAUDE.md. Use this once during early onboarding before any PRD or ADR authoring. Knowledge-cutoff aware: uses WebSearch to verify versions newer than the model's training data."
argument-hint: "[framework: react-native | flutter | ios | android] [--version <ver>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion, WebSearch
model: sonnet
---

# Set Up the Framework

The framework decision shapes everything downstream — the language used in PRDs' Implementation Hooks, the ADR Framework Compatibility tables, the test runner, the CI script, the platform-conventions checks in `/ux-review`, and the reverse-doc parser.

This skill is meant to be run **once** per project. Re-running it is allowed but flags potential damage.

---

## Purpose / When to Run

Run when:
- The Framework field in `.claude/docs/technical-preferences.md` is `[TO BE CONFIGURED]`
- The user picked a platform-first answer in `/brainstorm` and is ready to commit
- A brownfield audit (`/adopt`) flagged the framework as a HIGH gap

Do not re-run when the framework is already pinned and code exists — propose `/architecture-decision` to record a framework migration instead.

## Inputs

- Optional framework arg
- Optional `--version <ver>` arg
- `.claude/docs/technical-preferences.md` (current state)
- `package.json`, `pubspec.yaml`, `*.xcodeproj`, `app/build.gradle` (existing code signal)

## Outputs

- `docs/framework-reference/<framework>/VERSION.md` — version snapshot, knowledge-gap warning
- `docs/framework-reference/<framework>/conventions.md` — naming, structure, build, test commands
- `docs/framework-reference/<framework>/breaking-changes.md` — post-cutoff breaking changes
- `.claude/docs/technical-preferences.md` — Framework, Language, Rendering, Testing fields populated
- Optional update to `CLAUDE.md` (replace the placeholder bullet)

---

## Phase 1: Detect Existing State

Glob and report before asking anything:
- `package.json` exists? Look for `react-native` in dependencies → suggests RN
- `pubspec.yaml` exists? → suggests Flutter
- `*.xcodeproj` or `Package.swift` exists at root? → iOS native
- `settings.gradle` or `app/build.gradle` exists? → Android native
- Read `.claude/docs/technical-preferences.md`

If the existing code clearly contradicts the user's argument, surface the conflict before proceeding:
> "Argument says React Native, but `pubspec.yaml` is present — Flutter project. Confirm: pin Flutter, pin RN despite the file, or stop?"

---

## Phase 2: Confirm Framework

If no argument was passed, use `AskUserQuestion`:
- **Prompt**: "Which framework will this project use?"
- **Options**:
  - `React Native` — JS/TS, cross-platform, Expo or bare
  - `Flutter` — Dart, cross-platform
  - `iOS native` — Swift / SwiftUI
  - `Android native` — Kotlin / Jetpack Compose
  - `Other` — describe (free text — capture but flag that the rest of the template assumes one of the four)

If the user picked an existing-code-detected framework, skip confirmation.

---

## Phase 3: Resolve Version

If `--version` was passed, use it.

Otherwise, attempt to detect from existing files:
- `package.json` → `dependencies["react-native"]`
- `pubspec.yaml` → `environment.flutter` or `dependencies.flutter.sdk`
- iOS native → look for `IPHONEOS_DEPLOYMENT_TARGET` in xcodeproj or `Package.swift` swift-tools-version
- Android native → look for `compileSdk` and Kotlin version in `build.gradle`

If no version can be detected, use `WebSearch` to find the current stable release and ask the user:
- **Prompt**: "What version do you want to pin? Current stable is [version]."
- **Options**: `Latest stable [version]`, `Specific version (free text)`, `LTS line if available`

Capture the chosen version.

---

## Phase 4: Knowledge-Gap Check

The model has a knowledge cutoff. For frameworks that have shipped major versions since the cutoff, the model may not know about breaking changes.

Use `WebSearch` to query:
- `<framework> <version> release notes` — confirm the version exists and is GA
- `<framework> <previous-version> to <version> migration` — collect breaking changes
- `<framework> <version> deprecated APIs` — identify retired APIs

Classify the version's risk level:
- **LOW** — version pre-dates the model's knowledge cutoff
- **MEDIUM** — version released within ~6 months of cutoff
- **HIGH** — version released after cutoff

Capture the verified facts and the risk classification. They feed the VERSION.md file.

---

## Phase 5: Populate Framework Reference Docs

### 5a: VERSION.md

Write `docs/framework-reference/<framework>/VERSION.md` with:

```markdown
# <Framework Name> — Version Reference

| Field | Value |
|-------|-------|
| **Framework** | <Name> |
| **Version** | <pinned version> |
| **Release Date** | <from WebSearch> |
| **Pinned On** | <today's date> |
| **Last Verified** | <today's date> |
| **LLM Knowledge Cutoff** | <model's known cutoff> |

## Knowledge Gap Risk

[Risk level: LOW / MEDIUM / HIGH]

[1-paragraph explanation. For HIGH risk, list the major versions the model does
not have detailed knowledge of, and instruct that all framework-specific ADRs
must cross-reference these reference docs before recommending an API call.]

## Verified Sources

- Official docs: <link>
- Migration guide: <link, if any>
- Release notes: <link>
- API reference: <link>
```

### 5b: conventions.md

Write `docs/framework-reference/<framework>/conventions.md` with:

```markdown
# <Framework> Conventions

## Naming
- Files: <camelCase / snake_case / PascalCase per framework>
- Components / Screens: <pattern>
- State containers: <pattern>
- Tests: <pattern>

## Project Structure
[Tree of canonical directories — `src/screens`, `src/components`, etc. for RN; `lib/` for Flutter; `Sources/` for SwiftPM, etc.]

## Build Commands
- Dev build: `<command>`
- Production build: `<command>`
- iOS-specific: `<command>` (cross-platform only)
- Android-specific: `<command>` (cross-platform only)

## Test Commands
- Unit: `<command>`
- Integration / widget / UI: `<command>`
- Coverage: `<command>`

## Lint / Format
- Lint: `<command>`
- Format: `<command>`

## Recommended Tooling
- Package manager: <npm / yarn / pnpm / bundler / pub / cocoapods / spm>
- Type system: <TypeScript / Swift / Kotlin / Dart>
- Linter: <ESLint / SwiftLint / detekt / flutter analyze>
```

Fill from the user's preferences plus framework defaults (e.g., for RN, ESLint + Prettier + Jest + Detox; for Flutter, `flutter test` + `flutter analyze`; for iOS native, XCTest + SwiftLint; for Android native, JUnit + detekt).

### 5c: breaking-changes.md

Write `docs/framework-reference/<framework>/breaking-changes.md` listing post-cutoff changes (from Phase 4). Each entry:

```markdown
## <version> — <change title>

- **What changed**: <one paragraph>
- **Impact**: <which APIs / patterns this affects>
- **Migration path**: <link to upstream migration doc>
- **LLM-knowledge note**: <does the model know about this? If unclear, mark VERIFY.>
```

If the version is LOW risk, leave this file with a single "No post-cutoff changes" line.

---

## Phase 6: Update technical-preferences.md and CLAUDE.md

Edit `.claude/docs/technical-preferences.md`:
- `Framework` → `<name> <version>`
- `Language` → `<TypeScript / Swift / Kotlin / Dart>`
- `Rendering` → `<UIKit/SwiftUI / Jetpack Compose / Flutter / React Native CLI or Expo>`
- `Physics` → strike out — mobile apps usually do not need this; the field is a leftover. Mark `N/A`.
- `Target Platforms` → `<iOS / Android / both>`
- `Input Methods` → `<Touch / Keyboard / Voice>` based on user input in Phase 7
- `Testing → Framework` → `<Jest / XCTest / JUnit / flutter_test>`
- `Naming Conventions` → reference `docs/framework-reference/<framework>/conventions.md`

Use Edit tool for each field — never overwrite the file in one shot.

Edit `CLAUDE.md`:
- Replace the `[CHOOSE: ...]` placeholder for Framework / Language with the pinned values
- Update the version-reference include path

Ask before each Edit: "May I update technical-preferences.md to set Framework to `<name> <version>`?"

---

## Phase 7: Capture Platform Constraints

Use `AskUserQuestion`:
- **Prompt**: "Which platforms ship in v1?"
- **Options**: `iOS only`, `Android only`, `Both at once`, `iOS first, Android later`, `Android first, iOS later`

Use `AskUserQuestion`:
- **Prompt**: "Minimum OS versions supported?"
- **Options**: `iOS 15+`, `iOS 16+`, `iOS 17+`, `Android API 26+ (8.0)`, `Android API 30+ (11)`, `Android API 33+ (13)`, `Custom (free text)` — show only relevant options for the chosen platforms

Capture and write into `technical-preferences.md` under `Platform Notes`.

---

## Phase 8: Wire Test Framework

Append to `technical-preferences.md`:
- Unit-test framework name + recommended runner command
- Integration / UI test framework
- A note that `/dev-story` and `/qa-plan` will use these commands

If the user wants the test scaffolding stood up immediately, suggest running the dev-side `/test-setup` skill (in the second skill set) afterward.

---

## Phase 9: Confirm Setup

Print a summary block:
```
Framework pinned: <name> <version>
Risk: LOW / MEDIUM / HIGH
Reference docs at: docs/framework-reference/<framework>/
Test commands: <unit>, <integration>
Min OS: <iOS X.X>, <Android API NN>
```

Ask: "Run `/architecture-decision framework-pin` to record this as an ADR?" — Optional, recommended for HIGH-risk pins. The user decides.

---

## Edge Cases

- **Re-running on a project with code**: warn loudly. Do not overwrite VERSION.md without explicit confirmation. Offer to migrate-pin instead.
- **Mixed-framework projects** (e.g., RN with native modules): pin the dominant one, note the supplementary one in `Platform Notes`.
- **WebSearch is unavailable**: continue with model knowledge but mark the version risk as HIGH and `Last Verified` as "deferred — re-run when offline" warning.

---

## Quality Gates

- After running, `Framework` field in `technical-preferences.md` must not contain `[TO BE CONFIGURED]`.
- `docs/framework-reference/<framework>/VERSION.md` must exist with non-empty version and risk fields.
- `breaking-changes.md` must exist (even if empty for LOW risk).
- The user must have explicitly approved each Edit.

---

## Examples

`/setup-framework react-native --version 0.76`
- Pins React Native 0.76 + TypeScript 5.4 + Expo SDK 51.
- Populates `docs/framework-reference/react-native/VERSION.md` with New Architecture (Bridgeless, Fabric, TurboModules) notes and Hermes default.
- Risk: MEDIUM — model knows up to 0.74; verifies 0.75-0.76 via WebSearch.

`/setup-framework flutter`
- Asks for version. User picks 3.24.
- Populates Flutter / Dart 3.5, Impeller default, Material 3 conventions.
- Notes Play Store and App Store min-version policies for the chosen Dart SDK.

`/setup-framework ios`
- Pins iOS 17 minimum, Swift 6 strict concurrency, SwiftUI as the default UI layer.
- Notes Live Activities, App Intents, and Widgets as available platform features.
