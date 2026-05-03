# Workflow Guide

A phase-by-phase walkthrough of the full mobile-app lifecycle as the
template runs it. Each phase lists its objectives, the agents involved,
the artefacts produced, the gates that fire, and the skills that drive
the work. The guide is meant to read top-to-bottom on day one and
function as a reference thereafter.

The lifecycle has seven phases:

1. Discovery
2. Design
3. Architecture
4. Sprint Dev
5. QA & Beta
6. Release
7. Live Ops

The status line shows the detected phase. `/gate-check` produces a
PASS / CONCERNS / FAIL verdict on whether the project is ready to advance.

---

## 1. Discovery

**Objective**: Decide what to build and for whom. Capture the brief, the
target user, the success metric, and the rough scope. Recommend a
framework.

**Agents**: `product-director`, `product-designer`, `user-researcher`,
`brand-director`, `producer`.

**Skills**: `/start`, `/discover`, `/competitor-scan`, `/jobs-to-be-done`,
`/persona`.

**Artefacts**:
- `design/prd/00-product-brief.md` — the one-pager.
- `design/prd/personas.md` — primary and secondary personas.
- Optional: `design/research/` interview notes.

**Gates**: PD-VISION (vision differentiator stress test), PR-SCOPE
(scope and timeline validation).

**Walkthrough**:

```text
User: /start
Agent (start skill): "Where are you?
                      A) New product idea, no app yet
                      B) Have a brief, no framework picked
                      C) Existing project to onboard the template into"
User: A

Agent: "Routing you to /discover. The interview takes ~30 minutes."

[/discover runs through: who is the user, what is the job-to-be-done,
 why now, who is the competition, what does success look like, what
 are the constraints, what is the rough scope, what platforms]

[Outputs design/prd/00-product-brief.md after section-by-section approval]

Agent: "Brief written. Recommended next step: /setup-framework. Want to
        run it now?"
```

The discovery output is the input every later phase pulls from. Keep it
short (one to three pages) — long briefs disguise unmade decisions.

---

## 2. Design

**Objective**: Author PRDs for the first feature set. Define the user
journeys, the design system, and the motion language. Decide the brand
voice. Lock the discoverability + onboarding model.

**Agents**: `lead-designer`, `product-designer`, `ux-designer`,
`visual-design-director`, `motion-designer`, `content-designer`,
`info-architect`, `accessibility-specialist`, `brand-director`.

**Skills**: `/prd-create`, `/flow-create`, `/design-system-create`,
`/motion-direction`, `/microcopy-pass`, `/component-spec`, `/prd-review`,
`/review-all-prds`.

**Artefacts**:
- `design/prd/[feature].md` per feature, with all 11 required sections.
- `design/flows/[feature].md` per flow.
- `design/registry/design-tokens.md` — colour, type, spacing, motion.
- `design/content/style-guide.md` — voice, tone, tense, banned words.

**Gates**: PD-PRD (per PRD), LD-DESIGN-SYSTEM, LD-PRD-DESIGN.

**Walkthrough — authoring a PRD**:

```text
User: /prd-create email-signin

Agent (product-designer):
  "I'll author this PRD section by section. Order:
   1. Overview, 2. User Goal, 3. Detailed Requirements, 4. Flows,
   5. Edge Cases, 6. Dependencies, 7. Tunables, 8. Acceptance Criteria,
   9. Analytics, 10. Accessibility, 11. Localization.
   May I create the skeleton at design/prd/email-signin.md?"

User: Yes

[skeleton written]

Agent: "Section 1: Overview. Two questions:
        - What's the user-visible promise of this feature in one sentence?
        - What's the success metric (opt-in %? completion %?)"

[continues section by section, writing each as approved]

Agent: "All 11 sections written. May I run /prd-review to validate?"

User: Yes

[/prd-review runs gate PD-PRD; verdict APPROVE / CONCERNS / REJECT]
```

When all PRDs in scope are written, run `/review-all-prds` to find
contradictions across them.

---

