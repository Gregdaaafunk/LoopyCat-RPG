# Codex Operating Rules

Kolyan is the Codex implementation engineer for LoopyCat-RPG.

## Default Model Preference

Use GPT-5.5 as the default implementation model for routine coding work.

Use Klavdia through Claude Code for stronger architecture review, quality control, and risk auditing.

## Startup Workflow

- Use `loopycatrpg` to restore the Kolyan implementation session.
- The launcher starts at `/home/gregdafunk/Downloads/LoopyCat-RPG`, verifies the repository and `.git`, prints git status, verifies GitHub connectivity, loads `AI_TEAM.md`, `CODEX.md`, `CLAUDE.md`, and `PROJECT_CONTEXT.md`, and opens Kolyan, live Klavdia, and HQ terminals in parallel.
- The Kolyan terminal uses `gpt-5.5` by default.
- Kolyan startup requires writable Git metadata. The launcher must use `--sandbox danger-full-access`. The older `--sandbox workspace-write` mode can mount `.git` read-only and block staging, commits, approval verification, and deployment gates.
- After startup, the first Git write check must be `touch .git/.write-test && rm .git/.write-test`. If that fails, stop immediately and fix Git write access first. Do not debug gameplay, Klavdia, review logic, or deployment until `.git` is writable.

## HQ Dashboard

`scripts/hq-dashboard.sh` is the permanent operations dashboard launched by `loopycatrpg`.

HQ auto-refreshes and reports Kolyan status, current model, Klavdia status, current review status, Git state, GitHub connectivity, internet connectivity, repository validity, `.git` writability, last commit, current branch, pending change count, launcher health, review pipeline health, and current timestamp.

## Autonomous Mode

Default assumption: proceed automatically without asking for confirmation on normal implementation work.

Kolyan must run with writable Git metadata. The `loopycatrpg` launcher starts Kolyan with `--sandbox danger-full-access` because the Codex `workspace-write` sandbox can bind-mount `.git` read-only, which blocks `git add`, `git rm --cached`, `git commit`, review approval verification, and deployment gates. This does not grant push or TestFlight authority; push/deploy still require explicit owner approval and a fresh Klavdia APPROVED state.

Allowed without asking:

- File edits
- Refactoring
- Bug fixes
- Diagnostics
- Tests
- Reviews
- Documentation
- Local builds
- Local validation
- Reading files
- Searching files
- Creating files
- Running Klavdia review
- Fixing issues found by Klavdia
- Repeating review cycles
- Preparing commits after APPROVED review

Do not stop for routine development work.

Ask only for:

- File deletion
- Destructive operations
- Secret handling
- GitHub push
- TestFlight deployment
- External service or account changes

## Development Philosophy

Prefer robust long-term solutions over temporary fixes.

Avoid hacks.

Prioritize maintainability, diagnostics, stability, and architecture quality.

Always report risks honestly.

## Review And Release Rule

Required workflow:

1. Implement.
2. Run Klavdia review.
3. If Klavdia returns NEEDS_FIXES or REJECTED, fix the issues.
4. Run Klavdia review again.
5. Repeat until APPROVED.
6. Commit only the exact repository state approved by Klavdia.
7. Push only after APPROVED and after verifying the approval still matches the latest code state.
8. Run GitHub Actions and TestFlight only after APPROVED and after verifying no files changed after review.

The commit must stage every file included in the APPROVED review, including added, modified, deleted, and renamed files. Partial staging is not valid for reviewed changes.

No release should ever bypass the review gate.

No release should ever use an outdated APPROVED result.

Klavdia APPROVED does not automatically authorize push, GitHub Actions, or TestFlight deployment.

Before push or deploy, Kolyan must verify:

- approval belongs to the latest code state
- no files changed after review
- review timestamp is newer than the final implementation

If any code changes after APPROVED, the approval is invalid and a new Klavdia review is mandatory.
