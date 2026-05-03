---
name: patch-notes
description: "Generate user-facing patch notes from git history, sprint data, and the internal changelog. Translates engineering language into clear, store-appropriate user communication. Respects App Store / Play Store character limits."
argument-hint: "[--version=<v> | --tone=warm|neutral|formal]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
model: haiku
---

# Patch Notes

A focused twin of `/changelog`. Produces only the user-facing,
store-ready patch notes for a release. Haiku tier — this is formatting
and rewording, not synthesis.

---

## Phase 1: Locate Inputs

Parse `--version=<v>`. Default: most recent unreleased tag.

Read in parallel:

- `production/releases/changelog-internal-[version].md` (preferred
  source).
- If no internal changelog exists, read git log for the version window
  and any associated story / bug records.
- `.claude/docs/technical-preferences.md` for target locales.

---

## Phase 2: Pick the Tone

Parse `--tone`. If not given, propose options via AskUserQuestion:

- `warm` — friendly, first-person plural ("We've added...").
- `neutral` — direct, third-person ("[App] now supports Apple Pay").
- `formal` — precise, legal-friendly ("Version [N] introduces support
  for Apple Pay").

Default: warm.

Apply the tone to every line consistently. Mixing tones is a smell.

---

## Phase 3: Distill the Internal Changelog

For each entry in the internal source:

- Drop Internal / Refactor / Reverted entries unless user-visible.
- Drop test-only changes.
- Keep Features, Improvements, Fixes, Security in user-friendly form.

Apply rewriting rules:

- Replace developer terms with user terms: "reducer" -> drop;
  "background fetch" -> "while the app is closed"; "Hermes upgrade" ->
  "faster startup".
- Lead with user benefit: "Cold start improvements" -> "App opens
  faster".
- Avoid passive voice unless required by tone.
- Avoid "we fixed a bug where..." — be specific. "Sign-in no longer
  fails when switching from Wi-Fi to cellular."
- Keep entries punchy — one line per change unless context truly
  helps.

---

## Phase 4: Compose Long Form

```markdown
# What's New in [App] [version]

## New
- [bullet]

## Improvements
- [bullet]

## Fixes
- [bullet]

## Notes
[1-3 lines of plain language about anything users should know — new
permission, etc. Optional.]

Thanks for using [App]. Got feedback? [contact].
```

Show the result. Ask for tone adjustment if needed.

---

## Phase 5: Compose Short Form (Store-Specific)

### App Store What's New (4000 chars)

Allowed to be the long-form essentially. Trim if over 4000 chars.

### Play Store What's New (500 chars)

This is the hard one. Strategy:

1. Lead with the headline feature in one sentence.
2. Mention up to two other notable changes in one sentence.
3. Mention "stability and bug fixes" if there are fixes but they don't
   need names.
4. Stop.

Aim for 300-450 chars to leave room for localized expansion (some
languages run longer).

Example:

```
We've added Apple Pay at checkout and a dark mode for the home feed.
The app now opens faster and scrolls more smoothly. Plus stability
fixes including a more reliable sign-in.
```

Render character count alongside.

---

## Phase 6: Localization

If target locales include non-English markets:

- Tag the long-form and short-form English strings as the source.
- Write source files to:
  - `production/releases/whats-new-[version]-en-app-store.md`
  - `production/releases/whats-new-[version]-en-play-store.md`
- For each target locale, check whether:
  - A translation vendor pipeline is configured -> tag as
    `# UNTRANSLATED — for vendor`.
  - The previous release used machine translation -> propose same
    approach.
  - The team translates manually -> tag for localization-lead review.

For Play Store, remind the user: each locale has its own 500-char
limit, and verbose translations may overflow. Generate per-locale
guidance: "Spanish typically runs 110-115% of English length —
consider a tighter source string."

---

## Phase 7: Save

Ask before each write:

- `production/releases/whats-new-[version]-en-long.md`
- `production/releases/whats-new-[version]-en-app-store.md`
- `production/releases/whats-new-[version]-en-play-store.md`

If localized files were generated, ask per locale.

---

## Phase 8: Update State

Append to `production/session-state/active.md`:

```
## Patch Notes — [date]
- Version: [version]
- Tone: [tone]
- Long form: [path]
- App Store: [path] ([N] chars)
- Play Store: [path] ([N] chars)
- Locales pending: [list]
- Next: localization handoff or paste into store consoles
```

---

## Quality Gates / PASS-FAIL

- PASS — long form covers every user-visible change; short form fits
  within store limits with margin; tone is consistent; no engineering
  jargon leaked through.
- FAIL — short form over limit, internal jargon present
  ("reducer", "Hermes", "race condition" without user phrasing), or
  any reference to internal IDs (BUG-NN, STORY-NN).

---

## Examples

**Example 1 — v1.3.0 with three features and two fixes:**
Long form: 6 bullets across New / Improvements / Fixes. App Store:
fits. Play Store: 412 chars. Tone warm. 3 locales tagged for
translation.

**Example 2 — v1.2.1 hotfix:**
Single bullet: "Fixed an issue that could cause sign-in to fail when
switching networks." Long form 1 line, App Store 1 line, Play Store
86 chars.

---

## Next Steps

- Paste short form into App Store Connect / Play Console.
- For locales, run vendor pipeline.
- Refer to `/release-checklist` to confirm metadata is uploaded.
