# Contracts: Platform API Parity

Dated public catalog for `004-api-parity`.

| File | Role |
|------|------|
| [openapi.snapshot.json](./openapi.snapshot.json) | Full OpenAPI 3.0 document from `https://api.authdog.com/v1/openapi` on 2026-09-17 (Authdog API 1.0.0, 188 paths, 266 operations) |
| [operation-inventory.md](./operation-inventory.md) | Every operation assigned to Wave 1, 2, or 3 |
| [wave1-operations.json](./wave1-operations.json) | Wave 1 method, path, parameters, and response codes |

User-info remains documented in
[`../../001-userinfo-sdk/contracts/userinfo.openapi.yaml`](../../001-userinfo-sdk/contracts/userinfo.openapi.yaml).
The snapshot’s `UserInfo` schema is the live equivalent; do not change
user-info behavior in this feature.

Refresh process (later spec or chore): replace the snapshot, rebuild
the inventory, and re-assign new operations. Do not silently drop a
path.
