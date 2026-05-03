# Technical Preferences

This file is the canonical record of all framework-, language-, and
architecture-level choices made on this project. The `/setup-framework`
skill writes the initial values; ADRs update them over time.

> **Stub project**: every field marked `TO BE CONFIGURED` must be filled in
> before the first sprint. The `detect-gaps.sh` hook surfaces missing values
> at session start.

## Framework & Language

- **Framework**: [TO BE CONFIGURED — run /setup-framework]
- **Language**: [TO BE CONFIGURED — TypeScript / Dart / Swift / Kotlin]
- **UI Layer**: [TO BE CONFIGURED — RN core / Expo Router / Material / Cupertino / SwiftUI / Compose]
- **Minimum OS**: [TO BE CONFIGURED — e.g., iOS 17, Android 13 (API 33)]
- **Target OS**: [TO BE CONFIGURED — e.g., iOS 18, Android 15 (API 35)]

## Architecture

- **State Management**: [TO BE CONFIGURED — Zustand / Redux Toolkit / Riverpod / Bloc / TCA / ViewModel + StateFlow]
- **Navigation**: [TO BE CONFIGURED — Expo Router / React Navigation / GoRouter / NavigationStack / Navigation Compose]
- **Dependency Injection**: [TO BE CONFIGURED — manual / Hilt / Koin / Resolver / get_it]
- **Networking**: [TO BE CONFIGURED — fetch+TanStack Query / Dio / URLSession+async / Ktor / Retrofit]
- **Persistence**: [TO BE CONFIGURED — MMKV / Hive / Realm / SwiftData / Room]
- **Backend Contract**: [TO BE CONFIGURED — REST + OpenAPI / GraphQL + codegen / tRPC]

## Naming Conventions

| Concept | Convention |
|---|---|
| Files | [TO BE CONFIGURED — kebab-case.ts / PascalCase.swift / snake_case.dart / PascalCase.kt] |
| Components / Views | [TO BE CONFIGURED — PascalCase] |
| Variables | [TO BE CONFIGURED — camelCase] |
| Constants | [TO BE CONFIGURED — SCREAMING_SNAKE_CASE] |
| Analytics events | [TO BE CONFIGURED — snake_case verbs (sign_up_completed)] |
| Test files | [TO BE CONFIGURED — *.test.ts / *Tests.swift / *_test.dart / *Test.kt] |
| Feature modules | [TO BE CONFIGURED — kebab-case folder] |

## Performance Budgets

| Metric | Target | Why |
|---|---|---|
| Cold start (P50) | [TO BE CONFIGURED — e.g., 1500 ms on mid-tier device] | Above 2s users perceive sluggishness |
| Time to interactive | [TO BE CONFIGURED — 2500 ms on first home screen] | First impression budget |
| Frame rate | 60 fps sustained, 120 fps where supported | Smooth scroll and gesture |
| Frame budget | 16.6 ms / frame (8.3 ms on ProMotion) | Hard ceiling for any per-frame work |
| Jank rate | < 1% of frames over 16.6 ms | Measured via JankStats / Hitches |
| App size (download) | [TO BE CONFIGURED — e.g., < 50 MB iOS, < 30 MB Android] | Install conversion |
| App size (installed) | [TO BE CONFIGURED — e.g., < 200 MB] | Users delete bloated apps |
| Memory ceiling | [TO BE CONFIGURED — e.g., 250 MB on iPhone SE] | Foreground OOM risk |
| Network: P95 request | < 800 ms over 4G | Perceived responsiveness |

## Accessibility

- **Standard**: WCAG 2.2 AA + Apple Accessibility + Android Accessibility
- **Required features**: VoiceOver / TalkBack pass on every screen,
  Dynamic Type / Font Scale support, hit targets >= 44x44 (iOS) / 48x48dp
  (Android), reduce-motion respect, sufficient colour contrast (4.5:1 text,
  3:1 large text and UI components), keyboard navigation on iPadOS.

## Security

- **Cert pinning**: [TO BE CONFIGURED — pin per-domain with rotation plan]
- **Secret storage**: Keychain (iOS) / Keystore (Android) / encrypted MMKV; never plain `AsyncStorage`/`SharedPreferences`
- **Jailbreak / Root detection**: [TO BE CONFIGURED — required for finance/health, optional otherwise]
- **OWASP MASVS level**: [TO BE CONFIGURED — L1 minimum, L2 for sensitive data]

## Testing

- **Unit framework**: [TO BE CONFIGURED — Jest / XCTest / JUnit 5 + MockK / flutter_test]
- **UI/Widget tests**: [TO BE CONFIGURED — RNTL / SwiftUI ViewInspector / Compose UI / flutter_test]
- **End-to-end**: [TO BE CONFIGURED — Detox / Maestro / XCUITest / Espresso]
- **Coverage floor**: 70% for `domain/`, 50% overall (gameplay-style logic — formulas, validators, state machines — must be 90%+)
- **Required suites**: every PRD has at least one Logic test and one Integration test before sign-off

## Forbidden Patterns

- [None configured yet — record forbidden libraries, anti-patterns, and deprecated APIs as ADRs accept them]

## Allowed Libraries / Dependencies

- [None configured yet — log every third-party dependency added with the ADR that approved it]

## Architecture Decisions Log

- [No ADRs yet — use `/architecture-decision` to author one. Each ADR appends an entry to this list with its ID, title, and status.]

## Framework Specialists

- **Primary specialist**: [TO BE CONFIGURED — e.g., react-native-specialist]
- **Language specialist**: [TO BE CONFIGURED — e.g., typescript-specialist]
- **UI specialist**: [TO BE CONFIGURED — e.g., visual-design-director + animation-specialist]
- **Backend pair**: [TO BE CONFIGURED — backend-engineer + api-designer or graphql-specialist]
- **Routing notes**: [TO BE CONFIGURED]

### File Routing Table

| File / surface | Default specialist |
|---|---|
| Cross-platform business logic | [TO BE CONFIGURED — primary specialist] |
| iOS-only views or platform code | `ios-specialist` (+ `swiftui-specialist` for SwiftUI files) |
| Android-only views or platform code | `android-specialist` (+ `jetpack-compose-specialist` for Compose) |
| Animations, transitions, motion | `animation-specialist` paired with `motion-designer` |
| API client and contracts | `api-designer` for shape, `backend-engineer` for impl |
| Push notification handlers | `push-notification-specialist` |
| Offline cache + sync | `offline-sync-specialist` |
| Analytics instrumentation | `analytics-engineer` |
| Payments / IAP / subscriptions | `payment-integration-specialist` + `monetization-designer` |
| Localization strings | `localization-lead` |
| Accessibility audit | `accessibility-specialist` |
| Release pipeline / store metadata | `release-manager` + `mobile-devops` |
| General architecture review | `mobile-architect` |
