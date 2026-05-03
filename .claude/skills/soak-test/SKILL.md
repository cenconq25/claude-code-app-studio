---
name: soak-test
description: "Generate a soak-test protocol for extended app sessions. Defines what to observe and log during long sessions to surface memory leaks, battery drain, background-foreground crashes, and network flapping. Used in Polish and Release phases."
argument-hint: "[--duration=Nh | --scenario=<name>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
model: sonnet
---

# Soak Test

Most mobile bugs are not visible in a 5-minute test. This skill produces
a written protocol that a human runs over hours (or overnight) to surface
slow-burn issues: leaks, watchdog kills, queue overflow, network
recovery, push-during-background, and battery cost.

This skill writes a protocol document. It does not execute the soak.

---

## Phase 1: Inputs

Parse arguments:

- `--duration=Nh` — total session length. Default 4 hours; release-gate
  recommends 8 hours overnight on a charger.
- `--scenario=<name>` — pick from a known list: `idle`, `core-loop`,
  `background-mix`, `network-flap`, `push-storm`, `low-memory-device`.
  Default: a balanced mix.

If no scenario is provided, propose options via AskUserQuestion.

Read the current milestone and recent bug history to choose the device
matrix:

- `production/milestones/` — current target platforms.
- `production/qa/bugs/` — recent S1/S2 bugs grouped by symptom (crashes,
  ANRs, freezes, memory).

---

## Phase 2: Pick the Devices

Read `.claude/docs/technical-preferences.md` for Target Platforms. Propose
a soak device set:

- 1 Tier A device per platform (representative high-end).
- 1 Tier C device per platform (representative low-end / low-RAM).
- 1 device known to have reproduced a recent S1/S2.

A single soak run should cover at least one iPhone, one Android, and one
constrained device. Confirm with the user.

---

## Phase 3: Choose Observability Tools

The protocol references these tools by platform:

- iOS: Instruments (Allocations, Leaks, Time Profiler), Console.app for
  logs, MetricKit reports, Xcode Memory Graph.
- Android: Android Profiler (Memory, CPU, Network, Energy), Logcat,
  StrictMode, ANR traces under `/data/anr/`, perfetto.
- Cross-platform telemetry: Sentry, Firebase Crashlytics, Datadog RUM,
  custom analytics.
- Battery: iOS Settings -> Battery; Android adb `dumpsys batterystats`.

Ask which tools are wired into the build. A soak with no telemetry is a
blind soak — propose adding telemetry first.

---

## Phase 4: Build the Scenario Script

For the chosen scenario(s), produce a minute-by-minute script. Patterns:

### Idle soak (memory leak target)
- Minute 0-5: cold start, sign in, navigate to home.
- Minute 5-N: leave the app foregrounded on home, screen-on.
- Every 30 minutes: capture memory snapshot.
- Every hour: capture full Allocations / Memory Profiler trace.
- Pass criterion: memory growth < N MB/hour after the first hour.

### Core-loop soak
- Cycle through the app's primary user flow (browse -> view detail ->
  add to cart -> checkout test card -> back to home) on a 90-second
  loop.
- Capture metrics every 10 cycles.
- Pass criterion: no crash, no ANR, no UI freeze > 500 ms over the run.

### Background-mix soak
- Background the app every 3 minutes for 30 seconds; foreground; repeat.
- Mix in: lock screen (1 min), receive push (every 15 min), incoming
  call simulation (every 30 min).
- Pass criterion: state restored each foreground; no background watchdog
  kill; pushes deliver and do not crash on tap.

### Network-flap soak
- Toggle network between Wi-Fi, cellular, and airplane on a randomized
  schedule (every 2-7 minutes).
- Drive the core loop concurrently.
- Pass criterion: offline queue drains correctly on reconnect; no
  duplicate writes; no infinite spinner.

