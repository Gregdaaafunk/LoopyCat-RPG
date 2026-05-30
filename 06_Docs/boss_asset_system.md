# Boss Asset System

Project title: LoopyCat RPG

Internal title: Loopy TV RPG

## Goal

Boss feels alive.

Not image.

Animated enemy with reactions.

## Source Assets

Separated boss sheets are imported as game rig assets.

Raw sheets live in:

`04_Content/Bosses/raw_sheets/`

Pipeline folders:

- `04_Content/Bosses/raw_sheets`
- `04_Content/Bosses/extracted_parts`
- `04_Content/Bosses/manifests`
- `04_Content/Bosses/controllers`

## Import Pipeline

Each boss sheet is processed into:

- Boss manifest
- Extracted part images
- Animation controller data
- UI portrait
- Inventory icon
- FX references
- Sound placeholders

Pipeline steps:

1. Import raw boss sheet.
2. Assign `boss_id`.
3. Detect or manually mark asset cells.
4. Extract boss parts.
5. Save transparent part assets.
6. Generate boss manifest.
7. Generate animation controller.
8. Validate required parts.
9. Register boss with `boss_engine`.

## Boss Parts

Required parts:

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

These are rig parts, not static screenshots.

## Boss Animation Controller

Required boss states:

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

The controller maps combat events to procedural part animation.

## Procedural Animation

Do not use static image.

Move parts.

### HEAD

Animation examples:

- Shake
- Rotate
- Bounce
- Recoil

### ARMS

Animation examples:

- Attack
- Grab
- Recoil
- Panic motion

### EYES

Animation examples:

- Glow pulse
- Color swap
- Rage mode
- Blink flash

### BODY

Animation examples:

- Squash
- Stretch
- Hit compression

### LOWER_BODY

Animation examples:

- Spring movement
- Bounce
- Attack charge

## Combat Feedback

When player hits boss, show:

- `HIT`
- `DOUBLE HIT`
- `TRIPLE HIT`
- `COMBO`
- `CRITICAL`
- `SUPER HIT`

Need:

- Flying numbers
- Camera shake
- Impact flash
- Hit particles
- Boss reaction animation

## Sound Placeholders

Boss sound placeholders:

- `damage_small`
- `damage_big`
- `rage`
- `spawn`
- `KO`

Temporary voice style:

- `ah`
- `ugh`
- `ha`
- `growl`
- `rage_scream`

## Street Fighter Arcade Feeling

Required feel:

- Big hit pauses
- Impact flashes
- Reactive boss parts
- Punchy numbers
- Combo banners
- Camera shake
- Loud placeholder impacts
- Enraged visual shift

## Manifest Shape

Each boss manifest should include:

- `boss_id`
- `boss_name`
- `raw_sheet`
- `parts`
- `states`
- `controller`
- `sounds`
- `portrait`
- `icon`

Example:

```text
boss_id: boss09
boss_name: Magma Titan
raw_sheet: 04_Content/Bosses/raw_sheets/boss09_raw_sheet.jpg
parts:
  HEAD
  BODY
  LEFT_ARM
  RIGHT_ARM
  LOWER_BODY
  EYES
  SHADOW
  FX
  SPAWN
  HIT
  ENRAGED
  DEFEATED
  PORTRAIT
  ICON
```

## Engine Ownership

Owned by:

- `boss_engine`
- `animation_engine`

Used by:

- `combat_engine`
- `ui_engine`
- `recording_engine`
- `loot_engine`

## Recording Rule

REC and PHOTO must capture animated boss parts, reactions, combat text, flying numbers, particles, and UI overlays as composed output.

Raw static sheet display is not acceptable in battle.

## Out Of Scope

Do not build:

- Static boss image combat.
- Fixed video boss animation.
- Cloud animation generation.
- Paid AI animation API.

## Success Criteria

Boss Asset System succeeds when:

- Boss sheets import into structured rig assets.
- Boss manifests define all required parts.
- Boss animation controller maps states to procedural motion.
- Hits trigger animated part reactions.
- Combo text, flying numbers, particles, camera shake, and flashes appear.
- Boss feels like a living arcade enemy.
