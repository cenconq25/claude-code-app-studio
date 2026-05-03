# Director Gates

Standard review gates invoked by skills, team orchestrators, and workflows.
Each gate has a fixed ID, a defined trigger, the context it expects, the
prompt the director uses, and the verdicts it can return. Skills reference
gates by ID instead of inlining the prompt — when a prompt changes here,
every skill that uses it picks up the change automatically.

## Review Modes

Gate intensity is configured globally and overridable per skill run.

- **Global**: `production/review-mode.txt` — one of `full`, `lean`, `solo`.
  Set during `/start`. Edit the file directly to change.
- **Per run**: every gate-invoking skill accepts `--review [full|lean|solo]`.

| Mode | Behaviour | Best for |
|---|---|---|
| `full` | Every gate runs. | Teams, learners, projects with high stakes. |
| `lean` | Only PHASE-GATE gates run; per-skill gates are skipped. | **Default.** Solo and small-team work. |
| `solo` | All gates skipped. | Hackathons, throwaway prototypes. |

**Resolution rule (apply before every gate spawn):**

```text
1. If skill was called with --review [mode], use it
2. Else read production/review-mode.txt
3. Else default to lean

solo → skip; emit: "[GATE-ID] skipped — Solo mode"
lean → skip unless gate is a PHASE-GATE; emit: "[GATE-ID] skipped — Lean mode"
full → spawn as normal
```

## Standard Verdicts

| Verdict | Meaning | Default action |
|---|---|---|
| **APPROVE / READY** | No issues. Proceed. | Continue workflow. |
| **CONCERNS [list]** | Non-blocking issues found. | Surface to user via `AskUserQuestion` (Revise / Accept / Discuss). |
| **REJECT / NOT READY [blockers]** | Blocking issues. | Stop. Do not write files or advance phase until blockers resolve. |

When multiple gates run in parallel, apply the strictest verdict — one
NOT READY overrides any number of READYs.

## Recording Outcomes

After a gate resolves, append a one-line status to the relevant document:

```markdown
> **[Director] Review ([GATE-ID])**: APPROVED 2026-05-12
```

Phase gates record their outcome in
`docs/architecture/architecture.md` or `production/session-state/active.md`
as appropriate.

---

## Tier 1 — Product Director Gates

Agent: `product-director` | Tier: Opus | Domain: vision, scope, market fit.

### PD-VISION — Vision & Differentiator Stress Test

**Trigger**: After the product brief / one-pager is drafted (Discovery phase).

**Context**: brief, target user, primary job-to-be-done, success metric, top three competitors.

**Prompt**:
> "Pressure-test this product brief. Is the differentiator real and
> defendable, or could the next competitor copy it in a sprint? Is the
> success metric measurable and aligned with user value? Would the brief
> guide a contradictory feature decision the same way the team would?
> Return APPROVE, CONCERNS [specific weak points], or REJECT [the brief
> does not give the team enough to ship from]."

### PD-PRD — PRD Sign-off

**Trigger**: After a PRD is drafted via `/design-system`.

**Context**: PRD path, vision document, related PRDs already shipped.

**Prompt**:
> "Review this PRD. Are the user goal and success metric explicit? Is the
> scope cuttable into smaller shippable slices if needed? Are the edge
> cases documented (offline, denied permission, expired session, low
> battery)? Does it agree with the vision and not duplicate or contradict
> any sibling PRD? Return APPROVE, CONCERNS, or REJECT."

### PD-PRICING — Monetization & Pricing Review

**Trigger**: After a paywall, IAP catalogue, or pricing change is proposed.

**Context**: pricing proposal, current revenue model, user segments, churn data if available.

**Prompt**:
> "Review this pricing change. Is the user-perceived value commensurate
> with price? Does the upgrade path lead to a state worth paying for?
> Have store fees, taxes, and refund risk been accounted for? Will the
> A/B framing leak across cohorts? Return APPROVE, CONCERNS, or REJECT."

### PD-PHASE-GATE — Product Readiness at Phase Transition

**Trigger**: Always at `/gate-check` (in parallel with MA-PHASE-GATE, PR-PHASE-GATE, LD-PHASE-GATE).

**Context**: target phase, list of artefacts present, vision and success metric.

**Prompt**:
> "Assess product readiness for [target phase]. Are PRDs aligned with the
> vision? Are scope tiers explicit and cuttable? Are growth and
> monetization implications documented? Return READY, CONCERNS, or NOT
> READY."

---

## Tier 1 — Mobile Architect Gates

Agent: `mobile-architect` | Tier: Opus | Domain: architecture, framework risk, performance, security.

### MA-FRAMEWORK — Framework Choice Validation

**Trigger**: After `/setup-framework` proposes a stack but before pinning.

**Context**: PRDs (existing or planned), target platforms, team skills, performance budgets.

