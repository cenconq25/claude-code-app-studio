---
name: design-system
description: "Section-by-section authoring of a Product Requirements Doc for a single mobile-app system. Reads concept, systems index, dependencies, and registry; walks the user through each PRD section collaboratively; writes incrementally to file. Use when starting a new PRD or filling gaps in an existing one."
argument-hint: "<system-name> | retrofit <path> [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
model: sonnet
---

# Design a System (PRD Authoring)

Writes one PRD per system, one section at a time. Each approved section is written immediately so progress survives compaction or session loss.

Output: `design/prd/<system-name>.md`

---

## Purpose / When to Run

Run when:
- A system has been mapped via `/map-systems` and is ready for full design
- An existing PRD is missing sections (retrofit mode)
- A reverse-doc needs to be promoted to a full PRD

## Inputs

- A system name OR a `retrofit <path>` argument
- `design/concept.md` (required)
- `design/systems-index.md` (recommended)
- `design/registry/entities.yaml` (if present — cross-system fact registry)
- Existing dependency PRDs in `design/prd/`
- `.claude/docs/technical-preferences.md` and `docs/framework-reference/<framework>/`

## Outputs

- `design/prd/<system-name>.md` — written section by section
- Possibly updated `design/registry/entities.yaml`
- Possibly updated `design/systems-index.md`

---

## Phase 1: Argument Parsing & Review Mode

Resolve review mode:
1. If `--review full|lean|solo` present, use it
2. Else read `production/review-mode.txt`, default `lean` if absent

If argument starts with `retrofit` followed by a path, enter **retrofit mode**:
1. Read the file
2. Identify which of the 8 required sections are present (grep for headings)
3. Required: `Overview`, `User Goal`, `Detailed Requirements`, `Edge Cases`, `Dependencies`, `Configurable Values`, `Acceptance Criteria`, `Accessibility`
4. Identify which sections are placeholders (`[To be designed]` or empty)
5. Print a retrofit summary (sections present vs. missing) and ask: "Fill the [N] missing sections without touching existing ones?"
6. If yes: skip skeleton creation in Phase 3; in Phase 4 only run the section cycle for missing sections; never overwrite existing section content

Otherwise, normalize the system name to kebab-case for the filename.

If no argument and no systems index exists, stop:
> "Usage: `/design-system <system-name>`. No systems index found — run `/map-systems` first."

If no argument but systems index exists, find the highest-priority "Not started" system and ask:
- **Prompt**: "The next system in your design order is **[name]**. Author it now?"
- **Options**: `Yes — design [name]`, `Pick a different system`, `Stop here`

---

## Phase 2: Gather Context

### 2a: Required reads

- `design/concept.md` — fail if missing
- `design/systems-index.md` — fail if missing (unless retrofit)
- The target system's row in the index — its priority, layer, dependencies
- `design/registry/entities.yaml` — extract entries this system might touch

### 2b: Dependency reads

From the systems index, find:
- **Upstream** systems this depends on — read their PRDs if they exist
- **Downstream** systems that depend on this — read their PRDs if they exist

For each dependency PRD, capture: data interfaces, configurable values that feed in, acceptance criteria that assume this system's behavior.

### 2c: Optional reads

- `design/concept.md` Section 6 (Tone & Visual Anchor) and `design/design-bible.md` if present — for UI-touching systems
- `docs/architecture/architecture.md` if present — to know what layer this lives in
- Existing `design/prd/<system>.md` if it exists (resume rather than restart)

### 2d: Framework feasibility pre-check

For systems that touch the framework heavily (auth, push, persistence, deep links, biometrics, in-app purchase):
- Read `docs/framework-reference/<framework>/VERSION.md` — note knowledge-gap risk
- Read `docs/framework-reference/<framework>/breaking-changes.md` — flag relevant entries
- If the system involves a known platform-tricky area (e.g., iOS background tasks, Android foreground services, push tokens, biometric APIs), surface known gotchas before drafting

### 2e: Present a context brief

Before designing, print:
```
**Designing PRD: <System>**
- Priority: <from index>
- Layer: <from index>
- Depends on: <list, with PRD-status>
- Depended on by: <list>
- Locked facts from registry: <list — these values cannot be contradicted>
- Concept tone: <pull from concept.md Section 6>
- Framework gotchas: <list or "none">
```

Use `AskUserQuestion`:
- **Prompt**: "Ready to design <system>?"
- **Options**: `Yes`, `Show me more context first`, `Design a dependency first`, `Stop`

---

## Phase 3: Create the File Skeleton

If not in retrofit mode, write `design/prd/<system-name>.md` with empty sections:

