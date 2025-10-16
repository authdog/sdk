# Authdog Rust SDK

Rust SDK for Authdog authentication and user management.

## Installation

Add this to your `Cargo.toml`:

```toml
[dependencies]
authdog = "0.1.0"
```

## Usage

### Basic Usage

```rust
use authdog::{AuthdogClient, AuthdogClientConfig, AuthdogError, AuthenticationError, APIError};
use std::time::Duration;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Initialize the client
    let config = AuthdogClientConfig {
        base_url: "https://api.authdog.com".to_string(),
        api_key: Some("your-api-key".to_string()), // Optional
        timeout: Some(Duration::from_secs(10)), // Optional, defaults to 10 seconds
    };
    
    let client = AuthdogClient::new(config)?;

    // Get user information
    match client.get_user_info("your-access-token").await {
        Ok(user_info) => {
            println!("User: {}", user_info.user.display_name);
            if let Some(email) = user_info.user.emails.first() {
                println!("Email: {}", email.value);
            }
        }
        Err(e) => {
            if e.to_string().contains("Unauthorized") {
                println!("Authentication failed: {}", e);
            } else {
                println!("API error: {}", e);
            }
        }
    }

    Ok(())
}
```

### Using with Error Handling

```rust
use authdog::{AuthdogClient, AuthdogClientConfig, AuthdogError, AuthenticationError, APIError};

async fn get_user_data(access_token: &str) -> Result<(), Box<dyn std::error::Error>> {
    let config = AuthdogClientConfig {
        base_url: "https://api.authdog.com".to_string(),
        ..Default::default()
    };
    
    let client = AuthdogClient::new(config)?;
    
    match client.get_user_info(access_token).await {
        Ok(user_info) => {
            println!("User ID: {}", user_info.user.id);
            println!("Display Name: {}", user_info.user.display_name);
            println!("Provider: {}", user_info.user.provider);
            println!("Session remaining: {} seconds", user_info.session.remaining_seconds);
            
            for email in &user_info.user.emails {
                println!("Email: {} (verified: {})", 
                    email.value, 
                    user_info.user.verifications.iter()
                        .any(|v| v.email == email.value && v.verified)
                );
            }
        }
        Err(e) => {
            eprintln!("Error: {}", e);
        }
    }
    
    Ok(())
}
```

## API Reference

### AuthdogClient

#### `new(config: AuthdogClientConfig) -> Result<Self, AuthdogError>`

Creates a new Authdog client.

**Config Options:**
- `base_url` (String): The base URL of the Authdog API
- `api_key` (Option<String>): Optional API key for authentication
- `timeout` (Option<Duration>): Request timeout (default: 10 seconds)

#### Methods

##### `async fn get_user_info(&self, access_token: &str) -> Result<UserInfoResponse, AuthdogError>`

Get user information using an access token.

**Parameters:**
- `access_token` (&str): The access token for authentication

**Returns:** `Result<UserInfoResponse, AuthdogError>` - User information or error

**Response Structure:**
```rust
pub struct UserInfoResponse {
    pub meta: Meta,
    pub session: Session,
    pub user: User,
}

pub struct User {
    pub id: String,
    pub external_id: String,
    pub user_name: String,
    pub display_name: String,
    pub nick_name: Option<String>,
    pub profile_url: Option<String>,
    pub title: Option<String>,
    pub user_type: Option<String>,
    pub preferred_language: Option<String>,
    pub locale: String,
    pub timezone: Option<String>,
    pub active: bool,
    pub names: Names,
    pub photos: Vec<Photo>,
    pub phone_numbers: Vec<serde_json::Value>,
    pub addresses: Vec<serde_json::Value>,
    pub emails: Vec<Email>,
    pub verifications: Vec<Verification>,
    pub provider: String,
    pub created_at: String,
    pub updated_at: String,
    pub environment_id: String,
}
```

## Error Handling

The SDK provides structured error handling:

- `AuthenticationError`: Raised when authentication fails (401 responses)
- `APIError`: Raised when API requests fail
- `AuthdogError`: Base error type for all SDK errors

**Error Handling Example:**
```rust
match client.get_user_info(access_token).await {
    Ok(user_info) => {
        // Handle success
    }
    Err(e) => {
        if e.to_string().contains("Unauthorized") {
            // Handle authentication error
        } else {
            // Handle API error
        }
    }
}
```

## Dependencies

- `reqwest` - HTTP client
- `serde` - Serialization/deserialization
- `tokio` - Async runtime

## Development

```bash
# Build the project
cargo build

# Run tests
cargo test

# Run examples
cargo run --example basic

# Format code
cargo fmt

# Lint code
cargo clippy
```

## Async Support

This SDK is built with async/await and requires the `tokio` runtime. Make sure to use `#[tokio::main]` or run within a tokio runtime:

```rust
#[tokio::main]
async fn main() {
    // Your async code here
}

// Or within a tokio runtime
tokio::runtime::Runtime::new().unwrap().block_on(async {
    // Your async code here
});
```

## Examples

See the `examples/` directory for more usage examples:

- `basic.rs` - Basic usage example
- `error_handling.rs` - Error handling example
