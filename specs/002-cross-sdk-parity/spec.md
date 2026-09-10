# Feature Specification: Cross-SDK Parity Hardening

**Feature Branch**: `002-cross-sdk-parity`

**Created**: 2026-09-10

**Status**: Implemented

**Input**: Close the gaps found in the `001-userinfo-sdk` baseline
audit so every core SDK matches the constitution and the shared
user-info contract. No new Authdog endpoints.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Token is always the userinfo credential (Priority: P1)

A developer constructs a client with both an API key and later calls
get-user-info with a user access token. The platform receives the
access token, not the API key, on that request.

**Why this priority**: Go, Rust, and Java currently send the API key
instead. Apps that follow the README and pass both values authenticate
as the wrong principal.

**Independent Test**: Stub `/v1/userinfo` and assert the
`Authorization` header equals `Bearer <access-token>` when both
credentials are configured.

**Acceptance Scenarios**:

1. **Given** a client constructed with `apiKey=key-1`, **When**
   get-user-info is called with `accessToken=token-2`, **Then** the
   outgoing request has exactly one `Authorization` header and its
   value is `Bearer token-2`.
2. **Given** a client constructed without an API key, **When**
   get-user-info is called with `token-2`, **Then** the header is
   `Bearer token-2`.
3. **Given** C# with a default API-key header, **When** get-user-info
   runs, **Then** the request does not attempt to add a second
   Authorization header and still sends the access token.

---

### User Story 2 - Errors stay typed after return (Priority: P1)

A Go or Rust developer matches on authentication vs API failure
without reading message strings.

**Why this priority**: Constitution III; current helpers and `From`
impls hide the type.

**Independent Test**: Force 401 and 500; assert type checks
(`errors.As` / `IsAuthenticationError`, Rust enum or distinct error
types that survive `?`).

**Acceptance Scenarios**:

1. **Given** HTTP 401, **When** the caller inspects the error, **Then**
   they can detect authentication failure via type, not substring.
2. **Given** HTTP 500 GraphQL failure, **When** the caller inspects
   the error, **Then** they can detect API failure via type.
3. **Given** a transport failure, **When** the caller inspects the
   error, **Then** it is an API or base Authdog error, not a raw
   stdlib error that bypasses the taxonomy.

---

### User Story 3 - Python is a typed peer (Priority: P2)

A Python developer reads `user_info.user.display_name` (or an
equivalent documented mapping) with type hints, matching other cores.

**Why this priority**: README advertises type safety; Python is the
outlier.

**Independent Test**: Parse the shared sample payload into models;
`mypy` accepts attribute access.

**Acceptance Scenarios**:

1. **Given** HTTP 200 with the contract example, **When**
   `get_userinfo` returns, **Then** the value is a typed object (or
   TypedDict) exposing meta, session, and user fields.
2. **Given** existing dict-style tests and README samples, **When**
   the typed object is used, **Then** documented field names are
   available without breaking the 0.1.x import surface
   (`AuthdogClient`, exception names).

---

### User Story 4 - Timeouts and cleanup are consistent (Priority: P2)

A developer gets a 10 second default timeout in Python and C# without
supplying a custom HTTP client, and can still override it.

**Why this priority**: Constitution Security; two cores silently use
library defaults.

**Independent Test**: Inspect client configuration after construct
with no timeout argument.

**Acceptance Scenarios**:

1. **Given** no timeout argument, **When** a Python or C# client is
   constructed, **Then** the owned HTTP client’s timeout is 10
   seconds.
2. **Given** an explicit timeout, **When** the client is constructed,
   **Then** that value is used.

---

### User Story 5 - Docs and repo layout match reality (Priority: P3)

A contributor opening CONTRIBUTING.md sees the six core paths, Vitest
for Node, Python 3.8+, and `planned/` for incubating languages.

**Why this priority**: Wrong setup instructions waste reviews and CI.

**Independent Test**: Every directory named in CONTRIBUTING.md exists;
test commands match moon/README.

**Acceptance Scenarios**:

1. **Given** CONTRIBUTING.md, **When** a new contributor follows a
   language section, **Then** the folder and test runner exist.
2. **Given** leftover root `c/` or `kotlin/` build trees, **When**
   the repo is cloned from git, **Then** they are not presented as
   official SDKs (gitignored or removed; official C/Kotlin stay under
   `planned/` until promoted).

---

### Edge Cases

- Empty access token: clients SHOULD still send `Bearer ` and let the
  platform return 401 (current behavior); do not add local validation
  unless all six languages do it together.
- Custom HTTP client in Go/C#: timeout override on the wrapper MUST
  not silently replace a caller-supplied client.
- Rust error redesign MUST remain a `std::error::Error` and not break
  `AuthdogClient::new` / `get_user_info` signatures except via
  `Result` error type (allowed on 0.x if changelog notes it).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Go, Rust, Java, and C# MUST send the get-user-info
  access token as the sole `Authorization` header (001 FR-003).
- **FR-002**: Tests in those four SDKs MUST cover “apiKey set +
  access token sent” (missing today).
- **FR-003**: Go `IsAuthdogError` MUST be true for authentication and
  API errors (embed or wrap `AuthdogError`).
- **FR-004**: Rust MUST expose a matchable error type so 401 and API
  failures are distinguishable after `get_user_info`.
- **FR-005**: Transport failures in Go and Rust MUST enter the
  published error taxonomy.
- **FR-006**: Python MUST ship typed user-info models aligned with
  `001` `data-model.md`.
- **FR-007**: Python and C# MUST default timeout to 10 seconds on the
  owned client.
- **FR-008**: CONTRIBUTING.md MUST be rewritten to match core vs
  planned layout, Vitest, and current language versions.
- **FR-009**: Root README MUST link to `specs/` / Spec Kit so future
  work starts from the baseline.
- **FR-010**: Do not promote any `planned/` SDK in this feature.
- **FR-011**: Shared sample payload from
  `001-userinfo-sdk/contracts/userinfo.openapi.yaml` SHOULD be reused
  as a fixture where practical.

### Key Entities

Same as `001-userinfo-sdk` data model. No new wire entities.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The 001 checklist “Access token wins” column is Y for
  all six cores.
- **SC-002**: Go and Rust callers can branch on auth vs API errors
  without string matching.
- **SC-003**: `moon run :test` (core projects) stays green.
- **SC-004**: A new contributor can identify official vs planned SDKs
  from CONTRIBUTING.md alone.
- **SC-005**: Python public return type of get-user-info is no longer
  an untyped `Dict[str, Any]` only.

## Assumptions

- 0.x allows error-type and Python return-type tightening if
  README/changelog call it out (Constitution VI).
- Constructor `apiKey` remains in the public API for default headers
  or future endpoints; this spec only fixes userinfo precedence.
- Planned language ports are unchanged except if they copy a bug we
  fix and a later spec promotes them.
- No new HTTP endpoints.

## Constitution Check (preview)

Implements Principles I, III, IV, V and the Security & Tokens rule
from constitution v1.0.0. Does not add a second API surface.
