---
name: ux-review
description: "Validates a UX spec for completeness, accessibility (WCAG 2.2 AA), platform conventions (iOS HIG / Material 3), and implementation readiness. Produces APPROVED / NEEDS REVISION / MAJOR REVISION verdict with specific blockers. Run in a fresh session — never the same as the authoring session."
argument-hint: "<path-to-ux-spec>"
user-invocable: true
allowed-tools: Read, Glob, Grep, Task
model: sonnet
---

# UX Review

A fresh-eyes audit of a single UX spec. Catches the gaps the author cannot see — missing offline state, accessibility holes, copy that goes too long, layout that fights iOS HIG.

Read-only on the spec. Optionally writes a `<path>.review.md` snapshot.

---

## Purpose / When to Run

Run when:
- A UX spec has been authored by `/ux-design`
- The team wants a sanity-check before handing the spec to engineers
- A spec was edited significantly and needs re-validation

Run in a **fresh session** — the reviewer must not inherit the authoring context.

## Inputs

- Path to the UX spec
- Parent PRD
- `design/design-bible.md`
- `.claude/docs/technical-preferences.md`

## Outputs

- A printed verdict + blockers list
- Optional: `<path>.review.md`

---

## Phase 1: Resolve Path

If a name (not path) was passed, glob `design/ux/*.md` and find the match. If no argument, ask via `AskUserQuestion`.

---

## Phase 2: Read

- The UX spec
- The parent PRD (linked in the spec's header)
- The design bible (to verify token references are real)
- `.claude/docs/technical-preferences.md` for platform target and min OS

---

## Phase 3: Run Checks

Each check yields PASS / WARN / FAIL.

### 3a: Section presence

Required sections grep:
- Screen Goal
- User Flow Context
- Layout & Composition
- States
- Empty / Loading / Error / Offline
- Transitions & Motion
- Copy & Tone
- Accessibility
- Platform Notes
- Implementation Hooks

Any missing or `[To be designed]` → FAIL for that section.

### 3b: State coverage

Section 4 must enumerate states. Mobile minimum:
- Default
- Loading
- Empty (if the screen displays user data)
- Error
- Offline
- Stale (if cached data is shown anywhere)

Missing required state → FAIL.

Section 5 must give copy + behavior for at least: empty, loading, error, offline. Missing → FAIL.

### 3c: Token compliance

Every reference in Sections 3, 6 must point to a real token in the design bible:
- Color tokens by name (no inline hex)
- Type tokens by name (no inline pt sizes)
- Space tokens by name (no inline px values)
- Radius / elevation / motion tokens

For each violation (inline hex, inline px size, raw shadow params), FAIL.

### 3d: Accessibility

Section 8 must explicitly cover:
- VoiceOver / TalkBack reading order
- Element-level labels and roles
- Dynamic Type / scaled text
- Touch target floor
- Reduce-motion alternatives
- Color-not-the-only-cue
- Voice / Switch Control reachability

Missing items: WARN per item; FAIL if 3+ missing.

Verify contrast: cross-reference any color tokens used for text against the bible's contrast table (Section 13 of the bible). Any pair below WCAG AA → FAIL.

### 3e: Copy quality

- Every visible string in Section 7 has final-or-placeholder marker
- No untreated TODO / TBD strings
- Strings under 60 chars for buttons, under 90 chars for headlines, under 200 for body — soft heuristic; flag as WARN if exceeded
- For multi-locale projects, flag any string >40 chars that may not fit translated variants — WARN

### 3f: Platform conventions

If iOS-targeting, check the spec respects iOS HIG:
- Back nav uses gesture + nav-bar back button, not Android-style top-left arrow with text label
- Tab bar at bottom for primary nav
- Modal sheets follow iOS sheet conventions (handle, drag-to-dismiss)
- System fonts (SF Pro) used for type if no custom font is declared

If Android-targeting, check Material 3:
- Bottom nav bar or navigation rail per device size
- FAB conventions for primary action
- Dialog vs. bottom sheet conventions

For cross-platform, the spec must address both — Section 9 must not be empty.

Each violation: WARN. Pattern of violations: FAIL.

### 3g: Internal consistency

- The user-flow context in Section 2 must match how parent PRD describes entry points
- Every interactive element in Section 3 must appear in Section 8's reading order
- Every state in Section 4 must have either a layout reference (Section 3) or an explicit state-specific layout (Section 5)
- Every transition in Section 6 must reference real motion tokens

### 3h: Implementation readiness

Section 10 must include:
- Anticipated implementation file path or component name
- TR-ID coverage (linking to PRD requirements)
- Analytics events emitted from this screen
- Any feature flag gating

Missing TR-ID coverage: FAIL — stories that cite this UX spec will lack traceability.

### 3i: Open questions check

If Section 11 has 4+ unresolved questions, WARN — the spec is not implementation-ready until they are answered. If any open question would block engineering work, escalate to FAIL.

---

## Phase 4: Specialist Cross-Check (optional)

Spawn `Task` to:
- `accessibility-specialist` — deeper validation of Section 8 with the actual platform target
- `ux-designer` — sanity check on whether the screen does too much
- Framework specialist — read Section 10 implementation hooks for feasibility

The reviewer integrates findings.

---

## Phase 5: Verdict

Tally:
- 0 FAIL, ≤ 3 WARN → **APPROVED**
- 0 FAIL, 4-8 WARN → **APPROVED WITH NOTES**
- 1-3 FAIL → **NEEDS REVISION**
- 4+ FAIL → **MAJOR REVISION**

Output:

```
# UX Review: <screen / flow>

**Verdict: <APPROVED / APPROVED WITH NOTES / NEEDS REVISION / MAJOR REVISION>**

## Blockers (FAIL)
1. <issue> — Section <N>
   Fix: <action>

## Warnings (WARN)
- <list>

## Strengths
- <what passed and matters>

## Recommended next steps
- For APPROVED: stories that cite this UX spec are unblocked.
- For NEEDS REVISION: re-author specific sections in `/ux-design`, then re-run.
- For MAJOR REVISION: the spec has too many gaps — recommend re-running `/ux-design` from scratch.
```

---

## Phase 6: Optional snapshot

Ask: "Write this review to `<path>.review.md`?"

---

## Quality Gates

- Verdict matches tally rules
- Every blocker references a section number and a specific fix
- Every token reference in the spec is verified against the bible (the review never assumes)
- The review never edits the UX spec

---

## Examples

`/ux-review design/ux/home.md`
- All 10 sections present
- 1 FAIL: Section 5 missing offline state
- 2 WARN: Section 7 has 2 strings >60 chars on buttons; Section 9 thin on Android conventions
- Verdict: NEEDS REVISION
- Recommend re-authoring Section 5, tightening 2 button copy strings, expanding Section 9 with 3 Android-specific notes.

`/ux-review design/ux/paywall.md`
- 4 FAIL: missing accessibility section, 2 inline hex codes (no bible reference), no offline state, no platform notes
- Verdict: MAJOR REVISION
- Recommend re-running `/ux-design paywall`.

---

## Constraints

- Read-only on the UX spec
- Run in a fresh session — never the same one that authored the spec
- The review never silently fixes problems — always surfaces them
