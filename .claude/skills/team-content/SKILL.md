---
name: team-content
description: "Orchestrate the content pipeline. Coordinates content-strategist, content-designer, localization-lead, and ux-designer to take a content brief from concept through written, localized, and shipped state."
argument-hint: "[--brief=<path> | --feature=<name>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
agent: content-strategist
model: sonnet
---

# Team Content

The cross-functional pipeline that turns a one-line content need into
shipped, localized, on-tone copy. Useful any time a feature spans
multiple screens of copy or any time a marketing-adjacent moment needs
consistent voice.

---

## Team Composition

- **content-strategist** — voice, tone, content architecture, channel
  planning.
- **content-designer** — UX writing on screen-by-screen basis.
- **localization-lead** — translation pipeline, locale-specific
  decisions, RTL audit, cultural review.
- **ux-designer** — ensures copy fits the layout and the user journey.

Spawn each via Task. Run independent subagents in parallel where their
inputs are independent.

---

## Phase 1: Resolve the Brief

Parse arguments:

- `--brief=<path>` -> read the explicit brief.
- `--feature=<name>` -> glob `design/prd/**/*[name]*.prd.md` and
  related stories.
- No argument -> walk the user through a brief intake via
  AskUserQuestion (purpose, audience, channels, deadline, length
  guidelines).

Read the brief, the relevant PRD, and the current voice/tone guidelines
from `.claude/docs/content-guidelines.md` (if present).

---

## Phase 2: Voice and Tone Anchor via content-strategist

Spawn `content-strategist` via Task. Prompt template:

> Brief: [content]. Project voice/tone guide: [path or summary].
> Recent comparable copy in the app (from prior PRDs, prior releases):
> [list]. Define the voice anchor for this piece — tone, formality,
> humor allowance, sensitive-topic guardrails. Identify the channels
> this content must work across (in-app, push, email, store listing,
> social).

Render anchor. Use AskUserQuestion to confirm.

---

## Phase 3: Information Architecture (parallel with Phase 4)

Spawn `ux-designer` via Task. Prompt template:

> Brief: [content]. Voice anchor: [reference]. Map the content to
> screens and surfaces. For each surface, capture: container (modal,
> banner, inline), max length budget, dynamic vs static, related
> imagery, accessibility constraints.

Render the surface map. This dictates the length envelopes
content-designer must write within.

---

## Phase 4: First Draft via content-designer

Spawn `content-designer` via Task. Prompt template:

> Brief: [content]. Voice anchor: [reference]. Surface map: [reference].
> Write the first draft for every surface. Include alternates for
> length-constrained surfaces (push notification at 65 chars vs 120
> chars). Use placeholder names (no PII). For dynamic strings, mark
> ICU placeholder positions.

Render draft. Use AskUserQuestion per surface group to approve, edit,
or reject.

---

## Phase 5: UX Review via ux-designer

Spawn `ux-designer` via Task with the approved draft. Prompt:

> Approved draft: [reference]. Verify each string fits its surface at
> minimum and maximum supported font scales. Verify no string
> truncates on the smallest target device. Flag any string that needs
> a layout change.

Surface any layout escalations. Iterate with content-designer if
needed.

---

## Phase 6: Localization Plan via localization-lead

Spawn `localization-lead` via Task. Prompt template:

> Approved English draft: [reference]. Target locales:
> [list from technical-preferences]. Produce a translation plan:
> vendor route, expected turnaround, special notes per locale (RTL,
> formal-vs-informal address in German/French/Japanese, plural rules
> for Russian/Polish/Arabic). Identify any string that should be
> rewritten in source for clearer translation. Identify any string
> that should be culturally adapted (transcreated) rather than
> translated.

If a string should be rewritten in source, loop back to
content-designer for a revised version.

---

## Phase 7: Pre-Translation Source Lock

Once English source is final:

- Add new keys to the source string table per the `/localize --extract`
  rules.
- Snapshot the source via `/localize --freeze` if release proximity
  warrants it.
- Hand off to translation vendor with the briefing produced in Phase 6.

---

## Phase 8: Cultural / RTL Review

When translations come back, use `/localize --validate` to spot
mechanical issues. Then spawn `localization-lead` once more to
qualitatively review:

- Cultural adaptation correctness.
- RTL layouts on a device for any RTL locale.
- Tone preserved per voice anchor.

Iterate as needed.

---

## Phase 9: Render the Content Package

```markdown
# Content Package — [brief name]

## Brief
[content]

## Voice Anchor
[from content-strategist]

## Surface Map
| Surface | Container | Length budget | Constraints |

## Strings
| Key | English | Surfaces | Notes |

## Localization Plan
- Vendors: [list]
- Locales: [list]
- Transcreation flags: [list]
- ETA: [date]

## Approvals
- Content Strategist
- Content Designer
- UX Designer
- Localization Lead
```

Ask before writing to `production/content/[brief-slug]-package.md`.

---

## Phase 10: Update State

Append to `production/session-state/active.md`:

```
## Content Package — [date]
- Brief: [name]
- Strings: [count]
- Surfaces: [count]
- Locales: [count]
- Package: [path]
- Next: hand to vendor; resume after translations land
```

---

## Error Recovery

If any subagent returns BLOCKED:

- content-strategist blocked on missing voice guide -> propose creating
  one this cycle.
- ux-designer blocked on missing surface info -> escalate to design
  team to provide screens.
- localization-lead blocked on no vendor configured -> surface; either
  configure now or accept English-only ship.

---

## Quality Gates / PASS-FAIL

- PASS — every surface has a string, every string within budget,
  voice anchor preserved, localization plan attached, transcreations
  flagged where appropriate.
- FAIL — surface without a string, length over budget, missing
  localization plan for a launch locale.

---

## Examples

**Example 1 — Push notification system rewrite:**
Brief: re-tone every push to be warmer and respect frequency caps.
Surface map: 14 push templates. Voice anchor: warmer, less
transactional. Drafts produced, UX confirms layout, localization
plans transcreation for Japan and Brazil. Package written.

**Example 2 — Empty-state copy across the app:**
12 screens missing empty-state copy. Brief: encouraging, helpful.
Drafts produced; one screen needs a layout change to fit the chosen
phrasing. Two iterations. Final package shipped to localization.

---

## Next Steps

- Vendor returns translations -> `/localize --validate` then this
  skill resumes Phase 8.
- Strings ready -> `/dev-story` per surface to wire into UI.
- For ongoing copy work -> include the package as the source of truth
  in future PRDs.
