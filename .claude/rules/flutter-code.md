---
paths:
  - "src/**/*.dart"
  - "lib/**/*.dart"
---

# Flutter / Dart Rules

Specialists: `flutter-specialist`, `dart-specialist`.

## Required

- `analysis_options.yaml` enables `strict-casts`, `strict-inference`,
  `strict-raw-types`, plus `flutter_lints` (or stricter `very_good_analysis`).
- State management uses the project's chosen library (Riverpod, Bloc,
  Provider). Set once via ADR; do not mix.
- Widgets are pure with respect to their inputs; state lives in
  notifiers/blocs/providers, not in widget fields.
- Asynchronous work uses `Future` and `Stream` with cancellation tokens
  where appropriate (`CancelToken` for `dio`, `StreamSubscription` cleanup
  in `dispose`).
- Networking through a typed client (Dio + freezed models, or chopper).
  Errors are typed Dart `sealed` classes per domain.
- File naming: `snake_case.dart`. One major widget per file unless the
  helpers are private to its parent.
- Internationalization uses `flutter_intl` (or `slang`) — never hard-coded
  strings.

## Forbidden

- `setState` inside a feature widget — restricted to leaf controls (a
  custom slider, a swipe-to-delete handle, etc.).
- `dynamic` outside generated code or marshalling layers.
- `print` in production code; use `logger` (or framework logger).
- Force-unwrapping with `!` outside fixtures.
- Long-running synchronous work on the UI isolate; use `compute()` or a
  dedicated isolate.
- `Navigator.push(MaterialPageRoute(builder: ...))` patterns in apps that
  use `go_router` (or equivalent declarative router).

## Guarded

- Adding a new package: requires an ADR if it touches networking,
  persistence, security, or DI.
- Platform channels: require a paired iOS + Android implementation and
  matching tests.
- Custom render objects: require performance evidence (FPS recording on a
  low-tier device) before merge.

## Examples

**Correct** (Riverpod-based state, typed error):

```dart
@riverpod
class SignIn extends _$SignIn {
  @override
  SignInState build() => const SignInState.idle();

  Future<void> submit({required String email, required String password}) async {
    state = const SignInState.loading();
    try {
      final session = await ref.read(authRepoProvider).signIn(email, password);
      state = SignInState.success(session);
    } on AuthError catch (e) {
      state = SignInState.failure(e);
    }
  }
}
```

**Incorrect** (setState misuse, hard-coded URL, dynamic):

```dart
class SignInPage extends StatefulWidget {
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  dynamic session;                                     // VIOLATION (dynamic)
  Future<void> submit() async {
    final res = await http.post(                       // VIOLATION (no client wrapper)
      Uri.parse('https://api.acme.example/auth'),      // VIOLATION (hard-coded URL)
    );
    setState(() => session = jsonDecode(res.body));    // VIOLATION (state in widget)
  }
}
```
