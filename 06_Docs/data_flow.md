# Data Flow

Project title: LoopyCat RPG AR

Internal title: Loopy TV RPG

## Foundation Sprint Rule

This document defines foundation data flow only.

No new gameplay.

No cloud.

No accounts.

Everything is local.

## Foundation Data Owners

| Data | Owner |
| --- | --- |
| Event log | `event_bus` |
| Cat profile save | `save_manager` |
| Battle history save | `save_manager` |
| Reward item save | `save_manager` |
| Inventory item save | `save_manager` |
| Settings save | `save_manager` |
| Loaded asset registry | `asset_manager` |
| Composed frame output | `render_composition` |
| Debug display state | `debug_harness` |
| Tracking state | `tracking_engine` |
| Combat state | `combat_engine` |
| Boss animation state | `boss_engine` |
| Recording state | `recording_engine` |

## Local Save Models

### cat_profile

Stores:

- `cat_id`
- `cat_name`
- `cat_title`
- `cat_photo_refs`
- `level`
- `xp`
- `wins`
- `equipped_items`
- `updated_at`

### battle_history

Stores:

- `battle_id`
- `cat_id`
- `boss_id`
- `result`
- `damage_done`
- `hits_landed`
- `max_combo`
- `critical_count`
- `loot_ids`
- `recording_id`
- `photo_id`
- `started_at`
- `ended_at`

### reward_item

Stores:

- `reward_id`
- `item_id`
- `item_name`
- `item_rarity`
- `set_name`
- `source_boss_id`
- `battle_id`
- `obtained_at`

### inventory_item

Stores:

- `item_id`
- `owned`
- `equipped`
- `slot`
- `quantity`
- `first_obtained_at`
- `last_updated_at`

### settings

Stores:

- `audio_enabled`
- `recording_quality`
- `debug_overlay_enabled`
- `camera_permission_seen`
- `photos_permission_seen`

## Runtime Foundation Flow

```text
asset_manager loads marker image lazily
  -> tracking_engine can detect marker

tracking_engine emits marker_detected, lock_started, lock_confirmed
  -> event_bus validates owner
  -> debug_harness logs state
  -> persistent anchor owns toy-space attachment

boss_engine requests selected boss assets
  -> asset_manager loads only selected boss
  -> portal opens from persistent anchor
  -> boss emerges through portal
  -> boss name card and HP appear
  -> boss_engine emits boss_spawned

combat_engine receives hit signal
  -> emits boss_hit
  -> may emit combo_updated
  -> may emit critical_hit
  -> may emit boss_defeated
  -> may emit ko_sequence_started

loot_engine receives defeat signal
  -> emits loot_dropped
  -> emits loot_reveal_started
  -> emits loot_collected

save_manager receives loot_collected
  -> writes reward item
  -> writes inventory item
  -> emits reward_saved

cat_profile_engine updates cat runtime profile
  -> emits cat_updated

render_composition produces composed output
  -> recording_engine captures PHOTO or REC from composed output
  -> media saves to Photos from composed output only
  -> recording_engine emits recording_started, recording_finished, or recording_failed

debug_harness observes event_bus, state models, assets, FPS, and errors
```

## Asset Data Flow

Asset Manager supports:

- Boss assets
- Loot assets
- Marker image
- Cat photo
- UI assets

Rules:

- Marker loads for camera/tracking setup.
- Only selected boss loads for active battle.
- Loot assets load only when selected by `loot_engine`.
- Cat photo loads as runtime-sized image.
- UI assets load per screen.
- Do not decode or load all raw boss sheets at once.

## Render Data Flow

Render Composition owns the final composed frame.

Render order:

1. Camera feed.
2. Marker/toy-space layer.
3. Portal.
4. Boss.
5. Hit effects.
6. Damage numbers.
7. Combo text.
8. HP and HUD.
9. KO.
10. Loot animation.
11. UI overlays.
12. Debug overlay when enabled.

Recording reads the composed frame.

Raw camera-only recording is invalid.

## Debug Data Flow

Debug Harness reads:

- Current state
- Event log
- Tracking state
- Boss state
- Combat state
- Recording state
- Loaded assets
- FPS
- Errors

Debug Harness does not mutate gameplay state.

## Persistence Rules

- Save Manager is the only local save writer.
- UI never writes save data directly.
- Animation never writes save data directly.
- Recording never writes gameplay data.
- Reward save happens after `loot_collected`.
- If reward save fails, the reward remains visible and can retry.

## Frozen Data

Do not define implementation data yet for:

- 10-boss roster expansion
- Full inventory
- Cat 2.5D rig
- AR fitting
- Worlds
- Seasons
- Monster Book
- Cat Kingdom
- Social cards
