---
name: create-architecture
description: "Section-by-section authoring of the master architecture doc for the app. Reads all PRDs, systems index, existing ADRs, and the framework reference docs to produce a complete blueprint and a Required ADR list. Framework-version-aware: flags knowledge gaps and validates against the pinned framework. Run after /review-all-prds passes."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
model: sonnet
---

# Create Architecture

Produces the project's master architecture document — the technical blueprint that ADRs slot into. Without this, ADRs are scattered points without a structure.

Output: `docs/architecture/architecture.md`

---

## Purpose / When to Run

Run when:
- All MVP PRDs are individually approved and `/review-all-prds` returned PASS
- The team is ready to commit to top-level structure before writing ADRs

Distinct from `/architecture-decision` (single decision) — this skill creates the **frame** that decisions hang on, plus the list of which ADRs are required.

## Inputs

- All `design/prd/*.md`
- `design/systems-index.md`
- `design/concept.md`
- Existing `docs/architecture/ADR-*.md` (if any — typically retrofit)
- `docs/framework-reference/<framework>/`
- `.claude/docs/technical-preferences.md`

## Outputs

- `docs/architecture/architecture.md`
- A "Required ADRs" list inside that doc
- Optional initial `docs/architecture/architecture-registry.yaml` skeleton

---

## Phase 1: Pre-checks

- Confirm framework is pinned (`technical-preferences.md` not `[TO BE CONFIGURED]`)
- Confirm at least 80% of MVP PRDs are APPROVED in `design/systems-index.md`
- If `/review-all-prds` has not been run or returned PASS, warn: "Architecture without holistic PRD review can codify contradictions. Consider running `/review-all-prds` first." Allow proceed anyway.

If `docs/architecture/architecture.md` exists, ask:
- `Refresh sections (incremental)` — re-author specific sections
- `Rebuild from scratch (back up first)` — full new draft
- `Cancel`

---

## Phase 2: Read All Context

This skill is read-heavy. Hold in context:
- All PRDs
- Concept doc
- Systems index
- Existing ADRs (to integrate, not duplicate)
- Framework reference: VERSION.md, conventions.md, breaking-changes.md
- Technical preferences

Note knowledge-cutoff risk for the pinned framework — if HIGH, flag in the doc header that decisions in tricky domains must consult breaking-changes.md.

---

## Phase 3: Skeleton

Write `docs/architecture/architecture.md`:

```markdown
# Architecture — <App Name>

> **Status**: In Design
> **Last Updated**: <date>
> **Framework**: <name + version>
> **Knowledge Risk**: <LOW / MEDIUM / HIGH>

## 1. Goals & Constraints
[To be designed]

## 2. Top-level Structure
[To be designed]

## 3. Layers
[To be designed]

## 4. Cross-cutting Concerns
[To be designed]

## 5. Data Flow
[To be designed]

## 6. State Management
[To be designed]

## 7. Navigation
[To be designed]

## 8. Networking & API
[To be designed]

## 9. Persistence
[To be designed]

## 10. Auth & Identity
[To be designed]

## 11. Push & Background
[To be designed]

## 12. Analytics & Instrumentation
[To be designed]

## 13. Feature Flags & Remote Config
[To be designed]

## 14. Error Handling & Reporting
[To be designed]

## 15. Theming, Dark Mode, i18n
[To be designed]

## 16. Build, Release, CI
[To be designed]

## 17. Testing Strategy
[To be designed]

## 18. Performance Budgets
[To be designed]

## 19. Privacy & Security
[To be designed]

## 20. Required ADRs
[To be designed — generated last]
```

Ask before write.

---

## Phase 4: Section Authoring (cycle each)

For each section, do:

```
Context (summarize relevant PRDs) → Question(s) → Options → Decision → Draft → Approval → Write
```

### Section 1: Goals & Constraints

From concept doc + PRDs, list:
- Primary goal (the JTBD)
- Quality goals (perf, accessibility, reliability)
- Hard constraints (min OS, regulatory, store policies)
- Resource constraints (team size, timeline)

### Section 2: Top-level Structure

A high-level diagram of the app's modules:
```
App
 ├─ Core (auth, persistence, networking)
 ├─ Features (each major user-facing system)
 ├─ Shared (UI components, utilities, design tokens)
 └─ Platform (iOS-specific, Android-specific, native modules)
```

Concrete folder paths per the framework's conventions.

### Section 3: Layers

Common layering:
- Presentation (screens, components)
- State / view model
- Domain / use case (optional — depends on team complexity)
- Data (services, repositories)
- Infrastructure (cross-cutting)

For each layer, declare what it knows and does not know:
- Presentation knows nothing about persistence
- State knows nothing about UI rendering
- Data knows nothing about state shape

These rules become forbidden patterns in `/create-control-manifest`.

### Section 4: Cross-cutting Concerns

For each: which library/pattern, where it is wired, who uses it.
- Authentication
- Logging
- Error reporting (Sentry / Crashlytics)
- Analytics
- Feature flags
- Theming
- i18n
- Permissions
- Deep links
- Push notifications

Each becomes a candidate ADR.

### Section 5: Data Flow

Describe the dominant flow direction:
```
UI → ViewModel/Store → UseCase/Service → API/Persistence
        ↑                                    │
        └────────── State / Result ─────────┘
```

Note exceptions and document them.

### Section 6: State Management

Reference the chosen library (or candidate options). Will become an ADR if not yet decided.

For framework-pinned tendencies:
- RN: Zustand / Redux / Jotai / MobX — recommend based on app complexity
- Flutter: Riverpod / BLoC / Provider
- iOS: TCA / ObservableObject + Combine / Redux-style
- Android: ViewModel + StateFlow / MVI

