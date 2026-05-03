# Native Android — Version Reference

| Field | Value |
|---|---|
| **Platform Target** | Android 15 (API 35) — compile SDK |
| **Minimum SDK** | API 26 (Android 8.0) recommended floor |
| **Kotlin Version** | Kotlin 2.1 |
| **Android Gradle Plugin** | AGP 8.7 |
| **Compose BOM** | 2025.01 (or later) |
| **Compose Compiler** | bundled with Kotlin 2.1 (K2) |
| **Project Pinned** | [TO BE FILLED — set by /setup-framework] |
| **Last Docs Verified** | [TO BE FILLED — ISO date] |
| **LLM Knowledge Cutoff** | January 2026 |

## Quick Facts

- **K2 compiler** (Kotlin 2.0+): default. Compose Compiler is now part
  of the Kotlin distribution rather than a separate plugin.
- **Coroutines + Flow**: standard async primitive across the stack.
- **Jetpack Compose**: the recommended UI toolkit for new apps. View
  XML remains valid but is not the default for greenfield.
- **Navigation Compose**: the canonical navigator. Use type-safe routes
  introduced in Navigation 2.8+.
- **Hilt 2.50+**: the recommended DI library; Koin remains a valid
  alternative for KMP-friendly setups.
- **Predictive back gestures**: opt-in via `android:enableOnBackInvokedCallback`.
- **Foreground Service types**: required (mediaPlayback, location,
  camera, etc.) since Android 14. Granular declarations enforced in 15.
- **Photo Picker / SAF**: prefer the system Photo Picker over runtime
  storage permissions.
- **Edge-to-edge**: default in Android 15; the system applies it
  whether you opt in or not.

## Knowledge Gap Warning

The LLM's training data covers Kotlin 1.9 / Android 14 solidly. Verify
before suggesting:

- K2 compiler diagnostics and Compose Compiler integration.
- Type-safe Navigation Compose routes (annotation + serializer-based).
- Android 15 edge-to-edge defaults and the new
  `WindowInsets.systemBars` behaviour.
- Photo Picker API for newer media types.
- Foreground Service type enforcement specifics for Android 15.
- New Compose performance APIs (`Modifier.composed` deprecation,
  `LookaheadScope` usage, `SubcomposeLayout` evolutions).

## Post-Cutoff Topic Risk

| Topic | Risk | Notes |
|---|---|---|
| K2 compiler | MEDIUM | Migration from KAPT to KSP recommended. |
| Compose Compiler in Kotlin | HIGH | Setup differs from older Compose Compiler plugin. |
| Type-safe Navigation Compose | MEDIUM | Annotation-driven; older string-based routes are deprecated. |
| Edge-to-edge default | HIGH | UI laid out under system bars by default in Android 15. |
| Foreground Service types | HIGH | Build fails without correct declarations on Android 15. |
| Predictive back | MEDIUM | OnBackPressedDispatcher patterns refined. |
| Compose performance modifiers | MEDIUM | Some patterns deprecated. |

## Verified Sources

- Android Developers docs: <https://developer.android.com/>
- Compose docs: <https://developer.android.com/jetpack/compose>
- Navigation Compose: <https://developer.android.com/jetpack/compose/navigation>
- Behavior changes (Android 15): <https://developer.android.com/about/versions/15/behavior-changes-15>
- AGP release notes: <https://developer.android.com/build/releases>
- Kotlin 2.x migration: <https://kotlinlang.org/docs/whatsnew21.html>

## Update Protocol

Bumping `compileSdk`, `minSdk`, AGP, Kotlin, or Compose BOM requires
`/setup-framework upgrade android`. The skill produces a migration ADR
and runs `MA-FRAMEWORK-RISK` against affected code.
