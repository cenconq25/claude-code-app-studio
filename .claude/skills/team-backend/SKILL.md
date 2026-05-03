---
name: team-backend
description: "Orchestrate the server / data side of a feature. Coordinates backend-engineer, api-designer, database-specialist, offline-sync-specialist, push-notification-specialist, and firebase-specialist for the data layer."
argument-hint: "[--feature=<name> | --epic=<slug>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
agent: backend-engineer
model: sonnet
---

# Team Backend

The data-side counterpart to `/team-frontend`. Coordinates the roles
that own the API contract, the persistence layer, the offline sync
strategy, the push channel, and any Firebase-style BaaS surface.

---

## Team Composition

- **backend-engineer** — feature owner on the server side.
- **api-designer** — request / response shape, versioning, error
  conventions, OpenAPI spec.
- **database-specialist** — schema, indexes, migrations, query plans.
- **offline-sync-specialist** — local cache, conflict resolution,
  outbox pattern, retry semantics.
- **push-notification-specialist** — APNs / FCM topology, device-token
  lifecycle, payload contracts.
- **firebase-specialist** (optional) — Auth, Firestore, RemoteConfig,
  Crashlytics, Analytics, Cloud Functions.

Spawn each via Task. Parallelize where dependencies allow.

---

## Phase 1: Resolve Feature Scope

Parse argument:

- `--feature=<name>` -> glob related stories.
- `--epic=<slug>` -> read `production/epics/[slug]/`.
- No argument -> ask the user.

Read in parallel:

- The PRD under `design/prd/`.
- Governing ADRs in `docs/architecture/` (esp. data, sync, auth).
- Design package if a UI exists (`design/packages/`).
- Existing API specs in `docs/api/` or wherever OpenAPI lives.
- The current data schema docs.

Decide which roles are needed. Not every feature needs every role.

---

## Phase 2: API Contract via api-designer

Spawn `api-designer` via Task. Prompt template:

> Feature: [name]. PRD: [path]. Existing API conventions: [paths].
> Design endpoints: routes, methods, request bodies, response bodies,
> status codes, error envelopes, auth requirements, rate-limit
> implications, cursor / pagination semantics, idempotency keys for
> mutations. Output an OpenAPI fragment plus a written summary. Flag
> any deviation from existing conventions and require justification.

Render the contract. Use AskUserQuestion to approve.

This contract is the source of truth for the rest of the cycle —
both /team-frontend's state layer and /team-backend's database
specialist depend on it.

---

## Phase 3: Schema and Migrations via database-specialist (parallel with Phase 4)

Spawn `database-specialist` via Task. Prompt template:

> Contract: [reference]. Current schema: [paths]. Propose schema
> changes: new tables, new columns, new indexes, FK constraints. Plan
> migrations: forward AND rollback. Estimate query plans for the
> top 3 read paths and the top 3 write paths. Identify any change
> that requires a backfill and propose the backfill strategy
> (offline batch / online dual-write / shadow read).

Render the plan. Surface any migration risk to the user.

---

## Phase 4: Backend Implementation via backend-engineer (parallel with Phase 3)

Spawn `backend-engineer` via Task. Prompt template:

> Contract: [reference]. Implement the endpoints. Validate inputs
> server-side (do not trust the client). Enforce auth and
> authorization. Implement rate limiting. Log structured events for
> the analytics + audit surfaces declared in the PRD. Write
> integration tests covering: happy path, auth failure, validation
> failure, idempotency replay, rate-limit. Capture observability:
> traces, metrics, error rates.

The backend implementation may proceed in parallel with the schema
specialist, with the contract as the shared boundary. Coordinate
through the OpenAPI fragment.

---

## Phase 5: Offline Sync via offline-sync-specialist

If the feature includes offline support (read in PRD), spawn
`offline-sync-specialist`. Prompt template:

> Contract: [reference]. PRD offline behavior: [section]. Design the
> offline-cache strategy: what's cached, freshness rules, eviction.
> Design the outbox pattern for mutations: queue, retry-with-jitter,
> idempotency, on-reconnect drain. Define conflict resolution:
> last-write-wins / server-wins / merge / user-prompt. Define the
> "stale view" indicator the UI should show when offline.

Cross-check with api-designer's idempotency keys. Surface any
contract gap.

---

## Phase 6: Push Channel via push-notification-specialist

If the feature includes push:

