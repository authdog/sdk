# Authdog SDK

Official SDKs for Authdog authentication and user management platform.

## Available SDKs

- [Python SDK](./python/) - Python SDK for Authdog
- [Node.js SDK](./node/) - Node.js/TypeScript SDK for Authdog
- [Go SDK](./go/) - Go SDK for Authdog
- [Kotlin SDK](./kotlin/) - Kotlin SDK for Authdog
- [Rust SDK](./rust/) - Rust SDK for Authdog

## Quick Start

### Python

```python
from authdog import AuthdogClient

# Initialize the client
client = AuthdogClient("https://api.authdog.com")

# Get user information
user_info = client.get_userinfo("your-access-token")
print(f"User: {user_info['user']['displayName']}")

# Always close the client
client.close()
```

### Node.js

```typescript
import { AuthdogClient } from '@authdog/node-sdk';

// Initialize the client
const client = new AuthdogClient({
  baseUrl: 'https://api.authdog.com'
});

// Get user information
const userInfo = await client.getUserInfo('your-access-token');
console.log(`User: ${userInfo.user.displayName}`);
```

### Go

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
    })

    // Get user information
    ctx := context.Background()
    userInfo, err := client.GetUserInfo(ctx, "your-access-token")
    if err != nil {
        log.Fatal(err)
    }

    fmt.Printf("User: %s\n", userInfo.User.DisplayName)
}
```

### Kotlin

```kotlin
import com.authdog.sdk.*
import kotlinx.coroutines.runBlocking

fun main() = runBlocking {
    // Initialize the client
    val client = AuthdogClient(
        AuthdogClientConfig(
            baseUrl = "https://api.authdog.com",
            apiKey = "your-api-key" // Optional
        )
    )

    // Get user information
    val userInfo = client.getUserInfo("your-access-token")
    println("User: ${userInfo.user.displayName}")
}
```

### Rust

```rust
use authdog::{AuthdogClient, AuthdogClientConfig};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Initialize the client
    let config = AuthdogClientConfig {
        base_url: "https://api.authdog.com".to_string(),
        api_key: Some("your-api-key".to_string()), // Optional
        ..Default::default()
    };
    
    let client = AuthdogClient::new(config)?;

    // Get user information
    let user_info = client.get_user_info("your-access-token").await?;
    println!("User: {}", user_info.user.display_name);

    Ok(())
}
```

## Features

- **User Information**: Get detailed user information including profile data, emails, photos, and verification status
- **Authentication**: Handle authentication errors and token validation
- **Type Safety**: Full type support across all languages (TypeScript, Go, Kotlin, Rust)
- **Error Handling**: Structured error handling with specific exception types
- **Modern APIs**: Built with modern HTTP clients and async/await support
- **Cross-Platform**: Available for Python, Node.js, Go, Kotlin, and Rust

## API Endpoints

All SDKs support the following endpoint:

### GET /v1/userinfo

Retrieve user information using an access token.

**Authentication**: Bearer token required

**Response Structure**:
```json
{
  "meta": {
    "code": 200,
    "message": "Success"
  },
  "session": {
    "remainingSeconds": 56229
  },
  "user": {
    "id": "user-id",
    "externalId": "external-id",
    "userName": "username",
    "displayName": "Display Name",
    "emails": [{"value": "email@example.com", "type": null}],
    "photos": [{"value": "https://example.com/photo.jpg", "type": "photo"}],
    "names": {
      "familyName": "Last",
      "givenName": "First"
    },
    "verifications": [...],
    "provider": "google-oauth20",
    "environmentId": "env-id"
  }
}
```

## Error Handling

All SDKs provide structured error handling:

- `AuthenticationError`: Raised when authentication fails (401 responses)
- `APIError`: Raised when API requests fail
- Base `AuthdogError`: Common base class for all SDK errors

## Development

Each SDK has its own development setup. See the individual README files:

- [Python SDK Development](./python/README.md#development)
- [Node.js SDK Development](./node/README.md#development)
- [Go SDK Development](./go/README.md#development)
- [Kotlin SDK Development](./kotlin/README.md#development)
- [Rust SDK Development](./rust/README.md#development)

## Contributing

Please see our [Contributing Guide](CONTRIBUTING.md) for details on how to contribute to the SDKs.

## License

MIT License - see [LICENSE](LICENSE) for details.

