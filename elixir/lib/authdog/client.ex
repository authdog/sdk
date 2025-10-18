defmodule Authdog.Client do
  @moduledoc """
  Authdog API client for making HTTP requests.
  """

  defstruct [
    :base_url,
    :api_key,
    :timeout,
    :req_client
  ]

  @type t :: %__MODULE__{
    base_url: String.t(),
    api_key: String.t() | nil,
    timeout: integer(),
    req_client: Req.Request.t()
  }

  @doc """
  Creates a new Authdog client.

  ## Parameters

    * `base_url` - The base URL of the Authdog API
    * `opts` - Optional configuration

  ## Options

    * `:api_key` - Optional API key for authentication
    * `:timeout` - Request timeout in milliseconds (default: 10000)

  ## Examples

      iex> client = Authdog.Client.new("https://api.authdog.com")
      iex> client = Authdog.Client.new("https://api.authdog.com", api_key: "key", timeout: 5000)
  """
  @spec new(String.t(), keyword()) :: t()
  def new(base_url, opts \\ []) do
    base_url = String.trim_trailing(base_url, "/")
    api_key = Keyword.get(opts, :api_key)
    timeout = Keyword.get(opts, :timeout, 10_000)

    req_client = Req.new(
      base_url: base_url,
      receive_timeout: timeout,
      headers: [
        {"content-type", "application/json"},
        {"user-agent", "authdog-elixir-sdk/0.1.0"}
      ]
    )

    %__MODULE__{
      base_url: base_url,
      api_key: api_key,
      timeout: timeout,
      req_client: req_client
    }
  end

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

      iex> {:ok, user_info} = Authdog.Client.get_user_info(client, "your-access-token")
      iex> user_info.user.display_name
      "John Doe"
  """
  @spec get_user_info(t(), String.t()) :: 
    {:ok, Authdog.Types.UserInfoResponse.t()} | 
    {:error, :authentication_error, String.t()} | 
    {:error, :api_error, String.t()}
  def get_user_info(%__MODULE__{} = client, access_token) do
    headers = [
      {"authorization", "Bearer #{access_token}"}
    ]

    # Add API key if provided
    headers = if client.api_key do
      [{"authorization", "Bearer #{client.api_key}"} | headers]
    else
      headers
    end

    case Req.get(client.req_client, url: "/v1/userinfo", headers: headers) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
            user_info = Authdog.Types.UserInfoResponse.from_map(data)
            {:ok, user_info}
          {:error, _} ->
            {:error, :api_error, "Failed to parse response"}
        end

      {:ok, %Req.Response{status: 401}} ->
        {:error, :authentication_error, "Unauthorized - invalid or expired token"}

      {:ok, %Req.Response{status: 500, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"error" => error_message}} ->
            case error_message do
              "GraphQL query failed" ->
                {:error, :api_error, "GraphQL query failed"}
              "Failed to fetch user info" ->
                {:error, :api_error, "Failed to fetch user info"}
              _ ->
                {:error, :api_error, "HTTP error 500: #{inspect(body)}"}
            end
          _ ->
            {:error, :api_error, "HTTP error 500: #{inspect(body)}"}
        end

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, :api_error, "HTTP error #{status}: #{inspect(body)}"}

      {:error, reason} ->
        {:error, :api_error, "Request failed: #{inspect(reason)}"}
    end
  end
end
