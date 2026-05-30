# Game Flow Map V1

Project title: LoopyCat RPG AR

Internal title: Loopy TV RPG

## Goal

See the full playable loop before more coding.

Do not add features.

This document maps the first playable journey, state flow, event flow, save points, fail states, restart points, and architecture view.

## Scope Lock

This flow map covers only the first playable chain:

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

Frozen for now:

- 10 bosses
- Full inventory
- Cat 2.5D rig
- AR fitting
- Worlds
- Seasons
- Monster Book
- Cat Kingdom
- Social cards

## User Journey

```mermaid
flowchart TD
  A["APP START"] --> B["CAT PROFILE"]
  B --> B1["Photo"]
  B1 --> B2["Name"]
  B2 --> B3["Title"]
  B3 --> C["FIGHT BUTTON"]
  C --> D["Random boss selection"]
  D --> E["VS SCREEN"]
  E --> E1["Cat Hero"]
  E1 --> E2["VS"]
  E2 --> E3["Boss"]
  E3 --> F["CAMERA MODE"]
  F --> G["Marker search"]
  G --> H["TARGET LOCK"]
  H --> I["Portal spawn"]
  I --> J["Boss appears"]
  J --> K["Battle starts"]
  K --> L["Hit detection"]
  L --> M["Damage"]
  M --> H1["HP drop"]
  H1 --> N["Combo"]
  N --> O["Critical"]
  O --> P["Boss phase change"]
  P --> Q["KO"]
  Q --> R["Portal collapse"]
  R --> S["Loot animation"]
  S --> T["Cat finisher"]
  T --> U["Reward reveal"]
  U --> V["Save inventory"]
  V --> W["PHOTO / REC export"]
  W --> X["END"]
```

## Runtime State Diagram

```mermaid
stateDiagram-v2
  [*] --> AppStart
  AppStart --> CatProfile: no profile
  AppStart --> FightReady: profile exists
  CatProfile --> FightReady: cat_updated
  FightReady --> BossSelect: FIGHT
  BossSelect --> VSScreen: boss selected
  VSScreen --> CameraMode: intro complete
  CameraMode --> MarkerSearch
  MarkerSearch --> Locking: marker_detected
  Locking --> Locked: lock_confirmed
  Locked --> PortalSpawn
  PortalSpawn --> BossSpawn
  BossSpawn --> BattleIdle: boss_spawned
  BattleIdle --> HitResolve: boss_hit
  HitResolve --> BattleIdle: HP remains
  HitResolve --> PhaseChange: boss_phase_change
  PhaseChange --> BattleIdle
  HitResolve --> KO: boss_defeated
  KO --> PortalCollapse: ko_sequence_started
  PortalCollapse --> LootAnimation: loot_dropped
  LootAnimation --> CatFinisher
  CatFinisher --> RewardReveal: loot_reveal_started
  RewardReveal --> SaveInventory: loot_collected
  SaveInventory --> Export: reward_saved
  Export --> End: recording_finished or PHOTO saved
  Export --> ExportRetry: recording_failed
  ExportRetry --> Export

  Locked --> TrackingMemory: lock_lost short
  TrackingMemory --> Locked: lock_restored
  TrackingMemory --> SignalUnstable: loss passes 1.5s
  SignalUnstable --> Locked: lock_restored
  SignalUnstable --> LostNeedMarker: loss passes 5s
  LostNeedMarker --> Locking: marker returns
```

## Tracking State Diagram

```mermaid
stateDiagram-v2
  [*] --> SEARCH
  SEARCH --> LOCKING: marker_detected
  LOCKING --> LOCKED: lock_confirmed
  LOCKED --> TRACKING_MEMORY: lock_lost 0-1.5s
  TRACKING_MEMORY --> LOCKED: lock_restored
  TRACKING_MEMORY --> SIGNAL_UNSTABLE: loss 1.5-5s
  SIGNAL_UNSTABLE --> RELOCK: marker returns
  SIGNAL_UNSTABLE --> LOST: loss 5s+
  LOST --> RELOCK: marker returns
  RELOCK --> RESTORED: anchor reconciled
  RESTORED --> LOCKED: 400ms hit-ignore ends
```

Tracking rule:

- Marker is needed for acquisition.
- Persistent anchor is battle truth after lock.
- Boss does not disappear during tracking memory states.

## Combat State Diagram

