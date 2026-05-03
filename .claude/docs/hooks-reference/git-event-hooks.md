# Git Event Hooks Reference

Claude Code hooks fire on **harness** events. Git hooks fire on **git**
events. The two are complementary: harness hooks catch what the model
is about to do; git hooks catch what *anyone* (model, human, CI) is
about to do.

This doc covers patterns for the five most useful git hooks on a
mobile project — `pre-commit`, `commit-msg`, `pre-push`, `post-merge`,
`post-checkout` — and how each one integrates with the harness-side
scripts already shipped in `app_dev/.claude/hooks/`.

## Where git hooks live

The native location is `.git/hooks/`. Files there are local-only and
not versioned with the repo. Two ways to manage them:

1. **Husky** (JS projects): `.husky/<event>` files committed to the
   repo, installed on `yarn install` via a `prepare` script. Most
   common for React Native.
2. **Native + symlink**: keep the scripts in `tools/git-hooks/`,
   symlink them into `.git/hooks/` via a one-shot `tools/setup.sh`.
   Framework-agnostic.

For Flutter and the native stacks, option 2 is usually cleaner —
Husky pulls in a Node toolchain you may not otherwise need.

## Integration with the harness hooks

| Git event | Calls (or duplicates logic of) | Why both? |
|---|---|---|
| `pre-commit` | `validate-commit.sh` | Git hook catches **non-Claude** commits (you typing on the CLI). The harness hook catches commits Claude makes. |
| `commit-msg` | (no harness equivalent) | Validates message format after the message is written |
| `pre-push` | `validate-push.sh` | Same dual coverage as commit |
| `post-merge` | (optional) `validate-assets-post-merge.sh` | Sweep the asset tree after pulling in someone else's branch |
| `post-checkout` | (no harness equivalent) | Useful for warning when switching to/from `main` |

A safe pattern is to make every git hook **defer** to the matching
harness hook so logic lives in one place. Example
`tools/git-hooks/pre-commit`:

```bash
#!/usr/bin/env bash
# Wraps the Claude Code harness pre-commit so manual commits get the
# same checks Claude does.
set -uo pipefail

# Build the same JSON envelope the harness sends
COMMAND="git commit"
PAYLOAD=$(jq -n --arg cmd "$COMMAND" \
  '{tool_name:"Bash", tool_input:{command:$cmd}}')

printf '%s' "$PAYLOAD" | .claude/hooks/validate-commit.sh
```

## `pre-commit`

Fires before the commit message editor opens. Stages: lint, type
check, secret scan, fast unit tests on changed files. Block on hard
errors; warn on style.

```bash
#!/usr/bin/env bash
set -uo pipefail

CHANGED=$(git diff --cached --name-only --diff-filter=ACM)
[ -z "$CHANGED" ] && exit 0

# 1) Secret scan (cheap, run first)
if command -v gitleaks >/dev/null 2>&1; then
  gitleaks protect --staged --no-banner -v || exit 1
fi

# 2) Forbidden files
echo "$CHANGED" | grep -qE '(^|/)(\.env(\..*)?|local\.properties)$' && {
  echo "BLOCKED: secret file staged" >&2; exit 1; }
echo "$CHANGED" | grep -qE '\.(keystore|jks|p12|mobileprovision)$' && {
  echo "BLOCKED: signing material staged" >&2; exit 1; }

# 3) Defer the rest to the harness script
COMMAND="git commit"
PAYLOAD=$(jq -n --arg cmd "$COMMAND" \
  '{tool_name:"Bash", tool_input:{command:$cmd}}')
printf '%s' "$PAYLOAD" | .claude/hooks/validate-commit.sh
```

## `commit-msg`

Fires after the message is written. The single argument is a path to
the file containing the message. Block on malformed messages.

The project's commit message rule lives at
`app_dev/.claude/rules/commit-message.md` (path-scoped to git
artefacts). The hook should mirror the rule.

```bash
#!/usr/bin/env bash
# tools/git-hooks/commit-msg
set -uo pipefail

MSG_FILE="$1"
SUBJECT=$(head -1 "$MSG_FILE")

# Conventional Commits + project trailer (PRD/ADR/STORY)
PATTERN='^(feat|fix|chore|docs|style|refactor|perf|test|build|ci|revert)(\([a-z0-9-]+\))?!?: .{1,70}$'

if ! printf '%s' "$SUBJECT" | grep -qE "$PATTERN"; then
  cat >&2 <<EOF
BLOCKED: commit message subject does not follow Conventional Commits.

Expected:
  <type>(<scope>): <subject>

Where <type> is one of:
  feat fix chore docs style refactor perf test build ci revert

Example:
  feat(auth): add email validator for sign-up flow

You wrote:
  ${SUBJECT}
EOF
  exit 1
fi

# Trailer: src/ commits must reference PRD/ADR/STORY somewhere in body
BODY=$(tail -n +2 "$MSG_FILE")
SRC_TOUCHED=$(git diff --cached --name-only | grep -E '^src/' | head -1)
if [ -n "$SRC_TOUCHED" ] \
   && ! printf '%s\n%s' "$SUBJECT" "$BODY" \
        | grep -qE '(PRD-[A-Z0-9-]+|ADR-[0-9]+|STORY-[A-Z0-9-]+)'; then
  echo "BLOCKED: src/ change requires PRD-, ADR-, or STORY- reference in commit." >&2
  exit 1
fi

exit 0
```