```markdown
# <System Name> — PRD

> **Status**: In Design
> **Last Updated**: <date>
> **System**: <system-name>
> **Layer**: <from index>

## 1. Overview
[To be designed]

## 2. User Goal
[To be designed]

## 3. Detailed Requirements
[To be designed]

## 4. Edge Cases
[To be designed]

## 5. Dependencies
[To be designed]

## 6. Configurable Values
[To be designed]

## 7. Acceptance Criteria
[To be designed]

## 8. Accessibility
[To be designed]

## 9. Platform Notes
[Optional — fill if iOS/Android behavior differs]

## 10. Implementation Hooks
[Optional — for engineers, refs to ADRs/files when known]

## 11. Open Questions
[Optional]
```

Ask: "May I create the skeleton at `design/prd/<system-name>.md`?"

After write, update `production/session-state/active.md` (use Glob first; Write if missing, Edit if present).

---

## Phase 4: Section-by-Section Authoring

For each section, follow the cycle:

```
Context → Question(s) → Options → Decision → Draft → Approval → Write
```

After each write, scan for registry conflicts (Section 3 and 6 especially): if the section just wrote a value that contradicts the registry, surface immediately and pause.

### Section 1: Overview

**Goal**: One paragraph a stranger could read and understand what this system does and why it exists.

Ask:
- What does this system do, in one sentence?
- Where does the user encounter it (which screens/flows)?
- What would the app lose without it?

Use `AskUserQuestion` for one framing decision:
- **Prompt**: "Frame the overview as user-facing or infrastructure?"
- **Options**: `User-facing`, `Infrastructure`, `Both — describe the layer and the surface`

Draft. Ask `AskUserQuestion` to approve, request changes, or restart. Write with Edit using:
```
old_string: "## 1. Overview\n\n[To be designed]"
new_string: "## 1. Overview\n\n<approved text>"
```

### Section 2: User Goal

**Goal**: What the user is trying to accomplish — phrased as a JTBD.

Always include: when does the user need this, what alternatives exist (other apps, manual workarounds), and what success looks like for them.

Spawn `ux-designer` (Task) for any user-facing system to suggest the JTBD framing. Do not draft this section without specialist input on user-facing systems.

### Section 3: Detailed Requirements

**Goal**: Unambiguous behavioral spec a developer could implement without re-asking.

Sub-sections to consider, depending on system type:
- **Inputs** — what the user can do (taps, swipes, voice, sensor, deep link)
- **Outputs** — what the system produces (state changes, navigation, persisted data, notifications)
- **State machine** — if states are involved, list every state and transition in a table
- **Validation rules** — for any input, define accepted/rejected criteria
- **Backend integration** — for any networked system: endpoints called, auth required, payload shape (high-level), error codes handled
- **Persistence** — what is stored locally, where (encrypted? plain?), how long

Each behavioral requirement needs a **TR-ID**: `TR-<system>-NNN`. This is what stories cite.

Spawn the framework specialist for systems with platform-tricky behavior (push, background work, biometrics, payments) to flag implementation realities before they get baked into the spec.

### Section 4: Edge Cases

**Goal**: Every unusual situation has an explicit resolution.

Mobile-specific edge cases to always consider:
- Offline / no network
- Slow network (3G, throttled)
- Background-foreground transitions mid-action
- App killed mid-action
- OS permission denied / revoked
- Notification delivery failed
- Push token rotated
- Storage full
- App backgrounded during sensitive flow (auth, payment)
- App locale / region changed
- Dark mode toggled mid-session
- Dynamic type / large fonts
- Accessibility overlay (VoiceOver / TalkBack) running

Format each as: `If <condition>: <exact resolution>`. Vague answers ("handle gracefully") fail.

### Section 5: Dependencies

Pre-fill from the systems index. Then:
- Confirm each dependency
- For each, specify: hard (system breaks without it) vs. soft (degrades but works)
- Specify the data interface (what flows in, what flows out)

Cross-reference the dependency PRDs — if this PRD's expected interface contradicts what the dependency PRD specifies, flag and pause.

### Section 6: Configurable Values

**Goal**: Every value that should be tunable without a code release.

Mobile-specific candidates:
- Timeouts and retry counts
- Rate limits (client-side)
- Feature-flag-controlled behavior
- A/B test variants
- Push opt-in prompt timing
- Paywall display logic (event-triggered? after N sessions?)
- Onboarding screen count
- Cache TTLs

For each, capture: name, default value, safe range, who can change it (engineer / PM / data scientist), where it lives (build flag / remote config / database).

### Section 7: Acceptance Criteria

Format: GIVEN / WHEN / THEN.

At minimum: one criterion per detailed requirement, one per edge case, one per accessibility requirement (Section 8). Each criterion must be verifiable by a tester reading only the criterion, not the whole PRD.

