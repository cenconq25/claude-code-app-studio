---
name: create-control-manifest
description: "Produces a flat, immediately-actionable rules sheet — do this, never do that, per system and per layer — extracted from accepted ADRs, technical preferences, and framework reference docs. More directly usable than ADRs for day-to-day implementation. Run after /architecture-review passes."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
model: sonnet
---

# Create Control Manifest

ADRs explain **why**. The control manifest tells engineers **what to do** and **what not to do** in implementation, scoped to systems and layers, dated and versioned.

Output: `docs/architecture/control-manifest.md`

---

## Purpose / When to Run

Run when:
- All P0 ADRs are Accepted
- `/architecture-review` returned PASS
- The team is about to start the first sprint
- ADRs change in a way that affects implementation rules

The manifest is the single doc engineers reference at code-review time. Stories cite a Manifest Version date so they pin against a known rule set.

## Inputs

- All Accepted `docs/architecture/ADR-*.md`
- `docs/architecture/architecture.md`
- `docs/architecture/architecture-registry.yaml` (if present)
- `.claude/docs/technical-preferences.md`
- `docs/framework-reference/<framework>/conventions.md`

## Outputs

- `docs/architecture/control-manifest.md`

---

## Phase 1: Pre-checks

- Confirm at least one Accepted ADR exists
- Confirm `/architecture-review` was last run with verdict PASS or CONCERNS (warn for CONCERNS — manifest will codify approved rules but still call out the unresolved concerns)
- If a previous manifest exists, ask: `Refresh existing`, `Replace from scratch`, `Cancel`

---

## Phase 2: Read All ADRs

For each Accepted ADR:
- Decision section
- Key Interfaces
- Consequences (Negative — these often map to forbidden patterns)
- Performance Implications (these become guardrails)
- Mobile-Specific Considerations

For each, extract:
- **Required patterns** — "use X for Y"
- **Forbidden patterns** — "do not use X for Y"
- **Guardrails** — "X must be under Y ms" or "X must not exceed Y MB"
- **Owner** — which system or layer enforces this

---

## Phase 3: Group by Layer and System

The manifest organizes rules so an engineer working in a layer can read only the rules relevant to that layer. Layers from `architecture.md` Section 3:

- Presentation
- State / view model
- Domain / use case (if applicable)
- Data
- Infrastructure / cross-cutting

Within each layer, group rules by system (auth, payments, push, etc.).

For cross-cutting concerns (logging, error reporting, analytics, theming, i18n, accessibility), keep a global section that all layers must respect.

---

## Phase 4: Draft the Manifest

Write `docs/architecture/control-manifest.md`:

```markdown
# Control Manifest

> **Manifest Version**: <today's date>
> **Source**: <N> Accepted ADRs + architecture.md
> **Framework**: <name + version>
> **Status**: Active

This document is the authoritative rules sheet for implementation. Every story in this sprint cycle pins to **Manifest Version: <date>**. When ADRs change, regenerate this manifest and update story headers.

---

## Global Rules (apply everywhere)

### Required
- All public APIs have doc comments. (Coding standards)
- All gameplay-critical… [adapt for app] All user-visible text uses i18n keys, never inline literals. (ADR-NNNN)
- All errors reach error reporting via the central handler — never silently swallowed. (ADR-NNNN)
- All analytics events use names from `design/registry/entities.yaml`. (ADR-NNNN)

### Forbidden
- Do not import from `Presentation` into `Data` (or vice versa). (Architecture Section 3)
- Do not commit secrets. Use the secret manager. (ADR-NNNN)
- Do not use deprecated APIs listed in `docs/framework-reference/<framework>/breaking-changes.md`.
- Do not bypass the type system with `any` / `Any` / `dynamic` without a `// SAFETY:` comment justifying it.

### Guardrails (numeric)
- Cold start: < 1500ms on reference device (ADR-NNNN)
- Frame rate: 60fps min, 0 dropped frames during scroll (ADR-NNNN)
- App size: under <NN>MB (ADR-NNNN)
- Memory ceiling: <NN>MB at peak (ADR-NNNN)

---

## Layer: Presentation

### Required
- Components consume tokens from the design bible by name; never inline raw colors / sizes. (Bible + ADR-NNNN)
- Every interactive element has accessibility props (label, role). (ADR-NNNN)
- Loading, empty, error, offline states implemented for every screen. (ADR-NNNN)

### Forbidden
- No business logic in components — delegate to ViewModel / store. (Architecture Section 3)
- No direct network calls from components. Use the data layer. (Architecture Section 3)
- No direct AsyncStorage / SharedPreferences / UserDefaults reads in components. (Architecture Section 3)

### System: Auth UI
- Login screens must call `authStore.login()`, never the network client directly. (ADR-0003)
- Biometric prompt must be triggered only after explicit user opt-in in settings. (ADR-0007)

[... per system ...]

---

## Layer: State / ViewModel

