# Claude Code App Studios -- Mobile App Studio Agent Architecture

A coordinated team of 53 Claude Code subagents that build, ship, and operate
mobile apps end to end. Each agent owns a narrow slice of the lifecycle so
that responsibility, expertise, and review checkpoints stay separated and
observable.

## Technology Stack

- **Framework**: [CHOOSE: React Native + TypeScript / Flutter + Dart / Native iOS (Swift) / Native Android (Kotlin)]
- **Language**: [CHOOSE: TypeScript / Dart / Swift / Kotlin]
- **Target Platforms**: iOS 17+ and Android 13+ unless otherwise scoped
- **Source Control**: Git, trunk-based with short-lived feature branches
- **Build & Distribution**: [SPECIFY after framework is chosen — Fastlane, EAS, Xcode Cloud, Play Console, App Store Connect]
- **Backend**: [SPECIFY — REST/GraphQL service, Firebase, Supabase, custom]

> **Note**: Framework specialists exist for each of the four supported stacks
> with dedicated language and UI sub-specialists. Use the set that matches
> the framework you have chosen. Never mix specialists across stacks for the
> same surface area without an ADR.

## Domain Glossary

The repository uses mobile-product vocabulary throughout. When reading legacy
notes that reference any of these terms, translate as follows:

| Term in this template | Means |
|---|---|
| framework | The chosen mobile stack (RN, Flutter, iOS native, Android native) |
| app | The product itself |
| user | The person using the app |
| screen / flow / journey | A view, a multi-step task, the longitudinal path |
| PRD | Product requirements document — the single source of truth per feature |
| user test / beta | Pre-release validation with real users (TestFlight, Play internal track) |
| monetization / pricing | Revenue model (IAP, subscriptions, ads, paid app) |
| animations / transitions | Motion design including micro-interactions |
| haptics, sound, push notifications | Sensory and out-of-app communication channels |
| backend integration / sync | API consumption, offline cache, conflict resolution |
| mobile security | Cert pinning, RASP, jailbreak/root detection, secure storage |
| flow-designer / journey-designer | The agent that owns end-to-end task design |
| product-director | Final authority on product direction |
| visual-design-director | Owns the visual system and UI design language |
| motion-director | Owns motion, haptics, and sonic identity |

## Project Structure

@.claude/docs/directory-structure.md

## Framework Version Reference

@docs/framework-reference/FRAMEWORK.md

## Technical Preferences

@.claude/docs/technical-preferences.md

## Coordination Rules

@.claude/docs/coordination-rules.md

## Collaboration Protocol

**User-driven collaboration, not autonomous execution.**
Every task follows: **Question -> Options -> Decision -> Draft -> Approval**

- Agents MUST ask "May I write this to [filepath]?" before using Write/Edit tools
- Agents MUST present at least two viable options for any non-trivial decision
- Multi-file changes require explicit approval for the full changeset
- No commits without user instruction
- Store-facing copy, pricing, and analytics events are user-approved before code lands

See `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` for the full protocol with mobile-app examples.

> **First session?** If the project has no framework configured and no product
> brief yet, invoke the `/start` skill to walk through onboarding.

## Coding Standards

@.claude/docs/coding-standards.md

## Context Management

@.claude/docs/context-management.md
