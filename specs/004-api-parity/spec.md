# Feature Specification: Platform API Parity

**Feature Branch**: `004-api-parity`

**Created**: 2026-09-17

**Status**: Waves 1–3 implemented

**Input**: Keep official SDKs at parity with the public Authdog
platform API at api.authdog.com, not only the current user-info call.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - One client for user-info and management (Priority: P1)

A backend developer who already constructs an Authdog client to fetch
the signed-in user can reuse that same client to call the public
management API. They set a management credential once on the client
and then list organizations, tenants, and directory users without
building raw HTTP requests. Fetching user-info with a user access
token still works exactly as it does today.

**Why this priority**: Today every official SDK wraps a single
user-info call. Platform docs already tell integrators that backend
SDKs are typed clients over `https://api.authdog.com/v1/...`. Without
a shared client and credential rule, each new family would invent its
own auth story.

**Independent Test**: Construct a client with a management credential;
stub health plus user-info; assert health uses the management
credential and user-info still sends the access-token argument.

**Acceptance Scenarios**:

1. **Given** a client constructed with a management credential,
   **When** the developer calls the health check, **Then** the client
   sends `GET /v1/health` with `Authorization: Bearer <management-credential>`
   (or no Authorization if the platform marks the call as public) and
   returns the liveness payload.
2. **Given** the same client also receives a user access token on
   get-user-info, **When** get-user-info runs, **Then** that request
   still sends only `Authorization: Bearer <access-token>` and the
   existing user-info payload and error messages are unchanged.
3. **Given** a management call returns HTTP 401, **When** the
   developer inspects the failure, **Then** they can detect
   authentication failure by type, not by reading the message string.
4. **Given** a management call returns any other non-success status
   with a JSON `error` field, **When** the developer inspects the
   failure, **Then** they receive an API failure that includes the
   status code and the platform error text.

---

### User Story 2 - Manage organizations and tenants (Priority: P1)

An administrator script creates an organization, lists the caller's
tenants, creates a tenant, and reads it back. Membership, invitations,
domain verification, seats, and tenant-organization linking work
through the same client.

**Why this priority**: Tenants and organizations are the first
resource family in the public API reference. They are the project
boundary every later directory or environment call sits under.

**Independent Test**: Stub the organization and tenant collection
endpoints; create, list, get, update, and delete each; assert method,
path, and mapped fields.

**Acceptance Scenarios**:

1. **Given** a valid management credential, **When** the developer
   lists organizations, **Then** they receive the organization
   collection and total count from the platform.
2. **Given** a create-organization payload with at least a name,
   **When** they create an organization, **Then** the client returns
   the created organization and sent `POST /v1/organizations`.
3. **Given** an organization id, **When** they get, update, or delete
   it, **Then** the client uses `/v1/organizations/{id}` with PATCH
   for update and DELETE for removal.
4. **Given** the same credential, **When** they list, create, get,
   update, or delete tenants, **Then** the client uses `/v1/tenants`
   and `/v1/tenants/{id}` and returns tenant fields including id,
   name, active, and timestamps.
5. **Given** organization members, invitations, join/accept, tenant
   link/unlink, tenant domains, seats, and invites, **When** those
   operations are called, **Then** each uses the matching public
   path from the platform catalog and returns the documented
   resource.

---

### User Story 3 - Manage projects, environments, and the directory (Priority: P1)

A developer provisions an application environment, then creates and
looks up users and groups in that environment. They can search users,
toggle active state, and maintain group membership.

**Why this priority**: Directory and environment lifecycle are the
operations backend docs describe as “read users, organizations, and
more.” This is the first wave that makes the SDK a management client,
not only a session-profile helper.

**Independent Test**: Stub project, environment, user, and group
endpoints; exercise list/get/create/update/delete plus user search
and group membership; assert paths and typed fields.

**Acceptance Scenarios**:

1. **Given** a tenant id, **When** the developer saves, gets, or
   deletes a project (application) or sets its default environment,
   **Then** the client uses `/v1/tenants/{tenantId}/applications`
   routes.
