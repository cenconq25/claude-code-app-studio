# Setup Requirements

The template requires a few host-side tools to be useful. Hooks degrade
gracefully when something is missing — nothing breaks, but you lose the
related validation. Install what your chosen framework needs, plus the
universal helpers below.

## Universal

| Tool | Purpose | Install |
|---|---|---|
| **Git** | Version control | [git-scm.com](https://git-scm.com/) |
| **Claude Code** | Agent runtime | `npm install -g @anthropic-ai/claude-code` |
| **Bash** | Hooks runtime | macOS/Linux native; Git Bash on Windows |

## Highly Recommended

| Tool | Used by | Purpose | Install |
|---|---|---|---|
| **jq** | 6 of 12 hooks | JSON parsing in commit/asset/agent hooks | See platform notes |
| **Python 3** | 2 of 12 hooks | JSON validation in commit/asset hooks | [python.org](https://www.python.org/) |
| **Node 20+** | RN/JS tooling | Lint, type-check, test for JS-based stacks | [nodejs.org](https://nodejs.org/) |

### Installing jq

- **macOS**: `brew install jq`
- **Windows**: `winget install jqlang.jq` (or `choco install jq` / `scoop install jq`)
- **Linux**: `sudo apt install jq` / `sudo dnf install jq` / `sudo pacman -S jq`

## Per-Framework

### React Native + TypeScript

| Tool | Purpose | Install |
|---|---|---|
| Node 20+ + Yarn or pnpm | Package manager | `corepack enable` |
| Watchman | File watching for Metro | `brew install watchman` |
| Xcode 16+ | iOS build, simulator, signing | Mac App Store |
| CocoaPods | iOS native deps | `sudo gem install cocoapods` |
| Android Studio (Hedgehog or later) | Android SDK, emulators | [developer.android.com/studio](https://developer.android.com/studio) |
| Android Platform-tools (`adb`) | Bundled with Studio | — |
| Java 17 (Temurin or Zulu) | AGP 8.x runtime | `brew install --cask temurin@17` |
| EAS CLI (Expo) | Builds/distribution | `npm install -g eas-cli` |
| Detox or Maestro | E2E | `npm install -g maestro` or via project |

### Flutter + Dart

| Tool | Purpose | Install |
|---|---|---|
| Flutter SDK 3.27+ | Framework | `brew install --cask flutter` or [flutter.dev](https://flutter.dev) |
| Dart SDK | Bundled with Flutter | — |
| Xcode 16+ | iOS | Mac App Store |
| CocoaPods | iOS deps | `sudo gem install cocoapods` |
| Android Studio (Flutter plugin) | Android SDK, emulators | [developer.android.com/studio](https://developer.android.com/studio) |
| Java 17 | AGP runtime | `brew install --cask temurin@17` |
| Maestro or Patrol | E2E | `brew install facebook/fb/idb-companion` (Maestro), or `dart pub global activate patrol_cli` |

### Native iOS (Swift / SwiftUI)

| Tool | Purpose | Install |
|---|---|---|
| Xcode 16+ | Compile, simulate, sign | Mac App Store |
| Command Line Tools | git, swift CLI | `xcode-select --install` |
| SwiftLint | Style enforcement | `brew install swiftlint` |
| swift-format | Formatter | `brew install swift-format` |
| XCBeautify | Friendlier xcodebuild logs | `brew install xcbeautify` |
| Fastlane (optional) | Distribution | `brew install fastlane` |

### Native Android (Kotlin / Compose)

| Tool | Purpose | Install |
|---|---|---|
| Android Studio (Hedgehog or later) | IDE + SDK | [developer.android.com/studio](https://developer.android.com/studio) |
| Java 17 (Temurin or Zulu) | AGP 8.7 runtime | `brew install --cask temurin@17` |
| Android Platform-tools (`adb`) | Bundled with Studio | — |
| ktlint | Style enforcement | `brew install ktlint` |
| Detekt | Static analysis | `brew install detekt` |
| Espresso | E2E (bundled) | — |

## Verifying Setup

```bash
git --version
bash --version
jq --version             # optional but recommended
python3 --version        # optional
node --version           # for JS-based frameworks
flutter doctor           # for Flutter projects
xcodebuild -version      # for iOS builds
adb --version            # for Android builds
```

## Without Optional Tools

| Missing | Effect |
|---|---|
| jq | Hooks that parse hook input degrade to grep-based parsing — generally OK but slightly noisier. |
| Python 3 | `validate-commit.sh` cannot lint JSON — invalid JSON can be committed silently. |
| Node | Lint, type-check, and unit-test commands in JS-based stacks fail. |
| Watchman | Metro file watching falls back to polling — slow on large repos. |
| Xcode | Cannot build, simulate, or sign iOS. |
| Android Studio / SDK | Cannot build or sign Android. |

## Recommended IDE

The template works with any editor. Most teams use:
- **VS Code** (with Claude Code extension) for cross-platform JS/Dart work.
- **Xcode** for Swift/SwiftUI specifics.
- **Android Studio** for Kotlin/Compose specifics.

## Device Lab Recommendations

For QA and performance work, keep at least one representative device per
tier on hand:
- **iOS low-tier**: iPhone SE 3rd gen
- **iOS mid-tier**: iPhone 13/14
- **iOS high-tier**: iPhone 16 Pro (ProMotion)
- **Android low-tier**: Pixel 6a or Galaxy A14
- **Android high-tier**: Pixel 9 Pro or Galaxy S24

Cloud device farms (BrowserStack, Sauce Labs, Firebase Test Lab) cover the
long tail; do not rely on simulators for performance numbers.