The shipped `validate-commit.sh` already warns on this; the git hook
upgrades it to a block once the team is committed to the convention.

## `pre-push`

Fires on `git push` before the push happens. Two arguments: remote
name, remote URL. Stdin is `<local-ref> <local-sha> <remote-ref>
<remote-sha>` per ref being pushed.

```bash
#!/usr/bin/env bash
# tools/git-hooks/pre-push
set -uo pipefail

REMOTE="$1"

# Defer to harness pre-push script
PAYLOAD=$(jq -n \
  --arg cmd "git push $REMOTE" \
  '{tool_name:"Bash", tool_input:{command:$cmd}}')

printf '%s' "$PAYLOAD" | .claude/hooks/validate-push.sh
EXIT=$?
[ "$EXIT" -ne 0 ] && exit "$EXIT"

# Then run the slow framework gate
if [ -f package.json ]; then
  yarn lint && yarn typecheck && yarn test --ci
elif [ -f pubspec.yaml ]; then
  flutter analyze && flutter test
elif [ -f Package.swift ] || ls *.xcworkspace >/dev/null 2>&1; then
  xcodebuild test -scheme App -destination 'platform=iOS Simulator,name=iPhone 16'
elif [ -f settings.gradle ] || [ -f settings.gradle.kts ]; then
  ./gradlew lint test
fi
```

## `post-merge`

Fires after a successful `git merge` (or `git pull` that resulted in a
merge). Single arg `1` if it was a squash, `0` otherwise.

```bash
#!/usr/bin/env bash
# tools/git-hooks/post-merge
set -uo pipefail

# 1) If lockfiles changed, reinstall deps
CHANGED=$(git diff --name-only HEAD@{1} HEAD)
echo "$CHANGED" | grep -qE 'package-lock\.json|yarn\.lock|pubspec\.lock|Podfile\.lock|Gemfile\.lock' && {
  echo "Lockfile changed — re-run 'yarn install' / 'pod install' / 'flutter pub get' as appropriate."
}

# 2) If native config changed, remind to rebuild
echo "$CHANGED" | grep -qE '(android/.*build\.gradle|ios/Podfile|ios/.*\.xcconfig)' && {
  echo "Native config changed — clean build recommended."
}

# 3) Optional: trigger the asset sweep
[ -x .claude/hooks/validate-assets-post-merge.sh ] && {
  PAYLOAD=$(jq -n --arg cmd "git merge" \
    '{tool_name:"Bash", tool_input:{command:$cmd}}')
  printf '%s' "$PAYLOAD" | .claude/hooks/validate-assets-post-merge.sh
}
```

## `post-checkout`

Fires after `git checkout`. Three args: previous HEAD sha, new HEAD
sha, flag (`1` = branch checkout, `0` = file checkout).

```bash
#!/usr/bin/env bash
# tools/git-hooks/post-checkout
PREV="$1"; NEW="$2"; FLAG="$3"
[ "$FLAG" = "0" ] && exit 0   # only branch checkouts

NEW_BRANCH=$(git rev-parse --abbrev-ref HEAD)
case "$NEW_BRANCH" in
  main|master|production)
    echo "WARN: you are now on '${NEW_BRANCH}'. Direct edits here will be blocked by hooks." >&2
    ;;
esac

# Lockfiles changed between branches?
CHANGED=$(git diff --name-only "$PREV" "$NEW")
echo "$CHANGED" | grep -qE 'package-lock\.json|yarn\.lock|pubspec\.lock|Podfile\.lock' \
  && echo "WARN: lockfile differs between branches — install deps." >&2
```

## Conventional Commits format (project default)

```text
<type>(<optional-scope>): <subject>

<optional body explaining why>

<optional trailer>
PRD-AUTH-003
STORY-S5-12
ADR-0014
```

| Type | Use for |
|---|---|
| `feat` | New user-visible behaviour |
| `fix` | Bug fix |
| `chore` | Tooling, deps, repo housekeeping |
| `docs` | Docs-only |
| `style` | Formatting only, no logic |
| `refactor` | Internal restructure, behaviour preserved |
| `perf` | Performance-only change |
| `test` | Add/refactor tests |
| `build` | Build pipeline / native config |
| `ci` | CI config |
| `revert` | Reverts a prior commit |

Scopes used in this template: `auth`, `onboarding`, `payments`,
`navigation`, `analytics`, `a11y`, `motion`, `ios`, `android`, `rn`,
`flutter`, `infra`. Add new ones in
`app_dev/.claude/rules/commit-message.md`, not ad hoc.

## See also

- `app_dev/.claude/rules/` — the path-scoped rules that the
  `commit-msg` and `pre-commit` hooks derive their patterns from.
- `app_dev/.claude/hooks/validate-commit.sh`,
  `validate-push.sh` — the harness counterparts.
