# Agent Coordination Map

A visual reference for who reports to whom, who can delegate to whom, and
how to route the most common workflows. Pair this with
`coordination-rules.md` (which defines the rules in prose) and
`director-gates.md` (which defines the standard review prompts).

## Hierarchy

```text
                              [Studio Head — Human]
                                         |
            +----------------------------+----------------------------+
            |                            |                            |
   product-director           mobile-architect                    producer
            |                            |                       (coordinates
            |                            |                        all leads)
   +--------+--------+        +----------+-----------+
   |        |        |        |          |          |
 lead-     visual-  motion-   lead-      qa-lead    release-
 designer  design   designer  developer             manager
           director
   |        |                  |
   |        |                  +----------+----------+----------+----------+
   |        |                  |          |          |          |          |
   |        |              cross-      iOS leads   Android    backend    tools-
   |        |              platform                leads      leads      engineer
   |        |                  |          |          |          |
   |        |             react-native- ios-      android-    backend-
   |        |             specialist    specialist specialist  engineer
   |        |             flutter-      swift-    kotlin-     api-
   |        |             specialist    specialist specialist  designer
   |        |             typescript-   swiftui-  jetpack-    graphql-
   |        |             specialist    specialist compose-    specialist
   |        |             dart-                   specialist  database-
   |        |             specialist                          specialist
   |        |             state-mgmt-                         offline-sync-
   |        |             specialist                          specialist
   |        |             animation-                          push-
   |        |             specialist                          notification-
   |        |                                                 specialist
   |        |                                                 firebase-
   |        |                                                 specialist
   |        +- interaction-designer
   |        +- info-architect
   |        +- prototyper
   |        +- accessibility-specialist (advisory across UI)
   |
   +- product-designer
   +- ux-designer
   +- user-researcher
   +- content-strategist
   +- content-designer
   +- brand-director

  Quality / Ops report to producer + relevant lead:
    qa-lead          → producer (planning) + mobile-architect (gates)
      qa-tester
      mobile-test-automation
    performance-analyst → mobile-architect
    security-engineer   → mobile-architect
    mobile-devops       → producer (delivery) + mobile-architect (build chain)
    release-manager     → producer
    accessibility-specialist → lead-designer (design) + qa-lead (audit)

  Growth / Live ops report to product-director:
    analytics-engineer
    growth-engineer
    monetization-designer
    localization-lead
    community-manager
    live-ops-designer

  Tools / misc report to mobile-architect:
    tools-engineer
    ai-engineer
    payment-integration-specialist
```

## Delegation Authority

| From | May delegate to |
|---|---|
| `product-director` | `lead-designer`, `brand-director`, `monetization-designer`, `growth-engineer`, `community-manager`, `live-ops-designer` |
| `mobile-architect` | `lead-developer`, `mobile-devops`, `performance-analyst`, `security-engineer`, `tools-engineer`, `ai-engineer` |
| `producer` | Any agent (assigning tasks within their domain only) |
| `lead-designer` | `product-designer`, `ux-designer`, `visual-design-director`, `interaction-designer`, `motion-designer`, `info-architect`, `content-strategist`, `content-designer`, `prototyper`, `user-researcher` |
| `lead-developer` | All engineering specialists (cross-platform, iOS, Android, backend, animation, state-mgmt) |
| `qa-lead` | `qa-tester`, `mobile-test-automation`, `accessibility-specialist` (audit work) |
| `release-manager` | `mobile-devops`, `qa-lead` (release-quality testing) |
| `localization-lead` | `content-designer` (string review), UI specialists (text fitting) |
| `monetization-designer` | `payment-integration-specialist`, `analytics-engineer` (revenue events) |
| `live-ops-designer` | `community-manager`, `analytics-engineer`, `growth-engineer` |
| Engine/UI specialists | (advise programmers; do not delegate downward) |

## Escalation Paths

| Situation | Escalate to |
|---|---|
| Two designers disagree on a flow | `lead-designer` |
| Designer vs. engineer feasibility dispute | `producer` facilitates → `product-director` + `mobile-architect` if unresolved |
| Architecture pattern disagreement | `mobile-architect` |
| Cross-system code conflict | `lead-developer` → `mobile-architect` |
| Schedule conflict between teams | `producer` |
| Scope exceeds capacity | `producer` → `product-director` for cuts |
| Quality gate dispute | `qa-lead` → `mobile-architect` |
| Performance budget violation | `performance-analyst` flags, `mobile-architect` decides |
| Visual vs. motion direction conflict | `lead-designer` → `product-director` |
| Privacy / data handling concern | `security-engineer` → `mobile-architect` → `product-director` |
| Monetization placement vs. UX | `monetization-designer` + `ux-designer` → `product-director` |

## Common Workflow Patterns

### 1. New Feature

