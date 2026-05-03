# Rules Reference

Path-scoped coding and authoring rules live in `.claude/rules/`. Each rule
file uses YAML frontmatter to declare which paths it governs. When an agent
edits a file, the matching rules are loaded into its context automatically.

| Rule file | Applies to | Owner |
|---|---|---|
| `mobile-code.md` | All app source under `src/` regardless of framework | `lead-developer` |
| `react-native-code.md` | RN/TS files (`*.ts`, `*.tsx`) | `react-native-specialist` |
| `swift-code.md` | iOS Swift files (`*.swift`) | `swift-specialist` / `swiftui-specialist` |
| `kotlin-code.md` | Android Kotlin files (`*.kt`, `*.kts`) | `kotlin-specialist` / `jetpack-compose-specialist` |
| `flutter-code.md` | Flutter Dart files (`*.dart`) | `flutter-specialist` / `dart-specialist` |
| `ui-code.md` | UI surfaces across stacks (screens, components, theme) | `visual-design-director` + UI specialists |
| `prototype-code.md` | Throwaway prototypes under `prototypes/` (relaxed standards) | `prototyper` |
| `design-docs.md` | PRDs and design docs under `design/` | `product-designer` / `lead-designer` |
| `data-files.md` | Config, JSON, YAML, and remote-config payloads | `mobile-architect` |
| `content-writing.md` | UX writing, microcopy, push and email copy | `content-designer` |
| `test-standards.md` | Test files under `tests/` | `qa-lead` |

## How Rules Are Applied

Each rule file starts with frontmatter like:

```yaml
---
paths:
  - "src/**/*.ts"
  - "src/**/*.tsx"
---
```

Claude Code matches the file path being edited against the `paths` glob and
loads the rule body into the relevant agent's context. The body lists
required, forbidden, and guarded patterns with short examples.

## Authoring a New Rule

1. Decide the path scope. Be specific — overly broad rules trigger on
   irrelevant files and increase token costs.
2. Pick an owner. The owner is the agent that enforces the rule.
3. Write the rule body with these sections:
   - **Required**: things that must be true (with examples).
   - **Forbidden**: things that must not appear (with examples).
   - **Guarded**: things that need extra approval or sign-off.
   - **Examples**: side-by-side correct vs. incorrect.
4. Add the file to this index.

## Conflict Resolution

When two rules disagree (rare but possible — for example, the
cross-platform `mobile-code.md` and the framework-specific
`react-native-code.md`):

1. The more specific rule wins (file-extension match beats path-prefix match).
2. If both rules are equally specific, the framework-specific rule wins.
3. If still tied, escalate to `mobile-architect`.
