# Hit Detection Sprint Plan

Project title: LoopyCat RPG AR

Internal title: Loopy TV RPG

## Goal

Design hit detection logic before implementation.

Do not implement yet.

The goal is:

Make hits feel responsive but not random.

## Core Question

How does the app know the cat hit the toy?

Answer:

The app watches the locked marker / toy anchor for short, sharp, local motion impulses that look different from normal camera movement, marker jitter, relock correction, or tracking noise.

A hit is not one signal.

A hit is a scored event built from several signals:

- Marker movement
- Marker speed
- Marker acceleration
- Marker occlusion
- Camera shake
- Sudden position jump
- Confidence drop
- Relock event

## High-Level Pipeline

```text
tracking samples
-> smooth marker pose
-> estimate marker motion
-> reject camera/global motion
-> reject relock and jitter
-> score hit candidate
-> assign hit tier
-> emit hit outputs
```

## Input Signals

### Marker Movement

Use marker center movement over time:

- `delta_x`
- `delta_y`
- movement distance
- direction
- duration

Purpose:

- Detect physical toy displacement caused by cat impact.

### Marker Speed

Use movement distance per second.

Purpose:

- Separate normal slow camera drift from quick impact motion.

### Marker Acceleration

Use speed change per second.

Purpose:

- Detect sudden impulse.

Hits should have a fast acceleration spike.

### Marker Occlusion

Use partial or brief marker visibility loss.

Purpose:

- A paw may cover the marker briefly during impact.

Important:

- Occlusion alone is not a hit.
- Occlusion can increase confidence only when paired with motion impulse.

### Camera Shake

Use global frame motion, device motion if available, or background motion estimate.

Purpose:

- Reject hits caused by the phone moving.

Rule:

- If whole frame moves with marker, treat as camera shake, not toy hit.

### Sudden Position Jump

Detect large one-frame pose jumps.

Purpose:

- Separate real impact from tracking glitch.

Rule:

- Sudden jump with unstable confidence is rejected.
- Sudden jump with stable pre/post confidence and local motion can be candidate hit.

### Confidence Drop

Use tracking confidence changes.

Purpose:

- Detect possible paw occlusion or blur during hit.

Rule:

- Confidence drop supports a hit only if motion and timing also match impact.
- Confidence drop during relock or marker loss is not a hit.

### Relock Event

Use `lock_restored`.

Purpose:

- Prevent relock correction from being counted as a hit.

Rule:

- Ignore hit detection for 400 ms after relock.

## Motion Features

For each frame sample store:

- `timestamp`
- `marker_center_x`
- `marker_center_y`
- `rotation`
- `scale`
- `tracking_confidence`
- `tracking_state`
- `anchor_id`

Derived values:

- `position_delta`
- `rotation_delta`
- `scale_delta`
- `speed`
- `acceleration`
- `confidence_delta`
- `occlusion_duration`
- `global_camera_motion`
- `local_motion_score`

## Hit Candidate Rules

A hit candidate starts when:

- `tracking_state` is `LOCKED` or `TRACKING_MEMORY`
- marker motion exceeds jitter threshold
- acceleration exceeds impulse threshold
- confidence is above minimum threshold before the impulse
- not inside cooldown
- not inside relock ignore window

A hit candidate strengthens when:

- marker moves quickly and returns or settles
- acceleration spike is short
- confidence dips briefly and recovers
- rotation or scale changes briefly
- global camera motion is low

A hit candidate is rejected when:

- global camera motion is high
- relock just happened
- movement is below jitter threshold
- confidence is too low for too long
- marker is in `RELOCK`, `RESTORED`, or `LOST`
- cooldown is active
- motion is slow drift rather than impact

## Anti-False-Hit Rules

### Ignore Camera Shake

If marker motion matches whole-frame motion, reject hit.

Examples:

- User moves phone left.
- User steps forward.
- Camera tilts.

Implementation idea:

- Compare marker motion against background/global optical motion.
- If both move in same direction and similar magnitude, classify as camera movement.

### Ignore Relock Jumps

After `lock_restored`:

- Ignore hit detection for 400 ms.
- Do not calculate hits from anchor correction.
- Do not allow combo update during ignore window.

### Ignore Tiny Marker Jitter

Use deadzone thresholds:

- Small center movement is ignored.
- Small rotation movement is ignored.
- Small scale movement is ignored.

Purpose:

- Prevent constant micro-hits from tracking noise.

### Cooldown

After accepted hit:

- Start hit cooldown.
- Ignore new hits until cooldown ends.

Suggested v1 cooldown:

- LIGHT: 250 ms
- NORMAL: 300 ms
- HEAVY: 400 ms
- CRITICAL: 500 ms

### Confidence Threshold

Require stable confidence before accepting a hit.

Suggested v1 thresholds:

- Minimum pre-hit confidence: 0.60
- Minimum post-hit recovery confidence: 0.45
- Reject if confidence loss lasts longer than occlusion window.

### Motion Smoothing

Use smoothing before hit scoring:

- Smooth marker center.
- Smooth rotation.
- Smooth scale.
- Smooth confidence.

