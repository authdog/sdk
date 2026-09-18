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


WAVE2_CASES = [
    (lambda c: c.organizations.list_keys("org_1"), "GET", "/v1/organizations/org_1/keys", None),
    (lambda c: c.organizations.create_key("org_1", {"name": "ci"}), "POST", "/v1/organizations/org_1/keys", {"name": "ci"}),
    (lambda c: c.organizations.revoke_key("org_1", "key_1"), "POST", "/v1/organizations/org_1/keys/key_1/revoke", None),
    (lambda c: c.organizations.rotate_key("org_1", "key_1"), "POST", "/v1/organizations/org_1/keys/key_1/rotate", None),
    (lambda c: c.organizations.update_key_tenants("org_1", "key_1", {"tenantIds": ["ten_1"]}), "PUT", "/v1/organizations/org_1/keys/key_1/tenants", {"tenantIds": ["ten_1"]}),
    (lambda c: c.organizations.list_audit_logs("org_1"), "GET", "/v1/organizations/org_1/audit/logs", None),
    (lambda c: c.service_accounts.list(), "GET", "/v1/service-accounts", None),
    (lambda c: c.service_accounts.create({"name": "bot"}), "POST", "/v1/service-accounts", {"name": "bot"}),
    (lambda c: c.service_accounts.get("sa_1"), "GET", "/v1/service-accounts/sa_1", None),
    (lambda c: c.service_accounts.delete("sa_1"), "DELETE", "/v1/service-accounts/sa_1", None),
    (lambda c: c.personal_access_tokens.list(), "GET", "/v1/personal-access-tokens", None),
    (lambda c: c.personal_access_tokens.create({"name": "cli"}), "POST", "/v1/personal-access-tokens", {"name": "cli"}),
    (lambda c: c.personal_access_tokens.revoke("pat_1"), "POST", "/v1/personal-access-tokens/pat_1/revoke", None),
    (lambda c: c.api_secrets.list("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/api-secrets", None),
    (lambda c: c.api_secrets.create("ten_1", "env_1", {"name": "runtime"}), "POST", "/v1/tenants/ten_1/environments/env_1/api-secrets", {"name": "runtime"}),
    (lambda c: c.api_secrets.revoke("ten_1", "env_1", "sec_1"), "POST", "/v1/tenants/ten_1/environments/env_1/api-secrets/sec_1/revoke", None),
    (lambda c: c.audit.list_logs("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/audit/logs", None),
    (lambda c: c.audit.event_metadata("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/audit/event-metadata", None),
    (lambda c: c.audit.event_types("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/audit/event-types", None),
    (lambda c: c.audit.event_types_catalog("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/audit/event-types/catalog", None),
    (lambda c: c.events.list("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/events", None),
    (lambda c: c.events.list_types("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/events/types", None),
    (lambda c: c.events.ingest("ten_1", "env_1", {"events": []}), "POST", "/v1/tenants/ten_1/environments/env_1/events/ingest", {"events": []}),
    (lambda c: c.webhooks.list("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/webhooks", None),
    (lambda c: c.webhooks.create("ten_1", "env_1", {"url": "https://ex"}), "POST", "/v1/tenants/ten_1/environments/env_1/webhooks", {"url": "https://ex"}),
    (lambda c: c.webhooks.update("ten_1", "env_1", "ch_1", {"url": "https://ex"}), "PUT", "/v1/tenants/ten_1/environments/env_1/webhooks/ch_1", {"url": "https://ex"}),
    (lambda c: c.webhooks.delete("ten_1", "env_1", "ch_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/webhooks/ch_1", None),
    (lambda c: c.webhooks.rotate_secret("ten_1", "env_1", "ch_1"), "POST", "/v1/tenants/ten_1/environments/env_1/webhooks/ch_1/rotate-secret", None),
    (lambda c: c.webhooks.list_deliveries("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/webhooks/deliveries", None),
    (lambda c: c.webhooks.redeliver("ten_1", "env_1", "del_1"), "POST", "/v1/tenants/ten_1/environments/env_1/webhooks/deliveries/del_1/redeliver", None),
    (lambda c: c.notification_channels.list("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/notification-channels", None),
    (lambda c: c.notification_channels.create("ten_1", "env_1", {"type": "webhook"}), "POST", "/v1/tenants/ten_1/environments/env_1/notification-channels", {"type": "webhook"}),
    (lambda c: c.notification_channels.update("ten_1", "env_1", "ch_1", {"name": "n"}), "PUT", "/v1/tenants/ten_1/environments/env_1/notification-channels/ch_1", {"name": "n"}),
    (lambda c: c.notification_channels.delete("ten_1", "env_1", "ch_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/notification-channels/ch_1", None),
    (lambda c: c.notification_channels.test("ten_1", "env_1", "ch_1"), "POST", "/v1/tenants/ten_1/environments/env_1/notification-channels/ch_1/test", None),
    (lambda c: c.rbac.list_roles("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/roles", None),
    (lambda c: c.rbac.create_role("ten_1", "env_1", {"name": "admin"}), "POST", "/v1/tenants/ten_1/environments/env_1/roles", {"name": "admin"}),
    (lambda c: c.rbac.delete_role("ten_1", "env_1", "role_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/roles/role_1", None),
    (lambda c: c.rbac.list_role_permissions("ten_1", "env_1", "role_1"), "GET", "/v1/tenants/ten_1/environments/env_1/roles/role_1/permissions", None),
    (lambda c: c.rbac.set_role_permissions("ten_1", "env_1", "role_1", {"permissionIds": []}), "PUT", "/v1/tenants/ten_1/environments/env_1/roles/role_1/permissions", {"permissionIds": []}),
    (lambda c: c.rbac.list_permissions("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/permissions", None),
    (lambda c: c.rbac.create_permission("ten_1", "env_1", {"name": "read"}), "POST", "/v1/tenants/ten_1/environments/env_1/permissions", {"name": "read"}),
    (lambda c: c.rbac.delete_permission("ten_1", "env_1", "perm_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/permissions/perm_1", None),
    (lambda c: c.rbac.list_resources("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/resources", None),
    (lambda c: c.rbac.create_resource("ten_1", "env_1", {"name": "doc"}), "POST", "/v1/tenants/ten_1/environments/env_1/resources", {"name": "doc"}),
    (lambda c: c.rbac.delete_resource("ten_1", "env_1", "res_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/resources/res_1", None),
    (lambda c: c.rbac.list_group_roles("ten_1", "env_1", "grp_1"), "GET", "/v1/tenants/ten_1/environments/env_1/groups/grp_1/roles", None),
    (lambda c: c.rbac.add_group_role("ten_1", "env_1", "grp_1", {"roleId": "role_1"}), "POST", "/v1/tenants/ten_1/environments/env_1/groups/grp_1/roles", {"roleId": "role_1"}),
    (lambda c: c.rbac.remove_group_role("ten_1", "env_1", "grp_1", "role_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/groups/grp_1/roles/role_1", None),
    (lambda c: c.rbac.list_group_role_mappings("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/group-role-mappings", None),
    (lambda c: c.rbac.create_group_role_mapping("ten_1", "env_1", {"groupId": "grp_1"}), "POST", "/v1/tenants/ten_1/environments/env_1/group-role-mappings", {"groupId": "grp_1"}),
    (lambda c: c.rbac.apply_group_role_mappings("ten_1", "env_1"), "POST", "/v1/tenants/ten_1/environments/env_1/group-role-mappings/apply", None),
    (lambda c: c.rbac.delete_group_role_mapping("ten_1", "env_1", "map_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/group-role-mappings/map_1", None),
    (lambda c: c.rbac.list_abac_policies("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/abac-policies", None),
    (lambda c: c.rbac.save_abac_policy("ten_1", "env_1", {"name": "p"}), "POST", "/v1/tenants/ten_1/environments/env_1/abac-policies", {"name": "p"}),
    (lambda c: c.rbac.validate_abac_policy("ten_1", "env_1", {"rego": "x"}), "POST", "/v1/tenants/ten_1/environments/env_1/abac-policies/validate", {"rego": "x"}),
    (lambda c: c.rbac.delete_abac_policy("ten_1", "env_1", "pol_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/abac-policies/pol_1", None),
    (lambda c: c.rbac.my_permissions("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/me/permissions", None),
]


@pytest.mark.parametrize("call,method,path,body", WAVE2_CASES)
@patch("httpx.Client")
def test_wave2_method_and_path(mock_client_class, call, method, path, body):
    client, mock_http = _client_with_request(mock_client_class, _json_response({}))
    call(client)
    args, kwargs = mock_http.request.call_args
    assert args[0] == method
    assert args[1] == path
    assert kwargs.get("json") == body


@patch("httpx.Client")
def test_wave2_create_key_exposes_one_time_secret(mock_client_class):
    client, _ = _client_with_request(
        mock_client_class,
        _json_response({"token": "orgk_secret_once", "key": {"id": "key_1"}}),
    )
    created = client.organizations.create_key("org_1", {"name": "ci"})
    assert created.get("token") == "orgk_secret_once"


@patch("httpx.Client")
def test_wave2_audit_forwards_query_params(mock_client_class):
    client, mock_http = _client_with_request(mock_client_class, _json_response({}))
    client.events.list("ten_1", "env_1", params={"limit": 50, "after": "cur_1"})
    args, kwargs = mock_http.request.call_args
    assert args[1] == "/v1/tenants/ten_1/environments/env_1/events"
    assert kwargs.get("params") == {"limit": 50, "after": "cur_1"}


WAVE3_CASES = [
    (lambda c: c.authzen.configuration(), "GET", "/.well-known/authzen-configuration", None),
    (lambda c: c.authzen.evaluate({"subject": {}}), "POST", "/access/v1/evaluation", {"subject": {}}),
    (lambda c: c.authzen.evaluate_batch({"evaluations": []}), "POST", "/access/v1/evaluations", {"evaluations": []}),
    (lambda c: c.authzen.search_action({"subject": {}}), "POST", "/access/v1/search/action", {"subject": {}}),
    (lambda c: c.authzen.search_resource({"subject": {}}), "POST", "/access/v1/search/resource", {"subject": {}}),
    (lambda c: c.authzen.search_subject({"resource": {}}), "POST", "/access/v1/search/subject", {"resource": {}}),
    (lambda c: c.users.revoke_session("env_1", "sess_1"), "DELETE", "/v1/environments/env_1/sessions/sess_1", None),
    (lambda c: c.hris.list_departments(), "GET", "/v1/hris/v1/Departments", None),
    (lambda c: c.hris.create_department({"name": "Eng"}), "POST", "/v1/hris/v1/Departments", {"name": "Eng"}),
    (lambda c: c.hris.get_department("dep_1"), "GET", "/v1/hris/v1/Departments/dep_1", None),
    (lambda c: c.hris.replace_department("dep_1", {"name": "Eng"}), "PUT", "/v1/hris/v1/Departments/dep_1", {"name": "Eng"}),
    (lambda c: c.hris.patch_department("dep_1", {"name": "E"}), "PATCH", "/v1/hris/v1/Departments/dep_1", {"name": "E"}),
    (lambda c: c.hris.delete_department("dep_1"), "DELETE", "/v1/hris/v1/Departments/dep_1", None),
    (lambda c: c.hris.list_employees(), "GET", "/v1/hris/v1/Employees", None),
    (lambda c: c.hris.create_employee({"name": "Ada"}), "POST", "/v1/hris/v1/Employees", {"name": "Ada"}),
    (lambda c: c.hris.get_employee("emp_1"), "GET", "/v1/hris/v1/Employees/emp_1", None),
    (lambda c: c.hris.replace_employee("emp_1", {"name": "Ada"}), "PUT", "/v1/hris/v1/Employees/emp_1", {"name": "Ada"}),
    (lambda c: c.hris.patch_employee("emp_1", {"name": "A"}), "PATCH", "/v1/hris/v1/Employees/emp_1", {"name": "A"}),
    (lambda c: c.hris.delete_employee("emp_1"), "DELETE", "/v1/hris/v1/Employees/emp_1", None),
    (lambda c: c.hris.service_config(), "GET", "/v1/hris/v1/ServiceConfig", None),
    (lambda c: c.otel.export_logs({"resourceLogs": []}), "POST", "/v1/logs", {"resourceLogs": []}),
    (lambda c: c.mcp.ingest_events({"events": []}), "POST", "/v1/mcp/events", {"events": []}),
    (lambda c: c.mcp.resolve("agent-1"), "GET", "/v1/mcp/trust-store/resolve", None),
    (lambda c: c.otel.export_metrics({"resourceMetrics": []}), "POST", "/v1/metrics", {"resourceMetrics": []}),
    (lambda c: c.otel.export_logs_prefixed({"resourceLogs": []}), "POST", "/v1/otel/v1/logs", {"resourceLogs": []}),
    (lambda c: c.otel.export_metrics_prefixed({"resourceMetrics": []}), "POST", "/v1/otel/v1/metrics", {"resourceMetrics": []}),
    (lambda c: c.otel.export_traces_prefixed({"resourceSpans": []}), "POST", "/v1/otel/v1/traces", {"resourceSpans": []}),
    (lambda c: c.scim.list_groups(), "GET", "/v1/scim/v2/Groups", None),
    (lambda c: c.scim.create_group({"displayName": "G"}), "POST", "/v1/scim/v2/Groups", {"displayName": "G"}),
    (lambda c: c.scim.get_group("g_1"), "GET", "/v1/scim/v2/Groups/g_1", None),
    (lambda c: c.scim.replace_group("g_1", {"displayName": "G"}), "PUT", "/v1/scim/v2/Groups/g_1", {"displayName": "G"}),
    (lambda c: c.scim.patch_group("g_1", {"Operations": []}), "PATCH", "/v1/scim/v2/Groups/g_1", {"Operations": []}),
    (lambda c: c.scim.delete_group("g_1"), "DELETE", "/v1/scim/v2/Groups/g_1", None),
    (lambda c: c.scim.resource_types(), "GET", "/v1/scim/v2/ResourceTypes", None),
    (lambda c: c.scim.resource_type("User"), "GET", "/v1/scim/v2/ResourceTypes/User", None),
    (lambda c: c.scim.schemas(), "GET", "/v1/scim/v2/Schemas", None),
    (lambda c: c.scim.schema("urn:ietf:params:scim:schemas:core:2.0:User"), "GET", "/v1/scim/v2/Schemas/urn:ietf:params:scim:schemas:core:2.0:User", None),
    (lambda c: c.scim.service_provider_config(), "GET", "/v1/scim/v2/ServiceProviderConfig", None),
    (lambda c: c.scim.list_users(), "GET", "/v1/scim/v2/Users", None),
    (lambda c: c.scim.create_user({"userName": "ada"}), "POST", "/v1/scim/v2/Users", {"userName": "ada"}),
    (lambda c: c.scim.get_user("u_1"), "GET", "/v1/scim/v2/Users/u_1", None),
    (lambda c: c.scim.replace_user("u_1", {"userName": "ada"}), "PUT", "/v1/scim/v2/Users/u_1", {"userName": "ada"}),
    (lambda c: c.scim.patch_user("u_1", {"Operations": []}), "PATCH", "/v1/scim/v2/Users/u_1", {"Operations": []}),
    (lambda c: c.scim.delete_user("u_1"), "DELETE", "/v1/scim/v2/Users/u_1", None),
    (lambda c: c.environments.list_connections("ten_1", "app_1", "env_1"), "GET", "/v1/tenants/ten_1/applications/app_1/environments/env_1/connections", None),
    (lambda c: c.oidc_clients.list("ten_1", "app_1", "env_1"), "GET", "/v1/tenants/ten_1/applications/app_1/environments/env_1/oidc-clients", None),
    (lambda c: c.oidc_clients.register("ten_1", "app_1", "env_1", {"name": "cli"}), "POST", "/v1/tenants/ten_1/applications/app_1/environments/env_1/oidc-clients", {"name": "cli"}),
    (lambda c: c.oidc_clients.update("ten_1", "app_1", "env_1", "cid_1", {"name": "n"}), "PATCH", "/v1/tenants/ten_1/applications/app_1/environments/env_1/oidc-clients/cid_1", {"name": "n"}),
    (lambda c: c.oidc_clients.delete("ten_1", "app_1", "env_1", "cid_1"), "DELETE", "/v1/tenants/ten_1/applications/app_1/environments/env_1/oidc-clients/cid_1", None),
    (lambda c: c.environments.list_redirect_uris("ten_1", "app_1", "env_1"), "GET", "/v1/tenants/ten_1/applications/app_1/environments/env_1/redirect-uris", None),
    (lambda c: c.actions.list("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/actions", None),
    (lambda c: c.actions.save("ten_1", "env_1", {"url": "https://ex"}), "POST", "/v1/tenants/ten_1/environments/env_1/actions", {"url": "https://ex"}),
    (lambda c: c.actions.executions("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/actions/executions", None),
    (lambda c: c.actions.test("ten_1", "env_1", {"url": "https://ex"}), "POST", "/v1/tenants/ten_1/environments/env_1/actions/test", {"url": "https://ex"}),
    (lambda c: c.actions.delete("ten_1", "env_1", "act_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/actions/act_1", None),
    (lambda c: c.addons.list("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/addons", None),
    (lambda c: c.addons.save("ten_1", "env_1", {"provider": "slack"}), "POST", "/v1/tenants/ten_1/environments/env_1/addons", {"provider": "slack"}),
    (lambda c: c.addons.delete("ten_1", "env_1", "slack"), "DELETE", "/v1/tenants/ten_1/environments/env_1/addons/slack", None),
    (lambda c: c.billing.list_features("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/billing/features", None),
    (lambda c: c.billing.save_feature("ten_1", "env_1", {"name": "pro"}), "POST", "/v1/tenants/ten_1/environments/env_1/billing/features", {"name": "pro"}),
    (lambda c: c.billing.delete_feature("ten_1", "env_1", "feat_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/billing/features/feat_1", None),
    (lambda c: c.billing.list_plans("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/billing/plans", None),
    (lambda c: c.billing.save_plan("ten_1", "env_1", {"name": "pro"}), "POST", "/v1/tenants/ten_1/environments/env_1/billing/plans", {"name": "pro"}),
    (lambda c: c.billing.delete_plan("ten_1", "env_1", "plan_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/billing/plans/plan_1", None),
    (lambda c: c.billing.sync_stripe("ten_1", "env_1", "plan_1"), "POST", "/v1/tenants/ten_1/environments/env_1/billing/plans/plan_1/sync-stripe", None),
    (lambda c: c.settings.get_bot_detection_policy("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/bot-detection-policy", None),
    (lambda c: c.settings.update_bot_detection_policy("ten_1", "env_1", {"enabled": True}), "PUT", "/v1/tenants/ten_1/environments/env_1/bot-detection-policy", {"enabled": True}),
    (lambda c: c.settings.get_breached_password_policy("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/breached-password-policy", None),
    (lambda c: c.settings.update_breached_password_policy("ten_1", "env_1", {"enabled": True}), "PUT", "/v1/tenants/ten_1/environments/env_1/breached-password-policy", {"enabled": True}),
    (lambda c: c.settings.get_brute_force_policy("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/brute-force-policy", None),
    (lambda c: c.settings.update_brute_force_policy("ten_1", "env_1", {"enabled": True}), "PUT", "/v1/tenants/ten_1/environments/env_1/brute-force-policy", {"enabled": True}),
    (lambda c: c.environments.save_connection("ten_1", "env_1", {"provider": "okta"}), "POST", "/v1/tenants/ten_1/environments/env_1/connections", {"provider": "okta"}),
    (lambda c: c.environments.resolve_saml_metadata("ten_1", "env_1", {"url": "https://ex"}), "POST", "/v1/tenants/ten_1/environments/env_1/connections/resolve-saml-metadata", {"url": "https://ex"}),
    (lambda c: c.environments.get_sso_metadata("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/connections/sso-metadata", None),
    (lambda c: c.environments.delete_connection("ten_1", "env_1", "con_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/connections/con_1", None),
    (lambda c: c.settings.get_device_risk_policy("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/device-risk-policy", None),
    (lambda c: c.settings.update_device_risk_policy("ten_1", "env_1", {"enabled": True}), "PUT", "/v1/tenants/ten_1/environments/env_1/device-risk-policy", {"enabled": True}),
    (lambda c: c.elevate.activate_grant("ten_1", "env_1", "gr_1", {"reason": "x"}), "POST", "/v1/tenants/ten_1/environments/env_1/elevate/access-grants/gr_1/activate", {"reason": "x"}),
    (lambda c: c.elevate.revoke_grant("ten_1", "env_1", "gr_1", {"reason": "x"}), "POST", "/v1/tenants/ten_1/environments/env_1/elevate/access-grants/gr_1/revoke", {"reason": "x"}),
    (lambda c: c.elevate.list_requests("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/elevate/access-requests", None),
    (lambda c: c.elevate.create_request("ten_1", "env_1", {"reason": "x"}), "POST", "/v1/tenants/ten_1/environments/env_1/elevate/access-requests", {"reason": "x"}),
    (lambda c: c.elevate.get_request("ten_1", "env_1", "req_1"), "GET", "/v1/tenants/ten_1/environments/env_1/elevate/access-requests/req_1", None),
    (lambda c: c.elevate.approve_request("ten_1", "env_1", "req_1", {"note": "ok"}), "POST", "/v1/tenants/ten_1/environments/env_1/elevate/access-requests/req_1/approve", {"note": "ok"}),
    (lambda c: c.elevate.cancel_request("ten_1", "env_1", "req_1"), "POST", "/v1/tenants/ten_1/environments/env_1/elevate/access-requests/req_1/cancel", None),
    (lambda c: c.elevate.deny_request("ten_1", "env_1", "req_1", {"note": "no"}), "POST", "/v1/tenants/ten_1/environments/env_1/elevate/access-requests/req_1/deny", {"note": "no"}),
    (lambda c: c.elevate.get_policy("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/elevate/policy", None),
    (lambda c: c.elevate.update_policy("ten_1", "env_1", {"enabled": True}), "PUT", "/v1/tenants/ten_1/environments/env_1/elevate/policy", {"enabled": True}),
    (lambda c: c.email_providers.list("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/email-providers", None),
    (lambda c: c.email_providers.save("ten_1", "env_1", {"provider": "ses"}), "POST", "/v1/tenants/ten_1/environments/env_1/email-providers", {"provider": "ses"}),
    (lambda c: c.email_providers.test("ten_1", "env_1", {"to": "a@b.c"}), "POST", "/v1/tenants/ten_1/environments/env_1/email-providers/test", {"to": "a@b.c"}),
    (lambda c: c.email_providers.delete("ten_1", "env_1", "ses"), "DELETE", "/v1/tenants/ten_1/environments/env_1/email-providers/ses", None),
    (lambda c: c.email_providers.activate("ten_1", "env_1", "ses"), "POST", "/v1/tenants/ten_1/environments/env_1/email-providers/ses/activate", None),
    (lambda c: c.feature_flags.list("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/feature-flags", None),
    (lambda c: c.feature_flags.save("ten_1", "env_1", {"key": "x"}), "POST", "/v1/tenants/ten_1/environments/env_1/feature-flags", {"key": "x"}),
    (lambda c: c.feature_flags.delete("ten_1", "env_1", "flag_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/feature-flags/flag_1", None),
    (lambda c: c.forms.list_attachments("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/form-attachments", None),
    (lambda c: c.forms.list("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/forms", None),
    (lambda c: c.forms.save("ten_1", "env_1", {"name": "login"}), "POST", "/v1/tenants/ten_1/environments/env_1/forms", {"name": "login"}),
    (lambda c: c.forms.delete("ten_1", "env_1", "form_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/forms/form_1", None),
    (lambda c: c.provisioning_tokens.list_hris("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/hris-tokens", None),
    (lambda c: c.provisioning_tokens.create_hris("ten_1", "env_1", {"name": "hr"}), "POST", "/v1/tenants/ten_1/environments/env_1/hris-tokens", {"name": "hr"}),
    (lambda c: c.provisioning_tokens.revoke_hris("ten_1", "env_1", "tok_1"), "POST", "/v1/tenants/ten_1/environments/env_1/hris-tokens/tok_1/revoke", None),
    (lambda c: c.provisioning_tokens.rotate_hris("ten_1", "env_1", "tok_1"), "POST", "/v1/tenants/ten_1/environments/env_1/hris-tokens/tok_1/rotate", None),
    (lambda c: c.impersonation.list("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/impersonation-grants", None),
    (lambda c: c.impersonation.create("ten_1", "env_1", {"userId": "usr_1"}), "POST", "/v1/tenants/ten_1/environments/env_1/impersonation-grants", {"userId": "usr_1"}),
    (lambda c: c.impersonation.revoke("ten_1", "env_1", "gr_1"), "POST", "/v1/tenants/ten_1/environments/env_1/impersonation-grants/gr_1/revoke", None),
    (lambda c: c.settings.list_jwt_claim_mappings("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/jwt-claim-mappings", None),
    (lambda c: c.settings.save_jwt_claim_mapping("ten_1", "env_1", {"claim": "role"}), "POST", "/v1/tenants/ten_1/environments/env_1/jwt-claim-mappings", {"claim": "role"}),
    (lambda c: c.settings.delete_jwt_claim_mapping("ten_1", "env_1", "map_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/jwt-claim-mappings/map_1", None),
    (lambda c: c.mcp.list_entries("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/mcp/trust-store", None),
    (lambda c: c.mcp.create_entry("ten_1", "env_1", {"subject": "a"}), "POST", "/v1/tenants/ten_1/environments/env_1/mcp/trust-store", {"subject": "a"}),
    (lambda c: c.mcp.get_entry("ten_1", "env_1", "ent_1"), "GET", "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1", None),
    (lambda c: c.mcp.update_entry("ten_1", "env_1", "ent_1", {"name": "n"}), "PATCH", "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1", {"name": "n"}),
    (lambda c: c.mcp.delete_entry("ten_1", "env_1", "ent_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1", None),
    (lambda c: c.mcp.add_key("ten_1", "env_1", "ent_1", {"jwk": {}}), "POST", "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/keys", {"jwk": {}}),
    (lambda c: c.mcp.revoke_key("ten_1", "env_1", "ent_1", "key_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/keys/key_1", None),
    (lambda c: c.mcp.rotate_key("ten_1", "env_1", "ent_1", "key_1"), "POST", "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/keys/key_1/rotate", None),
    (lambda c: c.mcp.revoke_entry("ten_1", "env_1", "ent_1"), "POST", "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/revoke", None),
    (lambda c: c.mcp.verify_entry("ten_1", "env_1", "ent_1", {"verified": True}), "POST", "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/verify", {"verified": True}),
    (lambda c: c.users.totp_status("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/me/mfa/totp", None),
    (lambda c: c.settings.get_password_policy("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/password-policy", None),
    (lambda c: c.settings.update_password_policy("ten_1", "env_1", {"minLength": 8}), "PUT", "/v1/tenants/ten_1/environments/env_1/password-policy", {"minLength": 8}),
    (lambda c: c.portal.generate_link("ten_1", "env_1", {"email": "a@b.c"}), "POST", "/v1/tenants/ten_1/environments/env_1/portal/generate-link", {"email": "a@b.c"}),
    (lambda c: c.settings.get_rate_limit_policy("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/rate-limit-policy", None),
    (lambda c: c.settings.update_rate_limit_policy("ten_1", "env_1", {"limit": 10}), "PUT", "/v1/tenants/ten_1/environments/env_1/rate-limit-policy", {"limit": 10}),
    (lambda c: c.environments.save_redirect_uris("ten_1", "env_1", {"uris": []}), "PUT", "/v1/tenants/ten_1/environments/env_1/redirect-uris", {"uris": []}),
    (lambda c: c.settings.get_restrictions("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/restrictions", None),
    (lambda c: c.settings.update_restrictions("ten_1", "env_1", {"signup": False}), "PUT", "/v1/tenants/ten_1/environments/env_1/restrictions", {"signup": False}),
    (lambda c: c.provisioning_tokens.list_scim("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/scim-tokens", None),
    (lambda c: c.provisioning_tokens.create_scim("ten_1", "env_1", {"name": "scim"}), "POST", "/v1/tenants/ten_1/environments/env_1/scim-tokens", {"name": "scim"}),
    (lambda c: c.provisioning_tokens.revoke_scim("ten_1", "env_1", "tok_1"), "POST", "/v1/tenants/ten_1/environments/env_1/scim-tokens/tok_1/revoke", None),
    (lambda c: c.provisioning_tokens.rotate_scim("ten_1", "env_1", "tok_1"), "POST", "/v1/tenants/ten_1/environments/env_1/scim-tokens/tok_1/rotate", None),
    (lambda c: c.security.posture("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/security/posture", None),
    (lambda c: c.settings.get_session_config("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/session-config", None),
    (lambda c: c.settings.update_session_config("ten_1", "env_1", {"ttl": 3600}), "PUT", "/v1/tenants/ten_1/environments/env_1/session-config", {"ttl": 3600}),
    (lambda c: c.threats.list("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/threats", None),
    (lambda c: c.threats.create("ten_1", "env_1", {"type": "bot"}), "POST", "/v1/tenants/ten_1/environments/env_1/threats", {"type": "bot"}),
    (lambda c: c.threats.get("ten_1", "env_1", "th_1"), "GET", "/v1/tenants/ten_1/environments/env_1/threats/th_1", None),
    (lambda c: c.threats.update("ten_1", "env_1", "th_1", {"status": "open"}), "PATCH", "/v1/tenants/ten_1/environments/env_1/threats/th_1", {"status": "open"}),
    (lambda c: c.threats.delete("ten_1", "env_1", "th_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/threats/th_1", None),
    (lambda c: c.threats.resolve("ten_1", "env_1", "th_1", {"status": "resolved"}), "POST", "/v1/tenants/ten_1/environments/env_1/threats/th_1/resolve", {"status": "resolved"}),
    (lambda c: c.users.bulk_delete("ten_1", "env_1", {"userIds": ["usr_1"]}), "POST", "/v1/tenants/ten_1/environments/env_1/users/bulk/delete", {"userIds": ["usr_1"]}),
    (lambda c: c.users.bulk_set_active("ten_1", "env_1", {"userIds": ["usr_1"], "active": False}), "POST", "/v1/tenants/ten_1/environments/env_1/users/bulk/set-active", {"userIds": ["usr_1"], "active": False}),
    (lambda c: c.users.import_users("ten_1", "env_1", {"users": []}), "POST", "/v1/tenants/ten_1/environments/env_1/users/import", {"users": []}),
    (lambda c: c.users.disable_mfa("ten_1", "env_1", "usr_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/users/usr_1/mfa", None),
    (lambda c: c.users.list_sessions("ten_1", "env_1", "usr_1"), "GET", "/v1/tenants/ten_1/environments/env_1/users/usr_1/sessions", None),
    (lambda c: c.vanity_domains.list("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/vanity-domains", None),
    (lambda c: c.vanity_domains.create("ten_1", "env_1", {"domain": "a.com"}), "POST", "/v1/tenants/ten_1/environments/env_1/vanity-domains", {"domain": "a.com"}),
    (lambda c: c.vanity_domains.delete("ten_1", "env_1", "dom_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/vanity-domains/dom_1", None),
    (lambda c: c.vanity_domains.check("ten_1", "env_1", "dom_1"), "POST", "/v1/tenants/ten_1/environments/env_1/vanity-domains/dom_1/check", None),
    (lambda c: c.widgets.create_token("ten_1", "env_1", {"ttl": 60}), "POST", "/v1/tenants/ten_1/environments/env_1/widgets/token", {"ttl": 60}),
    (lambda c: c.otel.export_traces({"resourceSpans": []}), "POST", "/v1/traces", {"resourceSpans": []}),
]


def test_wave3_covers_all_inventory_operations():
    assert len(WAVE3_CASES) == 152


@pytest.mark.parametrize("call,method,path,body", WAVE3_CASES)
@patch("httpx.Client")
def test_wave3_method_and_path(mock_client_class, call, method, path, body):
    client, mock_http = _client_with_request(mock_client_class, _json_response({}))
    call(client)
    args, kwargs = mock_http.request.call_args
    assert args[0] == method
    assert args[1] == path
    assert kwargs.get("json") == body


@patch("httpx.Client")
def test_wave3_authzen_discovery_omits_bearer(mock_client_class):
    client, mock_http = _client_with_request(mock_client_class, _json_response({}))
    client.authzen.configuration()
    args, kwargs = mock_http.request.call_args
    assert args[1] == "/.well-known/authzen-configuration"
    assert kwargs.get("headers", {}).get("Authorization") == ""


@patch("httpx.Client")
def test_wave3_authzen_evaluate_uses_environment_secret(mock_client_class):
    mock_http = Mock()
    mock_http.request.return_value = _json_response({"decision": "Permit"})
    mock_client_class.return_value = mock_http
    client = AuthdogClient(
        "https://api.authdog.com",
        "key-1",
        environment_secret="adenv_secret",
    )
    result = client.authzen.evaluate({"subject": {"id": "u"}})
    assert result.get("decision") == "Permit"
    args, kwargs = mock_http.request.call_args
    assert args[1] == "/access/v1/evaluation"
    assert kwargs.get("headers", {}).get("Authorization") == "Bearer adenv_secret"


@patch("httpx.Client")
def test_wave3_scim_and_hris_use_specialized_tokens(mock_client_class):
    mock_http = Mock()
    mock_http.request.return_value = _json_response({})
    mock_client_class.return_value = mock_http
    client = AuthdogClient(
        "https://api.authdog.com",
        "key-1",
        scim_token="adscim_token",
        hris_token="adhris_token",
    )
    client.scim.list_users()
    assert mock_http.request.call_args.kwargs["headers"]["Authorization"] == "Bearer adscim_token"
    client.hris.list_employees()
    assert mock_http.request.call_args.kwargs["headers"]["Authorization"] == "Bearer adhris_token"


@patch("httpx.Client")
def test_wave3_create_scim_token_exposes_one_time_secret(mock_client_class):
    client, _ = _client_with_request(
        mock_client_class,
        _json_response({"token": "adscim_once", "id": "tok_1"}),
    )
    created = client.provisioning_tokens.create_scim("ten_1", "env_1", {"name": "scim"})
    assert created.get("token") == "adscim_once"


@patch("httpx.Client")
def test_wave3_query_params_forwarded(mock_client_class):
    client, mock_http = _client_with_request(mock_client_class, _json_response({}))
    client.mcp.resolve("agent-1")
    args, kwargs = mock_http.request.call_args
    assert args[1] == "/v1/mcp/trust-store/resolve"
    assert kwargs.get("params") == {"subject": "agent-1"}
    client.threats.list("ten_1", "env_1", params={"status": "open", "limit": 10})
    args, kwargs = mock_http.request.call_args
    assert kwargs.get("params") == {"status": "open", "limit": 10}
    client.elevate.list_requests("ten_1", "env_1", status="pending")
    args, kwargs = mock_http.request.call_args
    assert kwargs.get("params") == {"status": "pending"}
