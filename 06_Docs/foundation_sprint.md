# Foundation Sprint

Project title: LoopyCat RPG AR

Internal title: Loopy TV RPG

## Goal

Make the app technically possible and safe to expand.

Build only project foundation.

Do not build new gameplay now.

## Systems Built As Foundation Contracts

### 1. Event Bus

Created:

`02_App/event_bus/`

Contract:

`02_App/event_bus/EVENT_BUS.md`

Required events:

- `marker_detected`
- `lock_started`
- `lock_confirmed`
- `lock_lost`
- `lock_restored`
- `boss_spawned`
- `boss_hit`
- `combo_updated`
- `critical_hit`
- `boss_phase_change`
- `boss_defeated`
- `ko_sequence_started`
- `loot_dropped`
- `loot_reveal_started`
- `loot_collected`
- `reward_saved`
- `cat_updated`
- `recording_started`
- `recording_finished`
- `recording_failed`

Rule:

- One event = one owner.
- No duplicate emitters.

Core MVP events:

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

### 2. Save Manager

Created:

`02_App/save_manager/`

Contract:

`02_App/save_manager/SAVE_MANAGER.md`

Saves locally:

- Cat profile
- Battle history
- Reward item
- Inventory item
- Settings

Rules:

- No cloud.
- No accounts.
- Everything local.

### 3. Asset Manager

Created:

`02_App/asset_manager/`

Contract:

`02_App/asset_manager/ASSET_MANAGER.md`

Supports:

- Boss assets
- Loot assets
- Marker image
- Cat photo
- UI assets

Rules:

- Lazy loading required.
- Do not load all bosses at once.

### 4. Render And Composition Decision

Created:

`02_App/render_composition/`

Contract:

`02_App/render_composition/RENDER_COMPOSITION_DECISION.md`

Critical rule:

REC and PHOTO must capture composed output.

Output must include:

- Camera feed
- Boss
- Portal
- HP
- Damage numbers
- Combo text
- KO
- Loot animation
- UI overlays

Raw camera-only recording is invalid.

Decision:

- One composed render output is the truth.
- On-screen display, PHOTO capture, and REC capture use the same composed frame.

### 5. Debug Harness

Created:

`02_App/debug_harness/`

Contract:

`02_App/debug_harness/DEBUG_HARNESS.md`

Internal debug screen shows:

- Current state
- Event log
- Tracking state
- Boss state
- Combat state
- Recording state
- Loaded assets
- FPS
- Errors

### 6. State Models

Created:

`02_App/state_models/`

Contract:

`02_App/state_models/STATE_MODELS.md`

Tracking state:

- `SEARCH`
- `LOCKING`
- `LOCKED`
- `TRACKING_MEMORY`
- `SIGNAL_UNSTABLE`
- `RELOCK`
- `RESTORED`
- `LOST`

Combat state:

- `SPAWN`
- `IDLE`
- `HIT`
- `PHASE2`
- `ENRAGED`
- `DEFEATED`

Boss animation state:

- `SPAWN`
- `IDLE`
- `ATTACK`
- `HIT_REACTION`
- `COMBO_REACTION`
- `CRITICAL_HIT`
- `PHASE_2`
- `ENRAGED`
- `KO`
- `LOOT`

Recording state:

- `IDLE`
- `READY`
- `RECORDING`
- `CAPTURING_PHOTO`
- `EXPORTING`
- `FINISHED`
- `FAILED`

## MVP Lock

Freeze these for now:

- 10 bosses
- Full inventory
- Cat 2.5D rig
- AR fitting
- Worlds
- Seasons
- Monster Book
- Cat Kingdom
- Social cards

Only prepare architecture.

Do not build them yet.

## First Playable Target

The only chain to prove:

```text
camera
-> marker lock
-> persistent anchor
-> boss stays on toy
-> hit
-> HP drop
-> KO
-> loot drop
-> composed photo/video
```

## Foundation Sprint Outputs

Created module folders:

- `02_App/event_bus`
- `02_App/save_manager`
- `02_App/asset_manager`
- `02_App/render_composition`
- `02_App/debug_harness`
- `02_App/state_models`

Updated central docs:

- `06_Docs/system_map.md`
- `06_Docs/event_flow.md`
- `06_Docs/data_flow.md`

## Next Sprint

Next sprint:

- Tracking Sprint

Tracking Sprint should begin only after the foundation contracts are accepted.
