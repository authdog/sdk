# Feature Specification: Authdog User Info SDK

**Feature Branch**: `001-userinfo-sdk`

**Created**: 2026-09-10

**Status**: Baseline (implemented; drift recorded in `research.md`)

**Input**: Brownfield audit of the Authdog SDK monorepo — document the product that already exists so later specs can improve it without guessing.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Fetch the signed-in user (Priority: P1)

A backend or script developer constructs an Authdog client with the
platform base URL, then asks for the current user by passing the user's
access token. They receive profile data (identity, names, emails,
photos, verification status, provider, environment) plus session
remaining time.

**Why this priority**: This is the only shipped operation. Every core
SDK exists to perform it.

**Independent Test**: Point the client at a stub that returns a valid
`200` JSON body; assert the mapped user id, display name, and first
email.

**Acceptance Scenarios**:

1. **Given** a client configured with a valid base URL and a stub that
   returns HTTP 200 with a full user-info payload, **When** the
   developer calls get-user-info with a bearer access token, **Then**
   the client returns that payload (typed where the language supports
   it) and sent `GET {baseUrl}/v1/userinfo` with
   `Authorization: Bearer <access-token>`.
2. **Given** a base URL that ends with `/`, **When** the client is
   constructed, **Then** the trailing slash is not doubled on the
   request path.

---

### User Story 2 - Handle auth and platform failures (Priority: P1)

The same developer must distinguish "token rejected" from "platform
failed" from "network failed" so they can refresh a session, retry, or
surface an error.

**Why this priority**: Without structured errors the SDK is a thin
HTTP wrapper that leaks status codes into every app.

**Independent Test**: Drive 401, 500 (both known bodies), 404, and a
connection failure through the client; assert error types and messages.

**Acceptance Scenarios**:

1. **Given** the platform returns HTTP 401, **When** get-user-info is
   called, **Then** the client raises/returns an authentication error
   with message `Unauthorized - invalid or expired token`.
2. **Given** the platform returns HTTP 500 with
   `{"error":"GraphQL query failed"}`, **When** get-user-info is
   called, **Then** the client raises/returns an API error with
   message `GraphQL query failed`.
3. **Given** the platform returns HTTP 500 with
   `{"error":"Failed to fetch user info"}`, **When** get-user-info is
   called, **Then** the client raises/returns an API error with
   message `Failed to fetch user info`.
4. **Given** any other non-success HTTP status, **When** get-user-info
   is called, **Then** the client raises/returns an API error that
   includes the status code.
5. **Given** the request cannot be completed (timeout, DNS, reset),
   **When** get-user-info is called, **Then** the client raises/returns
   an API (or base) error, not an untyped language runtime error.

---

### User Story 3 - Configure the client (Priority: P2)

A developer sets an optional API key, optional timeout, and (where
idiomatic) a custom HTTP client. They can release connections when
finished.

**Why this priority**: Needed for production embedding; not required
to prove the happy path.

**Independent Test**: Construct with and without api key / timeout;
assert default headers and default 10s timeout where supported.

**Acceptance Scenarios**:

1. **Given** an API key in the constructor, **When** the client is
   created, **Then** default headers MAY include
   `Authorization: Bearer <api-key>`, but get-user-info MUST still
   send the access-token bearer header (access token wins).
2. **Given** no timeout is provided, **When** the client is created,
   **Then** the HTTP timeout is 10 seconds in languages that expose
   one.
3. **Given** the developer is done, **When** they close/dispose/exit a
   context manager, **Then** owned HTTP resources are released (or the
   method is a documented no-op).

---

### User Story 4 - Consume types in a typed language (Priority: P2)

A TypeScript, Go, Rust, Java, or C# developer reads `user.displayName`,
`user.emails[0].value`, `session.remainingSeconds`, and verification
flags without hand-parsing JSON.

**Why this priority**: Type safety is a stated product feature. Python
currently returns a dict and is a known gap.

**Independent Test**: Deserialize the shared sample payload and read
nested fields without extra parsing.

**Acceptance Scenarios**:

1. **Given** a successful response, **When** the developer inspects
   the result, **Then** `meta`, `session`, and `user` (including
   names, photos, emails, verifications) are available as first-class
   fields.
2. **Given** nullable profile fields (`nickName`, `title`, `timezone`,
   email `type`), **When** the JSON value is null, **Then** the
   binding is null/optional, not a crash.

---

### Edge Cases

- Empty `emails`, `photos`, `verifications`, `phoneNumbers`, or
  `addresses` arrays MUST parse as empty lists, not null, unless the
  JSON field is omitted and the language default is empty.
