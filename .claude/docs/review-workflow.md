# Review Workflow

Mobile work requires three kinds of review: code, design, and UX. Each has
a defined trigger, a defined reviewer, and a defined evidence trail. This
file explains how all three weave together with the gate system in
`director-gates.md`.

## Code Review

**Trigger**: Story implementation complete; ready for `/story-done`.

**Reviewer**: `lead-developer`, with the matching framework specialist as
consultant when the change is non-trivial in their domain.

**Process**:

1. Implementer runs `/code-review [paths...]` to self-review against rules
   and the governing ADR before requesting human review.
2. The skill spawns `lead-developer` with the LP-CODE-REVIEW gate from
   `director-gates.md`.
3. Verdict APPROVE → proceed to `/story-done`.
4. Verdict CONCERNS → discuss with the user; either accept (with reason
   captured in the story file) or revise.
5. Verdict REJECT → revise and re-review.

**Evidence**: Verdict + revisions captured in the story file's review
section. The story file is the durable record, not the conversation.

**Standards checked**: applicable rule files (`mobile-code.md` plus the
framework-specific rule), governing ADR boundaries, naming conventions,
test coverage for Logic and Integration stories, accessibility for UI
stories, performance budget for screens with custom rendering or
animations.

## Design Review

**Trigger**: Visual comps and motion direction complete for a PRD; ready
for engineering hand-off.

**Reviewer**: `lead-designer`, with `visual-design-director`,
`motion-designer`, `accessibility-specialist`, and the relevant UI
specialist as consultants.

**Process**:

1. The PRD owner runs `/design-system-audit [comp-paths]` first to catch
   token violations before review.
2. The skill spawns `lead-designer` with the LD-PRD-DESIGN gate.
3. Parallel checks (only in `full` review mode):
   - `accessibility-specialist` runs A11Y-AUDIT against the comps.
   - `motion-designer` checks motion specs match the language.
   - `localization-lead` flags strings that risk breaking layouts.
4. Verdict APPROVE → proceed to architecture / engineering.
5. CONCERNS → user decides whether to accept, fix, or defer.
6. REJECT → revise and re-review.

**Evidence**: Sign-off line appended to the PRD's review header. Review
artefacts (screenshots, motion clips) live under `production/qa/evidence/`.

**Standards checked**: design system token usage (no one-off colours,
type sizes, or spacing), state coverage (loading / empty / error / partial
/ success / offline), motion language consistency, accessibility floor,
localization fitness.

## UX Review

**Trigger**: Flow doc complete; before visual comps begin.

**Reviewer**: `ux-designer` and `info-architect`, with `interaction-designer`
consulting on gestures and `accessibility-specialist` consulting on focus order.

**Process**:

1. Author runs `/flow-review [flow-path]`.
2. The skill walks the flow against:
   - Primary path completes in the expected number of steps.
   - Each decision point has explicit success and failure branches.
   - Each error path returns the user to a recoverable state.
   - Permission prompts are positioned just-in-time, not up-front, with a
     pre-permission rationale screen where appropriate.
   - Offline behaviour is defined (block / queue / cache / degrade).
3. Verdict APPROVE → proceed to visual design.
4. CONCERNS / REJECT → revise.

**Evidence**: Sign-off line appended to the flow doc's review header.

**Standards checked**: platform conventions (iOS Human Interface Guidelines
+ Material 3), accessibility floor, error recovery, offline definition,
permission timing, hand-off to the right destination after every action.

## Combined Reviews at Phase Gates

`/gate-check` triggers parallel directors: `product-director`,
`mobile-architect`, `producer`, `lead-designer` — each with their
PHASE-GATE prompt from `director-gates.md`.

Apply the strictest verdict:
- Any NOT READY → overall FAIL.
- Any CONCERNS → overall CONCERNS.
- All READY → eligible PASS (still subject to artefact checks).

## Review Modes

Review intensity is controlled by `production/review-mode.txt`
(`full` / `lean` / `solo`) or per-skill `--review` flag.

- **full**: every gate runs.
- **lean (default)**: only PHASE-GATEs run. Per-skill gates skipped.
- **solo**: nothing runs. Use only on throwaway work.

Skills always print a one-liner when a gate is skipped so the audit trail
is honest about which reviews actually happened.

## Recording Outcomes

Every review verdict appends a single line to the document under review:

```markdown
> **Lead Developer Review (LP-CODE-REVIEW)**: APPROVED 2026-05-12 — comments addressed
```

This forms a durable history without bloating the document body. For
heavy reviews (architecture, beta gate, launch readiness), expand the
line into a sub-section detailing concerns and resolutions.

## Anti-Patterns

- **Approving with concerns and never fixing them.** Concerns must either
  be resolved or recorded as ADR-grade trade-offs with an owner and a
  date.
- **Re-reviewing after every keystroke.** Batch revisions; one re-review
  pass per round of changes.
- **Skipping accessibility review** because "it'll get audited later".
  Last-mile a11y rework is the most expensive kind.
- **Skipping performance review on visual stories.** A jank-laden screen
  in beta is a release blocker; catch it during code review.
