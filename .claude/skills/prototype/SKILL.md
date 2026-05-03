---
name: prototype
description: "Rapid prototyping workflow that deliberately skips standards to validate a risky concept fast. Produces throwaway code and a structured prototype report. Use to retire the riskiest assumption from /brainstorm before committing to architecture, or to validate a novel mechanic before adding to the sprint."
argument-hint: "<assumption-to-test>"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---

# Prototype

A prototype is a question the codebase poses to reality. It is **explicitly not** production code: no tests, no review, no PRD, no ADR, no manifest pinning. The output is a one-page report that tells the team whether the assumption holds — and whatever was learned along the way.

Outputs:
- `prototypes/<name>/` — the prototype's code (intentionally walled off from `src/`)
- `prototypes/<name>/REPORT.md` — what was built, what was learned, what to do with the learning

---

## Purpose / When to Run

Run when:
- The concept doc's "Riskiest Assumption" needs validation before architecture commitment
- A novel mechanic or framework feature needs to be tried before adding to a PRD
- A perf concern needs a quick measurement before locking budgets
- A library / SDK needs vetting before an ADR commits to it

Do not run for:
- Features that already have PRDs and ADRs (use `/dev-story` in the second skill set)
- Bug investigations (use the bug-fix workflow in the second skill set)
- Refactors of existing code (those are real stories)

## Inputs

- Assumption to test (required, free text)
- Optional: `design/concept.md` Section 8 (Riskiest Assumption) for context

## Outputs

- `prototypes/<name>/` — code
- `prototypes/<name>/REPORT.md`

---

## Phase 1: Frame the Question

If no argument was passed, ask:
- **Prompt**: "What assumption are you testing?"
- Free text — capture as kebab-case for the prototype name.

The framing matters. Use `AskUserQuestion`:
- **Prompt**: "Re-frame the assumption as a yes/no question. Pick or write:"
- **Options**: derived from the input — e.g., for "people will tap during a session":
  - `Q: Can users complete the core action in <3 seconds while doing something else?`
  - `Q: Does the gesture work mid-activity without misfires?`
  - `Custom (free text)`

The question becomes the prototype's success criterion.

---

## Phase 2: Define Success / Fail Criteria

Use `AskUserQuestion`:
- "What evidence would prove yes?" — free text
- "What evidence would prove no?" — free text

Pin both. The prototype is done when one or the other is observed — not when "the code runs."

Example:
- YES: "User completes the action in <3s in 80% of test runs across 5 testers."
- NO: "Median completion >5s, or misfire rate >20%."

---

## Phase 3: Constrain the Prototype

The point is to retire the question, not to build a feature. Constrain explicitly:

- **Time budget**: ask the user (1-3 days typical). Anything over 3 days is no longer a prototype — it is a feature in disguise.
- **Code quality bar**: "throwaway" — explicit non-goals: tests, accessibility, error handling, dark mode, localization, performance optimization.
- **Scope**: the smallest demo that shows yes/no.
- **Hardware target**: which device(s) this needs to run on. Often a single primary device.

---

## Phase 4: Pick an Approach

If the prototype lives in this repo's framework, use the existing framework setup. If the prototype needs a different stack (e.g., a quick HTML/JS sketch to validate a UX gesture before reimplementing in RN), allow it — call out the cross-stack mismatch in the report.

For mobile-specific prototypes, common patterns:
- **Static UX prototype** — Figma click-through with no code (the skill can produce a Figma-style spec instead of code)
- **Throwaway native** — quick SwiftUI / Compose / RN screen wired only to demonstrate the interaction
- **Library spike** — install the SDK, run the canonical demo, measure
- **Performance spike** — write the smallest possible reproduction; measure cold start / TTI / frame rate
- **Backend stub** — mock the API; validate the front-end behavior under known responses

Pick one with the user and document the choice.

---

## Phase 5: Build

Set up `prototypes/<name>/`. Inside it:
- README.md (one paragraph: question + how to run)
- A subdirectory or files for the actual prototype code
- A `.gitignore` at this level if needed

Build the smallest demo that answers the question. Skip:
- Tests (this code dies)
- Accessibility (intentional non-goal)
- Error handling (happy path only)
- Localization
- Dark mode
- Performance tuning beyond what is measured

Write inline comments noting why each shortcut is acceptable for a prototype.

---

## Phase 6: Run the Test

