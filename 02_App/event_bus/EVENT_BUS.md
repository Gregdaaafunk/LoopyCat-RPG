# Event Bus

Project title: LoopyCat RPG AR

Purpose:

- Provide one central event system.
- Keep modules decoupled.
- Enforce one owner per event.
- Feed debug harness and recording diagnostics.

## Foundation Rule

One event has one owner.

No duplicate emitters.

Other systems may subscribe to events, but only the owner may emit that event.

## Canonical Foundation Events

| Event | Owner |
| --- | --- |
| `marker_detected` | `tracking_engine` |
| `lock_started` | `tracking_engine` |
| `lock_confirmed` | `tracking_engine` |
| `lock_lost` | `tracking_engine` |
| `lock_restored` | `tracking_engine` |
| `boss_spawned` | `boss_engine` |
| `boss_hit` | `combat_engine` |
| `combo_updated` | `combat_engine` |
| `critical_hit` | `combat_engine` |
| `boss_phase_change` | `boss_engine` |
| `boss_defeated` | `combat_engine` |
| `ko_sequence_started` | `combat_engine` |
| `loot_dropped` | `loot_engine` |
| `loot_reveal_started` | `loot_engine` |
| `loot_collected` | `loot_engine` |
| `reward_saved` | `save_manager` |
| `cat_updated` | `cat_profile_engine` |
| `recording_started` | `recording_engine` |
| `recording_finished` | `recording_engine` |
| `recording_failed` | `recording_engine` |

## Core MVP Events

The minimum events needed to prove the first playable chain:

- `marker_detected`
- `lock_confirmed`
- `boss_spawned`
- `boss_hit`
- `boss_defeated`
- `loot_dropped`
- `reward_saved`
- `recording_started`
- `recording_finished`
- `recording_failed`

## Sprint 4-6 Event Rules

- `lock_confirmed` opens the portal path once for the active battle.
- `lock_lost` is a tracking fact, not a boss despawn command.
- `lock_restored` never resets HP or respawns the boss.
- `boss_spawned` is emitted once per boss instance after the portal entrance, name card, and HP reveal are complete.
- `recording_started` and `recording_finished` must report composed output capture.

## Event Shape

Every event uses the same envelope:

```text
event_id
event_name
owner
battle_id
timestamp
payload
debug_tags
```

Rules:

- `event_id` is unique.
- `timestamp` is monotonic where possible.
- `owner` must match the owner table.
- `payload` is event-specific.
- `debug_tags` are optional and local-only.

## Event Bus Responsibilities

The event bus owns:

- Subscription.
- Emission validation.
- Event ordering.
- Event log buffer for debug harness.
- Local-only diagnostics.

The event bus does not own:

- Gameplay state.
- Save data.
- UI state.
- Rendering.
- Recording.

## Debug Log

The debug harness reads the last events from the event bus.

Minimum log fields:

- Event name
- Owner
- Timestamp
- Battle id
- Payload summary
- Error flag

## Frozen Events

Expanded events from earlier roadmap docs are frozen until after MVP.

Do not implement additional events until the first playable chain works.