Spawn `push-notification-specialist` via Task. Prompt template:

> Feature: [name]. PRD push behavior: [section]. Define the topology:
> APNs / FCM. Device-token lifecycle: registration, refresh,
> invalidation. Payload contract: title, body, deep link, custom
> data, collapse keys. Quiet hours and rate caps. iOS rich notification
> service-extension if attachments are needed. Background-data
> handling. Notification grouping / threading. Permission prompt
> timing — coordinate with /team-design's "first relevant moment".

Cross-check with content-strategist's frequency caps if a content
package exists.

---

## Phase 7: Firebase / BaaS Surface (optional)

If the project uses Firebase or a similar BaaS, spawn
`firebase-specialist` via Task. Prompt template:

> Feature: [name]. Confirm: Firestore rules updates, Auth provider
> configuration, RemoteConfig keys to add, Cloud Functions to deploy,
> Crashlytics symbolication for new modules, Analytics events to
> register. Each of these has a deploy step that must be coordinated
> with the app release. Output a deploy checklist.

Render the deploy checklist for inclusion in the release plan.

---

## Phase 8: Cross-Cutting Reviews

Spawn in parallel:

- `security-engineer` (or run inline `/security-audit --scope=network`
  for the new endpoints) to confirm contract is safe.
- `qa-tester` to verify integration test seams.
- `analytics-engineer` to confirm event names and shapes match the
  PRD's analytics requirements.

Aggregate findings.

---

## Phase 9: Integration Smoke

Run an integration smoke against staging:

- Hit each new endpoint with a test client (curl / HTTPie / Bruno
  collection).
- Trigger a test push.
- Force-offline and verify outbox drains.
- Run the schema migration on a staging copy and rollback once.

Capture evidence in
`production/build/[feature]-backend-smoke.md`.

---

## Phase 10: Compose the Build Report

```markdown
# Backend Build Report — [feature]

Sprint(s) involved: [list]
Stories completed: [list]
Specialists engaged: [list]

## API Contract
[OpenAPI fragment or link]

## Schema Changes
- Tables: [list]
- Columns: [list]
- Migration: [ID and rollback path]
- Backfill: [strategy]

## Endpoints
- [path] — [method] — [auth] — tests: [count] — coverage: [PASS]

## Offline Sync
- Cache: [details]
- Outbox: [details]
- Conflict resolution: [policy]

## Push
- Topology: [APNs/FCM]
- Payload contract: [link]
- Permission prompt: [timing]

## Firebase Deploy Steps (if applicable)
- [list]

## Verdict: COMPLETE / FIXES NEEDED
```

Ask before writing to `production/build/[feature]-backend-build.md`.

---

## Phase 11: Update State

Append to `production/session-state/active.md`:

```
## Backend Build — [date]
- Feature: [name]
- Stories: [count] — Complete
- Endpoints: [count]
- Migrations: [count]
- Verdict: [verdict]
- Report: [path]
- Next: /team-frontend integrates contract; then /team-qa
```

---

## Error Recovery

If any subagent returns BLOCKED:

- api-designer blocked on PRD ambiguity -> back to PRD author.
- database-specialist blocked on migration risk -> escalate to
  technical lead; consider feature gating until resolved.
- offline-sync-specialist blocked on contract that is not
  idempotency-safe -> loop back to api-designer.
- push-notification-specialist blocked on missing APNs key / FCM project
  -> escalate to mobile-devops.
- firebase-specialist blocked on permissions -> escalate to producer.

---

## Quality Gates / PASS-FAIL

- COMPLETE — contract approved, schema migrated and rollback proven,
  integration tests green, offline tested, push tested, deploy
  checklist captured.
- FIXES NEEDED — any of the above outstanding.

---

## Examples

**Example 1 — Paywall backend:**
3 endpoints (catalog, intent, confirm), schema add for receipts,
offline outbox for purchase intents, no push. database-specialist
flags index need for receipt lookup. api-designer enforces
idempotency-key on confirm. Integration smoke passes.

**Example 2 — Push-only feature:**
Re-engagement campaign push. No new endpoints; only
push-notification-specialist + analytics-engineer. Deploy checklist
includes APNs key rotation reminder.

---

## Next Steps

- `/team-frontend` integrates the new contract.
- `/team-qa` for the full feature once both sides land.
- Include any deploy steps in `/team-release`.
