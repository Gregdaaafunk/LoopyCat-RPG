# LoopyCat RPG Mechanics

Internal title: Loopy TV RPG

## Phase 1 Battle Mechanics

Core loop:

1. Detect marker.
2. Lock target.
3. Create anchor.
4. Show `TARGET LOCKED`.
5. Open portal from marker center.
6. Boss emerges from portal.
7. Cat hits toy.
8. Reduce HP.
9. Defeat boss.
10. Drop loot result.

Required tracking states:

- `SEARCH`
- `LOCKING`
- `LOCKED`
- `TRACKING_MEMORY`
- `SIGNAL_UNSTABLE`
- `RELOCK`
- `RESTORED`
- `LOST`

Tracking memory rules:

- Marker is only needed for initial acquisition.
- After stable lock, boss stays attached to the last known anchor.
- Short marker loss from 0-1.5 seconds shows `LOCK STABLE`.
- Medium marker loss from 1.5-5 seconds shows `SIGNAL UNSTABLE`.
- Long marker loss after 5 seconds shows `SHOW MARKER AGAIN`.
- Boss must not disappear from slight camera movement.
- Fight must not reset on marker loss.
- HP must not hide on marker loss.
- Re-lock shows `TARGET RESTORED`.
- Hit detection is ignored for 400ms after re-lock.
- Hits must never be calculated from a re-lock jump.

Required outputs:

- Marker center X/Y
- Rotation
- Distance estimate
- Tracking confidence
- Hit confidence

## Phase 2 Boss Mechanics

Boss count: 10

Boss sheets are imported as rig assets, not static images.

Required boss parts:

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

Spawn:

- Random boss selection
- Avoid repeating the same boss every time
- Spawn only after stable marker lock and anchor creation
- Spawn through portal animation from marker center

Portal sequence:

- `LOCK CONFIRMED`
- Portal ring opens
- Vortex spins
- Smoke appears
- Eyes appear
- Head emerges
- Body rises
- Full boss form appears
- Screen flash
- Boss name card
- HP bar
- Fight starts

Boss states:

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

Procedural boss animation:

- Head shake, rotate, bounce, recoil.
- Arms attack, grab, recoil, panic motion.
- Eyes glow pulse, color swap, rage mode, blink flash.
- Body squash, stretch, hit compression.
- Lower body spring movement, bounce, attack charge.

Combat feedback:

- `HIT`
- `LIGHT HIT`
- `DOUBLE HIT`
- `TRIPLE HIT`
- `COMBO x5`
- `COMBO x10`
- `CRITICAL`
- `SUPER HIT`
- `MEGA HIT`
- Flying numbers
- Camera shake
- Camera punch
- Micro zoom
- Impact flash
- Hit particles
- Slow motion 150-250 ms on criticals

Combat Feel V1 layers:

- Basic hit
- Combo system
- Critical system
- Boss emotion
- Impact effects
- KO sequence
- Floating damage
- Audio placeholders
- Style mode

Boss emotion:

- HP > 70: normal
- HP 70-40: angry
- HP < 40: `ENRAGED`
- HP < 10: `DESPERATE`

Impact intensities:

- `small`
- `medium`
- `heavy`
- `boss_kill`

Boss sound placeholders:

- `damage_small`
- `damage_big`
- `rage`
- `spawn`
- `KO`

HP phases:

- HP > 60%: normal behavior
- HP 30-60%: more aggressive behavior
- HP < 30%: enraged mode

Required boss data:

- `boss_id`
- `boss_name`
- `boss_type`
- `boss_phase`
- `boss_drop_table`

Loot v1 rarities:

- `common`
- `rare`
- `epic`
- `legendary`

Loot remains placeholder-only. No inventory yet.

## Phase 3 Cat Profile Mechanics

First launch flow:

1. Show onboarding.
2. Create cat profile.
3. Enter cat name.
4. Add cat photo.
5. Optionally add second photo.
6. Save locally.
7. Generate Cat Card.

Cat Card fields:

- `cat_id`
- `cat_name`
- `cat_avatar`
- `level`
- `xp`
- `wins`
- `bosses_defeated`
- `equipped_items`

Victory reward flow:

1. Boss defeated.
2. Portal closes.
3. Loot explosion.
4. Reward card appears.
5. Item obtained.
6. Cat profile updated.

Loot categories:

- `collars`
- `crowns`
- `armor`
- `wings`
- `magic_effects`
- `toys`
- `titles`

Rarity:

- `COMMON`
- `RARE`
- `EPIC`
- `LEGENDARY`
- `MYTHIC`

