# Authdog SDK

Official SDKs for the Authdog authentication and user management platform.

## SDK Health

[![Python](https://github.com/authdog/sdk/actions/workflows/python-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/python-test.yml)
[![Node.js](https://github.com/authdog/sdk/actions/workflows/node-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/node-test.yml)
[![Go](https://github.com/authdog/sdk/actions/workflows/go-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/go-test.yml)
[![Rust](https://github.com/authdog/sdk/actions/workflows/rust-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/rust-test.yml)
[![Java](https://github.com/authdog/sdk/actions/workflows/java-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/java-test.yml)
[![C#](https://github.com/authdog/sdk/actions/workflows/csharp-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/csharp-test.yml)

## Core SDKs

| Language | Directory | Docs |
|----------|-----------|------|
| Python | [`python/`](./python/) | [README](./python/README.md) |
| Node.js / TypeScript | [`node/`](./node/) | [README](./node/README.md) |
| Go | [`go/`](./go/) | [README](./go/README.md) |
| Rust | [`rust/`](./rust/) | [README](./rust/README.md) |
| Java | [`java/`](./java/) | [README](./java/README.md) |
| C# | [`csharp/`](./csharp/) | [README](./csharp/README.md) |

## Planned SDKs

The following SDKs are under development in the [`planned/`](./planned/) directory:

C, C++, Clojure, Common Lisp, Dart, Elixir, F#, Kotlin, OCaml, PHP, PowerShell, R, Ruby, Scala, Swift, Zig

## Features

- **User Information** -- retrieve profile data, emails, photos, and verification status
- **Authentication** -- token-based auth with structured error handling
- **Type Safety** -- full type support in TypeScript, Go, Rust, Java, and C#
- **Async Support** -- modern async/await APIs where applicable

## API

All SDKs wrap a single endpoint:

```
GET /v1/userinfo
Authorization: Bearer <access-token>
```

See individual SDK READMEs for language-specific usage examples and response types.

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

| Task | Python | Node | Go | Rust | Java | C# |
|------|--------|------|----|------|------|----|
| `deps` | pip install | pnpm install | go mod download | -- | mvn dependency:resolve | dotnet restore |
| `test` | pytest | vitest | go test | cargo test | mvn test | dotnet test |
| `lint` | flake8 | eslint | go vet | cargo clippy | checkstyle | dotnet format |
| `build` | python -m build | pnpm build | go build | cargo build | mvn compile | dotnet build |
| `fmt` | -- | -- | gofmt | cargo fmt | -- | -- |
| `security` | -- | -- | -- | cargo audit | -- | security-scan |
| `benchmark` | -- | -- | go test -bench | -- | JMH | -- |

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

[MIT](./LICENSE)