But:

- Preserve short acceleration spikes.
- Do not over-smooth impact impulses.

## Hit Score

Hit score is built from weighted signals.

```text
hit_score =
  local_motion_score
  + acceleration_score
  + speed_score
  + brief_occlusion_bonus
  + rotation_impulse_bonus
  + scale_impulse_bonus
  - camera_shake_penalty
  - jitter_penalty
  - low_confidence_penalty
  - relock_penalty
```

Candidate hit requires:

- `hit_score` above minimum
- anti-false-hit rules pass
- cooldown inactive

## Hit Tiers

### LIGHT

Meaning:

- Small but valid toy impact.

Typical signal:

- Low motion impulse
- Stable confidence
- No major occlusion

Outputs:

- Lower damage
- Combo allowed
- Critical not allowed by default

### NORMAL

Meaning:

- Clear toy impact.

Typical signal:

- Medium speed
- Medium acceleration
- Short impact duration

Outputs:

- Standard damage
- Combo allowed
- Critical allowed

### HEAVY

Meaning:

- Strong toy impact.

Typical signal:

- High acceleration
- Larger local displacement
- Brief confidence drop or rotation impulse

Outputs:

- High damage
- Combo allowed
- Critical allowed

### CRITICAL

Meaning:

- Strong valid hit plus critical roll or rare high-confidence impact.

Typical signal:

- Heavy motion score
- Good confidence recovery
- Not camera shake
- Not relock

Outputs:

- Critical damage
- Combo allowed
- Critical effects allowed

## Output Fields

Hit detection outputs:

- `hit_confidence`
- `hit_power`
- `damage_value`
- `combo_allowed`
- `critical_allowed`

### hit_confidence

Range:

- 0.0 to 1.0

Meaning:

- Confidence that this was a real cat/toy hit, not camera movement or tracking noise.

### hit_power

Allowed values:

- `LIGHT`
- `NORMAL`
- `HEAVY`
- `CRITICAL`

Meaning:

- Tiered impact strength.

### damage_value

Meaning:

- Damage sent to `combat_engine`.

V1 recommendation:

- `LIGHT`: 5
- `NORMAL`: 10
- `HEAVY`: 18
- `CRITICAL`: 30

These values are tuning placeholders only.

### combo_allowed

Boolean.

False when:

- hit is rejected
- cooldown active
- relock ignore window active
- confidence too low
- battle paused

### critical_allowed

Boolean.

False when:

- hit tier is `LIGHT`
- confidence is below critical threshold
- relock ignore window active
- camera shake rejection triggered

## State Rules

Hit detection allowed during:

- `LOCKED`
- `TRACKING_MEMORY`

Hit detection restricted during:

- `SIGNAL_UNSTABLE`

Hit detection disabled during:

- `SEARCH`
- `LOCKING`
- `RELOCK`
- `RESTORED`
- `LOST`

After `RESTORED`:

- Ignore hits for 400 ms.

## Event Integration

Hit Detection does not emit raw tracking events.

It feeds `combat_engine`.

When accepted:

```text
combat_engine emits boss_hit
combat_engine may emit combo_updated
combat_engine may emit critical_hit
boss_engine may emit boss_phase_change
combat_engine may emit boss_defeated
```

When rejected:

- No combat event is emitted.
- Debug Harness may show rejection reason.

## Debug Harness Fields

Show:

- Current hit candidate score
- Last accepted hit tier
- Last rejected hit reason
- Hit cooldown remaining
- Relock ignore remaining
- Marker speed
- Marker acceleration
- Global camera motion
- Tracking confidence
- Occlusion duration

Rejection reasons:

- `camera_shake`
- `relock_ignore`
- `jitter`
- `cooldown`
- `low_confidence`
- `tracking_state_invalid`
- `slow_drift`
- `long_occlusion`

## Fail Cases

### Camera Moves Suddenly

Expected behavior:

- Reject as camera shake if global frame motion is high.

### Marker Briefly Disappears

Expected behavior:

- Do not count disappearance alone as hit.
- Keep boss alive through tracking memory.

### Marker Relocks

Expected behavior:

- Ignore hits for 400 ms.
- Do not combo.
- Do not damage.

### Cat Paw Covers Marker

Expected behavior:

- If brief occlusion plus local impulse, accept hit.
- If long occlusion without stable motion, reject and keep battle state.

### Toy Slowly Slides

Expected behavior:

- Reject slow drift.
- Only sharp impulse can become hit.

## First Prototype Plan

Step 1:

- Add debug-only hit signal from marker motion.
- No final damage balancing.

Step 2:

- Add camera-shake rejection.

Step 3:

- Add relock ignore window.

Step 4:

- Add cooldown and jitter deadzone.

Step 5:

- Add hit tiers.

Step 6:

- Add combo and critical permission outputs.

## Definition Of Done

Hit Detection Sprint Plan is ready when:

- Inputs are defined.
- Anti-false-hit rules are defined.
- Hit tiers are defined.
- Outputs are defined.
- State gating is defined.
- Relock jump protection is defined.
- Debug fields are defined.
- No implementation has been added yet.