Equipment slots:

- `HEAD`
- `NECK`
- `BODY`
- `AURA`
- `TAIL_EFFECT`

No AR fitting yet. No live cat tracking yet.

## Phase 4 Cat Hero Mechanics

Onboarding:

1. Create cat.
2. Enter cat name.
3. Enter custom title.
4. Capture cat photos in order.
5. Mark simple rig points.
6. Store photos and rig points locally.
7. Generate Cat Hero profile.

Chosen direction:

- Path 2 pseudo-3D / 2.5D puppet.
- No paid AI API.
- No cloud.
- No AI video generation.
- Not real 3D.

Photo capture order:

1. `FRONT`
2. `LEFT`
3. `RIGHT`

Optional:

- `BACK`
- `TOP`

Cat Hero profile fields:

- `cat_id`
- `cat_name`
- `cat_title`
- `front_image`
- `left_image`
- `right_image`
- `rig_points`
- `equipment_slots`
- `animation_state`

Rig points:

- `HEAD`
- `BODY`
- `LEFT_FRONT_PAW`
- `RIGHT_FRONT_PAW`
- `TAIL`

Optional rig points:

- `LEFT_EAR`
- `RIGHT_EAR`

Manual setup:

- Tap points
- Simple draggable circles
- No detailed masking required in v1

Cat Card fields:

- Cat image
- Cat name
- Custom title
- Level

Fighter presentation:

1. Boss selected.
2. VS screen opens.
3. Left side shows Cat Hero card.
4. Right side shows temporary boss portrait.
5. Center `VS` animation plays.
6. Lock in.
7. Fight starts.

Presentation flow:

1. `CAT CARD`
2. `VS`
3. `BOSS CARD`
4. `LOCK IN`
5. `FIGHT`

Use random temporary bosses for now. Do not build final bosses yet.

Sound placeholders:

- Cat Card reveal
- Boss Card reveal
- VS impact
- Lock in
- Fight start

Animation states:

- `IDLE`
- `JUMP`
- `PAW_ATTACK`
- `SUPER_ATTACK`
- `VICTORY_POSE`
- `KO_FINISHER`
- `LOOT_REACTION`

Animation logic:

- Use rig points as anchors.
- Move layered images with translate, rotate, scale, squash/stretch, and depth fake.

Victory sequence:

1. Boss defeated.
2. Victory arena loads.
3. Cat Hero enters.
4. Cat Hero jumps in.
5. Cat Hero performs `SUPER_ATTACK`.
6. Boss gets KO.
7. Loot explosion.
8. Reward screen.

Victory arenas:

- Aquarium Depth
- Chaos Rift
- Spirit Temple
- Void Chamber
- Ancient Arena
- Lava Forge
- Storm Peak
- Moon Garden
- Toy Kingdom
- Portal Throne

Arena rule:

- Use live animation scene.
- Do not play fixed video.
- Select random arena initially.
- Prepare future mapping from boss type to preferred arena.

Victory arena effects:

- Camera shake
- Particles
- Screen flash
- Title cards

Equipment support:

- `HEAD`
- `NECK`
- `BODY`
- `AURA`
- `TAIL_EFFECT`

Items attach to rig points.

Do not generate video. Use a local animation engine.

Prepare future support for animated portraits, boss intro video, and cat intro video.

## Phase 5 Loot And Equipment Mechanics

After boss defeat:

1. Show loot drop animation.
2. Show reward popup.
3. Save item.
4. Offer optional equip.
5. Update Cat Hero if equipped.

Loot Animation Expansion:

1. Boss defeated.
2. `KO`.
3. Freeze frame.
4. Portal becomes unstable.
5. Purple cracks appear.
6. Energy leaks.
7. Boss body collapses.
8. Loot energy appears inside boss.
9. Item launches upward.
10. Item reveal begins.
11. Camera focuses on item.
12. Item orbit effect plays.
13. Cat Hero reacts.
14. Item collects into inventory.
15. Reward saves locally.

Loot source sheets live in:

`04_Content/Loot/raw_sheets/`

Loot pipeline folders:

- `04_Content/Loot/raw_sheets`
- `04_Content/Loot/extracted_items`
- `04_Content/Loot/manifests`
- `04_Content/Loot/animations`

Rarity:

- `COMMON`
- `RARE`
- `EPIC`
- `LEGENDARY`
- `MYTHIC`

Drop categories:

- `COLLARS`
- `CROWNS`
- `HELMETS`
- `ARMOR`
- `AURAS`
- `WINGS`
- `TAIL_FX`
- `TITLES`

