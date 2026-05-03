# Skills Reference

An index of every slash-command skill bundled with the template, grouped by
category. Skill definitions live in `.claude/skills/`. Each entry below
gives a one-line description; full descriptions live in the skill's
SKILL.md frontmatter.

## Model Tier Summary

Pick the cheapest tier that produces correct output. Skills not listed
here default to **Sonnet**.

- **Haiku** (read-only, fast lookups): `/help`, `/sprint-status`,
  `/story-readiness`, `/scope-check`, `/patch-notes`.
- **Opus** (multi-document synthesis, high-stakes verdicts):
  `/review-all-prds`, `/architecture-review`, `/gate-check`.
- **Sonnet** (default): all 64 other skills.

## Onboarding & Meta

| Skill | What it does | Tier |
|---|---|---|
| `/start` | First-time onboarding — asks where you are starting from, classifies you, and routes to the right next skill. | sonnet |
| `/help` | Analyzes the project state and the user's question, then recommends the single best next skill or step. | haiku |
| `/onboard` | Generates a contextual onboarding doc for a new contributor based on their role (engineer, designer, PM, QA). | sonnet |
| `/project-stage-detect` | Read-only audit that classifies the project's current stage and recommends the next sensible skill. | sonnet |
| `/adopt` | Brownfield onboarding — audits existing artefacts for template compatibility and produces a migration plan. | sonnet |

## Setup

| Skill | What it does | Tier |
|---|---|---|
| `/setup-framework` | Pins the framework, captures the version, populates `docs/framework-reference/`, and writes the framework to technical-preferences. | sonnet |
| `/test-setup` | Scaffolds the test framework and CI pipeline — `tests/` structure, framework runner, GitHub Actions or Bitrise workflow. | sonnet |
| `/test-helpers` | Generates a framework-specific test helper library — factories, mocks, custom matchers, shared utilities under `tests/helpers/`. | sonnet |

## Design

| Skill | What it does | Tier |
|---|---|---|
| `/brainstorm` | Guided ideation for a mobile app — from blank page to a structured concept doc (target user, JTBD, MVP scope, primary metric). | sonnet |
| `/design-bible` | Section-by-section authoring of the Design Bible — visual identity tokens, app icon, splash, the spec that gates all visual work. | sonnet |
| `/design-system` | Section-by-section PRD authoring for a single mobile-app system. | sonnet |
| `/prd-review` | Validates a single PRD for completeness, consistency, accessibility, and implementability. APPROVED / NEEDS REVISION / MAJOR REVISION. | sonnet |
| `/review-all-prds` | Holistic cross-PRD review — finds contradictions, dominant strategies, broken funnels, and missing-system gaps single-PRD review cannot detect. | opus |
| `/design-review` | Reviews a PRD for completeness, consistency, implementability — generic single-PRD entry point, run in a fresh session. | sonnet |
| `/quick-design` | Lightweight design spec for small changes when a full PRD is overkill — embeds directly into a story file. | sonnet |
| `/map-systems` | Decomposes the app concept into discrete systems, maps dependencies, prioritizes design order, writes the systems index. | sonnet |
| `/propagate-design-change` | When a PRD changes, scans all ADRs, dependent PRDs, stories, and the registry to identify what is now stale. | sonnet |
| `/consistency-check` | Read-only audit scanning all PRDs against the entity registry to detect cross-doc inconsistencies. | sonnet |
| `/reverse-document` | Generates a PRD or architecture doc from existing implementation — works backward from code to the doc that should have existed. | sonnet |
| `/extract` | Extracts patterns from existing source code into a structured `system.md` — naming, state shape, navigation pattern, error handling. | sonnet |

## UX

| Skill | What it does | Tier |
|---|---|---|
| `/ux-design` | Section-by-section UX spec authoring for a single screen, flow, or HUD element. | sonnet |
| `/ux-review` | Validates a UX spec for completeness, accessibility (WCAG 2.2 AA), platform conventions (iOS HIG / Material 3). | sonnet |

## Architecture

