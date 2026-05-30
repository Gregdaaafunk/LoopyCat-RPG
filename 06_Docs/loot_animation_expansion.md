# Loot Animation Expansion

Project title: LoopyCat RPG

Internal title: Loopy TV RPG

## Goal

Loot must feel earned.

Reward is not an image popup.

Reward is a cinematic RPG reveal with physics, rarity effects, Cat Hero reaction, collect animation, and local save.

## Source Assets

Uploaded loot sheets contain separate equipment items and set presentation art.

Raw sheets live in:

`04_Content/Loot/raw_sheets/`

Current raw sheets:

- `toy_emperor_raw_sheet.jpg`
- `chaos_hunter_raw_sheet.jpg`
- `spirit_walker_raw_sheet.jpg`
- `nature_guardian_raw_sheet.jpg`

Pipeline folders:

- `04_Content/Loot/raw_sheets`
- `04_Content/Loot/extracted_items`
- `04_Content/Loot/manifests`
- `04_Content/Loot/animations`

## Import Pipeline

Each loot sheet is processed into:

- Item sprites
- Item icon
- Item card
- Set preview
- Cat preview reference
- Manifest data
- Reveal animation profile

Pipeline steps:

1. Import raw loot sheet.
2. Assign `set_id`.
3. Assign item IDs.
4. Detect or manually mark item cells.
5. Extract item assets.
6. Save transparent item sprites.
7. Generate item manifests.
8. Generate reward animation profiles.
9. Register items with `loot_engine` and `inventory_engine`.

## Cinematic Reward Sequence

Full sequence:

1. Boss defeated.
2. `KO`.
3. Freeze frame.
4. Portal becomes unstable.
5. Purple cracks appear.
6. Energy leaks from portal and boss body.
7. Boss body collapses.
8. Loot energy appears.
9. Item launches upward.
10. Item reveal begins.
11. Camera focuses.
12. Item orbit effect plays.
13. Cat Hero reacts.
14. Item collects into inventory.
15. Reward is saved.

## Step 1: Loot Energy

Loot energy appears inside boss.

Required effects:

- Small light pulse
- Particles
- Smoke
- Ground glow

## Step 2: Item Launch

Item launches upward with physical motion.

Example:

- Crown flies up
- Small bounce
- Rotation
- Light trail
- Pause in air

Motion requirements:

- Launch velocity
- Gravity or eased arc
- Spin
- Bounce
- Air hang

## Step 3: Reveal State

Item enters reveal state.

Required effects:

- Slow spin
- Light beam from below
- Rarity color appears
- Shine pulse
- Floating particles

## Step 4: Camera Focus

Background darkens slightly.

Item becomes center object.

Show:

- Item icon
- Item name
- Rarity
- Set name

Example:

```text
SPIRIT HALO
EPIC
SPIRIT WALKER
```

## Step 5: Item Orbit Effect

Need:

- Rings
- Energy wave
- Magic symbols

Optional theme effects:

- Spirits
- Fire
- Water
- Void smoke

## Step 6: Cat Hero Reaction

Cat Hero reacts to item.

Required animation:

- Cat looks at item
- Small jump
- Victory animation
- Tail motion
- Eye glow

## Step 7: Collect Animation

Item collection flow:

1. Item shrinks.
2. Item flies into inventory.
3. Inventory pulses.
4. Reward saves locally.

## Drop Count Support

Need support:

- Single loot
- Double loot
- Triple loot
- Legend burst
- Critical drop

Multi-loot rules:

- Reveal items one by one.
- Keep previous revealed items visible as small cards.
- Save only after collect animation resolves.
- If save fails, keep reward screen visible and retry save.

## Legendary And Mythic Sequence

Legendary and Mythic drops require special treatment.

Required sequence:

1. Screen dark.
2. Huge beam.
3. Slow motion.
4. Explosion.
5. Golden particles.
6. Rarity text.

Mythic text:

- `MYTHIC`

Legend burst can reuse the same sequence at lower intensity.

## Rarity Presentation

Rarity colors:

- `COMMON`: white
- `RARE`: blue
- `EPIC`: purple
- `LEGENDARY`: gold
- `MYTHIC`: red-gold

Rarity controls:

- Beam color
- Particle color
- Ring intensity
- Shake intensity
- Slow-motion duration
- Text scale
- Audio placeholder

## Animation States

Reward animation states:

- `KO_FREEZE`
- `PORTAL_UNSTABLE`
- `BOSS_COLLAPSE`
- `LOOT_ENERGY`
- `ITEM_LAUNCH`
- `ITEM_REVEAL`
- `RARITY_BURST`
- `ITEM_ORBIT`
- `CAT_REACTION`
- `COLLECT_TO_INVENTORY`
- `REWARD_SAVED`

## Audio Placeholders

Sound placeholders:

- `loot_energy`
- `item_launch`
- `item_reveal`
- `rarity_common`
- `rarity_rare`
- `rarity_epic`
- `rarity_legendary`
- `rarity_mythic`
- `inventory_collect`
- `inventory_pulse`

## Engine Ownership

Owned by:

- `loot_engine`
- `animation_engine`
- `ui_engine`

Used by:

- `inventory_engine`
- `cat_profile_engine`
- `recording_engine`

## Recording Rule

REC and PHOTO must capture:

- KO freeze
- Portal instability
- Purple cracks
- Boss collapse
- Loot energy
- Item launch
- Item reveal
- Rarity effects
- Item name
- Rarity
- Set name
- Cat Hero reaction
- Collect animation
- Inventory pulse
- Reward UI

Raw camera-only output is invalid.

## Out Of Scope

Do not build:

- Static popup-only rewards.
- Cloud reward generation.
- Online inventory.
- AR fitting.

## Success Criteria

Loot Animation Expansion succeeds when:

- Loot sheets import into structured item assets.
- Reward sequence starts after KO.
- Item launches with physical motion.
- Reveal state shows item identity and rarity.
- Legendary and Mythic drops feel special.
- Cat Hero reacts to the reward.
- Item collects into inventory and saves locally.
- REC and PHOTO capture the composed reward moment.
