# State Models

Project title: LoopyCat RPG AR

Purpose:

- Keep tracking, combat, boss animation, and recording states separate.
- Avoid state naming conflicts.
- Provide stable state contracts before gameplay starts.

## Tracking State

`tracking_state` values:

- `SEARCH`
- `LOCKING`
- `LOCKED`
- `TRACKING_MEMORY`
- `SIGNAL_UNSTABLE`
- `RELOCK`
- `RESTORED`
- `LOST`

Meaning:

- `SEARCH`: no marker candidate.
- `LOCKING`: marker candidate visible, confidence stabilizing.
- `LOCKED`: persistent anchor created.
- `TRACKING_MEMORY`: short marker loss, boss remains visible.
- `SIGNAL_UNSTABLE`: medium marker loss, boss remains visible with warning.
- `RELOCK`: marker candidate returned and is being reconciled.
- `RESTORED`: relock succeeded, hits ignored briefly.
- `LOST`: long marker loss, battle pauses but state persists.

## Combat State

`combat_state` values:

- `SPAWN`
- `IDLE`
- `HIT`
- `PHASE2`
- `ENRAGED`
- `DEFEATED`

Meaning:

- `SPAWN`: battle entity is entering.
- `IDLE`: combat active and waiting for hit.
- `HIT`: hit reaction and HP update are resolving.
- `PHASE2`: boss is in phase 2 combat range.
- `ENRAGED`: boss is in enraged combat range.
- `DEFEATED`: combat resolved and KO flow can begin.

## Boss Animation State

`boss_anim_state` values:

- `SPAWN`
- `IDLE`
- `ATTACK`
- `HIT_REACTION`
- `COMBO_REACTION`
- `CRITICAL_HIT`
- `PHASE_2`
- `ENRAGED`
- `KO`
- `LOOT`

Meaning:

- `SPAWN`: portal emergence animation.
- `IDLE`: alive idle motion.
- `ATTACK`: boss attack or threat motion.
- `HIT_REACTION`: normal hit response.
- `COMBO_REACTION`: combo hit response.
- `CRITICAL_HIT`: critical hit response.
- `PHASE_2`: phase transition presentation.
- `ENRAGED`: rage presentation.
- `KO`: defeat animation.
- `LOOT`: reward transition animation.

## Separation Rule

Do not merge these fields.

Examples:

- Tracking can be `TRACKING_MEMORY` while combat remains `IDLE`.
- Combat can be `ENRAGED` while boss animation is `HIT_REACTION`.
- Boss animation can be `KO` after combat is already `DEFEATED`.

## Recording State

`recording_state` values:

- `IDLE`
- `READY`
- `RECORDING`
- `CAPTURING_PHOTO`
- `EXPORTING`
- `FINISHED`
- `FAILED`

Meaning:

- `IDLE`: recording system is inactive.
- `READY`: composed output is available and capture can start.
- `RECORDING`: REC mode is actively capturing composed frames.
- `CAPTURING_PHOTO`: PHOTO mode is capturing the current composed frame.
- `EXPORTING`: media is being written locally / saved to Photos.
- `FINISHED`: capture/export succeeded.
- `FAILED`: capture/export failed and can expose an error.

Recording rule:

- `recording_state` describes capture/export only.
- It does not own battle, tracking, combat, loot, or save state.
- `RECORDING`, `CAPTURING_PHOTO`, and `EXPORTING` must use the final composed output, not raw camera-only capture.
