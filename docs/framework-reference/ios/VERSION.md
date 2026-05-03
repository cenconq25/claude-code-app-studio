# Native iOS — Version Reference

| Field | Value |
|---|---|
| **Platform Target** | iOS 18 (deployment target — set per project) |
| **Swift Version** | Swift 6 (strict concurrency available) |
| **Xcode Version** | Xcode 16+ |
| **SwiftUI** | 6.x (matches iOS 18) |
| **Project Pinned** | [TO BE FILLED — set by /setup-framework] |
| **Last Docs Verified** | [TO BE FILLED — ISO date] |
| **LLM Knowledge Cutoff** | January 2026 |

## Quick Facts

- **Swift 6 strict concurrency**: opt-in but recommended for new
  projects. Requires `Sendable` conformance for types crossing actor
  boundaries; `@MainActor` for UI-touching types.
- **Typed throws** (`throws(MyError)`): stable in Swift 6.
- **`@Observable` macro**: replaces `ObservableObject` for new code.
  `@StateObject`/`@ObservedObject` remain valid for legacy.
- **SwiftUI Lists** got performance improvements in iOS 17/18 — large
  lists no longer require manual virtualisation in most cases, but
  `LazyVStack`/`LazyHStack` remain for explicit lazy loading.
- **NavigationStack** (iOS 16+): the canonical navigation primitive.
  `NavigationView` is deprecated.
- **App Intents**: required for Siri, Shortcuts, Action Button on iPhone
  15 Pro+, and Apple Watch interactions. Authoring uses the
  `@AssistantIntent` family in iOS 18.
- **Live Activities** (`ActivityKit`): mature; iOS 18 adds dynamic
  content controls for Dynamic Island.
- **Widgets**: WidgetKit; iOS 17 introduced interactive widgets via
  `Button`/`Toggle` with App Intents.
- **SwiftData**: preferred for local persistence in new apps. Core Data
  remains for migrations from legacy apps.

## Knowledge Gap Warning

The LLM's training data covers iOS 17 / Swift 5.9-ish solidly and iOS 18
/ Swift 6 partially. Verify before suggesting:

- Swift 6 strict-concurrency diagnostics and how to satisfy them.
- New `@Observable` patterns (no more `@Published`; observation tracks
  property reads).
- iOS 18 SwiftUI APIs (e.g., `mesh gradients`, `floating tab bar`,
  `controlSize`, `containerRelativeFrame` updates).
- App Intents Assistant Schema (iOS 18.1+).
- ActivityKit Dynamic Island region updates.

## Post-Cutoff Topic Risk

| Topic | Risk | Notes |
|---|---|---|
| Swift 6 strict concurrency | HIGH | Many older examples won't compile. |
| `@Observable` macro | MEDIUM | Replaces a lot of `ObservableObject` boilerplate. |
| iOS 18 SwiftUI primitives | MEDIUM | New APIs added in 17/18 not in older training. |
| App Intents Assistant Schema | HIGH | iOS 18.1 only; many examples stale. |
| ActivityKit | MEDIUM | API surface evolved. |
| SwiftData migrations | MEDIUM | Versioning model differs from Core Data. |
| Visual tools (Reality Composer Pro) | LOW | Specialised. |

## Verified Sources

- Apple Developer docs: <https://developer.apple.com/documentation/>
- Swift 6 migration: <https://www.swift.org/migration/documentation/migrationguide/>
- WWDC 2025 session videos.
- SwiftUI tutorials: <https://developer.apple.com/tutorials/swiftui>
- Human Interface Guidelines: <https://developer.apple.com/design/human-interface-guidelines/>

## Update Protocol

Bumping iOS deployment target or Swift version requires
`/setup-framework upgrade ios`. The skill produces a migration ADR
listing changes between the old pin and the new. Run
`MA-FRAMEWORK-RISK` against any code using post-cutoff APIs.
