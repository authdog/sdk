# Authdog C# SDK

Official C# SDK for Authdog authentication and user management platform.

## Installation

Install the SDK using NuGet Package Manager:

```bash
dotnet add package Authdog.Sdk
```

Or via Package Manager Console:

```powershell
Install-Package Authdog.Sdk
```

## Requirements

- .NET 6.0 or higher
- Newtonsoft.Json
- Microsoft.Extensions.Http

## Quick Start

```csharp
using Authdog;
using Authdog.Exceptions;
using Authdog.Types;

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

## Configuration

### Basic Configuration

```csharp
var client = new AuthdogClient("https://api.authdog.com");
```

### With API Key

```csharp
var client = new AuthdogClient("https://api.authdog.com", "your-api-key");
```

### Custom HttpClient

```csharp
var httpClient = new HttpClient();
httpClient.Timeout = TimeSpan.FromSeconds(30);

var client = new AuthdogClient("https://api.authdog.com", null, httpClient);
```

### Dependency Injection (ASP.NET Core)

```csharp
// In Program.cs or Startup.cs
services.AddHttpClient<AuthdogClient>(client =>
{
    client.BaseAddress = new Uri("https://api.authdog.com");
    client.DefaultRequestHeaders.Add("User-Agent", "authdog-csharp-sdk/0.1.0");
});

// Or register as singleton
services.AddSingleton<AuthdogClient>(provider =>
{
    var httpClient = provider.GetRequiredService<HttpClient>();
    return new AuthdogClient("https://api.authdog.com", "your-api-key", httpClient);
});
```

## API Reference

### AuthdogClient

#### Constructor

```csharp
public AuthdogClient(string baseUrl, string? apiKey = null, HttpClient? httpClient = null)
```

- `baseUrl`: The base URL of the Authdog API
- `apiKey`: Optional API key for authentication
- `httpClient`: Optional custom HttpClient instance

#### Methods

##### GetUserInfoAsync

```csharp
public async Task<UserInfoResponse> GetUserInfoAsync(string accessToken)
```

Get user information using an access token asynchronously.

**Parameters:**
- `accessToken`: The access token for authentication

**Returns:** `Task<UserInfoResponse>` containing user information

**Throws:**
- `AuthenticationException`: When authentication fails (401 responses)
- `ApiException`: When API request fails

##### GetUserInfo

```csharp
public UserInfoResponse GetUserInfo(string accessToken)
```

Synchronous version of GetUserInfoAsync.

**Parameters:**
- `accessToken`: The access token for authentication

**Returns:** `UserInfoResponse` containing user information

**Throws:**
- `AuthenticationException`: When authentication fails (401 responses)
- `ApiException`: When API request fails

##### Dispose

```csharp
public void Dispose()
```

Dispose the HTTP client and release resources.

## Data Types

### UserInfoResponse

```csharp
public class UserInfoResponse
{
    public Meta Meta { get; set; }
    public Session Session { get; set; }
    public User User { get; set; }
}
```

### User

```csharp
public class User
{
    public string Id { get; set; }
    public string ExternalId { get; set; }
    public string UserName { get; set; }
    public string DisplayName { get; set; }
    public string? NickName { get; set; }
    public string? ProfileUrl { get; set; }
    public string? Title { get; set; }
    public string? UserType { get; set; }
    public string? PreferredLanguage { get; set; }
    public string Locale { get; set; }
    public string? Timezone { get; set; }
    public bool Active { get; set; }
    public Names Names { get; set; }
    public List<Photo> Photos { get; set; }
    public List<object> PhoneNumbers { get; set; }
    public List<object> Addresses { get; set; }
    public List<Email> Emails { get; set; }
    public List<Verification> Verifications { get; set; }
    public string Provider { get; set; }
    public string CreatedAt { get; set; }
    public string UpdatedAt { get; set; }
    public string EnvironmentId { get; set; }
}
```

### Names

```csharp
public class Names
{
    public string Id { get; set; }
    public string? Formatted { get; set; }
    public string FamilyName { get; set; }
    public string GivenName { get; set; }
    public string? MiddleName { get; set; }
    public string? HonorificPrefix { get; set; }
    public string? HonorificSuffix { get; set; }
}
```

### Email

```csharp
public class Email
{
    public string Id { get; set; }
    public string Value { get; set; }
    public string? Type { get; set; }
}
```

### Photo

```csharp
public class Photo
{
    public string Id { get; set; }
    public string Value { get; set; }
    public string Type { get; set; }
}
```

### Verification

```csharp
public class Verification
{
    public string Id { get; set; }
    public string Email { get; set; }
    public bool Verified { get; set; }
    public string CreatedAt { get; set; }
    public string UpdatedAt { get; set; }
}
```

## Error Handling

The SDK provides structured error handling with specific exception types:

### AuthenticationException

Thrown when authentication fails (401 responses).

```csharp
try
{
    var userInfo = await client.GetUserInfoAsync("invalid-token");
}
catch (AuthenticationException ex)
{
    Console.WriteLine($"Authentication failed: {ex.Message}");
}
```

### ApiException

Thrown when API requests fail.

```csharp
try
{
    var userInfo = await client.GetUserInfoAsync("valid-token");
}
catch (ApiException ex)
{
    Console.WriteLine($"API error: {ex.Message}");
}
```

### AuthdogException

Base exception class for all SDK errors.

```csharp
try
{
    var userInfo = await client.GetUserInfoAsync("token");
}
catch (AuthdogException ex)
{
    Console.WriteLine($"Authdog error: {ex.Message}");
}
```

## Examples

### Basic Usage

```csharp
using Authdog;
using Authdog.Types;

