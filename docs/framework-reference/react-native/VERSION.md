# React Native — Version Reference

| Field | Value |
|---|---|
| **Framework Version** | React Native 0.76 |
| **Toolchain** | Expo SDK 52 (Hermes default, New Architecture default) |
| **TypeScript** | 5.6 |
| **Release Date** | November 2025 (RN 0.76); November 2025 (Expo SDK 52) |
| **Project Pinned** | [TO BE FILLED — set by /setup-framework] |
| **Last Docs Verified** | [TO BE FILLED — ISO date] |
| **LLM Knowledge Cutoff** | January 2026 |

## Quick Facts

- **New Architecture**: Default in 0.76. Bridge is no longer the default
  path. Native modules using `NativeModules` (legacy) still work but
  should be migrated to TurboModules / Fabric.
- **Hermes**: Default JS engine on both iOS and Android. JSC fallback is
  removed for new projects.
- **Bridgeless mode**: Default. `NativeEventEmitter` patterns require
  TurboModule shapes.
- **Expo Router 4**: File-based routing on top of React Navigation 7.
- **Reanimated 3.16+**: Worklets API stabilised; `useAnimatedStyle` is
  the canonical hook. Reanimated 4 (Skia-based renderer for layout
  animations) is in preview.
- **FlashList 1.7**: Default recommendation over `FlatList` for large
  virtualised lists.
- **iOS**: Targets iOS 15.1+ (RN 0.76 minimum). Xcode 16+ required.
- **Android**: Targets minSdk 24, compileSdk 35. AGP 8.7+. JDK 17.

## Knowledge Gap Warning

The LLM's training data covers React Native up to roughly 0.74. Versions
0.75 and 0.76 introduced the New Architecture as default and removed
several legacy paths. Things to verify against this directory before
suggesting:

- TurboModule registration syntax and codegen invocation.
- Fabric component authoring patterns.
- New Architecture interop with legacy native modules.
- Bridgeless event emission.
- Expo SDK 52 API renames and removals.

## Post-Cutoff Topic Risk

| Topic | Risk | Notes |
|---|---|---|
| New Architecture default | HIGH | Most online examples still assume the bridge. |
| TurboModules codegen | HIGH | Codegen schema changed in 0.74-0.76. |
| Fabric components | HIGH | Authoring patterns evolved with each release. |
| Reanimated 3 worklets | MEDIUM | API stabilised but Reanimated 4 preview is in flight. |
| Expo Router 4 | MEDIUM | File-based conventions tightened. |
| OTA updates (EAS Update) | MEDIUM | Channels and runtime versions tightened. |
| Hermes-only JIT | LOW | Stable. |

## Verified Sources

- React Native docs: <https://reactnative.dev/docs/getting-started>
- React Native 0.76 release: <https://reactnative.dev/blog/2024/10/23/release-0.76-new-architecture>
- Expo SDK 52 release: <https://expo.dev/changelog/sdk-52>
- Expo Router 4: <https://docs.expo.dev/router/introduction>
- Reanimated 3: <https://docs.swmansion.com/react-native-reanimated/>
- TanStack Query: <https://tanstack.com/query/v5>

## Update Protocol

1. Run `/setup-framework upgrade` to bump the pin.
2. The skill produces a migration ADR listing breaking changes between
   the old pin and the new.
3. `mobile-architect` runs gate `MA-FRAMEWORK-RISK` against any
   features touching API surfaces that changed.
4. `tests/` are run on the new version before merging the bump.
