---
name: balance-check
description: "Analyze pricing tiers, paywall configs, A/B test variants, and feature-flag values for outliers, broken funnels, dominant variants, and monetization imbalance. Use after editing pricing, paywall copy, or any growth-experiment config."
argument-hint: "[--scope=pricing|experiments|flags|all]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion
model: sonnet
---

# Balance Check

Pricing and growth experiments are the app's economic balance. This
skill reads the configuration, applies sanity checks (outliers,
illogical funnels, dominant variants, missing fallbacks), and flags
issues before they ship to production.

---

## Phase 1: Locate Config

Read in parallel:

- Pricing config files — typical paths: `assets/data/pricing.json`,
  `src/config/pricing.ts`, `lib/config/pricing.dart`,
  `Resources/pricing.plist`, `res/raw/pricing.xml`.
- Paywall variant config — `assets/paywalls/*.json`,
  `src/config/paywalls/*`.
- Feature flags — local defaults file, plus the cloud provider
  reference (Firebase Remote Config, LaunchDarkly, ConfigCat,
  Statsig). The cloud values may live in `production/configs/`.
- Experiment definitions — `production/experiments/*.md` or whatever
  the project uses.
- The PRDs that govern monetization — `design/prd/monetization.prd.md`,
  `design/prd/paywall.prd.md`.

If nothing is found, ask the user to point at the relevant file or
folder.

---

## Phase 2: Pricing Sanity

For each pricing tier configuration, check:

- [ ] Currency is set per supported region.
- [ ] Each price has a fallback for App Store / Play Store SKU.
- [ ] Annual prices are at most 12x monthly; if higher, surface as a
      bug (probably an inverted unit). If lower than 8x monthly, the
      annual is essentially "always buy annual" — flag dominance.
- [ ] Trial duration is reasonable (1-30 days). 0-day trials should
      be removed unless intentional.
- [ ] Discount percentages match parent vs current price arithmetic
      (no `was $9.99 / now $14.99` type errors).
- [ ] Each tier maps to a defined SKU on both App Store Connect and
      Play Console (cross-reference the SKU IDs).
- [ ] No tier is reachable only through deprecated paths (paywall
      variant the app no longer renders).
- [ ] Localized prices are not silently in USD — confirm `priceLocale`
      handling.

---

## Phase 3: Paywall Variant Audit

If multiple paywall variants exist, build a comparison table:

| Variant | Headline | CTA | Price tiers shown | Trial | Default for cohort |

Check:

- [ ] No two variants have identical render and cohort. (Suggests dead
      experiment.)
- [ ] Each variant ID is referenced in the experiment registry.
- [ ] Each variant has localized strings present (cross-check with
      `/localize`).
- [ ] CTA copy is differentiated; if identical CTAs across variants,
      the experiment cannot measure CTA-driven impact.

---

## Phase 4: Experiment Health

Read experiment definitions. Per experiment:

- [ ] Hypothesis is stated.
- [ ] Primary metric is named.
- [ ] Sample size or duration is specified.
- [ ] Stop conditions are defined (early-stop on harm, max duration).
- [ ] Variant allocations sum to 100%.
- [ ] No two active experiments target the same primary metric without
      coordinated layering — surface conflict if found.
- [ ] No experiment depends on a feature flag that is also being
      modified by another active experiment.

Surface:

- Dominant-variant risk: when historical telemetry (if accessible at
  `production/analytics/`) shows one variant outperforming the others
  by > 30% on the primary metric, flag the experiment for early
  promotion.
- Long-tail risk: experiments running > 30 days without action.

---

## Phase 5: Feature Flag Hygiene

For each flag in the local defaults:

- [ ] Default value matches what the cloud config will fall back to
      when offline.
- [ ] No flag toggles risky behavior with a default of ON unless that
      is explicitly intended.
- [ ] No flag is referenced in code but missing from the defaults
      file (would crash on offline first launch).
- [ ] No flag exists in defaults but unused in code (dead flag — open
      a story to remove).
- [ ] Each flag is owned (annotation or doc comment with team name).

Render dead-flag list and ask user whether to clean up.

---

## Phase 6: Funnel Sanity

Walk the monetization funnel against the PRD:

1. Trigger (onboarding end, content gate, etc.).
2. Paywall variant rendered.
3. Tier selected.
4. Purchase attempted.
5. Purchase confirmed.
6. Receipt validated server-side.
7. Entitlement granted.

For each step, confirm the analytics event exists (grep for the named
events) and is wired. Missing events break attribution.

If the funnel skips server-side receipt validation, that is P0 (revenue
risk).

---

## Phase 7: Render Report

```markdown
# Balance Check — [date]

## Pricing Findings
| Severity | Finding | Where |

## Paywall Variants
| Variant | Active | Issues |

## Experiments
| Name | Status | Findings | Recommend |

## Feature Flags
- Dead flags: [list]
- Mismatched defaults: [list]
- Unowned flags: [list]

## Funnel
- Missing analytics events: [list]
- Server-side receipt validation: [present | MISSING]

## Recommendations
- [P0/P1/P2 with action]

## Verdict: BALANCED / IMBALANCE / BLOCKING
```

Ask before writing to `production/balance/balance-check-[date].md`.

---

## Phase 8: Update State

Append to `production/session-state/active.md`:

```
## Balance Check — [date]
- P0 issues: [count]
- Dominant-variant flags: [count]
- Dead flags: [count]
- Verdict: [verdict]
- Report: [path]
- Next: [/create-stories for P0/P1, or proceed]
```

---

## Quality Gates / PASS-FAIL

- BALANCED — pricing is internally consistent, no unowned flags, no
  funnel events missing, server-side receipt validation present.
- IMBALANCE — non-blocking issues exist (dead flags, dominant variants
  not yet promoted).
- BLOCKING — pricing arithmetic errors, missing receipt validation,
  flag references that crash offline launch, or experiments with
  invalid allocations.

---

## Examples

**Example 1 — Pre-release pricing tweak:**
User reduces annual price below 8x monthly. Skill flags dominance:
"Most users will find no reason to pick monthly. Confirm intent."
User confirms — promotion strategy. Verdict: IMBALANCE (with note).

**Example 2 — Dead experiment cleanup:**
Detects 3 paywall variants no longer referenced by any active
experiment. User approves removal of variants and config simplification.
Two follow-up stories filed.

---

## Next Steps

- BLOCKING -> open stories via `/create-stories`, fix before release.
- IMBALANCE -> schedule cleanup in next sprint via `/sprint-plan`.
- BALANCED -> include verdict in `/launch-checklist`.
