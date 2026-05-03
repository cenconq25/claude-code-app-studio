---
name: review-all-prds
description: "Holistic cross-PRD review — reads every PRD together to find contradictions, dominant strategies, cognitive overload, broken funnels, and missing-system gaps that single-PRD review cannot detect. Run after all MVP PRDs are individually approved, before architecture begins."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Task
model: opus
---

# Review All PRDs (Holistic)

Single-PRD review catches missing sections. This skill catches **interaction failures** between PRDs that look fine alone but collide once shipped together: the paywall blocks the empty-state CTA, two systems both want primary tab position, the onboarding promises a feature gated by a paywall the user has not seen, the analytics event vocabulary is inconsistent across systems.

Read-only. Produces a printed report. The user runs `/propagate-design-change` or `/design-system retrofit ...` to resolve findings.

---

## Purpose / When to Run

Run when:
- All v1 PRDs are individually `APPROVED`
- Before `/create-architecture` — architecture should not codify contradictions
- Before any major launch milestone
- After a batch of PRD changes (3+ PRDs touched in a sprint)

Distinct from `/consistency-check` (value drift) — this skill assesses **design intent**, **flow continuity**, and **system overlap**.

## Inputs

- All `design/prd/*.md`
- `design/concept.md`
- `design/systems-index.md`
- `design/registry/entities.yaml`
- `design/design-bible.md` if present

## Outputs

- A printed structured report. No file writes.

---

## Phase 1: Pre-Check

Verify all MVP-scoped PRDs are individually APPROVED. Read `design/systems-index.md` and confirm Status column.

If any PRD is not yet APPROVED, ask:
- **Prompt**: "<N> PRDs are not yet APPROVED. Run holistic review anyway, or stop and fix individual PRDs first?"
- **Options**: `Run anyway (degraded)`, `Stop`, `Show me which PRDs aren't approved`

If user proceeds with degraded run, mark the report header accordingly.

---

## Phase 2: Read Everything

Read all PRDs. Hold them in context simultaneously — that is the point of the skill (and why it runs on the opus tier).

Build cross-PRD summaries:
- **Screen-by-screen map** — for each screen referenced across PRDs, list every PRD that touches it
- **Event vocabulary** — every analytics event mentioned, by name, sorted; flag near-duplicates (`paywall_shown`, `paywallShown`, `payway_shown`)
- **Configurable values** — every value name across PRDs
- **Cross-system flows** — every flow that crosses 2+ systems (e.g., "user signs up → first session → first paywall trigger")
- **Permission asks** — every iOS/Android permission requested across PRDs (notifications, camera, location, contacts, photos)
- **Background work** — every system that schedules background tasks
- **Push notifications** — every category / channel / trigger across PRDs
- **Tabs / nav slots** — every system that wants top-level tab placement

---

## Phase 3: Run the Cross-PRD Checks

### 3a: Funnel breakage

Trace the v1 happy path end to end (typically: install → onboarding → first core action → retention loop → optional monetization). For each handoff between systems, confirm:
- The departing system finishes in a state the receiving system expects
- The receiving system's preconditions are described somewhere

Findings:
- "Onboarding ends with `auth_complete=true`, but the home screen PRD assumes `profile_complete=true` — there is no system that runs profile setup between."

### 3b: Surface conflicts

Two PRDs both claim primary visibility:
- "Both Notifications PRD and Activity Feed PRD describe a tab named 'Updates' in primary nav — only one tab can occupy that slot."
- "Onboarding PRD shows a banner on the home screen for 7 days; Promotions PRD shows a banner in the same slot starting day 1."

### 3c: Permission timing

For each permission:
- When is it asked?
- Is the ask justified by an in-context user action?
- Are multiple PRDs racing to ask the same permission first?

iOS / Android best practice: ask in context, never on first launch unless required for core function.

Findings:
- "Notifications and Location both want to prompt during onboarding. Only one should — pick the highest-leverage one."

### 3d: Vocabulary inconsistency

Event names with near-duplicates suggest the analytics PRD is not enforced. Configurable values with similar names ("debounce_search_ms" and "search_debounce_ms") suggest no naming convention.

Findings:
- "Analytics event names span three styles: snake_case (38), camelCase (12), Title Case (4). Pick one and standardize."

### 3e: Dominant-strategy / unintended exploits

Across PRDs, look for:
- Paid features unintentionally accessible through a free path (e.g., share-to-self workaround)
- Onboarding rewards stackable in unintended sequences (account churn for repeated sign-up bonus)
- Empty states with CTAs that lead to a paywall

