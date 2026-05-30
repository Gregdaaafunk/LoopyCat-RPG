# Boss Engine

Project title: LoopyCat RPG AR

## Goal

The boss must feel summoned from the physical toy.

It enters through a portal born from the locked marker anchor instead of appearing as a static image.

## Spawn Trigger

Boss spawn can start only after:

- `tracking_state` is `LOCKED`.
- `lock_confirmed` has an `anchor_id`.
- Selected boss assets are loaded.
- Portal has not already opened for this battle.

UI text:

- Show `TARGET LOCKED` immediately after stable lock.

## Spawn Ownership

`boss_engine` owns:

- Boss instance creation.
- Boss HP initialization.
- Boss phase source data.
- `boss_spawned` emission.

`animation_engine` owns:

- Portal animation playback.
- Vortex animation.
- Smoke and particles.
- Boss emergence motion.
- Name card timing.

`combat_engine` owns:

- Battle start.
- Hit acceptance.
- HP changes after spawn.

## Persistent Boss Instance

The boss instance stores:

- `battle_id`
- `boss_id`
- `boss_name`
- `anchor_id`
- `max_hp`
- `current_hp`
- `boss_phase`
- `boss_anim_state`
- `spawn_sequence_state`
- `has_spawned`
- `portal_opened`
- `battle_started`

Rules:

- HP initializes once when the boss instance is created.
- HP is never reset by marker loss.
- HP is never reset by relock.
- Relock never creates a second boss instance.

## Portal And Entrance Sequence

The first playable spawn sequence:

1. `TARGET LOCKED`
2. Portal seed appears at marker center.
3. Circular ring opens from toy-space anchor.
4. Vortex spirals inward.
5. Particles pull into portal center.
6. Smoke and mist push outward.
7. Boss eyes appear inside the portal.
8. Boss head emerges.
9. Boss body rises.
10. Full boss form locks to anchor.
11. Portal flash.
12. Boss name card appears.
13. HP appears.
14. `boss_spawned` is emitted.
15. Battle starts.

## Spawn Timing Prototype

```text
0 ms      TARGET LOCKED
100 ms    portal seed
250 ms    glowing ring expands
450 ms    vortex reaches full strength
650 ms    smoke and particles begin
900 ms    eyes appear
1150 ms   head emerges
1450 ms   body rises
1750 ms   full boss reveal
1900 ms   portal flash
2050 ms   boss name card
2300 ms   HP appears
2400 ms   emit boss_spawned
2500 ms   combat state can enter IDLE
```

## Anchor Attachment

The portal and boss read the same persistent anchor:

- Portal origin: anchor center.
- Boss root: anchor center with spawn offset.
- HP and name card: screen-space projection of boss root.
- Damage numbers: boss hit socket projected from boss root.

Tracking loss changes the tracking state only.

Tracking loss does not:

- Delete the boss.
- Hide the HP.
- Restart spawn.
- Replay the portal entrance.
- Reset HP.

## Event Payload

`boss_spawned` payload includes:

- `battle_id`
- `boss_id`
- `anchor_id`
- `boss_phase`
- `boss_anim_state`
- `current_hp`
- `max_hp`
- `spawn_sequence_state`

Required values at battle start:

- `boss_anim_state`: `IDLE`
- `spawn_sequence_state`: `COMPLETE`
- `current_hp`: initialized value, not relock-derived

## Acceptance Tests

- Spawn cannot start before `lock_confirmed`.
- `TARGET LOCKED` appears before portal opening.
- Portal opens from marker anchor center.
- Vortex, smoke, particles, and flash are part of the composed output.
- Boss emerges in stages.
- Boss name card appears before battle starts.
- HP appears before hit acceptance.
- `boss_spawned` emits once for the boss instance.
- Relock does not emit a second `boss_spawned`.
- Boss remains attached to anchor during tracking memory, unstable, and restored states.
