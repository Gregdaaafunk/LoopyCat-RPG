# Combat Feel System V1

Project title: LoopyCat RPG

Internal title: Loopy TV RPG

## Goal

Make battles feel powerful and arcade style.

Reference feeling:

- Arcade fighters
- Action games
- Fast impact combat

## Core Rule

Combat feedback is layered.

Player hits toy, boss reacts, combo builds, critical lands, boss enrages, KO triggers, loot appears, and Cat Hero finisher completes the fight.

## Layer 1: Basic Hit

Player hits toy.

Boss receives:

- Head shake
- Body recoil
- Small flash
- Damage number
- Particle burst
- Sound

Hit labels:

- `HIT`
- `LIGHT HIT`

Need random impact offsets so repeated hits do not feel identical.

## Layer 2: Combo System

Track hit chain.

Required labels:

- `DOUBLE HIT`
- `TRIPLE HIT`
- `COMBO x5`
- `COMBO x10`

Text style:

- Large
- Bold
- Arcade
- Screen pop

Need combo timer.

Miss window resets combo.

## Layer 3: Critical System

Criticals are random.

Required labels:

- `CRITICAL`
- `SUPER HIT`
- `MEGA HIT`

Critical impact requires:

- Camera punch
- Screen flash
- Larger particles
- Slow motion for 150-250 ms
- Heavy sound

## Layer 4: Boss Emotion

HP-based emotion states:

- HP > 70: normal
- HP 70-40: angry
- HP < 40: `ENRAGED`
- HP < 10: `DESPERATE`

Angry behavior:

- Eyes glow
- Extra motion

Enraged behavior:

- Effects increase
- Rage aura
- Faster reactions

Desperate behavior:

- Unstable motion
- Particles
- Panic state

## Layer 5: Impact Effects

Impact effects:

- Camera shake
- Micro zoom
- Screen vibration
- Hit sparks
- Dust
- Smoke
- Magic burst

Intensity levels:

- `small`
- `medium`
- `heavy`
- `boss_kill`

## Layer 6: KO Sequence

Boss HP reaches 0.

Required flow:

1. Freeze frame for 200 ms.
2. Show `KO`.
3. Boss launch.
4. Boss collapse.
5. Defeat animation.
6. Portal collapse.
7. Loot explosion.
8. Cat Hero finisher.
9. Reward screen.

## Layer 7: Floating Damage

Damage types:

- Normal damage
- Critical damage
- Combo damage
- Heal support future

Colors:

- White
- Yellow
- Orange
- Red

Movement:

- Rise
- Fade
- Scale
- Bounce

## Layer 8: Audio Placeholders

Sound placeholders:

- `spawn`
- `hit_small`
- `hit_heavy`
- `combo`
- `critical`
- `rage`
- `KO`
- `loot`

Voice placeholders:

- `ugh`
- `ah`
- `growl`
- `rage`
- `panic`

## Layer 9: Style Mode

Default style mode:

- `Arcade Fantasy`

Future themes:

- `Spirit`
- `Void`
- `Aquarium`
- `Chaos`
- `Mechanical`

## Engine Ownership

Owned by:

- `combat_engine`
- `animation_engine`
- `ui_engine`

Used by:

- `boss_engine`
- `recording_engine`
- `loot_engine`

## Recording Rule

REC and PHOTO must capture:

- Boss reactions
- Hit labels
- Floating damage
- Combo banners
- Critical flashes
- Camera punch
- Particles
- KO sequence
- UI overlays

Raw camera-only output is invalid.

## Success Criteria

Combat Feel V1 succeeds when:

- Basic hits make boss parts react.
- Combos build and reset correctly.
- Critical hits feel larger than normal hits.
- Boss emotion changes with HP.
- KO produces freeze frame, launch, collapse, portal collapse, loot explosion, Cat Hero finisher, and reward screen.
- REC and PHOTO capture the composed combat feel exactly as seen on screen.