- `phoneNumbers` and `addresses` have no published schema; clients
  MUST accept arbitrary JSON array elements.
- Unknown JSON fields SHOULD be ignored (forward compatible) where
  the deserializer allows it.
- Invalid JSON on HTTP 200 MUST surface as an API/parse error, not a
  successful empty user.
- Concurrent use of one client instance is unspecified except where
  the language HTTP stack documents thread safety.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Each core SDK MUST provide a client constructed with a
  required Authdog base URL.
- **FR-002**: The client MUST expose a get-user-info operation that
  issues `GET /v1/userinfo` relative to that base URL.
- **FR-003**: Get-user-info MUST send
  `Authorization: Bearer <access-token>` using the token argument,
  not a constructor API key, for this call.
- **FR-004**: Requests MUST send `Content-Type: application/json` and
  `User-Agent: authdog-<language>-sdk/<package-version>`.
- **FR-005**: HTTP 200 MUST return the user-info resource described in
  Key Entities (typed in TS/Go/Rust/Java/C#; Python MAY still return
  `dict` until the parity spec ships).
- **FR-006**: HTTP 401 MUST map to an authentication error with the
  stable message in the constitution.
- **FR-007**: HTTP 500 with the two known `error` strings MUST map to
  an API error with those exact messages.
- **FR-008**: All other HTTP failures MUST map to an API error that
  includes the status code.
- **FR-009**: Transport failures MUST map to an API or base Authdog
  error.
- **FR-010**: Authentication and API errors MUST be subtypes/wrappers
  of a base Authdog error in languages that support hierarchies.
- **FR-011**: Constructor MAY accept an optional API key and optional
  timeout (default 10s).
- **FR-012**: Constructor MAY accept a caller-supplied HTTP client in
  Go and C#.
- **FR-013**: Client MUST offer a close/dispose path; Python and Java
  MUST support context-manager / try-with-resources.
- **FR-014**: C# MUST offer both async and sync get-user-info.
- **FR-015**: Go MUST accept `context.Context` on get-user-info.
- **FR-016**: Node and Rust MUST expose get-user-info as async.
- **FR-017**: Package version across core SDKs is `0.1.0` until a
  coordinated bump.
- **FR-018**: Core SDKs MUST ship README usage for construct +
  get-user-info + error handling.

### Key Entities

- **UserInfoResponse**: Top-level envelope with `meta`, `session`,
  `user`.
- **Meta**: Numeric `code` and `message` from the platform.
- **Session**: `remainingSeconds` until the current session lapses.
- **User**: Platform identity (`id`, `externalId`, `userName`,
  `displayName`, optional profile fields, `locale`, `active`,
  `provider`, `environmentId`, timestamps) plus nested collections.
- **Names**: Structured name parts (`familyName`, `givenName`,
  optional middle/honorific/`formatted`).
- **Email**: `id`, `value`, optional `type`.
- **Photo**: `id`, `value`, `type`.
- **Verification**: Email verification record (`email`, `verified`,
  timestamps).
- **AuthdogError / AuthenticationError / APIError**: Public error
  taxonomy (Java/C# use `*Exception` / `ApiException` names).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A developer following any core README can retrieve user
  info with fewer than 15 lines of setup (construct, call, read
  display name).
- **SC-002**: All six core SDK unit suites cover the FR-005–FR-009
  status mapping cases.
- **SC-003**: The six core CI workflows stay path-filtered and
  required for merges that touch those trees.
- **SC-004**: A shared sample payload (see `contracts/`) deserializes
  in every typed core SDK without custom adapters.
- **SC-005**: Known gaps versus this spec are listed in `research.md`
  and scheduled in `002-cross-sdk-parity`, not silently accepted.

## Assumptions

- The Authdog platform already serves `GET /v1/userinfo`; SDKs do not
  implement identity storage.
- Access tokens are obtained outside this SDK (OAuth/OIDC or
  Authdog-hosted login). Constructor `apiKey` is reserved for future
  or default-header use and MUST NOT override userinfo bearer tokens.
- `phoneNumbers` and `addresses` remain opaque until a later spec.
- Planned languages under `planned/` are out of scope for this
  baseline except as evidence of intended shape.
- Root `c/` and `kotlin/` trees observed during the audit are not
  official packages.

## Audit Snapshot (2026-09-10)

Implemented at repo root: `python/`, `node/`, `go/`, `rust/`,
`java/`, `csharp/`. Orchestrated by moon. All advertised as wrapping
a single endpoint. See `plan.md` for stacks and `research.md` for
per-language drift.
