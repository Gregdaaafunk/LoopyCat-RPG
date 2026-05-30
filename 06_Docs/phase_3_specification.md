# Phase 3 Specification: Cat Profile RPG Layer

Project title: LoopyCat RPG

Internal title: Loopy TV RPG

## Goal

User starts building his own cat hero.

Phase 3 adds the Cat Profile system, victory rewards, equipment slots, and profile screen.

Do not build:

- AR fitting
- Live cat tracking
- Real-time wearable placement

Phase 3 is only the RPG layer.

## First Launch Onboarding

After first launch, show onboarding.

### Step 1: Create Cat Profile

Required inputs:

- Cat name
- Cat photo
- Optional second photo

Storage:

- Save locally.
- Persist profile data and selected photos on device.
- Use local-only data unless cloud sync is added in a later phase.

## Cat Card

Generate a Cat Card after profile creation.

Required fields:

- `cat_id`
- `cat_name`
- `cat_avatar`
- `level`
- `xp`
- `wins`
- `bosses_defeated`
- `equipped_items`

Initial values:

- `level`: 1
- `xp`: 0
- `wins`: 0
- `bosses_defeated`: 0
- `equipped_items`: empty slots

## Victory Reward System

After boss defeat, show a loot drop screen.

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

Rewards should update the cat profile after the victory flow completes.

## Equipment System

Phase 3 adds equipment ownership and slot assignment.

Slots:

- `HEAD`
- `NECK`
- `BODY`
- `AURA`
- `TAIL_EFFECT`

Equipment should affect the Cat Card and profile screen only.

No AR fitting yet.

No live cat tracking yet.

## Cat Profile Screen

Show:

- Cat image
- Name
- Level
- Equipped items
- Wins
- Collection progress

The profile screen should make the cat feel like the player's hero.

## Victory Flow

Required flow:

1. Boss defeated.
2. Portal closes.
3. Loot explosion.
4. Reward card appears.
5. Item obtained.
6. Cat profile updated.

The player should clearly understand that the boss fight made their cat stronger or more collectible.

## Data Rules

Required local data:

- Cat profile
- Cat photos
- Cat Card
- Owned reward items
- Equipped item slots
- Win count
- Boss defeat count
- XP and level
- Collection progress

## Out Of Scope

Do not build in Phase 3:

- AR fitting
- Live cat tracking
- Wearables attached to real cat video
- Multiplayer
- Cloud profile sync

## Success Criteria

Phase 3 succeeds when:

- First launch creates a local cat profile.
- Cat Card is generated with the required fields.
- Boss defeat opens a reward flow.
- Loot categories and rarities are represented.
- Obtained items can be assigned to equipment slots.
- Cat profile screen shows image, name, level, equipment, wins, and collection progress.
- The player feels they are building their own cat hero.