| Skill | What it does | Tier |
|---|---|---|
| `/architecture-decision` | Creates an Architecture Decision Record (ADR) — context, alternatives, decision, consequences, PRD requirements addressed. | sonnet |
| `/architecture-review` | Validates the architecture against all PRDs — traceability matrix, coverage gaps, cross-ADR conflicts. PASS / CONCERNS / FAIL. | opus |
| `/create-architecture` | Section-by-section authoring of the master architecture doc and Required ADR list. | sonnet |
| `/create-control-manifest` | Produces a flat, immediately-actionable rules sheet — do this, never do that, per system and per layer. | sonnet |
| `/create-epics` | Translates approved PRDs and architecture into epics — one epic per architectural module. | sonnet |
| `/create-stories` | Decomposes a single epic into implementable story files with TR-ID, ADR, acceptance criteria, story type, evidence path. | sonnet |

## Sprint Planning

| Skill | What it does | Tier |
|---|---|---|
| `/sprint-plan` | Generates or updates a sprint plan based on the milestone, completed work, and team capacity. | sonnet |
| `/sprint-status` | Fast status check — reads the sprint plan, scans story files, produces a concise progress snapshot with risks. | haiku |
| `/scope-check` | Compares current sprint or feature scope against the original plan to detect scope creep. | haiku |
| `/estimate` | Estimates effort for a story, batch, or epic by analyzing complexity, dependencies, velocity, and risk. | sonnet |
| `/milestone-review` | Comprehensive milestone progress review — completeness, quality metrics, risk, go/no-go recommendation. | sonnet |

## Production Rituals

| Skill | What it does | Tier |
|---|---|---|
| `/retrospective` | Generates a sprint or milestone retrospective by analyzing completed work, velocity, blockers, and patterns. | sonnet |
| `/story-readiness` | Validates that a story file is implementation-ready. READY / NEEDS WORK / BLOCKED. | haiku |
| `/story-done` | End-of-story completion review — verifies acceptance criteria, surfaces deviations, marks the story Complete. | sonnet |
| `/gate-check` | Validates readiness to advance between development phases. Synthesizes all department verdicts into PASS / CONCERNS / FAIL. | opus |

## Dev Workflow

| Skill | What it does | Tier |
|---|---|---|
| `/dev-story` | Reads a story file and implements it end-to-end — loads PRD, governing ADR, control manifest, routes to the right specialist. | sonnet |
| `/code-review` | Architectural and quality review of one or more files — coding standards, SOLID, testability, ADR compliance. | sonnet |

## Test Infra

| Skill | What it does | Tier |
|---|---|---|
| `/regression-suite` | Maps test coverage to PRD critical paths, identifies fixed bugs without regression tests, maintains the suite. | sonnet |
| `/test-flakiness` | Detects non-deterministic tests by reading CI run history; recommends quarantine or fix; maintains a flaky-test registry. | sonnet |
| `/test-evidence-review` | Quality review of test files and manual evidence — assertion coverage, edge cases, naming, completeness. ADEQUATE / INCOMPLETE / MISSING. | sonnet |

## QA

| Skill | What it does | Tier |
|---|---|---|
| `/qa-plan` | Generates a QA test plan — classifies stories by test type, defines automated tests, manual cases, smoke scope, device matrix. | sonnet |
| `/smoke-check` | Runs the critical-path smoke gate before QA hand-off. PASS / FAIL. | sonnet |
| `/soak-test` | Generates a soak-test protocol for extended sessions — observes leaks, battery drain, background-foreground crashes. | sonnet |
| `/team-qa` | Orchestrate the QA team through a full testing cycle — coordinates qa-lead and qa-tester. | sonnet |
| `/user-test-report` | Generates a structured user-test (beta) report template OR analyzes existing user-test notes into a structured format. | sonnet |

## Bug & Hotfix

