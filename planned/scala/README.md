# Authdog Scala SDK

Official Scala SDK for Authdog authentication and user management platform.

## Installation

### SBT

Add the following dependency to your `build.sbt`:

```scala
libraryDependencies += "com.authdog" %% "authdog-scala-sdk" % "0.1.0"
```

### Maven

Add the following dependency to your `pom.xml`:

```xml
<dependency>
    <groupId>com.authdog</groupId>
    <artifactId>authdog-scala-sdk_2.13</artifactId>
    <version>0.1.0</version>
</dependency>
```

## Requirements

- Scala 2.13 or higher
- STTP HTTP client
- Circe JSON library

## Quick Start

```scala
import com.authdog.AuthdogClient
import com.authdog.exceptions.{AuthenticationException, ApiException}

object Example extends App {
  val client = AuthdogClient("https://api.authdog.com")
  
  try {
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
}
```

## Configuration

### Basic Configuration

```scala
val client = AuthdogClient("https://api.authdog.com")
```

### With API Key

```scala
val client = AuthdogClient("https://api.authdog.com", "your-api-key")
```

### Custom Timeout

```scala
import scala.concurrent.duration._

val client = AuthdogClient("https://api.authdog.com", Some("your-api-key"), 30.seconds)
```

## API Reference

### AuthdogClient

#### Constructors

```scala
// Simple constructor
def apply(baseUrl: String): AuthdogClient

// With API key
def apply(baseUrl: String, apiKey: String): AuthdogClient

// With API key and custom timeout
def apply(baseUrl: String, apiKey: Option[String], timeout: Duration): AuthdogClient
```

#### Methods

##### getUserInfo

```scala
def getUserInfo(accessToken: String): UserInfoResponse
```

Get user information using an access token.

**Parameters:**
- `accessToken`: The access token for authentication

**Returns:** `UserInfoResponse` containing user information

**Throws:**
- `AuthenticationException`: When authentication fails (401 responses)
- `ApiException`: When API request fails

##### close

```scala
def close(): Unit
```

Close the HTTP client and release resources.

## Data Types

### UserInfoResponse

```scala
case class UserInfoResponse(
  meta: Meta,
  session: Session,
  user: User
)
```

### User

```scala
case class User(
  id: String,
  externalId: String,
  userName: String,
  displayName: String,
  nickName: Option[String],
  profileUrl: Option[String],
  title: Option[String],
  userType: Option[String],
  preferredLanguage: Option[String],
  locale: String,
  timezone: Option[String],
  active: Boolean,
  names: Names,
  photos: List[Photo],
  phoneNumbers: List[io.circe.Json],
  addresses: List[io.circe.Json],
  emails: List[Email],
  verifications: List[Verification],
  provider: String,
  createdAt: String,
  updatedAt: String,
  environmentId: String
)
```

### Names

```scala
case class Names(
  id: String,
  formatted: Option[String],
  familyName: String,
  givenName: String,
  middleName: Option[String],
  honorificPrefix: Option[String],
  honorificSuffix: Option[String]
)
```

### Email

```scala
case class Email(
  id: String,
  value: String,
  `type`: Option[String]
)
```

### Photo

```scala
case class Photo(
  id: String,
  value: String,
  `type`: String
)
```

### Verification

```scala
case class Verification(
  id: String,
  email: String,
  verified: Boolean,
  createdAt: String,
  updatedAt: String
)
```

## Error Handling

The SDK provides structured error handling with specific exception types:

### AuthenticationException

Thrown when authentication fails (401 responses).

```scala
try {
  val userInfo = client.getUserInfo("invalid-token")
} catch {
  case e: AuthenticationException => 
    println(s"Authentication failed: ${e.getMessage}")
}
```

### ApiException

Thrown when API requests fail.

```scala
try {
  val userInfo = client.getUserInfo("valid-token")
} catch {
  case e: ApiException => 
    println(s"API error: ${e.getMessage}")
}
```

### AuthdogException

Base exception class for all SDK errors.

```scala
try {
  val userInfo = client.getUserInfo("token")
} catch {
  case e: AuthdogException => 
    println(s"Authdog error: ${e.getMessage}")
}
```

