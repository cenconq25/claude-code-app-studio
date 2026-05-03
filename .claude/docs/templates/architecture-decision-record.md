<!--
name: architecture-decision-record
purpose: Capture a single significant technical decision for the mobile app — why it was made, what was rejected, and how to verify it.
consumed-by: /architecture-decision, /architecture-review, /create-control-manifest, /propagate-design-change
placeholders:
  - {{adr_id}}
  - {{title}}
  - {{date}}
  - {{decision_makers}}
  - {{framework}}
  - {{platform}}
  - {{summary}}
-->

# ADR-{{adr_id}}: {{title}}

## Status

Proposed | Accepted | Deprecated | Superseded by ADR-XXXX

## Date

{{date}}

## Last Verified

{{date}} — when this ADR was last reconfirmed against current platform / SDK
versions. Re-verify after any framework/SDK upgrade.

## Decision Makers

{{decision_makers}}

## Summary

Two sentences. Name the system, the problem, and the chosen approach so a
skill can decide whether to read the full ADR.

## Framework & Platform Compatibility

| Field | Value |
|-------|-------|
| **Primary Framework** | React Native / Flutter / Swift+SwiftUI / Kotlin+Compose |
| **iOS Deployment Target** | e.g. iOS 16.0 |
| **Android Deployment Target** | e.g. API 29 / Android 10 |
| **Domain** | Networking / Persistence / Navigation / Auth / Payments / Push / Telemetry / Build / UI / Performance |
| **Knowledge Risk** | LOW (in training) / MEDIUM (verify) / HIGH (post-cutoff, must verify) |
| **References Consulted** | Apple HIG section, Material 3 docs, RN/Flutter release notes, SDK docs |
| **Post-cutoff APIs Used** | List or "None" |
| **Verification Required** | Concrete behaviours to test, or "None" |

### Cross-framework Impact Table

If the decision is made in one framework but affects others (e.g. choosing a
shared Rust core for RN+Flutter+native), capture it here.

| Surface | Affected? | Notes |
|---------|-----------|-------|
| iOS native (Swift) | Y / N | |
| Android native (Kotlin) | Y / N | |
| React Native | Y / N | |
| Flutter | Y / N | |
| Web companion | Y / N | |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-NNNN (must be Accepted first) / None |
| **Enables** | ADR-NNNN / None |
| **Blocks** | Epic / story name / None |
| **Ordering Note** | |

## Context

### Problem Statement

What forces this decision? What is the cost of NOT deciding?

### Current State

How does the app behave today? What hurts?

### Constraints

- Performance: cold start budget, frame budget, binary size budget
- Privacy / regulatory: ATT, GDPR, COPPA, EU DMA
- Store policy: App Store Review Guidelines section, Play policy
- Team capability: who can maintain this?
- Cost: SDK licensing, infrastructure

## Decision

The choice in plain language. Reference exact APIs, libraries, versions where
possible.

### Why this choice

- Reason 1
- Reason 2

## Consequences

### Positive

- Benefit 1
- Benefit 2

### Negative / Trade-offs

- Cost 1
- Cost 2

### Neutral

- Side effect 1

## Alternatives Considered

### Alternative A: {{name}}

- What it is
- Pros
- Cons
- Why rejected

### Alternative B: {{name}}

- What it is
- Pros
- Cons
- Why rejected

## Related ADRs

- ADR-NNNN — {{relationship}}

## Verification Plan

How will we know this decision is working in production?

- [ ] Unit tests covering: {{areas}}
- [ ] Integration test on device matrix: {{devices}}
- [ ] Telemetry signal: {{metric}} stays within {{threshold}}
- [ ] Manual smoke on TestFlight / Play Internal track
- [ ] Re-verify after next framework / SDK upgrade

## Notes

Free-form supporting research, links, benchmarks, screenshots.
