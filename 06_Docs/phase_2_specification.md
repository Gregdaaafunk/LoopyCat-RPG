# Phase 2 Specification: Arcade Battle Upgrade

Project title: LoopyCat RPG

Internal title: Loopy TV RPG

## Goal

Make the toy battle feel like a real arcade game.

Phase 2 adds:

- Better bosses
- Better combat
- Better visuals

Do not build:

- Inventory
- Cat avatars
- AR fitting
- Full RPG progression

## Boss System

Phase 2 needs a random boss system with 10 bosses.

Spawn rules:

- Select one boss randomly at battle start.
- Avoid repeating the same boss every time.
- Track the previous boss and exclude it from the next random selection when possible.
- Spawn the selected boss only after marker lock and anchor creation are stable.

## Boss Data

Each boss must expose:

- `boss_id`
- `boss_name`
- `boss_type`
- `boss_phase`
- `boss_drop_table`

`boss_drop_table` is placeholder data only in Phase 2. It must not create inventory items yet.

## Boss Presentation

Each battle should start with arcade-style presentation.

Required presentation:

- Boss intro animation
- Street Fighter style presentation
- VS screen
- Boss name card
- Portal spawn animation

The intro should make the fight feel staged and intentional, not like a debug spawn.

## Portal Spawn Animation

When the marker is detected and lock is confirmed:

1. Create anchor at marker position.
2. Show `TARGET LOCKED`.
3. Open portal / vortex from marker center.

Portal style:

- Circular vortex
- Spiral energy
- Glowing ring
- Particles pulled inward
- Smoke/mist
- Arcade magic effect
- Monster summoning from the toy

Boss spawn must be a dramatic emergence, not a simple appearance.

Monster emergence sequence:

1. Smoke appears first.
2. Eyes appear.
3. Head emerges.
4. Body rises.
5. Full boss form locks into place.

Full animation sequence:

1. `LOCK CONFIRMED`
2. Portal ring opens.
3. Vortex spins.
4. Monster rises out.
5. Screen flash.
6. Boss name card appears.
7. HP bar appears.
8. Fight starts.

Anchor requirements:

- Boss must remain attached to the marker anchor.
- Portal is born from the marker.
- Boss emerges from that same point.
- Portal, boss, name card timing, and HP reveal must preserve the feeling that the toy summoned the boss.

Style target:

- Street Fighter presentation
- Arcade boss intro
- Magical toy portal

No simple fade-in.

## Boss States

Bosses use these states:

- `IDLE`
- `PHASE_1`
- `PHASE_2`
- `ENRAGED`
- `DEFEATED`

### IDLE

Boss is loaded but not actively fighting.

Use during intro, VS screen, name card, and pre-fight timing.

### PHASE_1

Normal behavior.

Active when boss HP is above 60%.

### PHASE_2

More aggressive behavior.

Active when boss HP is from 30% to 60%.

### ENRAGED

Most aggressive behavior.

Active when boss HP is below 30%.

### DEFEATED

Boss has reached 0 HP.

Use for KO animation, victory state, loot placeholder reveal, and recording finish moments.

## HP Phases

HP phase thresholds:

- HP > 60%: normal behavior
- HP 30-60%: more aggressive behavior
- HP < 30%: enraged mode

Phase changes must be visible through animation, effects, pacing, or UI feedback.

## Combat Feel

Phase 2 combat should feel readable, punchy, and game-like.

Required combat feedback:

- Basic hit reaction
- Combo system
- Critical system
- Boss emotion
- Impact effects
- KO sequence
- Floating damage
- Damage numbers
- Comic hit text
- Screen flash
- Particles
- Lock effects
- Victory burst

Required text:

- `HIT`
- `LIGHT HIT`
- `DOUBLE HIT`
- `TRIPLE HIT`
- `COMBO x5`
- `COMBO x10`
- `CRITICAL`
- `SUPER HIT`
- `MEGA HIT`

Criticals require camera punch, screen flash, larger particles, heavy sound, and 150-250 ms slow motion.

Boss emotion thresholds:

- HP > 70: normal
- HP 70-40: angry
- HP < 40: `ENRAGED`
- HP < 10: `DESPERATE`

Hits should feel immediate, but must not destabilize the marker lock, world anchor, or boss position.

## KO And Victory

Required end-of-fight flow:

1. Boss HP reaches 0.
2. Boss enters `DEFEATED`.
3. Freeze frame plays for 200 ms.
4. `KO` appears.
5. Boss launch and collapse play.
6. Portal collapse begins.
7. KO animation plays.
8. Victory state begins.
9. Victory burst plays.
10. Loot v1 placeholder appears.

Victory state must be clear in both live play and saved video.

## Loot V1

Phase 2 loot is placeholder-only.

Rarities:

- `common`
- `rare`
- `epic`
- `legendary`

Loot should appear as a reward result after victory, but must not connect to inventory.

Do not build inventory in Phase 2.

## Recording Requirements

The saved battle video must include:

- VS screen or boss intro
- `TARGET LOCKED`
- Portal ring
- Vortex
- Monster emergence
- Boss name card
- Boss
- Damage numbers
- Comic hit text
- Screen flash
- Particles
- KO animation
- Victory state
- Loot placeholder reveal
- UI

## Success Criteria

Phase 2 succeeds when:

- A battle randomly selects from 10 bosses.
- The same boss is not repeated every time.
- The fight has an arcade intro, VS screen, and boss name card.
- Bosses transition through HP phases.
- Damage and hit feedback are visible and satisfying.
- Boss defeat triggers KO, victory, and loot placeholder flow.
- Inventory, avatars, and AR fitting remain out of scope.
