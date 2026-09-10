# Implementation Plan: Cross-SDK Parity Hardening

**Branch**: `002-cross-sdk-parity` | **Date**: 2026-09-10 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-cross-sdk-parity/spec.md`

## Summary

Align the six core SDKs with constitution token and error rules: access
token always wins on `GET /v1/userinfo`; Go/Rust errors stay matchable;
Python returns typed models; Python/C# default to a 10s timeout;
contributor docs match the real tree. No new endpoints.

## Technical Context

**Language/Version**: Same cores as 001 (Python 3.8+/3.11 CI, Node 20,
Go 1.21, Rust 1.82, Java 11, .NET 8)

**Primary Dependencies**: Unchanged (httpx, axios, net/http, reqwest,
OkHttp, HttpClient). Python models use stdlib dataclasses only.

**Storage**: N/A

**Testing**: Existing per-language suites plus new header-precedence
and error-type assertions

**Target Platform**: Published client libraries

**Project Type**: Multi-language library monorepo

**Performance Goals**: Unchanged (single request, 10s default timeout)

**Constraints**: 0.x allows error/return-type tightening; keep public
constructor shapes; do not promote `planned/` SDKs

**Scale/Scope**: 4 clients with auth bugs, 2 error taxonomies, 1 new
Python module, 2 timeout defaults, 1 docs pass

## Constitution Check

| Principle | Status |
|-----------|--------|
| I. Parity | Restores header + timeout + types |
| II. Single API surface | Pass — still only `/v1/userinfo` |
| III. Structured errors | Go `IsAuthdogError` + Rust enum variants |
| IV. Contract tests | Header-precedence tests required |
| V. Idiomatic packaging | Python dataclasses; Rust enum; Go helpers |
| VI. SemVer | 0.1.x tightening; README notes |
| VII. Simplicity | No new frameworks |
| Security: access token wins | Primary gate for this feature |

Post-design: no unjustified violations.

## Project Structure

### Documentation (this feature)

```text
specs/002-cross-sdk-parity/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/          # reuses 001 OpenAPI; no new wire contract
└── tasks.md
```

### Source Code (repository root)

```text
go/client.go
go/errors.go
go/client_test.go
go/errors_test.go
rust/src/client.rs
rust/src/error.rs
rust/src/lib.rs
rust/tests/client_test.rs
rust/tests/error_test.rs
java/src/main/java/com/authdog/AuthdogClient.java
java/src/test/java/com/authdog/AuthdogClientTest.java
csharp/AuthdogClient.cs
csharp/Tests/AuthdogClientTests.cs
python/authdog/client.py
python/authdog/types.py          # new
python/authdog/__init__.py
python/tests/test_client.py
python/tests/test_types.py       # new
CONTRIBUTING.md
.gitignore
```

**Structure Decision**: Edit the existing language folders. Shared
payload remains `specs/001-userinfo-sdk/contracts/userinfo.openapi.yaml`.

## Complexity Tracking

No new constitution violations. Rust `AuthdogError` becomes an enum so
`?` preserves authentication vs API variants — required by Principle III;
keeping three separate structs that flatten on `From` was the rejected
simpler alternative.