## 3. Architecture

**Objective**: Pin the framework. Define the architecture spine — state,
navigation, networking, persistence, security. Document the API contracts
the app depends on. Establish the test infrastructure.

**Agents**: `mobile-architect`, `lead-developer`, `api-designer`,
`database-specialist`, `graphql-specialist`, `offline-sync-specialist`,
`security-engineer`, `mobile-devops`.

**Skills**: `/setup-framework`, `/architecture-decision`, `/api-contract`,
`/data-model`, `/architecture-review`, `/create-control-manifest`,
`/test-setup`.

**Artefacts**:
- `.claude/docs/technical-preferences.md` — fully populated.
- `docs/architecture/architecture.md` — the master architecture doc.
- `docs/architecture/adr-*.md` — one per significant decision.
- `docs/architecture/control-manifest.md` — programmer rules sheet.
- `docs/architecture/tr-registry.yaml` — TR-ID registry.
- `tests/` scaffold with framework-appropriate test runner.

**Gates**: MA-FRAMEWORK (framework choice), MA-ARCHITECTURE (master doc),
MA-ADR (per ADR), MA-FRAMEWORK-RISK (post-cutoff API usage).

**Walkthrough — ADR for state management**:

```text
User: /architecture-decision

Agent (mobile-architect):
  "Authoring an ADR. Topic? (e.g., state-management, navigation, networking)"
User: state-management

Agent: "Three steps: Context, Decision, Consequences. We'll do them
        section by section. Context first.
        - What problem are we solving? (heavy server state? deep derived
          state? team familiarity?)
        - What constraints? (bundle size? team skills? performance?)"

[interview, then drafts each section, writes ADR-0003]

Agent: "ADR-0003 drafted as Proposed. May I run gate MA-ADR to confirm?"

[gate spawns mobile-architect again with the prompt from director-gates.md]
```

Run `/architecture-review` after each batch of ADRs. It produces a
traceability matrix mapping every PRD requirement TR-ID to at least one
ADR.

---

## 4. Sprint Dev

**Objective**: Translate PRDs and ADRs into stories. Implement them in
time-boxed sprints. Continuously test and review.

**Agents**: `producer`, `lead-developer`, all framework specialists,
`animation-specialist`, `qa-lead`, `qa-tester`, `mobile-test-automation`,
`accessibility-specialist`, `analytics-engineer`.

**Skills**: `/create-epics`, `/create-stories`, `/sprint-plan`,
`/story-readiness`, `/dev-story`, `/code-review`, `/story-done`,
`/sprint-status`, `/scope-check`, `/perf-profile`.

**Artefacts**:
- `production/sprints/sprint-NN.md` per sprint.
- `production/sprints/stories/[story-id].md` per story.
- `src/**/*` — implementation.
- `tests/**/*` — passing tests.

**Gates**: QL-STORY-READY, LP-CODE-REVIEW, PR-SPRINT, PR-MILESTONE,
QL-TEST-COVERAGE.

**Walkthrough — implementing a story**:

```text
User: /dev-story STORY-S1-12

Agent: "Reading story file...
        - Story type: Logic
        - Governing ADR: ADR-0003 (state management)
        - Linked PRD requirements: PRD-AUTH-003.REQ-2, REQ-3
        - Acceptance criteria: 4 items
        - Routing to react-native-specialist (TS files only)

        Before implementation, two ambiguities I want to flag:
        - REQ-2 says 'session times out after inactivity' but doesn't
          define inactivity. Background time? Touch-idle time?
        - No edge case for an expired session restored from
          rememberMe. Should we route to sign-in or attempt silent
          refresh?

        I'll file these as PRD clarifications. Continue, or pause to
        get product-designer's input first?"

[user decides; specialist implements; tests written; lead-developer
 reviews via gate LP-CODE-REVIEW]

Agent: "All 4 acceptance criteria pass. Coverage on the new module: 87%.
        Story moved to Done. Next ready story in the sprint:
        STORY-S1-13. Continue?"
```

