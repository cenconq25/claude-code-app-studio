<p align="center">
  <h1 align="center">Claude Code App Studios</h1>
  <p align="center">
    Turn a single Claude Code session into a full mobile-app development studio.
    <br />
    53 agents. 73 skills. 12 hooks. 11 rules. One coordinated AI team.
  </p>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href=".claude/agents"><img src="https://img.shields.io/badge/agents-53-blueviolet" alt="53 Agents"></a>
  <a href=".claude/skills"><img src="https://img.shields.io/badge/skills-73-green" alt="73 Skills"></a>
  <a href=".claude/hooks"><img src="https://img.shields.io/badge/hooks-12-orange" alt="12 Hooks"></a>
  <a href=".claude/rules"><img src="https://img.shields.io/badge/rules-11-red" alt="11 Rules"></a>
  <a href="https://docs.anthropic.com/en/docs/claude-code"><img src="https://img.shields.io/badge/built%20for-Claude%20Code-f5f5f5?logo=anthropic" alt="Built for Claude Code"></a>
</p>

---

## Why This Exists

Shipping a mobile app from a single AI chat is a bad idea — and most people who try it find out the hard way. The chat will happily write a `LoginScreen.tsx` that hardcodes the API key, ships strings the localization team can't see, and leans on an `AsyncStorage` call that will fail App Store Review for storing a password. There is no PRD, no architecture review, no accessibility pass, no privacy nutrition label, no release manager. The result is fast on Monday and rejected on Friday.

This template fixes the structural gap. Instead of one general-purpose assistant, your session has **53 mobile-specific subagents** organised the way a real studio is — a product director who owns vision, a mobile architect who owns the technical spine, leads who own departments, and specialists who handle Swift concurrency, Compose recomposition, push permissions, ATT prompts, Play Data Safety forms, MASVS compliance, and the hundred other things that separate a working prototype from a shippable app. Each agent has a narrow lane, a clear escalation path, and a quality gate. You stay the studio head; the agents do the legwork and surface decisions back to you.

---

## Table of Contents

