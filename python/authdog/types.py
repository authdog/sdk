"""Typed models for the Authdog /v1/userinfo response."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional


def _str(data: Dict[str, Any], key: str, default: str = "") -> str:
    value = data.get(key, default)
    return default if value is None else str(value)


def _opt_str(data: Dict[str, Any], key: str) -> Optional[str]:
    value = data.get(key)
    return None if value is None else str(value)


@dataclass
class Meta:
    code: int = 0
    message: str = ""

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "Meta":
        data = data or {}
        return cls(code=int(data.get("code") or 0), message=_str(data, "message"))


@dataclass
class Session:
    remaining_seconds: int = 0

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "Session":
        data = data or {}
        return cls(remaining_seconds=int(data.get("remainingSeconds") or 0))


@dataclass
class Names:
    id: str = ""
    formatted: Optional[str] = None
    family_name: str = ""
    given_name: str = ""
    middle_name: Optional[str] = None
    honorific_prefix: Optional[str] = None
    honorific_suffix: Optional[str] = None

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "Names":
        data = data or {}
        return cls(
            id=_str(data, "id"),
            formatted=_opt_str(data, "formatted"),
            family_name=_str(data, "familyName"),
            given_name=_str(data, "givenName"),
            middle_name=_opt_str(data, "middleName"),
            honorific_prefix=_opt_str(data, "honorificPrefix"),
            honorific_suffix=_opt_str(data, "honorificSuffix"),
        )


@dataclass
class Photo:
    id: str = ""
    value: str = ""
    type: str = ""

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "Photo":
        data = data or {}
        return cls(id=_str(data, "id"), value=_str(data, "value"), type=_str(data, "type"))


@dataclass
class Email:
    id: str = ""
    value: str = ""
    type: Optional[str] = None

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "Email":
        data = data or {}
        return cls(id=_str(data, "id"), value=_str(data, "value"), type=_opt_str(data, "type"))


@dataclass
class Verification:
    id: str = ""
    email: str = ""
    verified: bool = False
    created_at: str = ""
    updated_at: str = ""

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "Verification":
        data = data or {}
        return cls(
            id=_str(data, "id"),
            email=_str(data, "email"),
            verified=bool(data.get("verified", False)),
            created_at=_str(data, "createdAt"),
            updated_at=_str(data, "updatedAt"),
        )


@dataclass
class User:
    id: str = ""
    external_id: str = ""
    user_name: str = ""
    display_name: str = ""
    nick_name: Optional[str] = None
    profile_url: Optional[str] = None
    title: Optional[str] = None
    user_type: Optional[str] = None
    preferred_language: Optional[str] = None
    locale: str = ""
    timezone: Optional[str] = None
    active: bool = False
    names: Names = field(default_factory=Names)
    photos: List[Photo] = field(default_factory=list)
    phone_numbers: List[Any] = field(default_factory=list)
    addresses: List[Any] = field(default_factory=list)
    emails: List[Email] = field(default_factory=list)
    verifications: List[Verification] = field(default_factory=list)
    provider: str = ""
    created_at: str = ""
    updated_at: str = ""
    environment_id: str = ""

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "User":
        data = data or {}
        return cls(
            id=_str(data, "id"),
            external_id=_str(data, "externalId"),
            user_name=_str(data, "userName"),
            display_name=_str(data, "displayName"),
            nick_name=_opt_str(data, "nickName"),
            profile_url=_opt_str(data, "profileUrl"),
            title=_opt_str(data, "title"),
            user_type=_opt_str(data, "userType"),
            preferred_language=_opt_str(data, "preferredLanguage"),
            locale=_str(data, "locale"),
            timezone=_opt_str(data, "timezone"),
            active=bool(data.get("active", False)),
            names=Names.from_dict(data.get("names")),
            photos=[Photo.from_dict(item) for item in data.get("photos") or []],
            phone_numbers=list(data.get("phoneNumbers") or []),
            addresses=list(data.get("addresses") or []),
            emails=[Email.from_dict(item) for item in data.get("emails") or []],
            verifications=[
                Verification.from_dict(item) for item in data.get("verifications") or []
            ],
            provider=_str(data, "provider"),
            created_at=_str(data, "createdAt"),
            updated_at=_str(data, "updatedAt"),
            environment_id=_str(data, "environmentId"),
        )


@dataclass
class UserInfoResponse:
    meta: Meta = field(default_factory=Meta)
    session: Session = field(default_factory=Session)
    user: User = field(default_factory=User)

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "UserInfoResponse":
        data = data or {}
        return cls(
            meta=Meta.from_dict(data.get("meta")),
            session=Session.from_dict(data.get("session")),
            user=User.from_dict(data.get("user")),
        )


def _bool(data: Dict[str, Any], key: str, default: bool = False) -> bool:
    value = data.get(key, default)
    return default if value is None else bool(value)


def _opt_bool(data: Dict[str, Any], key: str) -> Optional[bool]:
    value = data.get(key)
    return None if value is None else bool(value)


def _int(data: Dict[str, Any], key: str, default: int = 0) -> int:
    value = data.get(key, default)
    try:
        return default if value is None else int(value)
    except (TypeError, ValueError):
        return default


def _opt_float(data: Dict[str, Any], key: str) -> Optional[float]:
    value = data.get(key)
    if value is None:
        return None
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


@dataclass
class Probe:
    ok: bool = False

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "Probe":
        data = data or {}
        return cls(ok=_bool(data, "ok"))


@dataclass
class Organization:
    id: str = ""
    name: str = ""
    description: Optional[str] = None
    billing_email: Optional[str] = None
    logo_uri: Optional[str] = None
    active: bool = False
    created_at: str = ""
    updated_at: str = ""

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "Organization":
        data = data or {}
        return cls(
            id=_str(data, "id"),
            name=_str(data, "name"),
            description=_opt_str(data, "description"),
            billing_email=_opt_str(data, "billingEmail"),
            logo_uri=_opt_str(data, "logoUri"),
            active=_bool(data, "active"),
            created_at=_str(data, "createdAt"),
            updated_at=_str(data, "updatedAt"),
        )


@dataclass
class OrganizationsList:
    organizations: List[Organization] = field(default_factory=list)
    total: int = 0

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "OrganizationsList":
        data = data or {}
        return cls(
            organizations=[
                Organization.from_dict(item) for item in data.get("organizations") or []
            ],
            total=_int(data, "total"),
        )


@dataclass
class OrganizationResponse:
    organization: Organization = field(default_factory=Organization)

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "OrganizationResponse":
        data = data or {}
        return cls(organization=Organization.from_dict(data.get("organization")))


@dataclass
class SuccessIdResponse:
    success: bool = False
    id: str = ""

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "SuccessIdResponse":
        data = data or {}
        return cls(success=_bool(data, "success"), id=_str(data, "id"))


@dataclass
class Tenant:
    id: str = ""
    name: str = ""
    description: Optional[str] = None
    company: Optional[str] = None
    active: bool = False
    created_at: str = ""
    updated_at: str = ""
    organization_ids: List[str] = field(default_factory=list)

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "Tenant":
        data = data or {}
        return cls(
            id=_str(data, "id"),
            name=_str(data, "name"),
            description=_opt_str(data, "description"),
            company=_opt_str(data, "company"),
            active=_bool(data, "active"),
            created_at=_str(data, "createdAt"),
            updated_at=_str(data, "updatedAt"),
            organization_ids=[str(item) for item in data.get("organizationIds") or []],
        )


@dataclass
class TenantsList:
    tenants: List[Tenant] = field(default_factory=list)
    total: int = 0

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "TenantsList":
        data = data or {}
        return cls(
            tenants=[Tenant.from_dict(item) for item in data.get("tenants") or []],
            total=_int(data, "total"),
        )


@dataclass
class TenantResponse:
    tenant: Tenant = field(default_factory=Tenant)

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "TenantResponse":
        data = data or {}
        return cls(tenant=Tenant.from_dict(data.get("tenant")))


@dataclass
class EnvUserEmail:
    id: str = ""
    value: str = ""
    type: Optional[str] = None

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "EnvUserEmail":
        data = data or {}
        return cls(id=_str(data, "id"), value=_str(data, "value"), type=_opt_str(data, "type"))


@dataclass
class EnvUser:
    id: str = ""
    environment_id: Optional[str] = None
    external_id: Optional[str] = None
    user_name: Optional[str] = None
    display_name: Optional[str] = None
    nick_name: Optional[str] = None
    profile_url: Optional[str] = None
    active: Optional[bool] = None
    change_pw: Optional[bool] = None
    provider: Optional[str] = None
    emails: List[EnvUserEmail] = field(default_factory=list)
    last_login: Optional[str] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "EnvUser":
        data = data or {}
        return cls(
            id=_str(data, "id"),
            environment_id=_opt_str(data, "environmentId"),
            external_id=_opt_str(data, "externalId"),
            user_name=_opt_str(data, "userName"),
            display_name=_opt_str(data, "displayName"),
            nick_name=_opt_str(data, "nickName"),
            profile_url=_opt_str(data, "profileUrl"),
            active=_opt_bool(data, "active"),
            change_pw=_opt_bool(data, "changePw"),
            provider=_opt_str(data, "provider"),
            emails=[EnvUserEmail.from_dict(item) for item in data.get("emails") or []],
            last_login=_opt_str(data, "lastLogin"),
            created_at=_opt_str(data, "createdAt"),
            updated_at=_opt_str(data, "updatedAt"),
        )


@dataclass
class EnvUsersResponse:
    users: List[EnvUser] = field(default_factory=list)

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "EnvUsersResponse":
        data = data or {}
        return cls(users=[EnvUser.from_dict(item) for item in data.get("users") or []])


@dataclass
class EnvUserResponse:
    user: EnvUser = field(default_factory=EnvUser)

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "EnvUserResponse":
        data = data or {}
        return cls(user=EnvUser.from_dict(data.get("user")))


@dataclass
class EnvGroup:
    id: str = ""
    environment_id: str = ""
    name: str = ""
    slug: str = ""
    description: Optional[str] = None
    member_count: int = 0
    joined_at: Optional[str] = None
    created_at: str = ""
    updated_at: str = ""

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "EnvGroup":
        data = data or {}
        return cls(
            id=_str(data, "id"),
            environment_id=_str(data, "environmentId"),
            name=_str(data, "name"),
            slug=_str(data, "slug"),
            description=_opt_str(data, "description"),
            member_count=_int(data, "memberCount"),
            joined_at=_opt_str(data, "joinedAt"),
            created_at=_str(data, "createdAt"),
            updated_at=_str(data, "updatedAt"),
        )


@dataclass
class EnvGroupsResponse:
    groups: List[EnvGroup] = field(default_factory=list)

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "EnvGroupsResponse":
        data = data or {}
        return cls(groups=[EnvGroup.from_dict(item) for item in data.get("groups") or []])


@dataclass
class Environment:
    id: str = ""
    name: str = ""
    description: Optional[str] = None
    weight: Optional[float] = None
    is_live: Optional[bool] = None
    is_default: Optional[bool] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "Environment":
        data = data or {}
        return cls(
            id=_str(data, "id"),
            name=_str(data, "name"),
            description=_opt_str(data, "description"),
            weight=_opt_float(data, "weight"),
            is_live=_opt_bool(data, "isLive"),
            is_default=_opt_bool(data, "isDefault"),
            created_at=_opt_str(data, "createdAt"),
            updated_at=_opt_str(data, "updatedAt"),
        )


@dataclass
class Project:
    id: str = ""
    name: str = ""
    description: Optional[str] = None

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "Project":
        data = data or {}
        return cls(
            id=_str(data, "id"),
            name=_str(data, "name"),
            description=_opt_str(data, "description"),
        )


@dataclass
class JsonMap:
    """Forward-compatible envelope for less common Wave 1 responses."""

    data: Dict[str, Any] = field(default_factory=dict)

    @classmethod
    def from_dict(cls, data: Optional[Dict[str, Any]]) -> "JsonMap":
        return cls(data=data or {})

    def get(self, key: str, default: Any = None) -> Any:
        return self.data.get(key, default)
