---
name: team-polish
description: "Orchestrate the polish phase. Coordinates performance-analyst, accessibility-specialist, animation-specialist, qa-tester, and content-designer to harden a feature or area to release quality."
argument-hint: "[--feature=<name> | --area=<name>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
agent: lead-developer
model: sonnet
---

# Team Polish

The dedicated polish-cycle orchestrator. Once features are functionally
done, this skill drives them to release quality through five
disciplines in parallel: performance, accessibility, motion, QA, and
copy.

---

## Team Composition

- **performance-analyst** — frame budget, cold start, memory, network,
  battery, app size.
- **accessibility-specialist** — VoiceOver / TalkBack, dynamic type,
  contrast, reduced-motion, keyboard nav.
- **animation-specialist** — animation correctness, haptic pairing,
  reduced-motion fallbacks, easing fidelity.
- **qa-tester** — manual walkthrough on the device matrix, soak
  validation.
- **content-designer** — final copy pass, length on every device,
  empty/error/loading states.

Spawn each via Task. All five can run in parallel — their inputs are
independent.

---

## Phase 1: Resolve Polish Scope

Parse argument:

- `--feature=<name>` -> the feature's screens and flows.
- `--area=<name>` -> a thematic area (e.g., "auth", "paywall",
  "settings").
- No argument -> ask the user.

Read in parallel:

- The feature's PRD and design package.
- Existing `/perf-profile`, `/security-audit`, `/asset-audit` artifacts
  for the feature area.
- Any open S3/S4 bugs scoped to this feature.

Define the polish bar with the user:

- Performance budgets per metric.
- Accessibility level (AA minimum, AAA aspirational).
- Localization completeness.
- Visual fidelity tolerance ("pixel-perfect" vs "design-aligned").

---

## Phase 2: Spawn All Five Reviewers in Parallel

### performance-analyst

Prompt template:

> Polish target: [feature/area]. Run `/perf-profile` scoped to this
> area. Identify any metric over budget. For each, propose a fix with
> impact estimate and effort.

### accessibility-specialist

Prompt template:

> Polish target: [feature/area]. Walk every screen with VoiceOver and
> TalkBack. Test dynamic type at min, default, and largest accessibility
> sizes. Test color contrast. Test reduced motion. Test external
> keyboard navigation. List every gap with severity.

### animation-specialist

Prompt template:

> Polish target: [feature/area]. Audit every animation: timing matches
> motion spec, easing matches spec, haptic pairings present, reduced-
> motion fallbacks present, no jank on Tier C devices. List
> deviations.

### qa-tester

Prompt template:

> Polish target: [feature/area]. Walk every flow on each Tier A
> device per platform. Document edge cases (slow network, low memory,
> background interruptions, device rotation, multitasking). File any
> S3/S4 bugs found. Spot any regression vs the previous build.

### content-designer

Prompt template:

> Polish target: [feature/area]. Review every string on the smallest
> and largest font scales. Confirm empty / error / loading states have
> first-class copy (not "Failed!" or generic "Loading..."). Flag any
> string with placeholders that could break in non-English locales.

Wait for all five to return.

---

## Phase 3: Aggregate Findings

Render a combined table:

| Source | Finding | Severity | Effort | Owner |
|--------|---------|----------|--------|-------|

Bucket by:

- **Must fix this polish cycle** — anything that violates the agreed
  bar.
- **Should fix** — measurable improvement, not a violation.
- **Defer** — outside the polish bar; backlog for next cycle.

Use AskUserQuestion to confirm the buckets.

---

## Phase 4: Story Generation

For each Must-fix and Should-fix item, propose a story spec for
`/create-stories`. Group by owner / specialty. Use AskUserQuestion to
batch the generation.

Each story should specify:

- The finding (from the source).
- The fix approach.
- The acceptance criterion.
- The test evidence path.

---

## Phase 5: Implementation Loop

For each generated story, run the standard loop:

1. `/story-readiness`
2. `/dev-story`
3. `/code-review`
4. `/story-done`

Re-spawn the relevant specialist to verify each fix landed correctly:

- Performance fixes -> performance-analyst re-runs `/perf-profile` on
  the touched flow.
- Accessibility fixes -> accessibility-specialist re-walks the flow.
- Motion fixes -> animation-specialist re-checks timing and reduced-
  motion.

Iterate until each Must-fix item closes.

---

## Phase 6: Polish Gate

After all Must-fix items close, run:

- `/perf-profile` full pass on the feature/area -> expect HEALTHY.
- `/asset-audit` to confirm no orphans introduced.
- `/localize --validate` to confirm copy changes are localized.
- A targeted soak run if the polish touched memory or background work.

If any gate is RED, surface and loop.

---

## Phase 7: Compose the Polish Report

```markdown
# Polish Report — [feature/area]

Started: [date]
Completed: [date]

## Polish Bar
[as agreed]

## Findings
| Bucket | Count |
| Must fix | N |
| Should fix | N |
| Defer | N |

## Stories Closed
| Story | Owner | Verdict |

## Final Gates
- /perf-profile: [verdict]
- /asset-audit: [verdict]
- /localize: [verdict]
- Soak (if run): [verdict]

## Verdict: POLISHED / NEEDS MORE / NOT APPLICABLE
```

Ask before writing to `production/polish/[feature]-polish-[date].md`.

---

## Phase 8: Update State

Append to `production/session-state/active.md`:

```
## Polish — [date]
- Target: [feature/area]
- Findings closed: [count]
- Deferred: [count]
- Verdict: [verdict]
- Report: [path]
- Next: /gate-check polish->release if ready
```

---

## Error Recovery

If any subagent returns BLOCKED:

- performance-analyst blocked on missing instrumentation -> propose a
  small story to add the markers, then resume.
- accessibility-specialist blocked on a missing API surface (e.g., no
  semantic labels exposed) -> escalate to framework specialist.
- qa-tester blocked on missing device -> note as device-specific gap;
  defer that device's verdict.

---

## Quality Gates / PASS-FAIL

- POLISHED — every Must-fix closed, every gate passes, deferred items
  have a backlog entry.
- NEEDS MORE — Must-fix items remain open or a gate is red.
- NOT APPLICABLE — the area scope was empty after review (rare).

---

## Examples

**Example 1 — Polish the paywall area:**
performance-analyst flags 22ms p95 frame on tier list (List re-render
issue). accessibility-specialist finds missing labels on tier cards.
animation-specialist flags a 600ms transition that violates the 350ms
spec. content-designer rewrites two error strings. qa-tester files 2
S3 bugs. 6 stories opened, 6 closed. Verdict: POLISHED.

**Example 2 — Polish the settings screen:**
accessibility-specialist flags 4 contrast issues on dark mode.
content-designer flags 3 strings that overflow at largest font scale.
2 stories opened. Closed. Verdict: POLISHED.

---

## Next Steps

- `/gate-check polish->release` to check if the area is release-ready.
- Continue polish for other features via repeat invocation.
- After all features polished -> `/launch-checklist`.
