<!--
name: collaborative-protocols/draft-and-approval
purpose: How directors and senior agents present a multi-section draft to the user (PRD, ADR, paywall spec, store listing) and request explicit approval before writing or shipping. Mobile-flavoured examples included.
consumed-by: leadership agents (product-director, mobile-architect, lead-designer), authoring skills (/design-system, /architecture-decision, /ux-design)
placeholders: none — this is a guide
-->

# Draft & Approval Protocol

## Why this exists

Big artefacts in this project — PRDs, ADRs, store listings, paywall specs,
architecture docs — are written incrementally over multiple turns. The user
has to be able to steer the work as it forms, not after it's already on disk.

The Draft & Approval protocol is how that steering happens.

## Core rule

**A senior agent never writes more than one section to disk without an
explicit user "yes" between sections.** This is the difference between
collaborative authoring and autonomous execution.

## The protocol

### Step 1 — Skeleton first

Before drafting any prose, propose the document skeleton (section headers
only, no bodies). Use the template's section list.

> "I'm going to draft `design/prd/onboarding.md` using the PRD template. The
> sections will be: Overview, User Need (JTBD), User Stories, Detailed Rules,
> Edge Cases, Dependencies, Acceptance Criteria, Tunable Knobs, Telemetry,
> Accessibility Requirements, Out-of-Scope, Glossary. May I write the
> skeleton to disk so we can fill it in section by section?"

### Step 2 — Section-by-section drafting

For each section:

1. **Show the draft** — the full prose for that section in chat
2. **Highlight choices** — bullet the decisions you made and why
3. **Ask for approval** — "approve, revise, or skip"
4. **Wait** — do not write to disk until the user replies "approve"
5. **Write** — only the approved section, into the right place in the file
6. **Move on** — propose the next section

The conversation buffer holds at most one draft section at a time. Earlier
sections live in the file; the file is the memory.

### Step 3 — Final pass

After the last section is approved, do a brief re-read pass:

- Cross-references resolved?
- Placeholders all filled?
- Sign-off table present?

Then: "Draft is complete at `{{path}}`. Want me to mark it ready for review?"

## Mobile-app worked example

### PRD: in-app rating prompt

**Skeleton proposal**:

> "I'll use the PRD template. Sections will be Overview, User Need, User
> Stories, Detailed Rules (incl. iOS `SKStoreReviewController` and Android
> In-App Review API), Edge Cases (offline, low-rating users, repeated
> prompts), Dependencies, Acceptance Criteria, Tunable Knobs (cooldown
> days, qualifying-action threshold), Telemetry, Accessibility, Out-of-Scope.
> May I write the skeleton to `design/prd/in-app-rating.md`?"

**Section 1 — Overview**:

> Draft (in chat):
>
> > "Prompt qualified users for an App Store / Play Store rating after they
> > complete a value-defining action. Aim is to lift average store rating
> > from {{baseline}} to {{target}}, leveraging system-provided UI to keep
> > implementation thin and policy-compliant."
>
> Choices made:
> - Used system UI (no custom rating sheet) — Apple/Google policy
> - Phrased target as a delta, not absolute — leaves room for measurement
>
> Approve / revise / skip?

User replies "approve" → write section 1 → propose section 2.

## What "approve" means

Explicit affirmative. Examples:

- "Approve"
- "Looks good, write it"
- "Yes"

Not approval:

- "Hmm, OK." (ambiguous)
- "I think so." (uncertain)
- Silence (definitely not)
- "Sure, but change X" (revise → re-draft, do not write yet)

## Multi-file changesets

If the work spans multiple files (e.g. an ADR plus a control-manifest update
plus a story rewrite), present the full changeset in summary form before any
file is touched:

> "This change touches three files:
>
> 1. `docs/architecture/adr/0023-offline-cache.md` — new ADR
> 2. `docs/architecture/control-manifest.md` — append rule under Persistence
> 3. `production/sprints/sprint-12/stories/STORY-104.md` — update test approach
>
> May I proceed with all three?"

The user must approve the full set, OR specify which subset to do.

## When to skip a section

The user can answer "skip" for sections that don't apply (e.g. no telemetry
yet for a developer-only tool). When skipped, leave the section header with
a one-line note: "_Not applicable for v1._" Do NOT delete the section — it
keeps the document linter happy and signals the omission was intentional.

## Compaction-safe authoring

Because each section lives in the file as soon as it's approved, the
conversation can be compacted between sections without losing work. After a
compaction, the agent reads the partial file and resumes at the next
incomplete section.

## Cross-references

- `question-options-decision.md` — for in-section design choices
- `escalation-protocol.md` — when a section needs a different agent's input
