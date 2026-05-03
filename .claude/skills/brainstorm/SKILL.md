---
name: brainstorm
description: "Guided ideation for a mobile app — from a blank page (or a single hint) to a structured concept doc covering target user, core job-to-be-done, MVP scope, and primary metric. Use when starting a new app or when an existing pitch needs to be tightened into a concept."
argument-hint: "[open | <theme or hint phrase>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, WebSearch
model: sonnet
---

# Brainstorm — Mobile App Concept

This skill writes one file: `design/concept.md`. It is collaborative — the user does the deciding; this skill structures the conversation and captures decisions.

---

## Purpose / When to Run

Run when:
- The user picked option A or B in `/start` (no idea, or a fuzzy theme)
- The user typed `/brainstorm <hint>` directly
- An existing pitch is too vague to drive `/map-systems`

Do not run when a complete concept already exists at `design/concept.md` — direct the user to `/design-review design/concept.md` instead.

## Inputs

- Argument: either `open` (no constraints) or a free-text hint (e.g., "habit tracker", "audio for runners")
- `.claude/docs/technical-preferences.md` — to detect platform constraints if pinned
- Optional: existing `design/concept.md` (if user is iterating on a draft)

## Outputs

- `design/concept.md` — concept document with the eight sections listed in Phase 4
- Optional update to `production/session-state/active.md`

---

## Phase 1: Parse Argument & Pick Mode

If the argument is `open` (or empty), run **open mode** — fully unconstrained, the skill must coax a direction out of the user.

If the argument is anything else, treat it as a hint and run **directed mode** — the hint becomes the seed, and Phase 2 anchors to it.

If `design/concept.md` already exists, ask:
- **Prompt**: "A concept doc already exists. What would you like to do?"
- **Options**: `Iterate on it`, `Start fresh (back it up first)`, `Cancel`

If iterating: read the existing file and treat it as the working draft. Phase 2 questions become "do these still hold?" rather than "what should this be?"

---

## Phase 2: Surface the User's Real Want

Mobile apps live or die on whether they solve a job a real user has on a real day. Spend this phase narrowing to that — do not dive into screens, framework, or monetization yet.

Ask the user, conversationally, three things in sequence (one question at a time, free-text answers — these are not multiple choice):

1. **Who is the user?** Get specific. Not "people who like fitness" — "intermediate boulderers who train 3x a week and forget to log their attempts."
2. **What job do they hire the app to do?** Frame as JTBD — "When I'm at the gym, I want to log a project attempt without breaking flow, so I can see my session over time."
3. **Where does this happen today?** Notes app, spreadsheet, memory, a competing app — the answer reveals the alternative they would defect from.

Reflect each answer back in one sentence to confirm.

If the user is in `open` mode and stalls, offer 3-5 seed prompts as `AskUserQuestion` options to break the freeze:
- "Who do you find yourself talking to often whose problem is unsolved?"
- "What did you wish existed last week?"
- "What is the most boring repetitive task on your phone?"
- "What is your hobby's worst pain point?"
- "What do you keep losing track of?"

---

## Phase 3: Sharpen the Concept

Once the JTBD is on the table, work through the remaining shape. Use `AskUserQuestion` widgets where there are 2-4 clean choices; use free text for open ones.

### 3a: One-liner

Draft a one-line pitch in the format:
`[App name TBD] is a [category] for [user] that [verb] [object] so they can [outcome].`

Show it. Use `AskUserQuestion`:
- **Prompt**: "Does this one-liner capture it?"
- **Options**: `Yes`, `Tighten the verb`, `Wrong category`, `Wrong outcome`, `Rewrite — I'll dictate`

Iterate until approved.

### 3b: Primary platform

Use `AskUserQuestion`:
- **Prompt**: "Which platform first?"
- **Options**:
  - `iOS first` — App Store, iOS HIG, Swift / SwiftUI native
  - `Android first` — Play Store, Material 3, Kotlin / Compose native
  - `Cross-platform from day one` — React Native or Flutter
  - `Decide later in /setup-framework`

Record their pick. Note this is a recommendation — `/setup-framework` finalizes it.

### 3c: Primary success metric

