# Directory Structure

The repository is organised so that every artefact has one obvious home and
agents never have to guess where to write. The shape below is framework-agnostic
at the top, and each `src/` subtree gets framework-specific conventions
documented in `app_dev/src/CLAUDE.md` once the framework is configured.

```text
app_dev/
├── CLAUDE.md                       # Master configuration loaded by Claude Code
├── README.md                       # Human-facing project overview
├── .gitignore                      # Mobile-aware ignore list
├── .claude/                        # Agent definitions, skills, hooks, rules, docs
│   ├── settings.json               # Hook wiring, permissions, status line
│   ├── statusline.sh               # Single-line breadcrumb renderer
│   ├── agents/                     # 53 agent definition files
│   ├── skills/                     # Slash-command skill definitions
│   ├── hooks/                      # Bash hooks (12 scripts)
│   ├── rules/                      # Path-scoped coding rules
│   ├── agent-memory/               # Per-agent scratch (gitignored)
│   └── docs/                       # Reference docs (this directory)
├── src/                            # App source code (shape varies by framework)
├── tests/                          # Unit, integration, end-to-end suites
├── design/                         # PRDs, flows, registry of entities
│   ├── prd/                        # Per-feature product requirements docs
│   ├── flows/                      # End-to-end user journeys
│   └── registry/                   # Canonical names for screens, models, events
├── docs/                           # Technical documentation
│   ├── architecture/               # Master architecture doc + ADRs
│   ├── examples/                   # Reference snippets
│   ├── registry/                   # Cross-doc entity registry
│   ├── framework-reference/        # Framework version pin + API references
│   ├── COLLABORATIVE-DESIGN-PRINCIPLE.md
│   └── WORKFLOW-GUIDE.md
└── production/                     # Production management
    ├── sprints/                    # Sprint plans and retros
    ├── qa/                         # QA evidence, smoke runs, bug reports
    │   └── bugs/                   # One markdown file per open bug
    ├── session-state/              # Ephemeral session checkpoint (gitignored)
    └── session-logs/               # Audit trail of sessions and agent calls (gitignored)
```

## Framework-Specific `src/` Conventions

The shape of `src/` is locked in by `/setup-framework`. Until then, treat the
top of `src/` as empty. The skill writes a CLAUDE.md inside `src/` that pins
the convention for the chosen stack — typical layouts shown below.

### React Native + TypeScript (recommended for cross-platform)

```text
src/
├── app/                # Expo Router routes (or screens/ if using RN CLI)
├── features/           # Feature-vertical slices (auth/, onboarding/, ...)
├── components/         # Reusable presentational components
├── navigation/         # Navigators if not using file-based routing
├── services/           # API clients, auth, push, storage
├── state/              # Stores, selectors (Zustand, Redux Toolkit, etc.)
├── hooks/              # Cross-cutting hooks
├── theme/              # Tokens, typography, spacing, motion
├── lib/                # Pure utilities, no React imports
└── types/              # Ambient and shared TS types
```

### Flutter + Dart

```text
src/
├── lib/
│   ├── main.dart
│   ├── app/             # App shell, routing config
│   ├── features/        # Feature slices (auth/, profile/, ...)
│   ├── widgets/         # Reusable widgets
│   ├── data/            # Repositories, API clients, models
│   ├── domain/          # Use cases, entities
│   ├── presentation/    # Screens, view models
│   └── core/            # Theme, DI, error types
└── test/                # Mirrors lib/ structure (Flutter convention)
```

### Native iOS (Swift / SwiftUI)

```text
src/
├── App/                  # @main entry, AppDelegate/SceneDelegate
├── Features/             # Per-feature folders with Views, ViewModels, Services
├── DesignSystem/         # Colors, typography, components
├── Networking/           # URLSession clients, request builders
├── Persistence/          # SwiftData / Core Data / Keychain
├── Services/             # Auth, push, analytics
└── Resources/            # Assets, Localizable.strings, Info.plist
```

### Native Android (Kotlin / Jetpack Compose)

```text
src/
├── app/
│   └── src/main/java/com/[org]/[app]/
│       ├── ui/           # Compose screens, theme, components
│       ├── feature/      # Per-feature ViewModels and use cases
│       ├── data/         # Repositories, Room, Retrofit
│       ├── domain/       # Pure Kotlin domain models
│       ├── di/           # Hilt modules
│       └── App.kt
└── app/src/main/res/     # Strings, drawables (legacy XML resources)
```

## Why This Shape

- **`design/` is product-owned, `docs/` is engineering-owned.** PRDs live with
  the people authoring them; ADRs live with the people enforcing them.
- **`production/` holds disposable state.** Active session checkpoints,
  sprint plans, QA logs — anything that captures *how* the work happens, not
  the work itself. Most of it is gitignored.
- **Tests are siblings of `src/`, never nested inside.** This makes coverage
  visible and forces test files to be addressable by automated tooling.
- **Framework reference is version-pinned.** Mobile frameworks ship breaking
  changes constantly; `docs/framework-reference/` records what version the
  project assumes and which APIs were verified at pin time.
