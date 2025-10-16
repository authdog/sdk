# Authdog Python SDK

Python SDK for Authdog authentication and user management.

## Installation

```bash
pip install authdog
```

## Usage

### Basic Usage

```python
from authdog import AuthdogClient

# Initialize the client
client = AuthdogClient(
    base_url="https://api.authdog.com",
    api_key="your-api-key"  # Optional
)

# Get user information
try:
    user_info = client.get_userinfo("your-access-token")
    print(f"User: {user_info['user']['displayName']}")
    print(f"Email: {user_info['user']['emails'][0]['value']}")
except AuthenticationError as e:
    print(f"Authentication failed: {e}")
except APIError as e:
    print(f"API error: {e}")

# Always close the client when done
client.close()
```

### Using Context Manager

```python
from authdog import AuthdogClient

with AuthdogClient("https://api.authdog.com") as client:
    user_info = client.get_userinfo("your-access-token")
    print(f"User: {user_info['user']['displayName']}")
```

## API Reference

### AuthdogClient

#### `__init__(base_url: str, api_key: Optional[str] = None)`

Initialize the Authdog client.

- `base_url`: The base URL of the Authdog API
- `api_key`: Optional API key for authentication

#### `get_userinfo(access_token: str) -> Dict[str, Any]`

Get user information using an access token.

- `access_token`: The access token for authentication
- Returns: Dict containing user information with the following structure:
  ```python
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

## Exceptions

- `AuthdogError`: Base exception for all Authdog SDK errors
- `AuthenticationError`: Raised when authentication fails (401 responses)
- `APIError`: Raised when API requests fail

## Development

```bash
# Install development dependencies
pip install -e ".[dev]"

# Run tests
pytest

# Format code
black authdog/
isort authdog/

# Type checking
mypy authdog/
```
