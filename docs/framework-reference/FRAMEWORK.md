# Framework Selection Guide

This file is the entry point for framework decisions on this project.
The currently active framework is recorded in
`.claude/docs/technical-preferences.md`. The corresponding
`docs/framework-reference/[framework]/VERSION.md` is the canonical pin.

## When to Choose Which

| Framework | Choose when... | Avoid when... |
|---|---|---|
| **React Native + TypeScript** | Cross-platform with high code reuse, fast iteration matters more than peak per-platform polish, the team has strong web/JS skills, server-driven UI is on the roadmap, OTA updates are valuable. | The product needs deep platform features that change often (widgets, App Intents, Live Activities), peak performance on low-end Android matters, the team has zero web/JS experience. |
| **Flutter + Dart** | Cross-platform with **identical** look and feel by design, custom motion or graphics are core, the team can invest in Dart, the product roadmap is light on rapidly-evolving platform features. | iOS users expect highly-native feel (haptics, system controls, Live Activities), the team has an existing JS investment, web compatibility matters (Flutter Web is still constrained). |
| **Native iOS (Swift / SwiftUI)** | iOS-first product, premium iOS features (Live Activities, App Intents, Widgets, App Clips), peak performance, team is iOS-heavy. | Cross-platform parity is required at MVP, team has no Swift experience, time-to-Android matters. |
| **Native Android (Kotlin / Compose)** | Android-first product (often emerging markets, OEM partnerships), peak performance on a wide device matrix, team is Android-heavy. | Cross-platform parity is required at MVP, team has no Kotlin experience, time-to-iOS matters. |

A common pattern is **two natives** — separate iOS and Android codebases
with a shared backend. This makes sense for premium consumer apps where
each platform needs to feel native and the team can support both. It is
the most expensive option in headcount but yields the best per-platform
quality.

Another common pattern is **RN with native modules** — RN as the
default, native modules for the small set of features that need
platform depth. This is the dominant pattern for cross-platform consumer
apps in 2026.

## Decision Inputs

`/setup-framework` walks through these inputs:

1. **Platform reach** — iOS only / Android only / both / web too?
2. **Performance ceiling** — does any flow need 120 fps + sub-frame
   touch latency on low-end Android? (Yes → native; No → cross-platform OK)
3. **Platform features** — list the must-have platform features.
   Required Live Activities? Widgets? App Intents? Health integration?
   CarPlay/Auto?
4. **Team skills** — current language proficiency on day 1.
5. **Team size** — solo / 2-3 / 4-10 / >10? (Solo and small teams
   benefit from cross-platform; large teams can afford native pairs.)
6. **Speed-to-market** — first beta in two months? Six? Twelve?
7. **OTA updates** — is shipping JS bundles outside the store cadence
   important? (Yes → RN. Native and Flutter ship via store updates only.)
8. **Backend reuse** — is there an existing API? Is GraphQL on the roadmap?

The skill scores each option and surfaces the recommendation with
reasoning. The user makes the call.

## Pinning the Version

Once a framework is chosen, the corresponding `VERSION.md` records the
exact version pinned for the project, the verified docs date, and the
post-cutoff API risk. The pin is updated only by an explicit
`/setup-framework upgrade` invocation, which produces a migration ADR.

| Framework | Version reference |
|---|---|
| React Native | `docs/framework-reference/react-native/VERSION.md` |
| Flutter | `docs/framework-reference/flutter/VERSION.md` |
| Native iOS | `docs/framework-reference/ios/VERSION.md` |
| Native Android | `docs/framework-reference/android/VERSION.md` |

## Knowledge Cutoff

The LLM driving this template has a knowledge cutoff (see the model
documentation for the exact date). Mobile frameworks ship breaking
changes quickly. Always check the version reference before suggesting
APIs the LLM has memorised — especially for:

- Concurrency primitives (Swift 6, Kotlin coroutines, Dart isolates).
- Platform-specific renderers (Hermes, Skia, JIT toggles, Impeller).
- New OS feature integrations (Live Activities, App Intents, predictive back).
- Build-pipeline changes (AGP 8.x, Xcode 16, Expo SDK majors).

When in doubt, gate the decision behind `MA-FRAMEWORK-RISK` (see
`director-gates.md`).

## Mixing Frameworks

Two valid patterns:

1. **Brownfield** — embed RN or Flutter inside an existing native app.
   ADR required; mixing surface area must be minimised. Treat the
   embedded surface as one big black-box screen.
2. **Greenfield** — pick one framework and stick to it.

Mixing for the sake of "best tool for each screen" inflates build
complexity, fragmenting state and routing. Avoid unless an ADR can
defend the cost.