- [What's Included](#whats-included)
- [Studio Hierarchy](#studio-hierarchy)
- [Slash Commands](#slash-commands)
- [Getting Started](#getting-started)
- [Upgrading](#upgrading)
- [Project Structure](#project-structure)
- [How It Works](#how-it-works)
- [Design Philosophy](#design-philosophy)
- [Customization](#customization)
- [Platform Support](#platform-support)
- [Community](#community)
- [Support](#support)
- [License](#license)

---

## What's Included

| Category | Count | Description |
|---|---|---|
| **Agents** | 53 | Specialist subagents covering product, design, engineering (RN / Flutter / iOS / Android / backend), QA, security, performance, growth, live-ops, release, and tooling |
| **Skills** | 73 | Slash commands wired to every phase of the lifecycle (`/start`, `/setup-framework`, `/design-system`, `/create-epics`, `/dev-story`, `/release-checklist`, `/team-*` orchestrators, etc.) |
| **Hooks** | 12 | Bash scripts that run on session lifecycle, commits, pushes, asset writes, agent spawns, and compaction events |
| **Rules** | 11 | Path-scoped coding standards for RN, Flutter, Swift, Kotlin, UI surfaces, tests, design docs, content, and prototypes |
| **Templates** | Many | PRDs, ADRs, sprint plans, UX specs, design bible sections, control manifests, QA evidence, and release checklists |

## Studio Hierarchy

The 53 agents follow a three-tier structure modelled on a real product org. Tier 1 directors set direction; Tier 2 leads own departments; Tier 3 specialists do the work.

```
Tier 1 — Directors (Opus)
  product-director        mobile-architect

Tier 2 — Leads (Sonnet)
  producer                lead-designer           lead-developer

Tier 3 — Product & Design (Sonnet)
  product-designer        ux-designer             visual-design-director
  interaction-designer    motion-designer         info-architect
  content-strategist      content-designer        brand-director
  prototyper              user-researcher         ai-product-designer

Tier 3 — Engineering, Cross-Platform
  react-native-specialist typescript-specialist   flutter-specialist
  dart-specialist         state-management-specialist  animation-specialist

Tier 3 — Engineering, iOS
  ios-specialist          swift-specialist        swiftui-specialist

Tier 3 — Engineering, Android
  android-specialist      kotlin-specialist       jetpack-compose-specialist

Tier 3 — Engineering, Backend & Data
  backend-engineer        api-designer            database-specialist
  graphql-specialist      firebase-specialist     offline-sync-specialist

Tier 3 — Quality, Security, Performance
  qa-lead                 qa-tester               mobile-test-automation
  security-engineer       performance-analyst

Tier 3 — Live-Ops & Growth
  live-ops-designer       growth-engineer         analytics-engineer
  monetization-designer   community-manager

Tier 3 — Tools & Cross-Cutting
  tools-engineer          mobile-devops           accessibility-specialist
  localization-lead       push-notification-specialist
  payment-integration-specialist                  ai-engineer
  release-manager
```

The full roster — including each agent's authority, model tier, and routing notes — lives in [`.claude/docs/agent-roster.md`](.claude/docs/agent-roster.md).

### Framework Specialists

The template ships specialists for all four supported stacks. Pick the set that matches your project; specialists from other stacks stay dormant.

| Stack | Lead Specialist | Language | UI Layer |
|---|---|---|---|
| **React Native + TypeScript** | `react-native-specialist` | `typescript-specialist` | RN core / Expo Router |
| **Flutter + Dart** | `flutter-specialist` | `dart-specialist` | Material / Cupertino |
| **Native iOS** | `ios-specialist` | `swift-specialist` | `swiftui-specialist` |
| **Native Android** | `android-specialist` | `kotlin-specialist` | `jetpack-compose-specialist` |

Cross-stack specialists (`state-management-specialist`, `animation-specialist`, all backend, QA, security, growth) work the same regardless of framework.

## Slash Commands

Type `/` in Claude Code to access all 73 skills. Full one-line descriptions live in [`.claude/docs/skills-reference.md`](.claude/docs/skills-reference.md).

**Onboarding & Meta**
`/start` `/help` `/onboard` `/project-stage-detect` `/adopt`

**Setup**
`/setup-framework` `/test-setup` `/test-helpers`

**Design & PRDs**
`/brainstorm` `/design-bible` `/design-system` `/prd-review` `/review-all-prds` `/design-review` `/quick-design` `/map-systems` `/propagate-design-change` `/consistency-check` `/reverse-document` `/extract`

**UX**
`/ux-design` `/ux-review`

**Architecture**
`/architecture-decision` `/architecture-review` `/create-architecture` `/create-control-manifest` `/create-epics` `/create-stories`

**Sprint Planning**
`/sprint-plan` `/sprint-status` `/scope-check` `/estimate` `/milestone-review`

**Production Rituals**
`/retrospective` `/story-readiness` `/story-done` `/gate-check`

**Dev Workflow**
`/dev-story` `/code-review`

**Test Infrastructure**
`/regression-suite` `/test-flakiness` `/test-evidence-review`

**QA**
`/qa-plan` `/smoke-check` `/soak-test` `/team-qa` `/user-test-report`

**Bug & Hotfix**
`/bug-report` `/bug-triage` `/hotfix`

**Performance & Security**
`/perf-profile` `/security-audit`

**Asset & Content**
`/asset-spec` `/asset-audit` `/content-audit` `/balance-check`

**Release & Launch**
`/release-checklist` `/launch-checklist` `/day-one-patch`

**Communication**
`/changelog` `/patch-notes` `/localize`

**Team Orchestrators** (coordinate multiple agents on a single feature)
`/team-design` `/team-frontend` `/team-backend` `/team-content` `/team-polish` `/team-release` `/team-live-ops`

**Maintenance**
`/skill-improve` `/prototype` `/tech-debt`

## Getting Started

### Prerequisites

- [Git](https://git-scm.com/)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)
- **Recommended**: [jq](https://jqlang.github.io/jq/) for hook validation, plus the toolchain for whichever framework you pick (Xcode, Android Studio, Node 20+, or the Flutter SDK)

Hooks fail soft if optional tools are missing — you lose validation, but nothing breaks.

### Setup

1. **Drop the template into your project**:
   ```bash
   git clone <this-repo> my-app
   cd my-app/app_dev
   ```

2. **Open Claude Code**:
   ```bash
   claude
   ```

3. **First-time greenfield**: invoke `/start`. The skill asks four short questions (idea maturity, target platforms, team size, time-to-beta) and routes you to the next workflow without making assumptions.

4. **Existing codebase**: invoke `/adopt` instead. It audits what you already have, classifies the gaps by impact, and produces a numbered migration plan rather than overwriting your work.

5. **Pick a framework**:
   ```bash
   /setup-framework
   ```
   Walk through the decision inputs in [`docs/framework-reference/FRAMEWORK.md`](docs/framework-reference/FRAMEWORK.md). The skill scores React Native, Flutter, native iOS, and native Android against your inputs and surfaces a recommendation. You make the final call; the skill pins the version and writes the corresponding `VERSION.md`.

6. **Author your first PRD**:
   ```bash
   /design-system
   ```
   Drives `product-designer` through the eleven required PRD sections one at a time, writing each to `design/prd/<feature>.md` as you approve it.

7. **Plan and execute a sprint**:
   ```bash
   /sprint-plan
   /create-epics
   /create-stories <epic>
   /dev-story <story-id>
   /story-done
   ```

### Example prompts

A few realistic things to type once the template is wired up:

> "I have a half-finished onboarding flow and a vague PRD. Run `/adopt` and tell me what is missing."

> "Run `/setup-framework`. The team is two engineers, both ex-web, and we need an iOS and Android beta in eight weeks."

> "Author a PRD for the email sign-up flow. Use `/design-system`. Pause after each section so I can approve it."

## Upgrading

Already running an older version of this template? See [UPGRADING.md](UPGRADING.md) for the migration steps, the breakdown of what changed between versions, and which files are safe to overwrite vs. which need a manual merge.

## Project Structure

```
app_dev/
├── CLAUDE.md                         # Master configuration loaded at session start
├── README.md                         # Human-facing project overview
├── .gitignore                        # Mobile-aware ignore list
├── .claude/
│   ├── settings.json                 # Hook wiring, permissions, status line
│   ├── statusline.sh                 # Single-line breadcrumb renderer
│   ├── agents/                       # 53 agent definition files
│   ├── skills/                       # 73 slash-command skill definitions
│   ├── hooks/                        # 12 bash hook scripts
│   ├── rules/                        # 11 path-scoped coding rules
│   ├── agent-memory/                 # Per-agent scratch (gitignored)
│   └── docs/                         # Reference docs (roster, gates, workflow catalogue)
├── design/                           # Product-owned artefacts
│   ├── prd/                          # Per-feature PRDs
│   ├── flows/                        # End-to-end user journeys
│   └── registry/                     # Canonical names for screens, models, events
├── docs/                             # Engineering-owned artefacts
│   ├── architecture/                 # Master architecture doc + ADRs
│   ├── framework-reference/          # Framework version pin + verified API references
│   ├── examples/                     # Reference snippets
│   ├── COLLABORATIVE-DESIGN-PRINCIPLE.md
│   └── WORKFLOW-GUIDE.md
├── src/                              # App source code (shape pinned by /setup-framework)
├── tests/                            # Unit, integration, end-to-end suites
└── production/                       # Disposable production state
    ├── sprints/                      # Sprint plans and retros
    ├── qa/                           # QA evidence, smoke runs, bug reports
    ├── session-state/                # Active session checkpoint (gitignored)
    └── session-logs/                 # Session + agent audit trail (gitignored)
```

## How It Works

### Subagent spawning

Most skills spawn one or more subagents through the `Task` tool. Subagents share the parent session's permissions, run in their own context windows, and return a single text summary. Independent subagents are spawned in parallel inside one turn; dependent subagents run serially. Heavy orchestration skills like `/team-frontend` or `/review-all-prds` chain a dozen agents this way without bloating the parent's context.

### File-backed state

The conversation evaporates; files persist. Every meaningful step ends with a write to disk. `production/session-state/active.md` is the canonical recovery target — it answers "what is the current task, what has been decided, what is being touched, what is blocking" at any moment. After a `/clear`, a compaction, or a session crash, the `session-start.sh` hook auto-previews `active.md` so the next session resumes instead of restarting.

### The QODA collaboration protocol

Every non-trivial step follows **Question → Options → Decision → Approval**. Agents ask before assuming, offer at least two viable options for any judgement call, surface the trade-offs, and wait for explicit sign-off before writing files, running migrations, or committing. The protocol is embedded in [`docs/COLLABORATIVE-DESIGN-PRINCIPLE.md`](docs/COLLABORATIVE-DESIGN-PRINCIPLE.md) with concrete mobile examples (PRD authoring, ADR debates, paywall placement, push-permission UX).

### Hooks for safety, not autopilot

Twelve bash hooks wrap the session lifecycle. `validate-commit.sh` blocks commits with hardcoded values, missing PRD/ADR references, or malformed JSON. `validate-push.sh` warns on pushes to protected branches. `validate-assets.sh` enforces naming and size budgets on anything written under `assets/`. `log-agent.sh` and `log-agent-stop.sh` keep a full audit trail of every subagent invocation. `pre-compact.sh` and `post-compact.sh` preserve `active.md` across compactions. `detect-gaps.sh` surfaces obvious holes (no framework configured, code with no PRD) at session start.

### Skills as workflow

A skill is a `.claude/skills/<id>/SKILL.md` file with a YAML frontmatter (`description`, optional `model`, `allowed-tools`) and a markdown body. The body is the prompt; the harness routes the slash command to the matching skill, instantiates it with whatever arguments came in, and runs the skill body as the next turn. Adding a new workflow is just adding a new skill folder.

## Design Philosophy

A short list of opinions the template enforces, in priority order:

1. **User-driven, not autonomous.** The studio head (you) makes every decision. Agents propose, present trade-offs, and execute on approval.
2. **The file is the memory.** Every approved decision lands in a PRD, ADR, story, or `active.md` entry before the conversation can be safely compacted.
3. **Verification-driven development.** Logic ships with a unit test, UI with a screenshot or interaction recording, networking with a fixture-driven integration test. Every implementation has an artefact that proves it works.
4. **Mobile-first thinking.** App Store Review Guidelines, Play Console policy, ATT consent, Data Safety form, WCAG 2.2 AA, Dynamic Type, and 44/48 dp hit targets are not optional add-ons — they are entry-criteria.
5. **No magic numbers.** Configurable values live in typed config or remote-config — never inline. UI strings live in the localization catalogue.
6. **Every system has an ADR.** Architecture decisions are written down before code lands; `lead-developer` blocks PRs that ship architecture without one.
7. **Trunk-based development.** Short-lived feature branches, frequent integration, no long-lived release branches outside hotfixes.
8. **Privacy by default.** No PII to third parties without an ADR, no analytics events that capture user content without explicit consent, no `AsyncStorage`/`SharedPreferences` for credentials — Keychain or Keystore.

## Customization

Nothing in this template is locked. It is a starting point, not a framework.

- **Add or remove agents** — delete agents you do not need (e.g., drop `flutter-specialist` if you are RN-only); add new ones for project-specific domains.
- **Edit agent prompts** — every agent file is plain markdown plus YAML frontmatter. Tune the prompt, add house style, embed your own examples.
- **Modify skills** — adjust workflows to match your team's process. Use `/skill-improve` to lint and refactor a skill in place.
- **Add or relax rules** — `.claude/rules/` files are path-scoped via the `paths:` frontmatter. Add a rule for `src/payments/**` to enforce StoreKit conventions, or relax a rule for prototypes.
- **Tune hooks** — every hook is a small bash script. Tighten validation in `validate-commit.sh`, add new toast triggers in `notify.sh`, send Slack pings on session-stop.
- **Choose review intensity** — `full` (every director gate enforced), `lean` (phase gates only), `solo` (no gates). Set during `/start` or via `production/review-mode.txt`. Override per-run with `--review solo` on any skill.

Local-only overrides live in `CLAUDE.local.md` and `.claude/settings.local.json` — both gitignored. Templates for both ship in [`.claude/docs/`](.claude/docs/).

## Platform Support

| Platform | Status | Specialists |
|---|---|---|
| **iOS (Swift / SwiftUI)** | First-class | `ios-specialist` + `swift-specialist` + `swiftui-specialist` |
| **Android (Kotlin / Compose)** | First-class | `android-specialist` + `kotlin-specialist` + `jetpack-compose-specialist` |
| **React Native + TypeScript** | First-class | `react-native-specialist` + `typescript-specialist` + `state-management-specialist` |
| **Flutter + Dart** | First-class | `flutter-specialist` + `dart-specialist` + `state-management-specialist` |
| **Web (PWA via React Native Web)** | Best-effort | RN specialist with web ADR |
| **Desktop / TV / Wear / Watch / CarPlay** | Out of scope (v0.1.0) | — |

The template is tested on macOS and Linux with bash 3.2+. Hooks use POSIX-compatible patterns (`grep -E`, not `grep -P`) and degrade gracefully when `jq` or `python3` is missing.

## Community

- **Issues** — bug reports and feature requests via your fork's GitHub Issues. Templates ship in [`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE/).
- **Pull requests** — see [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md) for the expected shape (linked PRD/ADR, test evidence, reviewer routing).
- **Discussions** — open a discussion in your fork to share patterns, ask questions, or showcase apps shipped on the template.

## Support

This template is free and open source. If it saves you a sprint or unblocks a launch, contributions back to the template — bug fixes, new agents, sharper skills, expanded framework references — are the most valuable form of support.

---

## License

MIT License. See [LICENSE](LICENSE) for the full text. Treat all generated code, copy, and architectural choices as starting points to be reviewed — never as finished output.
