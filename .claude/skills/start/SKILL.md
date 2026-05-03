---
name: start
description: "First-time onboarding for the mobile app studio template. Asks where the user is starting from, classifies them, and routes them to the right next skill. Use this on the very first session, or whenever the project feels unmoored."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
model: sonnet
---

# Guided Onboarding (Mobile App Studio)

Single file written by this skill: `production/review-mode.txt` (only when the user picks a review mode in Phase 3b).

This is the entry point. It assumes nothing — not the framework, not the idea, not the user's experience level. It looks at what is on disk, asks the user where they are, then hands off.

---

## Purpose / When to Run

Run when:
- The repo has just been cloned and nothing has been authored yet
- The user types `/start` to re-orient
- A returning collaborator wants a clean route into the right next step

Do not run when the project is mid-sprint and the user has a clear active task — `/help` or `/sprint-status` are better.

## Inputs

- `.claude/docs/technical-preferences.md` — to detect whether a framework has been pinned
- `design/concept.md` — concept doc presence
- `design/prd/` — PRD count
- `production/review-mode.txt` — existing review-mode setting
- `production/sprints/` and `production/epics/` — production-stage signal
- `src/`, `ios/`, `android/`, `lib/` — code presence

## Outputs

- `production/review-mode.txt` — only written if not present and the user makes a choice in Phase 3b

---

## Phase 1: Silent State Probe

Do this without narrating. The findings only inform recommendations; they are not the conversation opener.

Check:
- **Framework configured?** Read `.claude/docs/technical-preferences.md`. If the Framework field still contains `[TO BE CONFIGURED]`, the framework is not pinned.
- **Concept exists?** Glob for `design/concept.md`.
- **PRDs exist?** Count files matching `design/prd/*.md`.
- **Source code present?** Glob for any of: `src/**/*.ts`, `src/**/*.tsx`, `lib/**/*.dart`, `ios/**/*.swift`, `app/src/main/**/*.kt`, `**/*.swift` excluding Pods.
- **Production work in flight?** Count files in `production/sprints/` and `production/epics/`.
- **Review mode set?** Glob `production/review-mode.txt`.

Hold these as facts to validate the user's self-assessment in Phase 4.

---

## Phase 2: Ask Where the User Is

Use `AskUserQuestion` once. Do not preload assumptions.

- **Prompt**: "Welcome to the mobile-app studio template. Before recommending anything, where are you with the app right now?"
- **Options**:
  - `A) No idea yet` — I want to figure out what to build.
  - `B) Loose theme` — I have a fuzzy sense (e.g., "a tracker for runners", "a calmer Instagram") but no spec.
  - `C) Clear pitch` — I can give you a one-liner: target user, core job, rough mechanic.
  - `D) Existing app` — There is already code, screens, or planning. I want to organize it.

Wait for their pick. Do not proceed otherwise.

---

## Phase 3: Route Based on Answer

### If A: No idea yet

1. Acknowledge that starting cold is normal.
2. Recommend `/brainstorm open` to develop a concept from zero. Mention `/brainstorm <hint>` if even a single seed word comes to mind.
3. Show the path:
   **Concept stage**
   - `/brainstorm open` — produce `design/concept.md`
   - `/setup-framework` — pin RN / Flutter / iOS / Android
   - `/design-bible` — visual identity tokens, app icon, splash
   - `/map-systems` — break the concept into systems
   - `/design-system <system>` — one PRD per system
   - `/consistency-check` and `/review-all-prds`
   **Architecture stage**
   - `/create-architecture` — master architecture
   - `/architecture-decision` (×N) — ADRs from the required list
   - `/create-control-manifest`
   - `/architecture-review`
   **Pre-production**
   - `/ux-design` — per-screen UX specs
   - `/prototype` — validate the riskiest mechanic
   - `/create-epics` then `/create-stories`
   - `/sprint-plan` — first sprint
   **Production** — pick stories with implementation skills (in the second skill set).

### If B: Loose theme

1. Ask them to share the theme in a sentence or two (free text).
2. Validate it as a starting point — never redirect.
3. Recommend `/brainstorm <hint>`.
4. Show the same path as A, with the brainstorm step substituted.

### If C: Clear pitch

