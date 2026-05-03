<!--
name: test-evidence
purpose: Per-story test evidence record. Links automated test runs, screenshots, walkthrough docs, and sign-offs. The artefact a story needs to be moved to Done.
consumed-by: /story-done, /test-evidence-review, /qa-plan, /smoke-check
placeholders:
  - {{story_id}}
  - {{title}}
  - {{author}}
  - {{date}}
-->

# Test Evidence — {{story_id}}: {{title}}

| Field | Value |
|-------|-------|
| Story | {{story_id}} |
| Author | {{author}} |
| Date | {{date}} |
| Story type | Logic / Integration / Visual / UI / Config |
| Gate level for this type | BLOCKING / ADVISORY |
| Verdict | PASS / FAIL / INCOMPLETE |

## Acceptance Criteria

Copy each AC from the story file. For each, state whether it is met and link
the evidence.

| AC | Description | Met? | Evidence |
|----|-------------|------|----------|
| AC-1 | | Y / N / Partial | link |
| AC-2 | | | |

## Automated Tests (if Logic / Integration)

| File | Test name | Last run | Result |
|------|-----------|----------|--------|
| `tests/unit/...` | `test_...` | CI run #{{n}} | PASS / FAIL |

CI run link: {{ci_url}}

### Coverage notes

- Lines covered: {{percent}}%
- Edge cases asserted:
- Edge cases NOT asserted (and why):

## Manual Walkthrough (if UI / Visual)

Step-by-step verification with device and OS recorded.

| Step | Expected | Actual | Pass? |
|------|----------|--------|-------|
| 1 | | | Y / N |

### Devices walked through

| Device | OS | Build | Tester |
|--------|----|----|--------|
| | | {{build_number}} | |

## Screenshots / Recordings

Place artefacts in `production/qa/evidence/{{story_id}}/`. Reference here.

| File | Caption |
|------|---------|
| `iPhone-15-light.png` | Default state, light mode |
| `iPhone-15-dark.png` | Default state, dark mode |
| `iPhone-15-dt-xxl.png` | Dynamic Type accessibility XXL |
| `Pixel-8-tb-flow.mp4` | TalkBack walkthrough |

## Accessibility Verification

- [ ] VoiceOver flow recorded
- [ ] TalkBack flow recorded
- [ ] Dynamic Type 200% spot-checked
- [ ] Reduce Motion respected
- [ ] Touch targets ≥ 44pt / 48dp verified

## Telemetry Verification

For features with new analytics events.

| Event | Fired in test? | Properties correct? | Notes |
|-------|----------------|---------------------|-------|
| | Y / N | Y / N | |

## Edge Cases Verified

Reference the PRD's Edge Cases section. Each row should appear here.

| Case | Behaviour observed | Pass? |
|------|---------------------|-------|
| Offline | | |
| Permission denied | | |
| Token expired | | |
| Backgrounded mid-flow | | |
| Locale RTL | | |

## Sign-off

| Role | Name | Approved | Date |
|------|------|----------|------|
| QA tester | | | |
| QA lead | | | |
| Design lead (Visual stories only) | | | |
| Engineering lead | | | |

## Open Issues Found

If any issue surfaced during testing, file a bug and link below. Story may
still pass if issues are P2 or lower.

| Bug | Severity | Status |
|-----|----------|--------|
| BUG-NN | P0 / P1 / P2 / P3 | Open / Fixed / Deferred |
