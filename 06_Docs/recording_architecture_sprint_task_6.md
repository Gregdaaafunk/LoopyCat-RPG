# Task 6: Recording Architecture Sprint

## Goal

Saved video and photo look exactly like the user sees on screen.

## Implemented Contract

Primary contract:

`02_App/recording_engine/RECORDING_ENGINE.md`

Supporting contract:

`02_App/render_composition/RENDER_COMPOSITION_DECISION.md`

## Technical Decision

Use final composed-output capture.

The screen, PHOTO, and REC share the same final frame source. Raw camera-only recording is invalid.

## Prototype

```text
final composed frame
  -> screen
  -> still image encoder
  -> video frame encoder
  -> local Photos save
```

PHOTO:

- Capture one composed frame.
- Encode image.
- Save to Photos.

REC:

- Capture composed frames over time.
- Encode video.
- Save to Photos.

## Required Output Layers

- Camera feed.
- Boss.
- Portal.
- HP.
- Damage numbers.
- Combo text.
- KO.
- Loot animation.
- UI overlays.

## Test Save To Photos

Device test must prove:

- PHOTO saves to Photos.
- REC saves to Photos.
- Both saved outputs include all composed gameplay/UI layers.
- No raw camera-only media is produced.

## Done

- Technical decision recorded.
- Composed-output prototype defined.
- PHOTO capture path defined.
- REC capture path defined.
- Photos save acceptance test defined.
- Raw camera-only path rejected.
