"""Custom exceptions for Authdog SDK."""


class AuthdogError(Exception):
    """Base exception for all Authdog SDK errors."""
    pass


class AuthenticationError(AuthdogError):
    """Raised when authentication fails."""
    pass


class APIError(AuthdogError):
    """Raised when API requests fail."""

    def __init__(self, message: str, status_code=None):
        super().__init__(message)
        self.status_code = status_code
