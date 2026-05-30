[ ] Foundation Sprint
[ ] Game Flow Map V1
[ ] Game Flow Map user journey
[ ] Game Flow Map state diagram
[ ] Game Flow Map event diagram
[ ] Game Flow Map save points
[ ] Game Flow Map fail states
[ ] Game Flow Map restart points
[ ] Game Flow Map architecture view
[ ] Hit Detection Sprint Plan
[ ] Hit Detection design only
[ ] Hit input marker movement
[ ] Hit input marker speed
[ ] Hit input marker acceleration
[ ] Hit input marker occlusion
[ ] Hit input camera shake
[ ] Hit input sudden position jump
[ ] Hit input confidence drop
[ ] Hit input relock event
[ ] Hit tier LIGHT
[ ] Hit tier NORMAL
[ ] Hit tier HEAVY
[ ] Hit tier CRITICAL
[ ] Hit anti false ignore camera shake
[ ] Hit anti false ignore relock jumps
[ ] Hit anti false ignore tiny marker jitter
[ ] Hit cooldown
[ ] Hit confidence threshold
[ ] Hit motion smoothing
[ ] Hit output hit_confidence
[ ] Hit output hit_power
[ ] Hit output damage_value
[ ] Hit output combo_allowed
[ ] Hit output critical_allowed
[ ] Tracking Sprint
[ ] Tracking marker detection
[ ] Tracking stable lock
[ ] Tracking anchor memory
[ ] Tracking relock
[ ] Tracking signal unstable state
[ ] Tracking lost state
[ ] Boss does not disappear instantly
[ ] No HP reset after relock
[ ] No hit from relock jump
[ ] Boss Spawn Sprint
[ ] Boss Spawn TARGET LOCKED
[ ] Boss Spawn portal opens from marker
[ ] Boss Spawn vortex animation
[ ] Boss Spawn smoke particles
[ ] Boss Spawn boss emerges from portal
[ ] Boss Spawn boss name card
[ ] Boss Spawn HP appears
[ ] Boss Spawn battle starts
[ ] Recording Architecture Sprint
[ ] Recording technical decision
[ ] Recording composed output prototype
[ ] Recording save to Photos test
[ ] Recording includes camera feed
[ ] Recording includes boss
[ ] Recording includes portal
[ ] Recording includes HP
[ ] Recording includes damage numbers
[ ] Recording includes combo text
[ ] Recording includes KO
[ ] Recording includes loot animation
[ ] Recording includes UI overlays
[ ] Recording rejects raw camera-only
[ ] Event Bus module
[ ] Event Bus central event system
[ ] Event Bus one event one owner
[ ] Event Bus no duplicate emitters
[ ] Event marker_detected
[ ] Event lock_started
[ ] Event lock_confirmed
[ ] Event lock_lost
[ ] Event lock_restored
[ ] Event boss_spawned
[ ] Event boss_hit
[ ] Event combo_updated
[ ] Event critical_hit
[ ] Event boss_phase_change
[ ] Event boss_defeated
[ ] Event ko_sequence_started
[ ] Event loot_dropped
[ ] Event loot_reveal_started
[ ] Event loot_collected
[ ] Event reward_saved
[ ] Event cat_updated
[ ] Event recording_started
[ ] Event recording_finished
[ ] Event recording_failed
[ ] Save Manager module
[ ] Local save cat profile
[ ] Local save battle history
[ ] Local save reward item
[ ] Local save inventory item
[ ] Local save settings
[ ] No cloud saves
[ ] No account system
[ ] Asset Manager module
[ ] Asset loading boss assets
[ ] Asset loading loot assets
[ ] Asset loading marker image
[ ] Asset loading cat photo
[ ] Asset loading UI assets
[ ] Lazy loading
[ ] Do not load all bosses at once
[ ] Render Composition module
[x] Composed output decision
[x] REC captures composed output
[x] PHOTO captures composed output
[x] Raw camera-only recording invalid
[ ] Debug Harness module
[ ] Debug current state
[ ] Debug event log
[ ] Debug tracking state
[ ] Debug boss state
[ ] Debug combat state
[ ] Debug recording state
[ ] Debug loaded assets
[ ] Debug FPS
[ ] Debug errors
[ ] State Models module
[ ] State model tracking_state
[ ] State model combat_state
[ ] State model boss_anim_state
[ ] MVP Lock freeze 10 bosses
[ ] MVP Lock freeze full inventory
[ ] MVP Lock freeze cat 2.5D rig
[ ] MVP Lock freeze AR fitting
[ ] MVP Lock freeze worlds
[ ] MVP Lock freeze seasons
[ ] MVP Lock freeze Monster Book
[ ] MVP Lock freeze Cat Kingdom
[ ] MVP Lock freeze social cards
[ ] Boss system
[ ] Phase 1 battle prototype
[ ] Canonical marker integration
[x] Stable marker detection
[x] Camera tracking
[x] Target lock
[x] Lock states SEARCH/LOCKING/LOCKED/LOST/RELOCK
[x] World anchor creation
[x] Frozen toy-space anchor
[x] Aggressive re-lock
[x] TARGET LOCKED UI
[x] Portal spawn animation
[x] Portal born from marker center
[x] Circular vortex
[x] Spiral energy
[x] Glowing portal ring
[x] Particles pulled inward
[x] Smoke and mist
[x] Monster emergence sequence
[x] Boss eyes appear
[x] Boss head emerges
[x] Boss body rises
[x] Full boss form reveal
[x] Portal screen flash
[x] Marker center X/Y output
[x] Rotation output
[x] Distance estimate output
[x] Tracking confidence output
[ ] Hit confidence output
[ ] HP system
[ ] Hit detection
[ ] Loot system
[ ] One prototype boss
[ ] Victory animation
[x] Video recording
[x] Save to Photos
[ ] TestFlight pipeline
[ ] Phase 2 arcade battle upgrade
[ ] Boss Asset System
[ ] Boss sheet import pipeline
[ ] Boss raw sheets folder
[ ] Boss extracted parts folder
[ ] Boss manifests folder
[ ] Boss controllers folder
[ ] Treat boss sheets as rig assets
[ ] Boss part HEAD
[ ] Boss part BODY
[ ] Boss part LEFT_ARM
[ ] Boss part RIGHT_ARM
[ ] Boss part LOWER_BODY
[ ] Boss part EYES
[ ] Boss part SHADOW
[ ] Boss part FX
[ ] Boss part SPAWN
[ ] Boss part HIT
[ ] Boss part ENRAGED
[ ] Boss part DEFEATED
[ ] Boss part PORTRAIT
[ ] Boss part ICON
[ ] Boss animation controller
[ ] 10 boss roster
[ ] Random boss selection
[ ] Prevent repeated boss every time
[x] Boss intro animation
[ ] Street Fighter style VS screen
[x] Boss name card
[ ] KO animation
[ ] Victory state
[x] Boss state IDLE
[ ] Boss state ATTACK
[ ] Boss state HIT_REACTION
[ ] Boss state COMBO_REACTION
[ ] Boss state CRITICAL_HIT
[ ] Boss state PHASE_2
[ ] Boss state ENRAGED
[ ] Boss state KO
[ ] Boss state LOOT
[ ] Boss procedural head shake
[ ] Boss procedural head rotate
[ ] Boss procedural head bounce
[ ] Boss procedural head recoil
[ ] Boss procedural arms attack
[ ] Boss procedural arms grab
[ ] Boss procedural arms recoil
[ ] Boss procedural arms panic motion
[ ] Boss procedural eyes glow pulse
[ ] Boss procedural eyes color swap
[ ] Boss procedural eyes rage mode
[ ] Boss procedural eyes blink flash
[ ] Boss procedural body squash
[ ] Boss procedural body stretch
[ ] Boss procedural body hit compression
[ ] Boss procedural lower body spring movement
[ ] Boss procedural lower body bounce
[ ] Boss procedural lower body attack charge
[ ] Hit text HIT
[ ] Hit text DOUBLE HIT
[ ] Hit text TRIPLE HIT
[ ] Hit text COMBO
[ ] Hit text CRITICAL
[ ] Hit text SUPER HIT
[ ] Flying damage numbers
[ ] Boss impact camera shake
[ ] Boss impact flash
[ ] Boss hit particles
[ ] Boss sound placeholder damage_small
[ ] Boss sound placeholder damage_big
[ ] Boss sound placeholder rage
[ ] Boss sound placeholder spawn
[ ] Boss sound placeholder KO
[ ] Boss voice placeholder ah
[ ] Boss voice placeholder ugh
[ ] Boss voice placeholder ha
[ ] Boss voice placeholder growl
[ ] Boss voice placeholder rage scream
[ ] Boss must feel alive not image
[ ] Combat Feel System V1
[ ] Combat layer basic hit
[ ] Combat layer combo system
[ ] Combat layer critical system
[ ] Combat layer boss emotion
[ ] Combat layer impact effects
[ ] Combat layer KO sequence
[ ] Combat layer floating damage
[ ] Combat layer audio placeholders
[ ] Combat layer style mode Arcade Fantasy
[ ] Basic hit head shake
[ ] Basic hit body recoil
[ ] Basic hit small flash
[ ] Basic hit random impact offsets
[ ] Combo timer
[ ] Miss window resets combo
[ ] Hit text LIGHT HIT
[ ] Hit text COMBO x5
[ ] Hit text COMBO x10
[ ] Hit text MEGA HIT
[ ] Critical random roll
[ ] Critical slow motion 150 to 250 ms
[ ] Boss emotion normal over 70 percent
[ ] Boss emotion angry 70 to 40 percent
[ ] Boss emotion ENRAGED under 40 percent
[ ] Boss emotion DESPERATE under 10 percent
[ ] Impact effect camera punch
[ ] Impact effect micro zoom
[ ] Impact effect screen vibration
[ ] Impact intensity small
[ ] Impact intensity medium
[ ] Impact intensity heavy
[ ] Impact intensity boss kill
[ ] KO freeze frame 200 ms
[ ] KO boss launch
[ ] KO boss collapse
[ ] HP phase over 60 percent
[ ] HP phase 30 to 60 percent
[ ] HP phase under 30 percent
[ ] Damage numbers
[ ] Comic hit text
[ ] Screen flash
[ ] Particles
[ ] Lock effects
[ ] Victory burst
[ ] Loot v1 common placeholder
[ ] Loot v1 rare placeholder
[ ] Loot v1 epic placeholder
[ ] Loot v1 legendary placeholder
[ ] Boss data boss_id
[ ] Boss data boss_name
[ ] Boss data boss_type
[ ] Boss data boss_phase
[ ] Boss data boss_drop_table
[ ] Phase 3 cat profile RPG layer
[ ] First launch onboarding
[ ] Create cat profile
[ ] Cat name input
[ ] Cat photo input
[ ] Optional second cat photo
[ ] Local profile save
[ ] Generate Cat Card
[ ] Cat Card field cat_id
[ ] Cat Card field cat_name
[ ] Cat Card field cat_avatar
[ ] Cat Card field level
[ ] Cat Card field xp
[ ] Cat Card field wins
[ ] Cat Card field bosses_defeated
[ ] Cat Card field equipped_items
[ ] Victory reward system
[ ] Loot drop screen after boss defeat
[ ] Loot category collars
[ ] Loot category crowns
[ ] Loot category armor
[ ] Loot category wings
[ ] Loot category magic effects
[ ] Loot category toys
[ ] Loot category titles
[ ] Loot rarity COMMON
[ ] Loot rarity RARE
[ ] Loot rarity EPIC
[ ] Loot rarity LEGENDARY
[ ] Loot rarity MYTHIC
[ ] Equipment slot HEAD
[ ] Equipment slot NECK
[ ] Equipment slot BODY
[ ] Equipment slot AURA
[ ] Equipment slot TAIL_EFFECT
[ ] Cat profile screen
[ ] Cat image display
[ ] Cat level display
[ ] Equipped items display
[ ] Wins display
[ ] Collection progress display
[ ] Portal closes after victory
[ ] Loot explosion
[ ] Reward card
[ ] Item obtained flow
[ ] Cat profile updated after victory
[ ] Phase 4 Cat Hero system
[ ] Cat Hero Path 2 pseudo-3D 2.5D puppet
[ ] No paid AI API for Cat Hero
[ ] No cloud Cat Hero processing
[ ] No AI video generation
[ ] Create cat onboarding
[ ] Cat Hero cat name input
[ ] Cat Hero custom title input Path 2
[ ] Multi-angle photo capture
[ ] Capture FRONT
[ ] Capture LEFT
[ ] Capture RIGHT
[ ] Optional capture BACK
[ ] Optional capture TOP
[ ] Store all hero photos locally
[ ] Generate Cat Hero profile
[ ] Cat Card generation for battle intro
[ ] Cat Card cat image
[ ] Cat Card cat name
[ ] Cat Card custom title
[ ] Cat Card level
[ ] Cat Hero field cat_id
[ ] Cat Hero field cat_name
[ ] Cat Hero field cat_title
[ ] Cat Hero field front_image
[ ] Cat Hero field left_image
[ ] Cat Hero field right_image
[ ] Cat Hero optional field back_image
[ ] Cat Hero optional field top_image
[ ] Cat Hero field rig_points
[ ] Cat Hero field equipment_slots
[ ] Cat Hero field animation_state
[ ] Simple manual rig assist
[ ] Rig point HEAD
[ ] Rig point BODY
[ ] Rig point LEFT_FRONT_PAW
[ ] Rig point RIGHT_FRONT_PAW
[ ] Rig point TAIL
[ ] Optional rig point LEFT_EAR
[ ] Optional rig point RIGHT_EAR
[ ] Tap point rig setup
[ ] Draggable circle rig setup
[ ] No detailed masking v1
[ ] Fighter presentation screen
[ ] VS screen opens after boss selected
[ ] Left side Cat Hero card
[ ] Right side temporary boss portrait
[ ] Random temporary boss
[ ] Center VS animation
[ ] Presentation flow CAT CARD
[ ] Presentation flow VS
[ ] Presentation flow BOSS CARD
[ ] Presentation flow LOCK IN
[ ] Presentation flow FIGHT
[ ] Street Fighter presentation style
[ ] Mortal Kombat intro energy
[ ] Strong transition
[ ] Screen effects
[ ] Camera movement
[ ] Impact flash
[ ] Sound placeholder Cat Card reveal
[ ] Sound placeholder Boss Card reveal
[ ] Sound placeholder VS impact
[ ] Sound placeholder Lock in
[ ] Sound placeholder Fight start
[ ] Future animated portraits support
[ ] Future boss intro video support
[ ] Future cat intro video support
[ ] Local template animation engine
[ ] Animation state IDLE
[ ] Animation state JUMP
[ ] Animation state PAW_ATTACK
[ ] Animation state SUPER_ATTACK
[ ] Animation state VICTORY_POSE
[ ] Animation state KO_FINISHER
[ ] Animation state LOOT_REACTION
[ ] Rig transform translate
[ ] Rig transform rotate
[ ] Rig transform scale
[ ] Rig transform squash stretch
[ ] Rig transform depth fake
[ ] Victory sequence boss falls
[ ] Victory sequence portal collapse
[ ] Victory sequence Cat Hero appears
[ ] Victory sequence Cat Hero jumps in
[ ] Victory sequence Cat Hero SUPER_ATTACK
[ ] Victory sequence KO animation
[ ] Victory sequence loot explosion
[ ] Victory sequence reward screen
[ ] Victory Arena System
[ ] Dynamic finisher arenas
[ ] No fixed video finisher
[ ] Live animation scene finisher
[ ] Random arena selection
[ ] Arena 01 Aquarium Depth
[ ] Aquarium Depth underwater ruins
[ ] Aquarium Depth bubbles
[ ] Aquarium Depth blue light
[ ] Aquarium Depth broken columns
[ ] Arena 02 Chaos Rift
[ ] Chaos Rift floating rocks
[ ] Chaos Rift cracks
[ ] Chaos Rift red energy
[ ] Chaos Rift smoke
[ ] Arena 03 Spirit Temple
[ ] Spirit Temple runes
[ ] Spirit Temple candles
[ ] Spirit Temple fog
[ ] Spirit Temple ancient symbols
[ ] Arena 04 Void Chamber
[ ] Void Chamber purple darkness
[ ] Void Chamber particles
[ ] Void Chamber floating fragments
[ ] Arena 05 Ancient Arena
[ ] Ancient Arena stone floor
[ ] Ancient Arena giant statues
[ ] Ancient Arena old battle ground
[ ] Arena 06 Lava Forge
[ ] Lava Forge magma
[ ] Lava Forge sparks
[ ] Lava Forge heat waves
[ ] Arena 07 Storm Peak
[ ] Storm Peak lightning
[ ] Storm Peak clouds
[ ] Storm Peak rain effects
[ ] Arena 08 Moon Garden
[ ] Moon Garden night sky
[ ] Moon Garden glowing plants
[ ] Moon Garden spirit lights
[ ] Arena 09 Toy Kingdom
[ ] Toy Kingdom giant toys
[ ] Toy Kingdom cat theme
[ ] Toy Kingdom playful environment
[ ] Arena 10 Portal Throne
[ ] Portal Throne massive gate
[ ] Portal Throne vortex
[ ] Portal Throne floating energy rings
[ ] Future boss type preferred arena mapping
[ ] Victory arena camera shake
[ ] Victory arena particles
[ ] Victory arena screen flash
[ ] Victory arena title cards
[ ] Equipment attach HEAD
[ ] Equipment attach NECK
[ ] Equipment attach BODY
[ ] Equipment attach AURA
[ ] Equipment attach TAIL_EFFECT
[ ] Collar attaches to neck body area
[ ] Crown attaches above head
[ ] Aura attaches behind body
[ ] Equipment changes hero appearance
[ ] Phase 5 loot and equipment layer
[ ] Loot drop animation after boss defeat
[ ] Loot Animation Expansion
[ ] Loot raw sheets folder
[ ] Loot extracted items folder
[ ] Loot manifests folder
[ ] Loot animations folder
[ ] Loot sheet Toy Emperor
[ ] Loot sheet Chaos Hunter
[ ] Loot sheet Spirit Walker
[ ] Loot sheet Nature Guardian
[ ] Loot import pipeline
[ ] Loot item manifest
[ ] Loot animation profile
[ ] KO freeze before reward
[ ] Portal unstable before loot
[ ] Purple cracks before loot
[ ] Energy leak before loot
[ ] Boss body collapse before loot
[ ] Loot energy inside boss
[ ] Loot small light pulse
[ ] Loot particles
[ ] Loot smoke
[ ] Loot ground glow
[ ] Item launch upward
[ ] Item physical motion
[ ] Item bounce
[ ] Item rotation
[ ] Item light trail
[ ] Item pause in air
[ ] Item reveal state
[ ] Item slow spin
[ ] Light beam from below
[ ] Rarity color reveal
[ ] Shine pulse
[ ] Floating particles reward
[ ] Camera focus reward
[ ] Background darken reward
[ ] Reward shows item icon
[ ] Reward shows item name
[ ] Reward shows rarity
[ ] Reward shows set name
[ ] Item orbit rings
[ ] Item energy wave
[ ] Item magic symbols
[ ] Cat Hero looks at item
[ ] Cat Hero reward jump
[ ] Cat Hero victory reaction
[ ] Cat Hero tail motion
[ ] Cat Hero eye glow reward
[ ] Item shrinks into inventory
[ ] Inventory pulse
[ ] Reward save after collect
[ ] Single loot support
[ ] Double loot support
[ ] Triple loot support
[ ] Legend burst support
[ ] Critical drop support
[ ] Legendary screen dark
[ ] Legendary huge beam
[ ] Legendary slow motion
[ ] Legendary explosion
[ ] Legendary golden particles
[ ] Mythic text
[ ] Rarity system COMMON
[ ] Rarity system RARE
[ ] Rarity system EPIC
[ ] Rarity system LEGENDARY
[ ] Rarity system MYTHIC
[ ] Drop category COLLARS
[ ] Drop category CROWNS
[ ] Drop category HELMETS
[ ] Drop category ARMOR
[ ] Drop category AURAS
[ ] Drop category WINGS
[ ] Drop category TAIL_FX
[ ] Drop category TITLES
[ ] Example item Destroyer Collar
[ ] Example item Chaos Crown
[ ] Example item Void Aura
[ ] Example item Golden Hunter
[ ] Example item Flame Tail
[ ] Equipment slot HEAD phase 5
[ ] Equipment slot NECK phase 5
[ ] Equipment slot BODY phase 5
[ ] Equipment slot AURA phase 5
[ ] Equipment slot TAIL phase 5
[ ] Equipment slot TITLE phase 5
[ ] Inventory screen
[ ] Inventory owned items section
[ ] Inventory equipped items section
[ ] Inventory locked items section
[ ] Inventory collection percent
[ ] Equip flow loot obtained
[ ] Equip flow reward popup
[ ] Equip flow save item
[ ] Equip flow optional equip
[ ] Equip flow Cat Hero updates
[ ] Visual update placeholders
[ ] Cat profile changes when item equipped
[ ] Future AR preview support
[ ] Future live fitting support
[ ] Future animated cosmetics support
[ ] Phase 6 AR fitting system
[ ] PHOTO_FIT mode
[ ] LIVE_CAMERA_FIT mode
[ ] Photo Fit upload cat photo
[ ] Photo Fit place collars
[ ] Photo Fit place crowns
[ ] Photo Fit place helmets
[ ] Photo Fit place armor
[ ] Photo Fit place auras
[ ] Photo Fit place tail effects
[ ] Fitting control move
[ ] Fitting control rotate
[ ] Fitting control scale
[ ] Fitting control drag
[ ] Fitting control resize
[ ] Fitting control lock
[ ] Fitting control save
[ ] Save preview locally
[ ] Live Camera Fit open camera
[ ] Live Camera Fit show cat
[ ] Live Camera Fit equipment overlay
[ ] Manual placement allowed
[ ] Future anchor head
[ ] Future anchor neck
[ ] Future anchor body
[ ] Future anchor tail
[ ] Future anchor ear points
[ ] Save fitted image locally
[ ] Placement metadata item id
[ ] Placement metadata mode
[ ] Placement metadata x position
[ ] Placement metadata y position
[ ] Placement metadata rotation
[ ] Placement metadata scale
[ ] Placement metadata lock state
[ ] Future automatic cat tracking support
[ ] Future cat pose detection support
[ ] Future live attachment support
[ ] Phase 7 Cat Evolution system
[ ] XP progression
[ ] Level system
[ ] XP rewards
[ ] Titles progression
[ ] Battle history
[ ] Boss kills tracking
[ ] Milestones
[ ] Unlock effects
[ ] Evolution stage Level 1 Street Cat
[ ] Evolution stage Level 5 Toy Hunter
[ ] Evolution stage Level 10 Boss Breaker
[ ] Evolution stage Level 20 Portal Master
[ ] Evolution stage Level 30 Chaos Destroyer
[ ] Major victory local cinematic
[ ] Cinematic boss defeated
[ ] Cinematic portal unstable
[ ] Cinematic Cat Hero appears
[ ] Cinematic final attack
[ ] Cinematic boss collapse
[ ] Cinematic loot explosion
[ ] Cinematic title update
[ ] Cinematic reward screen
[ ] Animation placeholder arrival
[ ] Animation placeholder attack
[ ] Animation placeholder super attack
[ ] Animation placeholder victory
[ ] Animation placeholder loot collect
[ ] Animation placeholder pose
[ ] Hall of Fame
[ ] Hall of Fame bosses defeated
[ ] Hall of Fame best drops
[ ] Hall of Fame cat titles
[ ] Hall of Fame rare items
[ ] Future special events support
[ ] Future season bosses support
[ ] Future world bosses support
[ ] Phase 8 Loopy World system
[ ] Seasonal content framework
[ ] Season bosses
[ ] Event bosses
[ ] Limited drops
[ ] Time rewards
[ ] World Aquarium Realm
[ ] World Chaos Zone
[ ] World Spirit Cave
[ ] World Void Water
[ ] World Ancient Toy Temple
[ ] World own bosses
[ ] World own loot
[ ] World own visual theme
[ ] World data world_id
[ ] World data world_name
[ ] World data visual_theme
[ ] World data boss_pool
[ ] World data loot_pool
[ ] World data rotation_rules
[ ] Daily bosses
[ ] Weekly bosses
[ ] Special spawn bosses
[ ] Rotation history
[ ] Collection bosses found
[ ] Collection bosses defeated
[ ] Collection rare drops
[ ] Collection mythic drops
[ ] Collection cat achievements
[ ] Achievement First Hunter
[ ] Achievement Boss Slayer
[ ] Achievement Portal Breaker
[ ] Achievement Chaos Master
[ ] Achievement Legend Cat
[ ] Event Halloween
[ ] Event New Year
[ ] Event Summer Event
[ ] Event Loopy Olympics
[ ] Event data event_id
[ ] Event data event_name
[ ] Event data event_theme
[ ] Event data start_rule
[ ] Event data end_rule
[ ] Event data event_bosses
[ ] Event data limited_drops
[ ] Event data time_rewards
[ ] Daily return reward
[ ] Weekly return reward
[ ] Event participation reward
[ ] Special spawn reward
[ ] Future global events support
[ ] Future community goals support
[ ] Future world raids support
[ ] Local only no multiplayer
[ ] Local only no online accounts
[ ] Phase 9 local social layer
[ ] Cat showcase
[ ] Victory cards
[ ] Battle screenshots
[ ] Reward posters
[ ] Share screen after victory
[ ] Share screen Cat Hero
[ ] Share screen boss defeated
[ ] Share screen loot
[ ] Share screen title
[ ] Share screen level
[ ] Share screen rare item
[ ] Template VS_CARD
[ ] Template KO_CARD
[ ] Template LOOT_CARD
[ ] Template LEGEND_CARD
[ ] Photo export image
[ ] Photo export short animation
[ ] Photo export victory frame
[ ] Save exports locally
[ ] Profile stats cat name
[ ] Profile stats title
[ ] Profile stats level
[ ] Profile stats bosses defeated
[ ] Profile stats rare drops
[ ] Profile stats achievements
[ ] Boss gallery
[ ] Loot gallery
[ ] Cat history
[ ] Future QR share support
[ ] Future friend battles support
[ ] Future cat exchange cards support
[ ] Future community events support
[ ] Local only no online mode
[ ] Phase 10 physical toy unlocks
[ ] Toy ID system
[ ] QR support
[ ] Physical unlock system
[ ] Toy class Classic
[ ] Toy class AR Edition
[ ] Toy class Elite Edition
[ ] Toy class Event Edition
[ ] Toy class Collector Edition
[ ] Toy scanned flow
[ ] Unlock content
[ ] Unlock bosses
[ ] Unlock cosmetics
[ ] Exclusive loot
[ ] Exclusive bosses
[ ] Hidden rewards
[ ] Serial support
[ ] Phase 11 Monster Book
[ ] Monster Book boss gallery
[ ] Monster Book locked bosses
[ ] Monster Book seen bosses
[ ] Monster Book defeated bosses
[ ] Store boss rarity
[ ] Store boss world
[ ] Store boss type
[ ] Store boss drops
[ ] Store boss story
[ ] Monster category Water
[ ] Monster category Chaos
[ ] Monster category Spirit
[ ] Monster category Void
[ ] Monster category Ancient
[ ] Boss class Mini Boss
[ ] Boss class Elite Boss
[ ] Boss class Legend Boss
[ ] Boss class World Boss
[ ] Phase 12 expanded equipment system
[ ] Mythic items
[ ] Set bonuses
[ ] Evolution items
[ ] 2-piece bonus
[ ] 3-piece bonus
[ ] Full set bonus
[ ] Set Aquarium King
[ ] Set Void Hunter
[ ] Set Spirit Crown
[ ] Item upgrade
[ ] Item evolution
[ ] Equipment visual changes
[ ] Phase 13 Cat Kingdom
[ ] Hero room
[ ] Trophy room
[ ] Boss statues
[ ] Loot display
[ ] Collection wall
[ ] Kingdom theme Aquarium
[ ] Kingdom theme Chaos
[ ] Kingdom theme Spirit
[ ] Kingdom theme Void
[ ] Favorite items
[ ] Top victories
[ ] Rare collections
[ ] Phase 14 Legend layer
[ ] Legend rank
[ ] Ancient bosses
[ ] Ultra rare drops
[ ] Legend title Portal Master
[ ] Legend title Chaos Destroyer
[ ] Legend title Legend Cat
[ ] Legend title World Hunter
[ ] Season history
[ ] Hero archive
[ ] Legend progression
[ ] Future global events phase 14
[ ] Future special worlds support
[ ] Future community systems support