Run `/sprint-status` daily for a 30-line snapshot. Run `/scope-check`
weekly to detect creep.

---

## 5. QA & Beta

**Objective**: Validate the build against PRD acceptance criteria, the
performance budget, the accessibility floor, and the security posture.
Ship to TestFlight / Play internal track. Run a structured beta with
real users.

**Agents**: `qa-lead`, `qa-tester`, `mobile-test-automation`,
`accessibility-specialist`, `security-engineer`, `performance-analyst`,
`user-researcher`, `release-manager`.

**Skills**: `/qa-plan`, `/smoke-check`, `/regression-suite`,
`/test-flakiness`, `/a11y-audit`, `/security-audit`, `/perf-profile`.

**Artefacts**:
- `production/qa/test-plan-*.md`
- `production/qa/evidence/**/*` — screenshots, recordings, audit reports.
- `production/qa/bugs/BUG-*.md`
- `production/qa/smoke-[date].md`

**Gates**: QL-TEST-COVERAGE, A11Y-AUDIT, SE-SECURITY, PA-PERF.

**Walkthrough — beta gate**:

```text
User: /gate-check beta

Agent: "Spawning four parallel reviewers..."

[product-director: PD-PHASE-GATE
 mobile-architect: MA-PHASE-GATE
 producer:         PR-PHASE-GATE
 lead-designer:    LD-PHASE-GATE]

[Plus four blocking specialist gates:
 qa-lead:                     QL-TEST-COVERAGE
 accessibility-specialist:    A11Y-AUDIT
 security-engineer:           SE-SECURITY
 performance-analyst:         PA-PERF]

Agent: "Verdicts collected:
        - PD: READY
        - MA: CONCERNS (no graceful degradation when push token is
          revoked; recommend a fallback path before beta)
        - PR: READY
        - LD: READY
        - QL: ADEQUATE
        - A11Y: PASS
        - SE: PASS
        - PA: WITHIN BUDGET (cold start P50 = 1.4s, jank rate 0.3%)

        Strictest verdict applies → CONCERNS overall.
        Suggested action: address MA's concern, re-run the gate."
```

---

## 6. Release

**Objective**: Submit to App Store and Play Store. Stage the rollout
gradually. Watch the post-release telemetry. Be ready to hotfix.

**Agents**: `release-manager`, `mobile-devops`, `qa-lead`,
`content-designer`, `localization-lead`, `visual-design-director`,
`community-manager`, `analytics-engineer`.

**Skills**: `/release-checklist`, `/launch-checklist`, `/store-listing`,
`/staged-rollout`, `/changelog`, `/patch-notes`, `/hotfix`.

**Artefacts**:
- `production/releases/release-*.md`
- `production/releases/store-listing-*.md`
- Localized listing copy and screenshots.
- `CHANGELOG.md` and user-facing patch notes.

**Gates**: All four PHASE-GATEs in parallel; A11Y-AUDIT for the final
build.

**Walkthrough — staged rollout**:

```text
User: /staged-rollout 1.0.0

Agent (release-manager):
  "Staged rollout plan for 1.0.0:
   - Day 0: Play 1% (release-manager publishes), App Store phased 1d.
   - Day 1: Watch crash-free rate and key funnel events.
            If crash-free < 99.5% on either platform, halt and decide.
   - Day 2: Play 5%, App Store phased 2d.
   - Day 3-7: Play doubles each day until 100%.
   - Day 7: Mark release complete.

   Rollback plan:
   - Play: pause rollout, revert to previous track in 30 min.
   - App Store: phased pause + expedited review for hotfix; 1.0.1
     submitted same day for hard rollback.

   Spawning analytics-engineer to set up post-release dashboards.

   May I run /release-checklist to verify the build artefacts before
   submission?"
```

---

## 7. Live Ops

**Objective**: Use the live data to guide improvements. Run growth and
monetization experiments behind feature flags. Operate retention
mechanics. Plan content updates.

