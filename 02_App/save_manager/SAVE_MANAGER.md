# Save Manager

Project title: LoopyCat RPG AR

Purpose:

- Save all local player data.
- Avoid cloud dependency.
- Avoid account dependency.
- Provide safe write boundaries for rewards, cat data, battle history, inventory, and settings.

## Foundation Rule

Everything is local.

No cloud.

No accounts.

UI does not write save files directly.

## Save Domains

Save Manager stores:

- Cat profile
- Battle history
- Reward item
- Inventory item
- Settings

## Save Models

### cat_profile

Fields:

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

Fields:

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

Fields:

- `reward_id`
- `item_id`
- `item_name`
- `item_rarity`
- `set_name`
- `source_boss_id`
- `battle_id`
- `obtained_at`

### inventory_item

Fields:

- `item_id`
- `owned`
- `equipped`
- `slot`
- `quantity`
- `first_obtained_at`
- `last_updated_at`

### settings

Fields:

- `audio_enabled`
- `recording_quality`
- `debug_overlay_enabled`
- `camera_permission_seen`
- `photos_permission_seen`

## Save Timing

Save after:

- `loot_collected`
- Battle end
- Cat profile update
- Inventory update
- Settings update
- Recording export result

## Event Ownership

Save Manager emits:

- `reward_saved`

Save Manager consumes:

- `loot_collected`
- `cat_updated`
- `recording_finished`
- `recording_failed`

## Safety Rules

- Use atomic writes where supported.
- Never save half-collected loot.
- If reward save fails, keep reward visible and retry.
- Keep save files versioned for future migration.
- Never delete player data without explicit user action.
