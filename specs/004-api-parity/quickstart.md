# Quickstart: Validate platform API parity

**Date**: 2026-09-17  
**Feature**: `004-api-parity`

This guide checks the Wave 1 contract after implementation. It does
not replace language READMEs.

## Prerequisites

```bash
proto use
```

Catalog files (already in git):

- [contracts/openapi.snapshot.json](./contracts/openapi.snapshot.json)
- [contracts/operation-inventory.md](./contracts/operation-inventory.md)
- [contracts/wave1-operations.json](./contracts/wave1-operations.json)

## Inventory gate

Every path in the snapshot must appear in the inventory with Wave 1,
2, or 3. Wave 1 count must be 56.

```bash
python3 - <<'PY'
import json
from pathlib import Path
root = Path("specs/004-api-parity/contracts")
snap = json.loads((root / "openapi.snapshot.json").read_text())
inv = (root / "operation-inventory.md").read_text()
ops = 0
for path, methods in snap["paths"].items():
    for verb in methods:
        if verb in ("get", "post", "put", "patch", "delete"):
            ops += 1
            assert f"`{path}`" in inv, path
print("snapshot operations", ops)
assert ops == 266
assert inv.count("| 1 |") >= 1
PY
```

## User-info unchanged (US1)

Existing get-user-info tests must stay green, including access-token
header precedence when `apiKey` is set.

```bash
moon run python:test
moon run node:test
moon run go:test
moon run rust:test
moon run java:test
moon run csharp:test
moon run zig:test
```

## Management credential (US1)

Stub `GET /v1/health` and one management list (organizations or
tenants). Construct with `apiKey=key-1`:

1. Health may omit Authorization (public) or send `Bearer key-1`.
2. `GET /v1/organizations` (or tenants) MUST send
   `Authorization: Bearer key-1`.
3. `getUserInfo("token-2")` MUST send `Authorization: Bearer token-2`
   only.

HTTP 401 on a management list MUST be an authentication error by
type.

## Organizations and tenants (US2)

For each core SDK, stub:

- `GET /v1/organizations` → `{ "organizations": [], "total": 0 }`
- `POST /v1/organizations` → created organization
- `GET /v1/tenants` → `{ "tenants": [], "total": 0 }`
- `GET /v1/tenants/{id}` → `{ "tenant": { ... } }`

Assert method, path, and mapped `id` / `name`.

## Directory (US3)

Stub `GET /v1/tenants/{tenantId}/environments/{environmentId}/users`
with `{ "users": [] }` and with one `EnvUser`. Assert empty list is
success. Repeat for groups list and `POST /v1/groups`.

## Docs (SC-007)

Root `README.md` must not say the SDKs wrap only `/v1/userinfo` once
Wave 1 is implemented. It should link here.

## Full core suite

```bash
moon run :test
```

Expected: all core projects green; new Wave 1 tests included in each.