**Agents**: `growth-engineer`, `analytics-engineer`,
`monetization-designer`, `live-ops-designer`, `community-manager`,
`product-designer` (for variant PRDs), framework specialists (for
implementation), `release-manager` (for rollout).

**Skills**: `/analytics-plan`, `/experiment-plan`, `/retention-audit`,
`/funnel-audit`, `/paywall-design`, `/staged-rollout` (for variants
behind flags).

**Artefacts**:
- `production/live-ops/experiments/[exp-id].md`
- `production/live-ops/retention-[date].md`
- `production/live-ops/funnel-[feature].md`

**Gates**: PD-PRICING (per pricing change), PR-MILESTONE.

**Walkthrough — retention audit**:

```text
User: /retention-audit

Agent (growth-engineer):
  "Pulling D1, D7, D30 retention curves from analytics. Three-cohort
   comparison: launch cohort, +30d, +60d.

   Initial findings:
   - D1 retention: 42% → 51% (improved after onboarding rev)
   - D7 retention: 18% → 19% (flat)
   - D30 retention: 8% → 8% (flat)

   The bottleneck is D7. The funnel from D1 → D7 has the largest drop.
   Three hypotheses ranked by likely impact and effort:

   1. Push opt-in is 38% (industry median ~55%); users without push are
      not pulled back. Estimated lift: +2-4 D7 points. Effort: rationale
      screen + value-moment trigger.

   2. The home feed is empty for first-time users without setting
      preferences. Estimated lift: +1-2 D7 points. Effort: defaults +
      one-tap onboarding.

   3. The paywall hits at session 2; some users churn rather than
      decide. Estimated lift: +1 D7 point. Effort: defer paywall to
      session 4.

   Want to design experiments for any of these? I'll spawn
   analytics-engineer to draft the event taxonomy and instrumentation
   plan."
```

---

## Stage Transitions

`/gate-check [target-stage]` validates readiness to advance. Verdicts:

- **PASS** — every required artefact is present, every required gate
  returned READY/APPROVE.
- **CONCERNS** — present but at least one gate returned CONCERNS. The
  user decides whether to proceed.
- **FAIL** — at least one gate returned NOT READY/REJECT, or a required
  artefact is missing.

Even in `lean` review mode, PHASE-GATEs always run.

---

## Lifecycle Anti-Patterns

- **Skipping Discovery** because "we already know what we're building".
  Briefs that fit on a napkin still belong in the file system. Future
  agents need them.
- **Skipping Architecture** because "we'll figure it out as we go". Mobile
  rewrites are six-month projects.
- **Skipping QA & Beta** because "tests pass". Tests do not validate
  feel, accessibility, or real-world performance.
- **Skipping Live Ops** because "we shipped". Apps that don't grow,
  shrink. The post-launch month is when most decisions get made.

---

## Cross-Cutting Concerns

### Director Review Modes

Every gate runs in one of three modes — set globally (in
`technical-preferences.md`) or per-skill via the `mode:` argument.

| Mode | Description | When to use |
|---|---|---|
| `strict` | Every required gate runs. Phase-gates run all four directors in parallel. Spawn cost: highest. | Pre-release, post-incident, regulated apps (finance, health, kids), public V1 launch. |
| `standard` | Required gates run; optional gates are skipped. | Default for active development. |
| `lean` | Only blocking gates run; advisory gates skipped. PHASE-GATE always runs even in lean mode. | Solo developer, prototyping, internal experimental builds, hackathon mode. |

The mode applies to *gates*, not to the underlying skills. `/dev-story`
still implements the story; only the post-story review changes shape.

### The Collaboration Protocol

Every interaction with every agent follows the same five-step shape:

1. **Question** — the user states intent.
2. **Options** — the agent surfaces at least two viable paths with
   trade-offs, never a single take-it-or-leave-it answer.
3. **Decision** — the user picks. The agent never picks for the user on
   non-trivial calls.
4. **Draft** — the agent produces a proposed artefact (PRD section, ADR,
   code, copy) and shows it for review.
