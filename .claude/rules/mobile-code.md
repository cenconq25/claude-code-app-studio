---
paths:
  - "src/**"
---

# Mobile Code Rules (Universal)

These rules apply to every file under `src/` regardless of framework.
Framework-specific rules add detail; they never override these.

## Required

- Every public symbol carries a doc comment with purpose, inputs, outputs,
  and platform caveats.
- Every system has a corresponding ADR in `docs/architecture/`. New
  systems without an ADR are blocked at code review.
- Configurable values (timeouts, thresholds, copy, feature flags) live in
  a typed config module or a remote-config payload — never inlined as
  magic numbers or hard-coded strings.
- Side effects (network, persistence, push, analytics) flow through a
  service layer that can be replaced by a fake in tests.
- Commits reference a PRD ID, ADR ID, or story ID
  (e.g., `[PRD-AUTH-003]` or `[STORY-S5-12]`).
- Errors are typed. Network errors carry the offending request id and a
  user-facing message that the UI can render verbatim.
- All asynchronous operations are cancellable; cancellation is honoured on
  unmount, screen-pop, or app-background.

## Forbidden

- Direct platform API calls (`fetch`, `URLSession`, `OkHttp`, `dart:io`)
  inside view files. Routing must go through the service layer.
- Storing secrets in plain key-value (AsyncStorage,
  UserDefaults/SharedPreferences without encryption, plain MMKV).
- Performing blocking I/O on the UI thread.
- Logging PII or secrets at any level. Crash reports must redact
  identifiers before upload.
- Using deprecated APIs without a removal date in the linked ADR.

## Guarded

- Any new third-party dependency requires an ADR before merge.
- Any new analytics event requires the event name, properties, and trigger
  documented in the relevant PRD's Analytics section.
- Any new permission request requires a pre-permission rationale screen
  approved by `ux-designer`.

## Examples

**Correct** (cross-platform, framework-agnostic):

```text
// services/auth.ts
export async function signIn(email: string, password: string,
                              opts: { signal?: AbortSignal } = {}): Promise<Session> {
  const response = await client.post('/auth/sign-in', { email, password },
                                      { signal: opts.signal });
  return parseSession(response);
}
```

**Incorrect** (platform call inside a view, hard-coded URL):

```text
function SignInView() {
  const handleSubmit = () => {
    fetch('https://api.acme.example/auth', { method: 'POST' })  // VIOLATION
      .then(/* ... */);
  };
}
```

**Correct** (typed errors, redacted logs):

```text
try { await signIn(email, password); }
catch (err) {
  if (err instanceof AuthError) {
    logger.warn('Auth failed', { code: err.code });   // no email, no password
    showToast(t('auth.error.invalid'));
  } else throw err;
}
```