```text
1. product-director         -- Aligns the feature on roadmap
2. product-designer         -- Authors the PRD
3. ux-designer              -- Drafts the flow + edge paths
4. visual-design-director   -- Visual comps using design system
5. motion-designer          -- Motion and haptics direction
6. mobile-architect         -- Architecture sign-off (ADR if novel)
7. producer                 -- Sprint plan, dependencies
8. [framework specialist]   -- Implementation
9. animation-specialist     -- Motion implementation
10. qa-lead                 -- Test plan
11. qa-tester / automation  -- Execute tests
12. accessibility-specialist -- A11y audit
13. lead-developer          -- Code review
14. producer                -- Mark done
```

### 2. Bug Fix

```text
1. qa-tester                -- Files bug report
2. qa-lead                  -- Triage (severity / priority)
3. producer                 -- Assign to sprint or hotfix
4. lead-developer           -- Root cause + assign specialist
5. [framework specialist]   -- Fix
6. lead-developer           -- Code review
7. qa-tester                -- Verify + regression
8. qa-lead                  -- Close
```

### 3. Pricing or Paywall Change

```text
1. monetization-designer    -- Proposes the change with revenue model
2. product-director         -- Approves direction
3. ux-designer              -- Paywall flow update
4. content-designer         -- Pricing copy
5. payment-integration-specialist -- StoreKit / Play Billing impl
6. analytics-engineer       -- Update revenue events
7. localization-lead        -- Translate pricing strings
8. qa-lead                  -- Test sandboxed purchase paths
9. release-manager          -- Roll out gradually with remote config
```

### 4. New Screen End-to-End

```text
1. info-architect           -- Slot the screen into nav
2. ux-designer              -- Flow + states (loading/empty/error)
3. visual-design-director   -- Comp using tokens
4. content-designer         -- Microcopy
5. interaction-designer     -- Gesture and feedback details
6. [framework specialist]   -- Build
7. animation-specialist     -- Transitions
8. accessibility-specialist -- A11y pass
9. qa-tester                -- Test plan + execution
```

### 5. Sprint Cycle

```text
1. producer                 -- /sprint-plan new
2. [agents]                 -- Execute stories
3. producer                 -- /sprint-status checkpoints
4. qa-lead                  -- Continuous testing
5. lead-developer           -- Continuous code review
6. producer                 -- Sprint retrospective
```

### 6. Beta Release

```text
1. producer                 -- Declares beta candidate
2. release-manager          -- Cuts release branch
3. qa-lead                  -- Full regression
4. accessibility-specialist -- A11y sign-off
5. localization-lead        -- String coverage check
6. performance-analyst      -- Cold-start + scroll budgets
7. mobile-devops            -- Build artefacts to TestFlight + Play internal track
8. user-researcher          -- Beta cohort instructions
9. community-manager        -- Beta release notes
```

### 7. Store Release

```text
1. release-manager          -- /launch-checklist
2. visual-design-director   -- Store screenshots, hero art
3. content-designer         -- Store listing copy
4. localization-lead        -- Localize listing
5. mobile-devops            -- Submit build (TestFlight → App Store, Internal → Production)
6. release-manager          -- Staged rollout (Play) / phased release (App Store)
7. qa-lead                  -- Smoke check on each rollout step
8. analytics-engineer       -- Watch crash-free rate + funnel
9. release-manager          -- Mark complete; tag release
```

### 8. Live Ops Experiment

```text
1. growth-engineer          -- Experiment hypothesis + KPI
2. analytics-engineer       -- Event + segmentation plan
3. product-designer         -- Variant PRD
4. [framework specialist]   -- Variant implementation behind a flag
5. monetization-designer    -- If revenue impacted
6. release-manager          -- Roll out behind remote config
7. growth-engineer          -- Read out + decide
```

## Cross-Department Notification

### PRD revision
`product-designer` notifies: `mobile-architect`, `qa-lead`, `producer`,
implementing engineering specialist, `analytics-engineer` (if metrics
change), `localization-lead` (if strings change).

### ADR revision
`mobile-architect` notifies: `lead-developer`, all affected specialists,
`qa-lead`, `producer`, `mobile-devops` (if build chain changes),
`security-engineer` (if posture changes).

### Design system change
`visual-design-director` notifies: `motion-designer`,
`accessibility-specialist`, all UI specialists, `localization-lead`,
`mobile-devops` (if asset pipeline changes).

## Anti-Patterns

1. **Skipping the hierarchy.** A specialist deciding scope or product
   direction is overstepping; route to the lead.
2. **Cross-domain implementation.** A specialist editing files outside its
   declared paths without delegation is a coordination break.
3. **Verbal-only decisions.** Decisions that affect code, design, or
   schedule must land in a PRD, ADR, or session-state file.
4. **Monolithic stories.** Anything that cannot finish in three days
   should be broken down before sprint inclusion.
5. **Assumption-driven implementation.** When a PRD is ambiguous, file a
   clarification with the author. Wrong guesses are more expensive than
   asked questions.