5. **Approval** — the user gives the explicit go-ahead before any Write
   tool fires.

`docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` is the canonical reference; the
hooks `validate-commit.sh` and `validate-skill-change.sh` enforce key
slices of it automatically.

### The AskUserQuestion Tool

Multi-option decisions use the structured `AskUserQuestion` tool, which
the harness renders as a chooser UI. Use it for: framework choice, state
library choice, paywall position, push-permission moment, default home
tab. Do *not* use it for free-form authoring decisions — those belong
in conversation.

### Agent Coordination (3-Tier Hierarchy)

```text
Tier 1 — Directors (opus)
  product-director       — product vision, pricing, positioning
  mobile-architect       — framework, architecture, security, perf
  + sonnet leadership: producer, lead-designer, lead-developer

Tier 2 — Department Leads (sonnet)
  visual-design-director, motion-designer, info-architect,
  content-strategist, qa-lead, brand-director, release-manager,
  monetization-designer, growth-engineer

Tier 3 — Specialists (sonnet)
  Cross-platform: react-native-specialist, typescript-specialist,
                  flutter-specialist, dart-specialist,
                  state-management-specialist, animation-specialist
  iOS:            ios-specialist, swift-specialist, swiftui-specialist
  Android:        android-specialist, kotlin-specialist,
                  jetpack-compose-specialist
  Backend:        backend-engineer, api-designer, database-specialist,
                  graphql-specialist, firebase-specialist,
                  offline-sync-specialist
  Quality:        qa-tester, mobile-test-automation
  Specialists:    accessibility-specialist, security-engineer,
                  performance-analyst, push-notification-specialist,
                  payment-integration-specialist, localization-lead,
                  analytics-engineer, ai-engineer, ai-product-designer,
                  community-manager, mobile-devops, tools-engineer
```

Skip-level delegation is allowed only when the intervening tier is
unavailable and the work is time-critical; the skip is logged.

### Automated Hooks (Safety Net)

12 bash hooks fire automatically. See `.claude/docs/hooks-reference.md`
for the index. The two most consequential at runtime are:

- `session-start.sh` — previews `production/session-state/active.md` on
  every new session. After a crash or `/clear`, it is the recovery target.
- `validate-commit.sh` — blocks commits with invalid JSON in data files
  and warns on commits without a PRD/ADR/STORY reference.

Hooks must `exit 0` to allow and `exit 2` to block. Anything else is a
non-blocking warning.

### Context Resilience

Context is the most expensive resource. The template handles compaction
and crashes by writing decisions to disk *as they are made*, not at the
end of a session.

- `production/session-state/active.md` — the live checkpoint, updated by
  every meaningful skill.
- Incremental file writing — multi-section docs are written
  section-by-section so the conversation only carries the *current*
  section's draft.
- After `/clear` or compaction, read `active.md` and any in-flight files
  first; the conversation summary is secondary.

`.claude/docs/context-management.md` is the full reference.

### Brownfield Adoption

Existing apps adopt the template via `/adopt`:

1. `/start` auto-detects existing artefacts.
2. `/adopt` audits PRDs, ADRs, stories, and tests against template
   conventions and produces a numbered migration plan that does *not*
   overwrite project work.
3. `/setup-framework` only if the framework is not yet pinned.
4. `/gate-check` reveals which lifecycle stage the project is actually
   in (often Sprint Dev or QA).
5. `/reverse-document` retro-builds the missing PRDs and ADRs from
   working code if the team needs them for new features.

### Gate System

Director gates are the cheap-now-or-expensive-later checkpoints.
`.claude/docs/director-gates.md` is the canonical catalogue. Gate IDs
are stable (`PD-PRD`, `MA-ADR`, `LD-DESIGN-SYSTEM`, `A11Y-AUDIT`, etc.);
skills reference them by ID, never by inlined prompt.

Strictest-verdict-wins for parallel gates: any single NOT READY in a
phase gate set fails the whole phase, regardless of how many gates
returned READY.

### Reverse Documentation

