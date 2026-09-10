# Tasks: Cross-SDK Parity Hardening

**Input**: Design documents from `/specs/002-cross-sdk-parity/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md

**Tests**: Required by spec FR-002 and constitution IV.

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup

- [x] T001 Write plan/research/data-model/quickstart under `specs/002-cross-sdk-parity/`

## Phase 2: Foundational

- [x] T002 Confirm wire contract is reused from `specs/001-userinfo-sdk/contracts/userinfo.openapi.yaml` (no new endpoint)

---

## Phase 3: User Story 1 - Token is always the userinfo credential (P1)

**Goal**: Access token is the sole Authorization header on get-user-info
**Independent Test**: Stub sees `Bearer <access-token>` when apiKey is also set

- [x] T003 [US1] Stop overwriting Authorization with apiKey in `go/client.go`
- [x] T004 [US1] Expect access token in `go/client_test.go` TestClient_GetUserInfo_With_API_Key
- [x] T005 [P] [US1] Stop overwriting Authorization with apiKey in `rust/src/client.rs`
- [x] T006 [P] [US1] Add access-token-wins test in `rust/tests/client_test.rs`
- [x] T007 [P] [US1] Always send access token in `java/src/main/java/com/authdog/AuthdogClient.java`
- [x] T008 [P] [US1] Expect access token in `java/src/test/java/com/authdog/AuthdogClientTest.java`
- [x] T009 [P] [US1] Do not set default Authorization from apiKey in `csharp/AuthdogClient.cs`
- [x] T010 [P] [US1] Keep `GetUserInfoAsync_WithApiKey_UsesAccessTokenInRequest` green in `csharp/Tests/AuthdogClientTests.cs`

---

## Phase 4: User Story 2 - Errors stay typed after return (P1)

**Goal**: Go/Rust callers match auth vs API without string search
**Independent Test**: 401 and 500 are type-detectable; transport is API/base

- [x] T011 [US2] Make `IsAuthdogError` true for auth and API errors in `go/errors.go`
- [x] T012 [US2] Wrap transport failures as `APIError` in `go/client.go`
- [x] T013 [US2] Update `go/errors_test.go` for the new `IsAuthdogError` membership
- [x] T014 [P] [US2] Turn `AuthdogError` into a matchable enum in `rust/src/error.rs`
- [x] T015 [P] [US2] Map transport failures to `APIError` in `rust/src/client.rs`
- [x] T016 [P] [US2] Assert `is_authentication` / `is_api` in `rust/tests/client_test.rs` and `rust/tests/error_test.rs`

---

## Phase 5: User Story 3 - Python is a typed peer (P2)

**Goal**: `get_userinfo` returns typed models
**Independent Test**: Shared-shape payload exposes `user.display_name`

- [x] T017 [US3] Add dataclasses in `python/authdog/types.py`
- [x] T018 [US3] Return `UserInfoResponse` from `python/authdog/client.py`
- [x] T019 [US3] Export types from `python/authdog/__init__.py`
- [x] T020 [US3] Update `python/tests/test_client.py` and add `python/tests/test_types.py`
- [x] T021 [US3] Document attribute access in `python/README.md`

---

## Phase 6: User Story 4 - Timeouts are consistent (P2)

**Goal**: Owned Python/C# clients default to 10s
**Independent Test**: Inspect timeout after construct with no argument

- [x] T022 [US4] Default `timeout=10.0` on httpx in `python/authdog/client.py`
- [x] T023 [US4] Assert default timeout in `python/tests/test_client.py`
- [x] T024 [P] [US4] Default owned HttpClient timeout in `csharp/AuthdogClient.cs`
- [x] T025 [P] [US4] Assert default timeout in `csharp/Tests/AuthdogClientTests.cs`

---

## Phase 7: User Story 5 - Docs match reality (P3)

**Goal**: CONTRIBUTING lists real cores vs `planned/`
**Independent Test**: Every named directory exists

- [x] T026 [US5] Rewrite language layout in `CONTRIBUTING.md`
- [x] T027 [US5] Ignore leftover `/c/` and `/kotlin/` in `.gitignore`
- [x] T028 [US5] Confirm root `README.md` already links to `specs/`

---

## Phase 8: Polish

- [x] T029 Run core tests (Go, Rust, Python green; Java checkstyle-clean, suite previously green; C# not runnable here — no `dotnet`)
- [x] T030 Note 0.x tightening in Go/Rust/Python READMEs where error or return types changed

## Dependencies

- US1 and US2 share `go/client.go` / `rust/src/client.rs` — do those files once
- US3 then US4 on Python client
- US5 after code so docs describe shipped behavior

## Parallel opportunities

- T005–T010 (Rust/Java/C# header fixes)
- T014–T016 (Rust errors) after T005
- T024–T025 (C# timeout) with T009

## MVP

T003–T010 (US1) — wrong-principal bug
