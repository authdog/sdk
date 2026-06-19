# Authdog PHP SDK

Official PHP SDK for Authdog authentication and user management platform.

## Installation

Install the SDK using Composer:

```bash
composer require authdog/php-sdk
```

## Requirements

- PHP 7.4 or higher
- Guzzle HTTP client

## Quick Start

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

## Configuration

### Basic Configuration

```php
$client = new AuthdogClient('https://api.authdog.com');
```

### With API Key

```php
$client = new AuthdogClient('https://api.authdog.com', 'your-api-key');
```

### Custom HTTP Client Options

```php
$client = new AuthdogClient('https://api.authdog.com', null, [
    'timeout' => 30,
    'verify' => false, // Disable SSL verification (not recommended for production)
]);
```

## API Reference

### AuthdogClient

#### Constructor

```php
public function __construct(string $baseUrl, ?string $apiKey = null, array $options = [])
```

- `$baseUrl`: The base URL of the Authdog API
- `$apiKey`: Optional API key for authentication
- `$options`: Additional Guzzle HTTP client options

#### Methods

##### getUserInfo

```php
public function getUserInfo(string $accessToken): UserInfoResponse
```

Get user information using an access token.

**Parameters:**
- `$accessToken`: The access token for authentication

**Returns:** `UserInfoResponse` object containing user information

**Throws:**
- `AuthenticationException`: When authentication fails (401 responses)
- `ApiException`: When API request fails

##### close

```php
public function close(): void
```

Close the HTTP client (for cleanup).

## Data Types

### UserInfoResponse

```php
class UserInfoResponse
{
    public Meta $meta;
    public Session $session;
    public User $user;
}
```

### User

```php
class User
{
    public string $id;
    public string $externalId;
    public string $userName;
    public string $displayName;
    public ?string $nickName;
    public ?string $profileUrl;
    public ?string $title;
    public ?string $userType;
    public ?string $preferredLanguage;
    public string $locale;
    public ?string $timezone;
    public bool $active;
    public Names $names;
    public array $photos; // Photo[]
    public array $phoneNumbers;
    public array $addresses;
    public array $emails; // Email[]
    public array $verifications; // Verification[]
    public string $provider;
    public string $createdAt;
    public string $updatedAt;
    public string $environmentId;
}
```

### Names

```php
class Names
{
    public string $id;
    public ?string $formatted;
    public string $familyName;
    public string $givenName;
    public ?string $middleName;
    public ?string $honorificPrefix;
    public ?string $honorificSuffix;
}
```

### Email

```php
class Email
{
    public string $id;
    public string $value;
    public ?string $type;
}
```

### Photo

```php
class Photo
{
    public string $id;
    public string $value;
    public string $type;
}
```

### Verification

```php
class Verification
{
    public string $id;
    public string $email;
    public bool $verified;
    public string $createdAt;
    public string $updatedAt;
}
```

## Error Handling

The SDK provides structured error handling with specific exception types:

### AuthenticationException

Thrown when authentication fails (401 responses).

```php
try {
    $userInfo = $client->getUserInfo('invalid-token');
} catch (AuthenticationException $e) {
    echo "Authentication failed: " . $e->getMessage();
}
```

### ApiException

Thrown when API requests fail.

```php
try {
    $userInfo = $client->getUserInfo('valid-token');
} catch (ApiException $e) {
    echo "API error: " . $e->getMessage();
}
```

### AuthdogException

Base exception class for all SDK errors.

```php
try {
    $userInfo = $client->getUserInfo('token');
} catch (AuthdogException $e) {
    echo "Authdog error: " . $e->getMessage();
}
```

## Examples

### Basic Usage

```php
<?php

use Authdog\AuthdogClient;

$client = new AuthdogClient('https://api.authdog.com');

$userInfo = $client->getUserInfo('your-access-token');

echo "User ID: " . $userInfo->user->id . "\n";
echo "Display Name: " . $userInfo->user->displayName . "\n";
echo "Email: " . $userInfo->user->emails[0]->value . "\n";
echo "Provider: " . $userInfo->user->provider . "\n";

$client->close();
```

### Error Handling

```php
<?php

use Authdog\AuthdogClient;
use Authdog\Exceptions\AuthenticationException;
use Authdog\Exceptions\ApiException;

$client = new AuthdogClient('https://api.authdog.com');

try {
    $userInfo = $client->getUserInfo('your-access-token');
    echo "Success: " . $userInfo->user->displayName . "\n";
} catch (AuthenticationException $e) {
    echo "Authentication failed: " . $e->getMessage() . "\n";
    // Handle authentication error
} catch (ApiException $e) {
    echo "API error: " . $e->getMessage() . "\n";
    // Handle API error
} finally {
    $client->close();
}
```

### Using with Framework (Laravel Example)

```php
<?php

namespace App\Services;

use Authdog\AuthdogClient;
use Authdog\Exceptions\AuthenticationException;
use Authdog\Exceptions\ApiException;

class AuthdogService
{
    private AuthdogClient $client;

    public function __construct()
    {
        $this->client = new AuthdogClient(
            config('authdog.base_url'),
            config('authdog.api_key')
        );
    }

    public function getUserInfo(string $accessToken): array
    {
        try {
            $userInfo = $this->client->getUserInfo($accessToken);
            
            return [
                'id' => $userInfo->user->id,
                'display_name' => $userInfo->user->displayName,
                'email' => $userInfo->user->emails[0]->value ?? null,
                'provider' => $userInfo->user->provider,
            ];
        } catch (AuthenticationException $e) {
            throw new \Exception('Authentication failed: ' . $e->getMessage());
        } catch (ApiException $e) {
            throw new \Exception('API error: ' . $e->getMessage());
        }
    }

    public function __destruct()
    {
        $this->client->close();
    }
}
```

## Development

### Running Tests

```bash
composer test
```

### Code Analysis

```bash
composer analyze
```

### Requirements

- PHP 7.4+
- Composer
- PHPUnit (for testing)
- PHPStan (for static analysis)

## License

MIT License - see [LICENSE](../LICENSE) for details.
