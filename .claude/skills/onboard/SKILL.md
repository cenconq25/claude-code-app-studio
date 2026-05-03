---
name: onboard
description: "Generates a contextual onboarding doc for a new contributor based on their role (engineer, designer, PM, QA, etc.). Summarizes app concept, architecture, conventions, current sprint, and the contributor's likely first tasks. Use when bringing someone new onto the project or when a contributor switches roles."
argument-hint: "[role: engineer | designer | pm | qa | tester | ds] [--name <person>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
model: haiku
---

# Contributor Onboarding

Produces a single onboarding document tailored to the role. The doc is meant to be read once on day one and revisited a few times in week one — it is not a manual replacement for the codebase.

Output: `production/onboarding/[role]-[date].md`

---

## Purpose / When to Run

Run when:
- A new contributor is joining the project
- An existing contributor is moving from one role to another (e.g., backend → mobile)
- The user wants a "what would I tell someone new about this project" snapshot

Do not run when no concept doc exists — onboarding without context is a tour of an empty room. Direct the user to `/start` first.

## Inputs

- Role argument (required)
- Optional `--name <person>` for personalization
- All design, architecture, production artifacts on disk

## Outputs

- `production/onboarding/[role]-[YYYY-MM-DD].md`

---

## Phase 1: Resolve Role

If no role argument was passed, ask:
- **Prompt**: "Which role is the onboarding for?"
- **Options**:
  - `Engineer (mobile)` — implements stories, writes tests
  - `Designer (UX/visual)` — authors UX specs and the design bible
  - `PM / producer` — owns sprint plans, scope, milestones
  - `QA / tester` — runs test plans, files bugs, gates releases
  - `Data scientist / analytics` — instrumentation, metrics
  - `Other` — describe in free text

Capture the role as a kebab-case slug for the filename (`engineer`, `designer`, `pm`, `qa`, `analytics`, or whatever the user gives).

If `--name <person>` is included, the doc personalizes the welcome.

---

## Phase 2: Gather Project Context

Read what exists. If a file is missing, note it as "not yet authored" — never invent content.

Always read:
- `design/concept.md`
- `.claude/docs/technical-preferences.md`
- `design/systems-index.md` (if present)
- `production/session-state/active.md` (if present)

Role-specific reads:

| Role | Additional reads |
|------|------------------|
| Engineer | `docs/architecture/architecture.md`, `docs/architecture/control-manifest.md`, all Accepted ADRs, current sprint plan, `docs/framework-reference/<framework>/VERSION.md` |
| Designer | `design/design-bible.md`, all `design/prd/*.md`, all `design/ux/*.md`, the visual reference apps named in `concept.md` |
| PM | All sprint plans, all milestone docs, `production/session-state/active.md`, last 3 retrospectives |
| QA | All `production/qa/` artifacts, current test plans, story types breakdown for the sprint |
| Analytics | `concept.md` Primary Metric, any analytics PRD, instrumentation ADRs |

---

## Phase 3: Build Role-Specific Sections

The doc has a fixed shell, but content varies by role.

### Common header (every role)

- Welcome (personalized if `--name` given)
- One-paragraph description of the app pulled from `concept.md` Section 1 + 3
- Target user (Section 2)
- Primary metric (Section 5)
- Current stage (run the same logic as `/project-stage-detect` Phase 2 but inline; do not actually invoke that skill)

### Engineer-specific

- **Framework**: name + version + LLM-knowledge-cutoff risk if known
- **Architecture overview**: top-level layers from `architecture.md`
- **Key Accepted ADRs**: list the 5-10 most-referenced ADRs by ID, title, and one-sentence decision
- **Coding conventions**: pulled from `.claude/docs/coding-standards.md`
- **Control manifest highlights**: top 5 forbidden patterns and top 5 required patterns
- **Repo layout**: `src/`, `tests/`, the framework-specific dirs (`ios/`, `android/`, `lib/`, etc.)
- **First tasks**: pull 2-3 stories with `Status: Ready` and `Layer: Foundation` or `Core` from current sprint. List file paths.
- **Tooling**: build command, test command, lint command (read from `package.json`, `pubspec.yaml`, or Makefile)

