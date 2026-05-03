---
name: skill-test
description: "Validates skill files for structural compliance and behavioral correctness in three modes (static lint / spec / audit). Use this before publishing skill changes or to audit the whole skill library for drift."
argument-hint: "[skill-id | --mode static|spec|audit | --all]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
model: sonnet
---

# Skill Test

The canonical validator for the project's skill library. Owned by the
template, used by `/skill-improve` (which calls `--mode static`), by CI
sanity hooks, and by maintainers auditing drift after a refactor.

Three modes, escalating cost:

- **static** — pure structural lint. Fast, deterministic. The default.
- **spec** — runs the skill against a fixture prompt set in
  `tests/skills/<skill-id>/` and checks the response shape.
- **audit** — library-wide coverage report: which agents are referenced
  by which skills, dead refs, ghost entries, tier drift.

Output is always a markdown report appended to
`production/skill-test-report.md`.

---

## Purpose / When to Run

Run before:

- Publishing a new skill (`--mode static`).
- Merging a PR that touches `.claude/skills/` (`--mode static --all`).
- A release-readiness gate (`--mode audit`).
- Investigating "why does this skill misbehave" (`--mode spec`).

Skip when:

- Editing only prose inside a skill that already passes static (the lint
  is unchanged).
- The change is a one-line typo fix.

---

## Inputs

- A skill id (resolves to `.claude/skills/<id>/SKILL.md`), or
- `--all` to iterate every skill, or
- `--mode <static|spec|audit>` to pick the mode (defaults to `static`).

For spec mode, fixtures live at
`tests/skills/<skill-id>/cases/<case-name>.md` with two sections: `## Input`
and `## Expected`.

For audit mode, the agent roster lives under `.claude/agents/`.

---

## Outputs

- A printed verdict per skill: `PASS`, `WARN`, `FAIL`.
- A structured report block appended to
  `production/skill-test-report.md` with timestamp.
- For `--mode audit`, a coverage table mapping skills → agents and
  agents → skills, with ghost / dead entries flagged.

---

## Mode A: Static Lint

The canonical structural rule set. This is what every skill MUST pass.

### Frontmatter rules

- [ ] YAML frontmatter delimited by `---` at file start.
- [ ] `name:` value matches the parent directory name exactly.
- [ ] `description:` is one sentence, ≤ 240 characters, begins with the
      action and ends with when to use.
- [ ] `argument-hint:` present using `[arg | --flag value]` shape.
- [ ] `user-invocable:` is literal `true` or `false`.
- [ ] `allowed-tools:` lists every tool referenced in the body. No
      `Write` if the body never writes; no missing tool either.
- [ ] `model:` matches the tier policy in `coordination-rules.md`:
  - Read-only/format-only → `haiku`.
  - Multi-doc synthesis with high-stakes verdicts → `opus` (only the
    handful listed in `coordination-rules.md`).
  - Otherwise → `sonnet` or absent.
- [ ] `agent:` if present matches a real file under `.claude/agents/`.

### Body rules

- [ ] Title H1 matches the skill name.
- [ ] Purpose paragraph is 2-4 lines below the H1.
- [ ] Phases are numbered (`## Phase 1:`, `## Phase 2:`...).
- [ ] Each phase declares: reads (inputs), asks (questions), writes
      (outputs), validations.
- [ ] At least one `## Quality Gates` or PASS-FAIL block.
- [ ] At least one `## Examples` block with two distinct examples.
- [ ] Line count between 150 and 450.
- [ ] No emoji in body unless the user explicitly invited them.
- [ ] No "be helpful" or generic-advice prose.

### Cross-reference rules

- [ ] Every agent name in backticks resolves to `.claude/agents/<name>.md`.
- [ ] Every skill name in backticks (`/skill-name` or `<skill-name>`)
      resolves to `.claude/skills/<name>/`.
- [ ] Every path referenced exists in the project's directory structure
      (per `directory-structure.md`).

### Severity

- **BLOCKER** — frontmatter mismatch, missing required field, dead
  agent ref, dead skill ref, illegal model tier.
- **WARNING** — line count out of range, missing Quality Gates section,
  description too long, allowed-tools mismatch.
- **NIT** — stylistic noise, missing Next Steps section, redundant
  prose.

### PASS / FAIL

