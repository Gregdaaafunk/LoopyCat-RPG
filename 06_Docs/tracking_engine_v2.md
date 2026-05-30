# Tracking Engine V2

Project title: LoopyCat RPG

Internal title: Loopy TV RPG

## Goal

Marker opens portal.

Boss stays alive even if tracking briefly disappears.

## Current Wrong Behavior

```text
Marker detected
-> boss appears
-> marker lost
-> boss disappears
```

This is wrong.

## Required Behavior

Use a persistent anchor system.

Marker is for acquisition, not for keeping the boss alive every frame.

After stable lock:

- Boss lives on anchor.
- Boss remains visible during short and medium marker loss.
- Boss state is preserved during long loss.
- HP is not reset.
- Fight is not restarted.
- Boss is not respawned.

## Layer 1: Marker Capture

Needs:

- Marker detection
- Confidence score
- Stable confirmation

Output:

- `marker_detected`
- `lock_started`
- `lock_confirmed`

Lock is confirmed only after marker evidence is stable.

## Layer 2: Anchor Memory

Store:

- `x`
- `y`
- `rotation`
- `scale`
- `velocity`
- `last_stable_position`

Boss lives on anchor.

The anchor remains valid after marker loss.

Anchor memory owns boss stability after lock.

## Layer 3: Hold System

### Short Loss: 0-1.5 seconds

Status:

- `LOCK STABLE`

Behavior:

- Keep full battle.
- Boss visible.
- HP visible.
- No reset.
- No fight pause.
- No boss hide.

### Medium Loss: 1.5-5 seconds

Status:

- `SIGNAL UNSTABLE`

Behavior:

- Show signal unstable.
- Small glitch effects allowed.
- Keep boss.
- Keep HP.
- Keep fight state.
- Continue anchor memory prediction.

### Long Loss: 5+ seconds

Status:

- `SHOW MARKER AGAIN`

Behavior:

- Request marker return.
- Pause battle.
- Keep state.
- Keep boss instance.
- Do not instantly disappear.
- Do not reset HP.

## Layer 4: Relock

When marker returns:

1. Enter `RELOCK`.
2. Compare marker candidate to anchor memory.
3. Smooth restore.
4. No jump.
5. No HP reset.
6. No boss reset.
7. No fight restart.
8. Show `TARGET RESTORED`.
9. Enter `RESTORED`.
10. Ignore hit detection for 400ms.
11. Return to `LOCKED`.

Never calculate hits from relock movement.

## Required States

Tracking Engine V2 states:

- `SEARCH`
- `LOCKING`
- `LOCKED`
- `TRACKING_MEMORY`
- `SIGNAL_UNSTABLE`
- `RELOCK`
- `RESTORED`
- `LOST`

## State Meaning

### SEARCH

No marker has been acquired.

### LOCKING

Marker candidate is visible and confidence is being stabilized.

### LOCKED

Stable lock is confirmed. Persistent anchor has been created.

### TRACKING_MEMORY

Marker is briefly missing and short loss hold is active.

Boss remains fully visible.

### SIGNAL_UNSTABLE

Marker has been missing for medium duration.

Boss remains visible with optional glitch effects.

### RELOCK

Marker candidate has returned and is being reconciled with anchor memory.

### RESTORED

Relock succeeded.

Show:

- `TARGET RESTORED`

Ignore hit detection for 400ms.

### LOST

Marker has been missing for long duration.

Show:

- `SHOW MARKER AGAIN`

Pause battle but keep state.

## State Transitions

```text
SEARCH -> LOCKING
  on marker candidate detected

LOCKING -> LOCKED
  on stable confirmation

LOCKED -> TRACKING_MEMORY
  on marker missing for 0-1.5 seconds

TRACKING_MEMORY -> LOCKED
  if marker returns quickly and pose is stable

TRACKING_MEMORY -> SIGNAL_UNSTABLE
  if marker missing passes 1.5 seconds

SIGNAL_UNSTABLE -> RELOCK
  when marker candidate returns

SIGNAL_UNSTABLE -> LOST
  if marker missing passes 5 seconds

LOST -> RELOCK
  when marker candidate returns

RELOCK -> RESTORED
  when smooth anchor restore succeeds

RESTORED -> LOCKED
  after 400ms hit-ignore window
```

## Forbidden Behavior

Do not:

- Remove boss on short loss.
- Remove boss on medium loss.
- Instantly remove boss on long loss.
- Reset HP on marker loss.
- Hide HP on marker loss.
- Reset fight on marker loss.
- Restart boss on relock.
- Respawn boss on relock.
- Calculate hits from relock jump.
- Drive boss directly from noisy frame-by-frame marker detection after lock.

## Implementation Priority

The user must feel that the toy opened a portal and the boss stays there.

Tracking loss should degrade gracefully instead of breaking the battle.
