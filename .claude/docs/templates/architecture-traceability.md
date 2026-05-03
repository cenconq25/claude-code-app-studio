<!--
name: architecture-traceability
purpose: Master matrix mapping every PRD requirement (TR-ID) to the ADR(s) that govern it, the story or stories that implement it, and the test that proves it. Single source of truth for "did we actually build what we said we would?"
consumed-by: /architecture-review, /create-stories, /qa-plan, /milestone-review, /launch-checklist
placeholders:
  - {{project_name}}
  - {{generated_date}}
  - {{milestone}}
-->

# Architecture Traceability Matrix — {{project_name}}

| Field | Value |
|-------|-------|
| Generated | {{generated_date}} |
| Milestone | {{milestone}} |
| Source PRDs | `design/prd/*.md` |
| Source ADRs | `docs/architecture/adr/*.md` |
| Source stories | `production/sprints/*/stories/*.md` |

## Legend

- **TR-ID**: Technical requirement identifier from a PRD (e.g. `TR-AUTH-001`)
- **Status**: `Open` / `Designed` / `In Progress` / `Implemented` / `Verified`
- **Coverage**: `Full` / `Partial` / `None`

## Matrix

| TR-ID | Requirement (one line) | PRD | Governing ADR(s) | Story / Epic | Test Evidence | Status | Coverage |
|-------|------------------------|-----|------------------|--------------|---------------|--------|----------|
| TR-001 | App cold-starts in <1.5s on iPhone 12 | `prd/onboarding.md` | ADR-0007 | STORY-042 | `tests/perf/cold_start_test.swift` | Verified | Full |
| TR-002 | Push notifications respect ATT consent | `prd/notifications.md` | ADR-0011, ADR-0014 | STORY-051 | `production/qa/evidence/STORY-051.md` | Implemented | Full |
| TR-003 | | | | | | | |

## Coverage Summary

| Status | Count | % of total |
|--------|-------|------------|
| Verified | | |
| Implemented (untested) | | |
| In Progress | | |
| Designed (no story) | | |
| Open (no ADR) | | |

## Gaps Detected

### Untraced PRD requirements (no ADR)

- TR-NNN — {{description}} — owner: {{name}}

### ADRs with no implementing story

- ADR-NNNN — {{title}} — created: {{date}}

### Stories with no governing ADR

- STORY-NN — {{title}} — risk: agent acted without architectural guidance

### Stories marked Done with no test evidence

- STORY-NN — {{title}} — blocking gate violation

## Cross-cutting Concerns Coverage

| Concern | TR-IDs | Coverage |
|---------|--------|----------|
| Accessibility (VoiceOver / TalkBack) | | |
| Localization (RTL, i18n) | | |
| Privacy (ATT, GDPR, COPPA) | | |
| Offline behaviour | | |
| Cold-start performance | | |
| Crash-free sessions | | |
| Deep linking | | |
| In-app purchase / subscription | | |

## Action Items

- [ ] {{owner}}: write ADR for TR-{{nnn}} by {{date}}
- [ ] {{owner}}: add test evidence for STORY-{{nn}} by {{date}}
- [ ] {{owner}}: create story for ADR-{{nnnn}} by {{date}}

## Notes

Free-form context — recent design pivots, deferred work, watch-list items.