1. Ask them to give the one-liner (free text — open response, not `AskUserQuestion`).
2. Use `AskUserQuestion`:
   - **Prompt**: "How do you want to proceed?"
   - **Options**:
     - `Formalize first` — Run `/brainstorm <pitch>` to structure it into `design/concept.md`.
     - `Skip ahead` — Go straight to `/setup-framework`, then author the concept doc by hand.
3. Show the path:
   - `/brainstorm` or `/setup-framework` (their choice)
   - `/design-bible` after the concept doc exists
   - `/design-review design/concept.md`
   - `/map-systems`
   - then PRDs → architecture → epics as in A.

### If D: Existing app

1. Reflect what you found in Phase 1, plainly: "I see [X PRDs / Y source files / framework set to Z / no concept doc]."
2. Sub-case D1 (early — only a concept or only a framework pin): recommend `/setup-framework` if missing, then `/project-stage-detect`.
3. Sub-case D2 (significant artifacts — PRDs, ADRs, stories already present):
   - Explain: "Files existing is not the same as the template's skills being able to read them. PRDs may be missing required sections; ADRs may lack Status. `/adopt` checks compliance specifically."
   - Recommend in order:
     1. `/project-stage-detect` — what stage and what is missing entirely
     2. `/adopt` — format compliance and migration plan
     3. `/setup-framework` if not pinned
     4. `/reverse-document` for any code with no design doc behind it
     5. `/architecture-review` to bootstrap the requirements registry

---

## Phase 3b: Set Review Mode

Check if `production/review-mode.txt` already exists.

**If it exists**: Read and report — "Review mode is set to `[value]`." Move to Phase 4. Do not re-ask.

**If it does not exist**: Use `AskUserQuestion`:
- **Prompt**: "How much review do you want as you move through the workflow?"
- **Options**:
  - `Full` — Director-tier reviews at every gate. Best for teams or anyone learning the template.
  - `Lean (recommended)` — Reviews only at phase boundaries. Balanced for solo and small teams.
  - `Solo` — No director reviews. Maximum speed. For prototypes, hackathons, or experienced solo devs.

Write the choice to `production/review-mode.txt` immediately:
- `Full` → `full`
- `Lean (recommended)` → `lean`
- `Solo` → `solo`

Create the `production/` directory first if it is missing.

---

## Phase 4: Confirm Before Handing Off

Use `AskUserQuestion` to confirm the recommended first step. Do not run another skill yourself.

- **Prompt**: "Want to start with [recommended skill]?"
- **Options**:
  - `Yes — start with [skill]`
  - `Something else first`

If the user picks the alternative, accept their input and adjust.

---

## Phase 5: Hand Off

Respond with one short line: "Type `[skill command]` to begin." Do not re-explain or pad.

Verdict: **COMPLETE** — user oriented and routed.

---

## Edge Cases

- **User picks D but disk is empty**: "The template looks unused — A or B may fit better. Which is closer?"
- **User picks A but disk has working code**: "I noticed code in [path]. Did you mean D?"
- **Returning user, fully set up**: Skip the long flow — "Framework: [X]. Concept: present. Review mode: [value or 'lean (default)']. Want to continue with `/sprint-plan`, `/sprint-status`, or describe what you want?"
- **None of the options fit**: Let the user describe their state in free text and adapt.

---

## Examples

User picks `B) Loose theme`, types "an app that helps bouldering gym climbers track their projects":
- Skill recommends `/brainstorm bouldering project tracker`.
- Shows the full concept → architecture → production path.
- Asks for review mode (user picks Lean).
- Writes `production/review-mode.txt` with `lean`.
- Confirms first step, hands off.

User picks `D) Existing app`, project has 3 PRDs and an iOS Xcode project:
- Reports findings.
- Recommends `/project-stage-detect` then `/adopt`.
- Notes that `/setup-framework` may not be needed if Xcode metadata already implies iOS native.
- Asks for review mode if unset.
- Hands off to `/project-stage-detect`.

---

## Collaborative Protocol

1. Ask first; never assume the user's state.
2. Present options as choices, not orders.
3. Recommend, do not auto-execute.
4. If the user's situation does not fit a tab, listen and adapt.
