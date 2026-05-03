# Context Management

Context is the most expensive resource in a Claude Code session and the
hardest to recover when it is lost. The strategies below keep work portable
across compactions, crashes, and team handoffs.

## File-Backed State Is the Memory

Conversations evaporate. Files persist. Treat the conversation as a
working memory whose only durable trace must be in a file by the end of
each meaningful step.

### Active Session State

Maintain `production/session-state/active.md` as a living checkpoint.
Update it after each milestone:

- A PRD section is approved and written to disk
- An ADR is accepted
- A sprint story moves to In Progress, In Review, or Done
- A bug is filed with reproduction steps
- A test run produces a pass/fail tally worth remembering

The state file should always answer four questions: what is the current
task, what has been decided, what files are being touched, and what is
blocking the next step.

### Status Block (Sprint Dev and Later)

Once the project enters Sprint Dev, embed a status block inside `active.md`
that the status line script can parse:

```markdown
<!-- STATUS -->
Epic: Onboarding
Feature: Email Sign-up
Task: Validate email format on blur
<!-- /STATUS -->
```

- All three fields are optional. Use only the ones that apply.
- Update the block when focus shifts to a different feature or task.
- The status line renders it as a breadcrumb after the stage label.
- Remove the block when no specific work is in flight.

After any disruption — `/clear`, compaction, or session crash — read
`active.md` first. It is the canonical recovery target.

### Incremental File Writing

For multi-section documents — PRDs, architecture docs, design system
proposals — write each section to disk as soon as it is approved.

1. Create the file immediately with a skeleton (all section headers, empty
   bodies, plus a status footer).
2. Discuss and draft one section at a time in conversation.
3. Write each section to the file when the user approves it.
4. Update `active.md` with the section completed.
5. Once a section is on disk, the conversation about it can be safely
   compacted — the decision is durable.

This pattern keeps the live context window holding only the *current*
section's discussion (~3-5k tokens) instead of the entire conversation
history (~30-50k tokens).

## Proactive Compaction

- **Compact at 60-70% of context, not at the wall.** Reactive compaction
  drops important context.
- **Use `/clear`** when switching to an unrelated task or after two failed
  correction attempts on the same issue.
- **Natural compaction points**: after writing a section to disk, after
  committing, after closing a story, before opening a new feature.
- **Focused compaction**: `/compact Focus on [feature] — sections 1-3 of
  the PRD are written; we are mid-draft on section 4`.

## Context Budgets by Task Type

- **Light** (status check, single-file review): ~3k tokens of warm-up reading.
- **Medium** (implement a feature against a PRD): ~8k tokens — the PRD,
  the relevant ADR, and the file being modified.
- **Heavy** (cross-system refactor or migration): ~15k tokens. If the
  budget runs over, split the work across multiple sessions and rely on
  `active.md` to chain them.

## Subagent Delegation

Use subagents for research and exploration to keep the main session lean.
A subagent runs in its own context window and returns only its summary.

- **Use a subagent** when investigating across many files, exploring
  unfamiliar code, or doing research that would consume more than 5k
  tokens of file reads.
- **Use direct reads** when you know exactly which one or two files
  matter.
- Subagents do not inherit conversation history. Provide the full context
  they need in the prompt.

## Compaction Instructions

When the harness compacts a session, the resulting summary must preserve:

- Pointer to `production/session-state/active.md` (read it to recover).
- List of files modified in this session and why.
- Architecture decisions made and their rationale.
- Active sprint stories and their statuses.
- Subagent invocations and their outcomes (success / failure / blocked).
- Test run results (pass/fail counts; specific failure names).
- Open questions awaiting user input.
- The current task and the step we are on.
- Which sections of any in-flight document are written to disk vs. still
  drafting.

**After compaction**: read `active.md` and any in-flight files first. The
decisions are in those files; the conversation that produced them is not.

## Recovery After Session Crash

A session can die mid-flight ("prompt too long", VPN drop, harness restart).
Recover with these steps:

1. The `session-start.sh` hook automatically previews `active.md` if it
   exists.
2. Read the full `active.md` for the current task and decisions.
3. Read any partially-completed file the state references (PRD,
   architecture doc, story file).
4. Continue from the next incomplete section or unchecked task. Do not
   redo work already on disk; resume it.
5. Update `active.md` with the resumption note (timestamp + what changed).
