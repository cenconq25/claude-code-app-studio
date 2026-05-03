# settings.local.json Template

`settings.local.json` is a per-developer override file that augments
`.claude/settings.json`. It is **not** committed. Use it to grant your
local user extra permissions or to disable hooks that get in your way.

Copy the JSON below to `.claude/settings.local.json` at the project root
and edit. Claude Code merges it on top of `settings.json` at session start.

## Skeleton

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [],
    "deny": []
  },
  "hooks": {}
}
```

## Common Patterns

### Allow extra commands

```json
{
  "permissions": {
    "allow": [
      "Bash(brew install*)",
      "Bash(brew upgrade*)",
      "Bash(open -a Simulator*)",
      "Bash(xcrun simctl*)",
      "Bash(adb devices*)",
      "Bash(adb logcat*)",
      "Bash(fastlane*)",
      "Bash(eas build*)",
      "Bash(maestro test*)",
      "Bash(./gradlew assembleDebug*)"
    ]
  }
}
```

### Disable a hook locally

The merged settings inherit hooks from `settings.json`. To disable one
locally, override the relevant event with an empty array:

```json
{
  "hooks": {
    "PreToolUse": []
  }
}
```

(Re-enable by removing that block.)

### Quieter status line

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash .claude/statusline.sh | sed 's/ctx: [0-9]*% | //'"
  }
}
```

### Block known-noisy paths from being read

```json
{
  "permissions": {
    "deny": [
      "Read(node_modules/**)",
      "Read(android/build/**)",
      "Read(ios/Pods/**)",
      "Read(.expo/**)"
    ]
  }
}
```

## What Belongs Here

- Personal allowlist for tools you have installed locally.
- Personal denylist for paths you never want Claude to read.
- Locally-disabled hooks (with a note explaining why).
- Personal status line format.

## What Does NOT Belong Here

- Anything teammates need (that's `settings.json`).
- Secrets or credentials.
- Hook scripts themselves (those live in `.claude/hooks/`).
- New skills or agents (those live in `.claude/skills/` and `.claude/agents/`).
