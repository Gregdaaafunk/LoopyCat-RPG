# Phase 7 Specification: Cat Evolution System

Project title: LoopyCat RPG

Internal title: Loopy TV RPG

## Goal

Cat becomes hero.

Hero becomes legend.

Phase 7 adds long-term progression, evolution stages, cinematic major victories, and Hall of Fame.

## Progression

Cat Hero gains:

- XP
- Levels
- Titles
- Battle history
- Boss kills

Required systems:

- Level system
- XP rewards
- Milestones
- Unlock effects

## Evolution Stages

Evolution stages are level-based identity upgrades.

Examples:

- Level 1: Street Cat
- Level 5: Toy Hunter
- Level 10: Boss Breaker
- Level 20: Portal Master
- Level 30: Chaos Destroyer

Evolution stage should affect:

- Cat Hero title options
- Profile presentation
- Victory presentation
- Unlock effects
- Hall of Fame records

## XP Rewards

XP should be awarded for:

- Boss defeat
- Rare drops
- First-time boss kills
- Milestone completion
- Major victories

XP should update:

- Current XP
- Level
- Evolution stage
- Unlock effects

## Milestones

Milestones should track meaningful progress.

Examples:

- First boss defeated
- 10 bosses defeated
- First `EPIC` drop
- First `LEGENDARY` drop
- First `MYTHIC` drop
- First full equipment set
- Level 5 reached
- Level 10 reached
- Level 20 reached
- Level 30 reached

Milestones can trigger unlock effects and title updates.

## Cinematic System

After major victory, play a local cutscene.

Do not generate video.

Use local animation and cutscene sequencing.

Required flow:

1. Boss defeated.
2. Portal unstable.
3. Cat Hero appears.
4. Final attack.
5. Boss collapse.
6. Loot explosion.
7. Title update.
8. Reward screen.

## Animation Placeholders

Need animation placeholders:

- `arrival`
- `attack`
- `super_attack`
- `victory`
- `loot_collect`
- `pose`

These placeholders should connect to the local animation engine.

## Hall Of Fame

Store:

- Bosses defeated
- Best drops
- Cat titles
- Rare items

Hall of Fame should celebrate the Cat Hero's history and make progression feel permanent.

## Future Support

Prepare future support for:

- Special events
- Season bosses
- World bosses

Do not build these systems in Phase 7.

## Local Data

Store locally:

- XP
- Level
- Current evolution stage
- Unlocked titles
- Active title
- Battle history
- Boss kill records
- Milestone records
- Unlock effects
- Hall of Fame entries
- Best drops
- Rare item records

## Success Criteria

Phase 7 succeeds when:

- Cat Hero gains XP from battles.
- Cat Hero levels up.
- Evolution stages unlock at milestone levels.
- Titles and unlock effects can be awarded.
- Major victories can play a local cinematic sequence.
- Hall of Fame stores bosses defeated, best drops, cat titles, and rare items.
- Future events, season bosses, and world bosses are placeholders only.
