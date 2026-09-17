# Authdog SDK

Official SDKs for the Authdog authentication and user management platform.

## Core SDKs

| Package | Version | Description | CI |
|---------|---------|-------------|-----|
| [`authdog`](./python/) | [![PyPI](https://img.shields.io/badge/pypi-v0.1.1-orange)](./python/) | Python SDK | [![CI](https://github.com/authdog/sdk/actions/workflows/python-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/python-test.yml) |
| [`@authdog/node-sdk`](./node/) | [![npm](https://img.shields.io/badge/npm-v0.1.0-orange)](./node/) | Node.js / TypeScript SDK | [![CI](https://github.com/authdog/sdk/actions/workflows/node-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/node-test.yml) |
| [`github.com/authdog/go-sdk`](./go/) | [![Go](https://img.shields.io/badge/go-v0.1.0-00ADD8)](./go/) | Go SDK | [![CI](https://github.com/authdog/sdk/actions/workflows/go-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/go-test.yml) |
| [`authdog`](./rust/) | [![crates.io](https://img.shields.io/badge/crates.io-v0.1.0-orange)](./rust/) | Rust SDK | [![CI](https://github.com/authdog/sdk/actions/workflows/rust-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/rust-test.yml) |
| [`com.authdog:authdog-java-sdk`](./java/) | [![Maven](https://img.shields.io/badge/maven-v0.1.0-orange)](./java/) | Java SDK | [![CI](https://github.com/authdog/sdk/actions/workflows/java-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/java-test.yml) |
| [`Authdog.Sdk`](./csharp/) | [![NuGet](https://img.shields.io/badge/nuget-v0.1.0-orange)](./csharp/) | C# / .NET SDK | [![CI](https://github.com/authdog/sdk/actions/workflows/csharp-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/csharp-test.yml) |
| [`authdog`](./zig/) | [![Zig](https://img.shields.io/badge/zig-v0.1.0-f7a41d)](./zig/) | Zig SDK | [![CI](https://github.com/authdog/sdk/actions/workflows/zig-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/zig-test.yml) |

## Planned SDKs

The following SDKs are under development in the [`planned/`](./planned/) directory:

C, C++, Clojure, Common Lisp, Dart, Elixir, F#, Kotlin, OCaml, PHP, PowerShell, R, Ruby, Scala, Swift

## Features

- **User Information** -- retrieve profile data, emails, photos, and verification status
- **Management API** -- organizations, tenants, directory, RBAC, audit, events, webhooks, and machine credentials
- **Authentication** -- token-based auth with structured error handling
- **Type Safety** -- full type support in TypeScript, Go, Rust, Java, C#, and Zig
- **Async Support** -- modern async/await APIs where applicable

## API

Official SDKs wrap the public Authdog HTTP API at
[`https://api.authdog.com`](https://api.authdog.com).

Constructor `apiKey` is the management Bearer credential. Get-user-info
still sends the access-token argument only:

```
GET /v1/userinfo
Authorization: Bearer <access-token>
```

Waves 1–2 include health, organizations, tenants, projects,
environments, directory users/groups, RBAC, audit, events, webhooks,
notification channels, and machine credentials. The full catalog and
Wave 3 live in [`specs/004-api-parity/`](./specs/004-api-parity/).

See individual SDK READMEs for language-specific usage.

## Specs

This repo uses [GitHub Spec Kit](https://github.com/github/spec-kit)
to describe what the SDKs already do and to drive changes.

- Constitution: [`.specify/memory/constitution.md`](./.specify/memory/constitution.md)
- Baseline (as-is): [`specs/001-userinfo-sdk/`](./specs/001-userinfo-sdk/)
- Cross-SDK hardening: [`specs/002-cross-sdk-parity/`](./specs/002-cross-sdk-parity/)
- Platform API parity (Wave 1 shipped): [`specs/004-api-parity/`](./specs/004-api-parity/)
- How to iterate: [`specs/README.md`](./specs/README.md)

In Cursor: `/speckit-specify` → `/speckit-plan` → `/speckit-tasks` →
`/speckit-implement` → `/speckit-converge`.

## Development

### Prerequisites

This monorepo uses [moon](https://moonrepo.dev/) for task orchestration and [proto](https://moonrepo.dev/proto) for toolchain management.

```bash
curl -fsSL https://moonrepo.dev/install/proto.sh | bash
curl -fsSL https://moonrepo.dev/install/moon.sh | bash
proto use
```

### Common Commands

```bash
moon check --all          # Run all checks across all SDKs
moon run <sdk>:test       # Run tests for a specific SDK
moon run <sdk>:lint       # Lint a specific SDK
moon run <sdk>:build      # Build a specific SDK
moon run :test            # Run tests for all SDKs
```

### Task Matrix

| Task | Python | Node | Go | Rust | Java | C# | Zig |
|------|--------|------|----|------|------|----|-----|
| `deps` | uv sync | pnpm install | go mod download | -- | mvn dependency:resolve | dotnet restore | -- |
| `test` | pytest | vitest | go test | cargo test | mvn test | dotnet test | zig build test |
| `lint` | flake8 | eslint | go vet | cargo clippy | checkstyle | dotnet format | zig fmt --check |
| `build` | python -m build | pnpm build | go build | cargo build | mvn compile | dotnet build | zig build |
| `fmt` | -- | -- | gofmt | cargo fmt | -- | -- | zig fmt --check |
| `security` | -- | -- | -- | cargo audit | -- | security-scan | -- |
| `benchmark` | -- | -- | go test -bench | -- | JMH | -- | -- |

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

[MIT](./LICENSE)
