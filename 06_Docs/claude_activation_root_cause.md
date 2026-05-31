# Claude Code Provider Activation Root Cause

Date: 2026-05-31

## Summary

The purchased code cannot be used directly in Claude Code. The provider instructions require a provider-console account first, then wallet redemption, then API-token generation. The current blocker is the provider registration step: the provider has email verification enabled, and no verified provider-console account/session exists on this machine.

## Evidence

Provider instruction document says:
- The purchased card/redeem code must be exchanged on the website into an `sk-...` token, not copied directly into config.
- Use `https://cc.580ai.net` or backup `https://cc.zhihuiapi.top`.
- Register an account, log in, open Wallet/Top-up to redeem the code, then open API Tokens to generate a key.
- Configure Claude Code with:
  - `ANTHROPIC_AUTH_TOKEN="your API key"`
  - `ANTHROPIC_BASE_URL="https://cc.580ai.net"`

Provider API status from `https://cc.580ai.net/api/status` reports:
- `email_verification: true`
- system name: `智汇api-企业级Claude code`
- API route: `https://cc.580ai.net`

Direct API probes:
- `POST /api/user/register` without email verification returns: `Email verification is enabled, please enter email address and verification code`.
- `POST /api/user/topup` with the activation code and no login returns: `Unauthorized, not logged in and no access token provided`.
- `GET /api/token/` with no login returns: `Unauthorized, not logged in and no access token provided`.
- `GET /api/user/self` with no login returns: `Unauthorized, not logged in and no access token provided`.
- `GET /api/verification` without a valid `email` query returns: `无效的参数`.

## Root Cause

The exact blocking step is provider account registration at `https://cc.580ai.net/register`.

The registration screen requires:
1. Username.
2. Password.
3. Email address.
4. Email verification code.

The verification code is expected in the inbox of the email address entered on that registration screen. No such email account has been selected or verified in the current setup, so no provider account session can be created.

Because there is no authenticated provider session:
- The wallet/top-up page cannot redeem the activation code.
- The API-token page cannot generate an `sk-...` key.
- Claude Code cannot receive `ANTHROPIC_AUTH_TOKEN`.

## Redemption Status

The activation code redemption status cannot be determined from the current unauthenticated state.

Reason: the provider top-up endpoint rejects the request as unauthorized before validating or reporting anything about the code. Therefore there is no evidence that the code has already been redeemed, and no evidence that it is unused. Checking this requires logging into the provider account that should own the redemption.

## Required Provider Flow

1. Open `https://cc.580ai.net/register`.
2. Register a provider-console account using an accessible email address.
3. Request the email verification code from the registration screen.
4. Open that email inbox and copy the verification code.
5. Complete registration and log in.
6. Open Wallet/Top-up and redeem the purchased code.
7. Open API Tokens and generate an `sk-...` token.
8. Configure locally:

```bash
export ANTHROPIC_BASE_URL="https://cc.580ai.net"
export ANTHROPIC_AUTH_TOKEN="sk-REDACTED"
```

The activation code is supposed to result in a provider-generated `sk-...` credential used as `ANTHROPIC_AUTH_TOKEN`. It is not itself `ANTHROPIC_AUTH_TOKEN`, and it is not an Anthropic `ANTHROPIC_API_KEY`.

## Account Requirements

Provider requires:
- Provider website account: yes.
- Provider email verification: yes.
- Provider browser/session authentication: yes, unless using equivalent authenticated API calls after account creation.
- Code redemption: yes.
- API token generation: yes.

Provider does not require, according to the instructions:
- Claude account login.
- Anthropic account creation.
- Anthropic OAuth browser authentication.
- Apple, GitHub, App Store Connect, certificate, `.p8`, or other deployment secrets.

## Remaining Owner Action

Owner action is required because an accessible email inbox is needed. The owner must choose the email address for the provider-console account and complete the verification email step.

After the owner supplies the generated `sk-...` token locally, the already-installed command can validate the workflow:

```bash
claude-review-gate
```

