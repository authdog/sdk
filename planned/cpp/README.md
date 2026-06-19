# Authdog C++ SDK

Official C++ SDK for Authdog authentication and user management platform.

## Requirements

- C++17 or higher
- CMake 3.16 or higher
- [nlohmann/json](https://github.com/nlohmann/json) - JSON library
- [cpr](https://github.com/libcpr/cpr) - HTTP client library

## Installation

### Using Conan (Recommended)

```bash
# Install dependencies
conan install . --build=missing

# Build the project
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build .
```

### Using vcpkg

```bash
# Install dependencies
vcpkg install nlohmann-json cpr

# Build the project
mkdir build && cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake
cmake --build .
```

### Manual Installation

```bash
# Install nlohmann/json
git clone https://github.com/nlohmann/json.git
cd json
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local
make install

# Install cpr
git clone https://github.com/libcpr/cpr.git
cd cpr
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local
make install

# Build Authdog SDK
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build .
```

## Quick Start

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

## Configuration

### Basic Configuration

```cpp
authdog::AuthdogClient client("https://api.authdog.com");
```

### Advanced Configuration

```cpp
authdog::ClientConfig config;
config.baseUrl = "https://api.authdog.com";
config.apiKey = "your-api-key";  // Optional
config.timeoutSeconds = 30;

authdog::AuthdogClient client(config);
```

## API Reference

### AuthdogClient

#### Constructor

```cpp
// Simple constructor
AuthdogClient(const std::string& baseUrl);

// Advanced constructor
AuthdogClient(const ClientConfig& config);
```

#### Methods

##### getUserInfo

```cpp
UserInfoResponse getUserInfo(const std::string& accessToken);
```

Get user information using an access token.

**Parameters:**
- `accessToken`: The access token for authentication

**Returns:** `UserInfoResponse` containing user information

**Throws:**
- `AuthenticationException`: When authentication fails (401 responses)
- `ApiException`: When API request fails

##### close

```cpp
void close();
```

Close the HTTP client (for cleanup).

## Data Types

### UserInfoResponse

```cpp
struct UserInfoResponse {
    Meta meta;
    Session session;
    User user;
};
```

### User

```cpp
struct User {
    std::string id;
    std::string externalId;
    std::string userName;
    std::string displayName;
    std::optional<std::string> nickName;
    std::optional<std::string> profileUrl;
    std::optional<std::string> title;
    std::optional<std::string> userType;
    std::optional<std::string> preferredLanguage;
    std::string locale;
    std::optional<std::string> timezone;
    bool active;
    Names names;
    std::vector<Photo> photos;
    std::vector<nlohmann::json> phoneNumbers;
    std::vector<nlohmann::json> addresses;
    std::vector<Email> emails;
    std::vector<Verification> verifications;
    std::string provider;
    std::string createdAt;
    std::string updatedAt;
    std::string environmentId;
};
```

### Names

```cpp
struct Names {
    std::string id;
    std::optional<std::string> formatted;
    std::string familyName;
    std::string givenName;
    std::optional<std::string> middleName;
    std::optional<std::string> honorificPrefix;
    std::optional<std::string> honorificSuffix;
};
```

### Email

```cpp
struct Email {
    std::string id;
    std::string value;
    std::optional<std::string> type;
};
```

### Photo

```cpp
struct Photo {
    std::string id;
    std::string value;
    std::string type;
};
```

### Verification

```cpp
struct Verification {
    std::string id;
    std::string email;
    bool verified;
    std::string createdAt;
    std::string updatedAt;
};
```

## Error Handling

The SDK provides structured error handling with specific exception types:

### AuthenticationException

Thrown when authentication fails (401 responses).

```cpp
try {
    auto userInfo = client.getUserInfo("invalid-token");
} catch (const authdog::AuthenticationException& e) {
    std::cerr << "Authentication failed: " << e.what() << std::endl;
}
```

### ApiException

Thrown when API requests fail.

```cpp
try {
    auto userInfo = client.getUserInfo("valid-token");
} catch (const authdog::ApiException& e) {
    std::cerr << "API error: " << e.what() << std::endl;
}
```

### AuthdogException

Base exception class for all SDK errors.

```cpp
try {
    auto userInfo = client.getUserInfo("token");
} catch (const authdog::AuthdogException& e) {
    std::cerr << "Authdog error: " << e.what() << std::endl;
}
```

## Examples

### Basic Usage

```cpp
#include <iostream>
#include "authdog/authdog_client.h"

int main() {
    authdog::AuthdogClient client("https://api.authdog.com");
    
    auto userInfo = client.getUserInfo("your-access-token");
    
    std::cout << "User ID: " << userInfo.user.id << std::endl;
    std::cout << "Display Name: " << userInfo.user.displayName << std::endl;
    std::cout << "Provider: " << userInfo.user.provider << std::endl;
    
    if (!userInfo.user.emails.empty()) {
        std::cout << "Email: " << userInfo.user.emails[0].value << std::endl;
    }
    
    client.close();
    return 0;
}
```

### Error Handling

```cpp
#include <iostream>
#include "authdog/authdog_client.h"
#include "authdog/exceptions.h"

int main() {
    authdog::AuthdogClient client("https://api.authdog.com");
    
    try {
        auto userInfo = client.getUserInfo("your-access-token");
        std::cout << "Success: " << userInfo.user.displayName << std::endl;
    } catch (const authdog::AuthenticationException& e) {
        std::cerr << "Authentication failed: " << e.what() << std::endl;
        // Handle authentication error
    } catch (const authdog::ApiException& e) {
        std::cerr << "API error: " << e.what() << std::endl;
        // Handle API error
    } finally {
        client.close();
    }
    
    return 0;
}
```

### RAII Usage

```cpp
#include <iostream>
#include "authdog/authdog_client.h"

void processUser() {
    // Client is automatically cleaned up when it goes out of scope
    authdog::AuthdogClient client("https://api.authdog.com");
    
    try {
        auto userInfo = client.getUserInfo("your-access-token");
        
        std::cout << "=== User Information ===" << std::endl;
        std::cout << "ID: " << userInfo.user.id << std::endl;
        std::cout << "Display Name: " << userInfo.user.displayName << std::endl;
        std::cout << "Username: " << userInfo.user.userName << std::endl;
        std::cout << "Provider: " << userInfo.user.provider << std::endl;
        std::cout << "Active: " << (userInfo.user.active ? "Yes" : "No") << std::endl;
        
        if (!userInfo.user.emails.empty()) {
            std::cout << "\n=== Emails ===" << std::endl;
            for (const auto& email : userInfo.user.emails) {
                std::cout << "- " << email.value;
                if (email.type) {
                    std::cout << " (" << *email.type << ")";
                }
                std::cout << std::endl;
            }
        }
        
        if (!userInfo.user.photos.empty()) {
            std::cout << "\n=== Photos ===" << std::endl;
            for (const auto& photo : userInfo.user.photos) {
                std::cout << "- " << photo.value << " (" << photo.type << ")" << std::endl;
            }
        }
        
    } catch (const authdog::AuthenticationException& e) {
        std::cerr << "Authentication failed: " << e.what() << std::endl;
    } catch (const authdog::ApiException& e) {
        std::cerr << "API error: " << e.what() << std::endl;
    }
    
    // Client is automatically closed here
}

int main() {
    processUser();
    return 0;
}
```

### Move Semantics

```cpp
#include <iostream>
#include "authdog/authdog_client.h"

authdog::AuthdogClient createClient() {
    return authdog::AuthdogClient("https://api.authdog.com");
}

int main() {
    // Move constructor
    auto client = createClient();
    
    try {
        auto userInfo = client.getUserInfo("your-access-token");
        std::cout << "User: " << userInfo.user.displayName << std::endl;
    } catch (const authdog::ApiException& e) {
        std::cerr << "Error: " << e.what() << std::endl;
    }
    
    return 0;
}
```

## Building and Testing

### Build the Library

```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build .
```

### Run Tests

```bash
# Build tests
cmake .. -DCMAKE_BUILD_TYPE=Debug
cmake --build .

# Run tests
ctest --output-on-failure
```

### Build Example

```bash
# Build example
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . --target authdog_example

# Run example
./authdog_example
```

## Integration with Other Projects

### CMake Integration

```cmake
# Find the Authdog C++ SDK
find_package(AuthdogCppSdk REQUIRED)

# Link against the library
target_link_libraries(your_target authdog_cpp_sdk)
```

### Conan Integration

```python
# conanfile.txt
[requires]
authdog-cpp-sdk/0.1.0

[generators]
CMakeDeps
CMakeToolchain
```

## Development

### Requirements

- C++17 compiler (GCC 7+, Clang 5+, MSVC 2017+)
- CMake 3.16+
- nlohmann/json
- cpr
- Google Test (for testing)

### Code Style

- Follow Google C++ Style Guide
- Use `clang-format` for formatting
- Use `clang-tidy` for static analysis
- Maximum line length: 100 characters
- Use `const` wherever possible
- Prefer `std::string_view` for read-only string parameters

### Running Tests

```bash
# Install Google Test
# Ubuntu/Debian
sudo apt-get install libgtest-dev

# macOS
brew install googletest

# Build and run tests
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
cmake --build .
ctest --output-on-failure
```

## License

MIT License - see [LICENSE](../LICENSE) for details.
