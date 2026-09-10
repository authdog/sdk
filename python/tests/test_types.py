"""Tests for typed user-info models."""

from authdog.types import UserInfoResponse


SAMPLE = {
    "meta": {"code": 200, "message": "Success"},
    "session": {"remainingSeconds": 3600},
    "user": {
        "id": "user-123",
        "externalId": "ext-123",
        "userName": "testuser",
        "displayName": "Test User",
        "nickName": None,
        "profileUrl": None,
        "title": None,
        "userType": None,
        "preferredLanguage": None,
        "locale": "en-US",
        "timezone": None,
        "active": True,
        "names": {
            "id": "name-123",
            "formatted": "Test User",
            "familyName": "User",
            "givenName": "Test",
            "middleName": None,
            "honorificPrefix": None,
            "honorificSuffix": None,
        },
        "photos": [],
        "phoneNumbers": [],
        "addresses": [],
        "emails": [{"id": "email-123", "value": "test@example.com", "type": "primary"}],
        "verifications": [
            {
                "id": "verification-123",
                "email": "test@example.com",
                "verified": True,
                "createdAt": "2023-01-01T00:00:00Z",
                "updatedAt": "2023-01-01T00:00:00Z",
            }
        ],
        "provider": "authdog",
        "createdAt": "2023-01-01T00:00:00Z",
        "updatedAt": "2023-01-01T00:00:00Z",
        "environmentId": "env-123",
    },
}


def test_from_dict_maps_camel_case_fields():
    info = UserInfoResponse.from_dict(SAMPLE)
    assert info.meta.code == 200
    assert info.session.remaining_seconds == 3600
    assert info.user.id == "user-123"
    assert info.user.display_name == "Test User"
    assert info.user.emails[0].value == "test@example.com"
    assert info.user.verifications[0].verified is True


def test_from_dict_tolerates_partial_payloads():
    info = UserInfoResponse.from_dict({"user": {"id": "123"}})
    assert info.user.id == "123"
    assert info.user.display_name == ""
    assert info.session.remaining_seconds == 0
