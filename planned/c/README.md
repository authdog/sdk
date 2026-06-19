# Authdog C SDK

A C library for interacting with the Authdog API.

## Features

- User information retrieval
- HTTP client with libcurl
- Memory management
- Error handling
- Cross-platform support

## Dependencies

- libcurl (for HTTP requests)
- CMake 3.10+ (for building)

## Building

```bash
mkdir build
cd build
cmake ..
make
```

## Running Tests

```bash
make test
# or
./test_authdog
```

## Usage Example

```c
#include "authdog.h"
#include <stdio.h>

int main() {
    // Create client configuration
    authdog_config_t config = {
        .base_url = "https://api.authdog.com",
        .access_token = "your_access_token_here",
        .api_key = NULL,
        .timeout_ms = 10000
    };
    
    // Create client
    authdog_client_t *client = authdog_client_create(&config);
    if (!client) {
        printf("Failed to create client\n");
        return 1;
    }
    
    // Get user info
    authdog_user_info_t *user_info = NULL;
    authdog_error_t error = authdog_get_user_info(client, &user_info);
    
    if (error == AUTHDOG_SUCCESS && user_info) {
        printf("User ID: %s\n", user_info->id);
        printf("Email: %s\n", user_info->email);
        
        // Free user info
        authdog_user_info_free(user_info);
    } else {
        printf("Error: %s\n", authdog_error_message(error));
    }
    
    // Clean up client
    authdog_client_destroy(client);
    
    return 0;
}
```

## API Reference

### Functions

- `authdog_client_create()` - Create a new client instance
- `authdog_client_destroy()` - Destroy a client instance
- `authdog_get_user_info()` - Get user information
- `authdog_user_info_free()` - Free user info structure
- `authdog_error_message()` - Get error message for error code

### Error Codes

- `AUTHDOG_SUCCESS` - Success
- `AUTHDOG_ERROR_INVALID_PARAM` - Invalid parameter
- `AUTHDOG_ERROR_MEMORY_ALLOCATION` - Memory allocation failed
- `AUTHDOG_ERROR_NETWORK` - Network error
- `AUTHDOG_ERROR_AUTHENTICATION` - Authentication failed
- `AUTHDOG_ERROR_SERVER` - Server error
- `AUTHDOG_ERROR_UNKNOWN` - Unknown error

## License

See LICENSE file for details.
