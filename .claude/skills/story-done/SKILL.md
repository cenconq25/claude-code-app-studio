---
name: story-done
description: "End-of-story completion review. Verifies each acceptance criterion against the implementation, surfaces deviations, prompts code review if not yet done, marks the story Complete, and surfaces the next ready story. Use after /code-review."
argument-hint: "[story-path]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Edit, Write, Bash, Task, AskUserQuestion
model: sonnet
---

# Story Done

The closing gate of the per-story loop. Reads the story, audits each
acceptance criterion against the actual implementation, ensures evidence is
in place, prompts a code review if one is missing, then transitions Status
to Complete and points the user at the next ready story.

---

## Phase 1: Resolve the Story

If a path is supplied, use it. Otherwise consult
`production/session-state/active.md` for an active story, or glob
`production/epics/**/*.md` and ask the user which one.

Stop and warn if the story file does not exist.

---

## Phase 2: Read Story + Implementation Files

Pull these from the story:

- Story ID, Title, Layer, Type
- TR-ID and Governing ADR
- Acceptance Criteria (every checkbox)
- Implementation Notes
- Test Evidence path
- Out of Scope list
- Status (must be `In Progress` or `In Review`; if already `Complete`,
  ask the user whether to re-verify)

Glob the most recent edits to `src/` to find files modified for this story.
Cross-reference with the session state file. Read each modified file.

If a Test Evidence path is specified, read the test file. If absent for a
Logic or Integration story, this is a hard blocker (see Phase 5).

---

## Phase 3: Verify Each Acceptance Criterion

Walk every AC checkbox in order. For each:

| Story Type | Verification method |
|------------|---------------------|
| Logic | Locate test function(s) covering the AC; confirm assertions match the AC text; confirm CI run was green. |
| Integration | Locate integration test or documented playtest evidence; confirm the cross-system interaction is exercised. |
| Visual/Feel | Ask the user via AskUserQuestion for sign-off; require an attached screenshot or screen recording in `production/qa/evidence/`. |
| UI | Ask the user to walk through the flow on a device; require an evidence note or attached screenshot. |
| Config/Data | Confirm a smoke check report exists (`production/qa/smoke-[date].md`) and the values shipped match the story. |

Mark each AC one of: `VERIFIED`, `DEFERRED` (Visual/Feel awaiting user
confirmation), `MISSING EVIDENCE`, or `FAILED`.

---

## Phase 4: Check for Deviations

- Out of Scope check: list every modified file. Flag any file outside the
  Out of Scope boundary as a Deviation. Ask the user to confirm whether
  it was intentional.
- ADR check: re-read the governing ADR's Implementation Guidelines. Spot
  any obvious divergence in the diff and surface it.
- Manifest check: confirm the story's Manifest Version stamp still matches
  the manifest header date.

---

## Phase 5: Code Review Gate

Look for evidence of `/code-review` having run on the changed files. Look
in the session state file, conversation transcript, or any cached review
artifact.

If no review is recorded, use AskUserQuestion:

- `[A] Run /code-review now and resume /story-done after`
- `[B] Skip the review — accept the risk (NOT recommended)`
- `[C] Cancel — I'll come back later`

If [A], run `/code-review` against the modified files and incorporate the
verdict into Phase 6.

---

## Phase 6: Build the Verdict

Compose:

```
## Story Closing Review: [Story Title] ([Story ID])

### AC Verification
- [x] [AC1 text] — VERIFIED — covered by [test or evidence]
- [x] [AC2 text] — VERIFIED — implemented in [file:function]
- [ ] [AC3 text] — DEFERRED — awaiting Visual/Feel sign-off
- [ ] [AC4 text] — MISSING EVIDENCE — [what's missing]

### Deviations
[None | list with rationale and user confirmation]

### Code Review
[Reference + verdict, or "Not run".]

### Test Evidence
[Path | "Not required for Type: [type]"]

### Verdict: [COMPLETE | NEEDS FIXES | BLOCKED]
```

Verdict rules:

- **COMPLETE** — every AC is VERIFIED or has user-approved DEFERRED status,
  no MISSING EVIDENCE, code review APPROVED (or APPROVED WITH SUGGESTIONS),
  no unresolved out-of-scope changes.
- **NEEDS FIXES** — one or more ACs FAILED or have MISSING EVIDENCE that the
  user wants to resolve.
- **BLOCKED** — fundamental gap (no test for Logic story, ADR violation,
  scope blowout the user has not acknowledged).

---

## Phase 7: Update Story Status

If verdict is COMPLETE, ask the user:

> "May I update [story path] Status to `Complete` and stamp the
> Closed date?"

On approval, edit the story file:

- Set `Status: Complete`
- Add `Closed: [today's date]`
- Append a closing note section if there were Deviations:

  ```
  ## Closing Notes
  - [Deviation summary]
  - Code review verdict: [verdict]
  - Test evidence: [path]
  ```

Append to `production/session-state/active.md`:

```
## Story Closed — [date]
- [story path] -> Complete
- ACs verified: [N/M]
- Code review: [verdict]
- Next: [next ready story slug]
```

If verdict is NEEDS FIXES or BLOCKED, leave the story Status untouched
and write a `## Open Issues` section into the story file (with user
approval) listing what remains.

---

## Phase 8: Surface the Next Story

Read the active sprint file (`production/sprints/[current-sprint].md` or
the parent epic). Find the next story whose Status is `Ready` and whose
Dependencies are all `Complete`.

Render:

```
Next ready story: [title] ([path])
- Type: [type]
- Estimated effort: [estimate from story file]
- Run /story-readiness [path] to validate, then /dev-story [path] to start.
```

If no Ready story exists in the sprint, suggest `/sprint-status` to inspect
sprint state, or `/create-stories [next-epic]` if the epic is still open.

---

## Quality Gates / PASS-FAIL

- COMPLETE — story passes every gate; Status flipped, session state
  updated, next story surfaced.
- NEEDS FIXES — at least one AC unverified; story stays open; specific
  remaining work is documented.
- BLOCKED — fundamental gap; story stays open; user is told exactly which
  skill to run next.

---

## Examples

**Example 1 — A formula change story (Logic):**
Reads tests, confirms the unit test file exists and tests the AC's
boundary values, runs `/code-review`, both pass. Updates Status to
Complete. Surfaces the next Ready story.

**Example 2 — A new onboarding screen (UI):**
No automated test required. Asks the user to walk through the flow on a
device, requires a screenshot in `production/qa/evidence/`. The user
confirms two of three ACs and reports a small layout regression on the
third. Verdict: NEEDS FIXES. Story stays open with an Open Issues note.
