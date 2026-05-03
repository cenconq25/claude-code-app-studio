---
name: reverse-document
description: "Generates a PRD or architecture doc from existing implementation — works backward from code to the doc that should have been written first. Use this for brownfield projects with working code but no design docs, or when a feature shipped without a PRD."
argument-hint: "[--prd <system> | --architecture] [path?]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
model: sonnet
---

# Reverse-Document — Code to Doc

Reads code (often via `/extract` first) and produces the missing design or architecture document, with explicit honesty about which sections are inferred vs. confirmed.

Outputs:
- `design/prd/<system>.md` (PRD mode), or
- `docs/architecture/architecture.md` and recommended ADRs (architecture mode)

---

## Purpose / When to Run

Run when:
- A feature is implemented but has no PRD
- Multiple features ship daily and design debt is accumulating
- A project audit (`/adopt`) flagged "code without docs" as the gap
- An ADR needs to be written for a decision that already shipped

Distinct from `/extract` (descriptive snapshot) — this skill commits to a forward-looking doc that the team can review and refine.

## Inputs

- Mode flag: `--prd <system-name>` or `--architecture`
- Optional path to source dir
- An existing `design/extracted/<system>.md` (preferred — uses it instead of re-reading code)
- `.claude/docs/technical-preferences.md`
- For architecture mode: existing `docs/architecture/architecture.md` if any

## Outputs

- `design/prd/<system>.md` (PRD mode), or
- `docs/architecture/architecture.md` plus a numbered list of recommended ADRs

---

## Phase 1: Determine Mode

If no flag was passed, ask:
- **Prompt**: "What do you want to reverse-document?"
- **Options**:
  - `A single system / feature → PRD` — produce a PRD that describes the implemented behavior
  - `Whole-app architecture` — produce architecture.md and a recommended ADR list
  - `Single decision → ADR` — for that case, redirect the user to `/architecture-decision retrofit ...` (this skill is for whole docs, not single ADRs)

Capture the system name if PRD mode.

---

## Phase 2: Source the Extraction

Check if `design/extracted/<system>.md` exists.

- If yes: read it. Skip to Phase 3.
- If no: run the extraction logic from `/extract` inline (read source, build the same fact table) before proceeding. Optionally write the extracted file as a side effect, asking permission first.

---

## Phase 3: PRD Mode

Build a PRD by mapping the extracted facts to the PRD section structure.

### 3a: Section mapping

| PRD Section | Extracted from |
|---|---|
| Overview | Function-level summary of what this code does |
| User Goal | Inferred from screen names, copy strings, navigation flow |
| Detailed Requirements | Behaviors observable in code: validation rules, state transitions, calls made |
| Edge Cases | Exception handlers, conditional branches, retry logic |
| Dependencies | Imports + cross-module references |
| Configurable Values | Hardcoded constants and feature-flag reads |
| Acceptance Criteria | Observable from tests if present; otherwise marked **inferred** |
| Accessibility | What the code already does (semantics, labels, dynamic type) |

### 3b: Honesty markers

Every section must mark each statement as one of:
- **OBSERVED** — directly visible in code
- **INFERRED** — implied but not explicit in code (must be confirmed by team)
- **GAP** — the code does not address this; it should

For example:
> "**OBSERVED**: Login screen has email and password fields with HTML5-equivalent validation. **INFERRED**: Failed login shows a generic error toast (the toast string is generic; the team may want a clearer error). **GAP**: The code does not handle a network timeout — currently shows the same generic error."

This honesty markup is what makes a reverse-doc useful — the team can quickly see what to fix vs. what to confirm.

### 3c: Configurable values

If hardcoded magic numbers were observed (timeouts, retry counts, debounce intervals), list them in `Configurable Values` with the **observed value**. Recommend whether they should move to a config file or feature flag.

### 3d: Acceptance criteria honesty

Without the team's intent, acceptance criteria can only be reconstructed from behavior. Use the GIVEN-WHEN-THEN format and mark each criterion **INFERRED** until the team confirms.

### 3e: Open questions

Reverse-docs always raise questions. Capture them at the bottom:
- "Should the rate-limit error retry automatically or surface a manual retry button? Code shows automatic retry, but no PRD context confirms the intent."
- "The screen has a 'Skip' affordance — was this intentional or vestigial?"

---

## Phase 4: Architecture Mode

Build a top-level architecture doc by extracting from multiple subsystems at once.

