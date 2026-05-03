---
name: architecture-decision
description: "Creates an Architecture Decision Record (ADR) documenting a significant technical decision — its context, alternatives, decision, consequences, and PRD requirements addressed. Every major mobile-architecture choice should have an ADR. Framework-version-aware: cross-references the framework reference docs to flag knowledge-cutoff risk."
argument-hint: "[title-or-slug | retrofit <path>] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
model: sonnet
---

# Architecture Decision

ADRs are the durable memory of why the architecture is shaped a given way. This skill captures one decision, anchored to PRD requirements, with the framework's knowledge-cutoff risk explicitly tracked.

Output: `docs/architecture/ADR-NNNN-<slug>.md`

---

## Phase 0: Argument Parsing & Mode

Resolve review mode:
1. `--review` flag if present
2. Else `production/review-mode.txt`
3. Else default `lean`

If the argument starts with `retrofit <path>`, enter retrofit mode:

1. Read the existing ADR
2. Identify which standard sections are present:
   - `## Status` — **CRITICAL** if missing (`/story-readiness` cannot validate)
   - `## ADR Dependencies` — HIGH (sequencing risk)
   - `## Framework Compatibility` — HIGH (knowledge-cutoff risk untracked)
   - `## PRD Requirements Addressed` — HIGH (traceability lost)
3. Print the gap report
4. Ask: "Add the [N] missing sections without modifying existing content?"
5. If yes:
   - For Status: ask the user (Proposed / Accepted / Deprecated / Superseded)
   - For ADR Dependencies: ask Depends On / Enables / Blocks (each can be "None")
   - For Framework Compatibility: read framework reference docs and generate the table; ask user to confirm domain
   - For PRD Requirements Addressed: ask which PRDs and which requirements
   - Append using Edit tool — never modify existing sections
6. Done; suggest re-running `/architecture-review` to validate.

If no argument or title:
> "What technical decision are you documenting? Provide a short slug (e.g., `state-management`, `navigation-library`, `auth-token-storage`)."

Then proceed to Phase 1.

---

## Phase 1: Load Framework Context

Always run before drafting. The model has knowledge cutoffs; the framework reference docs are the source of truth.

1. Read `.claude/docs/technical-preferences.md` to identify the framework + version
2. If `[TO BE CONFIGURED]`: stop and recommend `/setup-framework`
3. Identify the **domain** of this decision from the title:
   - State management
   - Navigation
   - Networking / API client
   - Persistence (local DB, secure storage)
   - Auth (token storage, refresh)
   - Push notifications
   - Background tasks
   - Analytics / instrumentation
   - Feature flags / remote config
   - Error reporting
   - i18n
   - Theming / dark mode
   - Build system / CI
   - Testing strategy
   - Code organization / module boundaries
   - In-app purchase / subscriptions
   - Deep links / universal links
   - Biometrics / secure enclave
   - Camera / media / AVFoundation / CameraX
   - Maps / location
4. Read `docs/framework-reference/<framework>/conventions.md`
5. Read `docs/framework-reference/<framework>/breaking-changes.md` — flag any post-cutoff entries in this domain
6. Read `docs/framework-reference/<framework>/VERSION.md` — note the risk level

If the domain carries MEDIUM/HIGH risk, surface a knowledge-gap warning before drafting:

```
KNOWLEDGE GAP NOTE
Framework: <name + version>
Domain: <domain>
Risk: <level>
Verified facts from reference docs:
- <facts the model should treat as ground truth, not invent around>
This ADR will be cross-checked against the reference docs. Do not rely on training data alone.
```

---

## Phase 2: Determine ADR Number

Glob `docs/architecture/ADR-*.md`. Pick the next zero-padded 4-digit number.

---

## Phase 3: Gather PRD and Existing-ADR Context

Read existing ADRs: which are Accepted? Which touch the same domain?

Read related PRDs from `design/prd/*.md` — any that reference this domain.

### 3a: Architecture registry check

If `docs/architecture/architecture-registry.yaml` exists, extract entries relevant to this domain:
- State ownership claims
- Interface contracts
- Forbidden patterns
- Performance budgets

