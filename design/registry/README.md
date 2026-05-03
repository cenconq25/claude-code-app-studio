# Design Registry

The design-side registry, kept inside `design/` so designers can edit it
without leaving their work tree. It mirrors a subset of
`docs/registry/` — the entries that are design-owned (screens,
analytics events, feature flags, design tokens) live here, and
engineering-owned entries (data models, API endpoints) live there.

## Files

| File | Holds | Owner |
|---|---|---|
| `screens.md` | Canonical screen names with PRD link, nav slot, and slug | `product-designer` |
| `flows.md` | Named flows with entry points and outcomes | `ux-designer` |
| `analytics-events.md` | Every user-facing event the product emits | `analytics-engineer` co-owned with PRD authors |
| `feature-flags.md` | Remote-config and local flags with defaults | `mobile-architect` co-owned with PRD authors |
| `design-tokens.md` | Color, type, spacing, motion, haptics tokens | `visual-design-director` |
| `glossary.md` | Domain vocabulary and banned terms | `content-strategist` |

## Why a Mirror?

The registry has two audiences. Engineers need data-model and
API-endpoint entries during architecture work; designers need
screen-name and event-name entries during PRD authoring. Splitting the
authoring surface keeps each audience focused while keeping the
canonical authority in one place per entry.

`/consistency-check` reads both and surfaces drift. Conflicts are
resolved by:

1. The owner declared in this table makes the call.
2. PRDs that still use the old name are flagged for revision.
3. ADRs that still reference the old name require an addendum.

## Entry Format

Use Markdown tables. Example:

```markdown
| Screen Name        | Slug          | Nav Slot      | PRD                                |
|--------------------|---------------|---------------|------------------------------------|
| SignInScreen       | sign-in       | auth-modal    | design/prd/email-signin.md         |
| OrderHistoryScreen | order-history | profile-tab   | design/prd/order-history.md        |
```

For analytics events:

```markdown
| Event              | Trigger                                 | Required Properties                  | Source PRD                |
|--------------------|-----------------------------------------|---------------------------------------|---------------------------|
| sign_in_completed  | After successful sign-in                | method (email/oauth), is_first_time   | design/prd/email-signin.md|
| paywall_shown      | Paywall component mounts                | placement (onboarding/upsell)         | design/prd/paywall.md     |
```

Keep entries terse. The PRD is the source of truth for behaviour; the
registry is the source of truth for *names*.
