# Authdog SDK Constitution

## Core Principles

### I. Cross-Language Behavioral Parity

Every official SDK MUST expose the same product behavior for the same
operation: same HTTP method and path, same request headers for that
operation, same success payload shape, and the same error classes for
401, 5xx, and transport failures. Language-idiomatic naming is allowed
(`get_userinfo` vs `GetUserInfoAsync`); semantic differences are not.
A behavior change in one core SDK MUST be reflected in the others in
the same release train, or documented as a temporary exception in
`specs/`.

Rationale: integrators switch languages; surprises between SDKs become
production incidents.

### II. Single Shared API Surface

SDKs wrap Authdog HTTP APIs. They MUST NOT invent parallel resource
models or extra network hops. New endpoints land in
`specs/*/contracts/` first, then in every core SDK. Until a second
endpoint is specified, the only required operation is
`GET /v1/userinfo` with `Authorization: Bearer <access-token>`.

Rationale: the monorepo exists to keep clients aligned with one
platform contract, not six private dialects.

### III. Structured, Catchable Errors

Public errors MUST form a hierarchy: a base Authdog error, an
authentication error for HTTP 401, and an API error for other HTTP
and transport failures. Callers MUST be able to distinguish those
cases without parsing message strings. Typed languages MUST preserve
that distinction at the type level (exceptions, error types, or
result enums). Message text for the known 401 and 500 cases MUST stay
stable across SDKs:

- 401: `Unauthorized - invalid or expired token`
- 500 `{"error":"GraphQL query failed"}`: `GraphQL query failed`
- 500 `{"error":"Failed to fetch user info"}`: `Failed to fetch user info`

Rationale: application code branches on error class, not wording — but
wording is part of the current public contract and MUST stay aligned.

### IV. Test-First Contract Coverage (NON-NEGOTIABLE)

Every public method MUST have tests for: constructor/config, success
`200` parse, `401`, the two known `500` bodies, a generic HTTP error,
and a transport/network failure. New behavior MUST add or update those
tests before or with the implementation. Core SDKs MUST run in CI on
`push`/`pull_request` to `main` and `develop` when their paths change.

Rationale: parity only holds if the contract is executable.

### V. Idiomatic Packaging, Common Shape

Each SDK MUST follow its language's packaging, naming, and resource
conventions (Go `context`, Python context managers, Java
`AutoCloseable`, C# `IDisposable`/`async`, Rust `Result` + async).
The *shape* stays common: a client constructed with `baseUrl` and
optional `apiKey`/`timeout`, a user-info method that takes an access
token, a `close`/dispose path, and typed user-info models (Python is
currently behind and MUST catch up).

Rationale: feel native, behave identically.

### VI. Backward Compatibility & SemVer

Public package versions follow SemVer. Breaking changes (renames,
error-type splits, required new constructor args, payload field type
changes) require a MAJOR bump coordinated across published core SDKs.
Optional fields and new endpoints are MINOR. Bug fixes that restore
documented behavior without changing the public type surface are PATCH.
All core SDKs are currently `0.1.0`; while on 0.x, MINOR MAY include
breaks if the spec and changelog say so explicitly.

Rationale: published packages already document a contract.

### VII. Simplicity Over Framework

SDKs MUST stay thin HTTP clients. Do not add retry/auth middleware
frameworks, telemetry pipelines, or opinionated DI containers unless a
spec requires them. Prefer the language standard library or one
mainstream HTTP + JSON stack. Optional constructor injection of an
HTTP client is allowed where the ecosystem expects it (Go, C#).

Rationale: the value is a correct, typed `/v1/userinfo` call — not a
platform inside the client.

## Language Tiers

### Core SDKs

Python (`python/`), Node/TypeScript (`node/`), Go (`go/`), Rust
(`rust/`), Java (`java/`), and C# (`csharp/`) are **core**. They MUST
stay moon-orchestrated, CI-green, and at parity with the active specs.

### Planned SDKs

Implementations under `planned/` are **not** official until they:

1. Match the shared contract (including tests listed in Principle IV)
2. Have an enabled path-filtered GitHub Actions workflow
3. Are registered in `.moon/workspace.yml`
4. Are listed under Core in the root README

Incomplete trees at the repo root (for example leftover `c/` or
`kotlin/` build artifacts) MUST NOT be treated as published SDKs.

## Security & Tokens

- Access tokens and API keys MUST be sent only as
  `Authorization: Bearer <token>` and MUST NOT be logged, interpolated
  into User-Agent, or written to fixtures committed to git.
- For `GET /v1/userinfo`, the **access token argument wins**. A
  constructor `apiKey` MUST NOT replace or shadow that header on this
  call. If an SDK needs a distinct API-key header later, specify it
  first.
- Default timeout is 10 seconds where the language client supports it.
- User-Agent MUST be `authdog-<language>-sdk/<version>` (for example
  `authdog-python-sdk/0.1.0`).

## Development Workflow

- Task orchestration: [moon](https://moonrepo.dev/). Toolchains:
  [proto](https://moonrepo.dev/proto) via `.prototools`.
- Common commands: `moon check --all`, `moon run <sdk>:test`,
  `moon run <sdk>:lint`, `moon run <sdk>:build`.
- Commits use Conventional Commits (`feat:`, `fix:`, `docs:`, `test:`,
  `refactor:`).
- Branch prefixes: `feature/`, `fix/`, `docs/`, `refactor/`, `test/`.
- Each language follows its README plus CONTRIBUTING.md style rules
  (PEP 8, gofmt, rustfmt/clippy, Google Java, and so on).
- CONTRIBUTING.md MUST list directories that actually exist. Do not
  document planned SDKs as if they already live at the repo root.

## Governance

This constitution supersedes ad-hoc README or CONTRIBUTING guidance
when they conflict. Amendments:

1. Update this file and bump **Version** (MAJOR for removed/redefined
   principles, MINOR for new principles or material expansion, PATCH
   for clarification).
2. Set **Last Amended** to the change date.
3. If a principle change invalidates a spec, update that spec in the
   same change set.
4. Pull requests that add endpoints, change auth headers, or alter
   error mapping MUST cite the spec requirement they implement.

Reviews MUST check: contract tests exist, User-Agent/version strings
match the package version, and no core SDK is left on old behavior
without an explicit exception.

Runtime guidance for agents lives in `.specify/` templates and
`specs/`. Do not fork a second set of principles in chat.

**Version**: 1.0.0 | **Ratified**: 2026-09-10 | **Last Amended**: 2026-09-10
