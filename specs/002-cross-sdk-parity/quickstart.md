# Quickstart: Validate parity hardening

**Date**: 2026-09-10  
**Feature**: `002-cross-sdk-parity`

## Prerequisites

```bash
proto use
```

## Header precedence (US1)

In Go, Rust, Java, and C# tests, construct a client with `apiKey` set
and call get-user-info with a different access token. The stub MUST
see `Authorization: Bearer <access-token>` only.

```bash
cd go && go test -count=1 -run 'API_Key|ApiKey'
cd rust && cargo test test_get_user_info_prefers_access_token
cd java && mvn test -Dtest=AuthdogClientTest#testGetUserInfoWithApiKey
cd csharp && dotnet test --filter GetUserInfoAsync_WithApiKey
```

## Typed errors (US2)

```bash
cd go && go test -count=1 -run 'IsAuthdogError|Request_Error'
cd rust && cargo test error_test
```

Expect `IsAuthdogError(authErr) == true` and Rust
`err.is_authentication()` after a 401.

## Python models + timeout (US3, US4)

```bash
cd python && python -m pytest tests/test_types.py tests/test_client.py -q
```

`get_userinfo` returns an object with `user.display_name`. Default
`client.timeout` is `10.0`.

## Docs (US5)

Open `CONTRIBUTING.md`: core paths are `python/`, `node/`, `go/`,
`rust/`, `java/`, `csharp/`; incubations are under `planned/`.

## Full core suite

```bash
moon run :test
```
