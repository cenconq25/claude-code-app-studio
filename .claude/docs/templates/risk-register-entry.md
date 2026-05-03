<!--
name: risk-register-entry
purpose: A single row in the project's risk register. One file per risk so it can be linked from sprint plans, milestone reviews, and ADRs. Status is updated weekly.
consumed-by: /sprint-plan, /milestone-review, /retrospective, /launch-checklist
placeholders:
  - {{risk_id}}
  - {{title}}
  - {{owner}}
  - {{opened_date}}
-->

# RISK-{{risk_id}}: {{title}}

| Field | Value |
|-------|-------|
| Owner | {{owner}} |
| Opened | {{opened_date}} |
| Last reviewed | {{last_reviewed}} |
| Status | Open / Mitigating / Accepted / Closed / Realised |
| Category | Technical / Schedule / Store-policy / Privacy-regulatory / Vendor / Capacity / Quality |

## Description

What is the risk? What would happen if it materialised? Avoid framing as "we
will fail to do X" — describe the underlying mechanism.

## Likelihood

| Score | Definition | This risk |
|-------|------------|-----------|
| L (Low) | <10% chance over horizon | |
| M (Medium) | 10–40% | |
| H (High) | >40% | |

Selected: **L / M / H** — rationale:

## Impact

| Dimension | L | M | H | This risk |
|-----------|---|---|---|-----------|
| User-facing breakage | minor cosmetic | feature unavailable | core flow broken | |
| Schedule | <1 week slip | 1–4 week slip | >4 week slip | |
| Store standing | none | warning | rejection / pulled | |
| Revenue | <1% MRR | 1–10% MRR | >10% MRR | |

Selected: **L / M / H** — rationale:

## Risk Score

`Likelihood × Impact = Score`. Low/Low = 1, High/High = 9.

| Score |  |
|-------|--|
| Computed | |
| Threshold for executive escalation | ≥ 6 |

## Triggers

Observable signals that this risk is materialising. List them so monitoring
can detect them.

- {{signal}}
- {{signal}}

## Mitigation Plan

What are we doing to reduce likelihood OR impact?

| Action | Owner | Due | Reduces | Status |
|--------|-------|-----|---------|--------|
| | | | Likelihood / Impact | |

## Contingency Plan

If the risk does materialise, what is the response? This is different from
mitigation — mitigation prevents, contingency contains.

- Step 1
- Step 2
- Communication: who tells whom?

## Acceptance Decision

If we are choosing to accept this risk rather than mitigate:

- Accepted by: {{name}}, {{name}}
- Accepted on: {{date}}
- Rationale:
- Re-review date:

## Linked Items

- ADRs: ADR-NNNN
- Stories: STORY-NN
- Incidents (if realised): INC-NN

## History

| Date | Status change | Note |
|------|--------------|------|
| {{opened_date}} | Opened | |