When code exists without specs, `/reverse-document` walks the source
tree and authors the PRD or ADR backwards from working behaviour. The
output is marked `Reverse-engineered` and queued for human review — it
is never silently merged into the canonical doc set.

---

## Appendix A: Agent Quick-Reference

### "I need to do X — which agent do I use?"

| I need to... | Use this agent |
|---|---|
| Define what we're building | `product-designer` |
| Decide who we're building for | `user-researcher` + `product-director` |
| Map the user journey | `ux-designer` |
| Pick a state-management library | `mobile-architect` (consults `state-management-specialist`) |
| Pick the framework | `mobile-architect` |
| Implement an iOS-only screen | `swiftui-specialist` |
| Implement an Android-only screen | `jetpack-compose-specialist` |
| Implement a cross-platform component | `react-native-specialist` or `flutter-specialist` |
| Wire up an API client | `api-designer` (designs) + `backend-engineer` (implements) |
| Set up an offline cache | `offline-sync-specialist` |
| Set up GraphQL | `graphql-specialist` |
| Set up Firebase | `firebase-specialist` |
| Plan the next sprint | `producer` |
| Profile a slow scroll | `performance-analyst` |
| Trim cold-start time | `performance-analyst` + framework specialist |
| Audit a screen for a11y | `accessibility-specialist` |
| Localize the app | `localization-lead` |
| Set up push | `push-notification-specialist` |
| Add an in-app purchase | `payment-integration-specialist` + `monetization-designer` |
| Run a beta | `qa-lead` + `release-manager` |
| Cut a release | `release-manager` + `mobile-devops` |
| Write microcopy | `content-designer` |
| Define brand voice | `content-strategist` |
| Review brand fit | `brand-director` |
| Plan a growth experiment | `growth-engineer` + `analytics-engineer` |
| Plan a retention loop | `live-ops-designer` + `growth-engineer` |
| Design a paywall | `monetization-designer` + `ux-designer` |
| Resolve a product disagreement | `product-director` |
| Resolve a tech disagreement | `mobile-architect` |
| Fix a CI failure | `mobile-devops` |
| Run a security audit | `security-engineer` |
| Build an LLM-backed feature | `ai-product-designer` (UX) + `ai-engineer` (impl) |

### Agent Hierarchy

```text
Directors (Tier 1, opus)
├── product-director
└── mobile-architect

Leadership (Tier 1, sonnet)
├── producer
├── lead-designer
└── lead-developer

Department Leads (Tier 2, sonnet)
├── visual-design-director, motion-designer, info-architect,
│   content-strategist, brand-director
├── qa-lead, release-manager, monetization-designer, growth-engineer

Specialists (Tier 3, sonnet)
├── Cross-platform: RN, TS, Flutter, Dart, state, animation
├── iOS: ios, swift, swiftui
├── Android: android, kotlin, jetpack-compose
├── Backend: backend-engineer, api-designer, database, graphql,
│            firebase, offline-sync
├── Quality: qa-tester, mobile-test-automation
└── Cross-cutting: accessibility, security, performance, push,
                   payments, localization, analytics, ai-engineer,
                   ai-product-designer, community-manager,
                   mobile-devops, tools-engineer
```

---

## Appendix B: Slash-Command Quick Reference

The full list of skills lives in `.claude/skills/`. The descriptions
below are deliberately one line each — see each skill's SKILL.md
frontmatter for the full prompt.

### Onboarding & Navigation

- `/start` — first-time onboarding router.
- `/help` — context-aware "what should I do next?".
- `/onboard` — generates a contextual onboarding doc by role.
- `/project-stage-detect` — read-only stage classification + next-step
  recommendation.
- `/adopt` — brownfield audit + migration plan.

### Setup

- `/setup-framework` — pin the framework, populate version reference.
- `/test-setup` — scaffold the test framework + CI pipeline.
- `/test-helpers` — generate framework-specific test helpers.

### Product & Design

