# Implementation Plan: Platform API Parity

**Branch**: `004-api-parity` | **Date**: 2026-09-17 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/004-api-parity/spec.md`

## Summary

Promote official SDKs from a single `GET /v1/userinfo` wrapper to
typed clients over the public Authdog API at api.authdog.com. Snapshot
the live OpenAPI catalog, assign all 266 operations to three waves,
and implement Wave 1 (56 operations: health, user-info, organizations,
tenants, projects, environment lifecycle, directory users/groups) in
every core SDK. Existing get-user-info signatures and the access-token
header rule stay unchanged; constructor `apiKey` becomes the
management Bearer credential it was reserved for.

## Technical Context

**Language/Version**: Same cores as 001/003 — Python ≥ 3.8 (CI 3.11),
Node 20 / TypeScript 5, Go 1.21, Rust 1.82, Java 11, .NET 8, Zig 0.14

**Primary Dependencies**: Unchanged HTTP/JSON stacks (httpx, axios,
net/http, reqwest, OkHttp, HttpClient, Zig std http). No new
frameworks. No OpenAPI codegen in Wave 1.

**Storage**: N/A (stateless clients). Feature artifacts store a dated
OpenAPI snapshot under `contracts/`.

**Testing**: Existing per-language suites plus new stub/contract tests
per Wave 1 method (success, empty list, 401, generic HTTP error,
transport failure)

**Target Platform**: Published server-side client libraries

**Project Type**: Multi-language library monorepo

**Performance Goals**: Unchanged — one HTTP request per public method,
10s default timeout on owned clients

**Constraints**: Thin clients only (Constitution VII). Do not break
get-user-info. Do not wrap Console GraphQL. Do not promote `planned/`
SDKs. Coordinate a 0.x MINOR across cores when Wave 1 ships.
Tokens and one-time secrets are never logged.

**Scale/Scope**: 266 public operations in the 2026-09-17 snapshot; 56
in Wave 1 across 7 core SDKs; 58 Wave 2 and 152 Wave 3 specified but
not required to implement in the first release train

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status |
|-----------|--------|
| I. Parity | Pass — Wave 1 ships in every core SDK together |
| II. Single API surface | Pass — catalog lands in `contracts/` first; no SDK-only paths |
| III. Structured errors | Pass — reuse 401 / API / base taxonomy; user-info 500 strings unchanged |
| IV. Contract tests | Pass — FR-015 test matrix per new method |
| V. Idiomatic packaging | Pass — resource namespaces; user-info stays on the root client |
| VI. SemVer | Pass — additive MINOR on 0.x; no required constructor args |
| VII. Simplicity | Pass — shared request helper, no retry/codegen framework |
| Security: access token wins | Pass — user-info rule unchanged; management uses constructor credential |

Post-design: no unjustified violations. Constitution II’s “until a
second endpoint is specified” clause is fulfilled by this feature’s
contracts. A later constitution PATCH may drop that sentence; it is
not required to implement Wave 1.

## Project Structure

### Documentation (this feature)

```text
specs/004-api-parity/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── checklists/requirements.md
├── contracts/
│   ├── openapi.snapshot.json      # live catalog, 2026-09-17
│   ├── operation-inventory.md     # 266 ops → waves
│   └── wave1-operations.json      # Wave 1 method/path index
└── tasks.md                       # created by /speckit-tasks
```

### Source Code (repository root)

```text
python/authdog/client.py
python/authdog/types.py            # add Wave 1 models
python/authdog/resources/          # optional namespaces
python/tests/
node/src/client.ts
node/src/types.ts
node/tests/
go/client.go
go/types.go
go/client_test.go
rust/src/client.rs
rust/src/types.rs
rust/tests/
java/src/main/java/com/authdog/
java/src/test/java/com/authdog/
csharp/AuthdogClient.cs
csharp/Types/
csharp/Tests/
zig/src/client.zig
zig/src/                          # add models as needed
README.md                         # stop claiming single-endpoint
python/README.md                  # and each core README
node/README.md
go/README.md
rust/README.md
java/README.md
csharp/README.md
zig/README.md
```

**Structure Decision**: Extend the existing language trees. Extract a
private request helper in each client; expose Wave 1 through resource
namespaces (`organizations`, `tenants`, `projects`, `environments`,
`users`, `groups`) plus root `getUserInfo` / `health`. Do not add a
new package or codegen crate in Wave 1.

## Complexity Tracking

No constitution violations. Nested resource namespaces are idiomatic
packaging (Principle V), not a second API surface: each method is a
1:1 catalog operation.
