# Recording Engine Implementation Contract

Project title: LoopyCat RPG AR

## Purpose

Capture PHOTO and REC from the final composed output.

## Non-Negotiable

Raw camera-only output is invalid.

## Inputs

- Final composed frame
- Recording mode
- Export destination
- Photos permission state

## Outputs

- `recording_started`
- `recording_finished`
- `recording_failed`
- Local media file
- Photos export result

## PHOTO Algorithm

```text
set recording_state = CAPTURING_PHOTO
read final composed frame
write image
save to Photos
if success:
  emit recording_finished
else:
  emit recording_failed
```

## REC Algorithm

```text
set recording_state = RECORDING
emit recording_started
while recording:
  read final composed frame
  append frame to encoder
set recording_state = EXPORTING
write video
save to Photos
if success:
  emit recording_finished
else:
  emit recording_failed
```

## Validation

Each capture must confirm:

- `contains_camera_feed`
- `contains_boss`
- `contains_portal`
- `contains_hp`
- `contains_damage_numbers`
- `contains_combo_text`
- `contains_ko`
- `contains_loot_animation`
- `contains_ui_overlays`

If validation fails:

- Emit `recording_failed`.