### Push-storm soak
- Send 200 silent + 50 visible pushes over the run.
- Pass criterion: no crash, no notification stack overflow, no analytics
  duplication; battery cost stays in budget.

### Low-memory soak
- Run on a device near its memory limit. Trigger memory pressure (open
  10 chrome tabs, etc.) every 20 minutes.
- Pass criterion: app survives at least one OS warning; reopens to last
  state; no data loss.

---

## Phase 5: Define the Pass/Fail Bar

Per scenario, write explicit thresholds. Default budgets (override per
project):

- Memory growth in idle: < 5 MB/hour after warm-up.
- Crash count over the run: 0.
- ANR count over the run: 0.
- Battery drain on idle, screen-on: < 5%/hour.
- Frame drops during loops: < 1% of frames over 16ms (60fps target) or
  8ms (120fps target).
- Network reconnect: queued mutations drain in < 30s.

---

## Phase 6: Logging and Evidence Plan

The tester must capture:

- Pre-soak: build version, device, OS, battery %, available storage,
  thermal state.
- Hourly: memory snapshot, battery %, foreground time, crash count.
- Per-incident: a written note with timestamp, what they observed,
  what was happening on screen, attached log/screenshot.
- Post-soak: full Instruments / Profiler trace exported, written summary.

Evidence lands in `production/qa/soak/[date]-[scenario]-[device]/`.

---

## Phase 7: Compose the Protocol Document

```markdown
# Soak Test Protocol — [scenario] — [date]

Build: [version + commit]
Duration: [Nh]
Devices: [list]
Scenarios: [list]

## Setup
1. Charge each device to 100%.
2. Enable telemetry in build settings.
3. Disable Do Not Disturb / Focus on test devices.
4. Connect each device to its profiling tool.

## Schedule (per device)
| Time | Action | Capture |

## Pass/Fail Bar
[explicit thresholds]

## Incident Log (blank — fill during run)
| Time | Device | Observation | Severity | Attached |

## Post-Run Checklist
- [ ] Export Instruments trace
- [ ] Export Android Profiler session
- [ ] Save Logcat / Console logs
- [ ] Battery report screenshot
- [ ] Crashlytics / Sentry deltas
- [ ] Write summary in `production/qa/soak/[date]/summary.md`

## Sign-Off
- QA tester: [name]
- QA Lead approval: [pending]
- Verdict: [pending — PASS / PASS WITH NOTES / FAIL]
```

Ask before writing to `production/qa/soak/[date]-[scenario]-protocol.md`.

---

## Phase 8: Update Session State

Append to `production/session-state/active.md`:

```
## Soak Protocol Generated — [date]
- Path: [protocol path]
- Scenario(s): [list]
- Duration: [Nh]
- Devices: [list]
- Next: human runs the soak; on completion, file PASS/FAIL in summary.md
```

---

## Quality Gates / PASS-FAIL

The protocol itself passes if:

- Every scenario has a script, a thresholds block, and an evidence path.
- The device list covers at least one constrained device.
- Telemetry tools are confirmed present in the build (or flagged).

The soak run's PASS/FAIL is determined post-run via the summary doc, not
this skill.

---

## Examples

**Example 1 — Pre-release 8-hour soak:**
Generates a balanced mix: 4h idle, 2h core-loop, 1h background-mix, 1h
network-flap. Devices: iPhone 14 Pro, iPhone SE (3rd gen), Pixel 7,
Pixel 4a (low-RAM). Protocol written to
`production/qa/soak/2026-05-03-pre-release-protocol.md`.

**Example 2 — Targeted leak hunt:**
`--scenario=idle --duration=12h`. Single iPhone target. Captures hourly
Allocations snapshots. Threshold: < 3 MB/hour growth.

---

## Next Steps

- After the soak runs, the tester writes `summary.md`. If FAIL, file
  bugs via `/bug-report` and re-run after fixes.
- Schedule a soak before every release as part of `/launch-checklist`.
