---
paths:
  - "prototypes/**"
---

# Prototype Code Rules (Relaxed Standards)

Owner: `prototyper`. Prototypes are throwaway code whose only purpose is
to validate a hypothesis. The full coding standards are intentionally
relaxed here — but a few rules still apply because prototypes that have
hidden costs are worse than no prototypes at all.

## Required

- Every prototype directory has a `README.md` (or `CONCEPT.md`) at the
  top level stating:
  - The hypothesis being tested.
  - The success criterion.
  - The expected lifespan ("delete after demo on 2026-05-30").
  - The framework and language used.
- Hypothesis and outcome are recorded back into the relevant PRD or
  product brief once the prototype is evaluated.
- Hard-coded credentials, API keys, and secrets are absolutely forbidden
  — even in prototypes. Use a `.env.example` placeholder.
- The prototype is **isolated** from `src/`. No imports from the
  production codebase, no shared dependencies that could leak rules.

## Allowed (relaxed from the universal rules)

- Hard-coded copy, magic numbers, and inline literals.
- Skipping doc comments.
- Skipping tests.
- One-off styling not anchored to design tokens.
- Sloppy error handling (provided the prototype's `README.md` notes the
  gap).
- Force-unwrapping (`!` / `!!`) for known-safe values.

## Forbidden

- Network calls to production endpoints — use a fixture or staging.
- Touching production analytics or telemetry endpoints.
- Touching production payment / IAP sandboxes without sandbox flags.
- Importing from `src/` — prototypes never establish dependencies on
  production code.
- Persisting on-device state into a path the production app reads.

## When a Prototype Is Promoted

A successful prototype is rebuilt — not lifted — into `src/`. The
production rebuild:

1. Re-applies the universal `mobile-code.md` rules.
2. Re-applies the framework-specific rules.
3. Adds tests.
4. Replaces hard-coded values with tokens / config.
5. Adds doc comments.
6. Files an ADR for any system that survived from the prototype.

Once the production version lands, the prototype is deleted (or moved to
`prototypes/archived/` if its README has historical value).

## Example README

```markdown
# Prototype: Push Permission Pre-Prompt

**Hypothesis**: A pre-permission rationale screen lifts opt-in rate
from 35% (current OS-default) to >55%.

**Success criterion**: Opt-in rate >= 55% across 100 simulated users
in usability testing.

**Lifespan**: Delete by 2026-06-15.

**Stack**: React Native (Expo) — same as production.

**Outcome (filled in after evaluation)**: TBD
```
