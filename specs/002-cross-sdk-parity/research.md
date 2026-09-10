# Research: Cross-SDK Parity Hardening

**Date**: 2026-09-10  
**Feature**: `002-cross-sdk-parity`

## Decision 1 — Access token is the only Authorization on userinfo

**Decision**: Remove api-key overwrite in Go/Rust/Java. Do not put
apiKey on C# `DefaultRequestHeaders`. Constructor `apiKey` remains
stored for future endpoints.

**Rationale**: Matches Node/Python and constitution Security.

**Alternatives considered**: Dual headers (rejected — HTTP forbids
ambiguous Authorization). Separate `X-API-Key` (rejected — not in
the wire contract).

## Decision 2 — Go helpers use type membership, not embedding only

**Decision**: `IsAuthdogError` returns true for `*AuthdogError`,
`*AuthenticationError`, and `*APIError`. Transport failures become
`*APIError` with the existing `request failed:` prefix.

**Rationale**: Embedding `AuthdogError` still fails a concrete type
assert on `*AuthenticationError`. Membership is what callers need.

**Alternatives considered**: `errors.As` on an embedded pointer
(more invasive, same outcome).

## Decision 3 — Rust `AuthdogError` is an enum

**Decision**:

```text
AuthdogError::Authentication(AuthenticationError)
AuthdogError::Api(APIError)
AuthdogError::Other(String)
```

Keep `AuthdogError::new` → `Other`. `From` impls wrap instead of
flattening. Add `is_authentication()` / `is_api()`.

**Rationale**: Survives `?`. Existing `to_string()` tests still pass.

**Alternatives considered**: `thiserror` crate (extra dep, rejected).
Keep structs + string matching (violates constitution).

## Decision 4 — Python dataclasses, snake_case attributes

**Decision**: New `authdog/types.py` with `from_dict`, resilient
defaults for partial fixtures. `get_userinfo` returns
`UserInfoResponse`. JSON stays camelCase on the wire.

**Rationale**: No new dependency. Matches Rust naming. 0.x may break
`response["user"]["displayName"]`; README updates.

**Alternatives considered**: TypedDict (keeps `[]` access but no
attribute API). Pydantic (extra dep).

## Decision 5 — Timeout only on owned HTTP clients

**Decision**: Python `timeout=10.0` on `httpx.Client`. C# sets
`HttpClient.Timeout` only when the constructor creates the client.
Injected clients are unchanged.

**Rationale**: Spec edge case; DI users own timeout.

## Decision 6 — Ignore leftover root `c/` and `kotlin/`

**Decision**: Add `/c/` and `/kotlin/` to `.gitignore`. Official ports
stay in `planned/`.

**Rationale**: Untracked build/copy trees; deleting local artifacts
is unnecessary.

## Decision 7 — No new OpenAPI file

**Decision**: Reuse `001-userinfo-sdk/contracts/userinfo.openapi.yaml`.

**Rationale**: Wire format unchanged.
