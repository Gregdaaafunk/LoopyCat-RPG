# LoopyCat RPG AR Architecture Audit

Project title: LoopyCat RPG AR

Internal title: Loopy TV RPG

Audit date: 2026-05-23

## Audit Scope

This is a technical diagnosis only.

Do not build new gameplay from this document.

Current project state:

- Architecture and product specifications exist.
- Module folders exist.
- Raw marker, boss, and loot assets exist.
- No executable app code exists yet.
- No engine implementations exist yet.

## Current Systems

### Project Structure

Top-level structure:

```text
LoopyCat-RPG/
  01_Project/
  02_App/
  03_AR/
  04_Content/
  05_TestFlight/
  06_Docs/
  NEXT_TASKS.md
  mechanics.md
  roadmap.md
  vision.md
```

App module folders:

```text
02_App/
  animation_engine/
  boss_engine/
  cat_profile_engine/
  combat_engine/
  inventory_engine/
  loot_engine/
  recording_engine/
  tracking_engine/
  ui_engine/
  world_engine/
```

Content structure:

```text
03_AR/
  canonical_marker.jpg

04_Content/
  Bosses/
    raw_sheets/
    extracted_parts/
    manifests/
    controllers/
  Loot/
    raw_sheets/
    extracted_items/
    manifests/
    animations/
```

Current raw assets:

- Marker: 1 canonical marker image, about 160 KB, 1254 x 1254.
- Boss sheets: 10 raw sheets, about 3.47 MB total.
- Loot sheets: 4 raw sheets, about 1.25 MB total.
- Total project size: about 5.02 MB.

### Existing Documentation

Core foundation docs:

- `system_map.md`
- `data_flow.md`
- `event_flow.md`
- `core_game_loop.md`
- `tracking_engine_v2.md`
- `boss_asset_system.md`
- `combat_feel_system_v1.md`
- `loot_animation_expansion.md`
- `cat_hero_path_2.md`
- `victory_arena_system.md`

Phase docs exist from Phase 1 through Phase 14.

Diagnosis:

- Good: vision is captured and decomposed into engines.
- Good: canonical marker and asset folders are in place.
- Risk: docs are ahead of implementation by a lot.
- Risk: some specs conflict because later phases changed earlier assumptions.

## Dependency Audit

Current intended dependency flow:

```text
cat_profile_engine -> ui_engine
ui_engine -> boss_engine -> recording_engine
tracking_engine -> boss_engine -> combat_engine
world_engine -> boss_engine -> loot_engine -> ui_engine
combat_engine -> boss_engine -> loot_engine -> animation_engine -> recording_engine -> ui_engine
loot_engine -> animation_engine -> inventory_engine -> cat_profile_engine -> ui_engine
inventory_engine -> cat_profile_engine -> ui_engine
animation_engine -> ui_engine
recording_engine -> local media output
```

Diagnosis:

- Good: UI and recording are observers, not owners of game state.
- Good: tracking is not allowed to remove boss after lock.
- Medium risk: dependency map allows `ui_engine -> boss_engine`, which can become UI-driven state mutation unless carefully constrained.
- Medium risk: `animation_engine` consumes and emits reward events, while `loot_engine` owns reward state. This needs strict event ownership.
- High risk: no central event bus exists yet, so dependency boundaries are conceptual only.

## Tracking System Review

Current design:

- Marker detection creates stable lock.
- Marker lock creates persistent anchor.
- Boss lives on anchor after lock.
- Marker loss does not remove boss.
- Anchor memory stores position, rotation, scale, velocity, and last stable position.
- Grace periods exist:
  - 0-1.5 seconds: `LOCK STABLE`
  - 1.5-5 seconds: `SIGNAL UNSTABLE`
  - 5+ seconds: `SHOW MARKER AGAIN`
- Relock uses smoothing and ignores hit detection for 400 ms.

Strengths:

- Correct mental model: marker is acquisition, anchor is battle truth.
- Good failure behavior: no boss disappearance on small camera movement.
- Good state names and user-facing status messages.
- Good explicit forbidden behavior list.