2. **Given** a tenant and application id, **When** they list or
   create environments, **Then** the client uses
   `/v1/tenants/{tenantId}/applications/{applicationId}/environments`.
3. **Given** a tenant and environment id, **When** they update or
   delete that environment, **Then** the client uses
   `/v1/tenants/{tenantId}/environments/{environmentId}`.
4. **Given** a tenant and environment id, **When** they list, create,
   get, update, delete, search, or count users, or set a user active,
   **Then** the client uses the matching `/users` routes and returns
   directory user fields (id, user name, display name, emails,
   active).
5. **Given** a user id, **When** they list that user's groups,
   **Then** the client returns the group collection for that user.
6. **Given** a tenant and environment id, **When** they list, create,
   or delete groups, or list/add/remove members, **Then** the client
   uses the public group routes (including `POST /v1/groups` for
   create) and returns group id, name, and membership results.

---

### User Story 4 - Authorize and observe activity (Priority: P2)

A security engineer assigns roles and permissions in an environment,
then reads audit logs and the identity event stream, and registers a
notification channel or webhook so their backend is told when users
sign in.

**Why this priority**: Access control and activity are the remaining
“core resource families” in the public API reference. They are not
required to prove the management client works, but they are required
for platform parity.

**Independent Test**: Stub one role, one audit list, one event list,
and one webhook create; assert paths and that create responses which
include a one-time secret surface that secret to the caller.

**Acceptance Scenarios**:

1. **Given** an environment, **When** the developer lists or creates
   roles, permissions, or resources, assigns permissions to a role,
   or assigns roles to a group, **Then** the client uses the public
   RBAC routes.
2. **Given** an environment, **When** they query audit logs or the
   event stream, **Then** they receive the platform pages/cursors
   without the client dropping documented query parameters.
3. **Given** a webhook or notification-channel create, **When** the
   platform returns a signing secret once, **Then** the client
   exposes that secret on the create/rotate result and does not
   invent a later read of the raw secret.

---

### User Story 5 - Machine credentials and specialized surfaces (Priority: P3)

A platform operator issues service accounts, personal access tokens,
environment API secrets, and organization keys. Later they also call
AuthZEN decisions, SCIM/HRIS provisioning, the MCP trust store, and
the remaining environment configuration families from the same
catalog.

**Why this priority**: These families complete parity with
api.authdog.com. They use additional credential kinds or
specification-fixed paths, so they ship after the management client
shape is stable.

**Independent Test**: For each remaining family in the catalog,
calling the generated or hand-written method hits the documented
method and path; AuthZEN discovery remains unauthenticated.

**Acceptance Scenarios**:

1. **Given** a management credential, **When** the developer creates
   a service account, PAT, environment API secret, or organization
   key, **Then** the one-time secret/token value is returned on that
   response.
2. **Given** an environment API secret, **When** they evaluate an
   AuthZEN decision, **Then** the client calls
   `POST /access/v1/evaluation` (not a `/v1/...` rewrite) and
   discovery uses `GET /.well-known/authzen-configuration` without a
   bearer token.
3. **Given** a SCIM or HRIS provisioning token, **When** they
   provision users/groups or employees/departments, **Then** the
   client uses `/v1/scim/v2` or `/v1/hris/v1` and sends that token
   as Bearer.
4. **Given** any other public family in the catalog (environment
   settings, email providers, vanity domains, threats, elevate, MCP
   trust store, billing, widgets, portal, impersonation, OIDC
   clients, forms, add-ons, feature flags, actions, OpenTelemetry,
   connections), **When** that family is implemented, **Then** it
   matches the catalog entry and is not a private SDK-only path.

---

### Edge Cases

- Get-user-info must not send the constructor management credential
  when an access token argument is provided (existing rule).
- Health is public; the client must not fail construction or the
  call if no management credential is configured.
- Empty list responses (`organizations: []`, `users: []`) must parse
  as empty collections, not as a missing-resource error.
- Unknown JSON fields on success bodies must be ignored so newer
  platform fields do not break older SDKs.
- Create/rotate responses that include a one-time secret must expose
  it; later list/get responses that only include `*Configured`
  booleans must not invent a secret value.
