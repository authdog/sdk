# Feature Specification: Zig Core SDK

**Feature Branch**: `003-zig-core-sdk`

**Created**: 2026-09-12

**Status**: Draft

**Input**: Add Zig to the official core SDKs so Zig developers get the
same user-info product as the other published languages.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Fetch the signed-in user from Zig (Priority: P1)

A Zig backend or systems developer constructs an Authdog client with
the platform base URL, then asks for the current user by passing the
user's access token. They receive profile data (identity, names,
emails, photos, verification status, provider, environment) plus
session remaining time.

**Why this priority**: This is the only shipped operation. A core SDK
exists to perform it.

**Independent Test**: Point the client at a stub that returns a valid
`200` JSON body; assert the mapped user id, display name, and first
email.

**Acceptance Scenarios**:

1. **Given** a client configured with a valid base URL and a stub that
   returns HTTP 200 with a full user-info payload, **When** the
   developer calls get-user-info with a bearer access token, **Then**
   the client returns that payload as typed fields and sent
   `GET {baseUrl}/v1/userinfo` with
   `Authorization: Bearer <access-token>`.
2. **Given** a base URL that ends with `/`, **When** get-user-info is
   called, **Then** the trailing slash is not doubled on the request
   path.

---

### User Story 2 - Handle auth and platform failures (Priority: P1)

The same developer must distinguish "token rejected" from "platform
failed" from "network failed" so they can refresh a session, retry, or
surface an error.

**Why this priority**: Constitution III; without structured errors the
SDK leaks status codes into every app.

**Independent Test**: Drive 401, 500 (both known bodies), 404, and a
connection failure through the client; assert error types and
messages.

**Acceptance Scenarios**:

1. **Given** the platform returns HTTP 401, **When** get-user-info is
   called, **Then** the client returns an authentication error with
   message `Unauthorized - invalid or expired token`.
2. **Given** the platform returns HTTP 500 with
   `{"error":"GraphQL query failed"}`, **When** get-user-info is
   called, **Then** the client returns an API error with message
   `GraphQL query failed`.
3. **Given** the platform returns HTTP 500 with
   `{"error":"Failed to fetch user info"}`, **When** get-user-info is
   called, **Then** the client returns an API error with message
   `Failed to fetch user info`.
4. **Given** any other non-success HTTP status, **When** get-user-info
   is called, **Then** the client returns an API error that includes
   the status code.
5. **Given** the request cannot be completed (timeout, DNS, reset),
   **When** get-user-info is called, **Then** the client returns an
   API or base Authdog error, not an untyped language runtime error.

---

### User Story 3 - Token is always the userinfo credential (Priority: P1)

A developer constructs a client with both an API key and later calls
get-user-info with a user access token. The platform receives the
access token, not the API key, on that request.

**Why this priority**: Same rule as the other cores after
`002-cross-sdk-parity`.

**Independent Test**: Stub `/v1/userinfo` and assert the
`Authorization` header equals `Bearer <access-token>` when both
credentials are configured.

**Acceptance Scenarios**:

1. **Given** a client constructed with an API key, **When**
   get-user-info is called with a different access token, **Then**
   the outgoing request has exactly one `Authorization` header and
   its value is `Bearer <access-token>`.

---

### User Story 4 - Official packaging and docs (Priority: P2)

A contributor opening the root README and CONTRIBUTING.md sees Zig
listed with the other official SDKs, can run the Zig test task from
the repo orchestrator, and can follow the Zig README to construct a
client in fewer than 15 lines.

**Why this priority**: Constitution Language Tiers — a port is not
official until it is listed, orchestrated, and on CI.

**Independent Test**: Zig lives at the repo-root SDK directory, is
registered in the workspace orchestrator, has a path-filtered CI
workflow on push/PR, and is removed from the incubating-language
list.

**Acceptance Scenarios**:

1. **Given** the root README, **When** a developer looks for official
   SDKs, **Then** Zig is listed with the other cores and not only
   under planned languages.
