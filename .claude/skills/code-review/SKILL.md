---
name: code-review
description: "Architectural and quality review of one or more files. Verifies coding standards, SOLID, testability, mobile anti-patterns, and ADR compliance. Use after /dev-story and before /story-done."
argument-hint: "[file-or-directory-path]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Task
agent: lead-developer
model: sonnet
---

# Code Review

Read-only quality pass over a recent change. Confirms the diff respects the
project's coding rules, the governing ADR, and mobile-specific health checks
(cold start, frame budget, memory, battery, deep-link surface).

---

## Phase 1: Load Targets

Read the target file(s) in full. If a directory is given, glob it for source
files (`*.ts`, `*.tsx`, `*.js`, `*.dart`, `*.swift`, `*.kt`, `*.kts`,
`*.java`, `*.m`, `*.mm`).

Read `CLAUDE.md` and `.claude/docs/coding-standards.md` to refresh the active
project rules. Read `.claude/docs/technical-preferences.md` to capture frame
budget, cold-start budget, memory ceiling, and forbidden patterns.

---

## Phase 2: Identify Framework Specialists

Open the `## Framework Specialists` section of `technical-preferences.md`.
Note:

- Primary specialist (architecture and lifecycle calls).
- Language/UI specialist (RN screens, SwiftUI views, Compose composables,
  Flutter widgets).
- Native modules / platform channels specialist (bridges, JNI, Obj-C++).
- State management specialist (Redux, Riverpod, MVI, Combine, etc.).

If the section is `[TO BE CONFIGURED]`, skip the framework-specialist phase.

---

## Phase 3: ADR Compliance

Search the changed files (and any matching story file) for ADR references:
patterns like `ADR-NNN`, `docs/architecture/ADR-`, or
`Governing ADR:`. If none are found, log: "No ADR references found — ADR
compliance check skipped."

For each referenced ADR, read it and pull out the Decision and Consequences
sections. Classify each deviation:

- BLOCKING — the code uses a pattern explicitly rejected by the ADR.
- DRIFT — the code diverges from the chosen approach without using a
  forbidden pattern.
- MINOR — small textual difference that does not change architecture.

---

## Phase 4: Standards Compliance

For each target file, score these checks:

- [ ] All public APIs (exports, public methods, public protocols) carry doc
      comments.
- [ ] No method exceeds 40 lines (excluding data declarations).
- [ ] Cyclomatic complexity stays under 10 per method.
- [ ] Dependencies are injected; no module-scope singletons holding mutable
      app state.
- [ ] Tunable values come from config/remote config, not magic numbers.
- [ ] Modules expose interfaces (TS interface, Swift protocol, Kotlin
      interface, abstract Dart class) rather than concrete implementations.
- [ ] No hardcoded user-facing strings — all strings flow through the
      localization system.

Cite line numbers for every failure.

---

## Phase 5: Architecture and SOLID

**Architecture:**

- [ ] Dependency direction is correct (UI -> domain -> data, never reverse).
- [ ] No circular module imports.
- [ ] UI does not own domain state directly; state passes through a state
      container.
- [ ] Cross-feature communication goes through events / streams /
      navigation, not direct calls.
- [ ] New code matches the patterns already in the codebase — flag novelty.

**SOLID:**

- [ ] Single Responsibility: each class/screen/hook has one reason to change.
- [ ] Open/Closed: extension via composition, not edits to closed code.
- [ ] Liskov Substitution: subtypes honour parent contracts.
- [ ] Interface Segregation: no fat protocols/interfaces.
- [ ] Dependency Inversion: depend on abstractions, not concretes.

---

## Phase 6: Mobile-Specific Concerns

- [ ] Cold-start budget respected — no synchronous heavy work in app entry,
      `AppDelegate.didFinishLaunching`, `MainActivity.onCreate`, or React
      Native `App.tsx` top-level.
- [ ] No allocations in animation callbacks, gesture handlers, or list
      cell builders.
- [ ] List rendering uses virtualization (`FlatList`/`SectionList`,
      `LazyColumn`, `LazyVStack`, `ListView.builder`).
- [ ] Image loads use a cache layer (FastImage, Coil, SDWebImage,
      cached_network_image).
