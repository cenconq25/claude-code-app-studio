---
name: prd-review
description: "PRD-specific validation gate: checks required PRD sections, TR-ID requirement IDs, GIVEN-WHEN-THEN acceptance criteria, dependency-graph bidirectionality, and traceability readiness for engineering hand-off. Use ONLY for PRDs (`design/prd/*.md`); for any other design doc, use /design-review. Run in a fresh session — never the same session that wrote the PRD."
argument-hint: "<path-to-prd>"
user-invocable: true
allowed-tools: Read, Glob, Grep, Task
model: sonnet
---

# Review a PRD

Independent review gate for a single PRD. The reviewer must be in a fresh session so it does not inherit the authoring context — a PRD that "felt right while writing" can still fail review.

Output: a printed verdict + structured blockers list. Optionally writes a `.review.md` sibling file.

---

## Purpose / When to Run

Run when:
- A PRD has just been finished by `/design-system`
- A PRD has been retrofit from extracted code
- A reviewer wants a second pass on a previously-approved PRD that has changed

Do not run when:
- The PRD is incomplete (sections still `[To be designed]`) → run `/design-system` first
- The PRD has not yet been written → run `/design-system` first

## Inputs

- Path to a PRD file (required)
- `design/concept.md` for pillar checks
- Dependency PRDs from `design/systems-index.md`
- `design/registry/entities.yaml`

## Outputs

- A verdict: `APPROVED`, `NEEDS REVISION`, or `MAJOR REVISION`
- A structured blockers list
- Optional: `<prd-path>.review.md` snapshot written

---

## Phase 1: Resolve Path and Confirm Doc Type

If the argument is a system name (not a path), check `design/prd/<name>.md`. If exists, use it. If multiple matches, ask which.

If no argument, glob `design/prd/*.md` and ask:
- **Prompt**: "Which PRD should I review?"
- **Options**: list of files (use AskUserQuestion if ≤ ~6, else free text)

If the file does not exist, stop with a clear error.

**Doc-type guard**: this skill is for PRDs only. If the resolved file is
*not* a PRD (no `## Detailed Requirements` with `TR-` IDs and not under
`design/prd/`), stop and recommend `/design-review <path>` instead. Do
not run PRD checks against a non-PRD doc.

---

## Phase 2: Read Context

Read:
- The target PRD in full
- `design/concept.md` for principle and metric alignment
- `design/systems-index.md` to identify dependencies
- For each listed dependency, read the dependency PRD's interface sections
- `design/registry/entities.yaml`
- `.claude/docs/technical-preferences.md` (framework + min OS)

---

## Phase 3: Run the Checks

Each check produces a status: PASS, WARN, or FAIL.

### 3a: Section presence (FAIL on missing)

Required sections grep:
- Overview
- User Goal
- Detailed Requirements
- Edge Cases
- Dependencies
- Configurable Values
- Acceptance Criteria
- Accessibility

Each missing or placeholder-only section is FAIL.

### 3b: Section quality

- **Overview** — at least one paragraph, not a single sentence; does not contradict the concept doc
- **User Goal** — explicitly mentions the user, the moment, the alternative they would use otherwise
- **Detailed Requirements** — every requirement has a TR-ID (`TR-<system>-NNN`); FAIL if missing
- **Edge Cases** — covers: offline, slow network, backgrounding, OS permission denied, accessibility overlays — at minimum. Each formatted as `If <condition>: <resolution>`. FAIL if any vague resolution (e.g., "handle gracefully" without specifics)
- **Dependencies** — bidirectional check: each listed dependency is also referenced in the dependency PRD's "depended on by" section (or the systems-index)
- **Configurable Values** — each value has: name, default, range, owner. FAIL if a default is missing.
- **Acceptance Criteria** — every requirement has at least one criterion; every criterion is GIVEN-WHEN-THEN. FAIL if any criterion is non-testable.
- **Accessibility** — for UI systems, must cover: contrast, touch target, screen reader, dynamic type, reduce motion. WARN if any of those are missing; FAIL if section is empty or `N/A` for a UI system.

### 3c: Internal consistency

- TR-IDs unique within the PRD: FAIL if any duplicates
- Configurable values referenced by name in Detailed Requirements: WARN if a value is defined but not referenced (likely dead)
- Acceptance criteria reference TR-IDs: WARN if a criterion has no TR-ID linkage
- Edge cases cover every state transition mentioned: WARN if a state transition has no edge-case row

### 3d: Cross-document consistency

For every entity / configurable / event mentioned in the PRD:
- Look up in the registry
- If registered with a different value: FAIL — VALUE MISMATCH
- If unregistered: WARN — should be registered or already declared in another PRD

