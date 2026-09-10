# Data Model: User Info SDK

**Date**: 2026-09-10  
**Feature**: `001-userinfo-sdk`

Wire names are JSON camelCase. Nullability matches the TypeScript
source of truth in `node/src/types.ts` unless noted.

## UserInfoResponse

Envelope returned on HTTP 200.

| Field | Type | Required |
|-------|------|----------|
| meta | Meta | yes |
| session | Session | yes |
| user | User | yes |

## Meta

| Field | Type | Required |
|-------|------|----------|
| code | integer | yes |
| message | string | yes |

## Session

| Field | Type | Required |
|-------|------|----------|
| remainingSeconds | integer | yes |

## User

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| id | string | yes | Platform user id |
| externalId | string | yes | Id at the identity provider |
| userName | string | yes | |
| displayName | string | yes | |
| nickName | string \| null | yes | |
| profileUrl | string \| null | yes | |
| title | string \| null | yes | |
| userType | string \| null | yes | |
| preferredLanguage | string \| null | yes | |
| locale | string | yes | |
| timezone | string \| null | yes | |
| active | boolean | yes | |
| names | Names | yes | |
| photos | Photo[] | yes | |
| phoneNumbers | unknown[] | yes | Schema unspecified |
| addresses | unknown[] | yes | Schema unspecified |
| emails | Email[] | yes | |
| verifications | Verification[] | yes | |
| provider | string | yes | e.g. `google-oauth20` |
| createdAt | string (ISO-8601) | yes | Go currently parses as `time.Time` |
| updatedAt | string | yes | Go leaves as string |
| environmentId | string | yes | |

## Names

| Field | Type | Required |
|-------|------|----------|
| id | string | yes |
| formatted | string \| null | yes |
| familyName | string | yes |
| givenName | string | yes |
| middleName | string \| null | yes |
| honorificPrefix | string \| null | yes |
| honorificSuffix | string \| null | yes |

## Photo

| Field | Type | Required |
|-------|------|----------|
| id | string | yes |
| value | string | yes |
| type | string | yes |

## Email

| Field | Type | Required |
|-------|------|----------|
| id | string | yes |
| value | string | yes |
| type | string \| null | yes |

## Verification

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| id | string | yes | |
| email | string | yes | |
| verified | boolean | yes | |
| createdAt | string (ISO-8601) | yes | Go: `time.Time` |
| updatedAt | string | yes | Go: string |

## ErrorResponse

Returned on some HTTP 500 bodies.

| Field | Type | Required |
|-------|------|----------|
| error | string | yes |

Known values: `GraphQL query failed`, `Failed to fetch user info`.

## Error types (client-side)

Not serialized. Constructed by each SDK:

- **AuthdogError** (Java/C#: `AuthdogException`) — base
- **AuthenticationError** (Java/C#: `AuthenticationException`) — HTTP 401
- **APIError** (Java/C#: `ApiException`) — other HTTP and transport errors

## Validation rules

- Clients do not locally validate email format, URL shape, or
  timestamp format beyond what the language JSON decoder requires.
- Missing required fields on 200: typed decoders fail; Python returns
  the partial dict.
- Extra JSON properties: should be ignored when the decoder allows
  (Rust `serde` default is deny-unknown unless configured — current
  structs do not use `deny_unknown_fields`, so extras are ignored).
