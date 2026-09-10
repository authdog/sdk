# Research: User Info SDK Baseline

**Date**: 2026-09-10  
**Feature**: `001-userinfo-sdk`

This is a code-first audit, not a greenfield technology choice. Decisions
below freeze the current intended contract and name the drift to fix
in `002-cross-sdk-parity`.

## Decision 1 — One operation: GET /v1/userinfo

**Decision**: Official SDKs wrap only `GET /v1/userinfo`.

**Rationale**: Root README, every core README, and every client
implementation agree. No other paths appear in core source.

**Alternatives considered**: Document unpublished methods found in
planned C (config-stored access token, flattened user struct). Rejected
for the baseline — that is a different, incomplete API.

## Decision 2 — Access token is the userinfo credential

**Decision**: The token passed to get-user-info is the Bearer credential
for that request. Constructor `apiKey` must not replace it.

**Rationale**: READMEs present `getUserInfo(accessToken)` as the way to
fetch the user. Node and Python already send the argument on the
request (overriding a default api-key header). Constitution Security
makes this non-negotiable.

**Observed drift**:

| SDK | Actual behavior |
|-----|-----------------|
| Node | Request header `Authorization: Bearer <accessToken>` (correct) |
| Python | Per-request header uses access token (correct) |
| Go | After setting the access token, a non-empty `apiKey` **overwrites** `Authorization` |
| Rust | Same overwrite as Go |
| Java | If `apiKey != null`, access token is **never sent** |
| C# | Default headers may already contain API-key `Authorization`; the request also adds access-token `Authorization` (duplicate-header risk) |

**Alternatives considered**: Treat API key as the only credential
(matches Java today). Rejected — it makes the access-token argument
dead code and contradicts Node/Python/docs.

## Decision 3 — Shared JSON field names stay camelCase

**Decision**: Wire format uses the TypeScript/Go/Java field names
(`displayName`, `remainingSeconds`, `externalId`, …). Language
bindings rename in-process (Rust `display_name`, C# `DisplayName`).

**Rationale**: All typed cores already deserialize this shape. Python
returns the JSON object unchanged.

**Alternatives considered**: snake_case on the wire. Rejected — would
break every typed client and the live API.

## Decision 4 — Three public error types

**Decision**: Base + Authentication + API. Stable messages for 401 and
the two known 500 bodies.

**Rationale**: Documented in every core README; implemented everywhere
with local naming (`ApiException` in Java/C#).

**Observed drift**:

- Go: `AuthenticationError` / `APIError` do not embed `AuthdogError`,
  so `IsAuthdogError` is always false for real failures.
- Rust: `From<AuthenticationError>` / `From<APIError>` collapse into
  `AuthdogError`, so callers cannot match the original type after
  `?`. README already tells people to search the message string —
  that violates Constitution III.
- Python: no timeout and no typed models; `get_userinfo` naming.

## Decision 5 — Timeout default 10 seconds

**Decision**: 10s is the default where the client owns the HTTP stack.

**Observed drift**: Python httpx client has no timeout. C# relies on
`HttpClient` default unless a custom client is injected.

## Decision 6 — Core vs planned

**Decision**: Only the six moon projects are official. `planned/` is
incubation. Root `c/` (built artifacts) and `kotlin/` (`build/` only)
are not packages.

**Rationale**: README "Core SDKs" table and `.moon/workspace.yml`
agree. CONTRIBUTING.md incorrectly lists many languages at the repo
root; that doc is stale.

**Planned CI**: Workflows exist for C, C++, Clojure, Common Lisp,
Dart, Elixir, F#, Kotlin, OCaml, PHP, PowerShell, R, Ruby, Scala,
Swift, Zig. Several (including C) have push/PR triggers commented
out and run only on `workflow_dispatch`.

## Decision 7 — Keep moon + proto

**Decision**: Do not replace the task runner as part of baseline
docs. Core workflows use `.github/actions/setup-moon`.

**Toolchain pins** (`.prototools`): Node 20.18.0, pnpm 9.15.0, Go
1.21.13, Rust 1.82.0, Python 3.11.10. Java and .NET are installed by
the composite action, not proto.

## Method naming (idiomatic, allowed)

| Language | Client | Method |
|----------|--------|--------|
| Python | `AuthdogClient` | `get_userinfo` |
| TypeScript | `AuthdogClient` | `getUserInfo` (async) |
| Go | `Client` via `NewClient` | `GetUserInfo(ctx, token)` |
| Rust | `AuthdogClient` | `get_user_info` (async) |
| Java | `AuthdogClient` | `getUserInfo` |
| C# | `AuthdogClient` | `GetUserInfoAsync` / `GetUserInfo` |

## Type-model drift

- Go `User.CreatedAt` is `time.Time` while `User.UpdatedAt` is
  `string`. Same split on `Verification`.
- Python has no `UserInfoResponse` model.
- `phoneNumbers` / `addresses` are untyped arrays in every language.

## Docs drift

- CONTRIBUTING.md still says Node tests use Jest (they use Vitest),
  Python 3.7+ (setup.py is ≥3.8), and lists Kotlin/PHP/C++ at `/kotlin`
  etc.
- Rust README error-handling example matches string matching, not
  typed errors.
- Package import paths: `authdog`, `@authdog/node-sdk`,
  `github.com/authdog/go-sdk`, `authdog` (crates.io name),
  `com.authdog:authdog-java-sdk`, `Authdog.Sdk`.
