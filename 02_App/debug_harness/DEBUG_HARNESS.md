# Debug Harness

Project title: LoopyCat RPG AR

Purpose:

- Provide one internal debug screen.
- Show foundation state before gameplay expansion.
- Help validate tracking, events, assets, recording, and performance.

## Foundation Rule

Debug Harness is internal.

It does not own gameplay state.

It observes engines and event bus.

## Required Panels

Debug screen shows:

- Current state
- Event log
- Tracking state
- Boss state
- Combat state
- Recording state
- Loaded assets
- FPS
- Errors

## Current State Panel

Shows:

- App mode
- Battle id
- Active cat id
- Active boss id
- Current screen
- Current foundation sprint lock

## Event Log Panel

Shows:

- Last 50 events
- Event owner
- Timestamp
- Payload summary
- Error state

## Tracking Panel

Shows:

- `tracking_state`
- Marker confidence
- Anchor id
- Last known position
- Last known rotation
- Last known scale
- Anchor velocity
- Loss duration
- Relock status
- Hit ignore remaining

## Boss And Combat Panel

Shows:

- Boss id
- Boss state
- Boss animation state
- Combat state
- Current HP
- Combo count
- Last hit confidence
- Last critical state

## Recording Panel

Shows:

- Recording state
- PHOTO readiness
- REC readiness
- Composed output active
- Last mode
- Saved to Photos
- Is composed output
- Last media id
- Last export result
- Last recording error

## Asset Panel

Shows:

- Loaded marker
- Loaded boss assets
- Loaded loot assets
- Loaded cat photo
- Loaded UI assets
- Estimated texture count
- Missing assets

## Performance Panel

Shows:

- FPS
- Frame time
- Dropped frame count
- Estimated memory
- Thermal warning placeholder
- Battery warning placeholder

## Error Panel

Shows:

- Last error
- Error source
- Recoverable flag
- Suggested next action
