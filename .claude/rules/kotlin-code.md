---
paths:
  - "src/**/*.kt"
  - "src/**/*.kts"
  - "android/**/*.kt"
  - "android/**/*.kts"
---

# Kotlin / Jetpack Compose / Android Rules

Specialists: `android-specialist`, `kotlin-specialist`, `jetpack-compose-specialist`.

## Required

- Kotlin 2.1 with `explicitApi()` mode on shared library modules.
- All threading flows through coroutines. Repositories expose suspend
  functions or `Flow<T>`; view models expose `StateFlow<T>` for screen state.
- Compose: state is hoisted; composables either render their inputs or
  delegate to a `ViewModel`. Use `remember`/`rememberSaveable` for local
  state only.
- DI through Hilt (or Koin where chosen). Never use `object`/global
  service locators in feature code.
- Strict null safety — leverage smart-casts; use the Elvis operator with
  fallback values; avoid `!!`.
- File naming: `FeatureNameScreen.kt`, `FeatureNameViewModel.kt`,
  `FeatureNameRepository.kt`. Tests: `FeatureNameViewModelTest.kt`.
- Resources used from Compose go through `stringResource`,
  `dimensionResource`, etc. — never hard-coded strings or dp values.

## Forbidden

- `runBlocking` outside tests.
- `LiveData` in new code; use `StateFlow` / `SharedFlow`.
- `GlobalScope.launch` — coroutines are scoped to a `ViewModelScope` or
  similar, never the global scope.
- Mutating state from a `@Composable` body directly; mutate through a
  `MutableStateFlow` in the view model.
- Force-unwrapping with `!!` outside tests.
- Performing I/O on `Dispatchers.Main`.

## Guarded

- Adding a new dependency or AGP version bump: requires an ADR.
- New Compose-side-effects API (e.g., `LaunchedEffect`,
  `DisposableEffect`) must be reviewed for cancellation correctness.
- Background work uses WorkManager when persistence is required;
  foreground services are reserved for user-visible long-running tasks
  (audio playback, downloads).

## Examples

**Correct** (state hoisted, coroutine-scoped):

```kotlin
@HiltViewModel
class SignInViewModel @Inject constructor(
  private val auth: AuthRepository,
) : ViewModel() {
  private val _state = MutableStateFlow(SignInState())
  val state: StateFlow<SignInState> = _state.asStateFlow()

  fun submit(email: String, password: String) {
    viewModelScope.launch(Dispatchers.IO) {
      runCatching { auth.signIn(email, password) }
        .onSuccess { _state.update { it.copy(session = it) } }
        .onFailure { e -> _state.update { it.copy(error = e.toUiError()) } }
    }
  }
}
```

**Incorrect** (LiveData, runBlocking, !! ):

```kotlin
class SignInViewModel : ViewModel() {
  val state = MutableLiveData<SignInState>()                // VIOLATION (LiveData)
  fun submit(email: String, password: String) {
    val session = runBlocking {                             // VIOLATION (runBlocking)
      AuthRepository.get().signIn(email, password)!!        // VIOLATION (!!)
    }
    state.value = SignInState(session = session)
  }
}
```

**Correct** (Compose state hoisting):

```kotlin
@Composable
fun SignInScreen(viewModel: SignInViewModel = hiltViewModel()) {
  val state by viewModel.state.collectAsStateWithLifecycle()
  SignInForm(state = state, onSubmit = viewModel::submit)
}
```
