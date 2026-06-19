# Authdog Kotlin SDK

Kotlin SDK for Authdog authentication and user management.

## Installation

### Gradle (Kotlin DSL)

```kotlin
dependencies {
    implementation("com.authdog:kotlin-sdk:0.1.0")
}
```

### Gradle (Groovy)

```groovy
dependencies {
    implementation 'com.authdog:kotlin-sdk:0.1.0'
}
```

### Maven

```xml
<dependency>
    <groupId>com.authdog</groupId>
    <artifactId>kotlin-sdk</artifactId>
    <version>0.1.0</version>
</dependency>
```

## Usage

### Basic Usage

```kotlin
import com.authdog.sdk.*
import kotlinx.coroutines.runBlocking

fun main() = runBlocking {
    // Initialize the client
    val client = AuthdogClient(
        AuthdogClientConfig(
            baseUrl = "https://api.authdog.com",
            apiKey = "your-api-key", // Optional
            timeoutSeconds = 10 // Optional, defaults to 10 seconds
        )
    )

    try {
        // Get user information
        val userInfo = client.getUserInfo("your-access-token")
        println("User: ${userInfo.user.displayName}")
        if (userInfo.user.emails.isNotEmpty()) {
            println("Email: ${userInfo.user.emails[0].value}")
        }
    } catch (e: AuthenticationError) {
        println("Authentication failed: ${e.message}")
    } catch (e: APIError) {
        println("API error: ${e.message}")
    } catch (e: Exception) {
        println("Unexpected error: ${e.message}")
    }
}
```

### Using with Coroutines

```kotlin
import com.authdog.sdk.*
import kotlinx.coroutines.*

suspend fun getUserData(accessToken: String): UserInfoResponse? {
    val client = AuthdogClient(
        AuthdogClientConfig(
            baseUrl = "https://api.authdog.com"
        )
    )
    
    return try {
        client.getUserInfo(accessToken)
    } catch (e: AuthdogError) {
        println("Error: ${e.message}")
        null
    }
}

// Usage
fun main() = runBlocking {
    val userInfo = getUserData("your-access-token")
    userInfo?.let {
        println("User: ${it.user.displayName}")
    }
}
```

## API Reference

### AuthdogClient

#### Constructor

```kotlin
AuthdogClient(config: AuthdogClientConfig)
```

**Config Options:**
- `baseUrl` (String): The base URL of the Authdog API
- `apiKey` (String?, optional): API key for authentication
- `timeoutSeconds` (Long, optional): Request timeout in seconds (default: 10)
- `httpClient` (HttpClient?, optional): Custom HTTP client

#### Methods

##### `suspend fun getUserInfo(accessToken: String): UserInfoResponse`

Get user information using an access token.

**Parameters:**
- `accessToken` (String): The access token for authentication

**Returns:** `UserInfoResponse` - User information

**Response Structure:**
```kotlin
data class UserInfoResponse(
    val meta: Meta,
    val session: Session,
    val user: User
)

data class User(
    val id: String,
    val externalId: String,
    val userName: String,
    val displayName: String,
    val nickName: String? = null,
    val profileUrl: String? = null,
    val title: String? = null,
    val userType: String? = null,
    val preferredLanguage: String? = null,
    val locale: String,
    val timezone: String? = null,
    val active: Boolean,
    val names: Names,
    val photos: List<Photo>,
    val phoneNumbers: List<Any>,
    val addresses: List<Any>,
    val emails: List<Email>,
    val verifications: List<Verification>,
    val provider: String,
    val createdAt: String,
    val updatedAt: String,
    val environmentId: String
)
```

##### `fun close()`

Close the HTTP client (for cleanup).

## Error Handling

The SDK provides structured error handling:

- `AuthenticationError`: Raised when authentication fails (401 responses)
- `APIError`: Raised when API requests fail
- `AuthdogError`: Base exception for all SDK errors

**Error Handling Example:**
```kotlin
try {
    val userInfo = client.getUserInfo(accessToken)
    // Handle success
} catch (e: AuthenticationError) {
    // Handle authentication error
} catch (e: APIError) {
    // Handle API error
} catch (e: AuthdogError) {
    // Handle general Authdog error
}
```

## Dependencies

- Kotlin 1.9.10+
- Kotlinx Serialization
- Kotlinx Coroutines
- Java HTTP Client (built-in)

## Development

```bash
# Build the project
./gradlew build

# Run tests
./gradlew test

# Publish to local Maven repository
./gradlew publishToMavenLocal
```

## Coroutines Support

This SDK is built with Kotlin coroutines and provides suspend functions for all API calls. Make sure to use coroutines in your application:

```kotlin
// In a coroutine scope
launch {
    val userInfo = client.getUserInfo(accessToken)
    // Handle response
}

// Or with runBlocking for simple scripts
runBlocking {
    val userInfo = client.getUserInfo(accessToken)
    // Handle response
}
```
