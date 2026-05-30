# Phase 5 Specification: Loot And Equipment Layer

Project title: LoopyCat RPG

Internal title: Loopy TV RPG

## Goal

Player defeats boss -> gets loot -> upgrades cat hero -> becomes stronger.

Phase 5 turns loot placeholders into inventory and equipment logic.

Do not build AR fitting now.

Build only:

- Loot drop animation
- Cinematic loot reveal animation
- Rarity system
- Item ownership
- Inventory screen
- Equipment slots
- Equip flow
- Cat Hero visual update placeholders

## Loot Drop Animation

After boss defeat, show loot drop animation.

Required flow:

1. Boss defeated.
2. `KO` and freeze frame play.
3. Portal becomes unstable.
4. Purple cracks and energy leak appear.
5. Boss body collapses.
6. Loot energy appears inside boss.
7. Item launches upward.
8. Item reveal animation plays.
9. Reward popup appears.
10. Item collects into inventory.
11. Item is saved.
12. Equip is offered as optional.
13. Cat Hero updates if item is equipped.

## Loot Asset Pipeline

Uploaded loot sheets contain separate items.

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

## Rarity System

Required rarities:

- `COMMON`
- `RARE`
- `EPIC`
- `LEGENDARY`
- `MYTHIC`

Rarity should affect presentation intensity, reward popup styling, and item value.

Rarity also affects:

- Beam color
- Particle color
- Orbit ring intensity
- Screen darkening
- Slow motion
- Text scale

Legendary and Mythic drops require:

- Screen dark
- Huge beam
- Slow motion
- Explosion
- Golden particles
- `MYTHIC` text for Mythic drops

## Drop Categories

Required categories:

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

## Equipment Slots

Required slots:

- `HEAD`
- `NECK`
- `BODY`
- `AURA`
- `TAIL`
- `TITLE`

Slot mapping:

- `CROWNS` and `HELMETS` -> `HEAD`
- `COLLARS` -> `NECK`
- `ARMOR` and `WINGS` -> `BODY`
- `AURAS` -> `AURA`
- `TAIL_FX` -> `TAIL`
- `TITLES` -> `TITLE`

## Inventory Screen

Required sections:

- Owned items
- Equipped items
- Locked items
- Collection %

Inventory must make collection progress clear.

## Equip Flow

Required flow:

1. Loot obtained.
2. Reward popup.
3. Save item.
4. Equip optional.
5. Cat Hero updates.

Equipping an item updates:

- Cat profile
- Cat Hero profile
- Equipped item slot
- Visual update placeholder
- Collection progress if newly obtained

## Loot Animation Support

Need support:

- Single loot
- Double loot
- Triple loot
- Legend burst
- Critical drop

Item reveal shows:

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

Cat Hero reaction:

- Cat looks at item
- Small jump
- Victory animation
- Tail motion
- Eye glow

## Visual Update Placeholders

Need visual update placeholders.

If item is equipped:

- Cat profile changes.
- Cat Hero presentation changes.
- Equipment slot displays item.
- Placeholder cosmetic appears where supported.

No final AR fitting is required.

## Future Support

Prepare future support for:

- AR preview
- Live fitting
- Animated cosmetics

Do not build these systems in Phase 5.

## Local Data

Store locally:

- Owned item ids
- Equipped item ids by slot
- Locked item definitions
- Collection progress
- Item rarity
- Item category
- Item display name
- Item visual placeholder key
- Item set name
- Item raw sheet path
- Item icon asset
- Item card asset
- Item animation profile

## Out Of Scope

Do not build in Phase 5:

- AR fitting
- Live fitting
- Real-time cat tracking
- Final animated cosmetics
- Cloud inventory sync

## Success Criteria

Phase 5 succeeds when:

- Boss defeat produces a loot drop animation.
- Loot reveal uses physical launch, spin, rarity effects, and collect animation.
- Reward popup shows obtained item.
- Item is saved to inventory.
- Player can choose to equip the item.
- Cat Hero updates when item is equipped.
- Inventory screen shows owned, equipped, locked, and collection progress.
- Future AR preview, live fitting, and animated cosmetics have placeholders only.
