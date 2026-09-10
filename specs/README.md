# Specs

Brownfield Spec Kit artifacts for this monorepo. The constitution is
`.specify/memory/constitution.md`. Cursor skills live in
`.cursor/skills/speckit-*`.

## What is already specified

| Folder | Status | Purpose |
|--------|--------|---------|
| [001-userinfo-sdk](./001-userinfo-sdk/) | Baseline | The product that already ships: `GET /v1/userinfo` across six core SDKs |
| [002-cross-sdk-parity](./002-cross-sdk-parity/) | Draft | First improvement: auth-header bugs, typed errors, Python models, docs |

Start here: [001-userinfo-sdk/spec.md](./001-userinfo-sdk/spec.md), then
the [audit checklist](./001-userinfo-sdk/checklists/baseline-audit.md).

## How to improve something

In Cursor, from the repo root:

1. `/speckit-specify` — new behavior (or refine `002`)
2. `/speckit-clarify` — if the spec still has open questions
3. `/speckit-plan` — stack and file-level plan
4. `/speckit-tasks` — implementable task list
5. `/speckit-implement` — execute tasks
6. `/speckit-converge` — compare code to spec/plan/tasks

Do not change a core SDK’s HTTP path, error mapping, or auth header
rules without updating the spec in the same change.

## CLI

```bash
# already installed during bootstrap; pin if you need to recreate
uv tool install specify-cli
specify check
```
