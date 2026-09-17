# Data Model: Platform API Parity

**Date**: 2026-09-17  
**Feature**: `004-api-parity`

Wire names are JSON camelCase. Full schemas live in
[`contracts/openapi.snapshot.json`](./contracts/openapi.snapshot.json).
User-info entities are unchanged; see
[`../001-userinfo-sdk/data-model.md`](../001-userinfo-sdk/data-model.md).

Language bindings MAY rename in-process (Python/Rust snake_case, C#
PascalCase) using the same convention as 002.

Unknown properties are ignored. Null catalog fields bind as
null/optional, not as a crash.

## Credentials

| Name | Where set | Used on |
|------|-----------|---------|
| Management credential | Constructor `apiKey` | Wave 1–2 `/v1` management calls |
| User access token | Get-user-info argument | `GET /v1/userinfo` only |
| Environment secret `adenv_` | Later constructor or per-call field | AuthZEN, MCP runtime (Wave 3) |
| SCIM token `adscim_` | Later field | `/v1/scim/v2` (Wave 3) |
| HRIS token `adhris_` | Later field | `/v1/hris/v1` (Wave 3) |

## Error taxonomy

Unchanged types from 001/002.

| Condition | Type | Notes |
|-----------|------|-------|
| HTTP 401 | Authentication error | User-info keeps message `Unauthorized - invalid or expired token` |
| Other HTTP | API error | Include status; copy body `error` when present |
| Transport / timeout / invalid JSON on 200 | API or base error | Not a raw stdlib error |
| User-info HTTP 500 known bodies | API error | Exact strings from constitution |

No per-resource error types in Wave 1.

## Probe (health)

| Field | Type | Required |
|-------|------|----------|
| ok | boolean | no (present on 200) |

Path: `GET /v1/health`. Public.

## Organization

| Field | Type | Required |
|-------|------|----------|
| id | string | yes |
| name | string | yes |
| description | string \| null | yes |
| billingEmail | string \| null | yes |
| logoUri | string \| null | yes |
| active | boolean | yes |
| createdAt | string | yes |
| updatedAt | string | yes |

**OrganizationsList**: `organizations: Organization[]`, `total: number`.

**OrganizationResponse**: `{ organization }`.

**CreateOrganizationRequest**: `name` required; optional
`description`, `billingEmail`, `tenantIds`.

Related Wave 1 entities (see snapshot): `OrganizationMember`,
`OrganizationInvitation`, `OrganizationKey` is Wave 2.

## Tenant

| Field | Type | Required |
|-------|------|----------|
| id | string | yes |
| name | string | yes |
| description | string \| null | yes |
| company | string \| null | yes |
| active | boolean | yes |
| createdAt | string | yes |
| updatedAt | string | yes |
| organizationIds | string[] | yes |

**TenantsList**: `tenants: Tenant[]`, `total: number`.

**CreateTenantRequest**: `name` required; optional `description`,
`company`.

Related Wave 1 entities: `TenantDomain`, `TenantSeat`,
`TenantProject`.

## Project (application)

Snapshot schema `Project` / `ProjectDetailsResponse`.

| Field | Type | Notes |
|-------|------|-------|
| id | string | Application id |
| name | string | |
| environments | Environment[] | On some envelopes |
| default environment | id via set-default route | `PUT .../default-environment` |

**ApplicationEnvironmentsResponse**: `project`, `environments[]`,
optional `meta`.

## Environment

| Field | Type | Required |
|-------|------|----------|
| id | string | yes |
| name | string | yes |
| description | string \| null | yes |
| weight | number \| null | yes |
| isLive | boolean \| null | yes |
| isDefault | boolean \| null | yes |
| createdAt | string \| null | yes |
| updatedAt | string \| null | yes |

Wave 1 verbs: list/create under
`/v1/tenants/{tenantId}/applications/{applicationId}/environments`;
update/delete at
`/v1/tenants/{tenantId}/environments/{environmentId}`.

## Directory user (EnvUser)

Distinct from user-info `User`.

| Field | Type | Required |
|-------|------|----------|
| id | string | yes |
| environmentId | string \| null | yes |
| externalId | string \| null | yes |
| userName | string \| null | yes |
| displayName | string \| null | yes |
| nickName | string \| null | yes |
| profileUrl | string \| null | yes |
| active | boolean \| null | yes |
| changePw | boolean \| null | no |
| provider | string \| null | yes |
| emails | EnvUserEmail[] | yes |
| lastLogin | string \| null | yes |
| createdAt | string \| null | yes |
| updatedAt | string \| null | yes |

**EnvUsersResponse**: `users`, optional `meta`.

**EnvUserResponse**: `{ user, meta? }`.

Empty `users` is a success.

## Directory group (EnvGroup)

| Field | Type | Required |
|-------|------|----------|
| id | string | yes |
| environmentId | string | yes |
| name | string | yes |
| slug | string | yes |
| description | string \| null | yes |
| memberCount | number | yes |
| joinedAt | string \| null | yes |
| createdAt | string | yes |
| updatedAt | string | yes |

**CreateGroupBody**: `environmentId` and `name` required; optional
`tenantId`, `slug`, `description`. Posted to `POST /v1/groups`.

## Management meta

Some write envelopes include `meta: ManagementMeta` with nullable
`ok` / `error` each `{ message, code }`. Bind it when present; do
not require it on list endpoints that omit it.

## Validation rules

- Path ids (`tenantId`, `environmentId`, `userId`, …) are opaque
  strings; clients do not format-check prefixes.
- Collection totals may be `0`.
- Create/update bodies follow the snapshot required arrays; do not
  send client-generated ids unless the catalog asks for them.
- Forward compatible: extra JSON keys ignored.

## State transitions

No client-side workflow. Active flags (`organization.active`,
`tenant.active`, `user.active`) change only when the matching
PATCH/PUT succeeds. Invitation cancel and member remove are
server-side; the client just calls the catalog route.

Wave 2/3 secrets: create/rotate responses may include a raw token;
subsequent list items expose only configured/revoked flags.
