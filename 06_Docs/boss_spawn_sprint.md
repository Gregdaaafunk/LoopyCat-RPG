# Boss Spawn Sprint

Project title: LoopyCat RPG AR

Internal title: Loopy TV RPG

## Goal

Boss must feel summoned from the toy, not just appear.

## Implementation Scope

Implement portal and boss entrance sequence.

Required:

- `TARGET LOCKED`
- Portal opens from marker
- Vortex animation
- Smoke / particles
- Boss emerges from portal
- Boss name card
- HP appears
- Battle starts

## Runtime Note

This project currently has no runnable app runtime.

This sprint defines the exact portal / boss entrance implementation contract.

Primary module contract:

`02_App/boss_engine/BOSS_ENGINE.md`

Implementation notes:

`02_App/boss_engine/BOSS_SPAWN_IMPLEMENTATION.md`

Portal animation contract:

`02_App/animation_engine/PORTAL_SPAWN_SEQUENCE.md`

## Trigger

Start only after:

- `lock_confirmed`
- Persistent anchor exists
- Boss asset selection is ready

Do not spawn before stable lock.

## Sequence

```text
lock_confirmed
-> show TARGET LOCKED
-> open portal ring at anchor
-> start vortex spin
-> emit smoke and particles
-> boss eyes appear
-> boss head emerges
-> boss body rises
-> full boss locks to anchor
-> screen flash
-> boss name card
-> HP appears
-> battle starts
```

## Timing Plan

Suggested v1 timing:

| Step | Duration |
| --- | --- |
| `TARGET LOCKED` | 500 ms |
| Portal ring open | 500 ms |
| Vortex spin build | 700 ms |
| Smoke / particles | 600 ms overlap |
| Boss eyes | 300 ms |
| Head emerge | 400 ms |
| Body rise | 600 ms |
| Screen flash | 120 ms |
| Boss name card | 700 ms |
| HP reveal | 300 ms |

Total target:

- 3.5 to 4.5 seconds.

## Anchor Rules

- Portal origin is marker anchor center.
- Boss emerges from same anchor.
- Boss remains attached to anchor after spawn.
- Camera can move.
- Boss stays in toy space.

## Visual Layers

Render order:

1. Camera feed.
2. Anchor debug marker if debug enabled.
3. Portal ring.
4. Vortex.
5. Inward particles.
6. Smoke / mist.
7. Boss partial body.
8. Full boss.
9. Flash.
10. Boss name card.
11. HP bar.
12. Battle HUD.

## Boss Animation States

Use:

- `SPAWN`
- `IDLE`

Spawn transition:

```text
boss_anim_state SPAWN
-> boss_spawned
-> portal sequence complete
-> boss_anim_state IDLE
-> battle starts
```

## Events

Consumes:

- `lock_confirmed`

Emits:

- `boss_spawned`

Does not emit:

- `boss_hit`
- `boss_defeated`
- `loot_dropped`

## UI Requirements

Show:

- `TARGET LOCKED`
- Boss name card
- HP bar

Do not show HP before boss has emerged enough to read as present.

## Debug Harness Fields

Show:

- Spawn sequence step
- Portal active flag
- Anchor id
- Boss id
- Boss asset loaded flag
- Boss animation state
- HP visible flag
- Battle started flag

## Failure Cases

### Lock Lost During Portal

Expected:

- Continue portal on persistent anchor.
- Do not cancel instantly.
- Tracking may show memory/unstable state.

### Boss Asset Missing

Expected:

- Stop before battle starts.
- Show debug error.
- Return to boss selection or use placeholder only if explicitly allowed.

### Long Tracking Loss During Spawn

Expected:

- Keep portal/boss state.
- Pause transition if needed.
- Ask user to show marker again.

## Acceptance Criteria

Boss Spawn Sprint is ready when:

- `TARGET LOCKED` appears after stable lock.
- Portal opens from marker anchor.
- Vortex, smoke, and particles play.
- Boss emerges in parts, not as a simple fade-in.
- Boss name card appears.
- HP appears.
- Battle starts only after spawn sequence.
- Boss remains attached to anchor.
