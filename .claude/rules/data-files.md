---
paths:
  - "**/*.json"
  - "**/*.yaml"
  - "**/*.yml"
  - "**/*.toml"
  - "src/**/config/**"
  - "src/**/data/**"
---

# Data and Config File Rules

Owner: `mobile-architect` for shape; feature owner for values.

## Required

- All JSON files are valid JSON. The `validate-commit.sh` hook blocks
  invalid JSON. Lint locally with `python3 -m json.tool [file]` or `jq .`.
- Every config file has a JSON Schema (`*.schema.json`) or a TS type that
  it validates against. Schema lives next to the data, named
  `[file].schema.json`.
- Numeric values for thresholds, durations, prices, and similar tunables
  carry a unit in the key (`timeoutMs`, `retryCount`, `priceUSD`,
  `cooldownSeconds`).
- Locale-sensitive values (currency, date formats) are tagged with their
  locale (`fr-FR`, `ja-JP`).
- Remote-config payloads include `"_version": <int>` and an `updatedAt`
  ISO-8601 timestamp.
- Sensitive keys (auth tokens, signing certs) are NEVER in committed
  data files. Use `.env*` and the platform secret store.

## Forbidden

- Comments in files where the format does not allow them (`.json`).
- Trailing commas in JSON.
- Mixed indentation (spaces and tabs).
- Floats as currency values. Use integer minor units (`priceCents: 999`).
- Hard-coded URLs to production. Configurable per environment.
- PII in fixtures. Use synthetic users (`alice@example.test`).

## Guarded

- Adding a new top-level key to a remote-config payload: requires
  `analytics-engineer` review (event hash impact) and an ADR if it
  changes how the app interprets a flag.
- Renaming a key in a payload that is already deployed: requires a
  migration path. Do not remove the old key for at least one release
  cycle.

## Recommended Structure

```json
{
  "_version": 3,
  "updatedAt": "2026-05-12T10:00:00Z",
  "auth": {
    "sessionTimeoutMs": 1800000,
    "refreshLeewayMs": 60000
  },
  "experiments": {
    "newOnboarding": { "enabled": true, "variant": "B" }
  },
  "pricing": {
    "monthlyUSD": { "priceCents": 999, "currency": "USD" }
  }
}
```

## Examples

**Correct** (typed config module backed by JSON):

```ts
import schema from './remote-config.schema.json';
import payload from './remote-config.json';

export const remoteConfig = validateAgainst(schema, payload);
```

**Incorrect** (mixed concerns, no units, floats for money):

```json
{
  "timeout": 1800,           // VIOLATION: unit unclear
  "price": 9.99,             // VIOLATION: float currency
  "secretKey": "sk_..."      // VIOLATION: secret in committed file
}
```
