---
name: security-audit
description: "Audit the app for vulnerabilities: insecure storage, improper TLS, OWASP MASVS coverage, dependency CVEs, exposed secrets, unsafe deep links, JS-bridge exploits, WebView attack surface. Produces a prioritized remediation report. Run before any public release."
argument-hint: "[--scope=all|storage|network|deps|deeplinks|webview|secrets]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash, AskUserQuestion, WebSearch
model: sonnet
---

# Security Audit

A scoped security pass anchored on OWASP MASVS. Each check has a
detection method, an impact rating, and a remediation suggestion. Output
is a prioritised P0-P3 backlog, plus a written report.

---

## Phase 1: Read Project Context

Read in parallel:

- `.claude/docs/technical-preferences.md` — framework, target platforms,
  forbidden patterns.
- `CLAUDE.md` — project context.
- `docs/architecture/` — relevant ADRs (auth, storage, network).
- Dependency manifests: `package.json`, `pubspec.yaml`, `Podfile`,
  `Package.swift`, `build.gradle*`.

Confirm scope with the user. If `--scope=all`, run every check.

---

## Phase 2: Insecure Storage (MASVS-STORAGE)

Goal: nothing sensitive lives outside the platform's secure store.

Grep the codebase for:

- iOS: `UserDefaults` or `NSUserDefaults` storing tokens, IDs, PII.
- Android: `SharedPreferences` storing credentials, tokens, biometric
  state.
- React Native: `AsyncStorage`, `MMKV` without encryption,
  `react-native-keychain` misuse.
- Flutter: `shared_preferences`, raw SQLite without SQLCipher.
- Cross: hardcoded strings in source that resemble keys, tokens, JWTs,
  or test passwords.

For each hit, classify the data:

- Auth tokens, refresh tokens, OAuth creds, biometric state -> P0 unless
  in Keychain / Keystore.
- PII (email, phone, name) -> P1 unless required and minimised.
- Feature flags, UI prefs -> P3.

Recommended remediation: Keychain (iOS) / Keystore (Android) /
EncryptedSharedPreferences / SecureStore (Expo) /
flutter_secure_storage.

---

## Phase 3: Network and TLS (MASVS-NETWORK)

Look for:

- HTTP (not HTTPS) URLs in source.
- iOS `NSAllowsArbitraryLoads` set to true in `Info.plist`.
- Android `usesCleartextTraffic="true"` or a permissive
  `network_security_config.xml`.
- Custom `TrustManager` / `URLSessionDelegate` / `HostnameVerifier`
  that accept any cert (man-in-the-middle vector).
- Missing certificate pinning on auth endpoints.
- React Native fetch without `cache-control` configuration leaving
  sensitive responses in disk caches.

Severity rules:

- HTTP for auth or payments -> P0.
- HTTP for any user data -> P1.
- Missing pinning on auth endpoint -> P1 (P0 if banking / health).
- Permissive trust manager -> P0.

---

## Phase 4: Dependency CVEs

Run dependency vulnerability scans via Bash:

- `npm audit --json` (suppress noise; capture high+critical only).
- `flutter pub outdated` and consult `pub.dev` for known issues.
- `bundle exec pod outdated` for CocoaPods; cross-reference
  `cve.mitre.org` via WebSearch for top dependencies.
- `./gradlew dependencyUpdates` and check `OWASP Dependency-Check`
  output if configured.

For each CVE:

- Critical / high severity -> P0.
- Medium with exploit path applicable -> P1.
- Medium without applicable path / low -> P2 or P3.

Note: noisy `npm audit` results in nested transitive packages may not
be exploitable from the app — assess the actual surface.

---

## Phase 5: Exposed Secrets

Grep for high-entropy strings and known patterns:

- `[A-Za-z0-9]{32,}` candidates in source.
- `BEGIN PRIVATE KEY`, `BEGIN RSA PRIVATE KEY`.
- AWS access keys (`AKIA[0-9A-Z]{16}`).
- Google API keys (`AIza[0-9A-Za-z-_]{35}`).
- Stripe / Twilio / Sentry tokens.
- Hardcoded `dev` / `staging` / `prod` URLs that imply embedded creds.

Check `.env` patterns ending up in version control via
`git ls-files | grep -E '\.env'`.

Inspect build outputs (`assets/`, `Resources/`, packaged JS bundles)
to ensure secrets are not bundled into release artifacts.

Severity: any production secret in the repo or release bundle is P0.

---

## Phase 6: Deep Link Surface

Find every deep link entry point:

- iOS: `Info.plist` URL Schemes; `Associated Domains` for universal
  links.
- Android: `intent-filter` declarations in `AndroidManifest.xml`; App
  Links verification.
