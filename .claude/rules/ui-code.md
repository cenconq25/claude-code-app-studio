---
paths:
  - "src/**/components/**"
  - "src/**/screens/**"
  - "src/**/features/**/ui/**"
  - "src/**/widgets/**"
  - "src/**/Views/**"
  - "src/**/ui/**"
  - "src/**/theme/**"
  - "src/**/DesignSystem/**"
---

# UI Code Rules

Specialists: `visual-design-director` (design intent),
`accessibility-specialist` (a11y floor), framework UI specialist
(`swiftui-specialist`, `jetpack-compose-specialist`,
`react-native-specialist`, `flutter-specialist`).

## Required

- All visual values come from design tokens (colour, type scale, spacing,
  radii, shadows, motion). One-off literals require a rationale comment
  pointing to a token-system update plan.
- Every screen handles five states: loading, empty, error, partial-data,
  success. Where applicable: offline.
- Every interactive element has:
  - An accessibility role/trait/semantic.
  - A label that survives translation.
  - A hit target of at least 44 pt (iOS) / 48 dp (Android).
  - A focus state for keyboard / D-pad navigation (where the platform supports it).
- Lists are virtualised by default (FlashList / LazyColumn / ListView.builder).
- Images use the platform's lazy decoding path (FastImage, AsyncImage,
  Image.network with cache, Coil/Glide). Never decode large images on the UI thread.
- Motion respects the user's reduce-motion preference (iOS:
  `accessibilityReduceMotion`; Android: `Settings.Global.TRANSITION_ANIMATION_SCALE`;
  RN: `AccessibilityInfo`; Flutter: `MediaQuery.disableAnimationsOf(context)`).

## Forbidden

- Inline colour hex strings, font sizes, or spacing values in component
  code. Tokens or theme references only.
- Fixed pixel font sizes that ignore Dynamic Type / font scale.
- Accessing `window.height` to size content without protecting the safe
  area.
- Bypassing the design system to ship a one-off component without an
  approval line from `visual-design-director`.
- Pushing a screen with no entry animation (cold-start screens excepted).
- Heavy work in render: synchronous JSON parsing, synchronous image
  decoding, layout-thrashing measurements.

## Guarded

- Custom drawing: require performance evidence (no jank on a mid-tier device).
- Bottom sheets and modal stacks deeper than two: must be reviewed for
  back-stack and gesture conflicts.
- Custom keyboard / IME interactions: require pair review with
  `interaction-designer`.
- Any new gesture (swipe, long-press, pinch): documented in the
  interaction pattern library before implementation.

## Required Component States

Every reusable UI component documents these states in its `*Component.story.*`
or equivalent reference file:

1. Default
2. Hover / Focus (where applicable)
3. Active / Pressed
4. Loading
5. Disabled
6. Error
7. Empty
8. Right-to-left mirror

## Examples

**Correct** (token-driven, accessibility-complete):

```tsx
function PrimaryButton({ label, onPress, isLoading }: PrimaryButtonProps) {
  return (
    <Pressable
      onPress={onPress}
      accessibilityRole="button"
      accessibilityLabel={label}
      accessibilityState={{ busy: isLoading, disabled: isLoading }}
      hitSlop={tokens.hitSlop.medium}
      style={({ pressed }) => [
        styles.base,
        pressed && styles.pressed,
        isLoading && styles.loading,
      ]}
    >
      {isLoading ? <Spinner /> : <Text style={styles.label}>{label}</Text>}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  base: { paddingVertical: tokens.space.md, borderRadius: tokens.radius.md,
          backgroundColor: tokens.color.primary },
  pressed: { opacity: 0.8 },
  loading: { backgroundColor: tokens.color.primaryMuted },
  label: { ...tokens.type.bodyEmphasis, color: tokens.color.onPrimary },
});
```

**Incorrect** (raw hex, missing a11y, no states):

```tsx
function PrimaryButton({ label, onPress }) {
  return (
    <Pressable onPress={onPress}                                     // no a11y
      style={{ padding: 12, backgroundColor: '#3478F6' }}>           // raw hex
      <Text style={{ fontSize: 16, color: 'white' }}>{label}</Text>  // raw size
    </Pressable>
  );
}
```