Gaps:

- No actual tracking algorithm is selected.
- No marker physical size is defined.
- Toy face is 8 cm x 7 cm, but marker dimensions are explicitly not toy dimensions. The marker real-world size is still required for distance estimation.
- No camera calibration rules.
- No confidence scoring formula.
- No stable lock window count or time threshold.
- No smoothing constants.
- No velocity decay formula.
- No max anchor drift rule.
- No relock snap threshold.
- No low-light or motion-blur failure handling.
- No permission/app-lifecycle handling when camera is interrupted.

Tracking risk: HIGH.

Reason:

Tracking stability is the core magic. The design is correct, but implementation success depends on algorithm selection, marker physical calibration, and careful smoothing.

## Combat System Review

Current design:

- Hit flow includes damage, HP drop, effects, boss reaction, combo, criticals, floating damage, boss emotion, and phase changes.
- Combat Feel V1 defines:
  - Basic hit
  - Combo system
  - Critical system
  - Boss emotion
  - Impact effects
  - KO sequence
  - Floating damage
  - Audio placeholders
  - Style mode
- KO requires 200 ms freeze frame, `KO`, boss launch, collapse, portal collapse, loot explosion, Cat Hero finisher, and reward screen.

Strengths:

- Good arcade feel decomposition.
- Good separation between combat state and animation presentation.
- Criticals, combos, and boss emotions are specified as systems, not one-off effects.

Gaps:

- Hit detection source is undefined.
- No definition of what counts as a cat hit on the physical toy.
- No cooldown/debounce rules.
- No false-positive rejection.
- No damage formula.
- No HP model per boss.
- No combo timer duration.
- No critical chance or random seed policy.
- No event ordering for normal hit plus critical hit in same frame.
- No input authority during tracking loss or long pause.

Conflict:

- Boss phase thresholds differ:
  - Phase 2: HP > 60, 30-60, < 30.
  - Combat Feel V1: HP > 70, 70-40, < 40, < 10.

Recommendation:

- Use Combat Feel V1 thresholds for emotion.
- Use Phase 2 thresholds for boss phase only.
- Name them separately:
  - `boss_phase`
  - `boss_emotion`

Combat risk: HIGH.

Reason:

The feel spec is strong, but hit detection and damage authority are not yet defined.

## Boss System Review

Current design:

- 10 raw boss sheets exist.
- Boss sheets are treated as rig assets, not static images.
- Required parts:
  - `HEAD`
  - `BODY`
  - `LEFT_ARM`
  - `RIGHT_ARM`
  - `LOWER_BODY`
  - `EYES`
  - `SHADOW`
  - `FX`
  - `SPAWN`
  - `HIT`
  - `ENRAGED`
  - `DEFEATED`
  - `PORTRAIT`
  - `ICON`
- Pipeline folders exist for raw sheets, extracted parts, manifests, and controllers.
- Boss animation states include spawn, idle, attack, hit reaction, combo reaction, critical hit, phase 2, enraged, KO, and loot.

Strengths:

- Excellent asset direction.
- Good rig-part vocabulary.
- Procedural animation approach is realistic for 2D sheets.
- Boss can feel alive without full skeletal animation.

Gaps:

- No actual extraction pipeline.
- No cell coordinate manifest.
- No transparent cutout assets yet.
- No pivot points per part.
- No part hierarchy.
- No draw order.
- No collision or hit zones.
- No animation curve format.
- No texture atlas.
- No asset cache.
- No fallback behavior if a part is missing.

Conflict:

- Boss states are named differently across docs:
  - Phase 2: `IDLE`, `PHASE_1`, `PHASE_2`, `ENRAGED`, `DEFEATED`
  - Boss Asset System: `SPAWN`, `IDLE`, `ATTACK`, `HIT_REACTION`, `COMBO_REACTION`, `CRITICAL_HIT`, `PHASE_2`, `ENRAGED`, `KO`, `LOOT`
  - System Map combat states: `SPAWN`, `IDLE`, `HIT`, `PHASE2`, `ENRAGED`, `DEFEATED`

Recommendation:

