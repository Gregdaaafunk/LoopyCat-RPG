# Project Context

This file is persistent project context. Future sessions must read it together with `AI_TEAM.md`, `CODEX.md`, and `CLAUDE.md` before starting work.

## Project Name

LoopyCat-RPG

## Current Project Goals

- Build a playable iPhone-first LoopyCat RPG MVP.
- Keep the runtime UI readable and safe on real iPhone portrait screens.
- Preserve enough diagnostics to understand every real-device test session after app reopen.
- Use Klavdia as a mandatory architecture and quality gate before commit, push, GitHub Actions, and TestFlight.

## Current Architecture Summary

- The active iOS prototype lives in `02_App/ios_runtime_prototype`.
- The app is a SwiftUI runtime prototype generated from `project.yml` with XcodeGen.
- `RuntimeSessionViewModel` owns runtime state, camera state, diagnostics, battle state, persistence, and event emission.
- `RuntimeViews.swift` contains the main SwiftUI screens, battle composition, debug panel, diagnostics sheets, and portrait hub layout.
- `RuntimeSaveStore` persists cat profile, inventory, settings, rewards, battle history, and last-session diagnostic report in Application Support.
- GitHub Actions workflow `.github/workflows/testflight.yml` builds and uploads the runtime prototype to TestFlight through Fastlane.

## Current Platform Status

- Target platform: iOS.
- Primary device priority: iPhone portrait.
- Project deployment target: iOS 16.0.
- CI build runner: macOS 26 with Xcode 26.
- Local Bucephalus environment does not currently provide `swift`, `xcodegen`, or `xcodebuild`; iOS builds are verified through GitHub Actions.

## Current TestFlight Status

- Latest successful TestFlight run: `26712468815`.
- Latest uploaded build: `1.0 (3)`.
- Commit deployed: `c95d737`.
- Upload completed successfully and App Store Connect finished processing the build.

## Current Priorities

- Validate the new portrait UI on a real iPhone.
- Confirm normal mode has no visible debug/event spam.
- Confirm Debug Mode shows controlled diagnostics without blocking core controls.
- Confirm previous-session diagnostics appear automatically on app reopen.
- Continue improving gameplay only after the UI/debug/report blocker is verified on device.

## Current Blockers

- No known repository blocker after TestFlight build `1.0 (3)`.
- Real-device validation is still required by Greg.

## Known Technical Debt

- `RuntimeSessionViewModel` is large and owns many responsibilities; future work should split runtime state, diagnostics, battle logic, and persistence when feature pressure grows.
- Diagnostic report persistence currently uses synchronous file writes on the main actor; acceptable for prototype, but should move to a safer persistence service if reports grow.
- Automated tests for scene phase handling and diagnostic persistence are missing.
- Some Fastlane/GitHub Actions logs show a Node 20 deprecation warning for `actions/checkout@v4`; this does not currently block builds.

## Recent Major Milestones

- Configured Claude Code provider access for Klavdia review.
- Added visible Klavdia review command: `scripts/klavdia-review.sh`.
- Installed local pre-commit review gate.
- Added permanent AI team document.
- Fixed runtime UI/UX blocker:
  - portrait-safe hub layout
  - large readable fight button
  - debug panel hidden by default
  - controlled debug panel when enabled
  - no frame event spam in normal UI
- Added previous-session diagnostic report persistence and launch display.
- Uploaded TestFlight build `1.0 (3)` successfully.

## Important Project Decisions

- Kolyan implements.
- Klavdia reviews.
- Only APPROVED code may be committed, pushed, or deployed.
- APPROVED applies only to the exact repository state reviewed by Klavdia.
- If any file changes after approval, the approval is invalid and review must run again.
- Klavdia has no push, deployment, release, credential, token, certificate, or account authority.
- Secrets must not be printed in terminal output or sent to Klavdia.
- Future sessions must read `AI_TEAM.md`, `CODEX.md`, `CLAUDE.md`, and `PROJECT_CONTEXT.md` before starting work.

## Visible Klavdia Review

The project supports visible review through:

```bash
scripts/klavdia-review.sh
```

The command displays:

- Changed files
- Review scope
- Repository state ID
- Claude output
- Final status: APPROVED, NEEDS_FIXES, or REJECTED

The command must not expose secrets, tokens, or provider credentials.