Example items:

- Destroyer Collar
- Chaos Crown
- Void Aura
- Golden Hunter
- Flame Tail

Equipment slots:

- `HEAD`
- `NECK`
- `BODY`
- `AURA`
- `TAIL`
- `TITLE`

Inventory sections:

- Owned items
- Equipped items
- Locked items
- Collection %

Visual update placeholders:

- Cat profile changes when item is equipped.
- Cat Hero presentation changes when item is equipped.
- Final AR fitting is not built yet.

Prepare future support for AR preview, live fitting, and animated cosmetics.

Loot animation support:

- Single loot
- Double loot
- Triple loot
- Legend burst
- Critical drop

Legendary and Mythic sequence:

- Screen dark
- Huge beam
- Slow motion
- Explosion
- Golden particles
- `MYTHIC` text for Mythic drops

## Phase 6 AR Fitting Mechanics

Modes:

- `PHOTO_FIT`
- `LIVE_CAMERA_FIT`

Photo Fit:

1. User uploads cat photo.
2. User selects equipped item.
3. User places equipment manually.
4. User moves, rotates, and scales item.
5. User locks placement.
6. User saves preview locally.

Live Camera Fit:

1. Open camera.
2. Show cat.
3. Place equipment overlay.
4. User adjusts overlay manually.
5. User locks placement.
6. User saves image locally.

Supported equipment:

- `COLLARS`
- `CROWNS`
- `HELMETS`
- `ARMOR`
- `AURAS`
- `TAIL_FX`

Fitting UI:

- Drag
- Rotate
- Resize
- Lock
- Save

Future anchors:

- `head`
- `neck`
- `body`
- `tail`
- `ear_points`

Do not build automatic cat tracking, cat pose detection, live attachment, or animated cosmetics in Phase 6.

## Phase 7 Cat Evolution Mechanics

Cat Hero gains:

- XP
- Levels
- Titles
- Battle history
- Boss kills

Required systems:

- Level system
- XP rewards
- Milestones
- Unlock effects

Evolution stages:

- Level 1: Street Cat
- Level 5: Toy Hunter
- Level 10: Boss Breaker
- Level 20: Portal Master
- Level 30: Chaos Destroyer

Major victory cinematic:

1. Boss defeated.
2. Portal unstable.
3. Cat Hero appears.
4. Final attack.
5. Boss collapse.
6. Loot explosion.
7. Title update.
8. Reward screen.

Animation placeholders:

- `arrival`
- `attack`
- `super_attack`
- `victory`
- `loot_collect`
- `pose`

Hall of Fame stores:

- Bosses defeated
- Best drops
- Cat titles
- Rare items

Prepare future support for special events, season bosses, and world bosses.

## Phase 8 Loopy World Mechanics

Seasonal content:

- Season bosses
- Event bosses
- Limited drops
- Time rewards

World examples:

- Aquarium Realm
- Chaos Zone
- Spirit Cave
- Void Water
- Ancient Toy Temple

Each world has:

- Own bosses
- Own loot
- Own visual theme

Boss rotation:

- Daily bosses
- Weekly bosses
- Special spawn bosses

Collection stores:

- Bosses found
- Bosses defeated
- Rare drops
- Mythic drops
- Cat achievements

Achievements:

- First Hunter
- Boss Slayer
- Portal Breaker
- Chaos Master
- Legend Cat

Event framework examples:

- Halloween
- New Year
- Summer Event
- Loopy Olympics

Everything is local. Do not build multiplayer or online accounts.

Prepare future support for global events, community goals, and world raids.

## Phase 9 Local Social Mechanics

Local social content:

- Cat showcase
- Victory cards
- Battle screenshots
- Reward posters

After victory, share screen shows:

- Cat Hero
- Boss defeated
- Loot
- Title
- Level
- Rare item

Templates:

- `VS_CARD`
- `KO_CARD`
- `LOOT_CARD`
- `LEGEND_CARD`

Photo export saves locally:

- Image
- Short animation
- Victory frame

Profile stats:

- Cat name
- Title
- Level
- Bosses defeated
- Rare drops
- Achievements

Collection pages:

- Boss gallery
- Loot gallery
- Cat history

Everything is local. Do not build online mode.

Prepare future support for QR share, friend battles, cat exchange cards, and community events.

## Goal

Physical cat toy
+
AR battles
+
Boss monsters
+
Loot
+
Cat avatars
+
Inventory
+
AR fitting
+
Victory videos
