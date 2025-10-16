# Authdog Java SDK

Official Java SDK for Authdog authentication and user management platform.

## Installation

### Maven

Add the following dependency to your `pom.xml`:

```xml
<dependency>
    <groupId>com.authdog</groupId>
    <artifactId>authdog-java-sdk</artifactId>
    <version>0.1.0</version>
</dependency>
```

### Gradle

Add the following dependency to your `build.gradle`:

```gradle
implementation 'com.authdog:authdog-java-sdk:0.1.0'
```

## Requirements

- Java 11 or higher
- OkHttp HTTP client
- Jackson JSON library

## Quick Start

```java
import com.authdog.AuthdogClient;
import com.authdog.exceptions.AuthenticationException;
import com.authdog.exceptions.ApiException;
import com.authdog.types.UserInfoResponse;

public class Example {
    public static void main(String[] args) {
        try (AuthdogClient client = new AuthdogClient("https://api.authdog.com")) {
            // Get user information
            UserInfoResponse userInfo = client.getUserInfo("your-access-token");
            System.out.println("User: " + userInfo.getUser().getDisplayName());
        } catch (AuthenticationException e) {
            System.err.println("Authentication failed: " + e.getMessage());
        } catch (ApiException e) {
            System.err.println("API error: " + e.getMessage());
        }
    }
}
```

## Configuration

### Basic Configuration

```java
AuthdogClient client = new AuthdogClient("https://api.authdog.com");
```

### With API Key

```java
AuthdogClient client = new AuthdogClient("https://api.authdog.com", "your-api-key");
```

### Custom Timeout

```java
AuthdogClient client = new AuthdogClient("https://api.authdog.com", "your-api-key", 30000);
```

## API Reference

### AuthdogClient

#### Constructors

```java
// Simple constructor
public AuthdogClient(String baseUrl)

// With API key
public AuthdogClient(String baseUrl, String apiKey)

// With API key and custom timeout
public AuthdogClient(String baseUrl, String apiKey, int timeoutMs)
```

#### Methods

##### getUserInfo

```java
public UserInfoResponse getUserInfo(String accessToken) 
    throws AuthenticationException, ApiException
```

Get user information using an access token.

**Parameters:**
- `accessToken`: The access token for authentication

**Returns:** `UserInfoResponse` containing user information

**Throws:**
- `AuthenticationException`: When authentication fails (401 responses)
- `ApiException`: When API request fails

##### close

```java
public void close()
```

Close the HTTP client and release resources. Implements `AutoCloseable`.

## Data Types

### UserInfoResponse

```java
public class UserInfoResponse {
    private Meta meta;
    private Session session;
    private User user;
    
    // Getters and setters...
}
```

### User

```java
public class User {
    private String id;
    private String externalId;
    private String userName;
    private String displayName;
    private String nickName;
    private String profileUrl;
    private String title;
    private String userType;
    private String preferredLanguage;
    private String locale;
    private String timezone;
    private boolean active;
    private Names names;
    private List<Photo> photos;
    private List<Object> phoneNumbers;
    private List<Object> addresses;
    private List<Email> emails;
    private List<Verification> verifications;
    private String provider;
    private String createdAt;
    private String updatedAt;
    private String environmentId;
    
    // Getters and setters...
}
```

### Names

```java
public class Names {
    private String id;
    private String formatted;
    private String familyName;
    private String givenName;
    private String middleName;
    private String honorificPrefix;
    private String honorificSuffix;
    
    // Getters and setters...
}
```

### Email

```java
public class Email {
    private String id;
    private String value;
    private String type;
    
    // Getters and setters...
}
```

### Photo

```java
public class Photo {
    private String id;
    private String value;
    private String type;
    
    // Getters and setters...
}
```

### Verification

```java
public class Verification {
    private String id;
    private String email;
    private boolean verified;
    private String createdAt;
    private String updatedAt;
    
    // Getters and setters...
}
```

## Error Handling

The SDK provides structured error handling with specific exception types:

### AuthenticationException

Thrown when authentication fails (401 responses).

```java
try {
    UserInfoResponse userInfo = client.getUserInfo("invalid-token");
} catch (AuthenticationException e) {
    System.err.println("Authentication failed: " + e.getMessage());
}
```

### ApiException

Thrown when API requests fail.

```java
try {
    UserInfoResponse userInfo = client.getUserInfo("valid-token");
} catch (ApiException e) {
    System.err.println("API error: " + e.getMessage());
}
```

### AuthdogException

Base exception class for all SDK errors.

```java
try {
    UserInfoResponse userInfo = client.getUserInfo("token");
} catch (AuthdogException e) {
    System.err.println("Authdog error: " + e.getMessage());
}
```

## Examples

### Basic Usage

```java
import com.authdog.AuthdogClient;
import com.authdog.types.UserInfoResponse;

public class BasicExample {
    public static void main(String[] args) {
        try (AuthdogClient client = new AuthdogClient("https://api.authdog.com")) {
            UserInfoResponse userInfo = client.getUserInfo("your-access-token");
            
            System.out.println("User ID: " + userInfo.getUser().getId());
            System.out.println("Display Name: " + userInfo.getUser().getDisplayName());
            System.out.println("Provider: " + userInfo.getUser().getProvider());
            
            if (!userInfo.getUser().getEmails().isEmpty()) {
                System.out.println("Email: " + userInfo.getUser().getEmails().get(0).getValue());
            }
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}
```