- `/discover` — guided discovery interview.
- `/brainstorm` — guided ideation for a mobile app.
- `/persona` — author a primary or secondary user persona.
- `/jobs-to-be-done` — JTBD authoring + evidence collection.
- `/prd-create` — section-by-section PRD authoring.
- `/prd-review` — single-PRD validation gate.
- `/review-all-prds` — cross-PRD consistency review (opus tier).
- `/quick-design` — lightweight design spec for small changes.
- `/design-system-create` — design-token authoring.
- `/motion-direction` — motion-language definition.
- `/microcopy-pass` — UX-copy review on a screen or flow.
- `/component-spec` — define a reusable component.
- `/flow-create` — author a user-journey doc.
- `/map-systems` — decompose the app into systems.
- `/propagate-design-change` — find stale ADRs after a PRD edit.
- `/consistency-check` — audit PRDs against the entity registry.

### UX & Interface

- `/ux-design` — author a UX spec (screen / flow / HUD).
- `/ux-review` — validate a UX spec.

### Architecture

- `/architecture-decision` — author an ADR.
- `/architecture-review` — cross-ADR coverage gate (opus tier).
- `/api-contract` — author the API contract for a feature.
- `/data-model` — author the data model for a feature.
- `/create-control-manifest` — flat programmer rules sheet.

### Stories & Sprints

- `/create-epics` — translate PRDs + architecture into epics.
- `/create-stories` — break an epic into stories.
- `/sprint-plan` — plan or update a sprint.
- `/story-readiness` — verify a story is ready for pickup.
- `/dev-story` — implement a story end to end.
- `/code-review` — review code against rules and ADRs.
- `/story-done` — verify acceptance criteria + close the story.
- `/sprint-status` — daily sprint snapshot (haiku tier).
- `/scope-check` — flag scope creep (haiku tier).

### Reviews & Analysis

- `/design-review` — generic single-PRD review.
- `/test-evidence-review` — evaluate test files and manual evidence.
- `/balance-check` — pricing / paywall / tunable consistency.
- `/perf-profile` — performance investigation.
- `/security-audit` — security audit (cert pinning, secrets, OWASP).
- `/a11y-audit` — accessibility audit.
- `/asset-audit` — visual-asset compliance.
- `/tech-debt` — debt registry update.
- `/regression-suite` — coverage drift + regression-test mapping.
- `/test-flakiness` — flaky-test detection.

### QA & Testing

- `/qa-plan` — sprint or feature test plan.
- `/smoke-check` — pre-handoff smoke gate.
- `/playtest-report` — structured beta-test report.
- `/bug-report` — author a structured bug.
- `/bug-triage` — re-prioritise open bugs.
- `/team-qa` — orchestrate the QA team.

### Production Management

- `/estimate` — task effort estimate.
- `/retrospective` — sprint or milestone retro.
- `/milestone-review` — milestone progress + go/no-go.
- `/content-audit` — feature content vs. PRD specification.
- `/gate-check` — phase-transition validation (opus tier).
- `/reverse-document` — back-author missing specs from code.

### Release

- `/release-checklist` — pre-release validation.
- `/launch-checklist` — full launch readiness sweep.
- `/store-listing` — App Store / Play Store metadata.
- `/staged-rollout` — release staging + rollback plan.
- `/changelog` — internal changelog generation.
- `/patch-notes` — player-facing patch notes (haiku tier).
- `/hotfix` — emergency-fix workflow.

### Live Ops & Growth

- `/analytics-plan` — event taxonomy + dashboard plan.
- `/experiment-plan` — A/B experiment design + analysis plan.
- `/retention-audit` — D1 / D7 / D30 retention curve audit.
- `/funnel-audit` — conversion-funnel audit.
- `/paywall-design` — paywall placement + UX.

### Team Orchestration

- `/team-design` — full design team.
- `/team-ux` — UX-pipeline orchestration.
- `/team-combat` (deprecated for app studios) — replaced by
  `/team-feature`.
