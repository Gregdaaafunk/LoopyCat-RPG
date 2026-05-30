# Phase 4 Specification: Cat Hero System

Project title: LoopyCat RPG

Internal title: Loopy TV RPG

## Goal

Photo cat -> create hero -> hero fights bosses -> hero evolves -> loot changes appearance.

Phase 4 builds the Cat Hero system on top of the Cat Profile RPG layer.

Chosen Cat Hero direction:

- Path 2: pseudo-3D / 2.5D puppet.
- No paid AI API.
- No cloud.
- No AI video generation.
- No real 3D requirement.
- Everything local.

Detailed technical direction:

`06_Docs/cat_hero_path_2.md`

## Onboarding

### Step 1: Create Cat

User enters:

- Cat name

### Step 2: Photo Capture Sequence

Need multi-angle capture.

Capture order:

1. `FRONT`
2. `LEFT`
3. `RIGHT`

Optional:

- `BACK`
- `TOP`

Store all photos locally.

The capture flow should clearly guide the user through each required angle.

## Cat Hero Profile

Generate a Cat Hero profile after capture.

Required fields:

- `cat_id`
- `cat_name`
- `cat_title`
- `front_image`
- `left_image`
- `right_image`
- `rig_points`
- `equipment_slots`
- `animation_state`

Optional field:

- `back_image`
- `top_image`

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

Manual setup must be extremely simple:

- Tap points
- Simple draggable circles

No detailed masking required in v1.

## Cat Hero Introduction System

After cat creation and photo capture, generate a Cat Card for battle presentation.

Cat Card must show:

- Cat image
- Cat name
- Custom title
- Level

Custom title:

- User can type any title.
- Store the title locally with the Cat Hero profile.

Example titles:

- Shoigu Destroyer
- Max The Silent
- Rick The Broken Paw
- Mighty Hunter

## Fighter Presentation Screen

When a battle starts:

1. Boss selected.
2. VS screen opens.
3. Cat Hero card appears on the left.
4. Boss card appears on the right.
5. Center VS animation plays.
6. Lock in.
7. Fight starts.

Left side: Cat Hero card

Show:

- Cat image
- Cat name
- Custom title
- Level

Right side: Boss portrait

Rules:

- Temporary boss image is allowed.
- Use random temporary boss for now.
- Do not build final bosses now.
- Real bosses will be added later.

Center:

- `VS` animation

Presentation flow:

1. `CAT CARD`
2. `VS`
3. `BOSS CARD`
4. `LOCK IN`
5. `FIGHT`

Style target:

- Street Fighter
- Mortal Kombat intro energy
- Strong transition
- Screen effects
- Camera movement
- Impact flash

The player should feel: "My cat entered battle."

## Sound Placeholders

Add placeholders for:

- Cat Card reveal sound
- Boss Card reveal sound
- VS impact sound
- Lock-in sound
- Fight start sound

These are placeholders only. Final audio can arrive later.

## Future Presentation Support

Prepare future support for:

- Animated portraits
- Boss intro video
- Cat intro video

Do not generate videos in Phase 4.

## Cat Hero Animation System

Create a template animation system.

Do not generate video.

Use a local animation engine.

The Cat Hero should be animated in-app from local assets and profile data.

Required animation states:

- `IDLE`
- `JUMP`
- `PAW_ATTACK`
- `SUPER_ATTACK`
- `VICTORY_POSE`
- `KO_FINISHER`
- `LOOT_REACTION`

Animation logic:

- Use rig points as anchors.
- Move layers with transforms.
- Support translate, rotate, scale, squash/stretch, and depth fake.

## Victory Sequence

Required sequence:

1. Boss defeated.
2. Boss falls.
3. Portal collapse.
4. Cat Hero appears.
5. Cat Hero jumps in.
6. Cat Hero performs `SUPER_ATTACK`.
7. Boss gets KO.
8. Loot explosion.
9. Reward screen.

This sequence should make the cat feel like the hero of the fight, not only the profile owner.

## Equipment Appearance

Loot should be prepared to change Cat Hero appearance.

Phase 4 should connect equipment data to hero presentation at a placeholder/template level.

The goal is to support:

- Hero evolution
- Visible equipment changes
- Reward-driven appearance growth

Future equipment slots:

- `HEAD`
- `NECK`
- `BODY`
- `AURA`
- `TAIL_EFFECT`

Attachment examples:

- Collar attaches to neck/body area.
- Crown attaches above head.
- Aura attaches behind body.

## Storage Rules

Store locally:

- Cat Hero profile
- Multi-angle photos
- Custom title
- Rig points
- Equipment slots
- Current `animation_state`
- Wins
- XP
- Level

## Out Of Scope

Do not build in Phase 4:

- Generated video
- Paid AI API
- Cloud processing
- Real 3D cat model
- Detailed masking
- User-authored animation timeline
- Final boss roster
- Final boss portraits
- Live cat tracking
- AR fitting on real cat
- Cloud sync

## Success Criteria

Phase 4 succeeds when:

- User can enter cat name.
- User can enter custom title.
- User can capture front, left, and right photos.
- Optional back and top photos are supported.
- Cat Hero profile is generated with required fields.
- User can mark simple rig points with taps or draggable circles.
- Cat Card includes cat image, cat name, custom title, and level.
- VS screen shows Cat Hero card on the left and temporary boss card on the right.
- Presentation flow plays: `CAT CARD` -> `VS` -> `BOSS CARD` -> `LOCK IN` -> `FIGHT`.
- Cat Hero can play template animation states locally.
- Victory sequence includes Cat Hero appearance and attack.
- Cat Hero uses local 2.5D puppet animation.
- Loot can begin changing hero appearance through equipment data.
