# Authdog Go SDK

Go SDK for Authdog authentication and user management.

## Installation

```bash
go get github.com/authdog/go-sdk
```

## Usage

### Basic Usage

```go
package main

import (
    "context"
    "fmt"
    "log"
    
    "github.com/authdog/go-sdk"
)

func main() {
    // Initialize the client
    client := authdog.NewClient(authdog.ClientConfig{
        BaseURL: "https://api.authdog.com",
        APIKey:  "your-api-key", // Optional
        Timeout: 10 * time.Second, // Optional, defaults to 10 seconds
    })

    // Get user information
    ctx := context.Background()
    userInfo, err := client.GetUserInfo(ctx, "your-access-token")
    if err != nil {
        if authdog.IsAuthenticationError(err) {
            log.Printf("Authentication failed: %v", err)
        } else if authdog.IsAPIError(err) {
            log.Printf("API error: %v", err)
        } else {
            log.Printf("Unexpected error: %v", err)
        }
        return
    }

    fmt.Printf("User: %s\n", userInfo.User.DisplayName)
    if len(userInfo.User.Emails) > 0 {
        fmt.Printf("Email: %s\n", userInfo.User.Emails[0].Value)
    }
}
```

### Using with Context

```go
package main

import (
    "context"
    "time"
    
    "github.com/authdog/go-sdk"
)

func getUserData(ctx context.Context, accessToken string) (*authdog.UserInfoResponse, error) {
    client := authdog.NewClient(authdog.ClientConfig{
        BaseURL: "https://api.authdog.com",
    })
    
    // Create a context with timeout
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()
    
    return client.GetUserInfo(ctx, accessToken)
}
```

## API Reference

### Client

#### `NewClient(config ClientConfig) *Client`

Creates a new Authdog client.

**Config Options:**
- `BaseURL` (string): The base URL of the Authdog API
- `APIKey` (string): Optional API key for authentication
- `Timeout` (time.Duration): Request timeout (default: 10 seconds)
- `HTTPClient` (*http.Client): Optional custom HTTP client

#### Methods

##### `GetUserInfo(ctx context.Context, accessToken string) (*UserInfoResponse, error)`

Get user information using an access token.

**Parameters:**
- `ctx` (context.Context): Context for the request
- `accessToken` (string): The access token for authentication

**Returns:** `(*UserInfoResponse, error)` - User information or error

**Response Structure:**
```go
type UserInfoResponse struct {
    Meta    Meta    `json:"meta"`
    Session Session `json:"session"`
    User    User    `json:"user"`
}

type User struct {
    ID                 string        `json:"id"`
    ExternalID         string        `json:"externalId"`
    UserName           string        `json:"userName"`
    DisplayName        string        `json:"displayName"`
    NickName           *string       `json:"nickName"`
    ProfileURL         *string       `json:"profileUrl"`
    Title              *string       `json:"title"`
    UserType           *string       `json:"userType"`
    PreferredLanguage  *string       `json:"preferredLanguage"`
    Locale             string        `json:"locale"`
    Timezone           *string       `json:"timezone"`
    Active             bool          `json:"active"`
    Names              Names         `json:"names"`
    Photos             []Photo       `json:"photos"`
    PhoneNumbers       []interface{} `json:"phoneNumbers"`
    Addresses          []interface{} `json:"addresses"`
    Emails             []Email       `json:"emails"`
    Verifications      []Verification `json:"verifications"`
    Provider           string        `json:"provider"`
    CreatedAt          time.Time     `json:"createdAt"`
    UpdatedAt          string        `json:"updatedAt"`
    EnvironmentID      string        `json:"environmentId"`
}
```

##### `Close()`

Close the HTTP client (for cleanup).

## Error Handling

The SDK provides structured error handling:

- `AuthenticationError`: Raised when authentication fails (401 responses)
- `APIError`: Raised when API requests fail
- `AuthdogError`: Base error type for all SDK errors

**Error Type Checking:**
```go
if authdog.IsAuthenticationError(err) {
    // Handle authentication error
} else if authdog.IsAPIError(err) {
    // Handle API error
} else if authdog.IsAuthdogError(err) {
    // Handle general Authdog error
}
```

## Development

```bash
# Initialize Go module
go mod init github.com/authdog/go-sdk

# Run tests
go test ./...

# Build
go build ./...

# Format code
go fmt ./...

# Lint code
golangci-lint run
```

## Dependencies

This SDK has no external dependencies and uses only the Go standard library.
