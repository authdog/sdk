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