- Split state machines:
  - `combat_state`: `SPAWN`, `IDLE`, `HIT`, `PHASE2`, `ENRAGED`, `DEFEATED`
  - `boss_anim_state`: `SPAWN`, `IDLE`, `ATTACK`, `HIT_REACTION`, `COMBO_REACTION`, `CRITICAL_HIT`, `PHASE_2`, `ENRAGED`, `KO`, `LOOT`
  - `boss_phase`: `PHASE_1`, `PHASE_2`, `ENRAGED`, `DEFEATED`

Boss risk: MEDIUM-HIGH.

Reason:

The design is feasible, but the import pipeline and manifest format are mandatory before implementation can move safely.

## Loot System Review

Current design:

- 4 raw loot sheets exist.
- Loot folders exist for raw sheets, extracted items, manifests, and animations.
- Rarities:
  - `COMMON`
  - `RARE`
  - `EPIC`
  - `LEGENDARY`
  - `MYTHIC`
- Loot categories:
  - collars, crowns, helmets, armor, auras, wings, tail FX, titles.
- Reward animation is cinematic, not popup-only.
- Supports single, double, triple, legend burst, and critical drop.
- Set names exist in loot sheet direction.

Strengths:

- Reward presentation is strong and differentiated.
- Inventory mapping is planned.
- Set logic direction is visible through sheet names and bonuses.

Gaps:

- No drop table schema.
- No rarity weights.
- No duplicate policy.
- No pity/guarantee logic.
- No set bonus data model yet.
- No item stat schema.
- No item upgrade/evolution schema.
- No inventory capacity policy.
- No save transaction design for reward save.
- No rollback if item collect animation completes but save fails.

Conflict:

- Phase 2 says loot is placeholder-only and no inventory.
- Later core loop saves item to inventory.

Recommendation:

- For MVP, allow inventory save but postpone equipment stats and set bonuses.
- Treat Phase 2 no-inventory rule as superseded by core loop for the playable build.

Loot risk: MEDIUM.

Reason:

Loot can start simple, but set bonuses and rarity scaling will become complex quickly.

## Cat Hero System Review

Current design:

- Path 2 selected: local pseudo-3D / 2.5D puppet.
- No paid AI API.
- No cloud.
- No AI video generation.
- Required photos: front, left, right.
- Optional photos: back, top.
- Manual rig assist uses tap points and draggable circles.
- Rig points:
  - `HEAD`
  - `BODY`
  - `LEFT_FRONT_PAW`
  - `RIGHT_FRONT_PAW`
  - `TAIL`
  - optional ears.
- Animation templates include idle, jump, paw attack, super attack, victory pose, KO finisher, loot reaction.

Strengths:

- Good scope discipline.
- Local-only design avoids AI/cloud dependency.
- Manual assist is realistic for v1.
- Equipment attach points are already aligned with future cosmetics.

Gaps:

- No photo storage format.
- No image downscale policy.
- No privacy or deletion policy.
- No rig point coordinate space.
- No layer extraction strategy.
- No masking strategy, even simple bounding zones.
- No default rig generation if user skips points.
- No animation template data format.
- No equipment attachment transform rules.
- No way to map left/right photos to animation direction.

Cat Hero risk: MEDIUM-HIGH.

Reason:

2.5D is the right path, but it needs a minimal rig data format and image processing rules before UI work begins.

## Recording System Review

Current design:

- Must support `REC` and `PHOTO`.
- Must capture composed output:
  - camera feed
  - boss
  - portal
  - HP
  - damage numbers
  - hit effects
  - combo banners
  - KO animation
  - loot animation
  - UI overlays
- Raw camera-only video is invalid.

Strengths:

- Requirement is clear and correct.
- Composed output is explicitly required.
- Recording is observer-only and should not mutate gameplay.

Gaps:

- No rendering stack is selected.
- No composed frame architecture exists.
- No decision between ReplayKit, AVAssetWriter, Metal texture capture, or screen recorder.
- No audio capture path.
- No microphone policy.
- No save-to-Photos permission handling.
- No recording resolution/fps target.
- No export format.
- No failure behavior for interrupted recording.
- No performance budget for recording plus AR plus particles.

