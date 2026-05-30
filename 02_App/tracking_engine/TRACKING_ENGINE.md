# Tracking Engine

Project title: LoopyCat RPG AR

## Goal

The marker opens the portal once.

After lock, the boss stays attached to the toy through anchor memory instead of disappearing when marker detection jitters or briefly drops.

## Runtime Inputs

Marker detection provides:

- `marker_center_x`
- `marker_center_y`
- `rotation`
- `scale`
- `distance_estimate`
- `tracking_confidence`
- `timestamp`

Detection is raw evidence only. It is not allowed to directly drive the boss after stable lock.

## Stable Lock

Lock starts when a marker candidate is detected above minimum confidence.

Lock confirms only when all conditions are true:

- Confidence remains at or above `0.72`.
- Pose movement remains under jitter tolerance.
- Candidate is visible for at least `300 ms`.
- At least `8` usable samples exist in the lock window.

On confirmation:

- Create persistent `anchor_id`.
- Store anchor memory.
- Emit `lock_confirmed`.
- UI may show `TARGET LOCKED`.
- Boss spawn may begin.

## Anchor Memory

Anchor memory stores:

- `anchor_id`
- `x`
- `y`
- `rotation`
- `scale`
- `velocity_x`
- `velocity_y`
- `angular_velocity`
- `last_stable_position`
- `last_stable_rotation`
- `last_stable_scale`
- `last_seen_timestamp`
- `loss_started_timestamp`
- `hit_ignore_until_timestamp`

The boss, portal, HP, damage numbers, and combat effects attach to `anchor_id`.

## Loss States

### `TRACKING_MEMORY`

Duration:

- `0-1.5 s` since marker loss.

Behavior:

- Keep boss visible.
- Keep HP visible.
- Keep battle active.
- Predict anchor from last velocity with damping.
- Emit `lock_lost` once when entering this state.
- Status text: `LOCK STABLE`.

### `SIGNAL_UNSTABLE`

Duration:

- `1.5-5 s` since marker loss.

Behavior:

- Keep boss visible.
- Keep HP visible.
- Keep combat state and HP unchanged.
- Continue damped anchor prediction.
- Allow small glitch, static, or portal flicker effects.
- Status text: `SIGNAL UNSTABLE`.

### `LOST`

Duration:

- `5 s+` since marker loss.

Behavior:

- Keep boss instance alive.
- Keep HP value.
- Pause hit acceptance and battle timers.
- Do not hide the boss instantly.
- Do not reset combat.
- Status text: `SHOW MARKER AGAIN`.

## Relock

When a marker candidate returns from `SIGNAL_UNSTABLE` or `LOST`:

1. Enter `RELOCK`.
2. Compare marker pose with anchor memory.
3. Reject impossible jumps.
4. Smooth anchor toward returned marker pose over `250-400 ms`.
5. Preserve boss instance and HP.
6. Emit `lock_restored`.
7. Enter `RESTORED`.
8. Ignore hit detection for `400 ms`.
9. Return to `LOCKED`.

Relock movement is never a hit input.

## Hit Gate

The tracking engine exposes:

- `can_accept_hit`
- `hit_ignore_until_timestamp`
- `tracking_state`
- `anchor_id`

Hit detection must reject input when:

- `tracking_state` is `RELOCK`.
- `tracking_state` is `RESTORED` and the 400 ms ignore window is still active.
- `tracking_state` is `LOST`.
- Anchor correction exceeds jump tolerance.

## Prototype State Reducer

```text
if state == SEARCH and marker.valid:
  emit marker_detected
  state = LOCKING
  start lock window

if state == LOCKING:
  add sample
  if marker missing:
    reset to SEARCH
  if confidence stable and pose stable for 300 ms:
    create anchor memory
    emit lock_confirmed
    state = LOCKED

if state == LOCKED:
  if marker.valid:
    update anchor memory with smoothed marker pose
  else:
    loss_started = now
    emit lock_lost status LOCK STABLE
    state = TRACKING_MEMORY

if state == TRACKING_MEMORY:
  predict anchor with damped velocity
  if marker.valid:
    state = RELOCK
  if loss_duration >= 1.5 s:
    emit lock_lost status SIGNAL UNSTABLE
    state = SIGNAL_UNSTABLE

if state == SIGNAL_UNSTABLE:
  predict anchor with stronger damping
  if marker.valid:
    state = RELOCK
  if loss_duration >= 5 s:
    emit lock_lost status SHOW MARKER AGAIN
    state = LOST

if state == LOST:
  keep boss instance and HP
  pause hit acceptance
  if marker.valid:
    state = RELOCK

if state == RELOCK:
  reconcile returned marker with anchor memory
  if restore complete:
    hit_ignore_until = now + 400 ms
    emit lock_restored status TARGET RESTORED
    state = RESTORED

if state == RESTORED:
  if now >= hit_ignore_until:
    state = LOCKED
```

## Acceptance Tests

- Marker detection emits `marker_detected`.
- Stable evidence emits exactly one `lock_confirmed` per battle lock.
- Boss remains visible in `TRACKING_MEMORY`.
- Boss remains visible in `SIGNAL_UNSTABLE`.
- `LOST` pauses battle but keeps boss, HP, anchor memory, and combat state.
- Relock preserves HP.
- Relock does not respawn boss.
- Relock sets a 400 ms hit ignore window.
- Sudden relock pose correction cannot create damage.
- Portal is opened by the first confirmed lock only.
