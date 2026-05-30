# Victory Arena System

Project title: LoopyCat RPG

Internal title: Loopy TV RPG

## Goal

Every victory feels different.

After boss defeat, use a dynamic live animation scene.

Do not play fixed video.

## Core Rule

Victory arena is a live animation scene.

Flow:

1. Boss defeated.
2. Arena loads.
3. Cat Hero enters.
4. Cat Hero performs finisher.
5. Boss gets KO.
6. Portal becomes unstable.
7. Boss collapses.
8. Loot explosion.
9. Loot reveal animation.
10. Reward screen.

## Required Arena Count

Need 10 arenas.

## Arena 01: Aquarium Depth

Theme:

- Underwater ruins
- Bubbles
- Blue light
- Broken columns

## Arena 02: Chaos Rift

Theme:

- Floating rocks
- Cracks
- Red energy
- Smoke

## Arena 03: Spirit Temple

Theme:

- Runes
- Candles
- Fog
- Ancient symbols

## Arena 04: Void Chamber

Theme:

- Purple darkness
- Particles
- Floating fragments

## Arena 05: Ancient Arena

Theme:

- Stone floor
- Giant statues
- Old battle ground

## Arena 06: Lava Forge

Theme:

- Magma
- Sparks
- Heat waves

## Arena 07: Storm Peak

Theme:

- Lightning
- Clouds
- Rain effects

## Arena 08: Moon Garden

Theme:

- Night sky
- Glowing plants
- Spirit lights

## Arena 09: Toy Kingdom

Theme:

- Giant toys
- Cat theme
- Playful environment

## Arena 10: Portal Throne

Theme:

- Massive gate
- Vortex
- Floating energy rings

## Arena Selection

Need random arena selection.

Initial behavior:

- Pick a random arena after boss defeat.
- Load arena before Cat Hero finisher.

Future world mapping:

```text
Boss type -> preferred arena
```

Examples:

- Water boss -> Aquarium Depth
- Chaos boss -> Chaos Rift
- Spirit boss -> Spirit Temple
- Void boss -> Void Chamber
- Ancient boss -> Ancient Arena

## Animation Flow

Required flow:

1. Boss defeated.
2. Arena loads.
3. Cat Hero enters.
4. Attack.
5. KO.
6. Portal instability.
7. Loot burst.
8. Item reveal.
9. Cat Hero reward reaction.
10. Reward screen.

## Supported Effects

Need support:

- Camera shake
- Particles
- Screen flash
- Title cards

## Engine Ownership

Owned by:

- `animation_engine`

Uses data from:

- `boss_engine`
- `cat_profile_engine`
- `loot_engine`

Observed by:

- `ui_engine`
- `recording_engine`

Recording rule:

- REC and PHOTO must capture the arena, Cat Hero, KO, loot burst, effects, and UI overlays as composed output.

## Out Of Scope

Do not build:

- Fixed video finisher playback.
- Cloud-generated animation.
- AI-generated video.
- Real 3D arena requirement.

## Success Criteria

Victory Arena succeeds when:

- Boss defeat can load a dynamic arena.
- Cat Hero enters the arena.
- Cat Hero performs a finisher.
- Boss gets KO.
- Loot explosion plays.
- Loot reveal animation plays.
- Reward screen appears.
- Arena selection can be random.
- Future boss-type arena mapping is prepared.
