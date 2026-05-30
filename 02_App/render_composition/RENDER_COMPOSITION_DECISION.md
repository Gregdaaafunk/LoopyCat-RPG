# Render And Composition Decision

Project title: LoopyCat RPG AR

## Critical Requirement

REC and PHOTO must capture composed output.

Raw camera-only recording is invalid.

Captured output must include:

- Camera feed
- Boss
- Portal
- HP
- Damage numbers
- Combo text
- KO
- Loot animation
- UI overlays

## Foundation Decision

Use one composed render output as the truth.

The same composed frame feeds:

- On-screen display
- PHOTO capture
- REC capture

Do not build gameplay on separate UI layers that recording cannot capture.

## Composition Layers

Render order:

1. Live camera feed.
2. Marker anchor / toy-space content.
3. Portal.
4. Boss.
5. Hit effects.
6. Damage numbers.
7. Combo text.
8. HP and combat HUD.
9. KO animation.
10. Loot animation.
11. Reward UI overlays.
12. Debug overlay when enabled.

## Capture Architecture

PHOTO:

- Capture current composed frame.
- Save locally to Photos.

REC:

- Encode frames from composed output.
- Include intended UI overlays.
- Emit `recording_started`.
- Emit `recording_finished` on success.
- Emit `recording_failed` on failure.

## Forbidden Architecture

Do not:

- Record camera feed only.
- Draw boss in a layer unavailable to capture.
- Draw UI in a native overlay that cannot enter recording.
- Let REC and screen output diverge.

## Implementation Choice

The exact native API can be selected when platform code begins, but the capture architecture is no longer open.

Chosen MVP path:

- Single composed render output.
- Camera frame is drawn into the composition.
- Portal, boss, combat effects, HP, KO, loot, and UI overlays are drawn into the same final frame.
- PHOTO reads the final composed frame.
- REC encodes final composed frames.
- Saves go to local Photos from composed output only.

Allowed implementation details:

- Single game/AR render surface with internal UI overlay.
- Native camera texture composed into render target.
- Recorder reads the final render target.

Rejected implementation path:

- Native camera recording plus separate AR/UI overlays.

## Sprint Decision

For Tracking, Boss Spawn, and Recording Architecture sprints:

- Treat the final composed render target as the only valid capture source.
- Draw camera feed, AR content, boss, portal, HP, damage numbers, combo text, KO, loot animation, and UI overlays into that composed target.
- PHOTO copies the composed target.
- REC encodes frames from the composed target.

This is the selected architecture until a platform-specific implementation replaces the contract.

## Debug Requirements

Debug harness must show:

- Composition active
- PHOTO capture readiness
- REC capture readiness
- Recording state
- Last recording error
- Output includes overlay flag
