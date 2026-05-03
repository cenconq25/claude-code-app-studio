---
name: tech-debt
description: "Track, categorize, and prioritize technical debt across the codebase. Scans for debt indicators (TODO, FIXME, deprecated APIs, version-skew, dead flags, stale dependencies), maintains a debt register, and recommends repayment scheduling."
argument-hint: "[--scan | --register | --plan | --pay-down=<id>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---

# Tech Debt

A debt register that lives in `docs/tech-debt.md`. This skill keeps the
register current, scores entries on impact and effort, and recommends
which entries to repay each sprint based on capacity.

---

## Phase 1: Mode

Parse the argument:

- `--scan` (default) — search for new debt indicators and update the
  register.
- `--register` — render the current register without scanning.
- `--plan` — propose which entries to repay in the next sprint.
- `--pay-down=<id>` — close out a register entry once the work shipped.

---

## Phase 2: Scan for Indicators

Grep across `src/` and tests:

- `TODO`, `FIXME`, `HACK`, `XXX`, `KLUDGE` comments. Capture file,
  line, comment text, author (via `git blame` if quick), date added.
- `// @deprecated` / `@Deprecated` / `[Obsolete]` annotations on
  public APIs.
- Imports of known deprecated framework APIs:
  - RN: `AsyncStorage` from `react-native` (now community), legacy
    Navigation v4, `WebView` from `react-native`.
  - iOS: pre-iOS-13 lifecycle methods, UIKit code that should be
    SwiftUI per the project ADR, deprecated APIs flagged by the
    framework reference.
  - Android: deprecated AsyncTask, old support libs (`android.support.*`),
    pre-Compose Views in Compose-target areas.
  - Flutter: pre-3.0 widget APIs, `RaisedButton`, etc.
- Dependency files: parse manifests for outdated versions.
  - `npm outdated --json`
  - `flutter pub outdated --machine`
  - `bundle outdated`
  - `./gradlew dependencyUpdates`
- Stale feature flags (cross-reference `/balance-check` output if
  available).
- Code with `git blame` age > 18 months that has been touched recently
  with non-trivial regression risk — surface for review.

For each, capture: id, type, location, age, last-touched date.

---

## Phase 3: Score Each Entry

Per entry, derive:

- **Impact** (0-3) — how much harm if left?
  - 0: cosmetic
  - 1: minor maintainability cost
  - 2: blocks a known upcoming feature, performance, or security issue
  - 3: production risk (deprecated API will break in next OS / store
    deadline, security CVE, looming framework removal)
- **Effort** (0-3) — to pay down:
  - 0: < 1 hour
  - 1: 1-4 hours
  - 2: half-day to two days
  - 3: > 2 days
- **Priority** = Impact - (0.5 * Effort), high to low.

Surface high-impact-low-effort entries first — those are free wins.

---

## Phase 4: Categorize

Group entries:

- **Code smells** (TODO/FIXME/HACK).
- **Deprecated APIs**.
- **Outdated dependencies**.
- **Version skew** (multiple versions of the same lib transitively).
- **Dead code / dead flags / orphaned assets**.
- **Architecture violations** (cross-cutting; usually surfaced via
  `/code-review` over time).
- **Test debt** (skipped tests, stale fixtures, missing regression
  coverage).

Each category gets its own table in the register.

---

## Phase 5: Maintain `docs/tech-debt.md`

Render or update:

```markdown
# Tech Debt Register

Last reviewed: [date]
Total open: [N] | High priority: [N] | Closed this quarter: [N]

## Code Smells
| ID | Location | Type | Note | Impact | Effort | Priority | Owner | Added |

## Deprecated APIs
| ID | Location | API | Removal target | Impact | Effort | Priority | Owner |

## Outdated Dependencies
| Package | Current | Latest | Risk | Impact | Effort | Priority | Owner |

## Version Skew
| Lib | Versions present | Caused by | Impact |

## Dead Code / Flags / Assets
| Path | Type | Last touched | Owner |

## Test Debt
| Test path | Issue | Owner |

## Closed (rolling 6 months)
| ID | Summary | Closed in | Date |

## How to use
- New TODOs/FIXMEs should be filed with: `// TODO(handle): brief — see DEBT-NN`.
- Pay down in scheduled sprints via `/tech-debt --plan`.
- Mark closed via `/tech-debt --pay-down=DEBT-NN`.
```

ID format: `DEBT-NNN`, incrementing.

Ask before each write.

---

## Phase 6: Plan Mode

When invoked with `--plan`:

1. Read the active sprint plan to estimate available "debt capacity"
   (default: 10-15% of sprint capacity).
2. Sort the register by Priority descending.
3. Greedy-pack entries into the available capacity, preferring
   diverse categories (don't use all debt capacity on one category
   unless required).
4. Render a recommendation table.

Use AskUserQuestion to confirm the plan and ask whether to convert
chosen entries into stories via `/create-stories`.

---

## Phase 7: Pay-Down Mode

When invoked with `--pay-down=DEBT-NN`:

1. Locate the entry in the register.
2. Confirm the work shipped (commit ref, story ID).
3. Move the entry to the "Closed" rolling list with date and reference.
4. Suggest a regression test if appropriate (link `/regression-suite`).

Ask before each register edit.

---

## Phase 8: Render Summary

```
## Tech Debt — [date]

Open: [N] (High: [P], Med: [Q], Low: [R])
New since last scan: [count]
Closed since last scan: [count]
Top 5 by priority:
  1. [DEBT-NN] [summary] — Impact [I] / Effort [E]
  ...
```

---

## Phase 9: Update State

Append to `production/session-state/active.md`:

```
## Tech Debt — [date]
- Open: [N]
- High priority: [count]
- Plan generated: [yes/no]
- Register: docs/tech-debt.md
```

---

## Quality Gates / PASS-FAIL

- HEALTHY — high-priority entries < 5; no entry older than 6 months
  in the High tier; release-blocking debt (deprecated API with OS
  removal date) has an active story.
- ACCUMULATING — high-priority entries trending up across scans.
- BLOCKING — at least one High-priority entry has a known external
  deadline (OS update, store policy change) within 60 days and no
  active story.

---

## Examples

**Example 1 — Quarterly scan:**
Finds 38 TODOs (8 high-priority), 4 deprecated API uses (one with iOS
17 removal warning), 6 outdated deps. User accepts plan that schedules
the iOS 17 fix this sprint and 3 other high entries.

**Example 2 — Single pay-down:**
`/tech-debt --pay-down=DEBT-042`. Confirms the deprecated API was
replaced in commit `abc1234`, moves entry to Closed.

---

## Next Steps

- Plan mode -> `/create-stories` for chosen entries.
- BLOCKING -> emergency story or `/hotfix` if already breaking.
- After every release -> run `/tech-debt --scan` to keep the register
  honest.
