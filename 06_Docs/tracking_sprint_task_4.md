# Task 4: Tracking Sprint

## Goal

Marker opens portal once, and the boss stays attached to the toy.

## Implemented Contract

Primary contract:

`02_App/tracking_engine/TRACKING_ENGINE.md`

Supporting contract:

`06_Docs/tracking_engine_v2.md`

## Decisions

- Marker detection is acquisition evidence.
- Stable lock creates a persistent anchor.
- Boss, portal, HP, and effects attach to the anchor.
- Marker loss degrades through `TRACKING_MEMORY`, `SIGNAL_UNSTABLE`, and `LOST`.
- Relock reconciles the marker to anchor memory.
- Relock creates a 400 ms hit ignore window.

## Done

- Marker detection defined.
- Stable lock thresholds defined.
- Anchor memory defined.
- Relock rules defined.
- Signal unstable state defined.
- Lost state defined.
- Boss persistence rules defined.
- HP preservation rule defined.
- Relock jump hit rejection defined.

## Acceptance

The sprint is accepted when the implementation can prove:

- One confirmed marker lock opens one portal.
- Boss does not disappear instantly on marker loss.
- Boss HP does not reset on relock.
- Relock movement cannot count as a hit.
- Debug harness exposes tracking state, anchor id, loss duration, and relock status.
