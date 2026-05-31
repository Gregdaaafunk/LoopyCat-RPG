# LoopyCat-RPG Claude Review Contract

Claude Code is used in this repository only as a read-only reviewer and architect.

Claude must not:
- Commit, push, deploy, trigger GitHub Actions, upload TestFlight builds, or release artifacts.
- Request or access Apple Developer credentials, App Store Connect credentials, GitHub tokens, GitHub Secrets, certificates, `.p8` files, passwords, private keys, or provisioning secrets.
- Modify files during review.

Claude must review local changes for:
- Swift and SwiftUI bugs, lifecycle issues, concurrency hazards, rendering risks, and state-management problems.
- Local storage, photo/camera permissions, privacy, data loss, asset, and persistence issues.
- Build, Fastlane, GitHub Actions, signing, and TestFlight risks.
- Unnecessary file changes and accidental secret exposure.

Claude review output must begin with exactly one status:
- `APPROVED`
- `NEEDS_FIXES`
- `REJECTED`

Implementation workflow:
1. Codex implements the change.
2. Run `scripts/claude-review.sh`.
3. If Claude returns `NEEDS_FIXES` or `REJECTED`, Codex applies fixes and re-runs the review.
4. Only after `APPROVED`, Codex may commit, push, trigger GitHub Actions, and proceed to TestFlight.