### Required
- State stores follow the pattern defined in ADR-NNNN.
- All async operations expose a `loading` and `error` state.
- State updates are immutable — produce new objects, do not mutate.

### Forbidden
- No UI primitives in stores (no `Color`, no `View`, no `Composable`). (Architecture Section 3)
- No global mutable singletons. (ADR-NNNN)
- No cross-store imports — coordinate via events. (ADR-NNNN)

[... per system ...]

---

## Layer: Domain / Use Case (if used)

[... rules ...]

---

## Layer: Data

### Required
- All API calls go through the central client. (ADR-NNNN)
- All sensitive values live in secure storage. (ADR-NNNN)
- All data models are explicit types — no `Map<String, Any>` blobs.

### Forbidden
- No business rules here — services pass data through. (Architecture Section 3)
- No direct UI imports. (Architecture Section 3)

### System: Network
- Always include the auth header (managed by interceptor). (ADR-NNNN)
- Use the central error type — do not throw raw exceptions to UI.
- Default timeout: <Nms>; do not raise without justification. (ADR-NNNN)

### System: Persistence
- Schema migrations are versioned and tested. (ADR-NNNN)
- Secure data uses Keychain / EncryptedSharedPreferences / KeyStore — never plain storage. (ADR-NNNN)

---

## Layer: Infrastructure / Cross-cutting

### Analytics
- Event names follow <case> from `design/registry/entities.yaml`.
- Required PII fields stripped before send. (ADR-NNNN)

### Error reporting
- All thrown errors reach Sentry (or chosen provider). (ADR-NNNN)
- User-facing errors include a code for support. (ADR-NNNN)

### Theming / Dark Mode
- All color references go through tokens. No raw hex outside the bible.
- Dark-mode support is mandatory at v1. (ADR-NNNN)

### Localization
- Every visible string is wrapped in `t(...)` / `Localizable.strings` / Compose `stringResource` per framework. (ADR-NNNN)
- Never use string interpolation with hardcoded English. (ADR-NNNN)

### Permissions
- Permission prompts are deferred to in-context user actions, never on first launch. (ADR-NNNN)
- Denied state has explicit recovery UX. (ADR-NNNN)

### Push notifications
- Token registration / rotation handled centrally. (ADR-NNNN)
- Categories / channels match the registered list. (ADR-NNNN)

### Background tasks
- Use the framework-approved API (BGTaskScheduler / WorkManager / RN background-fetch). (ADR-NNNN)
- Respect Doze and BGTask limits — no work over budget. (ADR-NNNN)

### Privacy & Security
- TLS pinning enabled for production. (ADR-NNNN)
- Account deletion path implemented per store policy. (ADR-NNNN)
- ATT prompt shown only when needed. (ADR-NNNN)

### Testing
- Logic stories require an automated test that fails before fix and passes after. (ADR-NNNN)
- UI / Visual stories require a manual evidence doc. (ADR-NNNN)
- Smoke check passes before QA hand-off. (ADR-NNNN)

### Performance
- No blocking work on the main / UI thread. (ADR-NNNN)
- Lists virtualize at <N> items. (ADR-NNNN)
- Images use the framework-recommended caching library. (ADR-NNNN)

---

## Open Concerns (from `/architecture-review`)
- <list any HIGH findings that did not block PASS — these are caveats engineers should know>

## Versioning Note

When this manifest changes:
1. Update the Manifest Version date at the top
2. Existing in-progress stories pin to their original Manifest Version
3. New stories pin to the new Manifest Version
4. Run `/architecture-review` to confirm changes did not break coverage
```

Each rule must reference its source ADR or doc — never an unsourced rule.

---

## Phase 5: Specialist Validation (optional)

Spawn `Task` to:
- `mobile-architect` — sanity check that no rule contradicts an ADR or another rule
- `lead-programmer` — check that rules are immediately actionable, not abstract

Integrate findings.

---

## Phase 6: Approve and Write

Show the draft. Ask: "Approve and write to `docs/architecture/control-manifest.md`?"

If approved, write. If the user wants edits, capture them and re-show.

---

## Phase 7: Hand Off

Print:
> "Control manifest written. Manifest Version: <date>. New stories will pin to this version. Run `/create-epics` next."

Update `production/session-state/active.md`.

---

## Quality Gates

- Every rule references its source (ADR-NNNN, Architecture Section, or framework doc)
- Every layer has at least one Required, one Forbidden, and one Guardrail rule
- Cross-cutting section addresses analytics, error, theming, i18n, permissions, push, performance, privacy, testing
- Manifest Version date is set and visible at the top
- No contradictions between two rules

---

## Examples

For an MVP RN project with 9 Accepted ADRs:
- Manifest has ~50 rules across 5 layers
- Cross-cutting section has rules for all 9 standard concerns
- Every rule cites an ADR
- Manifest Version: 2026-05-03
- Stories created today pin to that version
