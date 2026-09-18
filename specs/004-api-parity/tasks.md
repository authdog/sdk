# Tasks: Platform API Parity (Wave 1)

**Input**: Design documents from `/specs/004-api-parity/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Required by spec FR-015 and constitution IV. Wave 2/3
(US4, US5) are specified but **not** in this task list.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1 health + credentials, US2 orgs/tenants, US3
  projects/environments/directory

## Phase 1: Setup

**Purpose**: Confirm Wave 1 contracts and keep the catalog assigned

- [x] T001 Confirm Wave 1 inventory (56 ops) in `specs/004-api-parity/contracts/operation-inventory.md` and `specs/004-api-parity/contracts/wave1-operations.json`

---

## Phase 2: Foundational (Blocking)

**Purpose**: Shared request helper and Wave 1 models in every core SDK.
No story methods until this exists.

- [x] T002 Extract management request helper (401 → auth error, other HTTP → API error with status + `error` text, transport → API error) in `python/authdog/client.py`
- [x] T003 [P] Extract the same request helper in `node/src/client.ts`
- [x] T004 [P] Extract the same request helper in `go/client.go`
- [x] T005 [P] Extract the same request helper in `rust/src/client.rs`
- [x] T006 [P] Extract the same request helper in `java/src/main/java/com/authdog/AuthdogClient.java`
- [x] T007 [P] Extract the same request helper in `csharp/AuthdogClient.cs`
- [x] T008 [P] Extract the same request helper in `zig/src/client.zig`
- [x] T009 Add Wave 1 models (`Probe`, `Organization`, `Tenant`, `EnvUser`, `EnvGroup`, `Project`, `Environment`, list envelopes) in `python/authdog/types.py`
- [x] T010 [P] Add Wave 1 types in `node/src/types.ts`
- [x] T011 [P] Add Wave 1 types in `go/types.go`
- [x] T012 [P] Add Wave 1 types in `rust/src/types.rs`
- [x] T013 [P] Add Wave 1 types under `java/src/main/java/com/authdog/types/`
- [x] T014 [P] Add Wave 1 types under `csharp/Types/`
- [x] T015 [P] Add Wave 1 types in `zig/src/types.zig`

**Checkpoint**: Each client can issue an authenticated JSON request and parse Wave 1 entities

---

## Phase 3: User Story 1 - One client for user-info and management (P1) 🎯 MVP

**Goal**: `health` uses optional/management auth; `getUserInfo` still sends only the access-token argument

**Independent Test**: Stub health + userinfo; management list sends constructor `apiKey`; userinfo sends `Bearer <access-token>`

### Tests for User Story 1

- [x] T016 [P] [US1] Add health + management-401 + userinfo-precedence tests in `python/tests/test_client.py` and `python/tests/test_management.py`
- [x] T017 [P] [US1] Add the same coverage in `node/tests/client.test.ts`
- [x] T018 [P] [US1] Add the same coverage in `go/client_test.go`
- [x] T019 [P] [US1] Add the same coverage in `rust/tests/client_test.rs`
- [x] T020 [P] [US1] Add the same coverage in `java/src/test/java/com/authdog/AuthdogClientTest.java`
- [x] T021 [P] [US1] Add the same coverage in `csharp/Tests/AuthdogClientTests.cs`
- [x] T022 [P] [US1] Add the same coverage in `zig/src/client.zig`

### Implementation for User Story 1

- [x] T023 [P] [US1] Add `health()` in `python/authdog/client.py` (`GET /v1/health`, public if no apiKey)
- [x] T024 [P] [US1] Add `health()` in `node/src/client.ts`
- [x] T025 [P] [US1] Add `Health` in `go/client.go`
- [x] T026 [P] [US1] Add `health` in `rust/src/client.rs`
- [x] T027 [P] [US1] Add `health` in `java/src/main/java/com/authdog/AuthdogClient.java`
- [x] T028 [P] [US1] Add `HealthAsync`/`Health` in `csharp/AuthdogClient.cs`
- [x] T029 [P] [US1] Add `health` in `zig/src/client.zig`
- [x] T030 [US1] Keep get-user-info access-token-wins and known 500 strings in all seven cores

**Checkpoint**: US1 independently testable

---

## Phase 4: User Story 2 - Organizations and tenants (P1)

**Goal**: All organization and tenant Wave 1 operations (31 ops) on resource namespaces

**Independent Test**: Stub list empty/success, create, get, 401 for orgs and tenants

### Tests for User Story 2

- [x] T031 [P] [US2] Table-driven path/method tests for org + tenant ops in `python/tests/test_management.py`
- [x] T032 [P] [US2] Same table-driven coverage in `node/tests/management.test.ts`
- [x] T033 [P] [US2] Same coverage in `go/management_test.go`
- [x] T034 [P] [US2] Same coverage in `rust/tests/management_test.rs`
- [x] T035 [P] [US2] Same coverage in `java/src/test/java/com/authdog/ManagementTest.java`
- [x] T036 [P] [US2] Same coverage in `csharp/Tests/ManagementTests.cs`
- [x] T037 [P] [US2] Same coverage in `zig/src/management_test.zig`

### Implementation for User Story 2

- [x] T038 [P] [US2] Implement `organizations` + `tenants` namespaces (list/create/get/update/delete, members, invitations, join/accept, tenant link, domains, seats, invites, projects list) in `python/authdog/client.py`
- [x] T039 [P] [US2] Implement the same namespaces in `node/src/client.ts`
- [x] T040 [P] [US2] Implement the same namespaces in `go/client.go`
- [x] T041 [P] [US2] Implement the same namespaces in `rust/src/client.rs`
- [x] T042 [P] [US2] Implement the same namespaces in `java/src/main/java/com/authdog/AuthdogClient.java`
- [x] T043 [P] [US2] Implement the same namespaces in `csharp/AuthdogClient.cs`
- [x] T044 [P] [US2] Implement the same namespaces in `zig/src/client.zig`

**Checkpoint**: US2 independently testable

---

## Phase 5: User Story 3 - Projects, environments, directory (P1)

**Goal**: Projects, environment lifecycle, directory users/groups (24 remaining Wave 1 ops)

**Independent Test**: Stub project save/get, env list/create, user list empty + get, group create + members

### Tests for User Story 3

- [x] T045 [P] [US3] Extend table-driven tests for projects/environments/users/groups in `python/tests/test_management.py`
- [x] T046 [P] [US3] Same in `node/tests/management.test.ts`
- [x] T047 [P] [US3] Same in `go/management_test.go`
- [x] T048 [P] [US3] Same in `rust/tests/management_test.rs`
- [x] T049 [P] [US3] Same in `java/src/test/java/com/authdog/ManagementTest.java`
- [x] T050 [P] [US3] Same in `csharp/Tests/ManagementTests.cs`
- [x] T051 [P] [US3] Same in `zig/src/management_test.zig`

### Implementation for User Story 3

- [x] T052 [P] [US3] Implement `projects`, `environments`, `users`, `groups` in `python/authdog/client.py` including `POST /v1/groups` and user search/count/set-active
- [x] T053 [P] [US3] Implement the same in `node/src/client.ts`
- [x] T054 [P] [US3] Implement the same in `go/client.go`
- [x] T055 [P] [US3] Implement the same in `rust/src/client.rs`
- [x] T056 [P] [US3] Implement the same in `java/src/main/java/com/authdog/AuthdogClient.java`
- [x] T057 [P] [US3] Implement the same in `csharp/AuthdogClient.cs`
- [x] T058 [P] [US3] Implement the same in `zig/src/client.zig`
- [x] T059 Export new types from `python/authdog/__init__.py`, `node/src/index.ts`, `rust/src/lib.rs`, and Java/C# public namespaces

**Checkpoint**: All Wave 1 stories independently functional

---

## Phase 6: Polish

**Purpose**: Docs and version alignment

- [x] T060 Update root `README.md` so it no longer claims a single endpoint
- [x] T061 [P] Document Wave 1 usage in `python/README.md`
- [x] T062 [P] Document Wave 1 usage in `node/README.md`
- [x] T063 [P] Document Wave 1 usage in `go/README.md`
- [x] T064 [P] Document Wave 1 usage in `rust/README.md`
- [x] T065 [P] Document Wave 1 usage in `java/README.md`
- [x] T066 [P] Document Wave 1 usage in `csharp/README.md`
- [x] T067 [P] Document Wave 1 usage in `zig/README.md`
- [ ] T068 Bump published cores and User-Agent strings to `0.2.0`
- [x] T069 Run `specs/004-api-parity/quickstart.md` inventory gate and `moon run :test`

---

## Dependencies & Execution Order

- Phase 1 → Phase 2 (blocks stories) → US1 → US2 → US3 → Polish
- Languages marked [P] can proceed in parallel after T002’s helper shape is known
- US4 (RBAC/audit/webhooks) and US5 (AuthZEN/SCIM/…) are out of this list

### User Story dependencies

- **US1**: After Phase 2
- **US2**: After US1 helper + models
- **US3**: After US1 helper + models (can parallel US2 across languages)

### Parallel example: US1 helpers

```text
T023 python health
T024 node health
T025 go Health
T026 rust health
T027 java health
T028 csharp Health
T029 zig health
```

## Implementation Strategy

1. Setup + foundation (request helper + models)
2. US1 MVP: health + unchanged userinfo
3. US2 organizations/tenants
4. US3 directory/projects/environments
5. Docs + 0.2.0 + `moon run :test`

Wave 1 is the MVP for this feature. Wave 2 follows below.

---

## Phase 7: User Story 4 - Authorize and observe activity + machine credentials (P2)

**Goal**: Wave 2 — 58 operations: RBAC, audit, events, webhooks, notification channels, service accounts, PATs, API secrets, organization keys

**Independent Test**: Table-driven path/method tests; create/rotate responses expose one-time secrets; query params are forwarded

- [x] T070 [US4] Add Wave 2 namespaces and org key/audit methods in `python/authdog/resources.py` and `python/authdog/client.py`
- [x] T071 [US4] Add Wave 2 path/secret/query tests in `python/tests/test_management.py`
- [x] T072 [P] [US4] Implement Wave 2 in `node/src/resources.ts` and `node/src/client.ts` with tests in `node/tests/management.test.ts`
- [x] T073 [P] [US4] Implement Wave 2 in `go/` with tests in `go/management_test.go`
- [x] T074 [P] [US4] Implement Wave 2 in `rust/` with tests in `rust/tests/management_test.rs`
- [x] T075 [P] [US4] Implement Wave 2 in `java/` with tests in `java/src/test/java/com/authdog/ManagementTest.java`
- [x] T076 [P] [US4] Implement Wave 2 in `csharp/` with tests in `csharp/Tests/ManagementTests.cs`
- [x] T077 [P] [US4] Implement Wave 2 in `zig/` with tests in `zig/src/management_test.zig`
- [x] T078 [US4] Document Wave 2 namespaces in core READMEs and `specs/README.md`

---

## Phase 8: User Story 5 - Specialized surfaces (P3)

**Goal**: Wave 3 — 152 remaining operations: AuthZEN, SCIM, HRIS, MCP, OTEL, environment settings/connections, elevate, and the rest of the snapshot

**Independent Test**: Table-driven path/method tests; AuthZEN discovery is unauthenticated and evaluation stays on `/access/v1/...`; SCIM/HRIS send their constructor tokens; create/rotate secrets stay on the response

- [x] T079 [US5] Add Wave 3 namespaces, specialized credentials, and directory/environment extras in `python/authdog/resources.py` and `python/authdog/client.py`
- [x] T080 [US5] Add Wave 3 path/auth/secret/query tests in `python/tests/test_management.py`
- [x] T081 [P] [US5] Implement Wave 3 in `node/src/resources.ts` and `node/src/client.ts` with tests in `node/tests/management.test.ts`
- [x] T082 [P] [US5] Implement Wave 3 in `go/` with tests in `go/management_test.go`
- [x] T083 [P] [US5] Implement Wave 3 in `rust/` with tests in `rust/tests/management_test.rs`
- [x] T084 [P] [US5] Implement Wave 3 in `java/` with tests in `java/src/test/java/com/authdog/ManagementTest.java`
- [x] T085 [P] [US5] Implement Wave 3 in `csharp/` with tests in `csharp/Tests/ManagementTests.cs`
- [x] T086 [P] [US5] Implement Wave 3 in `zig/` with tests in `zig/src/management_test.zig`
- [x] T087 [US5] Document Wave 3 namespaces and specialized credentials in core READMEs and `specs/README.md`