### Section 7: Navigation

- Library
- Top-level structure (tabs / stack / drawer / mixed)
- Auth gating (where the redirect happens)
- Deep link strategy (universal links / app links / scheme)

### Section 8: Networking & API

- Client library
- Auth (header injection, refresh)
- Error model (Result / sealed class / thrown)
- Retry / timeout defaults
- Offline strategy

### Section 9: Persistence

- Local DB (SQLite / Hive / Realm / SwiftData / Room)
- Cache layer (HTTP cache / custom)
- Secure storage (Keychain / EncryptedSharedPreferences / KeyStore)
- Migration strategy

### Section 10: Auth & Identity

- Provider (custom / Auth0 / Firebase / Apple Sign In / Google Sign In / OIDC)
- Token storage and rotation
- Session expiry handling
- Multi-factor support
- Biometric unlock

### Section 11: Push & Background

- Push provider (FCM / APNS direct / OneSignal / etc.)
- Token storage and rotation
- Permission timing
- Categories / channels
- Deep link from notification
- Background tasks: which framework API (BGTaskScheduler / WorkManager / RN background-fetch)

### Section 12: Analytics & Instrumentation

- Provider (Amplitude / Mixpanel / Firebase / Segment)
- Event vocabulary policy (snake_case / camelCase, named conventions)
- User identification policy (opt-in for analytics if regulated)
- Naming registry — refer to a single source of truth (often `design/registry/entities.yaml`)

### Section 13: Feature Flags & Remote Config

- Provider (LaunchDarkly / ConfigCat / Firebase Remote Config / custom)
- Default values shipped in the bundle
- Sampling for A/B tests
- Kill-switch flags

### Section 14: Error Handling & Reporting

- Crash reporting (Sentry / Crashlytics / Bugsnag)
- Error boundaries (RN)
- Recoverable vs. fatal classification
- User-facing error UX (toast / screen / inline)

### Section 15: Theming, Dark Mode, i18n

- Token export pipeline (Style Dictionary / native)
- Dark-mode strategy (mirror tokens vs. defer)
- Locale loading (synchronous bundle vs. dynamic fetch)
- RTL support

### Section 16: Build, Release, CI

- Build flavors / configurations (dev, staging, prod)
- Codepush / OTA strategy if RN
- CI: GitHub Actions / Bitrise / Xcode Cloud — pick one
- Code signing
- Store provisioning

### Section 17: Testing Strategy

- Unit (test runner from technical-preferences)
- Component / widget tests
- Integration tests
- E2E (Detox / Maestro / EarlGrey / Espresso)
- Manual evidence (screenshots, walkthrough docs)
- CI gates

### Section 18: Performance Budgets

Concrete numbers:
- Cold start time target (ms)
- TTI (time-to-interactive) per screen
- Frame rate (60fps default; 120fps for ProMotion / 90fps Android)
- App size budget
- Memory ceiling
- Network: bytes per session

### Section 19: Privacy & Security

- Data minimization
- Encryption at rest
- TLS pinning (or explicit non-pinning rationale)
- Secret management
- App Tracking Transparency (iOS)
- Play Data Safety (Android)
- GDPR / CCPA stance

### Section 20: Required ADRs

Generate from Sections 6-19. Each cross-cutting decision needs an ADR. Output as a numbered list:

```
| Required ADR | Domain | Status | Priority |
|--------------|--------|--------|----------|
| state-management | State | Not yet written | P0 |
| navigation-library | Navigation | Not yet written | P0 |
| auth-token-storage | Auth | Not yet written | P0 |
| push-provider | Push | Not yet written | P1 |
| analytics-vocabulary | Analytics | Not yet written | P0 |
| feature-flag-provider | Feature flags | Not yet written | P1 |
| error-reporting | Error | Not yet written | P0 |
| testing-strategy | Testing | Not yet written | P0 |
| performance-budgets | Performance | Not yet written | P1 |
| ... | | | |
```

P0 ADRs gate stories — engineering work cannot proceed safely without them. P1 can be written during sprint zero.

---

## Phase 5: Specialist Synthesis

Spawn `Task` to:
- `mobile-architect` — read the doc and flag inconsistencies, missing layers, or contradictions with PRDs
- Framework specialist — validate Sections 6-11, 16 are idiomatic for the pinned version

Integrate findings.

---

## Phase 6: Initialize Architecture Registry

Optionally write `docs/architecture/architecture-registry.yaml` skeleton:

```yaml
version: 1
state_ownership: []
interfaces: []
forbidden_patterns: []
performance_budgets: []
api_decisions: []
```

Ask before writing.

---

## Phase 7: Hand Off

Print:
> "Architecture written. Required ADR list has <N> entries. Run `/architecture-decision <slug>` for each P0 entry next. Run `/architecture-review` (in fresh session) once all P0 ADRs are written."

Use `AskUserQuestion`:
- `Write the first P0 ADR now`
- `Run /architecture-review (after ADRs)` — disabled if no P0 ADR is yet Accepted
- `Stop here`

Update `production/session-state/active.md` with the architecture status and the next P0 ADR to write.

---

## Quality Gates

- All 20 sections non-empty
- Required ADRs section lists at least the P0 set
- Performance budgets are numeric (no "fast", "small")
- Privacy section names specific stances (not "TBD")
- Cross-cutting concerns each have a named library or "deferred to ADR"
- Knowledge-risk warning is shown if framework risk is HIGH

---

## Examples

A typical mobile MVP arch doc has ~20 sections, 8-12 P0 ADRs identified, and ~5-7 P1 ADRs. The Required ADR list includes state mgmt, nav, auth, push, analytics, error, testing, performance budgets at minimum.
