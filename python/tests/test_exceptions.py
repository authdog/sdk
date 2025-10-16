"""Tests for Authdog exceptions."""

import pytest
from authdog.exceptions import AuthdogError, AuthenticationError, APIError


class TestAuthdogExceptions:
    """Test cases for Authdog exceptions."""

    def test_authdog_error_inheritance(self):
        """Test that AuthdogError is the base exception."""
        assert issubclass(AuthenticationError, AuthdogError)
        assert issubclass(APIError, AuthdogError)

    def test_authdog_error_instantiation(self):
        """Test AuthdogError can be instantiated."""
        error = AuthdogError("Test error")
        assert str(error) == "Test error"

    def test_authentication_error_instantiation(self):
        """Test AuthenticationError can be instantiated."""
        error = AuthenticationError("Authentication failed")
        assert str(error) == "Authentication failed"
        assert isinstance(error, AuthdogError)

    def test_api_error_instantiation(self):
        """Test APIError can be instantiated."""
        error = APIError("API request failed")
        assert str(error) == "API request failed"
        assert isinstance(error, AuthdogError)

    def test_exception_raising(self):
        """Test that exceptions can be raised and caught."""
        with pytest.raises(AuthenticationError):
            raise AuthenticationError("Test authentication error")
        
        with pytest.raises(APIError):
            raise APIError("Test API error")
        
        with pytest.raises(AuthdogError):
            raise AuthdogError("Test base error")