Present any constraint that this ADR must respect:
```
## Existing architectural stances (must not contradict)

- State ownership: `current_user` → owned by auth-system (ADR-0003)
- Interface: token refresh uses `tokenRefreshed` event (ADR-0003)
- Forbidden: synchronous AsyncStorage reads on hot path (ADR-0007)
```

If the proposed decision contradicts any stance, flag the conflict and pause:
> "This ADR proposes <X>, but ADR-NNNN established <Y>. Resolve by: (1) aligning, (2) superseding ADR-NNNN explicitly, or (3) declaring an exception."

Do not proceed to Phase 4 until resolved.

---

## Phase 4: Guide the Decision Collaboratively

Derive assumptions from the gathered context, then confirm with `AskUserQuestion` rather than open questions.

Assumptions to derive:
- **Problem** — one-sentence statement from title + PRD context
- **Alternatives** — 2-3 concrete options grounded in framework reference docs
- **Dependencies** — upstream ADRs from registry / index
- **PRD linkage** — which PRD systems' requirements this addresses
- **Status** — always `Proposed` for new ADRs

Present:
```
Drafting assumptions:
- Problem: <derived>
- Alternatives:
  A) <option A>
  B) <option B>
  C) <option C>
- PRD linkage: <list>
- Dependencies: <list or None>
- Status: Proposed

[A] Proceed
[B] Change alternatives
[C] Adjust PRD linkage
[D] Add a constraint (performance budget, library limit, etc.)
[E] Something else
```

If schema or interface design questions arise, use a separate multi-tab `AskUserQuestion` — do not bundle them into the assumptions widget.

---

## Phase 5: Generate the ADR Draft

Template:

```markdown
# ADR-NNNN: <Title>

## Status
Proposed

## Date
<today>

## Framework Compatibility

| Field | Value |
|-------|-------|
| Framework | <name + version> |
| Domain | <domain> |
| Knowledge Risk | <LOW / MEDIUM / HIGH> |
| References Consulted | <list of reference doc paths> |
| Post-cutoff APIs Used | <list or "None"> |
| Verification Required | <behaviors to test before shipping, or "None"> |

## ADR Dependencies

| Field | Value |
|-------|-------|
| Depends On | <ADR-NNNN, or None> |
| Enables | <ADR or epic, or None> |
| Blocks | <epic / story, or None> |
| Ordering Note | <any nuance> |

## Context

### Problem
<paragraph>

### Constraints
- <list — technical, regulatory, business>

### Requirements
- <list — must-haves derived from PRD context>

## Decision

<paragraph: the actual decision in implementable detail>

### Architecture Sketch
<ASCII diagram or short prose describing the resulting structure>

### Key Interfaces
<API contracts, signal names, store shapes — concrete>

## Alternatives Considered

### Alternative A: <name>
- How it works
- Pros
- Cons
- Why rejected

### Alternative B: <name>
[same structure]

## Consequences

### Positive
- <list>

### Negative
- <list — accepted trade-offs>

### Risks
- <list, each with mitigation>

## PRD Requirements Addressed

| PRD | Requirement (TR-ID) | How this ADR addresses it |
|-----|---------------------|---------------------------|
| design/prd/auth.md | TR-auth-007 (token refresh) | <how> |

## Performance Implications
- App launch: <delta>
- Memory: <delta>
- Network: <delta if relevant>
- Battery: <delta if relevant>

## Migration Plan
<if changing existing code, the path>

## Validation Criteria
<how we'll know this was the right call — metrics, tests, behaviors>

## Mobile-Specific Considerations
- iOS: <if relevant>
- Android: <if relevant>
- Cross-platform parity: <if both>
- Min OS impact: <if any min OS bump implied>
- Battery / background: <if relevant>
- Privacy / permission impact: <if relevant>
- Store review impact: <if relevant — Apple guideline / Play policy>

## Related Decisions
- <ADRs, design docs>
```

Use `Mobile-Specific Considerations` actively — many architectural decisions for mobile have iOS/Android divergences (push, biometric, IAP, deep linking) that should be explicit.

---

## Phase 6: Specialist Validation

### 6a: Framework specialist

