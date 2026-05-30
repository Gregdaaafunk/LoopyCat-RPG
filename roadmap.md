# LoopyCat RPG Roadmap

Internal title: Loopy TV RPG

## Phase 1

Battle prototype only:

- Detect toy
- Lock canonical marker
- Create stable anchor
- Show `TARGET LOCKED`
- Open portal from marker center
- Spawn one boss through portal emergence
- Reduce HP from toy hits
- Defeat boss
- Drop loot result
- Record video with boss, damage, effects, and UI

Do not build inventory, avatars, or full RPG systems in Phase 1.

## Phase 2

Arcade battle upgrade:

- Random boss system
- 10 bosses
- No repeated boss every time
- Boss intro animation
- Portal spawn animation
- `TARGET LOCKED`
- Circular vortex
- Spiral energy
- Monster emergence
- Street Fighter style VS screen
- Boss name card
- Boss HP phases
- KO animation
- Victory state
- Damage numbers
- Comic hit text
- Screen flash
- Particles
- Lock effects
- Victory burst
- Loot v1 placeholders

Required boss fields:

- `boss_id`
- `boss_name`
- `boss_type`
- `boss_phase`
- `boss_drop_table`

Do not build inventory, avatars, or AR fitting in Phase 2.

## Phase 3

Cat Profile RPG layer:

- First launch onboarding
- Cat profile creation
- Cat name
- Cat photo
- Optional second photo
- Local save
- Cat Card generation
- Victory reward system
- Loot drop screen after boss defeat
- Equipment slots
- Cat profile screen

Required Cat Card fields:

- `cat_id`
- `cat_name`
- `cat_avatar`
- `level`
- `xp`
- `wins`
- `bosses_defeated`
- `equipped_items`

Loot categories:

- `collars`
- `crowns`
- `armor`
- `wings`
- `magic_effects`
- `toys`
- `titles`

Loot rarity:

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

Victory flow:

1. Boss defeated.
2. Portal closes.
3. Loot explosion.
4. Reward card.
5. Item obtained.
6. Cat profile updated.

Do not build AR fitting or live cat tracking in Phase 3.

## Phase 4

Cat Hero system:

- Create cat onboarding
- Cat name input
- Multi-angle photo capture
- Local photo storage
- Cat Hero profile generation
- Cat Card with custom title
- Fighter presentation screen
- Cat Hero left-side VS card
- Temporary boss right-side VS card
- Center VS animation
- Sound placeholders
- Local template animation engine
- Victory Cat Hero sequence
- Future rig placeholders
- Equipment appearance preparation

Capture order:

1. `FRONT`
2. `LEFT`
3. `RIGHT`
4. `BACK`

Optional:

- `TOP`

Required Cat Hero fields:

- `cat_id`
- `cat_name`
- `front_image`
- `left_image`
- `right_image`
- `back_image`
- `hero_state`
- `equipment`
- `wins`
- `xp`
- `level`

Cat Card shows:

- Cat image
- Cat name
- Custom title
- Level

Fighter presentation flow:

1. `CAT CARD`
2. `VS`
3. `BOSS CARD`
4. `LOCK IN`
5. `FIGHT`

Style:

- Street Fighter
- Mortal Kombat intro energy
- Strong transition
- Screen effects
- Camera movement
- Impact flash

Animation states:

- `IDLE`
- `RUN`
- `JUMP`
- `ATTACK`
- `SUPER_ATTACK`
- `VICTORY`
- `LOOT`

Victory sequence:

1. Boss defeated.
2. Boss falls.
3. Portal collapse.
4. Cat Hero appears.
5. Cat Hero attacks defeated boss.
6. KO animation.
7. Loot explosion.
8. Reward screen.

Future rig placeholders:

- `head`
- `body`
- `left_paw`
- `right_paw`
- `tail`
- `ear_anchors`

Do not generate video in Phase 4. Use a local animation engine.

Do not build final bosses in Phase 4. Use temporary random bosses.

## Phase 5

Loot and equipment layer:

- Loot drop animation after boss defeat
- Rarity system
- Drop categories
- Equipment slots
- Inventory screen
- Equip flow
- Cat Hero visual update placeholders
- Future AR preview hooks

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

Equip flow:

1. Loot obtained.
2. Reward popup.
3. Save item.
4. Equip optional.
5. Cat Hero updates.