- Directory user-info (session profile) and directory EnvUser
  (management user) are different resources; mapping one onto the
  other is out of scope.
- Bulk user import/delete, MFA disable, and session revoke are not
  part of Wave 1 even though they sit next to user CRUD.
- Environment connections, redirect URIs, and SSO metadata are not
  part of Wave 1.
- Console GraphQL is unsupported; SDKs must not add a second
  unpublished API.
- Invalid JSON on HTTP 200 must surface as an API/parse error.
- Path parameters and query parameters from the catalog must be
  sent as specified; the client must not collapse tenant/environment
  ids into headers unless the catalog says so.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Every official core SDK MUST remain a typed client over
  the public Authdog HTTP API. New operations MUST match the method,
  path, request fields, and success shape in the platform catalog
  snapshotted for this feature.
- **FR-002**: The platform catalog is the public OpenAPI document
  served at `https://api.authdog.com/v1/openapi` (rendered at
  `https://api.authdog.com`). This feature MUST keep a dated snapshot
  of that catalog in `specs/004-api-parity/contracts/`.
- **FR-003**: Every operation in that snapshot MUST be assigned to
  Wave 1, Wave 2, or Wave 3 in the feature inventory. Unassigned
  public operations are a defect.
- **FR-004**: Wave 1 MUST include: health; existing user-info
  (unchanged); all organization operations; all tenant operations;
  all project operations; environment list/create/update/delete;
  directory user list/create/get/update/delete/search/count/
  set-active and user-groups list; directory group
  list/create/delete and member list/add/remove.
- **FR-005**: Wave 2 MUST include RBAC, audit, events, webhooks,
  notification channels, service accounts, personal access tokens,
  environment API secrets, and organization keys.
- **FR-006**: Wave 3 MUST include every remaining snapshot
  operation, including AuthZEN, SCIM, HRIS, MCP trust store,
  elevate, environment settings and connections, and the other
  families listed in User Story 5.
- **FR-007**: Get-user-info MUST keep the current credential rule:
  the access-token argument is the sole `Authorization` value for
  that call. Constructor management credentials MUST NOT replace it.
- **FR-008**: Management operations in Waves 1–2 MUST authenticate
  with the constructor management credential as
  `Authorization: Bearer <credential>` unless the catalog marks the
  operation public.
- **FR-009**: When Wave 3 families that use a different credential
  kind ship (environment secret, SCIM token, HRIS token), those
  operations MUST send that credential as Bearer and MUST document
  which constructor or per-call field supplies it.
- **FR-010**: HTTP 401 on any wrapped operation MUST map to an
  authentication error. Other HTTP failures and transport failures
  MUST map to an API or base Authdog error. Callers MUST distinguish
  those cases by type. User-info’s two known HTTP 500 message
  strings MUST stay stable.
- **FR-011**: Management error bodies that include `error` MUST
  surface that string on the API error. Status code MUST remain
  available to the caller.
- **FR-012**: Success payloads MUST be available as first-class
  fields in typed languages. Wire names stay camelCase; language
  bindings MAY rename in-process.
- **FR-013**: Clients MUST send `User-Agent: authdog-<language>-sdk/<version>`
  and `Content-Type: application/json` on JSON requests.
- **FR-014**: Default timeout remains 10 seconds on owned HTTP
  clients. Close/dispose behavior from the baseline spec remains
  required.
- **FR-015**: Each new public method MUST have contract tests for
  success parse, 401, a generic HTTP error, and transport failure
  before or with the implementation. Collection methods MUST also
  cover an empty list.
- **FR-016**: One-time secrets returned on create or rotate MUST be
  readable on that response type. SDKs MUST NOT log those values.
- **FR-017**: Root and language READMEs MUST describe the client as
  covering the public platform API, list shipped families, and point
  at this spec for the full catalog. They MUST NOT keep claiming that
  user-info is the only wrapped endpoint once Wave 1 ships.
- **FR-018**: Planned-language ports and framework session
  middleware (route guards, cookie session resolvers) are out of
  scope.
