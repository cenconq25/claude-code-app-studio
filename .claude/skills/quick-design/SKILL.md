---
name: quick-design
description: "Lightweight design spec for small changes — copy tweaks, single-screen polish, parameter adjustments — when a full PRD is overkill. Produces a Quick Design Spec that embeds directly into a story file. Use when a change is too small to justify a new PRD section but still needs a written spec for traceability."
argument-hint: "<change-name> [--story <story-path>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion
model: sonnet
---

# Quick Design — Light Spec

For changes where opening `/design-system` would be heavyweight: copy tweaks, single-control re-designs, paywall-position changes, debounce tuning, error-message rewrites. The spec ends up embedded inside a story file, not as a standalone PRD.

---

## Purpose / When to Run

Run when:
- A change is too small to update a full PRD section
- The PRD for the affected system is already complete and the change is a delta
- A bug fix has product implications worth recording
- The user types `/quick-design` for a one-off tweak

Do not run when:
- The change crosses multiple systems → use `/design-system`
- The change introduces a new system → use `/design-system`
- The change has no PRD context at all → use `/design-system` from scratch

## Inputs

- Change name (required)
- Optional `--story <path>` to embed the spec into a specific story
- Existing PRD for the affected system if any
- `design/concept.md`

## Outputs

Either:
- A standalone `design/quick/<change-name>.md`, OR
- An appended `## Quick Design Spec` block inside the named story file

---

## Phase 1: Argument Resolution

If no change name is provided, ask:
- **Prompt**: "What is the change?"
- Free text — capture as kebab-case for filename.

Detect parent PRD: ask the user which existing PRD this change touches. Use Glob `design/prd/*.md` and offer the list as `AskUserQuestion` options if they don't know.

Detect mode:
- `--story <path>` provided → embed mode
- No flag → standalone mode (writes `design/quick/<change-name>.md`)

---

## Phase 2: Lightweight Context

Read only what is needed:
- The parent PRD section the change affects (not the whole PRD)
- The story file if embed mode
- Relevant entries in `design/design-bible.md` if the change is visual

Print a one-line context summary: "Change touches PRD `<system>`, section `<name>`. Embedding into story `<NNN>`."

---

## Phase 3: Capture the Spec

Use a compact Q&A loop. Each question maps to a section of the spec.

1. **What is changing?** (one sentence)
2. **Why?** — link to a bug, metric goal, user feedback, or concept-doc principle
3. **Specifically what is the new behavior?** — exact copy / value / sequence / position
4. **What is replaced?** — exact prior behavior, so the diff is unambiguous
5. **Who does this affect?** — all users / new users only / paying users / specific cohort
6. **Are there edge cases?** — minimum required: offline, accessibility, dark mode if visual
7. **How will we know it worked?** — one or two acceptance criteria in GIVEN-WHEN-THEN

Use `AskUserQuestion` for cohort question (closed list); free text for the rest.

For visual / copy changes, also ask:
- "Copy: provide the exact final text" (free text)
- "Visual: any token changes from the design bible? Which?" (`AskUserQuestion` with bible token names if bible exists)

For threshold / parameter changes, also ask:
- "Old value, new value, valid range, who can change it without a release?"

---

## Phase 4: Draft the Spec

Build a compact block:

```markdown
## Quick Design Spec — <Change Name>

> **Created**: <date>
> **Affects PRD**: `design/prd/<system>.md` § <section>
> **Cohort**: <all / new / paying / specific>

### Change
<one paragraph — what is changing and why>

### Behavior diff
**Before:** <exact prior behavior>
**After:** <exact new behavior>

### Edge cases
- <list, mobile-relevant>

### Acceptance criteria
- **GIVEN** <state> **WHEN** <action> **THEN** <observable result>

### Notes
- <any callouts — feature flag name, A/B test, kill switch, instrumentation event>
```

Keep this under 30 lines. If it grows past that, recommend converting to a full PRD update.

---

## Phase 5: Approval & Write

Show the draft. Ask via `AskUserQuestion`:
- **Prompt**: "Approve and write this spec?"
- **Options**:
  - `Approve — write to story` (if embed mode)
  - `Approve — write to design/quick/<name>.md` (if standalone)
  - `Make changes — describe`
  - `Discard`

If embed mode: append the block to the story file using Edit, anchoring to the end of `## Acceptance Criteria` or the bottom of the file.

If standalone: write the file with a header `# Quick Design — <name>` plus the block.

After write:
- Update the parent PRD's "Open Questions" section to note "see quick spec at <path>" if a tracking link is useful
- Update `production/session-state/active.md`

---

## Phase 6: Suggest Next

Print:
> "Quick spec written. If this change should ship in the active sprint, run `/sprint-plan` (or update the existing sprint plan)."

If embed mode: also note "Story `<path>` now has the embedded spec — run `/story-readiness <path>` before implementation."

---

## Edge Cases

- **The "small" change keeps growing**: pause after question 3 if the change is touching more than one system or 3+ screens. Recommend `/design-system` instead.
- **No parent PRD**: the change is too foundational for quick-design; redirect to `/design-system`.
- **The user wants the spec but not the story embed**: write standalone. The story can reference the path later.

---

## Quality Gates

- The spec must include at least one acceptance criterion in GIVEN-WHEN-THEN form
- The before/after diff must be exact — no "improve" language without the specific change
- For copy changes, the exact final string is captured verbatim
- For threshold changes, old value + new value + range are all specified

---

## Examples

`/quick-design empty-state-copy --story production/epics/onboarding/story-007-add-list.md`
- Change: rewrite the empty state on the lists screen
- Before: "No lists yet."
- After: "Tap + to start your first list — it takes about 10 seconds."
- Acceptance: GIVEN a new account WHEN the user opens the lists screen THEN the new copy is shown.
- Embedded into the story file.

`/quick-design paywall-trigger-timing`
- Change: paywall now triggers after the 3rd successful action, not the 1st app launch
- Standalone spec written to `design/quick/paywall-trigger-timing.md`
- Acceptance: GIVEN a free-tier user has completed 3 actions WHEN they attempt the 4th THEN the paywall is shown
- Notes: feature-flag `paywall_trigger_v2`, A/B test against current behavior