Recording risk: CRITICAL.

Reason:

Capturing overlays exactly as seen is often harder than gameplay rendering. If the render pipeline is not designed for composed capture from day one, recording can become a late-stage blocker.

## Memory And Performance Review

Current asset numbers:

- Raw boss sheets: 10 sheets, about 3.47 MB compressed.
- Raw loot sheets: 4 sheets, about 1.25 MB compressed.
- Canonical marker: about 160 KB.
- Total project files: about 5.02 MB.

Expected runtime expansion:

- JPEG decode expands heavily in memory.
- A 1536 x 1024 RGBA texture is about 6 MB uncompressed.
- 10 boss sheets decoded together would be about 60 MB before extracted parts.
- Extracted boss parts can multiply texture count.
- Cat photos can become the largest memory source if stored full-resolution.
- Recording buffers can add significant transient memory.

FPS estimate:

- Spec-only project: not measurable.
- Expected MVP target: 30 FPS on mid-range mobile during camera battle.
- Ideal target: 60 FPS for UI/VS screens, 30-60 FPS for camera battle depending on device.

Heat and battery risk:

- Camera + tracking + AR render + particles + recording is high heat.
- Long REC sessions will increase thermal throttling risk.
- Excess particles, full-resolution textures, and multiple live scenes will reduce stability.

Future bottlenecks:

- Composed recording.
- Texture count from boss rigs.
- Cat photo decode and resizing.
- Particle systems during portal, criticals, KO, and loot reveal.
- Dynamic victory arenas loaded immediately after camera battle.
- Save-to-Photos while animations continue.

Required performance rules:

- Load only selected boss, not all bosses.
- Use texture atlases for boss parts.
- Downscale cat photos for runtime.
- Keep original cat photos separate from runtime textures.
- Preload only next needed scene.
- Cap particles by device tier.
- Make recording resolution configurable.
- Reuse animation objects and effect pools.
- Avoid decoding images during live camera battle.

Performance risk: HIGH.

Reason:

The MVP combines camera, AR, animated rigs, particles, UI overlays, and recording. That can work, but only with strict render and asset budgets.

## Missing Systems

Critical missing systems:

- App runtime/framework selection.
- Event bus.
- Save manager.
- Asset manager.
- Render/composition pipeline.
- Recording/composed capture pipeline.
- Tracking implementation.
- Hit detection implementation.
- Permission manager.
- App lifecycle manager.

High-priority missing systems:

- Sound manager.
- Effect manager.
- Animation scheduler.
- Texture atlas pipeline.
- Asset manifest schema.
- Boss rig manifest schema.
- Loot item manifest schema.
- Cat rig data schema.
- Local database/storage layer.
- Error handling and retry policy.
- Performance profiler hooks.
- Device capability tiering.

Medium-priority missing systems:

- Asset streaming.
- Animation cache.
- Object pooling.
- RNG service.
- Config/tuning service.
- Debug overlay.
- Telemetry/logging local only.
- Test harness.
- Fake camera/test input mode.
- Save migration system.
- Content validation tools.

Future systems not needed for MVP:

- Online account system.
- Multiplayer.
- Global events.
- Community raids.
- Automatic cat tracking.
- Real 3D cat model.
- Cloud AI generation.
- Full set bonus/equipment evolution.
- Cat Kingdom.
- Monster Book.

## Dead Systems

No dead code exists because there is no implementation.

Potential dead or premature systems:

- Phase 10-14 docs are future-facing and should not influence MVP implementation.
- World rotations, events, achievements, Cat Kingdom, Monster Book, and Legend rank should stay frozen.
- AR fitting should not be built before the core battle loop is playable.

## Future Conflicts

### Event Ownership Conflict

Some events list multiple emitters:

- `boss_phase_change`: `boss_engine` and `combat_engine`
- `boss_defeated`: `boss_engine` and `combat_engine`
- `ko_sequence_started`: `combat_engine` and `animation_engine`
- `loot_energy_started`: `loot_engine` and `animation_engine`
- `loot_reveal_started`: `animation_engine` and `ui_engine`

