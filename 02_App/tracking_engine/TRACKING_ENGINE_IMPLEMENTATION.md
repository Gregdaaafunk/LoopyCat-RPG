# Tracking Engine Implementation Contract

Project title: LoopyCat RPG AR

## Purpose

Implement stable target tracking for the first playable battle loop.

## Main Rule

Marker detection is for acquisition.

Persistent anchor is battle truth.

Boss must not be parented directly to noisy frame-by-frame marker detection after lock.

## Inputs

- Camera frame
- Canonical marker image
- Marker candidate pose
- Marker confidence
- Timestamp

## Outputs

- `marker_detected`
- `lock_started`
- `lock_confirmed`
- `lock_lost`
- `lock_restored`
- Anchor memory
- Tracking state
- Hit ignore window after relock

## Core Algorithm

```text
if state == SEARCH:
  detect marker candidate
  if candidate confidence passes threshold:
    emit marker_detected
    enter LOCKING

if state == LOCKING:
  collect stable samples
  if samples are stable:
    create anchor memory
    emit lock_confirmed
    enter LOCKED

if state == LOCKED:
  update anchor memory from stable marker samples
  if marker missing:
    enter TRACKING_MEMORY

if state == TRACKING_MEMORY:
  keep boss visible
  predict anchor from memory
  if marker returns:
    enter RELOCK
  if loss > 1.5s:
    enter SIGNAL_UNSTABLE

if state == SIGNAL_UNSTABLE:
  keep boss visible
  continue decayed prediction
  if marker returns:
    enter RELOCK
  if loss > 5s:
    enter LOST

if state == LOST:
  keep boss and HP stored
  pause battle
  if marker returns:
    enter RELOCK

if state == RELOCK:
  reconcile candidate marker with anchor memory
  smooth correction
  emit lock_restored
  start 400ms hit ignore
  enter RESTORED

if state == RESTORED:
  wait until hit ignore ends
  enter LOCKED
```

## Forbidden

- Do not remove boss on marker loss.
- Do not reset HP on marker loss.
- Do not restart boss on relock.
- Do not emit hit from relock jump.
- Do not hide HP during short or medium loss.
