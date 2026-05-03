---
name: story-readiness
description: "Validates that a story file is implementation-ready — checks for embedded TR-ID, ADR references, framework notes, clear acceptance criteria, no open design questions. Produces READY / NEEDS WORK / BLOCKED verdict. Use before /dev-story to confirm a story can be started safely."
argument-hint: "<story-path>"
user-invocable: true
allowed-tools: Read, Glob, Grep
model: haiku
---

# Story Readiness

Fast pre-flight check on a story. Catches the gaps that would make `/dev-story` produce wrong code: missing TR-ID, Proposed ADR, missing UX spec for UI stories, ambiguous acceptance criteria.

Read-only. Outputs a verdict + checklist.

---

## Purpose / When to Run

Run when:
- A story has just been created and the engineer is about to start
- A story sat in the backlog and might have stale references
- The user types `/story-readiness <path>` or "is this story ready"

## Inputs

- Path to the story file (required)

## Outputs

- A printed verdict: `READY`, `NEEDS WORK`, or `BLOCKED`
- A checklist showing each check's status

---

## Phase 1: Resolve Path

If a slug is passed, glob `production/epics/*/story-*-<slug>.md` and find it. If multiple match, ask which.

If no argument, list stories with `Status: Ready` from `production/epics/*/story-*.md` and ask.

---

## Phase 2: Read

- The story file
- The PRD it references (just enough to verify the TR-ID exists)
- The governing ADR (verify Status)
- The control manifest (verify Manifest Version is current)
- The UX spec (UI stories only)

---

## Phase 3: Run Checks

Each check yields PASS / WARN / FAIL.

### 3a: Header completeness

- `Status` line present and one of `Ready / In Progress / Blocked / Complete` — FAIL otherwise
- `Type` line present — FAIL if missing
- `Manifest Version` line present — WARN if missing, FAIL if older than 30 days from today (probably stale)
- `Layer` line present — WARN if missing

### 3b: Context section

- PRD path resolves to an existing file — FAIL otherwise
- TR-ID is referenced and is in the format `TR-<system>-NNN` — FAIL if malformed
- TR-ID exists in `tr-registry.yaml` (if registry exists) or in the referenced PRD — WARN if not found
- Governing ADR path resolves to an existing file — FAIL otherwise
- Governing ADR has `Status: Accepted` — FAIL if Proposed (recommend `Status: Blocked`)
- Framework risk recorded — WARN if missing
- Verification required field has content (or explicit "None") — WARN if empty

### 3c: Control manifest pinning

- Manifest Version in story matches current Manifest Version in `docs/architecture/control-manifest.md` OR is at most 1 manifest version old
- If older: WARN — story may be implementing against outdated rules

### 3d: Acceptance criteria

- At least one criterion in GIVEN-WHEN-THEN form — FAIL if zero
- No criterion with TBD / TODO / "?" / "TBC" — FAIL if any
- Each criterion is testable independently (heuristic — flag obvious "the system works" criteria as FAIL)

### 3e: QA test cases

- For Logic / Integration: pre-written test specs present — WARN if absent (engineer can write them but the gate would prefer they be ready)
- For Visual/Feel / UI: manual verification steps present — WARN if absent

### 3f: Test evidence path

- Path stated — FAIL if missing
- Path is in the framework-conventional directory (`tests/unit/`, `tests/integration/`, `production/qa/evidence/`) — WARN if not

### 3g: UX spec pin (UI stories only)

- UX spec path resolves to an existing file — FAIL if missing
- UX spec has no `[To be designed]` placeholders — WARN if present
- UX spec has been reviewed (a `.review.md` file exists) — WARN if absent

### 3h: Mobile-specific considerations

- Section present — WARN if missing
- For platform-tricky stories (push, biometric, IAP, deep links, background): the section addresses platform divergence — FAIL if a Platform story has no per-platform notes
- Min OS noted — WARN if missing
- Permissions touched listed — WARN if missing for stories that obviously need them (camera, location, push)

### 3i: Open questions

- If the story has open questions, FAIL — story is not ready until they are resolved
- Comment in story like "TBD: confirm with PM" → FAIL

### 3j: Dependency stories

If the story is in a non-Foundation epic, check whether the Foundation stories its layer depends on are Complete:
- Yes / explicitly waived → PASS
- No → WARN (story can start but may hit blockers)

---

## Phase 4: Build Verdict

- 0 FAIL → **READY**
- 1-3 FAIL → **NEEDS WORK**
- 4+ FAIL OR governing ADR Proposed OR open questions present → **BLOCKED**

---

## Phase 5: Output

```
# Story Readiness: <slug>

**Verdict: <READY / NEEDS WORK / BLOCKED>**

## Checklist
- [PASS / WARN / FAIL] Header completeness
- [...] Context section
- [...] Control manifest pinning
- [...] Acceptance criteria
- [...] QA test cases
- [...] Test evidence path
- [...] UX spec pin (UI only)
- [...] Mobile considerations
- [...] Open questions
- [...] Dependency stories

## Blockers (FAIL)
1. <issue> — line <approx>
   Fix: <action>

## Warnings (WARN)
- <list>

## Recommended next step
- For READY: `/dev-story <path>`
- For NEEDS WORK: fix listed blockers, then re-run
- For BLOCKED: <specific path — e.g., write missing ADR, decompose blocking dependency>
```

---

## Quality Gates

- Verdict matches tally
- Every blocker has a fix path
- Read-only — never edits the story
- Fast — no specialist spawns, no deep PRD reads beyond TR-ID verification

---

## Examples

`/story-readiness production/epics/auth/story-003-token-storage.md`
- 0 FAIL, 1 WARN (no QA test cases pre-written)
- Verdict: READY
- Recommend: `/dev-story production/epics/auth/story-003-token-storage.md`

`/story-readiness production/epics/auth/story-005-biometric.md`
- 1 FAIL: governing ADR-0007 has Status: Proposed
- Verdict: BLOCKED
- Recommend: run `/architecture-decision retrofit docs/architecture/ADR-0007-biometric.md` to advance to Accepted, then re-run.

---

## Constraints

- Read-only
- Optimized for speed — runs on the haiku tier
- Does not duplicate `/architecture-review` work — only checks per-story readiness
