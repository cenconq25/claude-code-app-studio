---
name: extract
description: "Extracts patterns from existing source code into a structured system.md file — naming, state shape, navigation pattern, error handling, and component composition. Used as the first step inside /reverse-document and on its own when the team wants to capture undocumented conventions in a brownfield project."
argument-hint: "[path to source dir | file glob]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
model: sonnet
---

# Extract — Code Pattern Capture

Reads existing implementation and produces a system.md describing how the code is actually built — not how it should be. This is descriptive, not prescriptive.

Output: `design/extracted/<system-or-area>.md`

---

## Purpose / When to Run

Run when:
- A brownfield project has working code but no design docs
- `/reverse-document` is running and needs the extracted patterns as input
- The team wants a "this is how we currently do it" snapshot before making a change

Distinct from `/design-system` (which authors a forward-looking PRD) and `/architecture-decision` (which records a deliberate decision). This skill captures **observed reality** so a future PRD or ADR can be written against an honest baseline.

## Inputs

- Required: a path or glob pointing to the source files to analyze (e.g., `src/screens/auth/`, `lib/features/onboarding/**/*.dart`)
- The framework (read from `.claude/docs/technical-preferences.md`)

## Outputs

- `design/extracted/<system-name>.md`

---

## Phase 1: Resolve Scope

If no path was passed, ask:
- **Prompt**: "Which area of code should I extract patterns from?"
- **Options**:
  - `Screens / pages` — `src/screens/**`, `lib/features/**`, `app/Sources/**/Views/`
  - `State management` — wherever the app's stores / view models live
  - `Networking / API client` — fetchers, interceptors
  - `Navigation` — routing config, deep links
  - `Specific subdirectory` — free text path

Use Glob to confirm the target exists and resolve to a list of files. Cap at ~50 files for one extraction; if more, sample and ask whether to chunk.

Determine the **system name** from the path (e.g., `src/screens/auth/` → `auth`).

---

## Phase 2: Read & Skim

Read each file. For each, classify by role: screen, component, hook/composable, store, service, util, type definition, test.

While reading, build a fact table per file:
- Imports (which dependencies and from where)
- Exported names
- State shape (if a store)
- Side effects (network calls, persistence reads/writes, navigation)
- Error handling pattern

Do not summarize each file in the output — the goal is the cross-file pattern.

---

## Phase 3: Identify Patterns

Group findings into pattern categories:

### 3a: Naming

- File naming: `kebab-case.tsx`, `PascalCase.swift`, etc.
- Component naming: `<ScreenName>Screen.tsx`, `<Feature>Page.dart`
- State naming: `useAuthStore`, `AuthViewModel`, `AuthBloc`
- Hooks/composables: `useX`, `with<X>`

### 3b: State management

What library or pattern shows up:
- React Native: Redux, Zustand, Jotai, MobX, Context+useReducer
- Flutter: Provider, Riverpod, BLoC, GetX
- iOS native: ObservableObject, TCA, Combine, Redux-style
- Android native: ViewModel + StateFlow, MVI, Compose state

Capture **how** state is shaped (entity vs. ui state, normalized vs. nested), and **where** mutations happen.

### 3c: Navigation

- Library: React Navigation, Expo Router, GoRouter, NavigationStack, Compose Navigation, etc.
- Pattern: stack / tab / drawer / mixed
- Deep-link handling: present? where?
- Auth-gated routes: pattern used

### 3d: Networking

- Client library: fetch, Axios, Dio, URLSession, Ktor, Retrofit
- Auth: token in headers, biometric refresh, etc.
- Error handling: thrown / Result type / sealed class

### 3e: Error & loading states

- How does code handle network failures, timeouts, validation errors
- Where do loading indicators live (per-screen, global, hooked into store)

### 3f: Persistence

- Local storage: AsyncStorage, MMKV, SharedPreferences, UserDefaults, Hive, Drift, SwiftData
- Secure storage: Keychain, EncryptedSharedPreferences, react-native-keychain
- Cache invalidation: pattern observed

### 3g: Testing

- Test framework actually used
- Files-with-tests vs. files-without — count

### 3h: Dependencies

- Top 10 third-party deps from package.json / pubspec.yaml / Podfile / build.gradle

---

## Phase 4: Spot Inconsistencies

The point of extraction is to surface drift. For each pattern category, note where the codebase **disagrees with itself**:
- "12 screens use `useAuthStore`, 3 use `useContext(AuthContext)` directly."
- "8 services throw on error; 2 return `Result<T, E>`."
- "Most screens have a `Loading` state; 4 do not."

Inconsistencies are not bugs — they are evidence the team has not made a decision. List each one for the eventual ADR.

---

## Phase 5: Draft system.md

Write `design/extracted/<system-name>.md`:

```markdown
# Extracted Patterns: <System Name>

> **Status**: Descriptive (not prescriptive)
> **Source path**: <glob>
> **Files analyzed**: <count>
> **Extracted on**: <date>
> **Framework**: <name + version from technical-preferences.md>

## 1. Summary
[3-4 sentences describing what this code does, in plain terms.]

## 2. Naming Patterns
- Files: <observed convention>
- Components: <observed convention>
- State: <observed convention>
- Tests: <observed convention>
[Note any inconsistencies.]

## 3. State Management
- Library: <name>
- Shape: <entity-first / ui-first / mixed>
- Mutation pattern: <where mutations occur>
- Example: <one short snippet showing the dominant pattern, paraphrased>

## 4. Navigation
- Library: <name>
- Top-level structure: <stack / tabs / drawer / mixed>
- Deep links: <present | not present>
- Auth gating: <pattern>

## 5. Networking
- Client: <library>
- Auth handling: <pattern>
- Error handling: <pattern>

## 6. Loading & Error States
- Loading: <pattern + where it lives>
- Error: <pattern + where it lives>
- Empty: <pattern, if observable>

## 7. Persistence
- Local: <library>
- Secure: <library or "none">

## 8. Testing
- Framework: <name>
- Coverage observation: <X of Y files have tests>

## 9. Inconsistencies Worth Resolving
- [list — each becomes a candidate ADR or PRD note]

## 10. Open Questions
- [things the code does not make obvious — invitation for the team to clarify]
```

Ask: "May I write this to `design/extracted/<system>.md`?"

---

## Phase 6: Hand-off Suggestion

After writing, suggest one of:
- `/reverse-document <system>` — generate a forward-looking PRD or architecture doc on top of this extraction
- `/architecture-decision <inconsistency>` — record a decision for one of the surfaced drifts
- `/design-system retrofit design/prd/<system>.md` — if a partial PRD exists, fill it from the extraction

---

## Examples

`/extract src/screens/onboarding/`
- 18 files: 6 screens, 4 hooks, 2 stores, 3 services, 3 types
- State: Zustand
- Navigation: React Navigation v6, stack inside a tab
- Inconsistency: 5 screens use `useAuthStore`, 1 still uses Context API directly
- Output: `design/extracted/onboarding.md`

`/extract lib/features/auth/`
- Flutter project, Riverpod state, GoRouter navigation
- Inconsistency: 2 services use `Result<T, AppError>`, 1 still throws
- Output: `design/extracted/auth.md`

---

## Quality Gates

- Output must be **descriptive**, not prescriptive — no "should" language.
- Inconsistencies section must list at least one item or explicitly state "no observed inconsistencies."
- File counts in the doc must match the glob result — no inflated numbers.
- The doc must not invent abstractions the code does not have. If code is messy, the doc says so.