For every dependency listed:
- Confirm the dependency PRD exists. If not, WARN — provisional assumptions about the interface
- Confirm the interface this PRD expects matches what the dependency PRD declares

### 3e: Concept alignment

- The User Goal must serve a JTBD related to the concept's Section 2 persona
- The PRD must not contradict the concept's anti-features (Section 4 Cuts / 5 Anti-features)
- If the system is monetized and the concept said "Free" → FAIL

### 3f: Accessibility floor

For any UI-bearing system, the Accessibility section must explicitly state:
- WCAG 2.2 AA contrast verified
- Min touch target ≥ 44pt iOS / 48dp Android (state which platforms)
- VoiceOver / TalkBack labels and reading order
- Dynamic Type support up to at least Large (iOS) / 200% (Android)
- Reduce-motion alternative for any motion
- No color-only differentiation
- Accessibility test plan reference (manual or automated)

WARN per missing item; FAIL if 3+ items are missing.

### 3g: Mobile platform considerations

Check if the PRD addresses:
- Offline behavior
- Background-foreground transitions
- App-killed-mid-action recovery
- iOS / Android divergences if both are targets
- Push token rotation if push is involved
- IAP receipt validation if monetized
- Permission denial handling for any sensor / camera / location / notification

WARN per missing item that is clearly relevant to this system.

### 3h: Implementation readiness

A PRD passes if a competent engineer could read it and write the spec without re-asking the PM. Specifically:
- No "TBD" or "tbd" or "TODO" left
- Every numerical value has units
- Every external system referenced has at least an interface description (even if the integration ADR is not yet written)
- Acceptance criteria are independently verifiable

---

## Phase 4: Optional Specialist Cross-Check

For UI-heavy PRDs, optionally spawn `Task` to a UX specialist to validate Section 8 (Accessibility) and the User Goal against platform conventions (iOS HIG / Material 3).

For systems with framework-tricky behavior (push, biometrics, payments, background work), optionally spawn the framework specialist to flag implementation realities the PRD missed.

The reviewer remains in charge — specialists return findings, the reviewer integrates them into the verdict.

---

## Phase 5: Build the Verdict

Tally checks:
- 0 FAIL, 0 WARN → **APPROVED**
- 0 FAIL, ≤ 5 WARN → **APPROVED WITH NOTES** (treat as APPROVED but list warns)
- 0 FAIL, >5 WARN → **NEEDS REVISION**
- 1-3 FAIL → **NEEDS REVISION**
- 4+ FAIL → **MAJOR REVISION**

Surface the verdict at the top of the output.

---

## Phase 6: Output

```
# PRD Review: <system>

**Verdict: <APPROVED / APPROVED WITH NOTES / NEEDS REVISION / MAJOR REVISION>**

## Blockers (FAIL)
1. <specific issue> — Section <N>, line <approx>
   Fix: <suggested action>

## Warnings (WARN)
- <issue>

## Confirmed strengths
- <what passed and matters>

## Recommended next steps
- <if APPROVED> Run `/consistency-check` if not already, then `/architecture-review` will use this PRD.
- <if NEEDS REVISION> Run `/design-system retrofit <path>` to address the listed sections, then re-run this review.
- <if MAJOR REVISION> The PRD has too many gaps for line-edits. Recommend re-authoring sections in `/design-system`.
```

Optionally ask: "Write this review to `<prd-path>.review.md`?"

---

## Phase 7: Update Systems Index

If the user agrees, update the system's row in `design/systems-index.md`:
- APPROVED → Status: `Approved`
- NEEDS REVISION / MAJOR REVISION → Status: `In Review`

Ask before writing.

---

## Quality Gates

- The verdict must match the tally rules — no "soft passes" if FAILs exist.
- Every blocker has a section reference and a suggested fix.
- The review never edits the PRD itself.
- The review is opinionated about Accessibility and Edge Cases — these are the most-skipped sections in mobile PRDs and the cheapest gaps to flag here vs. fix in production.

---

## Examples

PRD `auth.md`: 0 FAIL, 2 WARN (offline edge case missing, dynamic type not mentioned).
- Verdict: APPROVED WITH NOTES.
- Blockers: none.
- Warnings: missing offline edge case, missing dynamic type assertion.
- Recommend: add the two warns; PRD is good to ship.

PRD `paywall.md`: 4 FAIL (no acceptance criteria, no accessibility, missing receipt-validation edge case, missing iOS / Android divergence section).
- Verdict: MAJOR REVISION.
- Recommend: re-author Sections 4, 7, 8, 9 in `/design-system`.

---

## Constraints

- Run in a fresh session — never the same session that wrote the PRD.
- Read-only on the PRD itself; only the systems index and optional review-snapshot file are written.
- The reviewer does not silently fix problems — surfaces them so the author can correct.
