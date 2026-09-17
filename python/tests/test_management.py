"""Wave 1 management API tests."""

from unittest.mock import Mock, patch

import httpx
import pytest

from authdog.client import AuthdogClient
from authdog.exceptions import APIError, AuthenticationError


def _json_response(payload, status_code=200):
    response = Mock()
    response.status_code = status_code
    response.content = b"{}" if payload is not None else b""
    response.text = "" if payload is None else "error"
    response.json.return_value = payload
    return response


def _client_with_request(mock_client_class, response):
    mock_http = Mock()
    mock_http.request.return_value = response
    mock_client_class.return_value = mock_http
    client = AuthdogClient("https://api.authdog.com", "key-1")
    return client, mock_http


@patch("httpx.Client")
def test_health_public(mock_client_class):
    client, mock_http = _client_with_request(
        mock_client_class, _json_response({"ok": True})
    )
    probe = client.health()
    assert probe.ok is True
    mock_http.request.assert_called_once()
    args, kwargs = mock_http.request.call_args
    assert args[0] == "GET"
    assert args[1] == "/v1/health"


@patch("httpx.Client")
def test_management_uses_constructor_key(mock_client_class):
    client, mock_http = _client_with_request(
        mock_client_class, _json_response({"organizations": [], "total": 0})
    )
    result = client.organizations.list()
    assert result.organizations == []
    assert result.total == 0
    headers = client._get_default_headers()
    assert headers["Authorization"] == "Bearer key-1"


@patch("httpx.Client")
def test_management_401_is_authentication_error(mock_client_class):
    client, _ = _client_with_request(mock_client_class, _json_response({}, 401))
    with pytest.raises(AuthenticationError):
        client.organizations.list()


@patch("httpx.Client")
def test_management_404_includes_status_and_error(mock_client_class):
    response = _json_response({"error": "not found"}, 404)
    response.text = '{"error":"not found"}'
    client, _ = _client_with_request(mock_client_class, response)
    with pytest.raises(APIError, match="HTTP error 404") as exc:
        client.organizations.get("missing")
    assert exc.value.status_code == 404
    assert "not found" in str(exc.value)


@patch("httpx.Client")
def test_management_transport_error(mock_client_class):
    mock_http = Mock()
    mock_http.request.side_effect = httpx.RequestError("Connection failed")
    mock_client_class.return_value = mock_http
    client = AuthdogClient("https://api.authdog.com", "key-1")
    with pytest.raises(APIError, match="Request failed: Connection failed"):
        client.tenants.list()


@patch("httpx.Client")
def test_userinfo_still_sends_access_token(mock_client_class):
    mock_response = Mock()
    mock_response.status_code = 200
    mock_response.json.return_value = {
        "meta": {"code": 200, "message": "OK"},
        "user": {"id": "123", "displayName": "Ada"},
    }
    mock_http = Mock()
    mock_http.get.return_value = mock_response
    mock_client_class.return_value = mock_http
    client = AuthdogClient("https://api.authdog.com", "key-1")
    result = client.get_userinfo("token-2")
    assert result.user.id == "123"
    mock_http.get.assert_called_once_with(
        "/v1/userinfo",
        headers={"Authorization": "Bearer token-2"},
    )


