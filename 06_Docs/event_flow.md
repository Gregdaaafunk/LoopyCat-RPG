# Event Flow

Project title: LoopyCat RPG AR

Internal title: Loopy TV RPG

## Foundation Sprint Rule

This document is the implementation event contract for Foundation Sprint.

One event has one owner.

No duplicate emitters.

Expanded events from older roadmap docs are frozen until after the first playable chain works.

## Event Bus

The central event system lives in:

`02_App/event_bus/`

Detailed event bus contract:

`02_App/event_bus/EVENT_BUS.md`

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

## Event Envelope

Every event uses:

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
- `event_name` must be in the canonical foundation event list.
- `owner` must match the owner table.
- `battle_id` can be empty before battle starts.
- `timestamp` is monotonic where possible.
- `payload` is event-specific.
- `debug_tags` are local-only.

## Required Event Payloads

### marker_detected

Owner:

- `tracking_engine`

Payload:

- `marker_center_x`
- `marker_center_y`
- `rotation`
- `distance_estimate`
- `tracking_confidence`

### lock_started

Owner:

- `tracking_engine`

Payload:

- `tracking_state`
- `tracking_confidence`

### lock_confirmed

Owner:

- `tracking_engine`

Payload:

- `tracking_state`
- `anchor_id`
- `marker_center_x`
- `marker_center_y`
- `rotation`
- `distance_estimate`
- `tracking_confidence`

### lock_lost

Owner:

- `tracking_engine`

Payload:

- `tracking_state`
- `anchor_id`
- `loss_duration`
- `status`
- `boss_should_remain_visible`

Allowed status:

- `LOCK STABLE`
- `SIGNAL UNSTABLE`
- `SHOW MARKER AGAIN`

### lock_restored

Owner:

- `tracking_engine`

Payload:

- `tracking_state`
- `anchor_id`
- `hit_ignore_ms`
- `status`

Required:

- `hit_ignore_ms`: 400
- `status`: `TARGET RESTORED`

### boss_spawned

Owner:

- `boss_engine`

Payload:

- `battle_id`
- `boss_id`
- `anchor_id`
- `boss_phase`
- `boss_anim_state`
- `current_hp`
- `max_hp`
- `spawn_sequence_state`

Required:

- `spawn_sequence_state`: `COMPLETE`
- `boss_anim_state`: `IDLE`

### boss_hit

Owner:

- `combat_engine`

Payload:

- `battle_id`
- `boss_id`
- `damage`
- `hit_confidence`
- `current_hp`
- `combat_state`

### combo_updated

Owner:

- `combat_engine`

Payload:

- `battle_id`
- `combo_count`
- `combo_label`
- `combo_timer_remaining_ms`

### critical_hit

Owner:

- `combat_engine`

Payload:

- `battle_id`
- `boss_id`
- `damage`
- `critical_label`
- `slow_motion_ms`

### boss_phase_change

Owner:

- `boss_engine`

Payload:

- `battle_id`
- `boss_id`
- `previous_phase`
- `next_phase`
- `current_hp`

### boss_defeated

Owner:

- `combat_engine`

Payload:

- `battle_id`
- `boss_id`
- `final_hp`
- `combat_state`

### ko_sequence_started

Owner:

- `combat_engine`

Payload:

- `battle_id`
- `boss_id`
- `freeze_ms`

Required:

- `freeze_ms`: 200

### loot_dropped

Owner:

- `loot_engine`

Payload:

- `battle_id`
- `boss_id`
- `item_id`
- `item_name`
- `item_rarity`
- `set_name`

### loot_reveal_started

Owner:

- `loot_engine`

Payload:

- `battle_id`
- `item_id`
- `item_name`
- `item_rarity`
- `set_name`
- `reveal_profile`

### loot_collected

Owner:

- `loot_engine`

Payload:

- `battle_id`
- `item_id`
- `cat_id`
- `target`

Required target:

- `inventory`

### reward_saved

Owner:

- `save_manager`

Payload:

- `battle_id`
- `cat_id`
- `item_id`
- `save_result`

### cat_updated

Owner:

- `cat_profile_engine`

Payload:

- `cat_id`
- `cat_name`
- `cat_title`
- `level`
- `xp`

### recording_started

Owner:

- `recording_engine`

Payload:

- `battle_id`
- `mode`
- `is_composed_output`

Required:

- `is_composed_output`: `true`

### recording_finished

Owner:

- `recording_engine`

Payload:

- `battle_id`
- `mode`
- `media_id`
- `saved_to_photos`
- `is_composed_output`

Required:

- `is_composed_output`: `true`

### recording_failed

Owner:

- `recording_engine`

Payload:

- `battle_id`
- `mode`
- `error_code`
- `error_message`
- `is_recoverable`

## First Playable Event Chain

The only chain to prove:

```text
marker_detected
-> lock_started
-> lock_confirmed
-> boss_spawned
-> boss_hit
-> combo_updated
-> boss_phase_change
-> boss_defeated
-> ko_sequence_started
-> loot_dropped
-> loot_reveal_started
-> loot_collected
-> reward_saved
-> recording_finished
```

Optional branches:

```text
lock_lost
-> lock_restored
```

```text
recording_started
-> recording_failed
```

```text
critical_hit
```

## Module Rules

- Engines emit only events they own.
- Events are append-only facts.
- UI reads events and displays state.
- Debug Harness reads event log.
- Save Manager owns local persistence events.
- Recording reads composed output and reports recording events.
- Tracking must not remove boss, reset fight, or hide HP during marker memory states.
