---
name: team-qa
description: "Orchestrate the QA team through a full testing cycle. Coordinates qa-lead (strategy + sign-off) and qa-tester (test cases + bug reports) for a sprint or feature. Covers plan, smoke gate, manual execution, bug filing, and sign-off."
argument-hint: "[sprint-id | feature: <name>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
agent: qa-lead
model: sonnet
---

# Team QA

End-to-end orchestrator for a testing cycle. Spawns qa-lead and qa-tester
subagents, walks through plan, smoke gate, manual execution, and lands on
a sign-off verdict the build either passes or does not.

---

## Team Composition

- **qa-lead** — strategy, story classification, sign-off verdict.
- **qa-tester** — manual test case writing, bug report drafting, on-device
  walkthrough.

Spawn each via Task with `subagent_type: qa-lead` or `qa-tester`. Always
hand the subagent the full context (story paths, plan path, device matrix,
scope constraints). Run independent qa-tester invocations in parallel
when scaffolding test cases for multiple stories at once.

---

## Phase 1: Load Context

Resolve the scope:

- `sprint-NN` -> read all stories in `production/sprints/sprint-NN/`.
- `feature: <name>` -> glob stories tagged for that feature.
- No argument -> consult `production/session-state/active.md`.

Read `production/qa/qa-plan-[sprint]-*.md` if it exists. If not, prompt:
"No QA plan for this scope. Run `/qa-plan` first?"

Read `production/stage.txt` for the current project phase.

Report to user:

> "QA cycle for [scope]. [N] stories. Stage: [phase]. Plan: [path or
> none]. Begin?"

---

## Phase 2: QA Strategy via qa-lead

Spawn `qa-lead` via Task. Prompt template:

> Read every story in [scope] and the QA plan at [path]. Produce a
> strategy: classify each story by Type (Logic/Integration/Visual/UI/
> Config-Data); flag any story missing acceptance criteria or test
> evidence; estimate manual hours; assess whether the smoke spec covers
> the scope adequately. Return a summary table.

Render the qa-lead's output. Use AskUserQuestion:

- `[A] Looks good — proceed to smoke check`
- `[B] Adjust classifications first`
- `[C] Skip blocked stories and proceed with the rest`
- `[D] Cancel — resolve blockers first`

---

## Phase 3: Smoke Gate

Run the `/smoke-check` skill (or invoke its workflow inline). Capture the
verdict.

- PASS -> continue.
- PASS WITH WARNINGS -> note for sign-off, continue.
- FAIL -> stop. Surface failures, point user at fix path. The cycle
  cannot proceed past a failed smoke check.

Update session state with the smoke verdict before continuing or stopping.

---

## Phase 4: Test Plan Production

If the QA plan from Phase 1 was absent or out of date, ask:
"Author/refresh the plan now via `/qa-plan`?"

If yes, run `/qa-plan` and use its output. Otherwise reuse the existing
plan. Write the final plan path to session state.

---

## Phase 5: Test Case Writing via qa-tester

For each story requiring manual QA (Visual/Feel, UI, Integration without
automated coverage):

Spawn `qa-tester` via Task — in parallel where stories are independent.
Per-story prompt template:

> Story: [path]. Plan section: [excerpt]. Acceptance criteria: [list].
> Write detailed manual test cases. Each case: Preconditions (app state
> required), Steps (numbered, unambiguous), Expected Result, Actual
> Result (blank), Pass/Fail (blank), Devices to run on. Cover every AC.

Render results grouped by story. Batch user review 3-4 stories at a time
via AskUserQuestion:

- `[A] Approved — begin manual QA on these`
- `[B] Revise [story] cases — [reason]`
- `[C] Skip [story] — not ready`

---

## Phase 6: Manual QA Execution

Walk each approved story group with the user.

Per story, render its cases and use AskUserQuestion:

```
question: "Manual QA — [Story Title] on [device]\n[case summary]"
options:
  - "PASS — every case verified"
  - "PASS WITH NOTES — minor issues (describe)"
  - "FAIL — one or more cases failed (describe)"
  - "BLOCKED — cannot run on this device (reason)"
```