ORG_TENANT_CASES = [
    (lambda c: c.organizations.list(), "GET", "/v1/organizations", None),
    (lambda c: c.organizations.create({"name": "Acme"}), "POST", "/v1/organizations", {"name": "Acme"}),
    (lambda c: c.organizations.get("org_1"), "GET", "/v1/organizations/org_1", None),
    (lambda c: c.organizations.update("org_1", {"name": "New"}), "PATCH", "/v1/organizations/org_1", {"name": "New"}),
    (lambda c: c.organizations.delete("org_1"), "DELETE", "/v1/organizations/org_1", None),
    (lambda c: c.organizations.accept_invitation({"token": "t"}), "POST", "/v1/organizations/invitations/accept", {"token": "t"}),
    (lambda c: c.organizations.join({"invitationCode": "c"}), "POST", "/v1/organizations/join", {"invitationCode": "c"}),
    (lambda c: c.organizations.list_invitations("org_1"), "GET", "/v1/organizations/org_1/invitations", None),
    (lambda c: c.organizations.create_invitation("org_1", {"email": "a@b.c"}), "POST", "/v1/organizations/org_1/invitations", {"email": "a@b.c"}),
    (lambda c: c.organizations.cancel_invitation("org_1", "inv_1"), "POST", "/v1/organizations/org_1/invitations/inv_1/cancel", None),
    (lambda c: c.organizations.send_invite("org_1", {"email": "a@b.c"}), "POST", "/v1/organizations/org_1/invites", {"email": "a@b.c"}),
    (lambda c: c.organizations.list_members("org_1"), "GET", "/v1/organizations/org_1/members", None),
    (lambda c: c.organizations.remove_member("org_1", "mem_1"), "DELETE", "/v1/organizations/org_1/members/mem_1", None),
    (lambda c: c.organizations.set_member_active("org_1", "mem_1", {"active": False}), "PATCH", "/v1/organizations/org_1/members/mem_1/active", {"active": False}),
    (lambda c: c.organizations.link_tenant("org_1", {"tenantId": "ten_1"}), "POST", "/v1/organizations/org_1/tenants", {"tenantId": "ten_1"}),
    (lambda c: c.organizations.unlink_tenant("org_1", "ten_1"), "DELETE", "/v1/organizations/org_1/tenants/ten_1", None),
    (lambda c: c.tenants.list(), "GET", "/v1/tenants", None),
    (lambda c: c.tenants.create({"name": "T"}), "POST", "/v1/tenants", {"name": "T"}),
    (lambda c: c.tenants.join({"invitationCode": "c"}), "POST", "/v1/tenants/join", {"invitationCode": "c"}),
    (lambda c: c.tenants.get("ten_1"), "GET", "/v1/tenants/ten_1", None),
    (lambda c: c.tenants.update("ten_1", {"name": "N"}), "PATCH", "/v1/tenants/ten_1", {"name": "N"}),
    (lambda c: c.tenants.delete("ten_1"), "DELETE", "/v1/tenants/ten_1", None),
    (lambda c: c.tenants.list_domains("ten_1"), "GET", "/v1/tenants/ten_1/domains", None),
    (lambda c: c.tenants.create_domain("ten_1", {"domain": "a.com", "validationMethod": "dns"}), "POST", "/v1/tenants/ten_1/domains", {"domain": "a.com", "validationMethod": "dns"}),
    (lambda c: c.tenants.delete_domain("ten_1", "dom_1"), "DELETE", "/v1/tenants/ten_1/domains/dom_1", None),
    (lambda c: c.tenants.retry_domain("ten_1", "dom_1"), "POST", "/v1/tenants/ten_1/domains/dom_1/retry", None),
    (lambda c: c.tenants.send_invite("ten_1", {"email": "a@b.c"}), "POST", "/v1/tenants/ten_1/invites", {"email": "a@b.c"}),
    (lambda c: c.tenants.list_projects("ten_1"), "GET", "/v1/tenants/ten_1/projects", None),
    (lambda c: c.tenants.list_seats("ten_1"), "GET", "/v1/tenants/ten_1/seats", None),
    (lambda c: c.tenants.update_seat("ten_1", "seat_1", {"active": True}), "PATCH", "/v1/tenants/ten_1/seats/seat_1", {"active": True}),
    (lambda c: c.tenants.delete_seat("ten_1", "seat_1"), "DELETE", "/v1/tenants/ten_1/seats/seat_1", None),
]


