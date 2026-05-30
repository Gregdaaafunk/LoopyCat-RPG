# iOS Runtime Prototype

Project title: LoopyCat RPG AR

Purpose:

- Prove camera preview plus overlay can be captured together.
- Keep this prototype minimal.
- Do not add gameplay yet.

## Recommended Stack

Swift native iOS-first.

Initial prototype uses:

- SwiftUI for shell and debug UI.
- AVFoundation video frames for camera preview.
- SwiftUI overlay layer for boss/portal/debug placeholders.
- SwiftUI `ImageRenderer` for composed PHOTO capture.
- PhotoKit for saving the composed image to Photos.

Future battle runtime can add:

- ARKit for marker / image tracking.
- Metal or RealityKit-backed composition if SwiftUI snapshot is not enough for REC.
- AVAssetWriter for composed REC.

## Why This Prototype

The hard requirement is composed capture.

Native camera-only recording is invalid because it misses boss, portal, HP, damage, combo, KO, loot, and UI overlays.

This prototype draws camera frames and overlay UI into one visible SwiftUI scene, then captures that composed scene.

## Files

- `LoopyCatRuntimePrototypeApp.swift`
- `ContentView.swift`
- `CameraFrameModel.swift`
- `ComposedSceneView.swift`
- `DebugState.swift`
- `PhotoLibraryWriter.swift`
- `Info.plist`

## Xcode Setup

Preferred:

1. Install XcodeGen on a Mac.
2. Run `xcodegen generate` in this folder.
3. Open the generated Xcode project.

Manual fallback:

Create a new iOS App project in Xcode named `LoopyCatRuntimePrototype`, then add the Swift files in this folder.

Required deployment target:

- iOS 16+

Required permissions:

- Camera usage
- Add to Photos usage

`Info.plist` is included as a reference.

## Test

1. Run on a physical iPhone.
2. Allow camera permission.
3. Confirm live camera preview appears.
4. Confirm overlay placeholder is visible over camera.
5. Tap `PHOTO`.
6. Allow Photos permission.
7. Open Photos.
8. Confirm saved image contains camera plus overlay.

Success:

- Saved image includes camera feed and overlay together.

Detailed device checklist:

`PHOTO_COMPOSITION_DEVICE_TEST.md`

## TestFlight Pipeline

For repeatable TestFlight builds, use fastlane from this folder:

```bash
bundle install
xcodegen generate
bundle exec fastlane ios beta
```

Required environment variables:

```bash
export APP_IDENTIFIER="com.yourcompany.loopycat.photoprototype"
export ASC_KEY_ID="YOUR_KEY_ID"
export ASC_ISSUER_ID="YOUR_ISSUER_ID"
export ASC_KEY_PATH="$HOME/keys/AuthKey_YOUR_KEY_ID.p8"
```

Optional:

```bash
export APPLE_TEAM_ID="YOUR_10_CHARACTER_TEAM_ID"
export TESTFLIGHT_GROUPS="Internal Testers"
```

Full deployment checklist:

`FASTLANE_TESTFLIGHT.md`

Failure:

- Saved image only contains camera.
- Saved image only contains UI.
- Saved image is black.
- Save to Photos fails.

## Known Limits

- This is not full AR tracking yet.
- This is not REC capture yet.
- This is not marker detection yet.
- This is not gameplay.
- The workspace is currently on Windows, so this cannot be built or device-tested here.
