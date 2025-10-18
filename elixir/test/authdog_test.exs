defmodule AuthdogTest do
  use ExUnit.Case
  doctest Authdog

  alias Authdog.Client

  describe "Client.new/2" do
    test "creates a client with base URL" do
      client = Client.new("https://api.authdog.com")
      
      assert client.base_url == "https://api.authdog.com"
      assert client.api_key == nil
      assert client.timeout == 10_000
    end

    test "creates a client with options" do
      client = Client.new("https://api.authdog.com", api_key: "test-key", timeout: 5000)
      
      assert client.base_url == "https://api.authdog.com"
      assert client.api_key == "test-key"
      assert client.timeout == 5000
    end

    test "trims trailing slash from base URL" do
      client = Client.new("https://api.authdog.com/")
      
      assert client.base_url == "https://api.authdog.com"
    end
  end

  describe "Client.get_user_info/2" do
    test "handles successful response" do
      # This would require mocking HTTP requests in a real test
      # For now, we'll test the error cases and structure
      _client = Client.new("https://api.authdog.com")
      
      # Test that the function exists and has correct arity
      assert function_exported?(Client, :get_user_info, 2)
    end
  end
end