### 4a: Layer detection

Read source organization. Identify layers:
- Presentation (screens, components)
- State / view model
- Domain / use cases (if present)
- Data (services, repositories, persistence)
- Cross-cutting (analytics, error reporting, feature flags)

### 4b: Cross-cutting concerns

Identify these patterns from the codebase:
- Authentication / session management
- Logging
- Error reporting (Sentry, Crashlytics, Bugsnag — detect from imports)
- Analytics (Amplitude, Mixpanel, Firebase, Segment)
- Feature flags (LaunchDarkly, ConfigCat, custom)
- Internationalization
- Theming / dark mode
- Push notifications
- Deep links

For each, note **library used** + **how it is wired**.

### 4c: Data flow

Sketch the dominant data flow:
```
UI → ViewModel/Store → UseCase/Service → API/Persistence
        ↑                                    │
        └──────────── Result/State ──────────┘
```

Or whatever the actual code shows. Mark inconsistencies (e.g., "most screens follow this; auth screen calls API directly").

### 4d: Recommended ADRs

For every observed-but-undocumented decision, propose an ADR:

```
## Recommended ADRs (decisions implicit in code, not yet recorded)

1. ADR-XXXX: State management library — code uses Zustand throughout. Record this so future contributors do not re-litigate.
2. ADR-XXXX: Navigation library — React Navigation v6 with stack-in-tab pattern.
3. ADR-XXXX: Error reporting — Sentry, manually invoked. Currently no automatic crash capture in screens; should we?
[...]
```

Each entry includes: title, decision summary, suggested status (Accepted retroactively / Proposed if the team needs to confirm).

---

## Phase 5: Specialist Consultation (optional, recommended)

For PRD mode and architecture mode, optionally spawn a specialist to validate the inferences.

Use `Task` to delegate to the framework specialist (e.g., RN engineer, Flutter engineer, iOS engineer, Android engineer) to:
- Confirm the extracted patterns are idiomatic for the framework
- Flag observed patterns that look broken or anti-pattern (e.g., "this state library was abandoned 2 years ago")

Surface specialist findings in the doc.

---

## Phase 6: Present and Approve

For PRD mode, present a section list before writing:
```
## Reverse-PRD: <system>
Sections to write:
1. Overview — OBSERVED
2. User Goal — INFERRED (will need team confirmation)
3. Detailed Requirements — mostly OBSERVED, a few GAP
4. Edge Cases — INFERRED + 2 GAPs flagged
5. Dependencies — OBSERVED
6. Configurable Values — OBSERVED + 3 hardcoded values flagged
7. Acceptance Criteria — INFERRED (4 criteria)
8. Accessibility — partially OBSERVED + 2 GAPs flagged

Open questions: 5
Recommended next steps: review with PM / lead engineer
```

Ask: "May I write `design/prd/<system>.md` with these honesty markers?"

For architecture mode, present the layer summary and the recommended ADR count, then ask for write approval.

---

## Phase 7: Write & Update

Write the file. Update `production/session-state/active.md` if it is being maintained.

Print:
> "Reverse-doc written. Read it with the team and convert INFERRED markers to confirmed by editing the doc. Run `/prd-review` (or `/architecture-review`) once the team has reviewed."

---

## Edge Cases

- **Code is partial / WIP**: produce the doc with a "Status: Reflects incomplete code" header and skip GAP markers — they will be misleading.
- **Two competing patterns in the same code**: pick the dominant one for the PRD, but mention the alternate in Open Questions.
- **No tests**: Acceptance Criteria section is fully INFERRED. Recommend writing a smoke-check before any further work on this system.

---

## Quality Gates

- Every claim in the doc is tagged OBSERVED, INFERRED, or GAP.
- The Open Questions list is non-empty for INFERRED-heavy docs.
- For architecture mode, every cross-cutting concern present in code has a corresponding entry in the doc.

---

## Examples

`/reverse-document --prd auth`
- Reads `design/extracted/auth.md` if present, else extracts inline
- Produces `design/prd/auth.md` with all 8 sections + honesty markers
- Lists 4 INFERRED Acceptance Criteria and 2 GAPs (no rate-limit handling, no biometric option mentioned in PRD but present in code)

`/reverse-document --architecture`
- Reads `src/`, identifies 4 layers, 8 cross-cutting concerns
- Produces `docs/architecture/architecture.md`
- Recommends 7 ADRs to record retroactively