- 0 BLOCKER, 0 WARNING → `PASS`.
- 0 BLOCKER, 1-3 WARNING → `WARN`.
- ≥ 1 BLOCKER, or ≥ 4 WARNING → `FAIL`.

---

## Mode B: Spec

For skills with fixtures at `tests/skills/<skill-id>/cases/`:

1. Read each case file. Parse `## Input` and `## Expected`.
2. The skill cannot be auto-invoked from inside another skill, so this
   mode emits a manual checklist:
   - For each case, print the input and the expected shape.
   - Ask the maintainer to run `/<skill-id>` against that input in a
     fresh session and paste the response.
   - Compare response shape (sections present, verdict tier, mandatory
     fields) to expected.
3. Aggregate: pass if every case matches expected shape; warn if 1 case
   diverges; fail if 2+ cases diverge.

If no fixtures exist for the skill, mode B reports `SKIPPED — no
fixtures` and recommends authoring at least two test cases.

---

## Mode C: Audit (library-wide)

Builds a coverage matrix:

1. Glob every skill SKILL.md.
2. For each, extract referenced agent names (regex on backticked names
   matching agent file basenames).
3. For each agent under `.claude/agents/`, list which skills reference
   it.
4. Flag:
   - **Dead skill→agent refs** — skill names an agent that does not
     exist.
   - **Ghost agents** — agent file exists but no skill references it.
     Not always a bug (some agents are spawned only by other agents);
     surface for review.
   - **Tier drift** — skill model tier disagrees with policy.
   - **Description length drift** — descriptions over 240 chars.
   - **Allowed-tools drift** — tools used in body but not declared.

Render the audit as a table grouped by category.

---

## Phase 1: Resolve Target

If argument is a skill id, resolve to its directory.
If `--all`, glob every skill.
If `--mode` is missing, default to static.

---

## Phase 2: Run the Mode

Dispatch on `--mode`:

- `static` → run the rule set above.
- `spec` → manual checklist mode.
- `audit` → library-wide coverage scan.

Each emits findings into a uniform record:
`{ skill, severity, rule, message, suggested_fix }`.

---

## Phase 3: Render the Report

Print the verdict at the top:

```
# Skill Test — [mode] [skill-id|all]

Verdict: [PASS / WARN / FAIL]

## Blockers
- [skill] [rule]: [message]
  Fix: [suggested]

## Warnings
- [skill] [rule]: [message]

## Nits
- [skill] [rule]: [message]
```

For `--mode audit`, additionally render the coverage matrix.

---

## Phase 4: Append to Report File

Ask before writing. If the user agrees, append the block to
`production/skill-test-report.md` with a timestamp header.

---

## PASS / FAIL Criteria

- **PASS**: zero BLOCKERs, zero WARNINGs.
- **WARN**: zero BLOCKERs, ≥ 1 WARNING. Skill is publishable but should
  be queued for `/skill-improve`.
- **FAIL**: ≥ 1 BLOCKER. Skill must not be merged until fixed.

For `--all`: aggregate is the strictest verdict across the set. One
FAIL means the library overall is FAIL.

---

## Examples

**Example 1 — single static lint:**
`/skill-test dev-story --mode static`. Frontmatter clean.
`allowed-tools` declares `Bash` but body never invokes it → WARNING.
Verdict: WARN.

**Example 2 — library audit:**
`/skill-test --mode audit`. Found: 3 dead agent refs (in `dev-story`,
`hotfix`, `team-backend`), 1 ghost agent (`prototyper` referenced
nowhere), 2 tier-drift skills. Verdict: FAIL. Maintainer fixes refs and
reruns.

**Example 3 — spec mode:**
`/skill-test prd-review --mode spec`. Fixtures present. Two test cases.
First case matches expected verdict shape; second diverges (skill
returned APPROVED but expected MAJOR REVISION). Verdict: FAIL.

---

## Next Steps

- For FAIL verdicts → run `/skill-improve <skill-id>` to apply the
  suggested fixes.
- For WARN verdicts → batch into the next maintenance pass.
- For PASS → mark the skill green in any tracking doc and move on.

---

## Constraints

- Static mode is read-only on `.claude/skills/`. The only file written
  is the report (with user consent).
- The skill never auto-fixes; that's `/skill-improve`'s job.
- Severity tiers are fixed and must not be downgraded by user
  preference.
