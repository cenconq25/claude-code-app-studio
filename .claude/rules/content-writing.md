---
paths:
  - "design/copy/**"
  - "design/content/**"
  - "src/**/*.strings"
  - "src/**/strings.xml"
  - "src/**/locales/**"
  - "src/**/i18n/**"
  - "src/**/l10n/**"
---

# Content & Microcopy Rules

Owner: `content-designer`. Reviewers: `content-strategist`,
`brand-director`, `localization-lead`, `accessibility-specialist`.

## Required

- Voice and tone follow the project's content style guide
  (`design/content/style-guide.md`). The guide is created once by
  `content-strategist` and revisited per major release.
- Every user-visible string is keyed in the localization catalogue —
  even if the app currently ships only one locale.
- Keys are stable (`auth.signin.error.invalid`), descriptive, and never
  contain English-language hints (`continueButtonLabel` is wrong; the
  label may not say "Continue" in every locale).
- Pluralization uses ICU MessageFormat (or the framework's pluralization
  primitive). Never concatenate strings to handle plurals.
- Buttons and CTAs use verbs: `Sign in`, `Save changes`, `Try again`.
- Errors follow the **what / why / how**:
  - what happened ("We couldn't sign you in.")
  - why ("The password you entered doesn't match.")
  - how to recover ("Try again, or reset your password.")
- Empty states do not just describe absence — they offer the next step
  ("Add your first card to get started.").
- Push notifications and emails use the same voice as the app and
  include a recognisable sender identity in the first 30 characters.

## Forbidden

- Hard-coded strings in source files. Always go through the catalogue.
- Truncated punctuation in non-Latin locales (Japanese, Chinese, Arabic
  often need separate punctuation handling — defer to the
  localization-lead).
- All-caps button labels for text containing non-Latin scripts.
- Placeholder text being used as a label ("Email" floating only as a
  placeholder is wrong; use a label).
- Apologetic tone in errors that are the user's fault. State the
  problem plainly.
- Ambiguous CTAs ("OK", "Submit", "Done") on destructive actions. Use
  verbs that describe the consequence ("Delete account", "Cancel
  subscription").

## Inclusivity & Tone

- Use inclusive language that does not assume gender, ability, age, or
  technical background.
- Avoid idioms that do not localize ("piece of cake", "spill the beans").
- Avoid metaphors borrowed from violence, gambling, or substance use.
- Use sentence case for buttons and headings unless the brand guide says
  otherwise.

## Length and Fitting

- Test every string against the longest reasonable translation. Common
  inflations: German +35%, Russian +30%, French +25%.
- For buttons, design accommodates the longest expected label or
  truncates with `…` (and the full label is available on focus).
- For RTL locales, ensure mirrored layout, cursor direction, and chevron
  direction.

## Accessibility

- Provide an `accessibilityLabel` separately from visible text when the
  visible text is iconographic (e.g., a "..." button gets a label like
  "More actions for [item]").
- Avoid "Click here". Use descriptive link text.

## Examples

**Correct** (key-driven, recoverable error):

```ts
t('auth.signin.error.invalidCredentials')
// "We couldn't sign you in. The email or password is wrong. Try again, or reset your password."
```

**Incorrect** (hard-coded, blames user, no recovery):

```ts
showToast("You typed it wrong. Submit again.")  // VIOLATION
```
