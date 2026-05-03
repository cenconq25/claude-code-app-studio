# Flutter — Version Reference

| Field | Value |
|---|---|
| **Framework Version** | Flutter 3.27 |
| **Dart Version** | 3.6 |
| **Renderer** | Impeller (iOS default, Android default) |
| **Release Date** | December 2025 |
| **Project Pinned** | [TO BE FILLED — set by /setup-framework] |
| **Last Docs Verified** | [TO BE FILLED — ISO date] |
| **LLM Knowledge Cutoff** | January 2026 |

## Quick Facts

- **Impeller**: Default on both platforms. Skia is no longer the default;
  it can be re-enabled with `--enable-impeller=false` for legacy support.
- **Material 3**: Default theme. `useMaterial3: true` is implicit.
- **Cupertino**: Updated 2025/2026 to track iOS 18 visual conventions
  (corner radii, sheet presentation, navigation transitions).
- **Wasm support**: Flutter Web supports `--wasm` target with
  significant performance improvement over JS.
- **Sound null safety**: Required everywhere; legacy nullable types are
  removed in 3.27.
- **Records and patterns**: Stable since Dart 3; widely used for
  destructuring API responses.
- **Sealed classes**: Stable; preferred over enums for discriminated
  unions.
- **iOS**: Targets iOS 12+. Xcode 16+ required.
- **Android**: Targets minSdk 23, compileSdk 35. AGP 8.7+. JDK 17.

## Knowledge Gap Warning

The LLM's training data covers Flutter up to roughly 3.22 / Dart 3.4.
Versions 3.23 through 3.27 introduced Impeller as default on both
platforms, Material 3 default, and several Cupertino redesigns. Things
to verify before suggesting:

- Impeller-specific shader and platform view caveats (texture sampling,
  hybrid composition fallback).
- Material 3 component renames (`OutlinedButton`, `FilledButton`,
  segmented buttons).
- New Cupertino widgets that match iOS 18 behaviours.
- `package:web` (the WASM-friendly replacement for `dart:html`).
- Threaded image decoding APIs.

## Post-Cutoff Topic Risk

| Topic | Risk | Notes |
|---|---|---|
| Impeller default | HIGH | Some platform views and shaders need adjustment. |
| Material 3 default | MEDIUM | Component naming and elevation rules differ. |
| Cupertino refresh (iOS 18) | MEDIUM | Several existing examples are stale. |
| Wasm web target | MEDIUM | Build pipeline differs from JS target. |
| AGP 8.x configuration | MEDIUM | Gradle scripts changed structurally. |
| Riverpod 2 / hooks_riverpod | LOW | Stable; broad community usage. |

## Verified Sources

- Flutter docs: <https://docs.flutter.dev>
- 3.27 release notes: <https://docs.flutter.dev/release/release-notes>
- Material 3 components: <https://docs.flutter.dev/ui/widgets/material>
- Cupertino: <https://docs.flutter.dev/ui/widgets/cupertino>
- Riverpod: <https://riverpod.dev>
- Bloc: <https://bloclibrary.dev>

## Update Protocol

Same as React Native: `/setup-framework upgrade` produces a migration
ADR; `MA-FRAMEWORK-RISK` runs against affected features; tests pass on
the new version before the pin moves.