**Prompt**:
> "Validate the proposed framework against this product. Will it hit the
> performance budget? Does it support every required platform feature
> (push, deep links, IAP, biometrics, background tasks)? Are the team's
> existing skills compatible? Return APPROVE, CONCERNS, or REJECT [list
> features the framework cannot deliver and recommend an alternative]."

### MA-ARCHITECTURE — Architecture Sign-off

**Trigger**: After the master architecture document is drafted.

**Context**: architecture doc, ADR list with statuses, framework reference.

**Prompt**:
> "Review the master architecture. Does every PRD requirement map to an
> ADR? Are state, navigation, networking, and persistence decisions
> explicit and consistent with the framework reference? Are platform
> divergence points (iOS/Android) explicitly handled? Return APPROVE,
> CONCERNS, or REJECT."

### MA-ADR — Architecture Decision Record Review

**Trigger**: After an ADR is authored, before it is marked Accepted.

**Context**: ADR path, framework version, related ADRs.

**Prompt**:
> "Review this ADR. Is the problem statement clear? Are alternatives
> genuinely considered, including 'do nothing'? Does the consequences
> section name trade-offs honestly? Is the framework version stamped?
> Are post-cutoff API risks flagged? Return APPROVE, CONCERNS, or REJECT."

### MA-FRAMEWORK-RISK — Framework Version Risk Review

**Trigger**: When using framework APIs released after the LLM knowledge cutoff or marked HIGH risk in `docs/framework-reference/`.

**Context**: API in question, framework version, relevant excerpt from version reference.

**Prompt**:
> "Validate this API usage against the pinned version. Does the API exist
> at this version? Has its signature or behaviour changed? Are there
> deprecation warnings or recommended replacements? Return APPROVE,
> CONCERNS [verify before use], or REJECT [API has changed — provide
> corrected approach]."

### MA-PHASE-GATE — Technical Readiness at Phase Transition

**Trigger**: Always at `/gate-check`.

**Context**: target phase, architecture doc, framework reference, ADR list.

**Prompt**:
> "Assess technical readiness for [target phase]. Is the architecture
> sound for the next phase's scope? Are performance budgets defined and
> realistic? Are foundational ADRs accepted? Return READY, CONCERNS, or
> NOT READY."

---

## Tier 1 — Producer Gates

Agent: `producer` | Tier: Opus | Domain: scope, schedule, dependencies.

### PR-SCOPE — Scope & Timeline Validation

**Trigger**: After scope tiers and timeline are proposed (Discovery / Architecture).

**Context**: full vision, MVP definition, timeline, team size, scope tiers.

**Prompt**:
> "Review the scope estimate. Is the MVP achievable in the stated
> timeline for this team size? Are scope tiers correctly ordered so each
> tier is shippable on its own? What is the most likely cut point under
> pressure, and is it graceful or broken? Return REALISTIC, OPTIMISTIC,
> or UNREALISTIC."

### PR-SPRINT — Sprint Feasibility Review

**Trigger**: Before finalising a sprint plan; after any mid-sprint scope change.

**Context**: proposed story list with estimates, capacity, debt from previous sprint.

**Prompt**:
> "Review this sprint plan. Is the load realistic for capacity? Are
> stories ordered by dependency? Are any stories underestimated for
> their technical complexity? Return REALISTIC, CONCERNS [risks], or
> UNREALISTIC [stories to defer]."

### PR-MILESTONE — Milestone Risk Assessment

**Trigger**: At `/milestone-review` or when a scope change affects the milestone.

**Context**: milestone definition + date, completion %, blocked count, velocity.

**Prompt**:
> "Will this milestone hit its date? Top three production risks before
> the date? Items to cut to protect the date vs. items that are
> non-negotiable? Return ON TRACK, AT RISK, or OFF TRACK."

### PR-PHASE-GATE — Production Readiness at Phase Transition

**Trigger**: Always at `/gate-check`.

**Context**: target phase, sprint and milestone artefacts, capacity, blocked count.

**Prompt**:
> "Assess production readiness for [target phase]. Is scope realistic
> for timeline and team size? Are dependencies ordered so the team can
> execute? Return READY, CONCERNS, or NOT READY."

---

## Tier 1 — Lead Designer Gates

Agent: `lead-designer` | Tier: Opus (escalations) / Sonnet (routine) | Domain: design system, brand fit.

### LD-DESIGN-SYSTEM — Design System Sign-off

**Trigger**: After the initial design system tokens (color, type, spacing, motion) are drafted.

**Context**: token files, brand guidelines, accessibility floor (WCAG 2.2 AA).

**Prompt**:
> "Review the design system. Are tokens internally consistent (e.g., type
> scale follows a defined ratio, motion durations belong to a set)? Does
> the colour system meet contrast requirements? Are tokens namespaced for
> light/dark and dynamic type? Return APPROVE, CONCERNS, or REJECT."

### LD-PRD-DESIGN — PRD Design Review

**Trigger**: After visual comps and motion direction land for a PRD.

**Context**: PRD, comps, design system version.

