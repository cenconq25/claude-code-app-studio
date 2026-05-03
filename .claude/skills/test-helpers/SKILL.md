---
name: test-helpers
description: "Generates a framework-specific test helper library — factories, mocks, custom matchers, and shared assertion utilities — under tests/helpers/. Reduces boilerplate in new test files. Run after /test-setup once the project has a few real tests."
argument-hint: "[--scan | --module=<name>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion
model: sonnet
---

# Test Helpers

Reads existing tests, finds repeated setup, and extracts that into a
helper library so future tests stay short and intention-revealing.

---

## Phase 1: Read Project Context

Read in parallel:

- `.claude/docs/technical-preferences.md` — Framework, Testing Framework,
  Naming Conventions.
- `.claude/docs/coding-standards.md` — test rules.
- `tests/helpers/` (if present) — what already exists.

Confirm the framework. If unset, redirect to `/setup-framework`.

---

## Phase 2: Scan Existing Tests

Glob the test tree:

- RN/TS: `tests/**/*.test.{ts,tsx,js,jsx}`
- Flutter: `tests/**/*_test.dart` and `test/**/*_test.dart`
- iOS: `tests/**/*Tests.swift`
- Android: `tests/**/*Test.kt`

For each file, find:

- Repeated factory functions (e.g., builders that return a `User`,
  `Product`, `CartItem`, etc.).
- Repeated mocks (network client, storage, analytics, deep-link router,
  push handler).
- Repeated assertion patterns (e.g., "the screen shows error X" or "the
  store dispatched action Y").
- Repeated setup/teardown blocks (auth state, seed data, navigation
  stack).

Group results by recurrence count. Anything that appears 3+ times is a
candidate.

---

## Phase 3: Propose the Helper API

Produce a proposal table:

| Helper | Type | Used in | Reason |
|--------|------|---------|--------|
| `makeUser({...overrides})` | Factory | 8 tests | duplicated user objects |
| `mockApiClient(responses)` | Mock | 5 tests | repeated fetch stubs |
| `expectScreenShowsError(matcher)` | Matcher | 4 tests | repeated assertion |

Use AskUserQuestion to confirm:

- `[A] Generate every helper in the table`
- `[B] Generate only the top N`
- `[C] Let me pick — show one at a time`

---

## Phase 4: Write the Helpers

Create files under `tests/helpers/` grouped by purpose. Always ask before
each write. Naming follows the framework convention.

### Factories — `tests/helpers/factories/*`

Pattern: pure functions that take an `overrides` object and return a
fully-formed domain object with sensible defaults.

```ts
// React Native example
export const makeUser = (overrides: Partial<User> = {}): User => ({
  id: 'user-1',
  email: 'a@b.com',
  isVerified: true,
  ...overrides,
});
```

### Mocks — `tests/helpers/mocks/*`

Pattern: factory functions that return an interface-shaped mock object.
For each platform module the project commonly stubs (network, storage,
analytics, biometrics, push, location), provide a mock factory.

### Custom matchers — `tests/helpers/matchers/*`

Wrap repeated assertions in named matchers with clear failure messages.
Examples:

- `toHaveDispatched(action)` for a Redux store.
- `toRenderError(message)` for a screen-level error UI.
- `toMatchSnapshotIgnoring([fields])` for resilient snapshot tests.

### Test fixtures — `tests/helpers/fixtures/*`

For canned responses (paginated lists, deep-link payloads, push payloads),
provide JSON fixtures plus a small loader utility.

### Render helpers — `tests/helpers/render.{ts,dart,swift,kt}`

Wrap the framework's render call to also wire navigation, theme, store,
and i18n providers in one call:

- RN: `renderWithProviders(ui, { store, navState })`
- Flutter: `pumpWithProviders(tester, widget, { router, theme })`
- SwiftUI: `RenderHost(view).withStubbedDeps()`
- Compose: `composeTestRule.setContentWithProviders { ui }`

---

## Phase 5: Refactor One Existing Test as a Demo

Pick the highest-duplication file from Phase 2. Refactor it to use the new
helpers. Show the diff and ask the user to approve before saving.

This proves the helpers work and provides a reference for future authors.

---

## Phase 6: Document the Helpers

Create `tests/helpers/README.md` with one short section per helper:

- Signature
- One-line purpose
- One-line usage example
- The original-pattern problem it replaces

Keep entries terse — engineers will skim, not read.

---

## Phase 7: Update Coding Standards

Append a `Test Helpers` block to `.claude/docs/coding-standards.md`:

- Where helpers live.
- The rule: "Before adding a third copy of any test setup, extract it
  into `tests/helpers/`."
- The rule: "New tests must use existing helpers when applicable."

Confirm before writing.

---

## Quality Gates / PASS-FAIL

- PASS — every generated helper compiles; the demo refactored test still
  passes; README exists; standards updated.
- FAIL — any helper has a type error or runtime error in the smoke run.
  Roll back the failing helper and surface the diagnostic.

---

## Examples

**Example 1 — RN app with 14 tests:**
Detects that 9 tests build a `Product` object inline. Generates
`makeProduct`, refactors `tests/unit/cart/cartReducer.test.ts` to use it,
adds a README entry, and updates standards.

**Example 2 — Flutter app:**
Detects a `pumpWithRouter` pattern repeated across widget tests.
Extracts `tests/helpers/pump.dart` and refactors one widget test as the
canonical example.

---

## Next Steps

- Run `/test-evidence-review` after the next sprint to verify the helpers
  are actually being used.
- Re-run `/test-helpers --scan` periodically (start of each sprint) to
  catch new duplication early.
