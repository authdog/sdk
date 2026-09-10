# Tasks: Authdog User Info SDK (baseline)

**Input**: Design documents from `/specs/001-userinfo-sdk/`

**Note**: Brownfield. Implementation already lives in the six core
SDK folders. These tasks record documentation of the baseline, not a
greenfield build. Remaining product work is `002-cross-sdk-parity`.

## Phase 1: Baseline capture

- [x] T001 Audit core clients (`python/`, `node/`, `go/`, `rust/`,
      `java/`, `csharp/`) and moon/CI layout
- [x] T002 Write constitution v1.0.0 from existing conventions
- [x] T003 Write `spec.md` for the shipped user-info product
- [x] T004 Write `plan.md` / `research.md` recording stacks and drift
- [x] T005 Write `data-model.md` and `contracts/userinfo.openapi.yaml`
- [x] T006 Write `quickstart.md` and `checklists/baseline-audit.md`
- [x] T007 Draft `002-cross-sdk-parity/spec.md` for the first
      improvement pass

## Out of scope here

Do not implement auth-header, error-type, or Python model fixes under
this feature number. Use `/speckit-plan` on `002-cross-sdk-parity`.
