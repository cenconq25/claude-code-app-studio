---
name: perf-profile
description: "Structured performance profiling: cold/warm start, frame time, memory, network, app size, battery. Identifies bottlenecks against budgets, recommends optimizations with priority. Use during Polish or before a release."
argument-hint: "[--target=cold-start|frame|memory|network|battery|size|all]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---

# Perf Profile

A repeatable mobile-performance pass. Each metric has a target tool, a
budget, a measurement protocol, and a severity rule. The output is a
prioritized backlog of optimizations.

---

## Phase 1: Read Budgets

Read `.claude/docs/technical-preferences.md` for performance budgets.
Defaults if unset:

- Cold start (clean install, no caches): under 2.0s on Tier A iPhone,
  under 2.5s on Tier A Android, under 3.5s on a low-end device.
- Warm start: under 1.0s.
- Frame budget: 16.6 ms at 60fps, 8.3 ms at 120fps. Dropped frames
  budget: < 0.5% of total frames in a session.
- Memory after reaching home: under 200 MB on iOS, under 250 MB on
  Android.
- App size on disk: under 100 MB iOS, under 150 MB Android (including
  AAB expansion).
- Network: first-meaningful-content under 1.5s on 3G; offline path
  must render in under 500 ms.
- Battery: idle drain under 5%/hour foreground, under 1%/hour
  background.

Confirm budgets with the user. Capture the build under test.

---

## Phase 2: Pick Target Metrics

Parse `--target`. If `all`, run every metric in order. Otherwise run
the requested one(s).

For each metric, the rest of the skill follows the same shape: tool,
protocol, capture, compare, recommendation.

---

## Phase 3: Cold Start

**Tools:**

- iOS: Instruments -> App Launch template; or `xcrun xctrace`.
- Android: `adb shell am start -W com.app/.MainActivity`; Macrobenchmark
  StartupBenchmark.
- React Native: TTI (time-to-interactive) marker via `Performance.now()`
  on the home screen mount.
- Flutter: `flutter run --profile --trace-startup`.

**Protocol:**

1. Force-stop the app.
2. Reboot the device (or at minimum, kill all background apps).
3. Wait 30 seconds for OS to settle.
4. Launch with the chosen tool.
5. Repeat 5 times; take the median.

**Capture:** total cold-start time, time-to-first-frame, time-to-interactive.

**Common bottlenecks to surface:**

- Synchronous work in the app entry point.
- Eager initialization of analytics SDKs, RUM, ads SDKs.
- Hermes / V8 startup overhead — bundle size > 5 MB is suspicious.
- Auto-loaded modules in `MainApplication` / `AppDelegate`.
- Heavy fonts loaded synchronously.

**Recommendation rules:**

- Over budget by >50% -> P0.
- Over budget 10-50% -> P1.
- Within 10% over budget -> P2 (track over time).

---

## Phase 4: Frame Time

**Tools:**

- iOS: Instruments -> Time Profiler + Hangs; SwiftUI Inspector.
- Android: Macrobenchmark FrameTimingMetric; Perfetto;
  GPUInspector / `dumpsys gfxinfo`.
- React Native: Flipper Performance plugin; `useDevSettings` for
  perf overlay.
- Flutter: DevTools Performance tab; `--profile` mode.

**Protocol:**

1. Run a representative scripted scroll over the heaviest list.
2. Run a representative animation (e.g., the main screen transition).
3. Run a heavy-load scenario (1000 list items, complex chart).
4. Capture per-frame timings for each.

**Capture:** mean frame time, p95 frame time, count of frames > budget,
count of UI thread blocks > 16ms.

**Common bottlenecks:**

- Unmemoized list cells re-rendering.
- Image decoding on the main thread.
- Reflow on every scroll due to layout thrash.
- Overdraw (multiple translucent layers).
- JS bridge chatter (RN) or Platform Channel chatter (Flutter).

---

## Phase 5: Memory

**Tools:**

- iOS: Instruments Allocations + Leaks; Memory Graph Debugger.
- Android: Android Profiler -> Memory; LeakCanary.
- React Native: Hermes memory snapshots; Flipper Memory plugin.
- Flutter: DevTools Memory.

**Protocol:**

1. Cold start, navigate to home, capture baseline.
2. Drive the core loop for 10 cycles, capture snapshot.
3. Drive the heaviest screen 20 times, capture snapshot.
4. Background the app, foreground, capture again.

**Capture:** peak resident memory, post-loop memory, leak suspects from
LeakCanary / Memory Graph.

**Common bottlenecks:**

