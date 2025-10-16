"""Custom exceptions for Authdog SDK."""


class AuthdogError(Exception):
    """Base exception for all Authdog SDK errors."""
    pass


class AuthenticationError(AuthdogError):
    """Raised when authentication fails."""
    pass


class APIError(AuthdogError):
    """Raised when API requests fail."""
    pass