Run the prototype on the target device(s). Capture observations:
- Did the success criterion hold?
- What was measured (time, accuracy, perceived feel)?
- What surprised the testers?
- What edge cases surfaced that the PRD will need to address?
- What technical realities surfaced (a library limitation, an OS quirk)?

If user testing is involved, run with at least 3 testers. Capture each tester's session quickly — verbatim quote, time-to-action, any misfires.

---

## Phase 7: Write the Report

`prototypes/<name>/REPORT.md`:

```markdown
# Prototype Report: <name>

> **Question**: <the framed question from Phase 1>
> **Run on**: <date>
> **Time spent**: <hours / days>
> **Verdict**: <YES / NO / INCONCLUSIVE>

## Setup
- Stack: <RN / Flutter / native / web / Figma>
- Device(s): <list>
- Testers: <count, optional names>

## Method
<one paragraph — what was built, how it was tested>

## Success / Fail criteria (pre-defined)
- YES if: <criterion>
- NO if: <criterion>

## Findings
- <observation 1, with measurement if applicable>
- <observation 2>
- <observation 3>

### Quotes (if user-tested)
> "<verbatim>" — Tester A
> "<verbatim>" — Tester B

### Measurements
| Metric | Result | Target |
|--------|--------|--------|
| Time to action | 2.4s median | <3s |
| Misfire rate | 12% | <20% |

## Verdict
<YES / NO / INCONCLUSIVE>: <one paragraph explaining why the data leads to this verdict>

## What this means

For YES:
- Proceed with: <PRD section, ADR, sprint commitment>
- Update concept.md Section 8 to mark the assumption retired
- Capture lessons in the relevant PRD's "Implementation Hooks" section

For NO:
- Do not pursue this approach. Alternatives that emerged: <list>
- Update concept.md Section 8 with the new riskiest assumption
- Re-run `/brainstorm` if the core JTBD is at risk

For INCONCLUSIVE:
- More data needed. Specifically: <what would resolve it>
- Run a second prototype focused on <narrower question>

## Lessons (mobile-specific)
- iOS: <anything platform-specific>
- Android: <anything>
- Framework: <any version-specific gotchas to record in `breaking-changes.md`>
- Performance: <any numbers to feed into the architecture's performance budgets>

## What lives on after this prototype
- This code is throwaway. Do **not** copy it into `src/`.
- The findings live on in <PRD path / ADR / concept doc update>.
- The questions answered are recorded above.
```

Ask: "Approve the report and write to `prototypes/<name>/REPORT.md`?"

---

## Phase 8: Hand Off

Print:
> "Prototype complete. Verdict: <X>. <Recommended action — write a PRD, write an ADR, update concept doc, abandon, run another prototype>."

Update `production/session-state/active.md`:
- Note the prototype's verdict
- Pointer to next-action skill

Use `AskUserQuestion`:
- For YES: `Update concept.md to retire the assumption`, `Author the PRD via /design-system`, `Author an ADR if a technical choice was validated`
- For NO: `Update concept.md with the new riskiest assumption`, `Run /brainstorm to find an alternative`
- For INCONCLUSIVE: `Run a follow-up prototype with a narrower question`

---

## Phase 9: Anti-Patterns

The prototype is failing its purpose if:
- The code is being copy-pasted into `src/`
- The "prototype" took 2+ weeks
- The success criterion was not defined before building
- The team is treating the prototype as a feature
- The report is missing the verdict

If any of these, surface in the report's Notes section as a process learning.

---

## Quality Gates

- The Question is a yes/no
- Pre-defined YES and NO criteria are written before the build
- Verdict is YES, NO, or INCONCLUSIVE — never "the code works"
- Code lives in `prototypes/`, not in `src/` or `lib/`
- Time spent is recorded honestly

---

## Examples

`/prototype gesture-during-session`
- Question: Can users tap to log mid-activity without breaking flow?
- Stack: throwaway SwiftUI app
- 5 testers, 3-second target
- Median 2.4s, misfire 12%
- Verdict: YES
- Recommendation: write the PRD section confidently; the assumption is retired

`/prototype ar-anchor-stability`
- Question: Does ARKit hold the anchor through a 10-minute session?
- Stack: throwaway iOS app
- 1 device, 5 sessions
- Anchor drift average 0.8m at 10 min
- Verdict: NO
- Recommendation: drop AR anchor approach; explore alternatives. Update concept doc.
