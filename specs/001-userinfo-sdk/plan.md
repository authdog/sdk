# Implementation Plan: Authdog User Info SDK

**Branch**: `001-userinfo-sdk` | **Date**: 2026-09-10 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-userinfo-sdk/spec.md`

**Note**: Brownfield plan. This records the architecture that already
ships. New work that changes behavior belongs in
`specs/002-cross-sdk-parity/` (or a later spec), not as silent edits
here.

## Summary

Six official HTTP client libraries call `GET /v1/userinfo` with a
bearer access token, map JSON into a shared user-info model, and
translate 401 / known 500 / other failures into a three-type error
taxonomy. moon + proto orchestrate deps, test, lint, and build. This
plan is the as-is technical baseline.

## Technical Context

**Language/Version**:

| SDK | Language | Toolchain (repo) |
|-----|----------|------------------|
| `python/` | Python ≥ 3.8 (CI 3.11.10) | proto `python` |
| `node/` | TypeScript 5 / Node ≥ 16 (CI 20.18.0) | pnpm 9.15.0 |
| `go/` | Go 1.21 | proto `go` 1.21.13 |
| `rust/` | Rust 2021 edition (CI 1.82.0) | proto `rust` |
| `java/` | Java 11 | Maven, Temurin in CI |
| `csharp/` | .NET 8 / C# 11 | `setup-dotnet` 8.0.x |

**Primary Dependencies**:

| SDK | HTTP | JSON |
|-----|------|------|
| Python | httpx ≥ 0.24 | stdlib `response.json()` |
| Node | axios ^1.6 | axios |
| Go | `net/http` | `encoding/json` |
| Rust | reqwest 0.11 | serde / serde_json |
| Java | OkHttp 4.12 | Jackson 2.16 |
| C# | `HttpClient` | Newtonsoft.Json 13 |

**Storage**: N/A (stateless clients)

**Testing**: pytest, vitest, `go test`, cargo test + wiremock, JUnit 5,
xUnit/NUnit-style C# tests under `csharp/Tests/`

**Target Platform**: Library consumers — server, CLI, and desktop
runtimes. Not a browser-first SDK (Node uses axios, not `fetch`).

**Project Type**: Multi-language library monorepo

**Performance Goals**: Single request, default 10s timeout. Go exposes
benchmarks; Java moon task can run JMH-named tests.

**Constraints**: No extra Authdog endpoints. MIT license. User-Agent
identifies language + `0.1.0`. Tokens never logged.

**Scale/Scope**: 6 core packages + 17 planned language trees + 22
GitHub Actions workflows (core enabled; most planned workflows are
manual or have path triggers commented out).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Baseline status |
|-----------|-----------------|
| I. Parity | Partial — see `research.md` (auth header, types, timeout) |
| II. Single API surface | Pass — only `/v1/userinfo` |
| III. Structured errors | Partial — hierarchy exists; Go `IsAuthdogError` misses children; Rust flattens into `AuthdogError` |
| IV. Contract tests | Partial — all cores test 200/401/500; coverage depth varies |
| V. Idiomatic packaging | Pass for cores; Python models untyped |
| VI. SemVer | Pass — all `0.1.0` |
| VII. Simplicity | Pass — thin clients |
| Security: access token wins | **Fail** in Go, Rust, Java (and C# default-header interaction) |

Phase 1 does not close those gates; `002-cross-sdk-parity` does.

## Project Structure

### Documentation (this feature)

```text
specs/001-userinfo-sdk/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── userinfo.openapi.yaml
└── checklists/
    └── baseline-audit.md
```

### Source Code (repository root)

```text
python/authdog/          # client.py, exceptions.py
node/src/                # client.ts, types.ts, exceptions.ts
go/                      # client.go, types.go, errors.go
rust/src/                # client.rs, types.rs, error.rs
java/src/main/java/com/authdog/
csharp/                  # AuthdogClient.cs, Types/, Exceptions/
planned/{c,cpp,clojure,commonlisp,dart,elixir,fsharp,kotlin,
         ocaml,php,powershell,r,ruby,scala,swift,zig}/
.moon/                   # workspace.yml, toolchain.yml
.github/workflows/       # per-language CI
.specify/                # Spec Kit (this process)
```

**Structure Decision**: Language-folder monorepo. Core SDKs at the
root; incubating ports in `planned/`. moon project ids match folder
names (`python`, `node`, `go`, `rust`, `java`, `csharp`).

## Phase 0 / 1 Artifacts

Already produced from the 2026-09-10 audit:

- `research.md` — parity findings and decisions
- `data-model.md` — shared entities
- `contracts/userinfo.openapi.yaml` — HTTP contract
- `quickstart.md` — how to run existing clients
- `checklists/baseline-audit.md` — language scorecard

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Six published languages | Product is a multi-language SDK org | A single language would drop existing published package names |
| Planned/ tree of 17 extra languages | Incubation without implying official support | Deleting them loses ports that already have tests |
| Constructor `apiKey` plus per-call token | Already in every public README | Removing `apiKey` is a breaking 0.x change; parity spec will define precedence instead |
