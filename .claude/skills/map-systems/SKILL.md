---
name: map-systems
description: "Decomposes the app concept into discrete systems, maps dependencies, prioritizes design order by upstream-first, and writes the systems index. Use after /brainstorm and /setup-framework, before authoring any individual PRD."
argument-hint: "[no arguments | next]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion
model: sonnet
---

# Map Systems

Translates the concept doc into a graph of systems with dependencies and a recommended design order. The systems index that this skill writes is the authoritative list `/design-system` reads to figure out what to write next.

Output: `design/systems-index.md`

---

## Purpose / When to Run

Run when:
- `design/concept.md` is complete and approved
- The team needs a single source of truth for what systems exist
- New systems were discovered mid-design and the index needs updating

Argument `next` is a shortcut: re-reads the index and shows the next system in the priority order without rebuilding the whole list.

## Inputs

- `design/concept.md` (required)
- `design/design-bible.md` if present
- `.claude/docs/technical-preferences.md`
- Existing `design/systems-index.md` if updating

## Outputs

- `design/systems-index.md`

---

## Phase 1: Argument Handling

If argument is `next`:
1. Read `design/systems-index.md`
2. Find the highest-priority system with status `Not started`
3. Print: "Next system to design: **<name>** (priority <N>, layer <X>). Run `/design-system <name>` to start."
4. Done — do not rebuild the index.

Otherwise, full mapping flow:
- If `design/systems-index.md` exists, ask whether to refresh it, append new systems only, or rebuild from scratch.

---

## Phase 2: Read Concept

Read `design/concept.md`. Extract:
- The one-liner
- The MVP scope (in v1) and cuts (out of v1)
- The primary metric
- The riskiest assumption

If concept doc is missing, stop:
> "No `design/concept.md` found. Run `/brainstorm` first."

If concept is fragmentary (sections empty), warn: "Concept doc has [N] empty sections. Mapping with incomplete concept will produce a brittle systems list — recommend completing the concept first."

---

## Phase 3: Propose System List

For a typical mobile app, propose a candidate list. Adapt to what the concept says — never copy this list verbatim. Use it as a checklist to make sure no obvious system is forgotten.

Standard candidate categories:

**Foundation layer**
- App shell / navigation chrome
- Authentication / session
- Persistence (local DB / cache / secure storage)
- Network client / API layer
- Error reporting / crash handling
- Logging
- Analytics
- Feature flags / remote config
- Theme / dark mode
- Localization

**Core layer (concept-specific)**
- The 1-3 systems that deliver the core JTBD from the concept doc — name them based on the concept

**Supporting features**
- Profile / account
- Settings
- Notifications (push + in-app)
- Sharing / deep links
- Onboarding
- Help / support
- Search
- Empty / error / offline screens

**Monetization**
- Paywall (if monetized)
- IAP / subscription management
- Receipt validation
- Restore purchases

**Platform integrations**
- Camera / media (if used)
- Maps / location (if used)
- Biometrics (if used)
- Background tasks (if used)
- Widgets (if used)
- App Clips / Instant Apps (if used)

Present the proposed list to the user as a draft. Ask:
- **Prompt**: "Which of these systems are in scope for v1? Mark each."
- Use multi-select if your interface supports it; otherwise iterate quickly with one yes/no per system.

For each in-scope system, also confirm: 1-3 sentence description.

---

## Phase 4: Capture Dependencies

For each in-scope system, ask the user (or infer from the concept):
- Which other systems must exist for this to function (hard dependencies)?
- Which systems would enrich it but are not required (soft dependencies)?

Build a dependency table. Validate:
- No cycles. If a cycle is detected, surface it: "Auth depends on Profile, Profile depends on Auth — break this with a contract or merge them."
- Foundation systems should depend only on other Foundation systems.
- Core systems may depend on Foundation.
- Supporting features may depend on Foundation and Core.

---

## Phase 5: Prioritize Design Order

Topological sort: the design order respects dependencies (upstream first).

Within each layer, prioritize by:
1. **Risk** — is this on the riskiest-assumption path? Higher priority.
2. **MVP weight** — how central to the v1 promise.
3. **Specialist availability** — if a system needs a hard-to-source specialist, schedule it earlier so blockers surface early.

Assign each system a priority bucket: `P0` (must design first), `P1`, `P2`. P0 should be ≤ 5 systems.

---

## Phase 6: Build the Index

Write `design/systems-index.md`:

```markdown
# Systems Index

> **Generated**: <date>
> **Source concept**: `design/concept.md`
> **Total systems**: <N>

## Progress Tracker
- Total: <N>
- Designed: 0
- In review: 0
- Approved: 0

## Design Order

The order below reflects upstream-first decomposition. Run `/design-system <name>` for each, top to bottom.

### Foundation (P0)
| # | System | Layer | Priority | Status | Doc |
|---|--------|-------|----------|--------|-----|
| 1 | navigation-shell | Foundation | P0 | Not started | — |
| 2 | auth | Foundation | P0 | Not started | — |
| 3 | persistence | Foundation | P0 | Not started | — |
| ... |

### Core (P0–P1)
| ... |

### Supporting (P1–P2)
| ... |

### Monetization (P1)
| ... |

## Dependency Graph

```
auth
 ├─ persistence
 ├─ network-client
 └─ error-reporting

profile → auth, persistence

[etc — render as ASCII tree or simple text]
```

## Out of v1 Scope (deferred)
- <system>: <reason — typically from concept's cut list>

## Open Mapping Questions
- <any unresolved item from the conversation>
```

Ask: "May I write this to `design/systems-index.md`?"

---

## Phase 7: Detect Anti-Patterns

Before finishing, scan the proposed map for common issues:

- **Foundation explosion**: more than ~10 Foundation systems means the team is over-architecting.
- **Core orphans**: a Core system with no Foundation dependencies — likely missing a lower-layer dependency.
- **Notifications without auth**: push systems that don't depend on Auth.
- **Paywall without auth**: monetization needs identity.
- **Single P0 with 6+ dependents**: bottleneck — flag as a critical-path risk.
- **No analytics in MVP**: if the concept's primary metric is engagement-based, analytics must be P0.

Surface each as a callout in the index under "Open Mapping Questions" or as a warning before write.

---

## Phase 8: Hand Off

After writing:
- Print: "Systems index written. Next: `/design-system <first P0 system>` — author the first PRD."
- Update `production/session-state/active.md` with the next-system pointer.

Use `AskUserQuestion`:
- **Prompt**: "Want to start designing the first system now?"
- **Options**:
  - `Yes — `/design-system <name>``
  - `Run `/design-bible` first (recommended if not yet done)`
  - `Stop here for now`

---

## Edge Cases

- **Concept implies too many systems for v1**: surface the cut list. Suggest deferring 30%+ to v1.1.
- **Concept does not describe a core mechanic**: stop. The concept is too vague — recommend re-running `/brainstorm`.
- **Updating an existing index**: only add new systems and update statuses; never silently delete a row. If a system is being killed, mark it `Killed` and keep the row.

---

## Quality Gates

- Every in-scope system has: name, layer, priority, dependency list, status.
- The dependency graph is acyclic.
- Foundation systems depend only on other Foundation systems.
- The next-priority system pointer is set.
- Out-of-scope list is non-empty (the concept's cut list must be reflected here).

---

## Examples

For a "bouldering project tracker":
- Foundation: navigation, auth, local persistence (SwiftData), error reporting
- Core: project list, attempt logger, session timer
- Supporting: profile, settings, notifications (session reminders), share-image
- Monetization: deferred to v1.1 (per concept doc cut list)
- P0 design order: auth → persistence → project list → attempt logger