```mermaid
stateDiagram-v2
  [*] --> SPAWN
  SPAWN --> IDLE: boss_spawned
  IDLE --> HIT: boss_hit
  HIT --> IDLE: HP remains
  HIT --> PHASE2: boss_phase_change
  PHASE2 --> HIT: boss_hit
  PHASE2 --> ENRAGED: boss_phase_change
  ENRAGED --> HIT: boss_hit
  HIT --> DEFEATED: boss_defeated
  PHASE2 --> DEFEATED: boss_defeated
  ENRAGED --> DEFEATED: boss_defeated
  DEFEATED --> [*]
```

## Boss Animation State Diagram

```mermaid
stateDiagram-v2
  [*] --> SPAWN
  SPAWN --> IDLE: emergence complete
  IDLE --> HIT_REACTION: boss_hit
  HIT_REACTION --> IDLE: reaction complete
  IDLE --> COMBO_REACTION: combo_updated
  COMBO_REACTION --> IDLE: reaction complete
  IDLE --> CRITICAL_HIT: critical_hit
  CRITICAL_HIT --> IDLE: reaction complete
  IDLE --> PHASE_2: boss_phase_change
  PHASE_2 --> IDLE: phase intro complete
  IDLE --> ENRAGED: boss_phase_change
  ENRAGED --> HIT_REACTION: boss_hit
  ENRAGED --> KO: boss_defeated
  IDLE --> KO: boss_defeated
  KO --> LOOT: ko_sequence_started
  LOOT --> [*]
```

## Event Diagram

```mermaid
sequenceDiagram
  participant User
  participant UI as ui_engine
  participant Cat as cat_profile_engine
  participant Boss as boss_engine
  participant Track as tracking_engine
  participant Combat as combat_engine
  participant Loot as loot_engine
  participant Save as save_manager
  participant Rec as recording_engine
  participant Bus as event_bus

  User->>UI: APP START
  UI->>Cat: Create or load cat profile
  Cat->>Bus: cat_updated
  User->>UI: FIGHT BUTTON
  UI->>Boss: Request random boss
  UI->>UI: VS SCREEN
  UI->>Track: CAMERA MODE
  Track->>Bus: marker_detected
  Track->>Bus: lock_started
  Track->>Bus: lock_confirmed
  Boss->>Bus: boss_spawned
  Combat->>Bus: boss_hit
  Combat->>Bus: combo_updated
  Combat->>Bus: critical_hit
  Boss->>Bus: boss_phase_change
  Combat->>Bus: boss_defeated
  Combat->>Bus: ko_sequence_started
  Loot->>Bus: loot_dropped
  Loot->>Bus: loot_reveal_started
  Loot->>Bus: loot_collected
  Save->>Bus: reward_saved
  Rec->>Bus: recording_started
  Rec->>Bus: recording_finished
```

Event ownership rule:

- Each event in this diagram has one owner.
- No duplicate emitters.
- UI can request actions, but does not own save or combat events.

## Save Points

```mermaid
flowchart TD
  A["Cat profile completed"] --> S1["Save cat_profile"]
  B["Reward collected"] --> S2["Save reward_item"]
  S2 --> S3["Save inventory_item"]
  C["Battle result complete"] --> S4["Save battle_history"]
  D["Settings changed"] --> S5["Save settings"]
  E["PHOTO / REC export finished"] --> S6["Save media reference"]
```

Save point details:

| Save Point | Trigger | Owner | Required Result |
| --- | --- | --- | --- |
| Cat profile | Photo, name, title completed | `save_manager` | Local cat profile exists |
| Reward item | `loot_collected` | `save_manager` | Reward is stored |
| Inventory item | `loot_collected` | `save_manager` | Item appears in inventory data |
| Battle history | KO/reward flow complete | `save_manager` | Battle result is stored |
| Settings | User changes setting | `save_manager` | Local settings updated |
| Media reference | `recording_finished` or PHOTO saved | `save_manager` | Export reference stored |

Save rules:

- No cloud.
- No accounts.
- UI never writes save data directly.
- If reward save fails, stay on reward reveal and retry.

## Fail States

