---
name: team-design
description: "Orchestrate a full design cycle. Coordinates lead-designer, ux-designer, visual-design-director, interaction-designer, and motion-designer to take a feature from brief through to implementation-ready specs."
argument-hint: "[--brief=<path> | --feature=<name>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
agent: lead-designer
model: sonnet
---

# Team Design

End-to-end design cycle orchestration. Spawns the five design roles in
the order their work depends on each other, gathers approvals at every
phase boundary, and lands on a package the engineering team can
implement without re-asking.

---

## Team Composition

- **lead-designer** — design direction, scope boundaries, sign-off
  authority.
- **ux-designer** — user flows, screens, information architecture,
  accessibility.
- **visual-design-director** — visual system, typography, color,
  imagery.
- **interaction-designer** — gestures, affordances, microinteractions,
  states.
- **motion-designer** — transitions, animations, haptics
  choreography.

Spawn each via Task. Run independent subagents in parallel where
inputs are independent.

---

## Phase 1: Brief Intake

Parse the argument:

- `--brief=<path>` -> read the explicit brief.
- `--feature=<name>` -> glob `design/prd/**/*[name]*.prd.md` and
  related stories.
- No argument -> use AskUserQuestion to capture: feature name, target
  user, business goal, scope boundaries, deadline, prior art.

Read in parallel:

- The PRD if present.
- `.claude/docs/design-system.md` (if present) — current visual
  system.
- Any existing flows for the feature in `design/flows/`.

---

## Phase 2: Direction via lead-designer

Spawn `lead-designer` via Task. Prompt template:

> Brief: [content]. Existing system: [paths]. Set design direction:
> the user-experience hypothesis, the success criteria for this
> design (number of taps, error rate, conversion), the explicit
> scope of this cycle (what is in, what is out), the design tier
> (custom one-off vs. system-conforming).

Render the direction. Use AskUserQuestion:

- `[A] Approve direction — proceed`
- `[B] Adjust scope`
- `[C] Reset — re-discuss the brief`

---

## Phase 3: User Flow via ux-designer

Spawn `ux-designer` via Task. Prompt template:

> Direction: [reference]. Brief: [reference]. Produce: complete user
> flow diagram (entry points, main path, branches, error paths,
> happy/unhappy ends). Information architecture per screen (what's
> shown, hierarchy). Accessibility considerations: target dynamic
> type sizes, contrast, screen reader path, reduced-motion path,
> keyboard / external-keyboard support.

Render flow. Identify any open question for lead-designer to resolve.
Loop on AskUserQuestion until approved.

---

## Phase 4: Visual System via visual-design-director (parallel with Phase 5)

Spawn `visual-design-director` via Task. Prompt template:

> Direction: [reference]. Flow: [reference]. Existing visual system:
> [paths]. Decide whether this feature uses the existing system
> verbatim, extends it (adds tokens), or breaks from it. For each
> decision, document the rationale. Output: typography, color, icon,
> imagery treatments. Specify dark mode and high-contrast variants.

If the proposal extends the system, propose updates to
`.claude/docs/design-system.md` for review.

---

## Phase 5: Interaction Spec via interaction-designer (parallel with Phase 4)

Spawn `interaction-designer` via Task. Prompt template:

> Direction: [reference]. Flow: [reference]. For each screen and
> control, specify: idle state, pressed state, disabled state, error
> state, loading state, empty state. Specify gestures (tap, long-press,
> swipe, pinch, pull-to-refresh). Specify affordances and feedback
> (visual + haptic). Note platform conventions: iOS swipe-back,
> Android system back, share sheets, action sheets, contextual menus.

Render spec.

---

## Phase 6: Motion via motion-designer

Spawn `motion-designer` via Task. Prompt template:

> Direction: [reference]. Flow: [reference]. Interaction spec:
> [reference]. Visual system: [reference]. Choreograph transitions
> between screens, microinteractions for key controls, loading
> states, success / error animations. Specify duration and easing.
> Specify haptic pairings. Specify reduced-motion alternatives — every
> motion must have a reduced-motion fallback.

Render spec. Cross-check with `interaction-designer`'s pressed-state
specs to confirm motion durations don't fight the interaction spec.

---

## Phase 7: Holistic Review via lead-designer

Spawn `lead-designer` via Task to run a final critique against:

- Brief alignment.
- Internal consistency across UX, visual, interaction, motion.
- Existing pattern library reuse vs. novelty.
- Accessibility (every flow must work in screen reader, dynamic type,
  reduced motion, high contrast).
- Engineering implementability — flag anything that looks expensive
  to build (custom shaders, frame-budget-risky animations).

Render the verdict: APPROVED / NEEDS REVISION. If revision, loop the
specific subagent for fixes.

---

## Phase 8: Compose the Design Package

```markdown
# Design Package — [feature]

## Direction
[from lead-designer]

## Flow
[from ux-designer — embedded as Mermaid or referenced as a Figma link]

## Visual System
[from visual-design-director — token table, dark/contrast variants]

## Interaction Spec
[from interaction-designer — per-control state matrix]

## Motion Spec
[from motion-designer — timing, easing, haptic pairings, reduced-motion]

## Accessibility
- Dynamic type range: [min..max]
- Contrast: WCAG AA / AAA
- Reduced motion fallbacks: [mapped]
- Screen reader path: [described]
- Reduced data: [described]

## Implementation Notes
- Frame-budget-risky moments: [list]
- Platform divergences: [list]
- Open questions for engineering: [list]

## Approvals
- Lead Designer
- UX Designer
- Visual Design Director
- Interaction Designer
- Motion Designer
```

Ask before writing to `design/packages/[feature]-design.md`.

---

## Phase 9: Story Breakdown

Propose stories for `/create-stories`:

- One per screen (UI type).
- One per non-trivial animation (Visual/Feel type).
- One per new visual-system token addition (Config/Data type).

Use AskUserQuestion to confirm scope.

---

## Phase 10: Update State

Append to `production/session-state/active.md`:

```
## Design Package — [date]
- Feature: [name]
- Package: [path]
- Stories proposed: [count]
- Next: /ux-review then /create-stories then /dev-story
```

---

## Error Recovery

If any subagent returns BLOCKED:

- ux-designer blocked on missing PRD detail -> back to PRD author.
- visual-design-director blocked on no existing system -> propose
  initial design system definition before continuing.
- motion-designer blocked on platform-channel limitations (Flutter
  haptics on iOS, etc.) -> escalate to framework specialist.

---

## Quality Gates / PASS-FAIL

- PASS — every screen has flow + visual + interaction + motion
  spec; every motion has a reduced-motion fallback; all five
  approvals present; package implements every PRD AC.
- FAIL — missing spec for any screen, or any AC not addressed in the
  package.

---

## Examples

**Example 1 — onboarding redesign:**
Brief: shorten onboarding from 6 screens to 3 without losing key
information. Five subagents engaged sequentially with parallel V/I
spec. Package contains: 3 screens, 8 microinteractions, 4 transitions,
all reduced-motion fallbacks. 7 stories proposed.

**Example 2 — single-screen polish:**
Lightweight cycle. ux-designer skipped (existing flow). Direction +
visual + interaction + motion only. Package smaller; 2 stories
proposed.

---

## Next Steps

- `/ux-review` for an additional review against UX standards.
- `/create-stories` for the proposed stories.
- `/dev-story` to begin implementation.
