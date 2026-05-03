<!--
name: user-test-report
purpose: Beta test or moderated usability study report. Captures study goals, methodology, participants, ranked findings, severity, supporting quotes, and recommendations. Authored by user-researcher; consumed by product, design, engineering.
consumed-by: /design-review, /retrospective, /milestone-review
placeholders:
  - {{study_id}}
  - {{title}}
  - {{author}}
  - {{study_date_range}}
  - {{build_tested}}
-->

# User Test Report — {{title}}

| Field | Value |
|-------|-------|
| Study ID | {{study_id}} |
| Author | {{author}} |
| Dates | {{study_date_range}} |
| Build tested | {{build_tested}} |
| Format | Moderated remote / Moderated in-person / Unmoderated remote / Public beta |
| Status | Draft / Reviewed / Final |

## Goals

What questions did this study set out to answer? Phrase as questions, not
hypotheses, so findings can fall out clearly.

1. {{question}}
2. {{question}}
3. {{question}}

## Methodology

- Recruitment criteria:
- Number of participants: {{n}}
- Compensation: {{amount}}
- Devices used: own / lab-provided
- Platforms: iOS / Android / both
- Tasks given (script available in appendix)
- Recording: video / audio / screen / consent obtained

## Participants

| ID | Persona match | Platform | Device | Tenure with app | Notes |
|----|---------------|----------|--------|------------------|-------|
| P1 | | | | | |
| P2 | | | | | |

## Top Findings (ranked)

Stack-ranked by severity × frequency. Present the top 3 prominently — readers
remember those.

### Finding 1 — {{headline}}

- **Severity**: P0 (blocks core flow) / P1 (frustrates many) / P2 (minor) / P3 (cosmetic)
- **Frequency**: {{n}}/{{total}} participants
- **What we observed**: {{description}}
- **Why it matters**: {{impact}}
- **Recommendation**: {{action}}
- **Supporting quote**: > "{{quote}}" — P{{n}}
- **Linked screen / flow**: `flow-spec.md#section`

### Finding 2 — {{headline}}

- ...

### Finding 3 — {{headline}}

- ...

## All Issues

A complete list, severity-ranked.

| Severity | Issue | Frequency | Suggested action | Owner |
|----------|-------|-----------|------------------|-------|
| P0 | | | | |
| P1 | | | | |
| P2 | | | | |
| P3 | | | | |

## Positive Findings

What worked well. Important to capture so we don't accidentally regress.

- {{positive}}
- {{positive}}

## Behavioural Patterns

Patterns observed across participants that aren't issues per se.

- {{pattern}}

## Quotes Library

Every quote captured, with consent tag. Use to fuel future copy work.

| Participant | Quote | Topic |
|-------------|-------|-------|
| P{{n}} | "{{quote}}" | {{topic}} |

## Recommendations

Translated into actionable next steps. Rank by ROI.

| Priority | Recommendation | Effort | Expected impact |
|----------|----------------|--------|------------------|
| Must | | S / M / L | |
| Should | | | |
| Could | | | |

## Limitations

Be honest about what this study cannot tell us.

- Sample size: {{n}} is {{adjective}} for generalisation
- Self-selection: {{description}}
- Build instability: any bugs that affected results

## Next Studies

What questions opened that need follow-up research?

- {{question}}

## Appendix

- Task script
- Screener questions
- Consent form
- Raw notes / transcripts (link)
