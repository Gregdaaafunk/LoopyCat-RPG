# Boss Spawn Implementation Contract

Project title: LoopyCat RPG AR

## Purpose

Spawn the selected boss only after target lock and persistent anchor creation.

## Inputs

- `lock_confirmed`
- `anchor_id`
- selected `boss_id`
- boss manifest
- boss portrait/name

## Outputs

- `boss_spawned`
- initial `boss_anim_state`: `IDLE` after emergence completes
- initial HP state

## Spawn Rule

Boss is attached to anchor.

Boss does not attach to raw marker pose.

## Spawn Pseudocode

```text
on lock_confirmed:
  ensure anchor exists
  ensure boss assets loaded
  set boss_anim_state = SPAWN
  show TARGET LOCKED
  request portal spawn sequence
  play vortex, smoke, particles, eyes, head, body, reveal, and flash
  when boss body is fully visible:
    show boss name card
    reveal HP
    set boss_anim_state = IDLE
    emit boss_spawned
    start battle
```

## Failure Rule

If tracking enters memory state during spawn:

- Continue from anchor memory.
- Do not cancel.
- Do not reset.
