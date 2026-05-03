<!--
name: changelog-template
purpose: Project changelog in Keep-a-Changelog format adapted for mobile concerns. Maintained at repo root as CHANGELOG.md. Each release is a section.
consumed-by: /changelog, /release-checklist, /patch-notes
placeholders:
  - {{project_name}}
format: keep-a-changelog (https://keepachangelog.com)
versioning: semver — MAJOR.MINOR.PATCH
-->

# Changelog — {{project_name}}

All notable changes to this app are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and adapted for
mobile-app-specific concerns (deployment targets, store metadata, SDK
upgrades).

This project adheres to [Semantic Versioning](https://semver.org/) for the
public API surface (intent URLs, deep links, push payload shape, exported
types). MAJOR is reserved for breaking forced-upgrade releases.

## [Unreleased]

### Added

- {{feature}}

### Changed

- {{change}}

### Deprecated

- {{thing}}

### Removed

- {{thing}}

### Fixed

- {{bug}}

### Security

- {{security_fix}}

### Mobile-specific

- iOS deployment target: {{from}} → {{to}}
- Android minSdk / targetSdk: {{from}} → {{to}}
- New permission requested: {{permission}} — rationale
- Privacy nutrition label / Data Safety form change: {{description}}
- New SDK / SDK upgrade: {{name}} {{version}}

---

## [{{version}}] — {{date}}

### Added

- {{feature}} (#{{pr}})

### Changed

- {{change}} (#{{pr}})

### Fixed

- {{bug}} (#{{pr}})

### Security

- {{fix}}

### Mobile-specific

- |

---

## [1.0.0] — YYYY-MM-DD

Initial public release.

### Added

- Initial feature set

### Mobile-specific

- iOS deployment target: 16.0
- Android minSdk: 29 (Android 10)
- Frameworks: {{primary_framework}}
- Telemetry: {{telemetry_stack}}

---

## Conventions for Authors

- One bullet = one user-visible change. Squash internal refactors unless they
  affect users (perf, battery, binary size).
- Reference the PR or issue: `(#123)` or `(STORY-42)`.
- Group by section in this order: Added, Changed, Deprecated, Removed, Fixed,
  Security, Mobile-specific.
- "Mobile-specific" is the place for: deployment-target shifts, permission
  changes, store-metadata shifts, SDK upgrades, push payload changes,
  deep-link scheme changes, intent filter changes.
- A breaking change MUST appear in **Changed** with the prefix `BREAKING:`.
- Do NOT delete past entries — append only.