- `/team-feature` — full vertical-slice team.
- `/team-polish` — performance + technical-art + audio polish.
- `/team-release` — full release coordination.
- `/team-live-ops` — live-ops + growth coordination.
- `/team-narrative` — content-narrative team (when story-rich).

### Creative

- `/asset-spec` — per-asset specs + AI generation prompts.
- `/localize` — full localization pipeline.

---

## Appendix C: Common Workflows

### Workflow 1: "I have an idea but no app yet"

```text
/start (route to /discover)
  → /discover                                  (capture brief)
  → /persona                                   (primary + secondary)
  → /jobs-to-be-done                           (top 3 JTBDs)
  → /setup-framework                           (pin RN / Flutter / native)
  → /map-systems                               (decompose into systems)
  → /prd-create [feature]    × N               (one per system)
  → /review-all-prds                           (consistency)
  → /architecture-decision   × N               (state, nav, networking…)
  → /architecture-review                       (coverage)
  → /create-control-manifest
  → /create-epics → /create-stories
  → /sprint-plan
  → /dev-story  (loop)
```

### Workflow 2: "I have designs and want to start coding"

```text
/start (detects designs)
  → /adopt                                     (audit PRDs)
  → /setup-framework                           (if not pinned)
  → /architecture-decision  × N
  → /architecture-review
  → /create-epics → /create-stories
  → /sprint-plan
  → /dev-story  (loop)
```

### Workflow 3: "I need to add a complex feature mid-production"

```text
/prd-create [new-feature]
  → /prd-review
  → /propagate-design-change                   (find affected ADRs)
  → /architecture-decision  (if architecture shifts)
  → /create-stories                            (story breakdown)
  → /sprint-plan update                        (slot into current sprint)
  → /team-feature                              (full vertical slice)
```

### Workflow 4: "Something broke in production"

```text
/bug-report                                    (capture repro + severity)
  → /bug-triage                                (severity + sprint slot)
  → /hotfix                                    (if Sev 1 / 2)
  → /smoke-check                               (verify fix)
  → /staged-rollout                            (controlled release)
  → /retrospective                             (post-incident review)
```

### Workflow 5: "Existing project, new template adoption"

```text
/start
  → /adopt                                     (numbered migration plan)
  → /reverse-document                          (back-author missing PRDs/ADRs)
  → /setup-framework                           (pin if missing)
  → /gate-check                                (where are we, really?)
  → resume normal Sprint Dev workflow
```

### Workflow 6: "Starting a new sprint"

```text
/retrospective                                 (close the previous sprint)
  → /sprint-plan new
  → /story-readiness  × N                      (validate every story)
  → /estimate                                  (capacity vs. scope)
  → /qa-plan                                   (test plan for the sprint)
  → /dev-story  (loop)
```

### Workflow 7: "Shipping the app"

```text
/launch-checklist                              (full readiness sweep)
  → /a11y-audit
  → /security-audit
  → /perf-profile
  → /smoke-check
  → /gate-check release                        (all four PHASE-GATEs)
  → /store-listing                             (final metadata)
  → /staged-rollout 1.0.0
  → /patch-notes                               (player-facing)
  → /changelog                                 (internal)
```

### Workflow 8: "I'm lost / don't know what to do next"

```text
/help                                          (context-aware suggestion)
  → or /project-stage-detect                   (full audit)
  → resume the appropriate phase
```

---

## Tips for Getting the Most Out of the System

- **Treat the file as the memory.** The conversation will compact;
  `production/session-state/active.md` will not.
- **Run `/help` whenever uncertain.** It is haiku-tier (cheap and fast)
  and reads the project state for context.
- **Spawn parallel subagents when inputs are independent.** Two
  reviewers for two PRDs > sequential review.
- **Keep PRDs short.** A long PRD usually hides an unmade decision.
- **Pick the cheapest tier that produces correct output.** Haiku for
  read-only checks; Opus only when a verdict spans 5+ documents.
- **Read the framework reference before quoting an API.** The LLM's
  knowledge cutoff is months behind the pinned framework version on
  most projects.
