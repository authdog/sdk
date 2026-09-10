# Baseline Audit Checklist

**Date**: 2026-09-10  
**Feature**: `001-userinfo-sdk`

Scorecard of what exists today versus the baseline spec. `N` items are
queued in `002-cross-sdk-parity`.

## Core SDK matrix

| Requirement | Py | Node | Go | Rust | Java | C# |
|-------------|----|------|----|------|------|----|
| Client + get-user-info | Y | Y | Y | Y | Y | Y |
| `GET /v1/userinfo` | Y | Y | Y | Y | Y | Y |
| Access token wins over apiKey | Y | Y | N | N | N | N |
| User-Agent `authdog-*-sdk/0.1.0` | Y | Y | Y | Y | Y | Y |
| Content-Type JSON | Y | Y | Y | Y | Y | default-only |
| Typed UserInfoResponse | N | Y | Y | Y | Y | Y |
| 401 → auth error | Y | Y | Y | Y | Y | Y |
| Known 500 messages | Y | Y | Y | Y | Y | Y |
| Other HTTP → API error | Y | Y | Y | Y | Y | Y |
| Transport → API/base error | Y | Y | Y* | Y* | Y | Y |
| Error hierarchy usable by callers | Y | Y | N | N | Y | Y |
| Timeout default 10s | N | Y | Y | Y | Y | N |
| close / context / dispose | Y | no-op | no-op | Drop | Y | Y |
| Async or context where idiomatic | N | Y | Y | Y | N | Y |
| Unit tests for 200/401/500 | Y | Y | Y | Y | Y | Y |
| moon project + CI workflow | Y | Y | Y | Y | Y | Y |
| README install + usage | Y | Y | Y | Y | Y | Y |
| Package version 0.1.0 | Y | Y | Y | Y | Y | Y |

\* Go/Rust wrap transport failures as `fmt.Errorf` / `AuthdogError`,
not always `APIError`.

## Repo hygiene

- [x] Root README lists six cores and `planned/` incubations
- [ ] CONTRIBUTING.md matches actual paths, test runners, and versions
- [x] `.moon/workspace.yml` lists only cores
- [ ] Planned workflows: decide enable vs keep `workflow_dispatch`
- [ ] Remove or ignore untracked root `c/` and `kotlin/` artifacts
- [x] Spec Kit initialized (`.specify/`, `.cursor/skills/`)

## Planned languages (incubation only)

Present under `planned/` with a client-shaped API: C, C++, Clojure,
Common Lisp, Dart, Elixir, F#, Kotlin, OCaml, PHP, PowerShell, R,
Ruby, Scala, Swift, Zig. C uses a flattened user struct and
config-stored token — not at parity with this contract.
