"""Tests for AuthdogClient."""

import pytest
import httpx
from unittest.mock import Mock, patch
from authdog.client import AuthdogClient
from authdog.exceptions import AuthenticationError, APIError


class TestAuthdogClient:
    """Test cases for AuthdogClient."""

    def test_init_with_api_key(self):
        """Test client initialization with API key."""
        client = AuthdogClient("https://api.authdog.com", "test-api-key")
        assert client.base_url == "https://api.authdog.com"
        assert client.api_key == "test-api-key"

    def test_init_without_api_key(self):
        """Test client initialization without API key."""
        client = AuthdogClient("https://api.authdog.com")
        assert client.base_url == "https://api.authdog.com"
        assert client.api_key is None

    def test_init_strips_trailing_slash(self):
        """Test that trailing slash is stripped from base URL."""
        client = AuthdogClient("https://api.authdog.com/")
        assert client.base_url == "https://api.authdog.com"

    def test_get_default_headers_with_api_key(self):
        """Test default headers include API key when provided."""
        client = AuthdogClient("https://api.authdog.com", "test-api-key")
        headers = client._get_default_headers()
        
        assert headers["Content-Type"] == "application/json"
        assert headers["User-Agent"] == "authdog-python-sdk/0.1.0"
        assert headers["Authorization"] == "Bearer test-api-key"

    def test_get_default_headers_without_api_key(self):
        """Test default headers don't include API key when not provided."""
        client = AuthdogClient("https://api.authdog.com")
        headers = client._get_default_headers()
        
        assert headers["Content-Type"] == "application/json"
        assert headers["User-Agent"] == "authdog-python-sdk/0.1.0"
        assert "Authorization" not in headers

    @patch('httpx.Client')
    def test_get_userinfo_success(self, mock_client_class):
        """Test successful userinfo retrieval."""
        # Mock response
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "meta": {"code": 200, "message": "OK"},
            "user": {"id": "123", "name": "Test User"}
        }
        
        # Mock client
        mock_client = Mock()
        mock_client.get.return_value = mock_response
        mock_client_class.return_value = mock_client
        
        client = AuthdogClient("https://api.authdog.com")
        result = client.get_userinfo("test-token")
        
        assert result["user"]["id"] == "123"
        assert result["user"]["name"] == "Test User"
        mock_client.get.assert_called_once_with(
            "/v1/userinfo", 
            headers={"Authorization": "Bearer test-token"}
        )

    @patch('httpx.Client')
    def test_get_userinfo_unauthorized(self, mock_client_class):
        """Test userinfo retrieval with unauthorized token."""
        # Mock response
        mock_response = Mock()
        mock_response.status_code = 401
        
        # Mock client
        mock_client = Mock()
        mock_client.get.return_value = mock_response
        mock_client_class.return_value = mock_client
        
        client = AuthdogClient("https://api.authdog.com")
        
        with pytest.raises(AuthenticationError, match="Unauthorized - invalid or expired token"):
            client.get_userinfo("invalid-token")

    @patch('httpx.Client')
    def test_get_userinfo_graphql_error(self, mock_client_class):
        """Test userinfo retrieval with GraphQL error."""
        # Mock response
        mock_response = Mock()
        mock_response.status_code = 500
        mock_response.json.return_value = {"error": "GraphQL query failed"}
        
        # Mock client
        mock_client = Mock()
        mock_client.get.return_value = mock_response
        mock_client_class.return_value = mock_client
        
        client = AuthdogClient("https://api.authdog.com")
        
        with pytest.raises(APIError, match="GraphQL query failed"):
            client.get_userinfo("test-token")

    @patch('httpx.Client')
    def test_get_userinfo_fetch_error(self, mock_client_class):
        """Test userinfo retrieval with fetch error."""
        # Mock response
        mock_response = Mock()
        mock_response.status_code = 500
        mock_response.json.return_value = {"error": "Failed to fetch user info"}
        
        # Mock client
        mock_client = Mock()
        mock_client.get.return_value = mock_response
        mock_client_class.return_value = mock_client
        
        client = AuthdogClient("https://api.authdog.com")
        
        with pytest.raises(APIError, match="Failed to fetch user info"):
            client.get_userinfo("test-token")

    @patch('httpx.Client')
    def test_get_userinfo_http_error(self, mock_client_class):
        """Test userinfo retrieval with HTTP error."""
        # Mock client that raises HTTPStatusError
        mock_client = Mock()
        mock_client.get.side_effect = httpx.HTTPStatusError(
            "Bad Request", 
            request=Mock(), 
            response=Mock(status_code=400, text="Bad Request")
        )
        mock_client_class.return_value = mock_client
        
        client = AuthdogClient("https://api.authdog.com")
        
        with pytest.raises(APIError, match="HTTP error 400"):
            client.get_userinfo("test-token")

    @patch('httpx.Client')
    def test_get_userinfo_request_error(self, mock_client_class):
        """Test userinfo retrieval with request error."""
        # Mock client that raises RequestError
        mock_client = Mock()
        mock_client.get.side_effect = httpx.RequestError("Connection failed")
        mock_client_class.return_value = mock_client
        
        client = AuthdogClient("https://api.authdog.com")
        
        with pytest.raises(APIError, match="Request failed: Connection failed"):
            client.get_userinfo("test-token")

    @patch('httpx.Client')
    def test_close(self, mock_client_class):
        """Test client close method."""
        mock_client = Mock()
        mock_client_class.return_value = mock_client
        
        client = AuthdogClient("https://api.authdog.com")
        client.close()
        
        mock_client.close.assert_called_once()

    @patch('httpx.Client')
    def test_context_manager(self, mock_client_class):
        """Test client as context manager."""
        mock_client = Mock()
        mock_client_class.return_value = mock_client
        
        with AuthdogClient("https://api.authdog.com") as client:
            assert isinstance(client, AuthdogClient)
        
        mock_client.close.assert_called_once()
