defmodule Authdog do
  @moduledoc """
  Official Elixir SDK for Authdog authentication and user management platform.

  ## Quick Start

      iex> client = Authdog.Client.new("https://api.authdog.com")
      iex> client.base_url
      "https://api.authdog.com"

  ## Configuration

      client = Authdog.Client.new("https://api.authdog.com", api_key: "your-api-key")

  ## Error Handling

      case Authdog.Client.get_user_info(client, "token") do
        {:ok, user_info} -> 
          IO.puts("User: " <> user_info.user.display_name)
        {:error, :authentication_error, message} -> 
          IO.puts("Authentication failed: " <> message)
        {:error, :api_error, message} -> 
          IO.puts("API error: " <> message)
      end
  """

  @doc """
  Creates a new Authdog client.

  ## Parameters

    * `base_url` - The base URL of the Authdog API
    * `opts` - Optional configuration

  ## Options

    * `:api_key` - Optional API key for authentication
    * `:timeout` - Request timeout in milliseconds (default: 10000)

  ## Examples

      iex> _client = Authdog.Client.new("https://api.authdog.com")
      iex> _client = Authdog.Client.new("https://api.authdog.com", api_key: "key", timeout: 5000)
  """
  defdelegate new(base_url, opts \\ []), to: Authdog.Client

  @doc """
  Gets user information using an access token.

  ## Parameters

    * `client` - The Authdog client
    * `access_token` - The access token for authentication

  ## Returns

    * `{:ok, user_info}` - On success
    * `{:error, :authentication_error, message}` - When authentication fails
    * `{:error, :api_error, message}` - When API request fails

  ## Examples

      iex> client = Authdog.Client.new("https://api.authdog.com")
      iex> client.base_url
      "https://api.authdog.com"
  """
  defdelegate get_user_info(client, access_token), to: Authdog.Client
end
