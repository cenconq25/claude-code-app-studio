# Agent Coordination Rules

These rules define how the 54 agents work together. They are not optional —
the entire template assumes that agents respect the hierarchy, escalate
disagreements rather than making unilateral calls, and document every
decision in the appropriate file.

## Core Rules

1. **Vertical delegation.** Tier 1 leadership delegates to Tier 2 department
   leads, who delegate to Tier 3 specialists. Skip-level delegation is only
   allowed when the intervening tier is unavailable and the work is
   time-critical; document the skip in the session log.
2. **Horizontal consultation.** Agents at the same tier may consult each
   other freely but cannot make binding decisions outside their domain.
3. **Conflict resolution.** When two agents disagree, escalate to the shared
   parent. With no shared parent, route product disagreements to
   `product-director` and technical disagreements to `mobile-architect`.
4. **Change propagation.** When a product change affects multiple departments
   (for example, a PRD revision that touches data models, UI, and analytics),
   the `producer` coordinates the propagation and confirms each affected
   agent has acknowledged the change.
5. **No unilateral cross-domain edits.** An agent must never modify files
   outside its designated paths without explicit delegation. Path scoping
   is enforced by the `paths:` frontmatter on each rule file.
6. **No silent skips.** When a parallel agent is BLOCKED, surface it
   immediately. Producers and orchestration skills must always emit a
   partial report rather than waiting indefinitely.

## Model Tier Assignment

Skills and agents are pinned to model tiers based on the cognitive load of
the task. Pick the cheapest tier that produces correct output.

| Tier | Model | Use for |
|---|---|---|
| Haiku | `claude-haiku-4-5-20251001` | Read-only status checks, formatting, short lookups, machine-checkable lints — no creative judgement required |
| Sonnet | `claude-sonnet-4-6` | Default. Implementation, single-doc design authoring, individual code reviews, single-system analysis |
| Opus | `claude-opus-4-6` | Multi-document synthesis, phase-gate verdicts, cross-system architectural review, conflict resolution between two specialists |

**Skills pinned to Haiku**: `/help`, `/sprint-status`, `/story-readiness`,
`/scope-check`, `/patch-notes`.

**Skills pinned to Opus**: `/review-all-prds`, `/architecture-review`,
`/gate-check`.

All other skills default to Sonnet. When authoring a new skill: pin Haiku
when the work is "read N files, produce a table", pin Opus when the work is
"synthesise 5+ documents and emit a high-stakes verdict", otherwise leave
unset.

## Subagents vs. Agent Teams

The template uses two distinct multi-agent patterns. Choose the right one.

### Subagents (default — always available)

Spawned via `Task` inside a single Claude Code session. Used by every
`team-*` skill and most orchestration skills. Subagents share the parent
session's permission context and return text only.

**Spawn in parallel** when subagents have independent inputs. Example:
`/review-all-prds` Phase 1 (consistency check) and Phase 2 (UX heuristics)
are independent — issue both Task calls in the same turn.

**Spawn sequentially** when one subagent's output is the next subagent's
input. Example: PRD authoring (`product-designer`) → architecture decision
(`mobile-architect`) is strictly serial.

### Agent Teams (experimental, opt-in)

Multiple independent Claude Code *sessions* coordinated through a shared
task list. Each session has its own context window and budget. Enable with
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

**Use teams when**:
- Work spans subsystems with no file overlap (iOS view + Android view + shared API)
- Each workstream takes >30 minutes and benefits from real parallelism
- A senior agent (`mobile-architect`, `producer`) needs 3+ specialist sessions running concurrently

**Do not use teams when**:
- One session's output is required as input for another (use serial subagents)
- The full task fits in one session's context (use subagents)
- Token cost matters — every team member burns its own budget

**Status in this template**: not yet adopted. Document first use here.

## Parallel Task Protocol

When an orchestration skill spawns multiple independent agents:

1. Issue every independent Task call in the same turn before awaiting any
   single result.
2. Collect all results before advancing to dependent phases.
3. If any agent returns BLOCKED, surface it in the user-visible report
   immediately — do not silently skip its phase.
4. If some agents complete and others block, produce a partial report
   describing what was produced and what is missing.
5. Apply the strictest verdict in any parallel director gate: a single
   NOT READY overrides all READY verdicts.

## Conflict Routing

| Situation | Route to |
|---|---|
| Two designers disagree on a flow | `lead-designer` |
| Designer vs. engineer disagree on feasibility | `producer` facilitates, then `product-director` + `mobile-architect` if unresolved |
| Architecture pattern disagreement | `mobile-architect` |
| Cross-system code conflict | `lead-developer`, then `mobile-architect` |
| Performance budget violation | `performance-analyst` flags, `mobile-architect` decides |
| Schedule conflict between departments | `producer` |
| Quality gate dispute | `qa-lead`, then `mobile-architect` |
| Visual design vs. motion direction | `lead-designer`, then `product-director` |
| Localization vs. UI fitting | `localization-lead` + visual design specialist, then `lead-designer` |
| Monetization placement vs. UX | `monetization-designer` + `ux-designer`, then `product-director` |
| Compliance vs. analytics scope | `security-engineer` + `analytics-engineer`, then `mobile-architect` |

## Cross-Department Notification Patterns

### PRD revision

When `product-designer` updates a PRD, notify:
- `mobile-architect` (system impact)
- `qa-lead` (test plan refresh)
- `producer` (schedule risk)
- The implementing engineering specialist
- `analytics-engineer` if metrics change
- `localization-lead` if user-facing strings change

### ADR change

When `mobile-architect` revises an ADR, notify:
- `lead-developer` (code impact)
- All affected specialists (RN, iOS, Android, Flutter)
- `qa-lead` (test strategy refresh)
- `producer` (schedule risk)
- `mobile-devops` if build pipeline changes
- `security-engineer` if security posture shifts

### Design system change

When `visual-design-director` updates the design system, notify:
- `motion-designer` (motion tokens)
- `accessibility-specialist` (contrast, hit targets)
- All UI engineering specialists
- `localization-lead` (typography fitting)
- `mobile-devops` if asset pipeline is affected

## Anti-Patterns

1. **Skipping director gates** to save time. Gates exist because cheap
   midstream review prevents expensive late-stage rework.
2. **Specialist making product calls.** A `react-native-specialist` choosing
   to drop a feature scope item is overstepping. Escalate to `producer`.
3. **Verbal-only decisions.** Anything that affects code, design, or
   schedule must be written into a PRD, ADR, or session-state file.
4. **Monolithic stories.** Any story expected to take more than three days
   should be broken down. Surface the issue to `producer` if it cannot.
5. **Assumption-driven implementation.** When a PRD is ambiguous, the
   implementer files a clarification question with the PRD author. Wrong
   guesses cost more than questions.
