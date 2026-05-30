# PHOTO Composition Device Test

Project title: LoopyCat RPG AR

## Goal

Prove the Swift prototype can save composed output.

Test only:

- Camera feed
- Overlay layer
- Portal placeholder
- Boss placeholder
- HUD
- PHOTO button

Saved image in Photos must include all visual layers.

Do not add:

- REC
- ARKit
- Marker tracking
- Gameplay

## Required Tools

Required:

- Mac with Xcode installed
- XcodeGen
- Physical iPhone
- iPhone USB cable or trusted wireless debugging
- Apple developer signing available in Xcode

Not enough:

- Windows machine
- iOS Simulator only

Reason:

- Camera and Photos behavior must be tested on a physical iPhone.

## Exact Mac Setup Steps

1. Copy or sync the project folder to a Mac.
2. Open Terminal.
3. Go to the prototype folder.
4. Generate the Xcode project.
5. Open the generated project.
6. Select a physical iPhone.
7. Set signing team.
8. Build and run.
9. Allow Camera permission.
10. Tap `PHOTO`.
11. Allow Photos add permission.
12. Open Photos app.
13. Verify saved image.

## Exact Commands

From the prototype folder:

```bash
cd "/path/to/LoopyCat-RPG/02_App/ios_runtime_prototype"
xcodegen generate
open LoopyCatRuntimePrototype.xcodeproj
```

Optional command-line build after project generation:

```bash
xcodebuild \
  -project LoopyCatRuntimePrototype.xcodeproj \
  -scheme LoopyCatRuntimePrototype \
  -destination 'generic/platform=iOS' \
  build
```

For actual camera test, run from Xcode on a physical iPhone.

## Expected On-Device Screen

The running app should show:

- Live camera feed filling the screen.
- `TARGET LOCKED` text.
- Cyan/purple portal placeholder rings.
- Red `BOSS` / `SPAWN` placeholder.
- Top HUD with `LOOPYCAT RPG AR`.
- HP bar.
- `COMBO x0`.
- Debug panel.
- `PHOTO` button.
- Status text near the button.

## Expected Saved Photo

Open Photos after tapping `PHOTO`.

The saved image must include:

- Camera feed.
- Portal rings.
- `TARGET LOCKED`.
- Boss placeholder.
- HUD.
- HP bar.
- Combo text.
- Debug panel if enabled.

The saved image must not be:

- Raw camera only.
- Overlay only.
- Black frame.
- Blank frame.
- Missing HUD.
- Missing boss/portal placeholders.

## Logs To Check

In Xcode console, look for debug event text:

- `app_start`
- `recording_started PHOTO`
- `recording_finished PHOTO composed=true`

Failure logs may include:

- `recording_failed image_renderer_empty`
- `recording_failed <permission error>`
- `CAMERA_DENIED`
- `CAMERA_CONFIG_FAILED`

Also watch runtime state in the debug panel:

- Camera should become `CAMERA_RUNNING`.
- Recording should move through:
  - `CAPTURING_PHOTO`
  - `EXPORTING`
  - `FINISHED`

## Possible Errors And Fixes

### `xcodegen: command not found`

Fix:

```bash
brew install xcodegen
```

Then rerun:

```bash
xcodegen generate
```

### Xcode signing error

Fix:

- Open project in Xcode.
- Select app target.
- Go to Signing & Capabilities.
- Select your Team.
- Change Bundle Identifier if needed.

### Camera permission denied

Fix:

- On iPhone, go to Settings.
- Find the prototype app.
- Enable Camera.
- Relaunch app.

### Photos permission denied

Fix:

- On iPhone, go to Settings.
- Find the prototype app.
- Enable Photos add permission.
- Relaunch app.

### App shows black camera

Possible causes:

- Running on simulator.
- Camera permission denied.
- Camera session failed.

Fix:

- Run on physical iPhone.
- Check Xcode console.
- Confirm `NSCameraUsageDescription` exists in `Info.plist`.

### Saved image is black

Meaning:

- Composition capture path failed.

Fix direction:

- Do not continue to gameplay.
- Investigate SwiftUI `ImageRenderer` camera-frame capture.
- Consider moving to a dedicated render target / Metal-backed composition.

### Saved image contains overlay but no camera

Meaning:

- Camera frame is not being included in the rendered snapshot.

Fix direction:

- Ensure camera is drawn as an image inside the SwiftUI composition.
- If live preview layer is used later, do not rely on layer capture.
- Move camera frame into the same render target.

### Saved image contains camera but no overlay

Meaning:

- Capture path is reading camera only.

Fix direction:

- Reject this architecture.
- Ensure PHOTO reads final composed scene, not raw camera output.

### PHOTO button disabled

Cause:

- No current camera frame yet.

Fix:

- Wait for `CAMERA_RUNNING`.
- Confirm live preview is visible.

## PASS Criteria

PASS only if all are true:

- App runs on physical iPhone.
- Live camera feed is visible.
- Overlay layer is visible.
- PHOTO button saves an image.
- Saved image appears in Photos.
- Saved image includes camera feed.
- Saved image includes portal placeholder.
- Saved image includes boss placeholder.
- Saved image includes HUD.
- Saved image includes debug panel if enabled.
- Xcode log shows `recording_finished PHOTO composed=true`.

## FAIL Criteria

FAIL if any are true:

- App cannot run on physical iPhone.
- Camera preview does not appear.
- PHOTO does not save.
- Saved photo is raw camera only.
- Saved photo is overlay only.
- Saved photo is black or blank.
- Saved photo misses portal/boss/HUD overlays.
- Xcode log shows `recording_failed`.

## Decision Rule

If PASS:

- Continue to Tracking Sprint.

If FAIL:

- Stop gameplay work.
- Change render/capture architecture before adding ARKit, marker tracking, boss spawn, or combat.

## Test Result Template

```text
Device:
iOS version:
Xcode version:
Date:

Camera visible:
Overlay visible:
PHOTO saved:
Saved image includes camera:
Saved image includes portal:
Saved image includes boss:
Saved image includes HUD:
Console success log:

PASS / FAIL:
Notes:
```
