# MIT License
#
# Copyright (c) 2025 Authdog
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
