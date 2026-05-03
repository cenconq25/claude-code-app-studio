# Agent Roster

54 specialist agents are available. Each has a definition file in
`.claude/agents/`. Pick the agent best matched to the task; when work
spans multiple domains, the relevant department lead or the `producer`
delegates to the correct specialists.

> **Opus tier (top-level directors)**: `product-director`,
> `mobile-architect`. All other agents run at Sonnet by default.

## Leadership

| Agent | Model | Role |
|---|---|---|
| `product-director` | opus | Highest product authority — owns vision, target users, positioning, pillar priority, and arbitrates conflicts between design, engineering, growth, and monetization. |
| `mobile-architect` | opus | Top technical authority — owns framework selection, architecture patterns, performance and memory strategy, security posture, and cross-platform trade-offs. |
| `producer` | sonnet | Primary coordination agent — owns sprint planning, milestone tracking, risk management, capacity, and cross-department orchestration. |
| `lead-designer` | sonnet | Design-system authority and visual quality bar — owns sign-off on UI work, coordinates design specialists, and enforces system uniformly. |
| `lead-developer` | sonnet | Owns code-level architecture, coding standards, code-review delegation, and day-to-day technical health of the codebase. |

## Product & Design

| Agent | Model | Role |
|---|---|---|
| `product-designer` | sonnet | Authors PRDs for individual features — rules, flows, requirements, acceptance criteria, and behavioural hooks. |
| `ux-designer` | sonnet | Owns interaction design, information architecture integration, accessibility integration, onboarding flows, and navigation patterns. |
| `visual-design-director` | sonnet | Owns visual identity — design tokens (color, type, spacing, elevation, radius, motion), component spec library, and the visual quality bar. |
| `interaction-designer` | sonnet | Owns gesture design, micro-interactions, state transitions, and haptic feedback. |
| `motion-designer` | sonnet | Owns the motion language — screen transitions, in-component animation, hero moments, Lottie/Rive specs. |
| `info-architect` | sonnet | Owns information architecture — taxonomy, top-level navigation model, hierarchy, search, and filter patterns. |
| `content-strategist` | sonnet | Owns voice and tone, content lifecycle, in-app messaging strategy, and the error-message system. |
| `content-designer` | sonnet | Writes UX copy — buttons, headers, microcopy, empty states, errors, push strings, within content-strategist guidelines. |
| `brand-director` | sonnet | Owns brand expression in-app and at store touchpoints — app icon, splash, store listing visuals, and screenshot composition. |
| `prototyper` | sonnet | Builds rapid throwaway prototypes — Figma click-throughs, code spikes, hybrid — to validate concepts before production. |
| `user-researcher` | sonnet | Plans and runs user research — interviews, usability tests, diary studies, surveys, beta-program analysis; maintains personas and JTBDs. |
| `ai-product-designer` | sonnet | Designs LLM-, agent-, and ML-powered features — prompt UX, guardrails, latency UX, error recovery, and evaluation framing. |

## Engineering — Cross-Platform

| Agent | Model | Role |
|---|---|---|
| `react-native-specialist` | sonnet | Authority on RN architecture — New Architecture (Fabric, TurboModules, JSI), Metro, Hermes, navigation, EAS workflows. |
| `typescript-specialist` | sonnet | Owns the TS type system, strict-mode configuration, schema-driven validation (zod, valibot), and shared types in monorepos. |
| `flutter-specialist` | sonnet | Authority on Flutter architecture, widget/element/render tree, slivers, custom painters, platform channels, isolates, build-mode tuning. |
| `dart-specialist` | sonnet | Owns Dart language usage — null safety, records, patterns, sealed classes, async/Stream/Isolate semantics, dart:ffi, analyzer rules. |
| `state-management-specialist` | sonnet | Owns choice and integration of state-management libraries across all four stacks; decides server/client state boundary. |
| `animation-specialist` | sonnet | Owns motion across frameworks — Reanimated, Skia, Flutter animations, SwiftUI/Core Animation, Compose animations, Lottie, Rive. |

## Engineering — iOS

| Agent | Model | Role |
|---|---|---|
| `ios-specialist` | sonnet | Top-level iOS authority — app architecture, framework selection, build settings, entitlements, App Store Review, ATT, App Clips, widgets, StoreKit. |
| `swift-specialist` | sonnet | Owns the Swift language — Swift 6 strict concurrency, actors, async/await, Sendable, generics, macros, result builders, Swift Testing. |
| `swiftui-specialist` | sonnet | Owns the SwiftUI view layer — declarative views, modifiers, NavigationStack, Observation, accessibility traits, UIKit bridge. |

## Engineering — Android

| Agent | Model | Role |
|---|---|---|
| `android-specialist` | sonnet | Top-level Android authority — app architecture, scoped storage, foreground services, Doze/App Standby, background limits, Play policy. |
| `kotlin-specialist` | sonnet | Owns Kotlin language — Kotlin 2.1, K2 compiler, coroutines, Flow, sealed interfaces, value classes, context receivers, KMP considerations. |
| `jetpack-compose-specialist` | sonnet | Owns Jetpack Compose — recomposition rules, state hoisting, side-effect APIs, modifier order, Compose Navigation, Material 3, baseline profiles. |

