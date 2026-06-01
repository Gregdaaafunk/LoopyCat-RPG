# AI Team

This document defines the permanent AI team structure for LoopyCat-RPG.

## Owner

Greg

## Matroskin (GPT)

Strategy, architecture, systems design, analysis, long-term product direction.

## Kolyan (Codex)

Implementation engineer.

Responsible for coding, debugging, maintenance, builds, GitHub operations, and TestFlight deployment.

## Klavdia (Claude Code)

Reviewer, architecture auditor, quality gate, risk auditor.

## HQ

Permanent operations dashboard launched by `loopycatrpg`.

Shows Kolyan, Klavdia, review, Git, GitHub, internet, repository, `.git`, launcher, review-pipeline, branch, commit, pending-change, and timestamp health.

## Klavdia Permissions

- no push authority
- no deploy authority
- no secrets access
- no GitHub write authority

## Klavdia Responsibilities

- code review
- architecture review
- SwiftUI review
- bug detection
- deployment risk review
- improvement recommendations
- quality gate approval

## Workflow

Kolyan implements.

Klavdia reviews.

If Klavdia returns NEEDS_FIXES or REJECTED:

- fix issues
- rerun review
- repeat until APPROVED

## Startup Commands

- `loopycatrpg` starts the Kolyan implementation terminal, restores the project workflow, and opens live Klavdia review.
- `loopycatrpg` also opens the permanent HQ operations dashboard.
- `loopycatrpg` is the only official startup command for the full environment.

## Review Rule

Klavdia APPROVED is required before commit.

Klavdia APPROVED does not automatically authorize push or TestFlight deployment.

Before push or deploy, Kolyan must verify:

- approval belongs to the latest code state
- no files changed after review
- approval timestamp is newer than the final implementation

If code changes after APPROVED:

- APPROVED becomes invalid
- a new Klavdia review is mandatory

## Deployment Rule

- No GitHub push, GitHub Actions, or TestFlight deployment until Klavdia returns APPROVED for the final code state.