### Designer-specific

- **Design Bible status**: token coverage + open sections
- **PRD inventory**: which systems have specs, which are stubs
- **UX coverage**: which screens have UX specs, which are missing
- **Conventions**: platform target (iOS HIG / Material 3 / both), accessibility floor (WCAG 2.2 AA)
- **First tasks**: missing UX specs for in-flight epics; PRDs with UI Requirements but no matching UX spec
- **Reference apps**: from `concept.md` Section 6

### PM / producer-specific

- **Current sprint**: name, dates, story count by status
- **Current milestone**: name, target date, completion %
- **Risk register**: open blockers from `production/session-state/active.md`
- **Recent retros**: takeaways from the last 1-2 retrospectives
- **Cadences in use**: sprint length, gate skills the team uses, review-mode setting
- **First tasks**: review the active sprint plan, run `/sprint-status`, talk to engineering lead about one named blocker

### QA-specific

- **Test framework** (from technical preferences)
- **Test counts**: unit / integration / manual evidence
- **Story type distribution** in the current sprint
- **Open bugs**: count + severity from `production/qa/bugs/`
- **First tasks**: run smoke check; read 3 specific stories due for QA hand-off

### Analytics-specific

- **North Star metric** (from concept.md)
- **Instrumentation status**: any analytics PRD or ADR
- **Tools**: analytics provider if pinned (Amplitude, Mixpanel, Firebase, etc.)
- **First tasks**: define the event schema for the in-flight epic; align metric definitions with PM

### Other

If the user described their role in free text, structure the doc with:
- Purpose of the role on this project
- Stakeholders they will interact with
- Files most-relevant to their work
- An open question for them to bring back to the team

---

## Phase 4: Sketch the First-Week Plan

Tail the doc with a "First week" section covering 5 work-days. Be concrete:

- Day 1: read these files in this order
- Day 2: shadow [contact] / pair with [contact] on [task]
- Day 3: take ownership of [specific story or PRD]
- Day 4: run [skill] for the first time
- Day 5: present what you learned in a 30-min review

If team contacts are not known, leave them as `[name TBD]` — do not invent.

---

## Phase 5: Write the Doc

Build the file content, then ask:
- "May I write this to `production/onboarding/[role]-[date].md`?"

If the user wants edits, capture them, redraft, ask again.

After writing:
- Update `production/session-state/active.md` if it is being maintained
- Print: "Doc written. Open it before [contributor]'s first day, share the path, and let them flag missing context — onboarding docs need updating after every cycle."

---

## Examples

`/onboard engineer --name Priya`
- Reads concept doc, framework ref, architecture, control manifest, current sprint
- Picks 3 Ready stories from Foundation/Core layers as first tasks
- Surfaces the most-relevant ADRs (state management, networking, navigation)
- Writes `production/onboarding/engineer-2026-05-03.md`

`/onboard pm`
- Reads sprint plans, milestone, active.md
- Tail-section recommends running `/sprint-status` and `/scope-check` in week one
- Lists stale stories that need re-triage

---

## Quality Gates

- The doc must list **at least one specific first task** with a file path. Vague advice ("get familiar with the codebase") is a failure mode.
- If a critical artifact is missing (no concept doc, no framework pin), the skill **must surface that as a blocker** rather than write a doc full of `[TBD]`.
- The doc never invents people, ADRs, sprints, or tasks.

---

## Constraints

- One file output, one role per run. To onboard multiple roles, run multiple times.
- Do not duplicate `/help`'s job. `/help` answers "what should I do right now?" — `/onboard` answers "what does this project look like to my role?"
