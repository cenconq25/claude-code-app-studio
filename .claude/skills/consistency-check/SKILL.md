---
name: consistency-check
description: "Read-only audit that scans all PRDs against the entity registry and detects cross-doc inconsistencies — same entity with different values, same configurable value with different defaults, same formula with different variables. Use when multiple PRDs are in flight to catch drift before /review-all-prds runs."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Glob, Grep
model: sonnet
---

# Consistency Check

Compares what each PRD claims about shared entities, values, and formulas against the registry. Pure read — never writes a file. Produces a structured findings list the user can resolve with `/design-system retrofit ...` or `/propagate-design-change`.

---

## Purpose / When to Run

Run when:
- Three or more PRDs exist
- A PRD has just been authored that overlaps with prior PRDs
- Before `/review-all-prds` (which is more expensive)

Distinct from `/review-all-prds`: this skill checks **values** for drift; the holistic review checks **design intent** for contradictions. Run consistency-check first — it is much cheaper.

## Inputs

- `design/registry/entities.yaml`
- All `design/prd/*.md`
- Optional: `design/systems-index.md`

## Outputs

- Printed findings. No file writes.

---

## Phase 1: Load the Registry

Read `design/registry/entities.yaml`. The registry is the source of truth for cross-PRD facts. Each entry has:
- `name`
- `type` (entity / configurable / formula / constant / event / endpoint)
- `value` or `attributes`
- `source` (the PRD that owns the canonical definition)
- `referenced_by` (other PRDs that reference it)

If the registry does not exist, stop:
> "No `design/registry/entities.yaml` found. The registry is built incrementally as `/design-system` runs. Cannot consistency-check without it. Either author more PRDs or run `/design-system retrofit ...` to populate the registry from existing PRDs."

If the registry has fewer than 5 entries, warn that meaningful checks need ≥5 entries — the skill will run but findings will be sparse.

---

## Phase 2: Index Every PRD

For each `design/prd/*.md`:
1. Read the file.
2. Identify which registry entries it references — grep for each entry's `name` in the file body.
3. For each referenced entry, extract the **value** the PRD claims (from sections 3 Detailed Requirements, 6 Configurable Values, and any inline tables).

Build a per-entry table:
```
entry: rate_limit_login_attempts
  registry value: 5 (per minute)
  source: design/prd/auth.md
  referenced in:
    design/prd/auth.md → 5 per minute ✓
    design/prd/account-recovery.md → 3 per minute ✗ MISMATCH
    design/prd/security.md → "5 attempts" ✓
```

Use grep judiciously — read each PRD once, scan for known entry names from the registry, capture surrounding context.

---

## Phase 3: Classify Findings

For each entry referenced in 2+ PRDs:

- **MATCH** — all PRDs agree with the registry. No finding.
- **MINOR DRIFT** — same value but different units or notation (e.g., "5 per minute" vs. "5/min"). Cosmetic. Reportable.
- **VALUE MISMATCH** — PRDs claim different values. **HIGH** finding.
- **REGISTRY DRIFT** — registry value differs from the source PRD's current text. The PRD changed without registry update. **HIGH** finding.
- **ORPHAN REFERENCE** — a PRD references something that looks like a registry entry name but is not registered. **MEDIUM** finding (may be a typo, may need registration).

Also detect cross-PRD-only patterns (registry-independent):
- **NAME COLLISION** — two PRDs define different things with the same name. **HIGH** finding.
- **INTERFACE DISAGREEMENT** — PRD A says it emits event `foo`, PRD B says it emits event `Foo` (case mismatch) or with different payload shape. **HIGH** finding.
- **TIMING DISAGREEMENT** — PRD A says "show paywall after 3 sessions", PRD B says "after 5". **HIGH** if neither references the registry.

---

## Phase 4: Print the Findings

Output format:

```
# Consistency Check

PRDs scanned: <N>
Registry entries: <N>
Findings: <count by severity>

## HIGH

### 1. VALUE MISMATCH — `rate_limit_login_attempts`
- Registry says: `5 per minute` (source: design/prd/auth.md)
- design/prd/auth.md: `5 per minute` ✓
- design/prd/account-recovery.md: `3 per minute` ✗

Resolution suggestions:
- If 5 is correct → update `design/prd/account-recovery.md` Section 3
- If 3 is correct → update registry source PRD and run `/propagate-design-change`

### 2. INTERFACE DISAGREEMENT — analytics event `paywall_shown`
- design/prd/paywall.md: emits with `{ trigger: string, user_segment: string }`
- design/prd/analytics.md: expects `{ trigger: string, segment: string, ts: number }`

Field name mismatch (`user_segment` vs `segment`) and missing `ts`.

## MEDIUM

### 3. ORPHAN REFERENCE — `feature_flag_paywall_v2`
- Referenced in: design/prd/paywall.md, design/prd/onboarding.md
- Not registered.

Either register it (run `/design-system retrofit design/prd/paywall.md` to push to registry) or rename to a registered flag.

## MINOR

### 4. UNIT DRIFT — `cache_ttl_user_profile`
- design/prd/profile.md: `300 seconds`
- design/prd/auth.md: `5 minutes`
- Same value, different notation. Standardize.

## Verdict
[CLEAN | DRIFT FOUND] — <count> HIGH, <count> MEDIUM, <count> MINOR.
```

If zero HIGH findings, the verdict is `CLEAN`. Otherwise `DRIFT FOUND`.

---

## Phase 5: Recommend Resolution Path

Below the findings list, print a short next-action block:

```
## Recommended next actions

For each HIGH finding:
- Decide on the canonical value
- Update the non-canonical PRD using `/design-system retrofit <path>` or manual Edit
- Run `/propagate-design-change <changed-prd>` to surface downstream impact
- Re-run `/consistency-check` to verify resolution

After all HIGH are resolved, run `/review-all-prds` for the holistic design check.
```

Do not run any of these — the user decides.

---

## Edge Cases

- **Registry is empty**: stop. The skill needs at least one entry to check anything.
- **Two registry entries with the same name**: that is itself a HIGH finding — the registry is corrupt. Surface it.
- **PRD references a registry entry inside a code block or example**: still count as a reference but lower confidence. Flag as MINOR if the only reference.
- **Whitespace or punctuation differences**: do not flag. Compare semantic values, not string equality.

---

## Quality Gates

- Every HIGH finding includes: registry path, conflicting PRD paths, resolution suggestions.
- The verdict is unambiguously CLEAN or DRIFT FOUND.
- No false positives on cosmetic differences (units, capitalization in prose).
- Read-only — no file writes ever.

---

## Examples

5 PRDs, registry has 23 entries.
- Output: 1 HIGH (rate-limit mismatch), 2 MEDIUM (orphan references), 3 MINOR (unit drift). Verdict: DRIFT FOUND.

12 PRDs, registry has 60 entries.
- Output: 0 findings. Verdict: CLEAN.

3 PRDs, all reference an unregistered analytics event:
- Output: 3 MEDIUM (each PRD with the orphan reference). Recommend running `/design-system retrofit design/prd/analytics.md` to register the event.

---

## Constraints

- Read-only — never writes
- Cross-document only — does not check intra-document consistency (that is `/prd-review`'s job)
- Does not evaluate design quality — only value-level drift
