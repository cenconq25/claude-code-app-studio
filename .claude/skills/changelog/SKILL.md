---
name: changelog
description: "Auto-generate a changelog from git commits, sprint data, and design docs. Produces both internal (engineering-facing) and user-facing (release-notes) versions for a given release window."
argument-hint: "[--from=<tag-or-date> | --to=<tag-or-date> | --version=<v>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash, AskUserQuestion
model: sonnet
---

# Changelog

Translate a git history window plus the corresponding sprint and PRD
context into a clean changelog. The internal version explains what
shipped and why; the user-facing version is short, plain, and
respectful of store character limits.

---

## Phase 1: Resolve the Window

Parse arguments:

- `--from=<tag-or-date>` and `--to=<tag-or-date>` define the explicit
  window.
- `--version=<v>` looks up the previous release tag and uses it as the
  `--from`.
- Default: `--from` = previous release tag, `--to` = HEAD.

Use Bash:

```
git tag --sort=-creatordate | head -n 5
git log --pretty=format:'%h%x09%s%x09%an' [from]..[to]
```

Capture commits, authors, and SHAs.

---

## Phase 2: Pull Auxiliary Context

Read in parallel:

- Sprint files closed within the window: `production/sprints/sprint-*.md`.
- Story files closed within the window:
  `production/epics/**/story-*.md` filtered by `Status: Complete` and
  `Closed: [in-window]`.
- Bug records closed within the window: `production/qa/bugs/BUG-*.md`
  filtered by `Status: Closed` and a closing date in window.
- PRD updates in the window via `git log -- design/prd/`.
- ADRs accepted in the window via `git log -- docs/architecture/`.

---

## Phase 3: Categorize Commits

Run each commit through a classifier:

- **Features** — commit message includes "feat" / "feature" / refers
  to a story closing as new functionality.
- **Improvements** — "perf", "improve", "polish", "tune".
- **Fixes** — "fix", "bug", references a BUG ID.
- **Security** — "security", "CVE", references a security audit
  finding.
- **Internal** — "refactor", "chore", "test", "ci", "docs", "style".
- **Reverted** — `Revert "..."` style messages.

For each commit, attempt to enrich:

- Linked story (commit body or branch name often contains `STORY-NN`).
- Linked bug (BUG-NN).
- Linked PRD section.

---

## Phase 4: Internal Changelog

Render at one entry per change. Structure:

```markdown
# Internal Changelog — [version]

Window: [from] -> [to]
Author count: [N]
Commit count: [N]

## Features
- [STORY-NN] [headline] — [PRD ref] (commits: abc123, def456)
  Notes: [summary, framework notes, ADR ref]

## Improvements
- [headline] — [perf-profile reference if perf-related]

## Fixes
- [BUG-NN] [headline] (commits: ...)

## Security
- [security-audit ref] [summary]

## Internal / Refactors
- [headline]

## Reverted
- [reverted commit + reason if known]

## Notes for Engineers
- API changes: [list]
- Migration steps: [list]
- Deprecations introduced: [list]
- New ADRs: [IDs]

## Stats
- Stories closed: [N]
- Bugs closed: [N]
- Test files added: [N]
- LOC delta: [+P / -Q]
```

Ask before writing to
`production/releases/changelog-internal-[version].md`.

---

## Phase 5: User-Facing Changelog

Translate Internal -> User-facing. Apply these rules:

- Drop Internal / Refactor entries entirely.
- Drop Reverted entries unless user-visible.
- Rewrite headlines to user benefit, not implementation:
  - "Refactor cart reducer to immutable state" -> drop.
  - "Add Apple Pay to checkout" -> "Apple Pay now works at checkout."
  - "Fix race condition in token refresh" -> "Sign-in is more reliable
    when switching networks."
- Group by theme that makes sense to a user, not an engineer.
- Keep entries terse — one line per change unless context truly needs
  two.

Render two formats:

### Long form (in-app updates feed, release notes page)

```markdown
# What's New — [version]

## New
- Apple Pay at checkout
- Dark mode for the home feed

## Improvements
- Faster cold start
- Smoother list scrolling

## Fixes
- Sign-in is more reliable when switching networks
- The paywall no longer flickers on slow connections

## Coming soon
- [list teased items if approved by marketing]
```

### Short form (App Store / Play Store What's New)

App Store limit: 4000 chars. Play Store limit: 500 chars.

Produce a 500-char version that hits the highlights:

```
We've added Apple Pay at checkout and dark mode for the home feed.
Cold start is faster and list scrolling is smoother. Sign-in is more
reliable when you switch networks, and we squashed a paywall flicker.
Thanks for using [App Name].
```

Show character counts and ask the user to approve.

---

## Phase 6: Translate User-Facing for Locales

Pull the target locale list from `.claude/docs/technical-preferences.md`.
For each locale:

- If a translation pipeline exists (vendor, MT), tag the user-facing
  copy as `# UNTRANSLATED` and write it to
  `production/releases/changelog-user-[version]-[locale].md` for the
  vendor.
- If a vendor is not configured, surface this as an open item to
  resolve before submission.

Ask before each write.

---

## Phase 7: Render and Save

Ask:

- "May I write Internal changelog to `production/releases/changelog-internal-[version].md`?"
- "May I write User long-form to `production/releases/changelog-user-[version].md`?"
- "May I write Short form (App Store) to `production/releases/whats-new-[version]-app-store.md`?"
- "May I write Short form (Play Store) to `production/releases/whats-new-[version]-play-store.md`?"

---

## Phase 8: Update State

Append to `production/session-state/active.md`:

```
## Changelog — [date]
- Window: [from] -> [to]
- Internal: [path]
- User long: [path]
- User App Store: [path]
- User Play Store: [path]
- Locales pending translation: [list]
- Next: /patch-notes for short-form polishing, then /release-checklist
```

---

## Quality Gates / PASS-FAIL

- PASS — internal changelog has every commit categorized; user-facing
  drops internal noise; short-form fits within store limits; no
  PRD-private detail leaks to user-facing.
- FAIL — internal text leaked into user-facing, or short-form exceeds
  store limits.

---

## Examples

**Example 1 — minor v1.3.0:**
Window covers 2 sprints, 47 commits, 12 stories closed. Internal
changelog produced; user-facing trimmed to 8 bullets; short-form 320
chars. 3 locales tagged for translation.

**Example 2 — patch v1.2.1 (hotfix):**
1 commit, 1 BUG. Internal: one fix entry. User-facing: one bullet
("We fixed an issue causing sign-in to fail intermittently."). Short-
form: 95 chars.

---

## Next Steps

- `/patch-notes` to polish the short-form for store submission.
- `/release-checklist` to make sure submission metadata includes the
  user-facing text.
