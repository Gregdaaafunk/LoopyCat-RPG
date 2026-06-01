# Project Context

This file is persistent project context. Future sessions must read it together with `AI_TEAM.md`, `CODEX.md`, and `CLAUDE.md` before starting work.

## Project Name

LoopyCat-RPG

## Current Project Goals

- Build a playable iPhone-first LoopyCat-RPG MVP.
- Keep the runtime UI readable and safe on real iPhone portrait screens.
- Preserve enough diagnostics to understand every real-device test session after app reopen.
- Use Klavdia as a mandatory architecture and quality gate before commit.
- Verify approval freshness before any push, GitHub Actions run, or TestFlight deployment.

## AI Team

- Greg - Owner
- Matroskin (GPT) - Strategy, architecture, systems design, analysis, long-term product direction
- Kolyan (Codex) - Implementation engineer
- Klavdia (Claude Code) - Reviewer, architecture auditor, quality gate, risk auditor

## Workflow

- Kolyan implements.
- Klavdia reviews.
- If Klavdia returns NEEDS_FIXES or REJECTED, fix issues, rerun review, and repeat until APPROVED.

## Review Rule

- Klavdia APPROVED is required before commit.
- Klavdia APPROVED does not automatically authorize push or TestFlight deployment.
- Before push or deploy, Kolyan must verify the approval belongs to the latest code state.
- Before push or deploy, Kolyan must verify no files changed after review.
- Before push or deploy, Kolyan must verify the approval timestamp is newer than the final implementation.
- If any code changes after APPROVED, APPROVED becomes invalid and a new Klavdia review is mandatory.
- GitHub pushes are blocked by `.git/hooks/pre-push` installed from `scripts/claude-review-pre-push`.
- TestFlight uploads are blocked by `02_App/ios_runtime_prototype/fastlane/Fastfile`, which runs `scripts/claude-review-verify.sh` before the `beta` lane continues.
- Local push/TestFlight gate behavior is verified by `scripts/launcher-gate-verify.sh`, which confirms `NEEDS_FIXES` and `REJECTED` block while `APPROVED` allows the current reviewed state.

## Live Review Mode

- Visible review entrypoint: `scripts/klavdia-review.sh`
- Live mode shows progress lines while Klavdia is reviewing.
- Example progress lines:
  - `Klavdia reviewing...`
  - `Reading changed files...`
  - `Checking SwiftUI layout...`
  - `Checking architecture...`
  - `Checking diagnostics...`
  - `Checking deployment risks...`
  - `Generating findings...`
  - `Generating final report...`

## Startup Workflow

- `loopycatrpg` is the only official startup command for the full environment.
- It opens `/home/gregdafunk/Downloads/LoopyCat-RPG`, verifies the repository and `.git`, prints git status, verifies GitHub connectivity, loads `AI_TEAM.md`, `CODEX.md`, `CLAUDE.md`, and `PROJECT_CONTEXT.md`, starts Kolyan with `gpt-5.5` by default, opens a separate visible live Klavdia terminal, and opens the permanent HQ operations dashboard.
- The workflow repeats review cycles until Klavdia returns `APPROVED` for the latest code state.
- If code changes after approval, the approval is invalid and a fresh review is mandatory.
- Kolyan is launched with writable Git metadata. The launcher uses Codex `--sandbox danger-full-access` because `workspace-write` can mount `.git` read-only and prevent staging, commits, approval verification, push, and TestFlight gates. This is a local repository write-access requirement only; push and deploy still require explicit owner approval and a current Klavdia APPROVED report.
- Startup verification must include `touch .git/.write-test && rm .git/.write-test`. If that check fails, stop immediately. Treat the failure as a Codex sandbox / mount problem, not a gameplay, Klavdia, or deployment problem.
- This Git-write requirement is permanent institutional knowledge for LoopyCat-RPG sessions.

## HQ Operations Dashboard

- HQ entrypoint: `scripts/hq-dashboard.sh`
- Launched automatically by `loopycatrpg` as the third permanent terminal.
- Auto-refreshes every 15 seconds by default.
- Displays Kolyan, current model, Klavdia, current review, Git, GitHub, internet, repository, `.git`, last commit, current branch, pending changes, launcher, review pipeline, and timestamp status.
- Makes `.git` read-only state, network/GitHub failure, launcher failure, review pipeline failure, and Klavdia review errors visible without asking Kolyan or Klavdia.

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
- Only APPROVED code may be committed.
- APPROVED applies only to the exact repository state reviewed by Klavdia.
- If any file changes after approval, the approval is invalid and review must run again.
- Klavdia has no push, deployment, release, credential, token, certificate, or account authority.
- Klavdia has no GitHub write authority.
- Secrets must not be printed in terminal output or sent to Klavdia.
- Future sessions must read `AI_TEAM.md`, `CODEX.md`, `CLAUDE.md`, and `PROJECT_CONTEXT.md` before starting work.

## Autonomous Mode

- Normal implementation work proceeds automatically without asking for confirmation.
- Allowed without asking:
  - file edits
  - refactoring
  - bug fixes
  - diagnostics
  - tests
  - reviews
  - documentation
  - local builds
  - local validation
- Ask only for:
  - file deletion
  - destructive operations
  - secret handling
  - GitHub push
  - TestFlight deployment
  - external service or account changes

## Visible Klavdia Review

The project supports visible review through:

```bash
scripts/klavdia-review.sh
```

The command displays:

- Changed files
- Review scope
- Live progress lines
- Repository state ID
- Claude output
- Final status: APPROVED, NEEDS_FIXES, or REJECTED

For pre-push and pre-deploy verification, use:

```bash
scripts/claude-review-verify.sh
```

The command must not expose secrets, tokens, or provider credentials.
