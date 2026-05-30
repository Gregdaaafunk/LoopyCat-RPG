# System Map

Project title: LoopyCat RPG AR

Internal title: Loopy TV RPG

## Foundation Sprint Rule

Build only project foundation.

Do not build new gameplay now.

Goal:

Make the app technically possible and safe to expand.

## Foundation Modules

Foundation modules live in:

`02_App/`

Required foundation modules:

- `event_bus`
- `save_manager`
- `asset_manager`
- `render_composition`
- `debug_harness`
- `state_models`

Gameplay modules:

- `tracking_engine`
- `boss_engine`
- `combat_engine`
- `loot_engine`
- `cat_profile_engine`
- `inventory_engine`
- `animation_engine`
- `recording_engine`
- `ui_engine`
- `world_engine`

## Foundation Module Responsibilities

### event_bus

Owns central event dispatch.

Rules:

- One event has one owner.
- No duplicate emitters.
- Events are append-only facts.
- Debug Harness can read event log.

Event contract:

`02_App/event_bus/EVENT_BUS.md`

Canonical event flow:

`06_Docs/event_flow.md`

### save_manager

Owns local persistence.

Saves:

- Cat profile
- Battle history
- Reward item
- Inventory item
- Settings

Rules:

- No cloud.
- No accounts.
- UI does not write save files directly.

Save contract:

`02_App/save_manager/SAVE_MANAGER.md`

### asset_manager

Owns asset loading structure.

Supports:

- Boss assets
- Loot assets
- Marker image
- Cat photo
- UI assets

Rules:

- Lazy loading required.
- Do not load all bosses at once.
- Only load selected boss for active battle.

Asset contract:

`02_App/asset_manager/ASSET_MANAGER.md`

### render_composition

Owns render and capture architecture decision.

Critical rule:

REC and PHOTO capture composed output, not raw camera only.

Composed output must include:

- Camera feed
- Boss
- Portal
- HP
- Damage numbers
- Combo text
- KO
- Loot animation
- UI overlays

Decision contract:

`02_App/render_composition/RENDER_COMPOSITION_DECISION.md`

### debug_harness

Owns internal debug screen requirements.

Shows:

- Current state
- Event log
- Tracking state
- Boss state
- Combat state
- Recording state
- Loaded assets
- FPS
- Errors

Debug contract:

`02_App/debug_harness/DEBUG_HARNESS.md`

### state_models

Owns separated state model definitions.

Defines:

- `tracking_state`
- `combat_state`
- `boss_anim_state`
- `recording_state`

State contract:

`02_App/state_models/STATE_MODELS.md`

## Gameplay Module Responsibilities

### tracking_engine

Owns:

- Marker detection
- Lock start
- Lock confirmation
- Lock loss
- Anchor memory
- Relock
- Lock restoration

Contract:

`02_App/tracking_engine/TRACKING_ENGINE.md`

Emits:

- `marker_detected`
- `lock_started`
- `lock_confirmed`
- `lock_lost`
- `lock_restored`

### boss_engine

Owns:

- Boss asset selection
- Boss spawn
- Boss phase changes
- Boss animation state source data

Contract:

`02_App/boss_engine/BOSS_ENGINE.md`

Emits:

- `boss_spawned`
- `boss_phase_change`

### combat_engine

Owns:

- Hit acceptance
- HP drop
- Combo update
- Critical hit
- Defeat authority
- KO sequence start

Emits:

- `boss_hit`
- `combo_updated`
- `critical_hit`
- `boss_defeated`
- `ko_sequence_started`

### loot_engine

Owns:

- Drop roll
- Loot reveal start
- Loot collection event

Emits:

- `loot_dropped`
- `loot_reveal_started`
- `loot_collected`

### cat_profile_engine

Owns:

- Cat profile runtime state
- Cat title
- Cat XP and level update

Emits:

- `cat_updated`

### inventory_engine

Owns:

- Owned item view
- Equipped item view
- Inventory item state read/write requests through Save Manager

Does not emit foundation events in this sprint.

### animation_engine

Owns:

- Portal animation playback
- Boss animation playback
- Hit effects playback
- KO visual playback
- Loot animation playback

Does not own combat state.

Does not save rewards.

### recording_engine

Owns:

- Composed PHOTO capture
- Composed REC capture
- Export result reporting

Contract:

`02_App/recording_engine/RECORDING_ENGINE.md`

Emits:

- `recording_started`
- `recording_finished`
- `recording_failed`

### ui_engine

Owns:

- Screens
- HUD
- Debug screen display
- Event display

Does not mutate save data directly.

### world_engine

Frozen for Foundation Sprint.

No world rotations, seasons, events, or Monster Book work now.

## State Models

### tracking_state

- `SEARCH`
- `LOCKING`
- `LOCKED`
- `TRACKING_MEMORY`
- `SIGNAL_UNSTABLE`
- `RELOCK`
- `RESTORED`
- `LOST`

### combat_state

- `SPAWN`
- `IDLE`
- `HIT`
- `PHASE2`
- `ENRAGED`
- `DEFEATED`

### boss_anim_state

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

### recording_state

- `IDLE`
- `READY`
- `RECORDING`
- `CAPTURING_PHOTO`
- `EXPORTING`
- `FINISHED`
- `FAILED`

## Dependency Direction

```text
event_bus
  -> debug_harness

asset_manager
  -> tracking_engine
  -> boss_engine
  -> loot_engine
  -> cat_profile_engine
  -> ui_engine

save_manager
  -> cat_profile_engine
  -> inventory_engine
  -> combat_engine
  -> ui_engine

render_composition
  -> recording_engine
  -> ui_engine
  -> animation_engine

tracking_engine
  -> event_bus
  -> boss_engine
  -> combat_engine

boss_engine
  -> event_bus
  -> animation_engine

combat_engine
  -> event_bus
  -> boss_engine
  -> loot_engine
  -> animation_engine

loot_engine
  -> event_bus
  -> save_manager
  -> animation_engine
  -> inventory_engine

recording_engine
  -> event_bus
  -> local media output

ui_engine
  -> event_bus
  -> debug_harness
```

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

## Foundation Sprint Docs

Foundation Sprint:

`06_Docs/foundation_sprint.md`

Event Flow:

`06_Docs/event_flow.md`

Data Flow:

`06_Docs/data_flow.md`

Game Flow Map V1:

`06_Docs/game_flow_map_v1.md`

Hit Detection Sprint Plan:

`06_Docs/hit_detection_sprint_plan.md`

Tracking Sprint Task 4:

`06_Docs/tracking_sprint_task_4.md`

Boss Spawn Sprint Task 5:

`06_Docs/boss_spawn_sprint_task_5.md`

Recording Architecture Sprint Task 6:

`06_Docs/recording_architecture_sprint_task_6.md`

Tracking Sprint:

`06_Docs/tracking_sprint.md`

Boss Spawn Sprint:

`06_Docs/boss_spawn_sprint.md`

Recording Architecture Sprint:

`06_Docs/recording_architecture_sprint.md`
