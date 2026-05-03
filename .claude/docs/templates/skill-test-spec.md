<!--
name: skill-test-spec
purpose: Behavioural test specification for a Claude skill. Defines inputs, expected outputs, and pass criteria so /skill-test (spec mode) can verify a skill behaves as documented.
consumed-by: /skill-test, /skill-improve
placeholders:
  - {{skill_name}}
  - {{spec_id}}
  - {{author}}
  - {{date}}
-->

# Skill Test Spec — `/{{skill_name}}`

| Field | Value |
|-------|-------|
| Spec ID | {{spec_id}} |
| Skill under test | `/{{skill_name}}` |
| Author | {{author}} |
| Date | {{date}} |
| Mode | spec |

## Skill Under Test

- File: `app_dev/.claude/skills/{{skill_name}}.md`
- Allowed tools (declared in skill frontmatter): {{tools}}
- Model tier: haiku / sonnet / opus

## Purpose

One paragraph on what the skill is supposed to do, in this author's words.
Used by reviewers to spot drift between intent and the skill's own description.

## Behavioural Test Cases

Each case is a closed input → expected behaviour pairing. The runner provides
the input, captures the skill's output, and grades against the criteria.

### Case 1 — {{case_name}}

| Field | Value |
|-------|-------|
| Pre-conditions | files present / project state / env vars |
| Input prompt | {{prompt}} |
| Mock fixture files | {{paths}} |

**Expected behaviour**:

- Reads {{path}} before generating output
- Asks user before writing if any file is created
- Writes output to {{path}} matching template `{{template_name}}.md`
- Does NOT modify files outside `{{allowed_dirs}}`

**Pass criteria** (any failure = test fails):

- [ ] Output is a single markdown file
- [ ] Output contains the required sections: {{sections}}
- [ ] No prohibited tool calls observed (e.g. `Bash` if not declared)
- [ ] Output references the input PRD by ID
- [ ] Skill asked for approval before writing

**Common failure modes to grade against**:

- Wrote without asking
- Hallucinated requirements not present in input
- Skipped a required section
- Used wrong template

### Case 2 — {{case_name}} (negative path)

Test that the skill fails gracefully when input is malformed or missing.

| Field | Value |
|-------|-------|
| Pre-conditions | required input file missing |
| Input prompt | {{prompt}} |

**Expected behaviour**:

- Skill does NOT proceed silently
- Skill surfaces a BLOCKED status with the missing artefact named
- Skill suggests the upstream skill to run first

**Pass criteria**:

- [ ] No file written
- [ ] Output contains "BLOCKED" or equivalent status word
- [ ] Output names the missing artefact
- [ ] Output recommends a specific next skill

### Case 3 — {{case_name}} (edge case)

| Field | Value |
|-------|-------|
| Pre-conditions | |
| Input prompt | |

**Expected behaviour**:

-

**Pass criteria**:

- [ ]

## Coverage Map

| Skill behaviour | Covered by case |
|-----------------|------------------|
| Happy path | Case 1 |
| Missing input | Case 2 |
| Malformed input | Case 3 |
| Permission boundary | |
| Idempotency | |

## Out-of-scope for this spec

Things the runner should not attempt to verify here.

- Visual rendering of generated diagrams
- Performance / token usage
- LLM creativity ("did the prose read well")
- Multi-skill orchestration (covered in orchestration spec)

## Run Notes

- Last run: {{date}}
- Result: PASS / FAIL ({{n}}/{{total}} cases passed)
- Failures linked: {{issue_links}}
