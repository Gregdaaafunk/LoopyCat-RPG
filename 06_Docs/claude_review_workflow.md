# Claude Code Review Gate

This project uses Claude Code as a review gate before commit, push, GitHub Actions, or TestFlight deployment.

## Provider Setup

The purchased service is a hosted New API gateway for Claude-compatible traffic. The Yuque instructions say the purchased redemption code must be redeemed in the provider console first; it is not itself an API key.

Provider console:
- Primary: `https://cc.580ai.net`
- Backup from instructions: `https://cc.zhihuiapi.top`

After account registration and email verification:
1. Open Wallet/Top-up in the provider console.
2. Redeem the purchased code.
3. Open API Tokens.
4. Generate an `sk-...` token.
5. Configure the token locally only, never in the repository.

Recommended local shell configuration:

```bash
export ANTHROPIC_BASE_URL="https://cc.580ai.net"
export ANTHROPIC_AUTH_TOKEN="sk-REDACTED"
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
export API_TIMEOUT_MS=60000
```

Do not commit any generated token or provider account credential.

## Review Command

Run:

```bash
scripts/claude-review.sh
```

For a visible manual review in a terminal, run:

```bash
scripts/klavdia-review.sh
```

The visible command prints changed files, review scope, live progress lines, Claude output, and a final status line. It redacts credential-looking values from terminal output and still uses the same reviewer-only Claude configuration.

Live progress lines include:

- `Klavdia reviewing...`
- `Reading changed files...`
- `Checking SwiftUI layout...`
- `Checking architecture...`
- `Checking diagnostics...`
- `Checking deployment risks...`
- `Generating findings...`
- `Generating final report...`

The live mode is meant to let Greg watch the review process instead of only seeing the final status result.

The same workflow is also installed for other repositories on this machine:

```bash
claude-review-gate
```

If a repository has its own executable `scripts/claude-review.sh`, the global command delegates to it. Otherwise it performs a generic read-only diff review with the same secret-file checks and approval gate.

The script sends only local git status, diffs, and safe untracked text excerpts to Claude over stdin. Claude tools are disabled with `--tools ""`, slash commands are disabled, MCP config is forced to an empty temporary config, session persistence is disabled, and Claude cannot edit files, push, deploy, or read arbitrary project files through tools.

The script refuses to send likely secret/certificate files. If that happens, inspect the change manually and remove secrets before continuing.

## Gate Rule

Only this first-line status allows commit:

```text
APPROVED
```

These statuses block commit until fixed and re-reviewed:

```text
NEEDS_FIXES
REJECTED
```

Push and deployment still require a fresh verification pass with `scripts/claude-review-verify.sh`.

## Local Commit Enforcement

This repository includes a local pre-commit hook installer:

```bash
scripts/install-claude-review-hook.sh
```

The installed hook blocks commits when:
- `CLAUDE_REVIEW.md` is missing.
- The first line of `CLAUDE_REVIEW.md` is not `APPROVED`.
- `CLAUDE_REVIEW.md` is older than local changed files.

The hook is intentionally local to `.git/hooks/pre-commit`; Git does not track installed hooks. The tracked source is `scripts/claude-review-pre-commit`.

For manual push/deploy checks, use the approval verifier:

```bash
scripts/claude-review-verify.sh
```

The verifier checks:

- the report status is `APPROVED`
- the approved state matches the current repository state
- no files changed after review
- the review timestamp is newer than the final implementation

Emergency bypass is available only as an explicit local override:

```bash
CLAUDE_REVIEW_BYPASS=1 git commit ...
```

Use bypass only for non-deploying administrative commits when Claude is unavailable and the owner accepts the risk.
