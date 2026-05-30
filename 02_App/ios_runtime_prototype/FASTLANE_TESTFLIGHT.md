# Fastlane TestFlight Pipeline

Goal:

One repeatable command uploads the Swift native iOS runtime prototype to TestFlight for real iPhone PHOTO composition testing.

This is deployment only. It does not add gameplay, REC, ARKit, marker tracking, or boss systems.

## Recommended Path

Use fastlane on a Mac.

The app is Swift native, so the build machine must have macOS and Xcode. EAS is not the right fit for this prototype because this is not an Expo or React Native app.

## Required Mac Tools

- macOS
- Xcode installed from the Mac App Store
- Apple Developer account access
- XcodeGen
- Ruby/Bundler
- Physical iPhone with TestFlight installed

Install tools:

```bash
brew install xcodegen
gem install bundler
```

Install fastlane from the project Gemfile:

```bash
cd "/path/to/LoopyCat-RPG/02_App/ios_runtime_prototype"
bundle install
```

## Apple Developer Setup

You need:

- Active Apple Developer Program membership
- Access to App Store Connect
- Permission to create App IDs, certificates, profiles, and TestFlight builds
- A unique Bundle ID

Recommended Bundle ID:

```text
com.yourcompany.loopycat.photoprototype
```

Use one real Bundle ID and keep it stable.

## App Store Connect App Record

In App Store Connect:

1. Open Apps.
2. Click `+`.
3. Create a new iOS app.
4. Select the same Bundle ID used by fastlane.
5. Use a clear name, for example:

```text
LoopyCat Runtime Prototype
```

6. Set SKU, for example:

```text
loopycat-photo-prototype-001
```

The Bundle ID in App Store Connect must exactly match `APP_IDENTIFIER`.

## App Store Connect API Key

In App Store Connect:

1. Open Users and Access.
2. Open Integrations or API Keys.
3. Create an App Store Connect API key.
4. Give it access that can upload builds and manage TestFlight.
5. Download the `.p8` file once.
6. Store it outside the repo, for example:

```bash
mkdir -p "$HOME/keys"
mv ~/Downloads/AuthKey_XXXXXXXXXX.p8 "$HOME/keys/"
```

Do not commit `.p8` files.

## Environment Variables

Required:

```bash
export APP_IDENTIFIER="com.yourcompany.loopycat.photoprototype"
export ASC_KEY_ID="YOUR_KEY_ID"
export ASC_ISSUER_ID="YOUR_ISSUER_ID"
export ASC_KEY_PATH="$HOME/keys/AuthKey_YOUR_KEY_ID.p8"
```

Optional:

```bash
export APPLE_TEAM_ID="YOUR_10_CHARACTER_TEAM_ID"
export ASC_TEAM_ID="YOUR_APP_STORE_CONNECT_TEAM_ID"
export TESTFLIGHT_GROUPS="Internal Testers"
export TESTFLIGHT_CHANGELOG="PHOTO composition prototype build"
```

Keep these in your shell profile, a private local script, or CI secrets. Do not commit secrets.

## Repeatable TestFlight Command

Run this from the iOS prototype folder:

```bash
cd "/path/to/LoopyCat-RPG/02_App/ios_runtime_prototype"
xcodegen generate
bundle exec fastlane ios beta
```

The `beta` lane also runs `xcodegen generate`, so the command is safe if you forget the first line.

## What The Lane Does

1. Reads App Store Connect API key environment variables.
2. Generates the Xcode project with XcodeGen.
3. Enables automatic signing on the generated Xcode project.
4. Reads the latest TestFlight build number.
5. Increments the local build number.
6. Archives the app.
7. Uploads the `.ipa` to TestFlight.
8. Optionally assigns the build to `TESTFLIGHT_GROUPS`.

## First Upload Notes

The first upload may still require one-time Apple setup:

- Accept current Apple Developer agreements.
- Create the App Store Connect app record.
- Confirm the Bundle ID exists.
- Make sure the Mac can create or access Apple signing certificates.
- If automatic signing cannot create profiles, open Xcode once and sign in under Settings > Accounts.

## Internal Testing

In App Store Connect:

1. Open the app.
2. Open TestFlight.
3. Create or select an internal testing group.
4. Add your Apple ID as an internal tester.
5. Add the processed build to the group.

If `TESTFLIGHT_GROUPS` is set and fastlane has enough permission, fastlane will attempt group assignment.

## iPhone Install

On the iPhone:

1. Install TestFlight.
2. Sign in with the invited Apple ID.
3. Accept the TestFlight invitation.
4. Install `LoopyCat Runtime Prototype`.
5. Open the app.
6. Allow Camera permission.
7. Tap `PHOTO`.
8. Allow Photos permission.
9. Open Photos and verify the saved image.

## PHOTO Composition PASS

PASS means the saved image includes all visible layers:

- camera feed
- overlay layer
- portal placeholder
- boss placeholder
- HUD
- PHOTO/debug UI intended for capture

The saved image must look like the prototype screen.

## PHOTO Composition FAIL

FAIL means any of these happen:

- saved image is camera-only
- saved image is overlay-only
- saved image is black
- overlay is missing
- camera feed is missing
- save to Photos fails
- the app crashes on PHOTO

If this fails, stop gameplay work and change render/capture architecture before continuing.

## Common Errors And Fixes

### Missing Environment Variables

Error:

```text
Missing required environment variables
```

Fix:

Set:

```bash
APP_IDENTIFIER
ASC_KEY_ID
ASC_ISSUER_ID
ASC_KEY_PATH
```

### API Key File Not Found

Error:

```text
ASC_KEY_PATH does not exist
```

Fix:

Check the `.p8` path:

```bash
ls "$ASC_KEY_PATH"
```

### Bundle ID Error

Common causes:

- Bundle ID already belongs to another developer account.
- App Store Connect app record uses a different Bundle ID.
- `APP_IDENTIFIER` does not match the app record.

Fix:

Use one exact Bundle ID everywhere.

### Signing Error

Common causes:

- Xcode not signed into the Apple Developer account.
- Wrong team selected.
- Missing distribution certificate.
- Automatic signing cannot create provisioning profiles.

Fix:

1. Open Xcode.
2. Xcode > Settings > Accounts.
3. Add Apple ID.
4. Confirm the correct Team.
5. Set `APPLE_TEAM_ID` if you belong to multiple teams.
6. Re-run:

```bash
bundle exec fastlane ios beta
```

### Archive Fails

Common causes:

- Xcode command line tools not selected.
- Project not generated.
- Code signing failed.

Fix:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcodegen generate
bundle exec fastlane ios beta
```

### Upload Fails

Common causes:

- App Store Connect app record missing.
- API key lacks permission.
- Build number already used.
- Apple agreements not accepted.

Fix:

- Accept agreements in Apple Developer/App Store Connect.
- Confirm API key permissions.
- Confirm the app record exists.
- Re-run the lane; it reads latest TestFlight build number and increments.

### TestFlight Processing Delay

Build upload succeeds, but build does not appear immediately.

Fix:

Wait. Processing can take minutes or longer. Check App Store Connect > TestFlight.

### Tester Cannot See Build

Common causes:

- Tester not in internal group.
- Build not added to group.
- Build still processing.
- Tester using a different Apple ID.

Fix:

Add tester and build to the same internal group, then reopen TestFlight on iPhone.

## Current Known Limits

- This pipeline is prepared but not tested in this Windows workspace.
- Xcode archive and upload must be run on a Mac.
- TestFlight processing happens on Apple servers and may take time.
- This validates deployment and PHOTO composition only.
