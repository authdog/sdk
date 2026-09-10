# Data Model: Cross-SDK Parity Hardening

**Date**: 2026-09-10  
**Feature**: `002-cross-sdk-parity`

Wire entities are unchanged. See
[`../001-userinfo-sdk/data-model.md`](../001-userinfo-sdk/data-model.md).

## Python attribute mapping

| JSON | Python |
|------|--------|
| remainingSeconds | remaining_seconds |
| externalId | external_id |
| userName | user_name |
| displayName | display_name |
| nickName | nick_name |
| profileUrl | profile_url |
| userType | user_type |
| preferredLanguage | preferred_language |
| phoneNumbers | phone_numbers |
| environmentId | environment_id |
| familyName | family_name |
| givenName | given_name |
| middleName | middle_name |
| honorificPrefix | honorific_prefix |
| honorificSuffix | honorific_suffix |
| createdAt | created_at |
| updatedAt | updated_at |

Missing JSON keys parse as empty string, `0`, `False`, or `[]` so
partial test fixtures do not raise.

## Client-side error model (Go / Rust)

- **Authentication** — HTTP 401
- **API** — other HTTP statuses and transport failures
- **Base / Other** — parse/client-build failures that are not HTTP

Callers distinguish these by type (`IsAuthenticationError` /
`AuthdogError::Authentication`), not by message substring.
