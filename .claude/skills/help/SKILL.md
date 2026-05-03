---
name: help
description: "Analyzes the project's current state and the user's question, then recommends the single best next skill or step. Use when the user says 'what should I do next', 'I'm stuck', or 'I don't know where to go'."
argument-hint: "[free-text question, optional]"
user-invocable: true
allowed-tools: Read, Glob, Grep
model: haiku
---

# Help — Next Step Recommendation

Read-only. Quick, decisive. The goal is to leave the user with **one** specific command to run next, not a menu of options.

This skill never writes a file.

---

## Purpose / When to Run

Run when:
- The user types `/help`, "what next", "I'm stuck", "I don't know what to do"
- The session resumed after a break and the user wants direction
- A skill just finished and the user wants the natural next step

Distinct from `/start` (full guided onboarding) and `/project-stage-detect` (full audit). This skill is fast — under 30 seconds of work — and outputs at most a paragraph.

## Inputs

- Optional free-text question (the user's exact words)
- The repo on disk

## Outputs

- A printed recommendation. No file writes.

---

## Phase 1: Read the Minimum

Read only what is needed to answer:
- `production/session-state/active.md` (if present) — the explicit ground truth of where the user is
- `.claude/docs/technical-preferences.md` Framework field — to detect setup state
- Glob `design/concept.md`, `design/systems-index.md`, `design/prd/*.md`, `docs/architecture/architecture.md`, `production/sprints/*.md` — count only, do not read content unless needed

If `active.md` exists and lists a clearly-defined "Next" line, that line **wins** over any other inference. Trust the file.

---

## Phase 2: Match the User's Question

Categorize the user's free-text input into one of:

1. **Stuck on a specific skill** — e.g., "I'm stuck on the architecture review", "design-system is asking weird questions"
2. **Lost about phase** — "where am I", "what stage are we in"
3. **Specific feature question** — "how do I add a screen", "where does the auth flow go"
4. **No question, just `/help`** — generic "what next"

If the input is empty, treat as case 4.

---

## Phase 3: Recommend

### Case 1 — Stuck on a specific skill

Read whatever artifact the skill writes (e.g., for `/architecture-review`, read its expected output path). If the issue is missing input, point to the upstream skill that produces it. If the issue is unclear, recommend reading `.claude/skills/<that-skill>/SKILL.md` to understand its inputs.

Output: one paragraph, one command.

### Case 2 — Lost about phase

If `active.md` says "Next: <command>", repeat that.

Otherwise infer phase from inventory:
- Empty repo → `/start`
- Concept exists, framework not pinned → `/setup-framework`
- Concept + framework, no PRDs → `/map-systems`
- PRDs exist, no architecture → `/create-architecture`
- Architecture exists, no epics → `/create-epics`
- Epics exist, no stories → `/create-stories <epic-slug>`
- Stories exist, no sprint plan → `/sprint-plan`
- Mid-sprint → `/sprint-status`

Pick **one**. Do not list the whole tree.

### Case 3 — Specific feature question

Examples:
- "how do I add a screen" → `/ux-design <screen-name>`
- "the auth flow is unclear" → check `design/prd/auth.md`; if missing, `/design-system auth`; if present, `/prd-review design/prd/auth.md`
- "I want to validate a risky idea before building" → `/prototype`
- "I want to know if scope has crept" → `/scope-check`

Match the question's verb (add, validate, review, audit, plan) to the right skill.

### Case 4 — Generic

Read `active.md`. If present, repeat its "Next" line. If absent, run the same inference as Case 2.

---

## Phase 4: Output

Format the response as:

```
**Recommended next step:** `/[skill] [args]`

Why: [one sentence pointing to a fact on disk that justifies this — e.g., "design/concept.md exists but design/systems-index.md does not, so /map-systems is the gap."]
```

If the user has multiple equally-valid options, name **one** as the primary and mention up to two alternatives in a single line:
```
Alternatively: `/skill-A` if you want to [reason], or `/skill-B` if [reason].
```

Never produce more than one paragraph + one alternatives line.

---

## Phase 5: Edge Cases

- **No artifacts at all**: recommend `/start`. End of story.
- **Multiple sprint plans, no clear active one**: recommend `/sprint-status`.
- **All artifacts complete and an active sprint exists**: recommend `/sprint-status` for situational awareness.
- **The user's question is genuinely ambiguous**: ask a single short clarifying question rather than guessing.
- **The recommended skill does not exist**: pick the closest valid skill and explain the substitution.

---

## Examples

User: "I have no idea what to do."
- `active.md` missing. Concept doc exists. PRDs missing.
- Output: "Recommended next step: `/map-systems`. Why: `design/concept.md` exists but no PRDs are written yet, so the next gap is decomposing the concept into systems."

User: "is the sprint going ok"
- Output: "Recommended next step: `/sprint-status`. Why: this is a fast read of the active sprint plan and story statuses."

User: "I think we have too many stories this sprint"
- Output: "Recommended next step: `/scope-check`. Why: this skill is designed to flag scope creep against the original sprint plan."

User: "the architecture review is yelling about a missing TR-ID"
- Output: "Recommended next step: `/architecture-decision retrofit docs/architecture/<file>.md` to add the missing PRD Requirements Addressed section. Why: that section is what `/architecture-review` uses to build the traceability matrix."

---

## Constraints

- Read-only. Never write a file. Never run another skill.
- One recommendation. No menus.
- No padding, no encouragement, no recap of what was inspected — just the recommendation and the one-sentence why.
- If the user asks something this skill cannot answer (a code-level technical question), say so and suggest `/onboard <role>` or pointing them to the relevant ADR.
