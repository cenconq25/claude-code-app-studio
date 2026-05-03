---
name: bug-report
description: "Author a structured bug report from a description, OR analyze code/logs to derive likely bugs. Captures reproduction steps, severity, device matrix, expected vs actual, and attachments. Use after a manual QA failure or when the user describes a defect."
argument-hint: "[--from-description | --from-code=<path> | --from-crashlog=<path>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---

# Bug Report

Turn a vague observation into a fileable, actionable defect record. Three
input modes — user description, target code/files, or a crash log.

---

## Phase 1: Pick the Mode

If `--from-description` (or no flag): collect details from the user via
AskUserQuestion.

If `--from-code=<path>`: read the specified file(s) and look for likely
bugs (unsafe optionals, race conditions, leaked subscriptions, etc.).

If `--from-crashlog=<path>`: read the crash log, identify the failing
stack frame, and reverse-engineer steps.

---

## Phase 2A: From User Description

Walk through these prompts via AskUserQuestion in order:

1. **Title** — one line, action + outcome ("Sign-in fails after biometric
   prompt cancel").
2. **Severity** — S1 (crash, data loss, blocks release), S2 (major
   feature broken, no workaround), S3 (minor feature broken, workaround
   exists), S4 (cosmetic).
3. **Affected platforms** — iOS / Android / both.
4. **Device(s) reproduced on** — model + OS version. List all confirmed.
5. **Build version + commit SHA** — the build under which the bug was
   seen.
6. **Reproduction steps** — numbered, unambiguous. Each step should be
   verifiable on a fresh install.
7. **Expected result**.
8. **Actual result**.
9. **Frequency** — every time / often (>50%) / sometimes / once.
10. **Attachments** — screenshots, screen recordings, crash logs, charles
    captures, video file paths.
11. **Workaround** — if any.

Keep collected answers in working memory and assemble them in Phase 4.

---

## Phase 2B: From Code

Read the target file(s). Check for these patterns:

- Force-unwrapped optionals on user input.
- Unchecked array index access.
- Async work without cancellation that captures view state.
- Missing offline / error / loading branches.
- Non-idempotent network mutations (no idempotency key).
- Missing feature-flag fallbacks.
- Leaked subscriptions / observers (RN useEffect missing cleanup,
  Combine cancellables not stored, Flutter StreamSubscription not
  cancelled, Android Job not cancelled).
- Hardcoded keys, URLs, or environment names.
- Race conditions in `Promise.all` ordering.
- Memory: closures capturing strong `self` in iOS, missing `[weak self]`.
- Deep links accepting unsanitized parameters.

For each finding, propose a bug report with synthesized reproduction.

---

## Phase 2C: From Crash Log

Read the crash log. Extract:

- Crash type (NSException, SIGSEGV, fatal Dart error, ANR, OutOfMemory).
- Top frame in the app's own code.
- The thread (main vs background).
- The OS version, device, build.
- The date and time.

Search the codebase for the failing symbol or file. Read the surrounding
code. Hypothesize the trigger condition. Propose reproduction steps.

If the log lacks an app-level frame (pure framework crash), surface that
and suggest enabling symbolication.

---

## Phase 3: Triage

For every assembled report, derive:

- **Severity** — apply S1-S4 rules. Confirm with the user if ambiguous.
- **Frequency** — affects priority.
- **Priority** — derived from severity + frequency + business impact:
  P0 (drop everything), P1 (current sprint), P2 (next sprint), P3
  (backlog).

Surface the proposed severity/priority via AskUserQuestion and let the
user override.

---

## Phase 4: Render the Report

Use this template:

```markdown
# BUG-[NNN]: [Title]

**Filed**: [date] by [author]
**Severity**: S[1-4]
**Priority**: P[0-3]
**Status**: Open
**Affected platforms**: iOS / Android / both
**Affected build**: [version + commit]
**Frequency**: [every time / often / sometimes / once]

## Devices Reproduced
- [Model + OS]
- [Model + OS]

## Reproduction Steps
1. ...
2. ...

## Expected
[what should happen]

## Actual
[what happens instead]

## Workaround
[if any]

## Attachments
- [path or link]

## Suspected Area
[code path, module, recent commit, related ADR/PRD]

## Related
- Story: [path or ID]
- ADR: [ID]
- PRD: [path]
- Similar bugs: [list]

## Notes
[free text — investigation log starts here]
```

Number the bug as the next available `BUG-NNN` by globbing
`production/qa/bugs/BUG-*.md`.

Slug naming: `BUG-NNN-[short-kebab-slug].md`.

---

## Phase 5: Save

Ask: "May I write this to `production/qa/bugs/BUG-[NNN]-[slug].md`?"

On approval, write the file. Append to
`production/session-state/active.md`:

```
## Bug Filed — [date]
- ID: BUG-NNN
- Title: [title]
- Severity / Priority: S[N] / P[N]
- Path: production/qa/bugs/BUG-[NNN]-[slug].md
- Next: /bug-triage to schedule, or hand to engineer
```

---

## Phase 6: Cross-Link

If the bug is suspected to break a regression test target, propose:
"Add this bug to the regression suite via `/regression-suite --add-bug=BUG-NNN`."

If the bug stems from a story that recently closed, propose linking it in
that story's Closing Notes.

If a hotfix is warranted, propose `/hotfix BUG-NNN`.

---

## Quality Gates / PASS-FAIL

A bug report passes if it has:

- A non-empty title that describes outcome, not feeling.
- Reproduction steps that another engineer can follow on a fresh build.
- Expected vs actual cleanly separated.
- A severity AND priority assigned.
- A device list with at least one entry.
- A build version + commit SHA OR a clear note "build version unknown".

Reject and re-prompt for any missing field.

---

## Examples

**Example 1 — User description:**
Tester reports "the sign-in screen sometimes hangs". Skill walks through
every prompt, derives S2/P1, writes BUG-067 with 5-step repro, lists
iPhone 13 + iOS 17.5 + iPhone SE + iOS 16.7.

**Example 2 — From crash log:**
User pastes a `.crash` path. Skill extracts the top frame
(`PaymentReducer.applyPromo`), reads that file, sees an unguarded
force-unwrap on a server response field, drafts BUG-068 with
hypothesized repro: "Apply promo code with empty discount payload".

---

## Next Steps

- High-severity bug -> `/hotfix BUG-NNN` to launch the emergency flow.
- Otherwise -> `/bug-triage` at sprint start to schedule.
- For S1/S2 closes -> `/regression-suite --add-bug=BUG-NNN`.