### Error Handling

```java
import com.authdog.AuthdogClient;
import com.authdog.exceptions.AuthenticationException;
import com.authdog.exceptions.ApiException;

public class ErrorHandlingExample {
    public static void main(String[] args) {
        try (AuthdogClient client = new AuthdogClient("https://api.authdog.com")) {
            UserInfoResponse userInfo = client.getUserInfo("your-access-token");
            System.out.println("Success: " + userInfo.getUser().getDisplayName());
        } catch (AuthenticationException e) {
            System.err.println("Authentication failed: " + e.getMessage());
            // Handle authentication error
        } catch (ApiException e) {
            System.err.println("API error: " + e.getMessage());
            // Handle API error
        }
    }
}
```

### Spring Boot Integration

```java
import com.authdog.AuthdogClient;
import com.authdog.exceptions.AuthenticationException;
import com.authdog.exceptions.ApiException;
import com.authdog.types.UserInfoResponse;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

@RestController
@RequestMapping("/api/users")
public class UserController {
    
    private final AuthdogClient authdogClient;
    
    public UserController() {
        this.authdogClient = new AuthdogClient("https://api.authdog.com");
    }
    
    @GetMapping("/info")
    public ResponseEntity<?> getUserInfo(@RequestParam String accessToken) {
        try {
            UserInfoResponse userInfo = authdogClient.getUserInfo(accessToken);
            
            return ResponseEntity.ok(Map.of(
                "id", userInfo.getUser().getId(),
                "displayName", userInfo.getUser().getDisplayName(),
                "email", getPrimaryEmail(userInfo.getUser().getEmails()),
                "provider", userInfo.getUser().getProvider()
            ));
        } catch (AuthenticationException e) {
            return ResponseEntity.status(401).body(Map.of("error", "Authentication failed"));
        } catch (ApiException e) {
            return ResponseEntity.status(400).body(Map.of("error", e.getMessage()));
        }
    }
    
    private String getPrimaryEmail(List<Email> emails) {
        return emails.isEmpty() ? null : emails.get(0).getValue();
    }
}
```

### Service Class Example

```java
import com.authdog.AuthdogClient;
import com.authdog.exceptions.AuthenticationException;
import com.authdog.exceptions.ApiException;
import com.authdog.types.UserInfoResponse;
import java.util.Map;
import java.util.HashMap;

public class UserService {
    private final AuthdogClient client;
    
    public UserService(String baseUrl, String apiKey) {
        this.client = new AuthdogClient(baseUrl, apiKey);
    }
    
    public Map<String, Object> getUserInfo(String accessToken) throws AuthenticationException, ApiException {
        UserInfoResponse userInfo = client.getUserInfo(accessToken);
        
        Map<String, Object> result = new HashMap<>();
        result.put("id", userInfo.getUser().getId());
        result.put("displayName", userInfo.getUser().getDisplayName());
        result.put("email", getPrimaryEmail(userInfo.getUser().getEmails()));
        result.put("provider", userInfo.getUser().getProvider());
        result.put("active", userInfo.getUser().isActive());
        
        return result;
    }
    
    private String getPrimaryEmail(List<Email> emails) {
        return emails.isEmpty() ? null : emails.get(0).getValue();
    }
    
    public void close() {
        client.close();
    }
}
```

### Async Usage with CompletableFuture

```java
import com.authdog.AuthdogClient;
import com.authdog.exceptions.AuthenticationException;
import com.authdog.exceptions.ApiException;
import com.authdog.types.UserInfoResponse;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class AsyncExample {
    private final ExecutorService executor = Executors.newFixedThreadPool(10);
    
    public CompletableFuture<UserInfoResponse> getUserInfoAsync(String accessToken) {
        return CompletableFuture.supplyAsync(() -> {
            try (AuthdogClient client = new AuthdogClient("https://api.authdog.com")) {
                return client.getUserInfo(accessToken);
            } catch (AuthenticationException | ApiException e) {
                throw new RuntimeException(e);
            }
        }, executor);
    }
    
    public void shutdown() {
        executor.shutdown();
    }
}
```

## Building and Testing

### Build the Project

```bash
mvn clean compile
```

### Run Tests

```bash
mvn test
```

### Package the Library

```bash
mvn clean package
```

### Install to Local Repository

```bash
mvn clean install
```

## Development

### Requirements

- Java 11+
- Maven 3.6+
- OkHttp 4.12.0+
- Jackson 2.16.1+
- JUnit 5 (for testing)

### Code Style

- Follow Google Java Style Guide
- Use `google-java-format` for formatting
- Use `SpotBugs` for static analysis
- Maximum line length: 100 characters
- Use `final` wherever possible
- Prefer immutable objects

### Running Tests

```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=AuthdogClientTest

# Run tests with coverage
mvn test jacoco:report
```

## License

MIT License - see [LICENSE](../LICENSE) for details.