Read the primary framework specialist from `.claude/docs/technical-preferences.md`. Spawn via `Task`:
- Pass: ADR's Decision section, Key Interfaces, Framework Compatibility table, framework reference doc paths
- Ask:
  1. Is this approach idiomatic for the pinned version?
  2. Are any cited APIs deprecated / changed post-cutoff?
  3. Mobile-specific gotchas missing from the draft?

Integrate findings:
- Blocking issues → revise Decision and Framework Compatibility before continuing
- Minor notes → append to Risks

### 6b: Technical Director (review-mode dependent)

Apply check pattern:
- `solo` → skip
- `lean` → skip
- `full` → spawn `mobile-architect` (Task) for cross-ADR coherence review

For `full` review:
- TD reads other Accepted ADRs in the same domain and adjacent domains
- Confirms this decision is consistent with the system as a whole
- Verdict: APPROVED / CONCERNS / REJECT — handle per gate rules

---

## Phase 7: PRD Sync Check

Before write, scan all PRDs referenced in the PRD Requirements Addressed table for naming inconsistencies with the ADR's Key Interfaces:
- Renamed events / signals / hooks
- Different payload shapes
- Different method names

If any are found, surface a prominent warning before write approval:

```
PRD SYNC WARNING
design/prd/auth.md uses names this ADR has renamed:
  authTokenRefresh → onAuthTokenRefreshed
  user_id → userId
The PRD must be updated to prevent stories implementing the wrong interface.
```

If no inconsistencies, skip silently.

---

## Phase 8: Write Approval

Use `AskUserQuestion`. If sync issues:
- `Write ADR + update PRD in same pass`
- `Write ADR only — I'll update the PRD manually`
- `Not yet — review further`

Without sync issues:
- `Write ADR to docs/architecture/ADR-NNNN-<slug>.md`
- `Not yet`

If yes, write the file (creating directory if needed). For combined option, also Edit the affected PRD(s).

---

## Phase 9: Update Architecture Registry

If `docs/architecture/architecture-registry.yaml` is in use:

Scan the new ADR for:
- State ownership claims
- Interface contracts (event names, hook signatures)
- Forbidden patterns
- Performance budgets
- API choices

Present registry candidates:
```
NEW state ownership: <name> → <system>
NEW interface contract: <name>
NEW forbidden pattern: <description>
NEW performance budget: <metric>
```

Ask: "Update `docs/architecture/architecture-registry.yaml` with these [N] new stances?" — never auto-write.

When appending, read the file fresh and append after the last entry in each section. Do not assume placeholders are still empty if other ADRs in this session may have added entries.

---

## Phase 10: Closing Steps

Use `AskUserQuestion`:
```
ADR-NNNN written. What's next?
[A] Write next priority ADR — `<title>`
[B] Run `/architecture-review` (in fresh session) to validate coverage
[C] Run `/create-control-manifest` if all priority ADRs are now written
[D] Stop here
```

Always include:
> "Run `/architecture-review` in a fresh session — never inline. The reviewing agent must be independent of the authoring context."

If any stories had `Status: Blocked` pending this ADR, suggest updating them to `Ready`.

---

## Quality Gates

- Status field always present
- Framework Compatibility table fully populated, including Knowledge Risk
- ADR Dependencies populated (each field has at least "None")
- At least one row in PRD Requirements Addressed
- At least 2 alternatives considered with explicit rejection reasons
- Mobile-Specific Considerations section addresses platform divergence if relevant

---

## Examples

`/architecture-decision state-management`
- Domain: state management
- Framework: React Native 0.74 (HIGH risk — post-cutoff)
- Specialist (RN engineer) recommends Zustand over Redux for this app's complexity
- Decision: Zustand for app-wide state, React state for per-screen
- PRD requirements addressed: TR-auth-007, TR-profile-002, TR-home-001
- Mobile considerations: AppState foreground/background hooks, Hermes JS engine compatibility

`/architecture-decision retrofit docs/architecture/ADR-0003-auth.md`
- Existing ADR is missing Status, ADR Dependencies, Framework Compatibility
- Skill walks user through filling them in without touching the rest of the file