| Skill | What it does | Tier |
|---|---|---|
| `/bug-report` | Authors a structured bug report from a description, OR analyzes code/logs to derive likely bugs. | sonnet |
| `/bug-triage` | Reads all open bugs, re-evaluates priority and severity, surfaces systemic trends, assigns to a sprint or backlog. | sonnet |
| `/hotfix` | Emergency fix workflow — bypasses normal sprint while keeping a full audit trail; tracks approvals; ensures backport. | sonnet |

## Performance & Security

| Skill | What it does | Tier |
|---|---|---|
| `/perf-profile` | Structured performance profiling — cold/warm start, frame time, memory, network, app size, battery against budgets. | sonnet |
| `/security-audit` | Audits the app for vulnerabilities — insecure storage, TLS, OWASP MASVS, CVEs, secrets, deep links, JS bridge, WebView. | sonnet |

## Asset & Content

| Skill | What it does | Tier |
|---|---|---|
| `/asset-spec` | Generates per-asset visual specs and AI-generation prompts from PRDs and the design bible; updates a master asset manifest. | sonnet |
| `/asset-audit` | Audits app assets for naming conventions, file size budgets, format standards, app icon, splash, store imagery, orphans. | sonnet |
| `/content-audit` | Audits PRD-specified content counts (screens, copy, images, locales, push categories, onboarding steps) against what's built. | sonnet |
| `/balance-check` | Analyzes pricing tiers, paywall configs, A/B variants, and feature-flag values for outliers and broken funnels. | sonnet |

## Release & Launch

| Skill | What it does | Tier |
|---|---|---|
| `/release-checklist` | Pre-release validation — build verification, certification, store metadata, screenshots, privacy nutrition labels, version numbering. | sonnet |
| `/launch-checklist` | Full launch readiness across departments — code, content, store listings, marketing, community, infra, legal, accessibility, sign-offs. | sonnet |
| `/day-one-patch` | Prepares a day-one patch for launch — scopes, prioritizes, implements, and QA-gates a focused patch with rollback plan. | sonnet |

## Communication

| Skill | What it does | Tier |
|---|---|---|
| `/changelog` | Auto-generates a changelog from git commits, sprint data, design docs — internal and user-facing versions for a release window. | sonnet |
| `/patch-notes` | Generates user-facing patch notes from git history, sprint data, and the internal changelog; respects store char limits. | haiku |
| `/localize` | Full localization pipeline — extract strings, manage tables, validate translations, RTL test, locale QA, VO localization, freeze. | sonnet |

## Live-Ops

| Skill | What it does | Tier |
|---|---|---|
| `/team-live-ops` | Orchestrate the live-ops team for post-launch content planning — coordinates live-ops, monetization, analytics, community, content. | sonnet |

## Team Orchestrators

| Skill | What it does | Tier |
|---|---|---|
| `/team-design` | Orchestrate a full design cycle — coordinates lead-designer, ux-designer, visual-design-director, interaction- and motion-designer. | sonnet |
| `/team-frontend` | Orchestrate the mobile UI build — coordinates lead-developer, framework specialist, state-management, animation. | sonnet |
| `/team-backend` | Orchestrate the server / data side — coordinates backend-engineer, api-designer, database, offline-sync, push, firebase. | sonnet |
| `/team-content` | Orchestrate the content pipeline — content-strategist, content-designer, localization-lead, ux-designer. | sonnet |
| `/team-polish` | Orchestrate the polish phase — performance-analyst, accessibility-specialist, animation-specialist, qa-tester, content-designer. | sonnet |
| `/team-release` | Orchestrate the release team — release-manager, qa-lead, mobile-devops, producer; from candidate through certification and rollout. | sonnet |

## Skill Maintenance

| Skill | What it does | Tier |
|---|---|---|
| `/skill-improve` | Improves a SKILL.md file via static lint, fix proposal, rewrite, and re-test loop. | sonnet |
| `/prototype` | Rapid prototyping workflow that deliberately skips standards to validate a risky concept fast. | sonnet |
| `/tech-debt` | Tracks, categorizes, and prioritizes technical debt — scans indicators, maintains a register, recommends repayment. | sonnet |
