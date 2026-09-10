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
