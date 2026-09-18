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
    print(f"User: {user_info.user.display_name}")
    print(f"Email: {user_info.user.emails[0].value}")
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
    print(f"User: {user_info.user.display_name}")
```

## API Reference

### AuthdogClient

#### `__init__(base_url: str, api_key: Optional[str] = None, timeout: float = 10.0, environment_secret: Optional[str] = None, scim_token: Optional[str] = None, hris_token: Optional[str] = None)`

Initialize the Authdog client.

- `base_url`: The base URL of the Authdog API
- `api_key`: Optional management Bearer credential (userinfo still uses the access token)
- `timeout`: Request timeout in seconds (default 10)
- `environment_secret`: Optional `adenv_` secret for AuthZEN and MCP runtime
- `scim_token`: Optional `adscim_` token for `/v1/scim/v2`
- `hris_token`: Optional `adhris_` token for `/v1/hris/v1`

#### `health() -> Probe`

`GET /v1/health`. Public; works without an API key.

#### Management namespaces

`organizations`, `tenants`, `projects`, `environments`, `users`,
`groups`, `rbac`, `audit`, `events`, `webhooks`,
`notification_channels`, `service_accounts`,
`personal_access_tokens`, `api_secrets`, `authzen`, `scim`, `hris`,
`mcp`, `otel`, `oidc_clients`, `actions`, `addons`, `billing`,
`settings`, `elevate`, `email_providers`, `feature_flags`, `forms`,
`provisioning_tokens`, `impersonation`, `portal`, `security`,
`threats`, `vanity_domains`, and `widgets` wrap Waves 1–3 of the
public API. Example:

```python
with AuthdogClient("https://api.authdog.com", api_key="ad_...") as client:
    orgs = client.organizations.list()
    users = client.users.list("ten_123", "env_456")
    decision = client.authzen.evaluate({"subject": {"id": "usr_1"}})
```

AuthZEN discovery (`authzen.configuration()`) is unauthenticated.
AuthZEN evaluate/search and MCP runtime use `environment_secret`.
SCIM uses `scim_token`; HRIS uses `hris_token`. See
`specs/004-api-parity/` for the full catalog.

#### `get_userinfo(access_token: str) -> UserInfoResponse`

Get user information using an access token.

- `access_token`: The access token for authentication
- Returns: `UserInfoResponse` (`meta`, `session`, `user`) with snake_case attributes
  (`user.display_name`, `user.emails[0].value`, `session.remaining_seconds`)

## Exceptions

- `AuthdogError`: Base exception for all Authdog SDK errors
- `AuthenticationError`: Raised when authentication fails (401 responses)
- `APIError`: Raised when API requests fail

## Development

```bash
# Install development dependencies
uv sync

# Run tests
uv run pytest

# Format code
uv run black authdog/
uv run isort authdog/

# Type checking
uv run mypy authdog/
```