- **FR-019**: This feature MUST NOT invent SDK-only paths, query
  names, or resource models. Optional convenience wrappers are
  allowed only when they call a catalog operation unchanged.
- **FR-020**: Wave 1 MUST ship across every core SDK in the same
  release train. Wave 2 and Wave 3 MAY follow in later releases of
  this program but MUST NOT appear in only a subset of core SDKs.

### Key Entities

- **Platform catalog**: Dated snapshot of the public OpenAPI
  document; source of methods, paths, and schemas.
- **Wave**: Delivery slice that groups catalog operations so a
  smaller set can ship at parity.
- **Management credential**: Constructor bearer token used for
  public `/v1` management calls (reserved `apiKey` in today’s
  clients).
- **User access token**: Per-call credential for get-user-info.
- **Organization**: Customer organization with name, optional
  billing email and logo, active flag, members, invitations, and
  linked tenants.
- **Tenant**: Project boundary with name, optional company and
  description, domains, seats, and projects.
- **Project (application)**: Application under a tenant, with
  environments and a default environment.
- **Environment**: Deployment boundary used on most directory and
  policy routes.
- **Directory user (EnvUser)**: Managed user in an environment
  (distinct from the user-info session profile).
- **Directory group**: Named group in an environment with members.
- **User-info response**: Existing session-profile envelope
  (`meta`, `session`, `user`); unchanged.
- **Error taxonomy**: Base Authdog error, authentication error
  (401), API error (other HTTP and transport).
- **One-time secret**: Token or signing secret returned only on
  create/rotate.
- **AuthZEN decision**: Permit/deny evaluation on specification-
  fixed `/access/v1` paths (Wave 3).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A developer who already fetches user-info can list
  organizations, tenants, and directory users with the same client
  and no extra HTTP helper, in under 20 lines of setup.
- **SC-002**: Existing get-user-info callers require zero source
  changes after Wave 1 ships.
- **SC-003**: 100% of operations in the dated platform snapshot are
  assigned to Wave 1, 2, or 3 in the inventory.
- **SC-004**: Every Wave 1 operation is present in all official core
  SDKs with the same method, path, and credential rule.
- **SC-005**: At least 95% of Wave 1 contract tests (success, empty
  list where applicable, 401, generic HTTP error, transport failure)
  pass in each core SDK suite.
- **SC-006**: A reviewer can open this spec and the inventory and
  tell, without reading client source, which public families are
  shipped versus deferred.
- **SC-007**: After Wave 1, published docs no longer describe the
  SDKs as wrapping only user-info.

## Assumptions

- The live platform already serves the public REST catalog; SDKs do
  not implement identity storage or authorization decisions
  themselves.
- “Parity” means wrapping the public HTTP API, not cloning Authdog
  Console and not exposing internal GraphQL.
- Wave 1 is the required implementation for this feature. Waves 2
  and 3 are specified here so later work does not rediscover the
  catalog; they MAY be executed as later task batches or follow-on
  specs that reference this inventory without changing Wave 1
  behavior.
- Constructor `apiKey` is the management credential. No new required
  constructor argument is added in Wave 1.
- Default base URL stays caller-supplied. Documentation examples use
  `https://api.authdog.com`.
- Specialized credential prefixes (`adenv_`, `adscim_`, `adhris_`)
  apply when those families ship; Wave 1 does not require them.
- Session verification middleware advertised on Authdog backend docs
  (require-auth guards, cookie readers) is a separate product and
  is not added to this monorepo by this feature.
- Planned SDKs under `planned/` stay incubating.
- Package versions remain on 0.x; adding operations is a MINOR
  bump coordinated across core SDKs. Breaking user-info types is
  not allowed.
- Forward compatibility: ignore unknown JSON fields. Do not depend
  on undocumented properties.

## Constitution Check (preview)

Advances Principle II (new endpoints land in `specs/*/contracts/`
first) and keeps Principles I, III, IV, V, VI, and VII: same
behavior in every core SDK, structured errors, contract tests, thin
HTTP clients, SemVer-safe additions. Security rule for user-info
(access token wins) is unchanged; management calls use the
constructor credential that was reserved for this purpose.