```mermaid
flowchart TD
  A["APP START"] --> F1["Missing cat profile"]
  F1 --> R1["Restart at CAT PROFILE"]

  B["CAMERA MODE"] --> F2["Camera permission denied"]
  F2 --> R2["Return to FIGHT READY / permissions prompt"]

  C["Marker search"] --> F3["Marker not found"]
  F3 --> R3["Stay in Marker search / allow cancel"]

  D["LOCK"] --> F4["Lock lost"]
  F4 --> R4["Use anchor memory / relock"]

  E["Battle"] --> F5["Hit confidence too low"]
  F5 --> R5["Ignore hit / stay in battle"]

  F["Boss asset load"] --> F6["Boss asset missing"]
  F6 --> R6["Retry load / return to boss selection"]

  G["Reward save"] --> F7["Save failed"]
  F7 --> R7["Keep reward visible / retry save"]

  H["PHOTO / REC export"] --> F8["Recording failed"]
  F8 --> R8["Retry export / keep battle result saved"]
```

## Restart Points

| Restart Point | From Fail State | Restarts At | Must Preserve |
| --- | --- | --- | --- |
| Profile restart | Missing profile | `CAT PROFILE` | Existing local data if any |
| Permission retry | Camera denied | `CAMERA MODE` | Cat profile and selected boss |
| Marker retry | Marker not found | `Marker search` | Selected boss and battle setup |
| Relock retry | Lock lost | `RELOCK` / `Marker search` | Anchor memory, boss HP, combat state |
| Asset retry | Boss asset missing | `Random boss selection` | Cat profile |
| Save retry | Reward save failed | `Reward reveal` | Reward item and battle result |
| Export retry | Recording failed | `PHOTO / REC export` | Saved inventory and battle history |
| Full restart | Unrecoverable error | `APP START` | Local saves |

## Architecture View

```mermaid
flowchart LR
  User["User"] --> UI["ui_engine"]
  UI --> Cat["cat_profile_engine"]
  UI --> Boss["boss_engine"]
  UI --> Track["tracking_engine"]

  Assets["asset_manager"] --> Track
  Assets --> Boss
  Assets --> Loot["loot_engine"]
  Assets --> Cat
  Assets --> UI

  Track --> Bus["event_bus"]
  Boss --> Bus
  Combat["combat_engine"] --> Bus
  Loot --> Bus
  Save["save_manager"] --> Bus
  Rec["recording_engine"] --> Bus

  Bus --> Debug["debug_harness"]
  Bus --> UI

  Track --> Anchor["persistent anchor"]
  Anchor --> Boss

  Combat --> Boss
  Combat --> Loot
  Loot --> Save
  Cat --> Save

  Render["render_composition"] --> Rec
  UI --> Render
  Boss --> Render
  Track --> Render
  Loot --> Render
```

Architecture rules:

- `event_bus` coordinates facts.
- `save_manager` owns local persistence.
- `asset_manager` lazy-loads content.
- `render_composition` owns the final composed frame.
- `recording_engine` captures composed output only.
- `debug_harness` observes; it does not own gameplay.

## Composed Output Map

```mermaid
flowchart TD
  C["Camera feed"] --> O["Composed output"]
  A["Anchor / toy-space layer"] --> O
  P["Portal"] --> O
  B["Boss"] --> O
  H["HP"] --> O
  D["Damage numbers"] --> O
  X["Combo text"] --> O
  K["KO"] --> O
  L["Loot animation"] --> O
  U["UI overlays"] --> O
  O --> Screen["On-screen display"]
  O --> Photo["PHOTO export"]
  O --> Rec["REC export"]
```

Capture rule:

- PHOTO and REC must match what the user sees.
- Raw camera-only output is invalid.

## Full Playable Loop Checklist

- App starts.
- Cat profile has photo, name, and title.
- Fight button starts boss selection.
- VS screen appears before camera mode.
- Camera mode opens.
- Marker search starts.
- Lock confirms.
- Persistent anchor is created.
- Portal spawns from anchor.
- Boss appears on anchor.
- Battle starts.
- Hit detection emits `boss_hit`.
- Damage and HP update.
- Combo can update.
- Critical can trigger.
- Boss phase can change.
- KO starts.
- Portal collapses.
- Loot animation plays.
- Cat finisher plays.
- Reward reveal appears.
- Inventory save completes.
- PHOTO or REC exports composed output.
- Flow ends safely.

## Definition Of Done For Flow Map

Game Flow Map V1 is complete when:

- User journey is visible.
- State diagram is defined.
- Event diagram is defined.
- Save points are defined.
- Fail states are defined.
- Restart points are defined.
- Architecture view is defined.
- No new gameplay features are added.