DIRECTORY_CASES = [
    (lambda c: c.projects.save("ten_1", {"name": "App"}), "POST", "/v1/tenants/ten_1/applications", {"name": "App"}),
    (lambda c: c.projects.get("ten_1", "app_1"), "GET", "/v1/tenants/ten_1/applications/app_1", None),
    (lambda c: c.projects.delete("ten_1", "app_1"), "DELETE", "/v1/tenants/ten_1/applications/app_1", None),
    (lambda c: c.projects.set_default_environment("ten_1", "app_1", {"environmentId": "env_1"}), "PUT", "/v1/tenants/ten_1/applications/app_1/default-environment", {"environmentId": "env_1"}),
    (lambda c: c.environments.list("ten_1", "app_1"), "GET", "/v1/tenants/ten_1/applications/app_1/environments", None),
    (lambda c: c.environments.create("ten_1", "app_1", {"name": "prod"}), "POST", "/v1/tenants/ten_1/applications/app_1/environments", {"name": "prod"}),
    (lambda c: c.environments.update("ten_1", "env_1", {"name": "prod"}), "PATCH", "/v1/tenants/ten_1/environments/env_1", {"name": "prod"}),
    (lambda c: c.environments.delete("ten_1", "env_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1", None),
    (lambda c: c.users.list("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/users", None),
    (lambda c: c.users.create("ten_1", "env_1", {"email": "a@b.c", "password": "x"}), "POST", "/v1/tenants/ten_1/environments/env_1/users", {"email": "a@b.c", "password": "x"}),
    (lambda c: c.users.search("ten_1", "env_1", q="ada"), "GET", "/v1/tenants/ten_1/environments/env_1/users/search", None),
    (lambda c: c.users.count("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/users/count", None),
    (lambda c: c.users.get("ten_1", "env_1", "usr_1"), "GET", "/v1/tenants/ten_1/environments/env_1/users/usr_1", None),
    (lambda c: c.users.update("ten_1", "env_1", "usr_1", {"displayName": "Ada"}), "PUT", "/v1/tenants/ten_1/environments/env_1/users/usr_1", {"displayName": "Ada"}),
    (lambda c: c.users.delete("ten_1", "env_1", "usr_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/users/usr_1", None),
    (lambda c: c.users.set_active("ten_1", "env_1", "usr_1", {"active": False}), "PATCH", "/v1/tenants/ten_1/environments/env_1/users/usr_1/active", {"active": False}),
    (lambda c: c.users.list_groups("ten_1", "env_1", "usr_1"), "GET", "/v1/tenants/ten_1/environments/env_1/users/usr_1/groups", None),
    (lambda c: c.groups.create({"environmentId": "env_1", "name": "Admins"}), "POST", "/v1/groups", {"environmentId": "env_1", "name": "Admins"}),
    (lambda c: c.groups.list("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/groups", None),
    (lambda c: c.groups.delete("ten_1", "env_1", "grp_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/groups/grp_1", None),
    (lambda c: c.groups.list_members("ten_1", "env_1", "grp_1"), "GET", "/v1/tenants/ten_1/environments/env_1/groups/grp_1/members", None),
    (lambda c: c.groups.add_member("ten_1", "env_1", "grp_1", {"userId": "usr_1"}), "POST", "/v1/tenants/ten_1/environments/env_1/groups/grp_1/members", {"userId": "usr_1"}),
    (lambda c: c.groups.remove_member("ten_1", "env_1", "grp_1", "usr_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/groups/grp_1/members/usr_1", None),
]


@pytest.mark.parametrize("call,method,path,body", ORG_TENANT_CASES + DIRECTORY_CASES)
@patch("httpx.Client")
def test_wave1_method_and_path(mock_client_class, call, method, path, body):
    client, mock_http = _client_with_request(mock_client_class, _json_response({}))
    call(client)
    args, kwargs = mock_http.request.call_args
    assert args[0] == method
    assert args[1] == path
    assert kwargs.get("json") == body


@patch("httpx.Client")
def test_users_list_parses_empty_and_item(mock_client_class):
    client, _ = _client_with_request(
        mock_client_class,
        _json_response(
            {
                "users": [
                    {
                        "id": "usr_1",
                        "displayName": "Ada",
                        "emails": [{"value": "ada@example.com"}],
                    }
                ]
            }
        ),
    )
    listed = client.users.list("ten_1", "env_1")
    assert listed.users[0].id == "usr_1"
    assert listed.users[0].display_name == "Ada"
    assert listed.users[0].emails[0].value == "ada@example.com"

    client2, _ = _client_with_request(
        mock_client_class, _json_response({"users": []})
    )
    assert client2.users.list("ten_1", "env_1").users == []
