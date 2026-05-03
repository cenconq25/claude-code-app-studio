<!--
name: collaborative-protocols/escalation-protocol
purpose: When and how an agent escalates — to a director, to a shared parent, or to the user. Defines the boundary between "consult horizontally" and "escalate vertically." Includes mobile-app examples.
consumed-by: every agent — read at session start; cited by every team-* orchestration skill
placeholders: none — this is a guide
-->

# Escalation Protocol

## Why this exists

Agents in this studio operate in a tiered hierarchy:

- **Specialists** — single-domain (mobile-engineer, payments-specialist, accessibility-specialist)
- **Department leads** — coordinate a team (engineering-lead, qa-lead, design-lead)
- **Directors** — cross-department leadership (product-director, technical-director, design-director)
- **The user** — final authority

Without clear escalation rules, two failure modes appear:

1. Agents act outside their domain "to be helpful" and break boundaries
2. Agents stall on disagreements that should be lifted to a parent

This document defines the rules.

## Vertical escalation: when to lift the question

Escalate up when ANY of the following is true:

- The decision is outside your declared domain
- Two agents at your tier disagree and neither will yield
- The decision crosses departmental boundaries (engineering ↔ product, design ↔ engineering)
- The cost of being wrong is high-blast-radius (architecture, key management, store policy)
- You hit a constraint you don't have authority to relax (timeline, budget, scope)

Lift to:

- **Same-team lead** — for a within-domain disagreement (two mobile engineers on file structure)
- **Shared parent director** — for cross-domain conflict (engineering vs. design)
- **Product director** — for product-vs-engineering tension on scope or feasibility
- **Technical director** — for cross-cutting tech decisions (auth model, persistence stack)
- **Design director** — for cross-cutting design decisions (motion language, ATT primer voice)
- **The user** — for final calls, especially anything that ships externally

## Horizontal consultation: when NOT to escalate

You may consult peers without escalating when:

- You need an opinion but not a binding decision
- The question is your domain but you'd benefit from a second perspective
- You're sharing context for awareness, not asking for action

Phrase it explicitly so the peer doesn't accidentally take ownership:

> "Consultation, not delegation: how do you usually structure
> `flow-spec.md` for an onboarding flow with three branches?"

## How to escalate

Use this format whenever lifting:

> **Escalating to {{agent}}.**
>
> **Question**: {{question_in_one_sentence}}
> **My recommendation**: {{my_take_with_one_sentence_rationale}}
> **What I need from you**: a binding decision / a tie-breaker / a domain check
> **Why this is your call**: {{why_it_is_in_their_domain}}
> **Context links**: {{file_paths_to_read}}

Keep it short. The recipient should be able to make the call from the
document plus the linked context, not from a conversation summary.

## Mobile-app worked examples

### Example 1: ATT prompt copy (design ↔ legal)

The mobile-engineer is implementing ATT. Marketing wants persuasive primer
copy; legal worries it skirts policy.

> Mobile-engineer escalates to design-director.
>
> "Question: should the ATT primer say 'help us personalise your experience'
> or 'help us measure ad performance'? Marketing prefers the former, but
> Apple's review guideline 5.1.1 requires accurate, honest description.
> My recommendation: use the latter and lean on a follow-up onboarding card
> to surface personalisation. Why this is your call: cross-cutting voice +
> compliance trade-off."

The design-director makes the call OR re-escalates to the user / legal.

### Example 2: storage stack (within engineering)

Two mobile engineers disagree: SQLite (via Room/SwiftData) vs. file-based
JSON for offline cache. Same tier, no resolution.

> Both escalate to engineering-lead.
>
> "Question: SQLite or JSON for v1 offline cache? Disagreement is on
> migrate-ability vs. iteration speed. We've each written a 5-line
> rationale. Need a tie-breaker; we'll write the ADR after."

Engineering-lead decides OR escalates to technical-director.

### Example 3: store rejection (cross-cutting)

App Store reviewer rejects v1.4.0 over IAP-policy compliance. The mobile
engineer believes the rejection is incorrect; the release manager wants to
re-architect to comply.

> Both escalate to user via technical-director and product-director jointly.

This is appropriate because:

- The cost of being wrong is high (release slip, multiple departments affected)
- Neither agent has authority to dismiss a reviewer's note unilaterally

## What NOT to do

- Do not escalate trivially ("which CSS class name should I use?") — decide
- Do not silently overrule a peer — escalate openly
- Do not act on the escalated question while waiting — pause
- Do not skip a tier ("I'll just ask the user") unless the parent isn't
  available; respect the chain of command
- Do not interpret silence as approval; re-ping after a reasonable interval

## When the escalation chain is unclear

If you can't tell who the right parent is:

- Default to the **technical-director** for technical conflicts
- Default to the **product-director** for product / scope conflicts
- Default to the **design-director** for visual / interaction / brand conflicts
- If still unclear, lift to the user with the question itself.

## After resolution

Always record the resolution:

- In the relevant ADR / PRD / story file (the durable artefact)
- In `production/session-state/active.md` if it was a session-blocking decision

This keeps escalations from re-litigating themselves later.