Do not build AR fitting in Phase 5. Only inventory and equipment logic.

## Phase 6

AR fitting system:

- Photo Fit mode
- Live Camera Fit mode
- Manual equipment placement
- Fitting UI
- Local image save
- Future anchor placeholders

Modes:

- `PHOTO_FIT`
- `LIVE_CAMERA_FIT`

Photo Fit:

- Upload cat photo
- Place collars
- Place crowns
- Place helmets
- Place armor
- Place auras
- Place tail effects
- Move
- Rotate
- Scale
- Save preview

Live Camera Fit:

- Open camera
- Show cat
- Place equipment overlay
- Manual placement allowed

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

Future support:

- Automatic cat tracking
- Cat pose detection
- Live attachment
- Animated cosmetics

Do not build automatic tracking in Phase 6. Only fitting framework.

## Phase 7

Cat Evolution system:

- XP progression
- Level system
- Titles
- Battle history
- Boss kills
- Milestones
- Unlock effects
- Evolution stages
- Local cinematic system
- Hall of Fame

Evolution stage examples:

- Level 1: Street Cat
- Level 5: Toy Hunter
- Level 10: Boss Breaker
- Level 20: Portal Master
- Level 30: Chaos Destroyer

Major victory cinematic flow:

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

Future support:

- Special events
- Season bosses
- World bosses

Goal: Cat becomes hero. Hero becomes legend.

## Phase 8

Loopy World system:

- Seasonal content
- Worlds
- Season bosses
- Event bosses
- Limited drops
- Time rewards
- Boss rotation
- Collection system
- Achievements
- Local event framework

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

Event examples:

- Halloween
- New Year
- Summer Event
- Loopy Olympics

Future support:

- Global events
- Community goals
- World raids

Do not build multiplayer or online accounts in Phase 8. Everything is local.

## Phase 9

Local social layer:

- Cat showcase
- Victory cards
- Battle screenshots
- Reward posters
- Share screens
- Photo export
- Profile stats
- Collection pages

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

Save locally:

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

Future support:

- QR share
- Friend battles
- Cat exchange cards
- Community events

Do not build online mode in Phase 9. Everything is local.

## Phase 10

Physical toy unlocks:

- Toy ID system
- QR support
- Physical unlock system
- Exclusive loot
- Exclusive bosses
- Hidden rewards
- Serial support

Toy classes:

- Classic
- AR Edition
- Elite Edition
- Event Edition
- Collector Edition

Flow:

1. Toy scanned.
2. Unlock content.
3. Unlock bosses.
4. Unlock cosmetics.

Goal: Real toy unlocks digital content.

## Phase 11

Monster Book:

- Boss gallery
- Locked bosses
- Seen bosses
- Defeated bosses

Store:

- Boss rarity
- Boss world
- Boss type
- Drops
- Story

Categories:

- Water
- Chaos
- Spirit
- Void
- Ancient

Boss classes:

- Mini Boss
- Elite Boss
- Legend Boss
- World Boss

Goal: Player collects monsters.

## Phase 12

Expanded equipment system:

- Mythic items
- Set bonuses
- Evolution items
- Item upgrade
- Item evolution
- Visual changes

Support:

- 2-piece bonus
- 3-piece bonus
- Full set bonus

Example sets:

- Aquarium King
- Void Hunter
- Spirit Crown

Goal: Cat becomes stronger over time.

## Phase 13

Cat Kingdom:

- Hero room
- Trophy room
- Boss statues
- Loot display
- Collection wall
- Favorite items
- Top victories
- Rare collections

Themes:

- Aquarium
- Chaos
- Spirit
- Void

Goal: Player builds personal cat kingdom.

## Phase 14

Legend layer:

- Legend rank
- Ancient bosses
- Ultra rare drops
- Season history
- Hero archive
- Legend progression

Titles:

- Portal Master
- Chaos Destroyer
- Legend Cat
- World Hunter

Future support:

- Global events
- Special worlds
- Community systems

Goal: Cat becomes legend.

## Final Product Direction

Physical toy
-> AR battle
-> Boss fight
-> Loot
-> Cat Hero
-> Equipment
-> Inventory
-> AR fitting
-> Collections
-> Monster Book
-> Cat Kingdom
-> Legends
-> Loopy Universe

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