Risk:

- Duplicate events.
- Race conditions.
- UI showing wrong state.
- Save happening twice.

Recommendation:

- Use one owner per event.
- Other modules request or react, but do not emit the same event.

Suggested ownership:

- `combat_engine`: `boss_hit`, `combo_updated`, `critical_hit`, `boss_defeated`, `ko_sequence_started`
- `boss_engine`: `boss_phase_change`, `boss_emotion_changed`
- `animation_engine`: `impact_effect_played`, `portal_unstable`, `loot_item_launched`, `loot_reveal_started`, `loot_collect_started`
- `loot_engine`: `loot_dropped`, `reward_saved`

### State Name Conflict

Risk:

- `PHASE2` and `PHASE_2` both appear.
- `DEFEATED` and `KO` overlap.
- Boss phase, boss animation state, and combat state are mixed.

Recommendation:

- Keep three separate fields:
  - `combat_state`
  - `boss_phase`
  - `boss_anim_state`

### Defeat Flow Conflict

Docs differ on whether victory arena loads before KO or KO happens before arena.

Recommendation for MVP:

```text
boss_defeated
-> ko_sequence_started
-> boss KO/collapse in camera battle
-> loot drop/reward
```

Postpone full victory arena until after first playable.

### Scope Conflict

Phase 2 says no inventory/cat avatars, but core loop now requires Cat Hero and inventory save.

Recommendation:

- Treat current Core Game Loop as the MVP truth.
- Treat older phase limits as historical notes.

## Risk Report

### CRITICAL

Recording composed output.

Reason:

- Raw camera-only is forbidden.
- Native camera recording may not capture overlays.
- Must capture camera, AR, UI, effects, KO, loot, and reward exactly as seen.

Mitigation:

- Choose render stack and recording pipeline before gameplay implementation.
- Build a tiny composed recording prototype early.

### HIGH

Tracking stability and relock.

Reason:

- The whole illusion depends on boss staying on toy space.
- Marker physical size and detection algorithm are undefined.

Mitigation:

- Build tracking prototype first.
- Define marker real-world dimensions.
- Log confidence, drift, loss duration, relock correction, and hit-ignore windows.

### HIGH

Hit detection.

Reason:

- The spec says cat hits toy, but the input signal is undefined.

Mitigation:

- Pick v1 hit source:
  - manual tap debug first,
  - then optical toy motion or accelerometer/vision signal.
- Add debounce and false-positive filters.

### HIGH

Performance and heat.

Reason:

- Camera + tracking + animated boss + particles + recording is heavy.

Mitigation:

- Target 30 FPS for MVP camera battle.
- Lazy-load selected boss.
- Use atlases and effect caps.

### MEDIUM-HIGH

Boss asset pipeline.

Reason:

- Raw sheets exist, but extracted parts, pivots, manifests, and controllers do not.

Mitigation:

- Build a manual manifest for one boss first.
- Only automate extraction after one boss works.

### MEDIUM-HIGH

Cat Hero rig.

Reason:

- User photos and simple rig points are feasible but need data format and transform rules.

Mitigation:

- Use one photo and simple card for MVP.
- Add full 2.5D puppet after battle loop is stable.

### MEDIUM

Loot/inventory complexity.

Reason:

- Rarity, sets, duplicate handling, and inventory saves can expand fast.

Mitigation:

- MVP: one item reward, local save, no set bonuses.

### LOW

Folder structure.

Reason:

- Current structure is clean and understandable.

Mitigation:

- Keep docs and app modules aligned as implementation starts.

## Architecture Score

Score: 7 / 10

Reason:

- Strong vision.
- Good module separation.
- Good event-driven direction.
- Good asset organization.
- Main weaknesses are missing implementation infrastructure, event ownership conflicts, and undefined hit/recording/tracking implementation details.

## MVP Score

Score: 5 / 10

Reason:

