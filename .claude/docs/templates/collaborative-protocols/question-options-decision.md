<!--
name: collaborative-protocols/question-options-decision
purpose: Reference guide for the Question → Options → Decision → Approval (QODA) protocol used by every agent in this studio. Includes mobile-app-specific worked examples.
consumed-by: every agent — read at session start; cited by /code-review, /design-review, leadership skills
placeholders: none — this is a guide, not a fillable template
-->

# QODA Protocol — Question, Options, Decision, Approval

## Why this exists

Agents in this studio do not act unilaterally on consequential decisions.
Every agent runs the same loop:

1. **Question** — What decision is on the table?
2. **Options** — What are the realistic choices, with trade-offs?
3. **Decision** — A recommendation, with rationale.
4. **Approval** — Explicit user (or director) sign-off before action.

This applies to: writing or editing files, choosing an SDK, selecting an
architectural pattern, picking a release window, drafting copy that ships
publicly, anything reaching the user.

## When to use it

Use QODA whenever the decision is:

- Hard to reverse later (architecture, naming, schema, public copy)
- Visible externally (store listing, ATT prompt, push payload)
- High-blast-radius (build pipeline, signing, key management)
- Stylistic in a way that affects identity (brand voice, motion language)

Do NOT use QODA for trivial mechanical work (renaming a private variable,
formatting a file, applying a lint fix). Use direct action.

## The four steps in detail

### 1. Question

Write the decision as a single closed question. If it can't be closed, the
question is too broad — split it.

Bad: "How should we do paywalls?"
Good: "Should we trigger the paywall on session 1 (hard wall), session 7
(soft wall), or after the user hits the free-tier limit (feature gate)?"

### 2. Options

Present 2–4 realistic options. For each, name:

- The option in one sentence
- Pros (≥ 2)
- Cons (≥ 2)
- Risks specific to this option
- Effort estimate

Avoid straw-man options. If you can't honestly defend an option, don't list it.

### 3. Decision (your recommendation)

Pick one option. State which and why. Be willing to defend it. The point of
the recommendation is to give the user a default; if they disagree, the QODA
exchange surfaces the disagreement faster than open-ended discussion.

### 4. Approval

Write the approval ask explicitly. Examples:

- "May I write this PRD to `design/prd/onboarding.md`?"
- "May I add the `react-native-purchases` dependency to `package.json`?"
- "May I open a PR with these changes?"

Wait for explicit "yes" before acting. Do not infer approval from neutral
acknowledgement.

## Worked examples (mobile)

### Example 1: paywall placement

**Q:** Should the v1 paywall fire on session 1, session 7, or on free-tier
limit hit?

**O:**

- A. Session 1 hard wall.
  - Pros: highest LTV/install; clear free vs. paid line; simplest to test
  - Cons: kills install→activation funnel; risks 1-star reviews; ATT consent
    drops sharply
  - Risk: Apple has rejected first-run hard walls without "alternatives" copy
  - Effort: S
- B. Session 7 soft wall (dismissable).
  - Pros: lets users feel the value; better day-1 retention
  - Cons: harder to attribute conversions; needs frequency-cap state
  - Risk: users settle on free tier and never convert
  - Effort: M
- C. Feature-gate at limit hit.
  - Pros: paywall fires when intent is highest
  - Cons: must define limits per feature; creates many surfaces
  - Effort: L

**D:** Recommend B (session 7 soft wall) for v1. Cheapest path to learning
without burning early funnel. We can layer C onto the same paywall infra
in v1.1.

**A:** "Should I draft the PRD for option B?"

### Example 2: cross-platform stack

**Q:** Should the v1 client be React Native + Expo, Flutter, or native
SwiftUI + Compose?

**O:** (three options with pros/cons/risks/effort)

**D:** Recommend Flutter for {{reasons}}.

**A:** "May I write ADR-0001 capturing this choice?"

### Example 3: ATT prompt timing

**Q:** When do we present the ATT prompt — pre-permission primer first, then
ATT? Or ATT raw on first launch?

**O:** primer-then-ATT vs. raw-ATT vs. defer until user hits an
attribution-relevant flow

**D:** primer-then-ATT after a value moment

**A:** "May I draft the primer copy for review?"

## What to do when the user pushes back

- Ask what they would change, not just whether they object
- Re-emit the QODA loop with the new constraint added
- Do not silently switch to their option — explicitly acknowledge

## Common anti-patterns

- Skipping straight to a recommendation with no options shown
- Listing "do nothing" as an option to pad the count
- Burying the recommendation under hedging — be willing to be wrong
- Acting before the explicit "yes"
- Treating a follow-up question as approval

## Cross-references

- `draft-and-approval.md` — when the artefact is a multi-section draft
- `escalation-protocol.md` — when QODA stalls or you're outside your domain
