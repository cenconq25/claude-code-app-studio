# Entity Registry

The registry is the single source of truth for cross-document names. When
two PRDs disagree on what to call something, the registry wins, and the
older PRD is updated. Without a registry, naming drift compounds: the
home screen becomes "feed" in one PRD and "stream" in another, the user
account is "profile" in one and "me" in another, and refactors stop
catching all the places that need updating.

## Files

| File | Holds |
|---|---|
| `screens.md` | Canonical screen names with their PRDs, navigation slot, and slug. |
| `data-models.md` | Entities (User, Order, Account) — name, fields, source PRD, ADR if persisted. |
| `api-endpoints.md` | All backend endpoints — method, path, request/response shapes, source ADR. |
| `analytics-events.md` | Every event name, properties, and trigger — source PRD. |
| `feature-flags.md` | Remote-config and local feature flags — name, default, current variants. |
| `glossary.md` | Domain vocabulary — synonyms, banned terms, preferred phrasing. |

## Naming Rules

- **Screens**: `PascalCase` semantic name — `SignInScreen`, `OrderHistoryScreen`. Avoid platform suffixes (`SignInActivity`, `SignInFragment`).
- **Data models**: `PascalCase` singular — `User`, `Order`, `Address`. Plurals only when the type is naturally a collection.
- **API endpoints**: lowercase kebab-case, plural resources — `/users/{id}/orders`. Verb-noun phrases for actions — `/orders/{id}/cancel`.
- **Analytics events**: `snake_case` past-tense — `sign_in_completed`, `order_placed`, `paywall_shown`.
- **Feature flags**: `snake_case` topic-first — `auth_v2_enabled`, `paywall_layout_variant`.

## Format

Each registry file uses a YAML or Markdown table. Example for screens:

```markdown
| Screen Name        | Slug              | Nav Slot      | PRD                                |
|--------------------|-------------------|---------------|------------------------------------|
| SignInScreen       | sign-in           | auth-modal    | design/prd/email-signin.md         |
| OrderHistoryScreen | order-history     | profile-tab   | design/prd/order-history.md        |
| PaywallScreen      | paywall           | modal         | design/prd/paywall.md              |
```

## When to Update

- A new PRD is approved → add its screens, models, events, and flags.
- An ADR introduces a new entity → add it.
- A renaming proposal lands → update the registry first, then propagate.
  PRDs that still use the old name are flagged for revision.

`/consistency-check` reads the registry and audits PRDs for drift.

## Why Not Auto-Generate?

Generated registries fall out of sync with the design intent. The
authored entries describe what the registry name *means*, which is what
matters for cross-doc consistency. Tooling cross-checks against the
registry; it does not own it.