Every app needs one number that proves it works. Ask:
- **Prompt**: "What single metric tells you it is working?"
- **Options**:
  - `D7 retention` — does the user come back a week later
  - `Sessions per week` — engagement frequency
  - `Task completion rate` — percentage of users who finish the core flow
  - `Session length` — depth per session
  - `Conversion to paid` — for monetized apps
  - `Custom` — describe it (free text)

This becomes the **North Star metric** in the concept doc.

### 3d: MVP scope (the cuts)

Mobile MVP scope is about what to remove, not what to add. Ask:
- "If you only shipped one screen and one core flow, what is it?" (free text)
- "What are 3-5 features you would cut from v1 even though they are tempting?" (free text, list)

The cut list is more useful than the keep list — capture both verbatim.

### 3e: Anti-pitch (what this is NOT)

To prevent feature creep:
- "What does this app explicitly not do? What are nearby competitors doing that you will refuse to copy?" (free text)

### 3f: Visual & tone anchor

Even before `/design-bible`, capture a feeling:
- **Prompt**: "Pick a tone direction:"
- **Options**:
  - `Calm and minimal` (Bear, Things, iA Writer)
  - `Playful and bold` (Duolingo, Headspace)
  - `Dense and powerful` (Bloomberg, Pro Camera apps)
  - `Warm and personal` (Day One, Cozy)
  - `Other` — describe in free text

Capture 1-3 reference apps the user admires for visuals. These get re-read by `/design-bible`.

### 3g: Monetization stance (early signal)

Just a stance, not a plan:
- **Options**: `Free`, `Free + IAP`, `Free trial → subscription`, `One-time paid`, `Ads`, `Undecided`

### 3h: Riskiest assumption

Ask: "What is the single belief that, if wrong, kills the idea?" — this becomes the prototype target.

---

## Phase 4: Write the Concept Doc

Use Write to create `design/concept.md` with these sections, filled from the conversation:

```markdown
# [App Name] — Concept

> **Status**: Draft
> **Last Updated**: [today]

## 1. One-liner
[the approved sentence from 3a]

## 2. Target User
- Primary persona: [from 2.1]
- Daily context: [from 2.3]
- Job-to-be-done: [from 2.2]

## 3. Core Promise
[what the app fundamentally promises in one paragraph]

## 4. MVP Scope
**In v1:**
- [single core flow]
- [supporting screens]

**Cut from v1 (deliberate):**
- [list]

**Anti-features (will not build):**
- [list]

## 5. Primary Metric
[the chosen North Star + the rough target if user offered one]

## 6. Tone & Visual Anchor
- Tone: [from 3f]
- Reference apps: [list]
- One-word feeling: [extract from 3f]

## 7. Monetization Stance
[from 3g — note "to be confirmed in monetization PRD"]

## 8. Riskiest Assumption
[from 3h — flag as the target for `/prototype`]

## 9. Open Questions
- [anything raised during brainstorm that did not resolve]
```

Before writing, ask: "May I write this to `design/concept.md`?"

---

## Phase 5: Hand Off

After the file is written:

1. Update `production/session-state/active.md`:
   - Task: "Concept brainstormed for [app name]"
   - Files: `design/concept.md`
   - Next: `/setup-framework` if framework is unset

2. Use `AskUserQuestion`:
   - **Prompt**: "What's next?"
   - **Options**:
     - `Run /setup-framework` — pin the framework
     - `Run /design-review design/concept.md` — independent review
     - `Run /design-bible` — visual identity (after framework)
     - `Stop here for now`

3. Suggest opening a fresh session for `/design-review` so the reviewer is independent.

---

## Examples

Hint: `bouldering project tracker`
- Phase 2 produces: persona = "intermediate boulderers V4-V7", JTBD = "log attempts on the wall mid-session", today = "memory + paper".
- One-liner: "Sendr is a project tracker for intermediate boulderers that captures wall attempts in two taps so they can see progression across months."
- Platform: iOS first.
- Metric: D30 retention.
- MVP cut list: social feed, video upload, gym map.
- Riskiest assumption: "people will tap during a session instead of after."

---

## Collaborative Protocol

- Question → Options → Decision → Draft → Approval before any file write
- Reflect every answer back in one sentence — do not collect silently
- If the user contradicts an earlier answer, pause and reconcile rather than overwriting
- Never invent a persona, metric, or feature the user did not say or confirm
