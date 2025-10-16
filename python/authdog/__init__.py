"""Authdog Python SDK - Authentication and user management SDK."""

from .client import AuthdogClient
from .exceptions import AuthdogError, AuthenticationError, APIError

__version__ = "0.1.0"
__all__ = ["AuthdogClient", "AuthdogError", "AuthenticationError", "APIError"]