var client = new AuthdogClient("https://api.authdog.com");

var userInfo = await client.GetUserInfoAsync("your-access-token");

Console.WriteLine($"User ID: {userInfo.User.Id}");
Console.WriteLine($"Display Name: {userInfo.User.DisplayName}");
Console.WriteLine($"Email: {userInfo.User.Emails.FirstOrDefault()?.Value}");
Console.WriteLine($"Provider: {userInfo.User.Provider}");

client.Dispose();
```

### Error Handling

```csharp
using Authdog;
using Authdog.Exceptions;

var client = new AuthdogClient("https://api.authdog.com");

try
{
    var userInfo = await client.GetUserInfoAsync("your-access-token");
    Console.WriteLine($"Success: {userInfo.User.DisplayName}");
}
catch (AuthenticationException ex)
{
    Console.WriteLine($"Authentication failed: {ex.Message}");
    // Handle authentication error
}
catch (ApiException ex)
{
    Console.WriteLine($"API error: {ex.Message}");
    // Handle API error
}
finally
{
    client.Dispose();
}
```

### Using with Dependency Injection

```csharp
// In Program.cs (ASP.NET Core)
using Authdog;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddHttpClient<AuthdogClient>(client =>
{
    client.BaseAddress = new Uri("https://api.authdog.com");
});

var app = builder.Build();

// In a controller or service
public class UserController : ControllerBase
{
    private readonly AuthdogClient _authdogClient;

    public UserController(AuthdogClient authdogClient)
    {
        _authdogClient = authdogClient;
    }

    [HttpGet("user/{accessToken}")]
    public async Task<IActionResult> GetUser(string accessToken)
    {
        try
        {
            var userInfo = await _authdogClient.GetUserInfoAsync(accessToken);
            return Ok(new
            {
                Id = userInfo.User.Id,
                DisplayName = userInfo.User.DisplayName,
                Email = userInfo.User.Emails.FirstOrDefault()?.Value,
                Provider = userInfo.User.Provider
            });
        }
        catch (AuthenticationException ex)
        {
            return Unauthorized(new { error = ex.Message });
        }
        catch (ApiException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }
}
```

### Console Application

```csharp
using Authdog;
using Authdog.Exceptions;
using Authdog.Types;

class Program
{
    static async Task Main(string[] args)
    {
        using var client = new AuthdogClient("https://api.authdog.com");

        Console.Write("Enter access token: ");
        var accessToken = Console.ReadLine();

        if (string.IsNullOrEmpty(accessToken))
        {
            Console.WriteLine("Access token is required.");
            return;
        }

        try
        {
            var userInfo = await client.GetUserInfoAsync(accessToken);
            
            Console.WriteLine("\n=== User Information ===");
            Console.WriteLine($"ID: {userInfo.User.Id}");
            Console.WriteLine($"Display Name: {userInfo.User.DisplayName}");
            Console.WriteLine($"Username: {userInfo.User.UserName}");
            Console.WriteLine($"Provider: {userInfo.User.Provider}");
            Console.WriteLine($"Active: {userInfo.User.Active}");
            
            if (userInfo.User.Emails.Any())
            {
                Console.WriteLine("\n=== Emails ===");
                foreach (var email in userInfo.User.Emails)
                {
                    Console.WriteLine($"- {email.Value} ({email.Type ?? "primary"})");
                }
            }

            if (userInfo.User.Photos.Any())
            {
                Console.WriteLine("\n=== Photos ===");
                foreach (var photo in userInfo.User.Photos)
                {
                    Console.WriteLine($"- {photo.Value} ({photo.Type})");
                }
            }
        }
        catch (AuthenticationException ex)
        {
            Console.WriteLine($"Authentication failed: {ex.Message}");
        }
        catch (ApiException ex)
        {
            Console.WriteLine($"API error: {ex.Message}");
        }
    }
}
```

### Unit Testing

```csharp
using Authdog;
using Authdog.Exceptions;
using Microsoft.Extensions.DependencyInjection;
using Moq;
using System.Net;
using System.Text;

[Test]
public async Task GetUserInfoAsync_ValidToken_ReturnsUserInfo()
{
    // Arrange
    var mockHttpClient = new Mock<HttpClient>();
    var client = new AuthdogClient("https://api.authdog.com", null, mockHttpClient.Object);
    
    var expectedResponse = new UserInfoResponse
    {
        User = new User
        {
            Id = "user-123",
            DisplayName = "Test User",
            Provider = "google-oauth20"
        }
    };

    // Act
    var result = await client.GetUserInfoAsync("valid-token");

    // Assert
    Assert.AreEqual("user-123", result.User.Id);
    Assert.AreEqual("Test User", result.User.DisplayName);
}
```

## Development

### Building the Project

```bash
dotnet build
```

### Running Tests

```bash
dotnet test
```

### Creating a Package

```bash
dotnet pack --configuration Release
```

### Requirements

- .NET 6.0+
- Visual Studio 2022 or VS Code
- NuGet Package Manager

## License

MIT License - see [LICENSE](../LICENSE) for details.
