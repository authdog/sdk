# Authdog C# SDK Tests

This directory contains comprehensive tests for the Authdog C# SDK.

## Test Structure

- **AuthdogClientTests.cs**: Tests for the main `AuthdogClient` class
  - Constructor tests
  - Successful API calls
  - Error handling (authentication, API errors, network errors, timeouts)
  - API key vs access token handling
  - Disposal and lifecycle management

- **ExceptionTests.cs**: Tests for exception classes
  - `AuthdogException` base class
  - `AuthenticationException` for auth failures
  - `ApiException` for API errors
  - Exception inheritance and behavior

## Running Tests

### Prerequisites
- .NET 7.0 SDK or later
- NuGet package manager

### Commands

```bash
# Restore dependencies
dotnet restore

# Build the solution
dotnet build

# Run all tests
dotnet test

# Run tests with coverage
dotnet test --collect:"XPlat Code Coverage"

# Run specific test class
dotnet test --filter "AuthdogClientTests"

# Run tests with detailed output
dotnet test --verbosity normal
```

## Test Dependencies

- **xUnit**: Testing framework
- **Moq**: Mocking framework for HTTP client
- **FluentAssertions**: Fluent assertion library
- **Microsoft.AspNetCore.Mvc.Testing**: Testing utilities
- **coverlet.collector**: Code coverage collection

## Test Coverage

The tests cover:
- ✅ Client initialization and configuration
- ✅ Successful API responses
- ✅ Authentication failures
- ✅ API errors (GraphQL, fetch errors)
- ✅ Network errors and timeouts
- ✅ HTTP status code handling
- ✅ JSON parsing and serialization
- ✅ Exception handling and propagation
- ✅ Resource disposal and cleanup
- ✅ API key vs access token precedence

## CI/CD Integration

Tests are automatically run in GitHub Actions with:
- Multiple .NET versions (6.0, 7.0, 8.0)
- Code coverage reporting
- Test result artifacts
- Security scanning
- Linting and formatting checks
