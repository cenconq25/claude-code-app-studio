---
name: propagate-design-change
description: "When a PRD is changed, scans all ADRs, dependent PRDs, stories, and the traceability index to identify what is now potentially stale. Produces a change-impact report and walks the user through resolving each downstream artifact. Use immediately after editing a PRD that other artifacts reference."
argument-hint: "<changed-prd-path>"
user-invocable: true
allowed-tools: Read, Glob, Grep, AskUserQuestion
model: sonnet
---

# Propagate a Design Change

A PRD edit invalidates downstream work in proportion to how many artifacts referenced it. This skill enumerates that impact in one pass so nothing slips through.

Read-only — no file edits. The user runs follow-up skills (`/architecture-decision`, `/design-system retrofit`, `/sprint-plan`) to apply changes.

---

## Purpose / When to Run

Run when:
- A PRD has just been edited (any section)
- A configurable value, formula, or interface in a PRD has changed
- A new edge case or acceptance criterion was added
- The user wants to know "if I change X, what breaks?"

## Inputs

- Path to the changed PRD (required)
- Optional: a description of what changed (free text); skill is more accurate with this hint
- All ADRs in `docs/architecture/`
- `docs/architecture/tr-registry.yaml` if present
- All stories in `production/epics/`
- All other PRDs

## Outputs

- A printed change-impact report

---

## Phase 1: Identify the Change

If the user did not describe what changed, ask:
- **Prompt**: "What changed in this PRD?"
- **Options**:
  - `New requirement added`
  - `Existing requirement modified`
  - `Configurable value changed (default or range)`
  - `Edge case added or modified`
  - `Acceptance criterion changed`
  - `Interface to another system changed (data shape / event)`
  - `Dependency added / removed`
  - `I don't know — scan and find out`

If user picks "I don't know" or "interface changed", skip to Phase 2 and rely on full scan.

---

## Phase 2: Identify Anchors

Build the list of "anchors" in the changed PRD that downstream work might reference:
- Every TR-ID in the PRD (`TR-<system>-NNN`)
- Every configurable value name (Section 6)
- Every interface / event / endpoint name (Section 3 / 5)
- The PRD's filename itself (some artifacts cite the path)
- Each entity name from the registry that this PRD owns (`source: <this-prd>`)

These anchors are the things downstream artifacts could cite.

---

## Phase 3: Scan for Downstream References

For each anchor, grep the project:
- `docs/architecture/ADR-*.md`
- `docs/architecture/tr-registry.yaml`
- `production/epics/*/EPIC.md`
- `production/epics/*/story-*.md`
- Other `design/prd/*.md`
- `design/ux/*.md`
- `tests/` (test names that reference TR-IDs)

Record every hit: file path + the anchor that matched.

---

## Phase 4: Classify Impact

For each downstream artifact that has a hit, classify:

- **STALE — REVIEW REQUIRED** — the artifact references something whose definition just changed; must be re-read to confirm it still aligns.
- **POTENTIALLY STALE** — the artifact references the PRD generally but not a specific changed anchor; may not be affected.
- **BLOCKED** — for stories: a story `Status: In Progress` that references a changed TR-ID. Halt that work until the change is reconciled.

ADR-specific:
- Status `Accepted` and references a changed anchor → may need to be updated or superseded (`/architecture-decision retrofit ...`)
- Status `Proposed` and references a changed anchor → revise before accepting

Story-specific:
- Status `Ready` and references a changed TR-ID → re-read the story; may need to update Acceptance Criteria
- Status `In Progress` → BLOCKED — surface to the engineer immediately
- Status `Complete` → check if test evidence still passes against the new criteria; if not, file a regression task

PRD-specific (cross-PRD):
- Another PRD references a configurable value whose default just changed → that PRD's expectations may be wrong
- Another PRD references an interface whose shape just changed → must update

---

## Phase 5: Produce the Impact Report

```
# Change Impact: <prd-path>

## What changed
<summary from Phase 1, or "scanned without explicit summary">

## Downstream impact

### ADRs (<N total, M stale)
- ADR-NNNN: <title> — Status: <Accepted | Proposed>
  References: TR-foo-001
  Action: re-read; if decision still valid, no change. If interface details have shifted, run `/architecture-decision retrofit docs/architecture/<adr>.md`.

### Stories (<N total, M stale, K blocked)
- production/epics/<epic>/story-NNN-<slug>.md — Status: <X>
  References: TR-foo-001 (changed), TR-foo-003 (unchanged)
  Action: <re-read | block | update acceptance criteria>

### Other PRDs (<N total, M stale)
- design/prd/<other>.md — references configurable `paywall_trigger_count` (default changed)
  Action: confirm the dependent PRD's expectations still hold.

### UX specs
- <list>

### Tests (regression risk)
- tests/integration/<...>_test.<ext> — Status: <pass | unknown>
  Action: re-run after changes propagate; failing tests indicate the change broke a verified behavior.

## Summary
- ADRs to revise: <N>
- Stories blocked: <N>
- Stories to re-validate: <N>
- PRDs to re-check: <N>
```

---

## Phase 6: Walk Through Resolution

Use `AskUserQuestion`:
- **Prompt**: "Want to walk through these one by one?"
- **Options**:
  - `Yes — start with the blocked stories`
  - `Yes — start with the stale ADRs`
  - `No — I'll handle them on my own`

If yes: for each artifact in the chosen list, present:
- The file path
- The specific anchor reference
- The relevant section of the changed PRD
- A recommendation:
  - For stories: re-read; suggest acceptance criteria diff
  - For ADRs: suggest `/architecture-decision retrofit ...` or a supersession
  - For other PRDs: suggest `/design-system retrofit ...`
  - For tests: suggest re-running before merging

After each, capture user's intent (free text) — "skip", "fix later", "fix now". Tally these for a summary at the end.

---

## Phase 7: Closing Summary

Print:
```
## Resolution log
- Acknowledged: <N>
- Action items captured: <N>
- Skipped: <N>

## Recommended sequence
1. Unblock in-progress stories first (talk to the engineer, update the story)
2. Update or supersede affected Accepted ADRs
3. Refresh other PRDs whose interface assumptions shifted
4. Re-run `/architecture-review` once stale ADRs are reconciled
5. Re-run `/consistency-check` once registry-affecting changes are pushed back to the registry
```

---

## Edge Cases

- **No downstream references found**: print "No downstream artifacts reference this PRD's anchors. Change is isolated." Useful confirmation.
- **The change involved deleting a TR-ID**: surface this loudly — any artifact citing it has lost its anchor and should be rewritten or deleted.
- **PRD path is ambiguous**: ask which one.

---

## Quality Gates

- Every downstream reference is named with file path + anchor
- Every CRITICAL / BLOCKED state surfaces an immediate action
- The skill never edits files itself
- The skill never silently deletes references — only reports

---

## Examples

User edited `design/prd/auth.md`, changing the rate limit from 5 to 3 per minute.
- 2 ADRs reference the rate limit
- 1 story `In Progress` references it (BLOCKED — engineer needs the new value)
- 3 other PRDs reference the auth rate limit indirectly
- Tests in `tests/integration/auth/` need to update their expected value
- Report walks through each, recommends `/architecture-decision retrofit` for ADR-0007, story update for the in-progress one