## Examples

### Basic Usage

```scala
import com.authdog.AuthdogClient
import com.authdog.types.UserInfoResponse

object BasicExample extends App {
  val client = AuthdogClient("https://api.authdog.com")
  
  try {
    val userInfo = client.getUserInfo("your-access-token")
    
    println(s"User ID: ${userInfo.user.id}")
    println(s"Display Name: ${userInfo.user.displayName}")
    println(s"Provider: ${userInfo.user.provider}")
    
    userInfo.user.emails.headOption.foreach { email =>
      println(s"Email: ${email.value}")
    }
  } catch {
    case e: Exception => 
      println(s"Error: ${e.getMessage}")
  } finally {
    client.close()
  }
}
```

### Error Handling

```scala
import com.authdog.AuthdogClient
import com.authdog.exceptions.{AuthenticationException, ApiException}

object ErrorHandlingExample extends App {
  val client = AuthdogClient("https://api.authdog.com")
  
  try {
    val userInfo = client.getUserInfo("your-access-token")
    println(s"Success: ${userInfo.user.displayName}")
  } catch {
    case e: AuthenticationException => 
      println(s"Authentication failed: ${e.getMessage}")
      // Handle authentication error
    case e: ApiException => 
      println(s"API error: ${e.getMessage}")
      // Handle API error
  } finally {
    client.close()
  }
}
```

### Using Try for Error Handling

```scala
import com.authdog.AuthdogClient
import com.authdog.exceptions.{AuthenticationException, ApiException}
import scala.util.{Try, Success, Failure}

object TryExample extends App {
  val client = AuthdogClient("https://api.authdog.com")
  
  val result = Try {
    client.getUserInfo("your-access-token")
  }
  
  result match {
    case Success(userInfo) => 
      println(s"User: ${userInfo.user.displayName}")
    case Failure(e: AuthenticationException) => 
      println(s"Authentication failed: ${e.getMessage}")
    case Failure(e: ApiException) => 
      println(s"API error: ${e.getMessage}")
    case Failure(e) => 
      println(s"Unexpected error: ${e.getMessage}")
  }
  
  client.close()
}
```

### Service Class Example

```scala
import com.authdog.AuthdogClient
import com.authdog.exceptions.{AuthenticationException, ApiException}
import com.authdog.types.UserInfoResponse
import scala.util.{Try, Success, Failure}

class UserService(baseUrl: String, apiKey: Option[String] = None) {
  private val client = AuthdogClient(baseUrl, apiKey)
  
  def getUserInfo(accessToken: String): Try[Map[String, Any]] = {
    Try {
      val userInfo = client.getUserInfo(accessToken)
      Map(
        "id" -> userInfo.user.id,
        "displayName" -> userInfo.user.displayName,
        "email" -> userInfo.user.emails.headOption.map(_.value),
        "provider" -> userInfo.user.provider,
        "active" -> userInfo.user.active
      )
    }
  }
  
  def close(): Unit = client.close()
}

object UserServiceExample extends App {
  val service = new UserService("https://api.authdog.com")
  
  service.getUserInfo("your-access-token") match {
    case Success(userData) => 
      println(s"User: ${userData("displayName")}")
    case Failure(e: AuthenticationException) => 
      println(s"Authentication failed: ${e.getMessage}")
    case Failure(e: ApiException) => 
      println(s"API error: ${e.getMessage}")
    case Failure(e) => 
      println(s"Error: ${e.getMessage}")
  }
  
  service.close()
}
```

### Akka HTTP Integration