**Prompt**:
> "Review the design output for this PRD. Does it use system tokens
> rather than one-offs? Do the empty/loading/error states use the
> defined patterns? Does motion follow the motion language? Return
> APPROVE, CONCERNS, or REJECT."

### LD-PHASE-GATE — Design Readiness at Phase Transition

**Trigger**: Always at `/gate-check`.

**Context**: target phase, design artefacts present.

**Prompt**:
> "Assess design readiness for [target phase]. Is the design system
> mature enough? Do the in-flight features have approved comps? Return
> READY, CONCERNS, or NOT READY."

---

## Tier 2 — Lead Reviews

### LD-CODE-REVIEW — Lead Developer Code Review

Agent: `lead-developer`. Triggered after a story is implemented.

**Prompt**:
> "Review this implementation against acceptance criteria, the governing
> ADR, and applicable rules. Does the code respect architecture
> boundaries? Are forbidden patterns absent? Is the public API tested?
> Return APPROVE, CONCERNS, or REJECT."

### QL-STORY-READY — QA Lead Story Readiness

Agent: `qa-lead`. Triggered before a story is accepted into a sprint.

**Prompt**:
> "Are acceptance criteria specific and testable? Logic stories must be
> verifiable by automated test; integration stories by fixtures or
> documented manual run. Flag vague criteria. Return ADEQUATE, GAPS, or
> INADEQUATE."

### QL-TEST-COVERAGE — QA Lead Coverage Review

Agent: `qa-lead`. Triggered before closing an epic, or at `/gate-check`
Sprint Dev → QA & Beta.

**Prompt**:
> "Are all Logic stories covered by passing unit tests? Are Integration
> stories covered by integration tests or documented manual runs? Are
> all PRD acceptance criteria mapped to at least one test? Return
> ADEQUATE, GAPS, or INADEQUATE."

### A11Y-AUDIT — Accessibility Specialist Audit

Agent: `accessibility-specialist`. Triggered before beta and release gates.

**Prompt**:
> "Audit the build for WCAG 2.2 AA + Apple/Android accessibility. Check
> screen-reader labels, hit targets, dynamic type, motion preferences,
> contrast. Return PASS, CONCERNS [list], or FAIL [list blockers]."

### SE-SECURITY — Security Engineer Review

Agent: `security-engineer`. Triggered before beta, after major networking/storage changes, and at release.

**Prompt**:
> "Audit cert pinning, secret storage, jailbreak/root posture, deep-link
> validation, OAuth flows, IAP receipt validation, third-party SDK
> permissions. Return PASS, CONCERNS, or FAIL."

### PA-PERF — Performance Analyst Review

Agent: `performance-analyst`. Triggered before beta and release.

**Prompt**:
> "Measure cold start, time to interactive, scroll jank, memory ceiling,
> battery impact, and network P95 against the budgets in
> technical-preferences.md. Return WITHIN BUDGET, CONCERNS, or OVER
> BUDGET [specific budgets exceeded]."

---

## Parallel Phase Gates

When `/gate-check` runs, spawn all four PHASE-GATE agents in parallel:

```text
Issue all four Task calls before awaiting any single result:
1. product-director  → PD-PHASE-GATE
2. mobile-architect  → MA-PHASE-GATE
3. producer          → PR-PHASE-GATE
4. lead-designer     → LD-PHASE-GATE

Collect all four verdicts and apply the strictest:
  any NOT READY / REJECT → overall FAIL
  any CONCERNS           → overall CONCERNS
  all READY / APPROVE    → eligible for PASS
```

## Adding a New Gate

1. Pick a prefix: `PD-`, `MA-`, `PR-`, `LD-`, `LP-` (lead developer),
   `QL-` (qa lead), `SE-` (security), `PA-` (performance), `A11Y-`,
   `RM-` (release manager). Add new prefixes if a new agent owns gates.
2. Add an ID using `[PREFIX]-[DESCRIPTIVE-SLUG]`.
3. Document the trigger, context, prompt, and verdicts.
4. Reference by ID from skills — never copy the prompt text inline.

## Coverage by Stage

| Stage | Required gates | Optional gates |
|---|---|---|
| Discovery | PD-VISION, PR-SCOPE | — |
| Design | PD-PRD (per PRD), LD-DESIGN-SYSTEM | LD-PRD-DESIGN |
| Architecture | MA-ARCHITECTURE, MA-ADR (per ADR) | MA-FRAMEWORK-RISK |
| Sprint Dev | LD-CODE-REVIEW (per story), QL-STORY-READY (per story), PR-SPRINT (per sprint) | PR-MILESTONE, QL-TEST-COVERAGE |
| QA & Beta | QL-TEST-COVERAGE, A11Y-AUDIT, PA-PERF, SE-SECURITY | — |
| Release | All four PHASE-GATEs | A11Y-AUDIT (final pass) |
| Live Ops | PD-PRICING (per pricing change), PR-MILESTONE | — |
