---
paths:
  - "src/**/*.swift"
  - "ios/**/*.swift"
---

# Swift / SwiftUI / iOS Rules

Specialists: `ios-specialist`, `swift-specialist`, `swiftui-specialist`.

## Required

- Swift 6 strict concurrency: types crossing actor boundaries are
  `Sendable`; UI-touching view models are `@MainActor`.
- View models use `@Observable` (Swift 5.9+/6) where supported; legacy
  `ObservableObject` is acceptable in maintenance branches with an ADR.
- Networking flows through `URLSession` (or the project's chosen client)
  inside an actor-isolated repository, never inside the view.
- Persistence: SwiftData where the data is local-only, Core Data only
  with an ADR justifying the legacy choice. Keychain for secrets.
- Errors are `Error`-conforming enums per domain (e.g., `AuthError`,
  `PaymentError`). Use typed throws (`throws(MyError)`) where supported.
- Every screen has VoiceOver labels, traits, and a sensible reading order.
  Buttons declare `.accessibilityIdentifier` for UI tests.
- File naming: `FeatureNameView.swift`, `FeatureNameViewModel.swift`,
  `FeatureNameRepository.swift`. One major type per file.

## Forbidden

- Force unwraps (`!`) outside test fixtures and stable IBOutlets.
- Implicitly-unwrapped optionals on persisted properties.
- Synchronous network or disk calls on the main actor.
- `print()` for logging in production code; use `Logger` (os.Logger).
- `@StateObject` for state owned outside the view; use environment or
  pass the model as a parameter.
- Fat `View` types containing business logic; logic belongs in the view
  model.

## Guarded

- Combine usage in new code — confirm the team's stance (Combine vs.
  Swift Concurrency vs. AsyncAlgorithms) before adding subscribers.
- UIKit interop in a SwiftUI app — requires a justification comment
  pointing to the gap that SwiftUI cannot fill.
- Adopting a new iOS API only available on the latest OS — must be gated
  by `#available` and have a fallback path.

## Examples

**Correct** (actor-isolated repository, typed errors):

```swift
actor AuthRepository {
  func signIn(email: String, password: String) async throws(AuthError) -> Session {
    let request = try AuthRequest(email: email, password: password)
    let (data, _) = try await URLSession.shared.data(for: request.urlRequest)
    return try Session(decoding: data)
  }
}
```

**Incorrect** (force-unwrap, blocking call on main):

```swift
@MainActor
final class SignInViewModel {
  func signIn(email: String, password: String) {
    let url = URL(string: "https://api.acme.example/auth")!     // VIOLATION
    let data = try! Data(contentsOf: url)                       // VIOLATION (sync I/O)
    self.session = try! Session(decoding: data)                 // VIOLATION
  }
}
```

**Correct** (SwiftUI view delegates to view model):

```swift
struct SignInView: View {
  @State private var model = SignInViewModel()
  var body: some View {
    Form { /* fields */ }
      .task { await model.preload() }
      .accessibilityIdentifier("sign-in-form")
  }
}
```
