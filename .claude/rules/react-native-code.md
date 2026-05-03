---
paths:
  - "src/**/*.ts"
  - "src/**/*.tsx"
  - "src/**/*.js"
  - "src/**/*.jsx"
---

# React Native + TypeScript Rules

Specialist: `react-native-specialist` and `typescript-specialist`.

## Required

- `tsconfig.json` extends `@tsconfig/strictest` (or equivalent) with
  `strict: true`, `noUncheckedIndexedAccess: true`, `exactOptionalPropertyTypes: true`.
- Components are function components with an explicit prop type and
  default-prop handling via destructuring.
- Side-effectful state lives in TanStack Query (server state) or the
  chosen client-state lib (Zustand / Redux Toolkit). `useState` is reserved
  for view-local state.
- Lists use `FlashList` (or `FlatList` with `keyExtractor`,
  `getItemLayout`, `removeClippedSubviews`) — never `ScrollView` for
  unbounded data.
- Navigation passes typed params; routes registered with the navigator's
  generic type. No untyped string keys.
- Memoise expensive children with `React.memo`; memoise computed props
  with `useMemo`/`useCallback` only when measurement says they matter.
- Native modules wrapped in TS types live in `src/native/` with explicit
  `.d.ts` declarations.

## Forbidden

- `any` outside generated code or third-party shims. Use `unknown` and
  narrow it.
- `React.FC` for component typing — does not infer children correctly and
  conflates default-props handling.
- Mutating Redux state outside a `createSlice` reducer (Immer aside).
- Inline functions in props of memoised list rows — defeats memoisation.
- Hard-coded string literals for navigation route names — use typed enums
  or the generated route map.
- Calling `fetch` directly inside a component — go through the service
  layer with TanStack Query.

## Guarded

- Adding a native module: requires an ADR plus iOS and Android pair-review.
- Adding a Reanimated worklet: requires an ADR if it touches the UI
  thread continuously (cost can be invisible until a low-end Android shows
  up).
- Bumping React Native: requires a `MA-FRAMEWORK-RISK` review against the
  pinned version reference.

## Examples

**Correct** (typed component, memoised row):

```ts
type AccountRowProps = { account: Account; onPress: (id: string) => void };

export const AccountRow = React.memo(function AccountRow(
  { account, onPress }: AccountRowProps,
) {
  const handlePress = useCallback(() => onPress(account.id), [account.id, onPress]);
  return (
    <Pressable onPress={handlePress} accessibilityRole="button">
      <Text>{account.name}</Text>
    </Pressable>
  );
});
```

**Incorrect** (any, inline handler defeats memo, no a11y role):

```ts
export const AccountRow: React.FC = (props: any) => {        // VIOLATION (any, FC)
  return (
    <Pressable onPress={() => props.onPress(props.account.id)}>  // inline handler
      <Text>{props.account.name}</Text>
    </Pressable>
  );
};
```

**Correct** (TanStack Query):

```ts
const { data, isLoading } = useQuery({
  queryKey: ['account', id],
  queryFn: ({ signal }) => accountService.get(id, { signal }),
  staleTime: 30_000,
});
```
