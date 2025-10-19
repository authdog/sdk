# Authdog SDK

Official SDKs for Authdog authentication and user management platform.

[![Python SDK Tests](https://github.com/authdog/sdk/actions/workflows/python-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/python-test.yml)
[![Node.js SDK Tests](https://github.com/authdog/sdk/actions/workflows/node-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/node-test.yml)
[![Go SDK Tests](https://github.com/authdog/sdk/actions/workflows/go-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/go-test.yml)
[![Java SDK Tests](https://github.com/authdog/sdk/actions/workflows/java-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/java-test.yml)
[![C# SDK Tests](https://github.com/authdog/sdk/actions/workflows/csharp-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/csharp-test.yml)
[![C++ SDK Tests](https://github.com/authdog/sdk/actions/workflows/cpp-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/cpp-test.yml)
[![Kotlin SDK Tests](https://github.com/authdog/sdk/actions/workflows/kotlin-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/kotlin-test.yml)
[![Rust SDK Tests](https://github.com/authdog/sdk/actions/workflows/rust-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/rust-test.yml)
[![PHP Tests](https://github.com/authdog/sdk/actions/workflows/php-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/php-test.yml)
[![Elixir Tests](https://github.com/authdog/sdk/actions/workflows/elixir-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/elixir-test.yml)
[![Scala Tests](https://github.com/authdog/sdk/actions/workflows/scala-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/scala-test.yml)
[![Clojure Tests](https://github.com/authdog/sdk/actions/workflows/clojure-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/clojure-test.yml)
[![Common Lisp Tests](https://github.com/authdog/sdk/actions/workflows/commonlisp-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/commonlisp-test.yml)
[![Swift Tests](https://github.com/authdog/sdk/actions/workflows/swift-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/swift-test.yml)
[![Zig Tests](https://github.com/authdog/sdk/actions/workflows/zig-test.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/zig-test.yml)
[![F# SDK](https://github.com/authdog/sdk/actions/workflows/fsharp.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/fsharp.yml)
[![Ruby SDK](https://github.com/authdog/sdk/actions/workflows/ruby.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/ruby.yml)
[![OCaml SDK](https://github.com/authdog/sdk/actions/workflows/ocaml.yml/badge.svg)](https://github.com/authdog/sdk/actions/workflows/ocaml.yml)

## Available SDKs

- [Python SDK](./python/) - Python SDK for Authdog
- [Node.js SDK](./node/) - Node.js/TypeScript SDK for Authdog
- [Go SDK](./go/) - Go SDK for Authdog
- [Kotlin SDK](./kotlin/) - Kotlin SDK for Authdog
- [Rust SDK](./rust/) - Rust SDK for Authdog
- [PHP SDK](./php/) - PHP SDK for Authdog
- [C# SDK](./csharp/) - C# SDK for Authdog
- [C++ SDK](./cpp/) - C++ SDK for Authdog
- [Elixir SDK](./elixir/) - Elixir SDK for Authdog
- [Java SDK](./java/) - Java SDK for Authdog
- [Scala SDK](./scala/) - Scala SDK for Authdog
- [Common Lisp SDK](./commonlisp/) - Common Lisp SDK for Authdog
- [Clojure SDK](./clojure/) - Clojure SDK for Authdog
- [Swift SDK](./swift/) - Swift SDK for Authdog
- [Zig SDK](./zig/) - Zig SDK for Authdog

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

### PHP

```php
<?php

require_once 'vendor/autoload.php';

use Authdog\AuthdogClient;
use Authdog\Exceptions\AuthenticationException;
use Authdog\Exceptions\ApiException;

// Initialize the client
$client = new AuthdogClient('https://api.authdog.com');

try {
    // Get user information
    $userInfo = $client->getUserInfo('your-access-token');
    echo "User: " . $userInfo->user->displayName . "\n";
} catch (AuthenticationException $e) {
    echo "Authentication failed: " . $e->getMessage() . "\n";
} catch (ApiException $e) {
    echo "API error: " . $e->getMessage() . "\n";
}

// Always close the client
$client->close();
```

### C#

```csharp
using Authdog;
using Authdog.Exceptions;

// Initialize the client
var client = new AuthdogClient("https://api.authdog.com");

try
{
    // Get user information
    var userInfo = await client.GetUserInfoAsync("your-access-token");
    Console.WriteLine($"User: {userInfo.User.DisplayName}");
}
catch (AuthenticationException ex)
{
    Console.WriteLine($"Authentication failed: {ex.Message}");
}
catch (ApiException ex)
{
    Console.WriteLine($"API error: {ex.Message}");
}
finally
{
    // Always dispose the client
    client.Dispose();
}
```

### C++

```cpp
#include <iostream>
#include "authdog/authdog_client.h"
#include "authdog/exceptions.h"

int main() {
    try {
        // Initialize the client
        authdog::AuthdogClient client("https://api.authdog.com");
        
        // Get user information
        auto userInfo = client.getUserInfo("your-access-token");
        std::cout << "User: " << userInfo.user.displayName << std::endl;
        
        // Close the client
        client.close();
        
    } catch (const authdog::AuthenticationException& e) {
        std::cerr << "Authentication failed: " << e.what() << std::endl;
    } catch (const authdog::ApiException& e) {
        std::cerr << "API error: " << e.what() << std::endl;
    }
    
    return 0;
}
```

### Elixir

```elixir
# Initialize the client
client = Authdog.Client.new("https://api.authdog.com")

# Get user information
case Authdog.Client.get_user_info(client, "your-access-token") do
  {:ok, user_info} ->
    IO.puts("User: #{user_info.user.display_name}")
  {:error, :authentication_error, message} ->
    IO.puts("Authentication failed: #{message}")
  {:error, :api_error, message} ->
    IO.puts("API error: #{message}")
end
```

### Java

```java
import com.authdog.AuthdogClient;
import com.authdog.exceptions.AuthenticationException;
import com.authdog.exceptions.ApiException;

// Initialize the client
try (AuthdogClient client = new AuthdogClient("https://api.authdog.com")) {
    // Get user information
    UserInfoResponse userInfo = client.getUserInfo("your-access-token");
    System.out.println("User: " + userInfo.getUser().getDisplayName());
} catch (AuthenticationException e) {
    System.err.println("Authentication failed: " + e.getMessage());
} catch (ApiException e) {
    System.err.println("API error: " + e.getMessage());
}
```

### Scala

```scala
import com.authdog.AuthdogClient
import com.authdog.exceptions.{AuthenticationException, ApiException}

// Initialize the client
val client = AuthdogClient("https://api.authdog.com")

try {
  // Get user information
  val userInfo = client.getUserInfo("your-access-token")
  println(s"User: ${userInfo.user.displayName}")
} catch {
  case e: AuthenticationException => 
    println(s"Authentication failed: ${e.getMessage}")
  case e: ApiException => 
    println(s"API error: ${e.getMessage}")
} finally {
  client.close()
}
```

### Common Lisp

```lisp
(ql:quickload :authdog)
(use-package :authdog)

;; Initialize the client
(defvar *client* (make-authdog-client "https://api.authdog.com"))

;; Get user information
(handler-case
    (let ((user-info (get-user-info *client* "your-access-token")))
      (format t "User: ~A~%" (user-display-name (user-info-response-user user-info))))
  (authentication-error (e)
    (format t "Authentication failed: ~A~%" (authdog-error-message e)))
  (api-error (e)
    (format t "API error: ~A~%" (authdog-error-message e))))
```

### Clojure

```clojure
(require '[authdog.core :as authdog]
         '[authdog.exceptions :as ex])

;; Initialize the client
(def client (authdog/make-client "https://api.authdog.com"))

;; Get user information
(try
  (let [user-info (authdog/get-user-info client "your-access-token")]
    (println "User:" (:display-name (:user user-info))))
  (catch clojure.lang.ExceptionInfo e
    (cond
      (ex/authentication-error? e)
      (println "Authentication failed:" (.getMessage e))
      
      (ex/api-error? e)
      (println "API error:" (.getMessage e)))))
```

### Swift

```swift
import AuthdogSwiftSDK

// Initialize the client
let client = AuthdogClient(baseURL: "https://api.authdog.com")

// Get user information (async/await)
Task {
    do {
        let userInfo = try await client.getUserInfo(accessToken: "your-access-token")
        print("User: \(userInfo.user.displayName)")
    } catch AuthdogError.authenticationFailed(let message) {
        print("Authentication failed: \(message)")
    } catch AuthdogError.apiError(let message) {
        print("API error: \(message)")
    }
}

// Get user information (completion handler)
client.getUserInfo(accessToken: "your-access-token") { result in
    switch result {
    case .success(let userInfo):
        print("User: \(userInfo.user.displayName)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

### Zig

```zig
const authdog = @import("authdog");

// Initialize the client
var client = authdog.AuthdogClient.init("https://api.authdog.com", .{});

// Get user information
const user_info = client.getUserInfo("your-access-token") catch |err| switch (err) {
    error.AuthenticationFailed => {
        std.debug.print("Authentication failed\n", .{});
        return;
    },
    error.ApiError => {
        std.debug.print("API error\n", .{});
        return;
    },
    else => {
        std.debug.print("Unexpected error: {}\n", .{err});
        return;
    },
};

std.debug.print("User: {s}\n", .{user_info.user.display_name});
```

## Features

- **User Information**: Get detailed user information including profile data, emails, photos, and verification status
- **Authentication**: Handle authentication errors and token validation
- **Type Safety**: Full type support across all languages (TypeScript, Go, Kotlin, Rust)
- **Error Handling**: Structured error handling with specific exception types
- **Modern APIs**: Built with modern HTTP clients and async/await support
- **Cross-Platform**: Available for Python, Node.js, Go, Kotlin, Rust, PHP, C#, C++, Elixir, Java, Scala, Common Lisp, Clojure, Swift, and Zig

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
- [PHP SDK Development](./php/README.md#development)
- [C# SDK Development](./csharp/README.md#development)
- [C++ SDK Development](./cpp/README.md#development)
- [Elixir SDK Development](./elixir/README.md#development)
- [Java SDK Development](./java/README.md#development)
- [Scala SDK Development](./scala/README.md#development)
- [Common Lisp SDK Development](./commonlisp/README.md#development)
- [Clojure SDK Development](./clojure/README.md#development)
- [Swift SDK Development](./swift/README.md#development)
- [Zig SDK Development](./zig/README.md#development)

## Contributing

Please see our [Contributing Guide](CONTRIBUTING.md) for details on how to contribute to the SDKs.

## License

MIT License - see [LICENSE](LICENSE) for details.

