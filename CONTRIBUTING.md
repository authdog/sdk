# Contributing to Authdog SDK

Thank you for your interest in contributing to the Authdog SDK! This document provides guidelines and instructions for contributing to our multi-language SDK project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Language-Specific Guidelines](#language-specific-guidelines)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Release Process](#release-process)

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct. Please be respectful and constructive in all interactions.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/sdk.git`
3. Create a new branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes
6. Submit a pull request

## Development Setup

This repository contains multiple SDK implementations in different programming languages:

- **Python SDK** (`/python/`)
- **Node.js SDK** (`/node/`)
- **Go SDK** (`/go/`)
- **Kotlin SDK** (`/kotlin/`)
- **Rust SDK** (`/rust/`)
- **PHP SDK** (`/php/`)
- **C# SDK** (`/csharp/`)
- **C++ SDK** (`/cpp/`)
- **Elixir SDK** (`/elixir/`)
- **Java SDK** (`/java/`)
- **Scala SDK** (`/scala/`)
- **Common Lisp SDK** (`/commonlisp/`)
- **Clojure SDK** (`/clojure/`)
- **Swift SDK** (`/swift/`)
- **Zig SDK** (`/zig/`)

Each SDK has its own development setup. Please refer to the individual README files in each language directory for specific setup instructions.

## Contributing Guidelines

### General Guidelines

1. **Consistency**: Maintain consistency across all language implementations
2. **Documentation**: Update relevant documentation for any changes
3. **Testing**: Add tests for new features and bug fixes
4. **Code Style**: Follow the established code style for each language
5. **Backward Compatibility**: Ensure changes don't break existing functionality

### Commit Messages

Use clear, descriptive commit messages following conventional commits:

```
feat: add new authentication method
fix: resolve token validation issue
docs: update API documentation
test: add unit tests for user info endpoint
```

### Branch Naming

Use descriptive branch names with prefixes:

- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test improvements

## Language-Specific Guidelines

### Python SDK

- Follow PEP 8 style guidelines
- Use type hints for better code clarity
- Add docstrings for all public methods
- Use `pytest` for testing
- Maintain compatibility with Python 3.7+

### Node.js SDK

- Use TypeScript for type safety
- Follow ESLint configuration
- Use `jest` for testing
- Maintain compatibility with Node.js 14+
- Export types and interfaces

### Go SDK

- Follow Go formatting with `gofmt`
- Use `golint` for code quality
- Write tests using `testing` package
- Maintain compatibility with Go 1.16+
- Use proper error handling patterns

### Kotlin SDK

- Follow Kotlin coding conventions
- Use `ktlint` for formatting
- Write tests using `kotlin.test`
- Maintain compatibility with Kotlin 1.6+
- Use coroutines for async operations

### Rust SDK

- Follow Rust formatting with `rustfmt`
- Use `clippy` for linting
- Write tests using `cargo test`
- Maintain compatibility with Rust 1.60+
- Use proper error handling with `Result` types

### PHP SDK

- Follow PSR-12 coding standards
- Use PHPStan for static analysis
- Write tests using PHPUnit
- Maintain compatibility with PHP 7.4+
- Use proper type hints and PHPDoc comments
- Follow PSR-4 autoloading standards

### C# SDK

- Follow Microsoft C# coding conventions
- Use nullable reference types
- Write tests using xUnit or NUnit
- Maintain compatibility with .NET 6.0+
- Use proper async/await patterns
- Follow SOLID principles

### C++ SDK

- Follow Google C++ Style Guide
- Use `clang-format` for formatting
- Use `clang-tidy` for static analysis
- Write tests using Google Test
- Maintain compatibility with C++17+
- Use RAII and smart pointers
- Prefer `const` wherever possible

### Elixir SDK

- Follow Elixir Style Guide
- Use `mix format` for formatting
- Write tests using ExUnit
- Maintain compatibility with Elixir 1.12+
- Use proper pattern matching
- Follow functional programming principles
- Use `Credo` for code quality

### Java SDK

- Follow Google Java Style Guide
- Use `google-java-format` for formatting
- Use `SpotBugs` for static analysis
- Write tests using JUnit 5
- Maintain compatibility with Java 11+
- Use `final` wherever possible
- Prefer immutable objects

### Scala SDK

- Follow Scala Style Guide
- Use `scalafmt` for formatting
- Use `scalastyle` for style checking
- Write tests using ScalaTest
- Maintain compatibility with Scala 2.13+
- Use `val` wherever possible
- Prefer immutable data structures

### Common Lisp SDK

- Follow Common Lisp Style Guide
- Use `cl-format` for formatting
- Use meaningful variable and function names
- Write tests using FiveAM
- Maintain compatibility with ANSI Common Lisp
- Use `defclass` for data structures
- Use `handler-case` for error handling
- Prefer `let` over `setf` for local bindings

### Clojure SDK

- Follow Clojure Style Guide
- Use `cljfmt` for formatting
- Use meaningful function and variable names
- Write tests using Midje or clojure.test
- Maintain compatibility with Clojure 1.11+
- Use `defn` for functions
- Use `try-catch` for error handling
- Prefer `let` over `def` for local bindings
- Use `->` and `->>` for threading

### Swift SDK

- Follow Swift API Design Guidelines
- Use `swiftformat` for formatting
- Use `swiftlint` for linting
- Use meaningful variable and function names
- Write tests using XCTest
- Maintain compatibility with Swift 5.9+
- Use `struct` for data models
- Use `async/await` for asynchronous operations
- Prefer `let` over `var` for immutable values

### Zig SDK

- Follow Zig Style Guide
- Use `zig fmt` for formatting
- Use meaningful variable and function names
- Write tests using Zig's built-in testing framework
- Maintain compatibility with Zig 0.11+
- Use `const` for immutable values
- Use `var` for mutable values
- Use error unions for error handling
- Prefer `comptime` when possible

## Testing

### Test Requirements

- All new features must include tests
- Bug fixes must include regression tests
- Maintain or improve test coverage
- Tests should be fast and reliable

### Running Tests

Each language has its own test runner:

```bash
# Python
cd python && python -m pytest

# Node.js
cd node && npm test

# Go
cd go && go test ./...

# Kotlin
cd kotlin && ./gradlew test

# Rust
cd rust && cargo test

# PHP
cd php && composer test

# C#
cd csharp && dotnet test

# C++
cd cpp && mkdir build && cd build && cmake .. && make && ctest

# Elixir
cd elixir && mix test

# Java
cd java && mvn test

# Scala
cd scala && sbt test

# Common Lisp
cd commonlisp && asdf:test-system :authdog

# Clojure
cd clojure && lein test

# Swift
cd swift && swift test

# Zig
cd zig && zig build test
```

## Pull Request Process

### Before Submitting

1. Ensure all tests pass
2. Update documentation if needed
3. Check code style and formatting
4. Verify backward compatibility
5. Test across different environments

### Pull Request Template

When creating a pull request, please include:

1. **Description**: Clear description of changes
2. **Type**: Feature, bug fix, documentation, etc.
3. **Testing**: How the changes were tested
4. **Breaking Changes**: Any breaking changes and migration steps
5. **Checklist**: Completed items from the contribution checklist

### Review Process

1. Automated checks must pass (tests, linting, formatting)
2. Code review by maintainers
3. Address feedback and make requested changes
4. Maintainer approval and merge

## Release Process

### Versioning

We follow [Semantic Versioning](https://semver.org/) (SemVer):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] Version numbers updated across all SDKs
- [ ] Changelog updated
- [ ] Release notes prepared
- [ ] Packages published to respective registries

## Getting Help

- **Issues**: Use GitHub Issues for bug reports and feature requests
- **Discussions**: Use GitHub Discussions for questions and general discussion
- **Documentation**: Check the README files in each language directory

## Recognition

Contributors will be recognized in:
- CONTRIBUTORS.md file
- Release notes
- Project documentation

Thank you for contributing to Authdog SDK! 🚀
