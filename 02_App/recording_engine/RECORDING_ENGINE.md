# Recording Engine

Project title: LoopyCat RPG AR

## Goal

Saved video and photo must look exactly like the user sees on screen.

Raw camera-only capture is invalid.

## Technical Decision

Use composed-output capture.

There is one final composed frame. It feeds:

- On-screen display.
- PHOTO capture.
- REC capture.

The recorder must read the final render target after all visual layers are drawn.

## Required Captured Layers

Every PHOTO and REC output must include:

- Camera feed.
- Marker/toy-space content.
- Portal.
- Boss.
- HP.
- Damage numbers.
- Combo text.
- KO.
- Loot animation.
- Reward UI overlays.
- Debug overlay when debug capture is enabled.

## Rejected Plan

Do not use native camera recording plus separate overlay UI.

That path loses:

- Boss.
- Portal.
- HP.
- Damage numbers.
- Combo text.
- KO.
- Loot animation.
- UI overlays.

## Prototype Architecture

```text
camera frame
  -> render_composition camera layer
  -> anchor layer
  -> portal layer
  -> boss layer
  -> hit effect layer
  -> damage and combo layer
  -> HP and HUD layer
  -> KO and loot layer
  -> reward overlay layer
  -> final composed frame
  -> screen
  -> photo capture
  -> video encoder
  -> Photos save
```

## PHOTO Prototype

PHOTO flow:

1. Set `recording_state` to `CAPTURING_PHOTO`.
2. Request current final composed frame.
3. Encode frame as image.
4. Set `recording_state` to `EXPORTING`.
5. Save image to local Photos library.
6. Emit `recording_finished` with `mode: PHOTO`.

Failure:

- Emit `recording_failed`.
- Include `is_composed_output: true` if the frame source was composed.
- Include recoverable permission errors for Photos access.

## REC Prototype

REC flow:

1. Confirm composed output is active.
2. Set `recording_state` to `RECORDING`.
3. Emit `recording_started`.
4. For each display frame, copy the final composed frame to the encoder.
5. Preserve on-screen aspect, scale, and overlays.
6. Set `recording_state` to `EXPORTING`.
7. Finalize video.
8. Save video to local Photos library.
9. Emit `recording_finished` with `mode: REC`.

Failure:

- Stop encoder safely.
- Keep battle result and reward save intact.
- Emit `recording_failed`.

## Save To Photos Test

The first device test must verify:

- Photos permission request appears if needed.
- PHOTO saves to Photos.
- REC saves to Photos.
- Saved PHOTO includes camera, boss, portal, HP, damage/combo UI, and overlays.
- Saved REC includes camera, boss, portal, HP, damage/combo UI, KO, loot, and overlays.
- Saved output aspect matches screen output.
- No raw camera-only file is produced.

## Debug Fields

Recording debug panel shows:

- `recording_state`
- `composition_active`
- `photo_ready`
- `rec_ready`
- `last_mode`
- `saved_to_photos`
- `is_composed_output`
- `last_recording_error`
- `last_media_id`

## Event Payloads

`recording_started` payload:

- `battle_id`
- `mode`
- `is_composed_output`

Required:

- `is_composed_output`: `true`

`recording_finished` payload:

- `battle_id`
- `mode`
- `media_id`
- `saved_to_photos`
- `is_composed_output`

Required:

- `saved_to_photos`: `true` for successful MVP export.
- `is_composed_output`: `true`.

`recording_failed` payload:

- `battle_id`
- `mode`
- `error_code`
- `error_message`
- `is_recoverable`

## Acceptance Tests

- PHOTO cannot capture from raw camera source.
- REC cannot capture from raw camera source.
- Capture source is the final composed frame.
- Recording includes portal and boss.
- Recording includes HP, damage numbers, combo text, KO, loot, and UI overlays.
- Saved media reports `saved_to_photos: true`.
- Debug harness shows composition and capture readiness.