Spawn `qa-lead` via Task to validate testability. Surface any "untestable as written" findings before writing.

### Section 8: Accessibility

Required for every PRD that touches UI. Cover:
- WCAG 2.2 AA contrast on all visible elements
- Touch target ≥ 44×44 pt (iOS HIG) / 48×48 dp (Material 3)
- Screen reader: every interactive element has a label and role
- Dynamic type / font scaling respected
- Reduce motion respected for any animated transition
- Color is not the only differentiator (icons + text)
- VoiceOver / TalkBack reading order makes sense
- Voice Control / Switch Control supported

For non-UI systems, write "N/A — no UI surface" and explain.

### Optional Sections 9-11

`Platform Notes` — if iOS and Android behavior diverge, list per-platform.
`Implementation Hooks` — once ADRs are written, link them here.
`Open Questions` — anything raised but not resolved during design.

---

## Phase 5: Post-Design Validation

### 5a: Self-check

Read the file back. Verify:
- All 8 required sections have content (no `[To be designed]` left)
- Every requirement has a TR-ID
- Every Acceptance Criterion is GIVEN/WHEN/THEN
- Accessibility section is non-empty for UI systems

### 5b: Update registry

Scan the PRD for new cross-system facts (named entities, configurable values, formulas). For each, check if registered. Present:
```
Registry candidates:
  NEW: <name> [type]: <attrs> (from <system>)
  EXISTING (referenced_by update only): <name> ✓
```

Ask: "Update `design/registry/entities.yaml` with these [N] new entries?"

### 5c: Offer review

Print:
> "PRD complete. To validate, open a fresh session and run `/prd-review design/prd/<system>.md`. Do not run `/prd-review` here — the reviewer must be independent of the authoring context."

### 5d: Update systems index

Update the system's row in `design/systems-index.md`:
- Status → `Designed (pending review)` or `Awaiting review`
- Doc → link to the PRD path

Ask before writing.

### 5e: Suggest next steps

Use `AskUserQuestion`:
- **Options**:
  - `/consistency-check` — verify no cross-PRD contradictions
  - `/design-system <next system>` — design the next-priority system
  - `/prd-review design/prd/<system>.md` (in a fresh session)
  - `Stop here`

---

## Specialist Routing

| System category | Primary spawn | Supporting spawns |
|---|---|---|
| Authentication / identity | `ux-designer` | framework specialist, `security-engineer` |
| Onboarding | `ux-designer` | `growth-engineer` |
| Payments / IAP / subscriptions | `ux-designer` | framework specialist, `monetization-designer` |
| Push notifications | framework specialist | `growth-engineer` |
| Search / browse | `ux-designer` | `analytics-engineer` |
| Profile / settings | `ux-designer` | `accessibility-specialist` |
| Analytics / instrumentation | `analytics-engineer` | `product-director` |
| Offline / sync | framework specialist | `database-specialist` |
| Sharing / deep links | framework specialist | `ux-designer` |
| Camera / media | framework specialist | `ux-designer` |
| Maps / location | framework specialist | `ux-designer` |
| Chat / messaging | `ux-designer` | framework specialist |

The main session orchestrates; specialists return analyses and the user picks. Specialists do not write files.

---

## Recovery & Resume

If the session is interrupted:
1. Read `production/session-state/active.md`
2. Read `design/prd/<system>.md` — sections with content are done; `[To be designed]` ones remain
3. Resume from the next incomplete section

---

## Collaborative Protocol

- Question → Options → Decision → Draft → Approval, every section
- Always include the heading in `Edit`'s `old_string` (placeholders are not unique)
- Never write a full PRD in one shot
- Always cross-reference dependency PRDs before writing Sections 3, 5, 6
- Never silently overwrite registry values

---

## Examples

`/design-system auth`
- Reads `design/concept.md` and any sibling PRDs (e.g., `onboarding.md`).
- JTBD: "When I land on the app, I want to sign in with as little typing as possible so I can get to the home screen."
- Section by section, walks: passwordless email magic-link vs. social SSO, biometric re-auth, token-storage choice (Keychain / Keystore / encrypted MMKV), session expiry policy, offline-token edge case.
- Writes `design/prd/auth.md`. Each accepted section is committed before moving to the next.

`/design-system paywall`
- Captures pricing tiers, trial length, restore-purchases flow, App Store and Play Store compliance copy, paywall trigger timing, A/B knobs (`paywall_variant`), analytics events (`paywall_shown`, `purchase_started`, `purchase_completed`), and edge cases (declined card, family sharing, refund flow).
- Spawns `monetization-designer` and `payment-integration-specialist` for the pricing and IAP/subscription sections.
