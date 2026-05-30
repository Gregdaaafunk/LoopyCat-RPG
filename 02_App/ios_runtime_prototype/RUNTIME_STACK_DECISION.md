# Runtime Stack Decision

Project title: LoopyCat RPG AR

## Recommended Stack

Use Swift native iOS-first.

Recommended path:

```text
Swift / SwiftUI shell
-> AVFoundation camera prototype
-> ARKit marker tracking sprint
-> native composed render pipeline
-> PhotoKit / AVAssetWriter capture
-> TestFlight
```

## Comparison

### A. React Native + VisionCamera + Skia

Pros:

- Fast UI iteration.
- Familiar app shell patterns.
- Skia can draw overlays.

Cons:

- ARKit marker tracking still needs native code.
- Composed video capture with camera + Skia overlays is risky.
- Native bridge complexity grows quickly.
- Harder to guarantee frame-accurate REC.

Verdict:

- Not recommended for first runtime.

### B. Swift Native + ARKit

Pros:

- Best iOS camera/AR integration.
- Direct ARKit support.
- Best path to marker tracking and anchors.
- Best access to PhotoKit and AVFoundation.
- Best TestFlight path.
- Lowest bridge risk.

Cons:

- More native iOS code.
- Codex cannot compile/test it in this Windows workspace.
- Needs physical iPhone for camera/AR/Photos testing.

Verdict:

- Recommended.

### C. Unity + AR Foundation

Pros:

- Strong cross-platform AR tooling.
- Good for 3D-heavy games.
- Built-in scene/render pipeline.

Cons:

- Larger app footprint.
- More engine overhead.
- iOS native Photos/recording integration can still require plugins.
- Project becomes Unity-first instead of app-first.
- Current product is 2D/2.5D AR overlay, not heavy 3D.

Verdict:

- Good backup if the product becomes 3D-heavy. Not best for current MVP.

### D. React Native Shell + Native AR Module

Pros:

- React Native can handle RPG/UI screens.
- Native module can own AR/camera.

Cons:

- Hardest architecture boundary.
- Recording composed UI across RN + native AR is high risk.
- Bridge latency and ownership complexity.
- Debugging capture bugs becomes painful.

Verdict:

- Not recommended until after native MVP proves the core loop.

## What Records Overlays Best

Swift native gives the most control.

Best principle:

- One composed render output.
- Screen, PHOTO, and REC read the same final frame.

Avoid:

- Native camera recording plus separate overlays.

## Easiest For Codex

For pure file generation, React Native is easier.

For this product's actual hard problems, Swift native is safer:

- camera
- marker tracking
- anchors
- Photos
- composed capture
- TestFlight

Codex can scaffold Swift files, docs, and architecture. Actual compile/device validation requires Xcode and iPhone.

## Best For TestFlight

Swift native.

Reason:

- Standard Xcode archive flow.
- Direct permissions.
- Direct app signing.
- No RN/Unity build layer while proving MVP.

## Best For RPG Layer Scaling

Swift native is still acceptable for the RPG layer:

- SwiftUI can cover menus, inventory, rewards, debug screens.
- Native rendering can cover camera battle.
- Local persistence can stay simple.

Future option:

- If RPG UI becomes large, add a structured SwiftUI architecture rather than React Native.

## Final Decision

Choose:

- `B. Swift native + ARKit`

Immediate Task 1 prototype:

- SwiftUI + AVFoundation camera frames
- SwiftUI overlay layer
- composed PHOTO capture
- PhotoKit save

Then:

- replace/extend camera prototype with ARKit marker tracking.
