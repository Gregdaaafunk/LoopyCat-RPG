# Cat Hero System: Path 2

Project title: LoopyCat RPG

Internal title: Loopy TV RPG

## Chosen Direction

Use pseudo-3D / 2.5D Cat Hero.

Goal:

Turn user cat photos into a simple animated fighter avatar.

Rules:

- No paid AI API.
- No cloud.
- No AI video generation.
- No real 3D requirement.
- Everything local.

This is local 2.5D puppet animation.

## User Flow

1. User creates cat profile.
2. User enters cat name.
3. User enters custom title.
4. User captures or uploads cat photos.
5. App creates Cat Rig.
6. App uses predefined animation templates.
7. Cat Hero appears in battle and victory finisher.

## Required Cat Photos

Required:

- `FRONT`
- `LEFT`
- `RIGHT`

Optional:

- `BACK`
- `TOP`

## Cat Rig

Cat Rig is not real 3D.

Cat Rig is a layered 2.5D puppet.

Need simple manual assist.

User marks points / zones:

- `HEAD`
- `BODY`
- `LEFT_FRONT_PAW`
- `RIGHT_FRONT_PAW`
- `TAIL`

Optional:

- `LEFT_EAR`
- `RIGHT_EAR`

Manual setup must be extremely simple.

Use:

- Tap points
- Simple draggable circles

Do not require:

- Complex editing
- Detailed masking
- Manual frame animation

## Stored Cat Hero Data

Store:

- `cat_id`
- `cat_name`
- `cat_title`
- `front_image`
- `left_image`
- `right_image`
- `rig_points`
- `equipment_slots`
- `animation_state`

Optional stored images:

- `back_image`
- `top_image`

## Animation System

User does not animate manually.

App uses predefined animation templates:

- `IDLE`
- `JUMP`
- `PAW_ATTACK`
- `SUPER_ATTACK`
- `VICTORY_POSE`
- `KO_FINISHER`
- `LOOT_REACTION`

Animation logic:

- Use rig points as anchors.
- Move layers with local transforms.

Supported transforms:

- Translate
- Rotate
- Scale
- Squash/stretch
- Depth fake

## Victory Finisher

After boss defeated:

1. Cat Hero appears.
2. Cat Hero jumps in.
3. Cat Hero performs `SUPER_ATTACK`.
4. Boss gets KO.
5. Loot explosion.
6. Reward appears.

The player should feel:

"My real cat became a game fighter."

## Equipment Support

Future slots:

- `HEAD`
- `NECK`
- `BODY`
- `AURA`
- `TAIL_EFFECT`

Items attach to rig points.

Examples:

- Collar attaches to neck/body area.
- Crown attaches above head.
- Aura attaches behind body.

## Out Of Scope

Do not build:

- Real 3D cat model.
- AI video generation.
- Cloud processing.
- Paid AI API dependency.
- Complex manual masking.
- User-authored animation timeline.

## Success Criteria

Path 2 succeeds when:

- User can create a Cat Hero from local photos.
- User can mark simple rig points with taps or draggable circles.
- App stores rig points locally.
- App plays predefined template animations.
- Equipment has future attachment slots.
- Victory finisher uses the Cat Hero puppet.
- The system feels like the user's real cat became a game fighter.