- React Native: `Linking.getInitialURL`, deep-link library config.
- Flutter: `uni_links` / `app_links` config.

For each, audit:

- [ ] Are inbound URL parameters validated before use?
- [ ] Is auth required before sensitive deep-link destinations?
- [ ] Can a malicious URL trigger account state changes (email change,
      password reset, payment) without confirmation?
- [ ] Are universal/App Links verified by the apple-app-site-association
      / assetlinks.json file?

Open redirects, unauthenticated state-change endpoints reachable via
deep link, or unvalidated intent extras -> P0.

---

## Phase 7: WebView Surface

Find every WebView mount:

- iOS: `WKWebView`, `SFSafariViewController`.
- Android: `WebView`, `Custom Tabs`.
- React Native: `react-native-webview`.
- Flutter: `webview_flutter`, `flutter_inappwebview`.

Audit:

- [ ] `javaScriptEnabled` set deliberately, with bridge constraints.
- [ ] No `addJavascriptInterface` / `WebViewMessageHandler` exposing
      privileged APIs to untrusted origins.
- [ ] URL allowlist on navigation; unknown origins do not load.
- [ ] No mixed content allowed.
- [ ] File-system access disabled unless required and sandboxed.
- [ ] User-agent does not leak sensitive info.

Native bridge over an untrusted origin -> P0.

---

## Phase 8: Auth and Session

Audit (read auth code if present):

- [ ] Tokens never logged to console / file / analytics.
- [ ] Refresh token rotation is implemented; replay is rejected.
- [ ] Logout clears every keychain entry, in-memory cache, and pending
      background job tokens.
- [ ] Biometric prompts (FaceID, TouchID, BiometricPrompt) are guarded
      by a server-issued challenge — not local-only.
- [ ] Session timeout is enforced server-side.
- [ ] No auto-fill of credentials into webview-rendered login forms.

---

## Phase 9: Platform Permissions

Read `Info.plist` (iOS) and `AndroidManifest.xml` (Android). For each
permission:

- [ ] Is it actually used by current code?
- [ ] Does the usage description (`NSLocationWhenInUseUsageDescription`,
      etc.) accurately describe purpose?
- [ ] Are background variants (location-always, microphone-always)
      declared only when needed?

Unused permissions -> P3 noise, but cumulative noise is a store-review
risk.

---

## Phase 10: Logging and Telemetry

- Are tokens / PII redacted before log emit?
- Are crash logs scrubbed before upload?
- Does telemetry respect ATT (App Tracking Transparency) on iOS?
- Does Android adhere to Data Safety form declarations?

PII or token in any log path -> P0.

---

## Phase 11: Render Report

```markdown
# Security Audit — [build] — [date]

Scope: [scope flags]

## Findings

### P0 — Must fix before release
| Finding | Location | OWASP MASVS ref | Recommendation |

### P1 — High priority
| ... |

### P2 — Medium priority
| ... |

### P3 — Low / hygiene
| ... |

## Dependency CVEs
| Package | Version | CVE | Severity | Fixed in |

## Permission Audit
| Permission | Used? | Justification | Verdict |

## Verdict: BLOCK RELEASE / RELEASE WITH PLAN / RELEASE OK

Reasoning: [paragraph]

## Remediation Plan
[ordered list with story IDs to be created]
```

Ask before writing to `production/security/security-audit-[date].md`.

---

## Phase 12: Update State and Open Stories

Append to `production/session-state/active.md`:

```
## Security Audit — [date]
- Findings: P0=[count], P1=[count], P2=[count]
- Verdict: [verdict]
- Report: [path]
- Next: open stories for P0/P1 via /create-stories
```

For each P0 finding, prompt: "Open a story for this finding now?" If
yes, draft the story spec for `/create-stories` to use.

---

## Quality Gates / PASS-FAIL

- RELEASE OK — zero P0; P1 count manageable.
- RELEASE WITH PLAN — P0 has a tracked fix in active sprint, no other
  P0 unaccounted for.
- BLOCK RELEASE — any P0 unfixed or untracked.

---

## Examples

**Example 1 — Pre-launch RN app:**
Finds 2 P0 (auth token in AsyncStorage; missing TLS pinning on
auth.example.com), 4 P1, 11 P2. Verdict: BLOCK RELEASE. Two stories
opened for the P0s.

**Example 2 — Quarterly check on Flutter app:**
Zero P0; one P1 (deprecated dependency with known CVE, fix available);
moderate P2/P3 hygiene items. Verdict: RELEASE OK with plan to bump
dependency in next sprint.

---

## Next Steps

- P0 findings -> `/create-stories` then `/dev-story` immediately.
- P1 findings -> next sprint via `/sprint-plan`.
- Re-run `/security-audit` before every public release as part of
  `/launch-checklist`.
