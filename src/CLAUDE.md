# Source Tree

This file describes the conventions for `src/`. The structure depends on
the framework chosen by `/setup-framework`. Until then the directory is
empty and `/setup-framework` writes a framework-specific replacement of
the relevant section below.

## General Conventions (All Frameworks)

- Code is organised by **feature**, not by file type. A feature owns its
  views, models, services, and tests.
- A `core/` (or `shared/`) module holds primitives that more than one
  feature uses: the design-token theme, the API client, error types,
  the auth session, the analytics dispatcher, the navigation root.
- Files are named after their export. One major export per file.
- Side effects flow through a service layer, not directly from views.
- Tests live in `tests/` (sibling to `src/`), not nested inside.
- Generated code lives in `src/generated/` and is regenerated, not
  edited.

## React Native + TypeScript

```text
src/
├── app/                  # Expo Router routes (or screens/ for RN CLI)
│   ├── (auth)/           # Route group: pre-auth screens
│   ├── (tabs)/           # Route group: post-auth tabs
│   └── _layout.tsx
├── features/             # Feature-vertical slices
│   └── auth/
│       ├── components/
│       ├── hooks/
│       ├── services/
│       └── auth.types.ts
├── components/           # Shared presentational components
├── hooks/                # Cross-cutting hooks
├── services/             # API clients, push, storage
├── state/                # Zustand stores or Redux slices
├── theme/                # Tokens, typography, spacing, motion
├── lib/                  # Pure utilities (no React imports)
├── i18n/                 # Localization strings + setup
├── types/                # Ambient and shared TS types
└── generated/            # Codegen output (do not edit)
```

Key conventions:
- Routes (under `app/` or `screens/`) are thin: they parse params, call
  hooks, render layout. Logic lives in `features/[name]/services/` and
  `features/[name]/hooks/`.
- Shared UI components in `components/` are stateless or hooks-driven.
- Server state through TanStack Query; client state through Zustand or
  Redux Toolkit (per the chosen ADR).

## Flutter + Dart

```text
src/
├── lib/
│   ├── main.dart
│   ├── app/             # MaterialApp / CupertinoApp shell, router config
│   ├── core/            # DI, theme, errors, env config
│   ├── features/        # Feature slices (auth/, profile/, ...)
│   │   └── auth/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   ├── shared/          # Shared widgets and utilities
│   ├── data/            # Repositories, API clients (when shared)
│   └── l10n/            # Generated localization
└── test/                # Mirrors lib/ structure (Flutter convention)
```

Key conventions:
- `domain/` is pure Dart with no Flutter dependencies — entities, use
  cases, repository interfaces.
- `data/` implements repositories using the chosen networking and
  persistence libraries.
- `presentation/` holds widgets and the chosen state management
  (Riverpod notifiers, Bloc, etc.).

## Native iOS (Swift / SwiftUI)

```text
src/
├── App/                    # @main, AppDelegate, SceneDelegate
├── Features/               # Per-feature folders
│   └── Auth/
│       ├── Views/
│       ├── ViewModels/
│       ├── Services/
│       └── Models/
├── DesignSystem/           # Colors, typography, components
├── Networking/             # URLSession clients, request types
├── Persistence/            # SwiftData / Keychain
├── Services/               # Auth, push, analytics, deep links
├── Resources/              # Assets, Localizable.xcstrings, Info.plist
└── Generated/              # Codegen output
```

Key conventions:
- Views are stateless; state lives in `@Observable` view models.
- Repositories are actors; networking is an actor-isolated dependency.
- One major type per file; file name matches type name.

## Native Android (Kotlin / Compose)

```text
src/
├── app/
│   └── src/main/java/com/[org]/[app]/
│       ├── App.kt              # Application subclass
│       ├── ui/                 # Theme, shared composables
│       │   ├── theme/
│       │   └── components/
│       ├── feature/            # Feature folders
│       │   └── auth/
│       │       ├── ui/         # Compose screens + ViewModel
│       │       ├── data/       # Repository, mappers
│       │       └── domain/     # Use cases, entities
│       ├── data/               # Cross-feature repositories
│       ├── di/                 # Hilt modules
│       └── core/               # App-wide utilities, errors
└── app/src/main/res/           # Strings, drawables (legacy XML)
```

Key conventions:
- Compose screens are thin: render state, dispatch events to ViewModel.
- ViewModels expose `StateFlow<UiState>` plus events.
- Repositories return `Flow<T>` for streaming data, suspend functions
  for one-shot calls.
- Hilt modules wire DI; never use service locators.

## Path Routing for Specialists

Once the framework is configured, file extensions route changes to the
right specialist:

| Path / extension | Specialist |
|---|---|
| `*.ts`, `*.tsx`, `*.js`, `*.jsx` | `react-native-specialist` + `typescript-specialist` |
| `*.swift` | `swift-specialist` (logic), `swiftui-specialist` (views) |
| `*.kt`, `*.kts` | `kotlin-specialist` (logic), `jetpack-compose-specialist` (UI) |
| `*.dart` | `dart-specialist` (logic), `flutter-specialist` (widgets) |
| `*/components/**`, `*/ui/**`, `*/Views/**`, `*/widgets/**` | also `visual-design-director`, `accessibility-specialist` (advisory) |
| `*/animations/**`, `*/motion/**` | also `animation-specialist`, `motion-designer` |

The full table lives in `.claude/docs/technical-preferences.md`.

## What Does Not Belong Here

- Build outputs (`build/`, `dist/`, `Pods/`, `.gradle/`) — gitignored.
- Generated docs — they go to `docs/`.
- Tests — they go to `tests/`.
- PRDs and design docs — they go to `design/`.
- ADRs — they go to `docs/architecture/`.