- Enough specification exists to start.
- Enough assets exist for one prototype boss and several loot rewards.
- Not enough implementation decisions exist for camera, tracking, recording, hit detection, or rendering.
- The first playable build is achievable, but only if scope is cut hard.

## MVP Review

Enough for first playable build:

- One Cat Hero profile:
  - cat name
  - custom title
  - one uploaded/captured cat photo
- One VS screen:
  - Cat Hero card
  - one selected boss card
  - simple `VS` animation
- Camera battle:
  - live camera feed
  - canonical marker detection
  - stable lock
  - persistent anchor memory
  - portal spawn
  - one boss attached to anchor
- One boss:
  - use Boss01 or Boss10
  - manual manifest
  - simple rig parts
  - idle, hit, enraged, KO
- Combat:
  - debug tap or simple physical hit signal
  - HP bar
  - damage number
  - basic combo
  - one critical variant
  - KO
- Loot:
  - one reward item
  - rarity reveal
  - local inventory save
- Recording:
  - composed PHOTO first
  - short composed REC second
- Save:
  - cat profile
  - battle result
  - reward item

Not required for first playable:

- 10 bosses.
- Full boss import automation.
- Full Cat Hero 2.5D puppet.
- Full inventory screen.
- Set bonuses.
- AR fitting.
- Victory arenas.
- Worlds.
- Daily/weekly rotations.
- Social cards.
- Monster Book.
- Cat Kingdom.

## Recommended Build Order

### Build First

1. App shell and render stack.
2. Event bus.
3. Save manager.
4. Asset manager.
5. Composed rendering pipeline.
6. Composed PHOTO capture.
7. Tracking prototype with canonical marker.
8. Persistent anchor memory.
9. One boss manual manifest.
10. Boss anchored spawn.
11. Basic hit input.
12. HP and KO.
13. One loot reward save.

### Build Next

1. REC capture.
2. Boss procedural hit reactions.
3. Combo and critical feel.
4. Loot reveal animation.
5. Cat Hero card and title.
6. Simple Cat Hero finisher.
7. Inventory view.
8. Asset extraction helper.

### Freeze Now

- Phase 10-14 expansion.
- World rotations.
- Seasonal events.
- Monster Book.
- Cat Kingdom.
- Legend layer.
- Multiplayer/community ideas.
- Automatic cat tracking.

### Postpone

- 10 full bosses.
- Full equipment set bonuses.
- AR fitting.
- Full 2.5D Cat Hero rig.
- Victory arenas.
- Social exports.
- Daily rewards.

## Recommended Roadmap

### Foundation Sprint

Goal:

- Make the app technically possible.

Deliverables:

- Event bus.
- Save manager.
- Asset manager.
- Renderer decision.
- Recording prototype decision.
- One-screen debug harness.

### Tracking Sprint

Goal:

- Prove the toy portal illusion.

Deliverables:

- Marker detect.
- Stable lock.
- Anchor memory.
- Relock.
- Status UI.
- Drift/loss debug overlay.

### Battle Prototype Sprint

Goal:

- First real battle.

Deliverables:

- One boss.
- Portal spawn.
- HP.
- Hit input.
- Damage feedback.
- KO.

### Reward Sprint

Goal:

- Make victory feel rewarding.

Deliverables:

- One loot item.
- Rarity reveal.
- Local save.
- Reward screen.
- Composed PHOTO.

### Recording Sprint

Goal:

- Prove shareable battle clip.

Deliverables:

- Composed REC.
- Export to Photos.
- Capture validation.
- Performance pass.

### Expansion Sprint

Goal:

- Add variety only after MVP loop works.

Deliverables:

- More bosses.
- More loot.
- Better Cat Hero.
- Inventory UI.
- Optional victory arena.

## Final Diagnosis

The project has a strong creative direction and a surprisingly coherent architecture for a spec-stage prototype.

The current foundation is good enough to begin implementation, but not good enough to begin all systems at once.

The first dangerous mistake would be building inventory, worlds, arenas, or social features before proving:

```text
camera -> marker lock -> persistent anchor -> boss stays -> hit -> KO -> composed capture
```

That chain is the soul of the product.

Everything else should wait until that chain works.
