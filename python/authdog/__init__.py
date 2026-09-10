"""Authdog Python SDK - Authentication and user management SDK."""

from .client import AuthdogClient
from .exceptions import AuthdogError, AuthenticationError, APIError
from .types import (
    Email,
    Meta,
    Names,
    Photo,
    Session,
    User,
    UserInfoResponse,
    Verification,
)

__version__ = "0.1.0"
__all__ = [
    "AuthdogClient",
    "AuthdogError",
    "AuthenticationError",
    "APIError",
    "UserInfoResponse",
    "Meta",
    "Session",
    "User",
    "Names",
    "Email",
    "Photo",
    "Verification",
]