### 3f: Cognitive overload at MVP

Count user-visible primary actions, top-level menu items, modal triggers, push categories. If any of these exceed common mobile thresholds, flag:
- More than 5 primary tabs (most apps cap at 4-5)
- More than 3 modals possible on the same screen
- More than 6 push notification categories at MVP
- Onboarding longer than 5 screens at MVP

### 3g: Cross-platform divergence

If the project targets both iOS and Android, scan for:
- Features described as iOS-only without a corresponding Android note
- Different monetization models per platform (often a real choice, but should be explicit)
- Push categories that map cleanly to iOS but not Android channels (and vice versa)

### 3h: Missing-system gaps

Look at the cross-PRD flow. Is there a system that should obviously exist that no PRD covers?
- "No PRD describes account deletion flow. Required by iOS App Store and Play Store."
- "No PRD describes data export — required by GDPR if you have EU users."
- "No PRD addresses how to handle a kid who is under 13 — relevant if any user-generated content."

### 3i: Concept-doc alignment

For each PRD, confirm:
- It serves the JTBD from concept Section 2
- It does not contradict an anti-feature in concept Section 4/5
- It contributes (positively or neutrally) to the primary metric in concept Section 5

Findings:
- "Concept says primary metric is D7 retention; the Onboarding PRD optimizes for D0 conversion (paywall in first session) — these may be in tension. Confirm the trade-off is intentional."

---

## Phase 4: Optional Specialist Synthesis

Spawn `Task` to:
- `ux-designer` — review the screen-by-screen map for flow coherence
- `pm` — review the funnel and metric alignment
- `accessibility-specialist` — survey accessibility coverage across UI PRDs

Specialists return findings; the main review integrates them.

---

## Phase 5: Verdict

Tally findings:
- **CRITICAL** — would break the app or fail store review (account deletion missing, IAP receipt invalidation missing, accessibility floor unmet across multiple PRDs)
- **HIGH** — would harm the user experience or metric (funnel break, surface conflict, permission timing collision)
- **MEDIUM** — improvable (vocabulary inconsistency, cognitive overload at edges)
- **LOW** — cosmetic

Verdict ladder:
- 0 CRITICAL, ≤ 3 HIGH → **PASS WITH NOTES**
- 0 CRITICAL, 4-8 HIGH → **CONCERNS**
- 1+ CRITICAL or 9+ HIGH → **REVISIONS REQUIRED**

---

## Phase 6: Output

```
# Holistic PRD Review

**Verdict: <PASS WITH NOTES / CONCERNS / REVISIONS REQUIRED>**
PRDs reviewed: <N>
Findings: <count by severity>

## CRITICAL
1. <finding> — affecting PRDs: <list>
   Fix: <specific recommendation>

## HIGH
1. <finding> — affecting PRDs: <list>
   Fix: <specific recommendation>

## MEDIUM
- <list>

## LOW
- <list>

## Strengths to preserve
- <what is working — name PRDs that demonstrate good practice>

## Recommended next steps
- For each CRITICAL: <skill or action>
- For HIGH cluster: run `/propagate-design-change` after each PRD edit
- After fixes: re-run this skill
- If PASS: proceed to `/create-architecture`
```

---

## Phase 7: After-Action

If verdict is PASS:
- Note in output: "Architecture work can proceed. Run `/create-architecture` next."

If CONCERNS or REVISIONS REQUIRED:
- Suggest the order in which to fix: CRITICAL first, then by impact
- Note that `/propagate-design-change` should follow each PRD edit so dependent PRDs and ADRs are surfaced

---

## Edge Cases

- **Single PRD only**: skill is wasted — direct user to `/prd-review`.
- **Concept doc absent**: degrade — skip Section 3i but run the rest. Note the limitation.
- **Mixed maturity (some PRDs polished, others stub)**: flag the immature ones at the top of the report; do not let them drown out findings about the polished ones.

---

## Quality Gates

- Verdict matches tally — no soft passes when CRITICAL exists
- Every finding names specific PRDs (no "the PRDs say X")
- Every CRITICAL and HIGH has a concrete fix path
- The skill never modifies files

---

## Examples

12 PRDs.
- 1 CRITICAL: no account-deletion PRD (Apple guideline 5.1.1(v))
- 3 HIGH: tab conflict, vocabulary drift (43 events, 9 near-duplicates), funnel break between onboarding and home
- 5 MEDIUM, 2 LOW
- Verdict: REVISIONS REQUIRED
- Recommendation: author missing PRD via `/design-system account-deletion`, then re-run the skill.
