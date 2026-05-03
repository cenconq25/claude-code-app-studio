---
name: user-test-report
description: "Generate a structured user-test (beta) report template OR analyze existing user-test notes into a structured format. Standardizes how qualitative feedback turns into actionable findings tied to PRDs and stories."
argument-hint: "[--new | --from=<notes-path> | --session=<id>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion
model: sonnet
---

# User-Test Report

The output of beta tests, usability sessions, and TestFlight / Play
internal-testing waves. Two modes: produce a fresh report template a
researcher fills in during the session, or take messy notes and turn
them into a structured analysis.

---

## Phase 1: Mode

Parse the argument:

- `--new` — produce a blank report template for an upcoming session.
- `--from=<path>` — analyze raw notes at the given path.
- `--session=<id>` — locate session notes by ID under
  `production/research/sessions/`.

If no flag, ask the user which mode.

---

## Phase 2: Read Project Context

Read in parallel:

- `CLAUDE.md` and `.claude/docs/technical-preferences.md`.
- Active PRDs under `design/prd/`.
- Latest milestone in `production/milestones/`.
- Any prior session reports in `production/research/`.

This context anchors findings back to PRD requirements and ongoing
stories.

---

## Phase 3A: New-Template Mode

Compose a template the researcher will fill in:

```markdown
# User Test Report — [session-id]

**Date**: [date]
**Type**: [moderated remote | unmoderated remote | in-person | TestFlight | Play closed test]
**Build version**: [version + commit]
**Researcher**: [name]
**Participants**: [N]

## Goals
- [primary research question]
- [secondary]

## Recruitment
- Source: [pool]
- Demographics summary: [age, region, device class]
- Consent obtained: [yes — link to consent form]

## Tasks
| # | Task | Success criterion | Notes |
| 1 | Sign up | Reaches home screen in < 90s | |
| 2 | First paywall | Understands tiers; chooses or declines | |
| 3 | [feature] | [criterion] | |

## Per-Participant Results
| Participant | Task 1 | Task 2 | Task 3 | Notes |

## Observations (raw)
[Free text. Time-stamped if possible. One bullet per observation.]

## Quotes (direct)
- "[quote]" — Participant N

## Friction Map
| Screen | Friction | Severity | Frequency |

## Findings
### Confirmed (PRD assumptions verified)
- [finding] — confirms [PRD ref]

### Disconfirmed
- [finding] — challenges [PRD ref]

### New Insights
- [finding] — no PRD coverage; recommend [action]

## Recommendations
| Recommendation | Priority | Owner | Linked story / bug |

## Next Steps
- [action]
```

Ask before writing to
`production/research/sessions/[session-id]-template.md`.

---

## Phase 4A: New-Template Setup

Confirm with the user:

- Goals — what specific PRD assumptions are being tested?
- Tasks — which user flows will participants attempt?
- Build version — which TestFlight / closed test build?

For each task, suggest a success criterion drawn from the relevant
PRD's Acceptance Criteria. Use AskUserQuestion to confirm.

---

## Phase 3B: Analyze-Notes Mode

Read the notes file. Extract:

- Time-stamps if present.
- Mentions of features, screens, buttons, errors, terminology.
- Direct quotes.
- Researcher annotations.

Group raw observations into themes (auth, paywall, navigation, copy,
performance). Use clustering hints — repeated language, repeated
screens.

---

## Phase 4B: Apply the Friction Lens

For each observation, classify:

- **Friction type** — discoverability (couldn't find), comprehension
  (didn't understand), error (got an error), performance (felt slow),
  trust (hesitated to commit), aesthetic (didn't like).
- **Severity** — blocker (couldn't continue), major (workaround
  found), minor (noted but completed).
- **Frequency** — how many participants encountered it.

Render the friction map.

---

## Phase 5B: Tie Findings to PRDs and Stories

For each finding, search PRDs and active stories for relevant
references:

- PRD AC supports / contradicts the finding -> annotate.
- Active story is in flight that could absorb the finding ->
  recommend updating that story.
- No coverage exists -> recommend a new PRD section or story.

Surface "PRD-disconfirming" findings prominently — they are the
highest-value output of user testing.

---

## Phase 6B: Recommendations and Priorities

For each finding, propose:

- Priority (P0-P3 using same rules as bugs).
- Owner role (UX designer, content designer, lead developer, etc.).
- Linked artifact (existing story, new story, new PRD section).

Use AskUserQuestion to confirm priorities.

---

## Phase 7: Render the Report

Use the same template as Phase 3A but populated with the analyzed
content.

Ask before writing to
`production/research/sessions/[session-id]-report.md`.

---

## Phase 8: Update State

Append to `production/session-state/active.md`:

```
## User Test — [date]
- Session: [id]
- Participants: [N]
- Findings: [count]
- High-priority recommendations: [count]
- PRD-disconfirming findings: [count]
- Report: [path]
- Next: open follow-up stories via /create-stories
```

---

## Phase 9: Disconfirming-Finding Escalation

For any PRD-disconfirming finding, propose:

- A `/propagate-design-change` run on the affected PRD.
- A new ADR if the finding implies an architecture rethink.
- A retro topic for the next `/retrospective`.

---

## Quality Gates / PASS-FAIL

A user-test report passes if:

- Goals, tasks, participants, build version are recorded.
- Findings are categorized (confirmed / disconfirmed / new).
- Each finding has a recommendation with priority and owner.
- Direct quotes are preserved (not paraphrased) when notable.
- Disconfirming findings are escalated, not buried.

---

## Examples

**Example 1 — Pre-launch beta with 8 participants:**
Notes file contains 4 hours of observations across 3 sessions. Skill
produces a structured report. Surfaces 3 confirmed assumptions, 2
disconfirmed (paywall pricing logic and the onboarding skip path),
4 new insights. 3 follow-up stories opened.

**Example 2 — Template for upcoming TestFlight wave:**
`/user-test-report --new` walks user through goals, tasks, success
criteria; writes a blank session template the researcher uses live.

---

## Next Steps

- New high-priority finding -> `/create-stories` then `/dev-story`.
- Disconfirmed PRD assumption -> `/propagate-design-change`.
- Patterns across multiple sessions -> `/retrospective` topic.