After every FAIL: spawn `qa-tester` via Task to draft a bug report at
`production/qa/bugs/BUG-[NNN]-[slug].md` (NNN = next number after
existing). Include: title, severity (S1-S4), reproduction steps, expected,
actual, device + OS, build version, attachment paths.

After every BLOCKED: capture the reason in session state and surface to
qa-lead in Phase 7.

---

## Phase 7: Bug Triage Pass

If bugs were filed in Phase 6, surface them to the user via
AskUserQuestion:

- `[A] Sign-off as-is with bugs noted`
- `[B] Send back to engineering — fix S1/S2 bugs and re-run /team-qa`
- `[C] Defer S3/S4 bugs, sign off on current scope`

Pass the user's decision into Phase 8.

---

## Phase 8: Sign-Off Report via qa-lead

Spawn `qa-lead` via Task. Prompt template:

> Compose a sign-off report. Inputs: classification table from Phase 2,
> smoke verdict from Phase 3, manual results table from Phase 6, bug
> list from Phase 7. Verdict rules: APPROVED if no S1/S2 open and all
> stories PASS or PASS WITH NOTES; APPROVED WITH CONDITIONS if S3/S4
> open or PASS WITH NOTES; NOT APPROVED if any S1/S2 open or any story
> FAIL without workaround.

Report shape:

```markdown
## QA Sign-Off — [scope]
Date: [date]
QA Lead: [name]
Build: [version + commit]

### Coverage
| Story | Type | Auto | Manual | Result |

### Smoke Result
[PASS / PASS WITH WARNINGS]

### Bugs Filed
| ID | Story | Severity | Status |

### Verdict: APPROVED / APPROVED WITH CONDITIONS / NOT APPROVED

Conditions (if any): [list]

### Next Step
[guidance per verdict]
```

Verdict next-step guidance:

- APPROVED -> "Build is ready for the next phase. Run `/gate-check`."
- APPROVED WITH CONDITIONS -> "Resolve conditions before advancing.
  S3/S4 bugs may slide to polish."
- NOT APPROVED -> "Fix S1/S2 bugs; re-run `/team-qa` or targeted
  manual QA."

Ask before writing to `production/qa/qa-signoff-[sprint]-[date].md`.

---

## Phase 9: Update Session State

Append to `production/session-state/active.md`:

```
## QA Cycle Complete — [date]
- Scope: [sprint/feature]
- Smoke: [verdict]
- Manual: [PASS/FAIL counts]
- Bugs filed: [IDs]
- Verdict: [APPROVED / APPROVED WITH CONDITIONS / NOT APPROVED]
- Next: [/gate-check | fix and re-run]
```

---

## Error Recovery

If any subagent returns BLOCKED:

1. Surface immediately: "[agent]: BLOCKED — [reason]".
2. Identify whether downstream phases need that agent's output.
3. Offer options: skip + gap-note; retry narrower scope; stop and
   resolve.
4. Always emit a partial report.

Common blockers:

- Story file missing -> `/create-stories`.
- Build not installable on Tier A device -> `/release-checklist` build
  verification.
- Smoke check FAIL -> stop the entire cycle.

---

## Quality Gates / PASS-FAIL

This skill emits the binding verdict for the cycle. APPROVED means the
build advances; NOT APPROVED means it does not.

---

## Examples

**Example 1 — sprint-04 cycle:**
Loads plan, runs smoke (PASS), spawns 4 parallel qa-tester subagents to
scaffold cases, walks user through 4 stories, files 1 S2 bug, sign-off
verdict NOT APPROVED. User fixes the bug, re-runs `/team-qa sprint-04`.

**Example 2 — feature: paywall cycle:**
Single feature scope. 3 stories. Plan exists. Smoke PASS. Manual PASS
WITH NOTES (minor copy issue), no bugs. Verdict APPROVED.

---

## Next Steps

- APPROVED -> `/gate-check` for phase advancement.
- APPROVED WITH CONDITIONS -> resolve conditions, move to next sprint.
- NOT APPROVED -> fix bugs and re-run.
