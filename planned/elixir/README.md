# Authdog Elixir SDK

Official Elixir SDK for Authdog authentication and user management platform.

## Installation

Add `authdog` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:authdog, "~> 0.1.0"}
  ]
end
```

Then run `mix deps.get`.

## Requirements

- Elixir 1.12 or higher
- Req HTTP client
- Jason JSON library

## Quick Start

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

## Configuration

### Basic Configuration

```elixir
client = Authdog.Client.new("https://api.authdog.com")
```

### With API Key

```elixir
client = Authdog.Client.new("https://api.authdog.com", api_key: "your-api-key")
```

### Custom Timeout

```elixir
client = Authdog.Client.new("https://api.authdog.com", timeout: 5000)
```

## API Reference

### Authdog.Client

#### new/2

```elixir
new(base_url, opts \\ [])
```

Creates a new Authdog client.

**Parameters:**
- `base_url`: The base URL of the Authdog API
- `opts`: Optional configuration

**Options:**
- `:api_key` - Optional API key for authentication
- `:timeout` - Request timeout in milliseconds (default: 10000)

#### get_user_info/2

```elixir
get_user_info(client, access_token)
```

Get user information using an access token.

**Parameters:**
- `client`: The Authdog client
- `access_token`: The access token for authentication

**Returns:**
- `{:ok, user_info}` - On success
- `{:error, :authentication_error, message}` - When authentication fails
- `{:error, :api_error, message}` - When API request fails

## Data Types

### UserInfoResponse

```elixir
%Authdog.Types.UserInfoResponse{
  meta: %Authdog.Types.Meta{...},
  session: %Authdog.Types.Session{...},
  user: %Authdog.Types.User{...}
}
```

### User

```elixir
%Authdog.Types.User{
  id: "user-id",
  external_id: "external-id",
  user_name: "username",
  display_name: "Display Name",
  nick_name: nil,
  profile_url: nil,
  title: nil,
  user_type: nil,
  preferred_language: nil,
  locale: "en",
  timezone: nil,
  active: true,
  names: %Authdog.Types.Names{...},
  photos: [%Authdog.Types.Photo{...}],
  phone_numbers: [],
  addresses: [],
  emails: [%Authdog.Types.Email{...}],
  verifications: [%Authdog.Types.Verification{...}],
  provider: "google-oauth20",
  created_at: "2024-01-01T00:00:00Z",
  updated_at: "2024-01-01T00:00:00Z",
  environment_id: "env-id"
}
```

### Names

```elixir
%Authdog.Types.Names{
  id: "name-id",
  formatted: nil,
  family_name: "Last",
  given_name: "First",
  middle_name: nil,
  honorific_prefix: nil,
  honorific_suffix: nil
}
```

### Email

```elixir
%Authdog.Types.Email{
  id: "email-id",
  value: "email@example.com",
  type: nil
}
```

### Photo

```elixir
%Authdog.Types.Photo{
  id: "photo-id",
  value: "https://example.com/photo.jpg",
  type: "photo"
}
```

### Verification

```elixir
%Authdog.Types.Verification{
  id: "verification-id",
  email: "email@example.com",
  verified: true,
  created_at: "2024-01-01T00:00:00Z",
  updated_at: "2024-01-01T00:00:00Z"
}
```

## Error Handling

The SDK provides structured error handling with tagged tuples:

### Authentication Error

```elixir
case Authdog.Client.get_user_info(client, "invalid-token") do
  {:error, :authentication_error, message} ->
    IO.puts("Authentication failed: #{message}")
end
```

### API Error

```elixir
case Authdog.Client.get_user_info(client, "valid-token") do
  {:error, :api_error, message} ->
    IO.puts("API error: #{message}")
end
```

## Examples

### Basic Usage

```elixir
defmodule MyApp.UserService do
  def get_user_info(access_token) do
    client = Authdog.Client.new("https://api.authdog.com")
    
    case Authdog.Client.get_user_info(client, access_token) do
      {:ok, user_info} ->
        {:ok, %{
          id: user_info.user.id,
          display_name: user_info.user.display_name,
          email: get_primary_email(user_info.user.emails),
          provider: user_info.user.provider
        }}
      {:error, reason, message} ->
        {:error, reason, message}
    end
  end
  
  defp get_primary_email(emails) do
    case emails do
      [email | _] -> email.value
      [] -> nil
    end
  end
end
```

### Error Handling

```elixir
defmodule MyApp.AuthController do
  def show(conn, %{"access_token" => access_token}) do
    client = Authdog.Client.new("https://api.authdog.com")
    
    case Authdog.Client.get_user_info(client, access_token) do
      {:ok, user_info} ->
        json(conn, %{
          id: user_info.user.id,
          display_name: user_info.user.display_name,
          email: get_primary_email(user_info.user.emails),
          provider: user_info.user.provider
        })
      {:error, :authentication_error, _message} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication failed"})
      {:error, :api_error, message} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: message})
    end
  end
  
  defp get_primary_email(emails) do
    case emails do
      [email | _] -> email.value
      [] -> nil
    end
  end
end
```

### Phoenix LiveView Example

```elixir
defmodule MyAppWeb.UserLive do
  use MyAppWeb, :live_view
  
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
  
  def handle_event("fetch_user", %{"access_token" => access_token}, socket) do
    client = Authdog.Client.new("https://api.authdog.com")
    
    case Authdog.Client.get_user_info(client, access_token) do
      {:ok, user_info} ->
        {:noreply, assign(socket, :user_info, user_info)}
      {:error, :authentication_error, message} ->
        {:noreply, put_flash(socket, :error, "Authentication failed: #{message}")}
      {:error, :api_error, message} ->
        {:noreply, put_flash(socket, :error, "API error: #{message}")}
    end
  end
  
  def render(assigns) do
    ~H"""
    <div>
      <h1>User Information</h1>
      <%= if @user_info do %>
        <p>Name: <%= @user_info.user.display_name %></p>
        <p>Email: <%= get_primary_email(@user_info.user.emails) %></p>
        <p>Provider: <%= @user_info.user.provider %></p>
      <% else %>
        <p>No user information available</p>
      <% end %>
    </div>
    """
  end
  
  defp get_primary_email(emails) do
    case emails do
      [email | _] -> email.value
      [] -> "No email"
    end
  end
end
```

### GenServer Example

```elixir
defmodule MyApp.AuthdogClient do
  use GenServer
  
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  def get_user_info(access_token) do
    GenServer.call(__MODULE__, {:get_user_info, access_token})
  end
  
  def init(opts) do
    base_url = Keyword.get(opts, :base_url, "https://api.authdog.com")
    api_key = Keyword.get(opts, :api_key)
    timeout = Keyword.get(opts, :timeout, 10_000)
    
    client = Authdog.Client.new(base_url, api_key: api_key, timeout: timeout)
    
    {:ok, %{client: client}}
  end
  
  def handle_call({:get_user_info, access_token}, _from, state) do
    result = Authdog.Client.get_user_info(state.client, access_token)
    {:reply, result, state}
  end
end
```

## Development

### Running Tests

```bash
mix test
```

### Code Analysis

```bash
# Credo for code quality
mix credo

# Dialyxir for type checking
mix dialyzer
```

### Requirements

- Elixir 1.12+
- Mix
- Req HTTP client
- Jason JSON library

## License

MIT License - see [LICENSE](../LICENSE) for details.