```scala
import akka.actor.ActorSystem
import akka.http.scaladsl.server.Directives._
import akka.http.scaladsl.model.StatusCodes
import akka.http.scaladsl.server.Route
import com.authdog.AuthdogClient
import com.authdog.exceptions.{AuthenticationException, ApiException}
import spray.json._

class UserRoutes(authdogClient: AuthdogClient) {
  implicit val system: ActorSystem = ActorSystem()
  
  val routes: Route = path("user" / "info") {
    get {
      parameter("access_token") { accessToken =>
        try {
          val userInfo = authdogClient.getUserInfo(accessToken)
          complete(StatusCodes.OK, Map(
            "id" -> userInfo.user.id,
            "displayName" -> userInfo.user.displayName,
            "email" -> userInfo.user.emails.headOption.map(_.value),
            "provider" -> userInfo.user.provider
          ).toJson)
        } catch {
          case e: AuthenticationException => 
            complete(StatusCodes.Unauthorized, Map("error" -> "Authentication failed").toJson)
          case e: ApiException => 
            complete(StatusCodes.BadRequest, Map("error" -> e.getMessage).toJson)
        }
      }
    }
  }
}
```

### Cats Effect Integration

```scala
import cats.effect.{IO, Resource}
import com.authdog.AuthdogClient
import com.authdog.exceptions.{AuthenticationException, ApiException}

class AuthdogService(baseUrl: String, apiKey: Option[String] = None) {
  
  def getUserInfo(accessToken: String): IO[UserInfoResponse] = {
    Resource.make(IO(AuthdogClient(baseUrl, apiKey)))(client => IO(client.close()))
      .use { client =>
        IO.fromTry(Try(client.getUserInfo(accessToken)))
          .handleErrorWith {
            case e: AuthenticationException => 
              IO.raiseError(new RuntimeException(s"Authentication failed: ${e.getMessage}"))
            case e: ApiException => 
              IO.raiseError(new RuntimeException(s"API error: ${e.getMessage}"))
            case e => 
              IO.raiseError(e)
          }
      }
  }
}

object CatsEffectExample extends IOApp {
  def run(args: List[String]): IO[ExitCode] = {
    val service = new AuthdogService("https://api.authdog.com")
    
    service.getUserInfo("your-access-token")
      .flatMap { userInfo =>
        IO.println(s"User: ${userInfo.user.displayName}")
      }
      .handleErrorWith { error =>
        IO.println(s"Error: ${error.getMessage}")
      }
      .as(ExitCode.Success)
  }
}
```

### ZIO Integration

```scala
import zio._
import com.authdog.AuthdogClient
import com.authdog.exceptions.{AuthenticationException, ApiException}

class AuthdogService(baseUrl: String, apiKey: Option[String] = None) {
  
  def getUserInfo(accessToken: String): ZIO[Any, Throwable, UserInfoResponse] = {
    ZIO.acquireReleaseWith(
      ZIO.succeed(AuthdogClient(baseUrl, apiKey))
    )(client => ZIO.succeed(client.close())) { client =>
      ZIO.fromTry(Try(client.getUserInfo(accessToken)))
        .mapError {
          case e: AuthenticationException => 
            new RuntimeException(s"Authentication failed: ${e.getMessage}")
          case e: ApiException => 
            new RuntimeException(s"API error: ${e.getMessage}")
          case e => e
        }
    }
  }
}

object ZIOExample extends ZIOAppDefault {
  def run: ZIO[Any, Throwable, Unit] = {
    val service = new AuthdogService("https://api.authdog.com")
    
    service.getUserInfo("your-access-token")
      .tap(userInfo => ZIO.println(s"User: ${userInfo.user.displayName}"))
      .catchAll(error => ZIO.println(s"Error: ${error.getMessage}"))
  }
}
```

## Building and Testing

### Build the Project

```bash
sbt compile
```

### Run Tests

```bash
sbt test
```

### Package the Library

```bash
sbt package
```

### Publish to Local Repository

```bash
sbt publishLocal
```

## Development

### Requirements

- Scala 2.13+
- SBT 1.8+
- STTP 3.9.1+
- Circe 0.14.6+
- ScalaTest (for testing)

### Code Style

- Follow Scala Style Guide
- Use `scalafmt` for formatting
- Use `scalastyle` for style checking
- Maximum line length: 100 characters
- Use `val` wherever possible
- Prefer immutable data structures

### Running Tests

```bash
# Run all tests
sbt test

# Run specific test
sbt "testOnly *AuthdogClientTest"

# Run tests with coverage
sbt clean coverage test coverageReport
```

## License

MIT License - see [LICENSE](../LICENSE) for details.
