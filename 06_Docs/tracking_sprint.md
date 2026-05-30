# Tracking Sprint

Project title: LoopyCat RPG AR

Internal title: Loopy TV RPG

## Goal

Marker opens portal once.

Boss stays attached to toy.

Tracking loss must not break the magic.

## Implementation Scope

Implement stable target tracking.

Required systems:

- Marker detection
- Stable lock
- Anchor memory
- Relock
- Signal unstable state
- Lost state
- Boss does not disappear instantly
- No HP reset after relock
- No hit from relock jump

## Runtime Note

This project currently has no runnable app runtime.

This sprint defines the implementation contract and state behavior that the future runtime must implement.

Primary module contract:

`02_App/tracking_engine/TRACKING_ENGINE.md`

Implementation notes:

`02_App/tracking_engine/TRACKING_ENGINE_IMPLEMENTATION.md`

## Tracking Flow

```text
SEARCH
-> marker detected
-> LOCKING
-> stable lock confirmed
-> LOCKED
-> create persistent anchor
-> portal / boss attach to anchor
```

After `LOCKED`:

- Marker detection updates anchor memory.
- Boss position comes from persistent anchor, not raw marker pose.
- Marker loss changes tracking status only.
- Marker loss does not destroy boss.
- Marker loss does not reset HP.

## State Machine

```text
SEARCH
-> LOCKING
-> LOCKED
-> TRACKING_MEMORY
-> SIGNAL_UNSTABLE
-> RELOCK
-> RESTORED
-> LOCKED
```

Long loss:

```text
SIGNAL_UNSTABLE
-> LOST
-> RELOCK
-> RESTORED
-> LOCKED
```

## State Rules

### SEARCH

No marker candidate.

Behavior:

- Do not spawn boss.
- Show marker search UI.

### LOCKING

Marker candidate is visible.

Behavior:

- Accumulate stable samples.
- Emit `marker_detected`.
- Emit `lock_started`.
- Do not spawn boss yet.

### LOCKED

Stable lock confirmed.

Behavior:

- Create persistent anchor.
- Freeze boss attachment to anchor.
- Emit `lock_confirmed`.
- Allow portal spawn.

### TRACKING_MEMORY

Short loss: 0-1.5 seconds.

Behavior:

- Boss visible.
- HP visible.
- Fight continues.
- Status: `LOCK STABLE`.
- Predict from last known anchor memory.

### SIGNAL_UNSTABLE

Medium loss: 1.5-5 seconds.

Behavior:

- Boss visible.
- HP visible.
- Slight glitch effect allowed.
- Status: `SIGNAL UNSTABLE`.
- Hit detection should be restricted.

### LOST

Long loss: 5+ seconds.

Behavior:

- Show `SHOW MARKER AGAIN`.
- Pause battle.
- Keep boss instance.
- Keep HP.
- Keep combat state.
- Do not despawn boss.

### RELOCK

Marker candidate returns.

Behavior:

- Compare candidate marker pose to anchor memory.
- Smoothly reconcile anchor.
- Do not snap instantly.
- Do not reset boss.
- Do not reset HP.

### RESTORED

Relock succeeded.

Behavior:

- Show `TARGET RESTORED`.
- Ignore hits for 400 ms.
- Return to `LOCKED`.

## Anchor Memory Model

Store:

- `anchor_id`
- `x`
- `y`
- `rotation`
- `scale`
- `velocity_x`
- `velocity_y`
- `angular_velocity`
- `scale_velocity`
- `last_stable_position`
- `last_stable_rotation`
- `last_stable_scale`
- `last_seen_timestamp`
- `loss_duration`
- `tracking_confidence`

## Smoothing And Prediction

Use:

- Smoothed position.
- Smoothed rotation.
- Smoothed scale.
- Last velocity.
- Decay over time.

Rules:

- Small jitter is ignored.
- Large single-frame jumps are treated as suspicious.
- Relock correction is eased over time.
- Prediction decays during marker loss.

## Relock Protection

After `lock_restored`:

- Set `hit_ignore_ms` to 400.
- Disable hit detection.
- Disable combo update.
- Disable critical detection.
- Never calculate hits from anchor correction.

## Boss And HP Preservation

During `TRACKING_MEMORY`, `SIGNAL_UNSTABLE`, `RELOCK`, `RESTORED`, and `LOST`:

- Boss instance remains alive.
- Boss HP remains unchanged unless a valid hit occurs.
- Combat state remains stored.
- UI HP bar remains visible except if battle is explicitly paused in `LOST`.

## Events

Emitted by `tracking_engine`:

- `marker_detected`
- `lock_started`
- `lock_confirmed`
- `lock_lost`
- `lock_restored`

Tracking Engine does not emit:

- `boss_hit`
- `boss_defeated`
- `boss_spawned`

## Debug Harness Fields

Show:

- `tracking_state`
- `anchor_id`
- Marker center
- Rotation
- Scale
- Distance estimate
- Tracking confidence
- Loss duration
- Last velocity
- Relock smoothing progress
- Hit ignore remaining
- Boss attached flag

## Failure Cases

### Camera Moves Slightly

Expected:

- Boss stays on anchor.
- Tracking may enter memory state.
- Boss does not disappear.

### Marker Briefly Lost

Expected:

- `TRACKING_MEMORY`.
- Boss visible.
- HP visible.
- No reset.

### Marker Lost For 5+ Seconds

Expected:

- `LOST`.
- Prompt marker return.
- Pause battle.
- Keep boss and HP.

### Marker Returns

Expected:

- `RELOCK`.
- Smooth anchor correction.
- `RESTORED`.
- 400 ms hit ignore.
- Return to `LOCKED`.

## Acceptance Criteria

Tracking Sprint is ready when:

- Stable lock creates persistent anchor.
- Marker loss does not despawn boss.
- Short loss keeps full battle visible.
- Medium loss shows unstable signal but keeps boss.
- Long loss pauses without reset.
- Relock restores smoothly.
- HP does not reset after relock.
- Hits are ignored during relock correction.