## Engineering — Backend & Data

| Agent | Model | Role |
|---|---|---|
| `backend-engineer` | sonnet | Owns the server side of mobile features — auth, sessions, rate limiting, mobile-friendly endpoints, payload size, retry, idempotency. |
| `api-designer` | sonnet | Designs the contract between mobile clients and servers — REST/GraphQL/gRPC, versioning, error envelopes, idempotency, pagination. |
| `database-specialist` | sonnet | Owns data storage on client and server — picks the right tool, designs schemas, plans migrations, tunes indexes. |
| `graphql-specialist` | sonnet | Owns GraphQL specifics — schema design, persisted queries, federation, Apollo/Relay/urql cache strategies, optimistic updates, offline mutations. |
| `firebase-specialist` | sonnet | Owns Firebase/Google Cloud usage — Auth, Firestore, FCM, Remote Config, App Check, Crashlytics, Analytics, Cloud Functions. |
| `cloudflare-specialist` | sonnet | Owns Cloudflare platform usage end to end — Workers, Durable Objects, D1, R2, KV, Queues, Workflows, Vectorize, Hyperdrive, Workers AI, Agents SDK, Pages, Tunnel, DNS, WAF, and Wrangler. |
| `offline-sync-specialist` | sonnet | Owns offline-first patterns — local write queues, background sync, conflict resolution (LWW, CRDT), idempotent mutations, network-aware UX. |

## Quality

| Agent | Model | Role |
|---|---|---|
| `qa-lead` | sonnet | Owns the test strategy — test pyramid (unit + integration + E2E), bug triage, beta-test sign-off, and release quality gates. |
| `qa-tester` | sonnet | Writes test cases, executes plans, runs exploratory testing on real devices, files high-quality bug reports. |
| `mobile-test-automation` | sonnet | Owns automated UI testing — XCUITest, Espresso, Detox, Maestro, Patrol, plus device farms (BrowserStack, Sauce Labs, Firebase Test Lab). |

## Security

| Agent | Model | Role |
|---|---|---|
| `security-engineer` | sonnet | Owns mobile security — cert pinning, root/jailbreak detection, secure storage, OWASP MASVS, app shielding, dependency CVE monitoring, API review. |

## Performance

| Agent | Model | Role |
|---|---|---|
| `performance-analyst` | sonnet | Owns mobile performance — cold start, frame time, jank, memory, app size, network, battery, using Instruments / Android Profiler / Hermes. |

## Live-Ops & Growth

| Agent | Model | Role |
|---|---|---|
| `live-ops-designer` | sonnet | Owns feature flags, segmented rollouts, in-app events / campaigns, and retention loops in the deployed app. |
| `growth-engineer` | sonnet | Owns acquisition, activation, retention loops, ASO, referral systems, and attribution (SKAdNetwork, Play Install Referrer, MMPs). |
| `analytics-engineer` | sonnet | Owns event taxonomy, instrumentation, funnel design, A/B framework, and dashboards (Amplitude, Mixpanel, PostHog, Firebase). |
| `monetization-designer` | sonnet | Owns pricing models, paywall design, conversion funnels, and regulation-aware monetization (App Store / Play / EU DMA / regional). |
| `community-manager` | sonnet | Owns App Store / Play Store review responses, social channels, support triage, and the beta community. |

## Tools

| Agent | Model | Role |
|---|---|---|
| `tools-engineer` | sonnet | Owns internal developer tooling — CLI scripts, codegen, Storybook / sandboxes, design-token sync, env management, automation. |
| `mobile-devops` | sonnet | Owns mobile CI/CD — GitHub Actions, Bitrise, Codemagic, EAS, Fastlane; signing, provisioning, certificate rotation, store uploads, build caching. |

## Specialists

Cross-cutting specialists invoked by feature teams as needed.

| Agent | Model | Role |
|---|---|---|
| `accessibility-specialist` | sonnet | Owns accessibility compliance — WCAG 2.2 AA, iOS Accessibility (VoiceOver, Dynamic Type), Android Accessibility (TalkBack, Switch Access). |
| `localization-lead` | sonnet | Owns the i18n architecture — ICU MessageFormat, RTL, translator workflow, locale QA, voiceover/audio localization. |
| `push-notification-specialist` | sonnet | Owns push end-to-end — APNs (HTTP/2 token), FCM, rich notifications, permission UX, silent push, Live Activities, notification channels. |
| `payment-integration-specialist` | sonnet | Owns mobile payments — StoreKit 2, Play Billing 7, RevenueCat, Stripe Mobile, Apple/Google Pay, subscriptions, receipt validation. |
| `ai-engineer` | sonnet | Engineers AI/LLM features — on-device (Core ML, TFLite, MLC), server inference (Anthropic, OpenAI, hosted Llama), prompts, eval harnesses, fallback UX. |
| `release-manager` | sonnet | Owns the release pipeline — App Store Review prep, Play Console staged rollout, version numbering, certification, day-one patch coordination, rollback. |
