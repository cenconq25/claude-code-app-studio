# CLAUDE.local.md Template

`CLAUDE.local.md` is a per-developer override file that lives next to
`CLAUDE.md` but is **not** committed (it is in `.gitignore`). Use it for
preferences and quirks that should not affect teammates.

To use: copy this file to `CLAUDE.local.md` at the project root, edit
freely, never commit it. Claude Code merges it on top of `CLAUDE.md` at
session start, so anything here takes precedence.

```markdown
# Local Overrides

## Personal Preferences

- Prefer concise responses; skip preamble.
- Always show the diff before writing files.
- When choosing colour systems, default to OKLCH over HSL.

## Local Environment

- Default device for builds: iPhone 16 Pro (sim)
- Default Android device: Pixel 9 Pro (emulator-arm64)
- Local API base: http://localhost:4000
- Locale to test against: en-US, ja-JP

## Local Skills to Always Run

- After every implementation, automatically suggest `/perf-profile` if the
  diff touched a List, FlatList, or LazyColumn.
- After every PRD revision, suggest `/review-all-prds`.

## Personal Shortcuts

- "ship it" → run `/release-checklist` then `/staged-rollout` if PASS.
- "rage" → run `/test-flakiness` and surface the top three offenders.

## Tooling Path Overrides

- xcode-select path: /Applications/Xcode-16.app/Contents/Developer
- Java home: /Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
- Flutter SDK: ~/dev/flutter

## Work-In-Progress Notes (private)

- Currently spiking ADR-0017 — do not surface to teammates yet.
- Keep paywall variant C alive locally for personal testing.
```

## What Belongs Here

- Personal communication preferences (verbosity, formatting).
- Local tool paths and device defaults.
- Private notes you do not want to commit.
- Personal automation shortcuts.

## What Does NOT Belong Here

- Anything teammates need: that goes in `CLAUDE.md` or
  `.claude/docs/technical-preferences.md`.
- Secrets: those live in `.env*` (which is also gitignored).
- Architecture decisions: those live in ADRs.
- Style guides: those live in `.claude/rules/` and `coding-standards.md`.