- Unreleased image bitmaps.
- Closures capturing strong `self` (iOS).
- Subscriptions not cancelled (RxSwift, Combine, RxJava, RN listeners).
- Caches without bounds.

---

## Phase 6: Network

**Tools:**

- Charles Proxy / Proxyman / mitmproxy.
- iOS Instruments Network template.
- Android Profiler Network tab.
- Sentry / Datadog network panels in production builds.

**Protocol:**

1. Cold start under simulated 3G (`Network Link Conditioner` on iOS,
   `adb shell tc qdisc` or emulator network profile on Android).
2. Capture every request from launch to home.
3. Drive the core loop on 3G.
4. Toggle to airplane mode and confirm offline path renders.

**Capture:** request count, total bytes, p95 request time, redundant
requests, requests blocking main thread.

**Common bottlenecks:**

- N+1 requests at home (analytics, config, feature flags fetched
  serially).
- Missing HTTP caching.
- No request deduplication.
- Image fetches without progressive loading.

---

## Phase 7: App Size

**Tools:**

- iOS: Xcode -> Window -> Organizer -> App Size Report; `xcrun
  altool --output-format`.
- Android: Android Studio APK Analyzer; `bundletool build-apks`.
- React Native: Metro bundle size with `--analyze` or `react-native-bundle-visualizer`.
- Flutter: `flutter build appbundle --analyze-size`.

**Protocol:**

1. Build a release artifact.
2. Inspect breakdown by category (executable, assets, frameworks,
   localizations).
3. Identify the top 10 largest files.

**Capture:** total install size, top-10 contributors, total localized
asset overhead.

**Common bottlenecks:**

- Multiple image versions for unused densities.
- Bundled fonts the app does not use.
- Native libraries not stripped of unused architectures.
- Vector assets duplicated as PNGs.

---

## Phase 8: Battery

**Tools:**

- iOS: Settings -> Battery; Energy Log via Console.app.
- Android: `adb shell dumpsys batterystats`; Battery Historian.
- Cross-platform: scheduled telemetry via Sentry / Firebase.

**Protocol:**

1. Charge to 100%, disconnect.
2. Run idle scenario for 1 hour foreground.
3. Run core loop for 1 hour.
4. Background for 4 hours with push storms enabled.
5. Capture battery percentage and breakdown per phase.

**Common bottlenecks:**

- High-frequency location updates.
- Always-on BLE scanning.
- Unbounded background work.
- Loops that wake the CPU on every frame even when off-screen.

---

## Phase 9: Compose the Report

```markdown
# Performance Profile — [build] — [date]

## Targets and Results
| Metric | Budget | Measured | Status |
|--------|--------|----------|--------|
| Cold start | 2.0s iOS / 2.5s Android | [N]s / [N]s | PASS / OVER |

## Bottleneck Backlog
| Priority | Metric | Issue | Recommended Fix | Owner |
|----------|--------|-------|------------------|-------|
| P0 | Cold start | Eager Sentry init | Defer to post-home | mobile |
| P1 | Frame | Unmemoized cell render | useMemo / Equatable | rn |

## Wins Since Last Profile
[improvements vs prior run]

## Verdict: HEALTHY / NEEDS WORK / BLOCKING
```

Ask before writing to `production/perf/perf-profile-[date].md`.

---

## Phase 10: Update State

Append to `production/session-state/active.md`:

```
## Perf Profile — [date]
- Build: [version]
- Worst breach: [metric] — [delta]
- P0 items: [count]
- Report: [path]
- Next: open stories for P0/P1 via /create-stories
```

---

## Quality Gates / PASS-FAIL

- HEALTHY — every measured metric within budget; only nice-to-have wins
  on the backlog.
- NEEDS WORK — at least one P1 over budget; ship-blocking only if a
  release is imminent.
- BLOCKING — at least one P0 over budget by >50%, OR battery drain
  outside budget on idle, OR cold start >50% over budget.

---

## Examples

**Example 1 — pre-release on RN app:**
Cold start 1.7s (PASS), p95 frame 22ms on home list (FAIL — list cell
re-renders), memory 185 MB (PASS), app size 88 MB (PASS), battery idle
4.2%/h (PASS). One P1 backlog item; verdict NEEDS WORK.

**Example 2 — `--target=memory` on Flutter app:**
Drives core loop 10x, memory grows 14 MB/loop. LeakCanary points at an
uncancelled stream subscription in cart provider. P0 fix.

---

## Next Steps

- Convert each P0/P1 entry into a story via `/create-stories`.
- Re-run `/perf-profile` after fixes to verify regression-free.
- Pair with `/soak-test` for issues that only show under load.
