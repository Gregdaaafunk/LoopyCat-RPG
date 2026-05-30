# Recording Architecture Sprint

Project title: LoopyCat RPG AR

Internal title: Loopy TV RPG

## Goal

Saved video must look exactly like user sees on screen.

Raw camera-only recording is invalid.

## Required Output

PHOTO and REC must include:

- Camera feed
- Boss
- Portal
- HP
- Damage numbers
- Combo text
- KO
- Loot animation
- UI overlays

## Runtime Note

This project currently has no runnable app runtime.

Native save-to-Photos cannot be tested until the app project exists.

This sprint defines the architecture decision, prototype requirement, and test checklist.

Primary module contract:

`02_App/recording_engine/RECORDING_ENGINE.md`

Implementation notes:

`02_App/recording_engine/RECORDING_ENGINE_IMPLEMENTATION.md`

## Technical Decision

Use one composed render output as the capture source.

The same composed frame feeds:

- On-screen display
- PHOTO export
- REC export

Do not use native camera-only recording.

Do not render boss/UI in layers that cannot be captured.

## Capture Stack Contract

Required architecture:

```text
camera frame
-> camera texture / camera layer inside render composition
-> AR toy-space content
-> portal
-> boss
-> combat UI
-> loot / KO / overlays
-> final composed frame
-> screen
-> PHOTO capture
-> REC encoder
```

## PHOTO Prototype

Prototype must:

1. Open camera feed or test camera frame.
2. Draw marker-anchored placeholder.
3. Draw boss placeholder.
4. Draw HP and UI overlay.
5. Capture final composed frame.
6. Save image locally / Photos.
7. Verify image includes all overlays.

## REC Prototype

Prototype must:

1. Start from composed frame output.
2. Encode frames over time.
3. Include camera feed and overlays.
4. Include animated portal/boss placeholders.
5. Save video locally / Photos.
6. Verify video matches on-screen composition.

## Recording States

Use `recording_state`:

- `IDLE`
- `READY`
- `RECORDING`
- `CAPTURING_PHOTO`
- `EXPORTING`
- `FINISHED`
- `FAILED`

## Events

Emitted by `recording_engine`:

- `recording_started`
- `recording_finished`
- `recording_failed`

## Debug Harness Fields

Show:

- Recording state
- Composed output active
- PHOTO readiness
- REC readiness
- Last recording error
- Output includes camera feed
- Output includes boss
- Output includes portal
- Output includes UI overlays
- Export destination

## Test Save To Photos Checklist

PHOTO test:

- Saved image exists.
- Saved image contains camera feed.
- Saved image contains boss.
- Saved image contains portal.
- Saved image contains HP/UI.
- Saved image is not raw camera-only.

REC test:

- Saved video exists.
- Saved video plays.
- Saved video contains camera feed.
- Saved video contains boss.
- Saved video contains portal.
- Saved video contains HP/UI.
- Saved video contains animation frames.
- Saved video is not raw camera-only.

Failure test:

- Permission denied emits `recording_failed`.
- Export failure emits `recording_failed`.
- User can retry export without losing battle result.

## Acceptance Criteria

Recording Architecture Sprint is ready when:

- Composed output is the only capture source.
- PHOTO prototype captures overlays.
- REC prototype captures overlays.
- Save-to-Photos path is tested in app runtime.
- Raw camera-only path is rejected.