- [ ] Network calls have explicit timeout, retry, and offline handling.
- [ ] Background work uses platform-correct APIs (WorkManager, BGTaskScheduler).
- [ ] Deep links and universal links validate input before navigating.
- [ ] Sensitive data lands in Keychain / Keystore, never AsyncStorage,
      SharedPreferences, NSUserDefaults, or unencrypted SQLite.
- [ ] Battery-affecting features (location, camera, BLE) release resources
      on screen exit.
- [ ] No string-concatenated SQL; use parameterized queries.
- [ ] Memory: no retain cycles in closures (Swift `[weak self]`, Dart
      avoid capturing State, RN avoid capturing component refs).

---

## Phase 7: Specialist Reviews (in parallel)

Spawn every applicable specialist via Task at the same time — do not chain.

### Framework specialists

Decide per file:

- React Native screens / hooks / RN-specific code -> RN specialist.
- Flutter widgets / Dart code -> Flutter specialist.
- SwiftUI / UIKit / Swift code -> iOS specialist (UI variant if SwiftUI).
- Compose / Views / Kotlin code -> Android specialist (Compose variant if
  Compose).
- Native module / platform channel / JNI code -> native modules specialist.
- Cross-cutting (build config, app entry, lifecycle) -> primary specialist.

### Testability review

For Logic and Integration stories, also spawn `qa-tester` in parallel. Pass:

- The diff under review.
- The story's `## QA Test Cases` section.
- The story's Acceptance Criteria.

Ask qa-tester to verify:

- [ ] Test seams exist — public hooks, exported functions, dependency
      injection points.
- [ ] Each QA test case maps to a code path that is reachable in test mode.
- [ ] No AC is hidden behind a hardcoded value or non-injectable singleton.
- [ ] No new edge cases are introduced without a corresponding test.
- [ ] Observable side effects (analytics events, navigation, persistence)
      have at least an interaction test.

For Visual/Feel and UI stories: qa-tester instead checks that the manual
verification steps in QA Test Cases are physically reachable in the build
(e.g., the state transition the tester needs to observe is reachable).

Wait for all specialists to return before composing output.

---

## Phase 8: Render the Review

```
## Code Review: [target]

### Framework Specialist Findings: [N/A | CLEAN | ISSUES]
[per-specialist output]

### Testability: [N/A | TESTABLE | GAPS | BLOCKING]
[qa-tester output — list test seams missing or untestable ACs]

### ADR Compliance: [NONE FOUND | COMPLIANT | DRIFT | BLOCKING]
[ADR-by-ADR result and severity]

### Standards Compliance: [X/7 passing]
[failures with file:line]

### Architecture: [CLEAN | MINOR | VIOLATIONS]
[specific concerns]

### SOLID: [COMPLIANT | ISSUES]
[specific violations]

### Mobile-Specific Concerns
[cold start, frame budget, battery, secure storage, deep links, etc.]

### Positive Observations
[Always include — what the change did well]

### Required Changes
[Must-fix before approval. Any BLOCKING ADR finding lands here.]

### Suggestions
[Nice-to-have improvements]

### Verdict: [APPROVED | APPROVED WITH SUGGESTIONS | CHANGES REQUIRED]
```

This skill writes nothing to disk.

---

## Quality Gates / PASS-FAIL

- APPROVED — every required check passed and no BLOCKING items remain.
- APPROVED WITH SUGGESTIONS — required checks passed; nice-to-haves remain.
- CHANGES REQUIRED — at least one BLOCKING ADR violation, standards
  failure, mobile anti-pattern, or testability gap is present.

---

## Examples

**Example 1 — A new RN list screen:**
Reads `src/screens/inbox/InboxScreen.tsx`, finds ADR-022 (list virtualization
policy), spawns RN specialist + qa-tester, flags an inline `.map()` over
2000+ items as a frame-budget violation, returns CHANGES REQUIRED.

**Example 2 — A pricing config edit:**
Single file `assets/data/pricing.json`. Standards check passes; no ADR
referenced. qa-tester confirms a smoke check exists for the price flow.
Verdict: APPROVED.

---

## Next Steps

- APPROVED -> run `/story-done [story-path]`.
- CHANGES REQUIRED -> fix and re-run `/code-review`.
- BLOCKING ADR violation -> run `/architecture-decision` to capture the
  correct approach before re-implementing.
