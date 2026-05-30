# Task 5: Boss Spawn Sprint

## Goal

Boss feels summoned from the toy, not placed on screen.

## Implemented Contract

Primary contract:

`02_App/boss_engine/BOSS_ENGINE.md`

Related contracts:

- `02_App/tracking_engine/TRACKING_ENGINE.md`
- `02_App/render_composition/RENDER_COMPOSITION_DECISION.md`
- `06_Docs/boss_asset_system.md`

## Decisions

- `TARGET LOCKED` appears after stable lock.
- Portal opens from the persistent marker anchor.
- Portal and boss share the same anchor.
- Boss HP initializes once when the boss instance is created.
- `boss_spawned` emits after the entrance sequence, name card, and HP reveal.

## Spawn Sequence

```text
TARGET LOCKED
-> portal seed
-> glowing ring
-> vortex
-> smoke / particles
-> eyes
-> head
-> body
-> full reveal
-> portal flash
-> boss name card
-> HP
-> boss_spawned
-> battle starts
```

## Done

- `TARGET LOCKED` timing defined.
- Portal-from-marker behavior defined.
- Vortex animation phase defined.
- Smoke and particles defined.
- Boss emergence sequence defined.
- Boss name card timing defined.
- HP reveal timing defined.
- Battle start boundary defined.

## Acceptance

The sprint is accepted when:

- Spawn cannot happen before stable target lock.
- Portal origin follows anchor memory.
- Boss emerges in visible stages.
- HP and name card appear before battle input begins.
- Relock does not replay spawn or reset HP.