2. **Given** a change under the Zig tree, **When** a pull request
   targets `main` or `develop`, **Then** the Zig CI workflow runs.
3. **Given** the Zig README, **When** a developer copies the usage
   sample, **Then** they can construct a client, call get-user-info,
   and branch on authentication vs API failure.

---

### Edge Cases

- Empty `emails`, `photos`, `verifications`, `phoneNumbers`, or
  `addresses` arrays MUST parse as empty lists.
- Nullable profile fields (`nickName`, `title`, `timezone`, email
  `type`) MUST bind as null/optional when the JSON value is null.
- Unknown JSON fields SHOULD be ignored.
- Invalid JSON on HTTP 200 MUST surface as a parse/API error, not a
  successful empty user.
- Empty access token: the client SHOULD still send `Bearer ` and let
  the platform return 401 (same as the other cores).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Zig SDK MUST provide a client constructed with a
  required Authdog base URL.
- **FR-002**: The client MUST expose a get-user-info operation that
  issues `GET /v1/userinfo` relative to that base URL.
- **FR-003**: Get-user-info MUST send
  `Authorization: Bearer <access-token>` using the token argument,
  not a constructor API key.
- **FR-004**: Requests MUST send `Content-Type: application/json` and
  `User-Agent: authdog-zig-sdk/<package-version>`.
- **FR-005**: HTTP 200 MUST return a typed user-info resource
  (`meta`, `session`, `user` and nested collections).
- **FR-006**: HTTP 401 MUST map to an authentication error with the
  stable constitution message.
- **FR-007**: HTTP 500 with the two known `error` strings MUST map to
  an API error with those exact messages.
- **FR-008**: All other HTTP failures MUST map to an API error that
  includes the status code.
- **FR-009**: Transport failures MUST map to an API or base Authdog
  error.
- **FR-010**: Callers MUST be able to distinguish authentication vs
  API failure by type, not by parsing message strings.
- **FR-011**: Constructor MAY accept an optional API key and optional
  timeout (default 10 seconds).
- **FR-012**: Client MUST offer a close/dispose path that releases
  owned resources.
- **FR-013**: Package version is `0.1.0` until a coordinated bump.
- **FR-014**: The Zig SDK MUST ship README usage for construct +
  get-user-info + error handling.
- **FR-015**: Tests MUST cover constructor/config, success `200`,
  `401`, both known `500` bodies, a generic HTTP error, transport
  failure, and “apiKey set + access token sent”.
- **FR-016**: Zig MUST be registered as a core SDK (workspace
  orchestrator, path-filtered CI on push/PR to `main`/`develop`,
  listed under Core in the root README).
- **FR-017**: The incubating Zig tree MUST not remain the
  documented implementation after promotion.

### Key Entities

Same as `001-userinfo-sdk` data model. No new wire entities.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A developer following the Zig README can retrieve user
  info with fewer than 15 lines of setup (construct, call, read
  display name).
- **SC-002**: The Zig unit suite covers the FR-005–FR-009 status
  mapping cases plus access-token precedence.
- **SC-003**: Zig CI is path-filtered and required for merges that
  touch the Zig tree.
- **SC-004**: A new contributor can identify Zig as official from
  CONTRIBUTING.md and the root README alone.
- **SC-005**: `moon run zig:test` stays green.

## Assumptions

- The shared `GET /v1/userinfo` contract from `001-userinfo-sdk` and
  `002-cross-sdk-parity` is unchanged. This feature adds a language,
  not an endpoint.
- Zig get-user-info is synchronous (like Java). Async is not
  required.
- Default timeout is stored as 10 seconds even if the standard HTTP
  client cannot enforce a per-request deadline.
- Promoting Zig updates the constitution language-tier list (MINOR).
- Other planned languages stay incubating.

## Constitution Check

Implements Principles I–V and the Language Tiers promotion rules
from constitution v1.1.0. Does not add a second API surface.
