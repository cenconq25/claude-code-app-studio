# Quick Start — Mobile App Studio Template

## What You Have

A Claude Code project pre-wired for shipping production mobile apps. The
template includes 54 specialised subagents, a catalogue of slash-command
skills, path-scoped coding rules, and lifecycle hooks that audit every
session, commit, and agent invocation. Out of the box it supports React
Native, Flutter, native iOS, and native Android.

## What You Do First

Run `/start`. The skill asks where you are in the lifecycle (zero idea,
have an idea, mid-flight, existing codebase) and routes you to the right
next step.

If you already know the path you want, jump directly:

### Path A — "I have an idea but no app yet"

1. `/discover` — guided discovery interview. Captures the user, the job to
   be done, the differentiator, and the success metric. Outputs
   `design/prd/00-product-brief.md`.
2. `/setup-framework` — recommends a framework based on platform reach,
   team skills, and performance needs. Pins the version and writes
   technical preferences.
3. `/prd-create [feature]` — author a PRD section by section with
   `product-designer` driving and `ux-designer` consulting.
4. `/flow-create` — describe the primary and edge user journeys.
5. `/architecture-decision` — make the foundational ADRs (state, navigation,
   networking).
6. `/sprint-plan` — break the first vertical slice into stories.
7. `/dev-story` — implement story by story.

### Path B — "I have a brief and a framework picked"

1. `/setup-framework [framework] [version]`.
2. `/prd-create` for the first feature.
3. `/architecture-review` after the first three ADRs land.
4. `/sprint-plan new`.
5. Build.

### Path C — "Existing project, new template adoption"

1. `/start` — auto-detects what already exists.
2. `/adopt` — audits PRDs, ADRs, stories, and tests against the template
   conventions, and produces a numbered migration plan that does not
   overwrite your work.
3. `/setup-framework` only if the framework is not yet pinned.
4. `/gate-check` to find out which lifecycle stage the project belongs in.

## Picking the Right Agent

Ask "what department would handle this in a real studio?" Then route to
the matching agent.

| I need to... | Use this agent |
|---|---|
| Define what we're building | `product-designer` |
| Map the user journey | `ux-designer` or `journey-designer` |
| Pick a state-management library | `mobile-architect` (consults `state-management-specialist`) |
| Implement an iOS-only screen | `swiftui-specialist` |
| Implement a cross-platform component | `react-native-specialist` or `flutter-specialist` |
| Wire up an API client | `api-designer` (designs) + `backend-engineer` (implements) |
| Plan the next sprint | `producer` |
| Profile a slow scroll | `performance-analyst` |
| Audit a screen for a11y | `accessibility-specialist` |
| Localize the app | `localization-lead` |
| Set up push | `push-notification-specialist` |
| Add an in-app purchase | `payment-integration-specialist` + `monetization-designer` |
| Run a beta | `qa-lead` + `release-manager` |
| Cut a release | `release-manager` + `mobile-devops` |
| Write microcopy | `content-designer` |
| Review brand fit | `brand-director` |
| Plan a growth experiment | `growth-engineer` + `analytics-engineer` |
| Resolve a product disagreement | `product-director` |
| Resolve a tech disagreement | `mobile-architect` |
| Fix a CI failure | `mobile-devops` |

## Lifecycle Stages

The status line surfaces the detected stage automatically. Stages progress:

1. **Discovery** — capture the brief, identify the user, decide what to ship first.
2. **Design** — author PRDs, flows, design system tokens, motion direction.
3. **Architecture** — pin the framework, write foundational ADRs, define API contracts.
4. **Sprint Dev** — execute stories in time-boxed sprints with continuous QA.
5. **QA & Beta** — run end-to-end suites, file and triage bugs, ship to TestFlight / Play internal track.
6. **Release** — store metadata, screenshots, review submission, staged rollout.
7. **Live Ops** — analytics, growth experiments, retention work, post-launch patches.

`/gate-check` produces a PASS / CONCERNS / FAIL verdict on whether the
project is ready to advance from one stage to the next.

## Common Commands

| Command | What it does |
|---|---|
| `/start` | Onboarding router |
| `/help` | Context-aware "what should I do next?" |
| `/setup-framework` | Pick and pin the framework |
| `/prd-create` | Author a PRD section by section |
| `/flow-create` | Author a user-journey doc |
| `/architecture-decision` | Record an ADR |
| `/architecture-review` | Validate ADR coverage of all PRDs |
| `/sprint-plan` | Plan or update a sprint |
| `/dev-story` | Implement a story end to end |
| `/story-done` | Verify a story against acceptance criteria |
| `/code-review` | Review code against rules and ADRs |
| `/gate-check` | Validate readiness to advance phase |
| `/perf-profile` | Run a performance investigation |
| `/a11y-audit` | Run an accessibility audit |
| `/release-checklist` | Pre-release validation |
| `/launch-checklist` | Full launch readiness sweep |
| `/team-design` | Orchestrate the design team |
| `/team-release` | Orchestrate the release team |

The full list is in `skills-reference.md`.

## File Map

```text
CLAUDE.md                            -- Master config
.claude/
  settings.json                      -- Hook wiring + permissions
  agents/                            -- 54 agents
  skills/                            -- Slash-command playbooks
  hooks/                             -- 12 bash hooks
  rules/                             -- Path-scoped coding rules
  docs/                              -- This directory
design/prd/                          -- PRDs
design/flows/                        -- User journeys
docs/architecture/                   -- ADRs and master architecture
docs/framework-reference/            -- Pinned framework reference
production/sprints/                  -- Sprint plans + retros
production/session-state/active.md   -- Recovery target
production/qa/                       -- Bugs, smoke runs, evidence
src/                                 -- App source
tests/                               -- Unit, integration, e2e
```

## Coordination Refresher

1. Work flows down the hierarchy: directors → leads → specialists.
2. Conflicts escalate up the same path.
3. Cross-department work is coordinated by the `producer`.
4. Agents do not modify files outside their scope without explicit
   delegation.
5. Every meaningful decision lands in a file on disk before the session
   compacts.
