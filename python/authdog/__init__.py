"""Authdog Python SDK - Authentication and user management SDK."""

from .client import AuthdogClient
from .exceptions import AuthdogError, AuthenticationError, APIError
from .types import (
    Email,
    EnvGroup,
    EnvUser,
    Environment,
    Meta,
    Names,
    Organization,
    OrganizationsList,
    Photo,
    Probe,
    Project,
    Session,
    Tenant,
    TenantsList,
    User,
    UserInfoResponse,
    Verification,
)

__version__ = "0.1.1"
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
    "Probe",
    "Organization",
    "OrganizationsList",
    "Tenant",
    "TenantsList",
    "EnvUser",
    "EnvGroup",
    "Environment",
    "Project",
]
