# Phase 6 Specification: AR Fitting System

Project title: LoopyCat RPG

Internal title: Loopy TV RPG

## Goal

Player wins item -> equips item -> sees item on real cat.

Phase 6 builds the fitting framework.

Do not build automatic tracking now.

Build only:

- Photo fitting mode
- Live camera fitting mode
- Manual placement tools
- Save preview
- Future anchor placeholders

## Modes

Phase 6 needs two modes:

- `PHOTO_FIT`
- `LIVE_CAMERA_FIT`

## Mode 1: PHOTO FIT

User uploads cat photo.

Place equipment:

- Collars
- Crowns
- Helmets
- Armor
- Auras
- Tail effects

Required controls:

- Move
- Rotate
- Scale
- Save preview

Photo mode must allow the user to save the fitted image locally.

## Mode 2: LIVE CAMERA FIT

Open camera.

Show cat.

Place equipment overlay.

For now:

- Manual placement is allowed.
- User positions equipment by hand.
- No automatic cat tracking is required.

Need future anchors:

- `head`
- `neck`
- `body`
- `tail`
- `ear_points`

These are placeholder anchors for future automatic fitting.

## Fitting UI

Required fitting controls:

- Drag
- Rotate
- Resize
- Lock
- Save

Control rules:

- Drag moves selected equipment.
- Rotate changes selected equipment angle.
- Resize changes selected equipment scale.
- Lock prevents accidental movement.
- Save stores the preview locally.

## Supported Equipment Types

Phase 6 fitting should support visual placement for:

- `COLLARS`
- `CROWNS`
- `HELMETS`
- `ARMOR`
- `AURAS`
- `TAIL_FX`

Titles do not need physical fitting.

## Save Behavior

User can save image locally.

Save outputs:

- Photo Fit preview image
- Live Camera Fit snapshot image
- Placement metadata for equipped items

Placement metadata should include:

- Item id
- Mode
- X position
- Y position
- Rotation
- Scale
- Lock state
- Optional anchor placeholder

## Future Support

Prepare future support for:

- Automatic cat tracking
- Cat pose detection
- Live attachment
- Animated cosmetics

Do not build these systems in Phase 6.

## Out Of Scope

Do not build in Phase 6:

- Automatic cat tracking
- Cat pose detection
- Live attachment
- Final animated cosmetics
- Cloud sync for fitting previews

## Success Criteria

Phase 6 succeeds when:

- User can open Photo Fit.
- User can upload a cat photo.
- User can manually place equipment.
- User can move, rotate, scale, lock, and save.
- User can open Live Camera Fit.
- User can overlay equipment manually on camera.
- User can save a fitted image locally.
- Future anchors exist for head, neck, body, tail, and ear points.
- Automatic tracking remains out of scope.
