# Phase 1 Specification: Battle Prototype

Project title: LoopyCat RPG

Internal title: Loopy TV RPG

## Scope

Phase 1 is only the AR battle prototype.

Build:

- Toy detection
- Canonical marker lock
- Stable boss anchor
- Real battle loop
- Video recording with boss visible

Do not build:

- Inventory
- Cat avatars
- Full RPG systems
- Marker redesigns
- Alternate markers

## Canonical Marker

Use only the attached marker image:

`03_AR/canonical_marker.jpg`

This marker is canonical.

Do not:

- Generate alternatives
- Replace it
- Redesign it
- Modify its visual design
- Train against another marker unless explicitly approved later

## Toy Face Dimensions

Toy face dimensions:

- Width: 8 cm
- Height: 7 cm

These are toy dimensions, not marker dimensions.

The marker is placed at the center of the toy face.

## Tracking Priority

The primary technical requirement is extremely stable detection.

If the marker is detected:

1. Create a world anchor.
2. Freeze the anchor position.
3. Show `TARGET LOCKED`.
4. Open the portal from the marker center.
5. Spawn the boss from that portal.
6. Keep the boss attached to toy space.

Phone movement must not move the boss relative to the toy.

The camera may move freely. The boss must remain on the toy.

## Portal Spawn

When marker detection is confirmed and the target enters `LOCKED`, the prototype must create a portal from the marker anchor.

Portal rules:

- The portal is born from the marker center.
- The portal uses the same frozen world anchor as the boss.
- The portal must stay attached to marker space.
- Boss emergence must use the same anchor point.
- Phone movement must not detach the portal or boss from the toy.

Required sequence:

1. Lock confirmed.
2. Create anchor at marker position.
3. Show `TARGET LOCKED`.
4. Portal ring opens from marker center.
5. Vortex spins.
6. Monster rises out.
7. Screen flash.
8. Boss name card appears.
9. HP bar appears.
10. Fight starts.

No simple fade-in.

The user should feel that the toy opened a portal and summoned a boss.

## Lock State Machine

Tracking must use a strong lock system:

- `SEARCH`
- `LOCKING`
- `LOCKED`
- `TRACKING_MEMORY`
- `SIGNAL_UNSTABLE`
- `RELOCK`
- `RESTORED`
- `LOST`

### SEARCH

No reliable marker target is active.

Behavior:

- Scan for the canonical marker.
- Reject weak detections.
- Output low confidence until marker evidence is stable enough to enter `LOCKING`.

### LOCKING

Candidate marker is visible, but not trusted yet.

Behavior:

- Accumulate stable frames.
- Estimate marker center, rotation, distance, and confidence.
- Smooth pose before committing.
- Enter `LOCKED` only after confidence and pose stability pass thresholds.

### LOCKED

Marker has been accepted and the boss anchor is active.

Behavior:

- Create the world anchor once.
- Freeze anchor position.
- Spawn boss once.
- Keep boss attached to toy space.
- Do not reset boss while marker tracking is healthy.

### TRACKING_MEMORY

Marker has briefly disappeared after a confirmed lock.

Behavior:

- Keep previous anchor.
- Keep boss visible at the last stable toy-space anchor.
- Show `LOCK STABLE`.
- Do not flicker.
- Do not jump.
- Do not reset boss HP.
- Do not respawn boss.
- Use last known position, size, rotation, velocity, and decay.

Duration:

- 0-1.5 seconds.

### SIGNAL_UNSTABLE

Marker has been missing for medium duration.

Behavior:

- Keep boss visible.
- Keep HP visible.
- Show `SIGNAL UNSTABLE`.
- Add slight glitch effect.
- Do not reset HP.
- Do not restart boss.

Duration:

- 1.5-5 seconds.

### LOST

Marker has been missing for long duration.

Behavior:

- Show `SHOW MARKER AGAIN`.
- Pause boss.
- Do not instantly disappear.
- Do not reset fight.
- Do not hide HP.

Duration:

- 5+ seconds.

### RELOCK

Marker has reappeared after memory or unstable tracking.

Behavior:

- Aggressively reacquire the canonical marker.
- Compare new pose against the previous anchor.
- Smoothly snap anchor back only when pose is credible.
- Avoid visible jumps.
- Do not reset HP.
- Do not restart boss.
- Never calculate hits from relock jump.

### RESTORED

Re-lock succeeded.

Behavior:

- Show `TARGET RESTORED`.
- Ignore hit detection for 400ms.
- Return to `LOCKED`.

## Required Tracking Outputs

The prototype must expose these outputs every frame:

- Marker center X
- Marker center Y
- Rotation
- Distance estimate
- Tracking confidence
- Hit confidence

## Anchor Rules

Anchor behavior is more important than raw detection frequency.

Rules:

- The first reliable `LOCKED` pose creates the anchor.
- The anchor remains valid through marker loss grace periods.
- Marker loss must not reset the boss.
- Reacquired marker pose must be filtered against the frozen anchor.
- Boss position must not be driven directly by noisy frame-by-frame detection.
- Boss must not disappear from slight camera movement.
- HP must not hide during marker memory states.
- Re-lock must ignore hit detection for 400ms.

## Combat Flow

Prototype flow:

1. Detect marker.
2. Lock target.
3. Create anchor.
4. Show `TARGET LOCKED`.
5. Open portal from marker center.
6. Boss emerges from portal.
7. Cat hits toy.
8. Reduce boss HP.
9. Defeat boss.
10. Drop loot.

Loot exists only as a battle result in Phase 1. Do not build inventory.

## Hit Detection

Hit detection must be tied to toy interaction and marker confidence.

Required output:

- Hit confidence

Hit confidence should consider:

- Marker lock state
- Camera movement
- Toy-space impact motion
- Recent tracking stability
- Whether boss is currently targetable

Hits should not reset tracking or boss state.

## Boss Behavior

Phase 1 needs one prototype boss.

Requirements:

- Spawn from the locked toy anchor through the portal sequence.
- Stay attached to toy space.
- Display HP.
- React to hits.
- Play defeat state.
- Trigger loot drop on defeat.

Do not build the full 10-boss system in Phase 1.

## Recording

Saved video must include:

- Boss
- Damage
- Effects
- UI

The recording must show the actual battle result, with the boss visible and attached to the toy.

## Success Criteria

Phase 1 succeeds when:

- The toy is detected.
- The canonical marker locks reliably.
- The boss remains stable on the toy.
- Phone movement does not drag the boss away from the toy.
- Temporary marker loss does not flicker, jump, reset, or despawn the boss.
- The player can complete a simple battle.
- A saved video shows boss, damage, effects, and UI.
