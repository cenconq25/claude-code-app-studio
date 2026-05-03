---
paths:
  - "tests/**"
  - "src/**/__tests__/**"
  - "src/**/*.test.*"
  - "src/**/*Test.kt"
  - "src/**/*Tests.swift"
  - "src/**/*_test.dart"
---

# Test Standards

Owners: `qa-lead`, `mobile-test-automation`. Each story produces evidence
appropriate to its type (see `coding-standards.md` for the matrix).

## Naming

- **TypeScript / RN**: `[feature]-[capability].test.ts(x)`. Test names
  use BDD-style: `it('signs in with valid credentials')`.
- **Swift / iOS**: `FeatureNameTests.swift`. Test methods:
  `func test_signsIn_withValidCredentials()`.
- **Kotlin / Android**: `FeatureNameTest.kt`. Test methods:
  `fun signsIn_withValidCredentials()`.
- **Dart / Flutter**: `feature_name_test.dart`. Test names:
  `test('signs in with valid credentials', () { ... })`.

## Determinism

- No random seeds without an injectable seed.
- No clock-dependent assertions; inject a clock and freeze it in tests.
- No live network. Mock the client or use a recorded fixture.
- No file I/O against the user's filesystem; use temp directories and
  clean up.
- No reliance on test execution order. Each test sets up its own state
  and tears it down.

## Isolation

- Unit tests do not call platform APIs. Repositories under test get
  fakes for `Storage`, `Network`, `Clock`, `Random`, `Permissions`.
- Integration tests sit one layer up: they exercise repository +
  service-worker / cache + offline-queue together but still fake the
  network at the transport layer.
- End-to-end tests run on a real or virtual device against a known
  fixture backend. They live in `tests/e2e/` and never block the unit
  CI.

## Test Pyramid

| Layer | What it covers | Runtime budget | Where it lives |
|---|---|---|---|
| Unit | Pure logic — formulas, validators, reducers | < 5 ms each | `tests/unit/` |
| Integration | Repository + cache + offline queue | < 200 ms each | `tests/integration/` |
| Component / Widget | Rendered output for a single component | < 200 ms each | `tests/component/` (or framework idiom) |
| E2E | Critical user paths | Minutes | `tests/e2e/` |

## Required Suites Per Story Type

| Story type | Test suite |
|---|---|
| Logic | At least one unit test that covers all acceptance criteria |
| Integration | Integration test or documented manual run with fixtures |
| UI | Component test or screenshot diff plus manual a11y walkthrough |
| Animation / Motion | Recorded clip plus motion-director sign-off |
| Config / Remote | Smoke check of each variant |
| Accessibility | Audit run and screen-reader walkthrough |

## Test Code Quality

- Tests are read more often than written. Prefer clarity to cleverness.
- Use Arrange / Act / Assert blocks separated by a blank line.
- One logical assertion per test. Multiple `expect`s are fine if they
  collectively assert one behaviour.
- Use factories for fixtures (`buildUser({ ... })`) — never magic numbers
  or copy-pasted blobs of JSON.
- Test names describe behaviour, not implementation.
- Tests fail loudly. Avoid try/catch swallowing.

## What NOT to Automate

- Pixel-perfect rendering across devices — covered by device-farm runs
  and visual review.
- Real push delivery and IAP purchases — covered by sandbox-mode QA.
- Subjective qualities ("feels snappy", "looks polished") — covered by
  lead reviews and beta testing.

## Forbidden

- Skipping a test to make CI green. Fix the test or fix the bug.
- `xit`, `xtest`, `@Ignore`, `@Disabled` without a linked ticket and an
  owner.
- Disabling test isolation features (Vitest's `--isolate=false`,
  Gradle's `--parallel` without proper test isolation).
- Keeping flaky tests in the main suite. They go to a quarantine list
  via `/test-flakiness` and are fixed within one sprint.

## Examples

**Correct** (clear name, factory, one behaviour):

```ts
it('signs in with valid credentials', async () => {
  const repo = buildAuthRepo({ users: [buildUser({ email: 'a@example.test' })] });
  const session = await repo.signIn({ email: 'a@example.test', password: 'pw' });
  expect(session.user.email).toBe('a@example.test');
});
```

**Incorrect** (multiple behaviours, magic numbers, network call):

```ts
it('does auth stuff', async () => {
  const r = await fetch('https://api.acme.example/auth');         // VIOLATION (network)
  expect(r.status).toBe(200);                                      // multiple behaviours
  const data = await r.json();
  expect(data.user.id).toBe(42);                                   // magic number
  expect(data.session.expiresAt).toBeGreaterThan(Date.now());      // clock-dependent
});
```
