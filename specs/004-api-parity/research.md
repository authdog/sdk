# Research: Platform API Parity

**Date**: 2026-09-17  
**Feature**: `004-api-parity`

## Decision 1 — Snapshot the live catalog; do not scrape Console GraphQL

**Decision**: Treat `GET https://api.authdog.com/v1/openapi` as the
source of truth. Keep a dated copy at
`contracts/openapi.snapshot.json` (Authdog API 1.0.0, fetched
2026-09-17). Assign every operation in
`contracts/operation-inventory.md`.

**Rationale**: Platform docs state that live schemas live at
api.authdog.com and that Console GraphQL is internal. Constitution II
requires contracts before implementation.

**Alternatives considered**: Reverse-document from READMEs only
(already stale — they claim a single endpoint). Generate clients
directly against the live URL with no snapshot (non-reproducible
reviews). Wrap GraphQL (explicitly unsupported).

## Decision 2 — Three waves; implement Wave 1 in this release train

**Decision**:

| Wave | Count | Contents |
|------|-------|----------|
| 1 | 56 | Health, user-info, all Organizations, all Tenants, all Projects, environment list/create/update/delete, directory user CRUD + search/count/set-active/user-groups, directory group CRUD + members |
| 2 | 58 | RBAC, audit, events, webhooks, notification channels, service accounts, PATs, API secrets, organization keys |
| 3 | 152 | AuthZEN, SCIM, HRIS, MCP, elevate, settings, connections, remaining directory/environment ops, and the rest of the snapshot |

**Rationale**: 266 operations × 7 languages in one PR violates
Constitution VII and Principle IV’s test matrix. Wave 1 matches the
API reference’s first resource families (tenants, organizations,
directory) plus the project/environment ids those routes need.

**Alternatives considered**: Ship all 266 now (undeliverable). Wave 1
= read-only list/get only (weaker than “manage users”). Include
AuthZEN in Wave 1 (different path prefix and `adenv_` credential;
defer).

## Decision 3 — Constructor `apiKey` is the management Bearer token

**Decision**: Management calls send `Authorization: Bearer <apiKey>`.
`getUserInfo(accessToken)` still overrides that header. Health is
public and must work without an api key. No new required constructor
argument.

**Rationale**: 001/002 reserved `apiKey` for future endpoints.
Constitution Security already defines access-token-wins for user-info.

**Alternatives considered**: Separate `ManagementClient` (splits the
product the docs call “the backend SDK”). Per-call token on every
method (noisier than today’s constructor). `X-API-Key` (not in the
catalog).

## Decision 4 — Hand-written resource namespaces, not codegen (Wave 1)

**Decision**: Add a private `request` helper in each existing client
and public resource namespaces:

| Namespace | Catalog families |
|-----------|------------------|
| `health` | `GET /v1/health` |
| (root) | `getUserInfo` unchanged |
| `organizations` | `/v1/organizations...` |
| `tenants` | `/v1/tenants...` (not application/environment subtrees) |
| `projects` | `/v1/tenants/{tenantId}/applications...` |
| `environments` | environment list/create/update/delete |
| `users` | directory user Wave 1 ops |
| `groups` | directory group Wave 1 ops |

Language-idiomatic names are allowed (`list` / `List` / `listAsync`).

**Rationale**: Existing clients are hand-written thin wrappers.
Codegen would introduce a new toolchain and make 002-style error
mapping harder to keep identical. Wave 2/3 MAY revisit codegen once
the helper and error rules are stable.

**Alternatives considered**: Flat `listOrganizations` on the root
client (56 methods, unreadable). OpenAPI Generator / oapi-codegen
per language (extra deps, inconsistent errors). One shared WASM/C
core (out of scope; Zig is already a peer core SDK).

## Decision 5 — Reuse the three-type error taxonomy

**Decision**: 401 → authentication error. Other HTTP and transport
failures → API error. If a management body has `{"error":"..."}`,
copy that string onto the API error and keep the status code.
User-info’s two known HTTP 500 strings stay exact. Do not add
per-family exception types in Wave 1.

**Rationale**: Constitution III. Callers already branch on these
types.

**Alternatives considered**: HTTP-status enums per family (new public
surface). Parse `ManagementMeta.error` only (not all failures use
that envelope).

## Decision 6 — Directory EnvUser ≠ user-info User

**Decision**: Separate types. Do not reuse `UserInfoResponse.user`
for `EnvUser`. Phone/address/verification collections on user-info
stay as specified in 001.

**Rationale**: The catalog defines different schemas and different
auth (management vs user access token).

**Alternatives considered**: One `User` type with optional fields
(hides which API you called).

## Decision 7 — One-time secrets stay on the create/rotate type

**Decision**: Wave 2/3 create responses that include a raw secret
must expose it. List/get types that only have `*Configured`
booleans must not grow a fake secret field. Wave 1 has no such
secrets except if an organization/tenant invite response includes a
code — map whatever the catalog returns, do not persist it.

**Rationale**: Platform docs for webhooks and API secrets.

## Decision 8 — Docs and version

**Decision**: When Wave 1 ships, bump published cores together
(MINOR on 0.x, e.g. 0.2.0) and rewrite root + language READMEs so
they no longer say “all SDKs wrap a single endpoint.” Point at this
spec and the inventory.

**Rationale**: FR-017, SC-007, Constitution VI.

## Decision 9 — Out of scope (confirmed)

- Framework session middleware (`require_auth`, cookie resolvers)
  described on Authdog backend docs — different product.
- `planned/` language ports.
- Fetching OpenAPI at runtime inside the SDK.
- Retry, pagination helpers that hide catalog cursors, or
  opinionated auth middleware.

## Resolved clarifications

No `[NEEDS CLARIFICATION]` markers remained in the spec. Wave
boundaries, credential rules, and catalog source are recorded above.
