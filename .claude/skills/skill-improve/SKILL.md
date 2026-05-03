---
name: skill-improve
description: "Improve a SKILL.md file via static lint, fix proposal, rewrite, and re-test loop. Runs structural checks, proposes targeted fixes, applies them, re-tests, and either keeps or reverts based on score change."
argument-hint: "[skill-id | --all | --static-only]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---

# Skill Improve

A maintenance skill for the skill library itself. Combines static
linting (frontmatter compliance, structure rules) with a fix-test-keep
loop. Use when an existing skill is producing poor results, when
template structure changes and skills need to follow, or when a skill
has decayed against new conventions.

---

## Phase 1: Pick the Target

Parse the argument:

- `<skill-id>` — work on that skill at
  `.claude/skills/<id>/SKILL.md`.
- `--all` — iterate through every skill in the directory.
- `--static-only` — run only the linter, no rewrites.

If no argument is provided, list every skill and ask the user.

Read in parallel:

- The target SKILL.md.
- A reference set of skills already known to be in good shape (3-4 of
  the simplest, like `/help` and `/sprint-status`).
- Any local `skill-conventions.md` if present.

---

## Phase 2: Static Lint

Delegate the structural checks to `/skill-test --mode static <skill-id>`.
That skill is the canonical lint runner for the library — it owns the
frontmatter rules, body rules, and severity scoring. This skill consumes
its report and decides what to fix.

Run:

```
/skill-test --mode static <skill-id>
```

Read the resulting verdict and the per-rule findings. Capture: rule id,
severity (BLOCKER, WARNING, NIT), short description, suggested fix
hint.

If `/skill-test` is unavailable for any reason, fall back to inlining the
checklist (see `/skill-test` SKILL.md for the canonical rule set):
frontmatter compliance (`name`, `description`, `argument-hint`,
`user-invocable`, `allowed-tools`, `model`, `agent`), body compliance
(H1, purpose paragraph, numbered phases, Quality Gates, Examples, Next
Steps, line count 150-450, no emoji).

---

## Phase 3: Convention Lint

Cross-check against the rest of the library:

- Does the skill claim agents/tools that exist?
- Does it reference paths that match the project's directory
  structure?
- Does it use the project's standard verdict tiers
  (PASS/CONCERNS/FAIL or APPROVED/etc.)?
- Does it use AskUserQuestion at decision points where the reference
  skills do?

Capture each deviation.

---

## Phase 4: Render the Lint Report

```
## Skill Lint: [skill-id]
Rules checked: [N]
Passing: [N]
Failing: [N]

### Blockers
- [rule] [description]

### Warnings
- [rule] [description]

### Nits
- [rule] [description]

### Verdict: [CLEAN / NEEDS WORK / FAILS LINT]
```

If `--static-only`, stop here.

---

## Phase 5: Propose Fixes

For each Blocker and high-priority Warning, draft a specific fix:

- Frontmatter fixes are usually exact edits.
- Body structural fixes may require rewrites to whole sections.
- Phase clarity fixes require rewriting the offending phase.

Render the proposed diff. Use AskUserQuestion:

- `[A] Apply all proposed fixes`
- `[B] Apply some — let me pick`
- `[C] Skip — I want to fix manually`

For [A] or [B], run Phase 6.

---

## Phase 6: Apply Fixes

For each chosen fix:

- Snapshot the original content to memory (for revert).
- Apply via Edit (or Write for whole-section rewrites).
- Re-run the lint of Phase 2 on the updated file.

If the post-fix lint score is worse, revert and surface what went
wrong.

If the post-fix lint score is the same or worse on a different metric,
ask the user whether to keep, refine further, or revert.

---

## Phase 7: Behavioral Re-Test (optional)

If the skill has a behavioral test plan in
`tests/skills/[skill-id].test.md` (a manual-style test plan with
"input X, expected output Y" cases), run through it:

- For each case, ask the user to mentally run or actually run the
  skill against the case.
- Record PASS/FAIL.

If the behavioral score worsens, revert.

---

## Phase 8: Render the Improvement Report

```
## Skill Improvement: [skill-id]

Before:
- Lint passing: [N/M]
- Behavioral PASS: [N/M] (if tested)

After:
- Lint passing: [N/M]
- Behavioral PASS: [N/M] (if tested)

Changes applied:
- [list]

Reverts:
- [list]

Verdict: IMPROVED / NEUTRAL / REVERTED
```

Append to `.claude/skill-improvement-log.md` (create if absent). Ask
before writing.

---

## Phase 9: --all Mode

When `--all`, iterate every skill:

1. Static lint each.
2. Render a project-wide table of pass/fail.
3. Sort by Blocker count.
4. Walk through worst-first, asking the user whether to enter the
   improve loop for that skill.

Stop when the user says enough or every Blocker is resolved.

---

## Phase 10: Update State

Append to `production/session-state/active.md`:

```
## Skill Improve — [date]
- Target: [skill-id or all]
- Skills changed: [count]
- Reverts: [count]
- Log: .claude/skill-improvement-log.md
- Next: /skill-improve --all to keep going, or done
```

---

## Quality Gates / PASS-FAIL

- IMPROVED — post-state has fewer Blockers AND no regressions in
  behavioral score.
- NEUTRAL — same scores; user accepts no-op.
- REVERTED — post-state was worse; original restored.

---

## Examples

**Example 1 — fix a single skill:**
`/skill-improve dev-story`. Lint finds: missing PASS/FAIL block,
description over one sentence, two unused tools in `allowed-tools`.
Three fixes applied. Re-lint passes. Verdict: IMPROVED.

**Example 2 — library-wide audit:**
`/skill-improve --all`. 36 skills scanned. 4 have Blockers; user
walks through fixing two and defers two. Verdict per skill recorded
in log.

---

## Next Steps

- After improving a skill, exercise it on a real workflow to confirm
  the change helps.
- Re-run `--static-only` periodically (start of each release cycle)
  to catch decay early.
- For systematic conventions, document them in
  `.claude/skill-conventions.md` and re-run `--all`.
