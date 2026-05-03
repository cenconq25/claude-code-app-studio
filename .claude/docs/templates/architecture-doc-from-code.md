<!--
name: architecture-doc-from-code
purpose: Reverse-engineered architecture description produced from existing source. Used when joining a brownfield project or reconstructing missing ADRs. Markers OBSERVED / INFERRED / GAP keep the author honest about confidence level.
consumed-by: /reverse-document, /adopt, /architecture-review
placeholders:
  - {{adr_id}}
  - {{title}}
  - {{author}}
  - {{date}}
  - {{repo_commit}}
  - {{files_examined}}
marker-legend:
  - "[OBSERVED]" — directly visible in the code or build artefacts
  - "[INFERRED]" — best guess from observation; mark for confirmation
  - "[GAP]" — necessary information could not be determined
-->

# ADR-{{adr_id}} (from code): {{title}}

> Reverse-documented {{date}} by {{author}} from commit `{{repo_commit}}`.
> Every claim is tagged [OBSERVED], [INFERRED], or [GAP]. Confirm INFERRED
> claims with a maintainer before treating this as Accepted.

## Status

Reverse-documented — pending review

## Source Inputs

| Source | Path | Confidence |
|--------|------|------------|
| Source files | {{files_examined}} | OBSERVED |
| Build config | `app/build.gradle.kts`, `ios/Podfile` | OBSERVED |
| Package manifest | `package.json`, `pubspec.yaml`, `Podfile.lock` | OBSERVED |
| Runtime logs | | OBSERVED / GAP |
| Maintainer interview | | OBSERVED / GAP |

## Framework & Platform Compatibility

| Field | Value | Marker |
|-------|-------|--------|
| Framework | | [OBSERVED] |
| iOS deployment target | | [OBSERVED] (Podfile / project.pbxproj) |
| Android minSdk / targetSdk | | [OBSERVED] (build.gradle) |
| RN / Flutter version | | [OBSERVED] (package.json / pubspec.lock) |
| Major SDKs in use | | [OBSERVED] |
| Knowledge risk | | [INFERRED] |

## Context

### Problem the code appears to solve

[INFERRED] from naming, comments, and call sites: …

### Current behaviour

[OBSERVED] in {{file_path}}:{{line}}: …

### Why the original team chose this approach

[GAP] — original rationale not recorded. Candidate hypotheses:

- Hypothesis 1
- Hypothesis 2

## Decision (as implemented)

[OBSERVED] The code does X by Y at Z.

- Entry points: {{file:line}}
- Key abstractions: {{class_or_function}}
- Data flow: source → transform → sink

## Consequences (observable)

### Positive [OBSERVED]

- …

### Negative [OBSERVED]

- …

### Unknown [GAP]

- …

## Alternatives (not visible in code)

[GAP] No record of alternatives considered. Author should ask the team.

## Related ADRs

- ADR-NNNN — relationship [INFERRED]

## Framework Compatibility Notes

| Surface | Status | Marker |
|---------|--------|--------|
| iOS | | |
| Android | | |
| RN bridge / Flutter platform channel | | |
| Tests present | Y / N | [OBSERVED] |

## Verification Plan

To confirm INFERRED claims and close GAPs:

- [ ] Maintainer interview: confirm hypothesis on rationale
- [ ] Run on device matrix: {{devices}}
- [ ] Add telemetry to verify assumed behaviour
- [ ] Write missing tests for: {{areas}}

## Open Questions for Original Author

- [ ] {{question}}
- [ ] {{question}}

## Notes

Anything else worth recording for future contributors.
