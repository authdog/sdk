# Authdog R SDK

R SDK for Authdog authentication and user management platform.

## Installation

```r
# Install from GitHub (when available)
devtools::install_github("authdog/sdk/r")

# Or install from local source
devtools::install(".")
```

## Quick Start

```r
library(authdog)

# Initialize the client
client <- AuthdogClient$new("https://api.authdog.com")

# Get user information
user_info <- client$get_user_info("your-access-token")
print(paste("User:", user_info$user$display_name))

# With optional API key
client <- AuthdogClient$new("https://api.authdog.com", "your-api-key")
user_info <- client$get_user_info("your-access-token")
```

## Error Handling

```r
library(authdog)

client <- AuthdogClient$new()

tryCatch({
  user_info <- client$get_user_info("invalid-token")
}, error = function(e) {
  if (inherits(e, "AuthenticationError")) {
    print("Authentication failed")
  } else if (inherits(e, "ApiError")) {
    print("API error occurred")
  } else {
    print("Unexpected error")
  }
})
```

## API Reference

### AuthdogClient

Main client class for interacting with the Authdog API.

#### Methods

- `initialize(base_url, api_key)` - Create a new client instance
- `get_user_info(access_token)` - Get user information using an access token

### Data Types

- `UserInfoResponse` - Complete user info response
- `User` - User information
- `Email` - Email information
- `Photo` - Photo information
- `Names` - Name information
- `Verification` - Verification information
- `Session` - Session information
- `Meta` - Meta information

### Exceptions

- `AuthdogError` - Base error class
- `AuthenticationError` - Authentication failures
- `ApiError` - API request failures

## Development

### Running Tests

```r
# Install test dependencies
devtools::install_deps(dependencies = TRUE)

# Run tests
devtools::test()

# Run tests with coverage
covr::package_coverage()
```

### Linting

```r
# Install lintr
install.packages("lintr")

# Run linting
lintr::lint_package()
```

## License

MIT License - see [LICENSE](LICENSE) for details.
