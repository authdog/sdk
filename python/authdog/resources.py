"""Wave 1–3 management resource namespaces."""

from __future__ import annotations

from typing import Any, Dict, Optional, TYPE_CHECKING

from .types import (
    EnvGroupsResponse,
    EnvUserResponse,
    EnvUsersResponse,
    JsonMap,
    OrganizationResponse,
    OrganizationsList,
    SuccessIdResponse,
    TenantResponse,
    TenantsList,
)

if TYPE_CHECKING:
    from .client import AuthdogClient


def _params(**kwargs: Any) -> Optional[Dict[str, Any]]:
    values = {key: value for key, value in kwargs.items() if value is not None}
    return values or None


class OrganizationsResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list(self) -> OrganizationsList:
        return OrganizationsList.from_dict(self._client.request("GET", "/v1/organizations"))

    def create(self, body: Dict[str, Any]) -> OrganizationResponse:
        return OrganizationResponse.from_dict(
            self._client.request("POST", "/v1/organizations", json=body)
        )

    def get(self, organization_id: str) -> OrganizationResponse:
        return OrganizationResponse.from_dict(
            self._client.request("GET", f"/v1/organizations/{organization_id}")
        )

    def update(self, organization_id: str, body: Dict[str, Any]) -> OrganizationResponse:
        return OrganizationResponse.from_dict(
            self._client.request("PATCH", f"/v1/organizations/{organization_id}", json=body)
        )

    def delete(self, organization_id: str) -> SuccessIdResponse:
        return SuccessIdResponse.from_dict(
            self._client.request("DELETE", f"/v1/organizations/{organization_id}")
        )

    def accept_invitation(self, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("POST", "/v1/organizations/invitations/accept", json=body)
        )

    def join(self, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(self._client.request("POST", "/v1/organizations/join", json=body))

    def list_invitations(self, organization_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"/v1/organizations/{organization_id}/invitations")
        )

    def create_invitation(self, organization_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"/v1/organizations/{organization_id}/invitations", json=body
            )
        )

    def cancel_invitation(self, organization_id: str, invitation_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"/v1/organizations/{organization_id}/invitations/{invitation_id}/cancel",
            )
        )

    def send_invite(self, organization_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"/v1/organizations/{organization_id}/invites", json=body
            )
        )

    def list_members(self, organization_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"/v1/organizations/{organization_id}/members")
        )

    def remove_member(self, organization_id: str, member_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE", f"/v1/organizations/{organization_id}/members/{member_id}"
            )
        )

    def set_member_active(
        self, organization_id: str, member_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PATCH",
                f"/v1/organizations/{organization_id}/members/{member_id}/active",
                json=body,
            )
        )

    def link_tenant(self, organization_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"/v1/organizations/{organization_id}/tenants", json=body
            )
        )

    def unlink_tenant(self, organization_id: str, tenant_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE", f"/v1/organizations/{organization_id}/tenants/{tenant_id}"
            )
        )

    def list_keys(self, organization_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"/v1/organizations/{organization_id}/keys")
        )

    def create_key(self, organization_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"/v1/organizations/{organization_id}/keys", json=body
            )
        )

    def revoke_key(self, organization_id: str, key_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"/v1/organizations/{organization_id}/keys/{key_id}/revoke"
            )
        )

    def rotate_key(self, organization_id: str, key_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"/v1/organizations/{organization_id}/keys/{key_id}/rotate"
            )
        )

    def update_key_tenants(
        self, organization_id: str, key_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PUT",
                f"/v1/organizations/{organization_id}/keys/{key_id}/tenants",
                json=body,
            )
        )

    def list_audit_logs(
        self, organization_id: str, params: Optional[Dict[str, Any]] = None
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET",
                f"/v1/organizations/{organization_id}/audit/logs",
                params=params,
            )
        )


class TenantsResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list(self, organization_id: Optional[str] = None) -> TenantsList:
        return TenantsList.from_dict(
            self._client.request(
                "GET", "/v1/tenants", params=_params(organization_id=organization_id)
            )
        )

    def create(self, body: Dict[str, Any]) -> TenantResponse:
        return TenantResponse.from_dict(self._client.request("POST", "/v1/tenants", json=body))

    def join(self, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(self._client.request("POST", "/v1/tenants/join", json=body))

    def get(self, tenant_id: str, organization_id: Optional[str] = None) -> TenantResponse:
        return TenantResponse.from_dict(
            self._client.request(
                "GET",
                f"/v1/tenants/{tenant_id}",
                params=_params(organization_id=organization_id),
            )
        )

    def update(self, tenant_id: str, body: Dict[str, Any]) -> TenantResponse:
        return TenantResponse.from_dict(
            self._client.request("PATCH", f"/v1/tenants/{tenant_id}", json=body)
        )

    def delete(self, tenant_id: str) -> SuccessIdResponse:
        return SuccessIdResponse.from_dict(
            self._client.request("DELETE", f"/v1/tenants/{tenant_id}")
        )

    def list_domains(self, tenant_id: str) -> JsonMap:
        return JsonMap.from_dict(self._client.request("GET", f"/v1/tenants/{tenant_id}/domains"))

    def create_domain(self, tenant_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("POST", f"/v1/tenants/{tenant_id}/domains", json=body)
        )

    def delete_domain(self, tenant_id: str, domain_id: str) -> SuccessIdResponse:
        return SuccessIdResponse.from_dict(
            self._client.request("DELETE", f"/v1/tenants/{tenant_id}/domains/{domain_id}")
        )

    def retry_domain(self, tenant_id: str, domain_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"/v1/tenants/{tenant_id}/domains/{domain_id}/retry"
            )
        )

    def send_invite(self, tenant_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("POST", f"/v1/tenants/{tenant_id}/invites", json=body)
        )

    def list_projects(self, tenant_id: str) -> JsonMap:
        return JsonMap.from_dict(self._client.request("GET", f"/v1/tenants/{tenant_id}/projects"))

    def list_seats(self, tenant_id: str) -> JsonMap:
        return JsonMap.from_dict(self._client.request("GET", f"/v1/tenants/{tenant_id}/seats"))

    def update_seat(self, tenant_id: str, seat_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PATCH", f"/v1/tenants/{tenant_id}/seats/{seat_id}", json=body
            )
        )

    def delete_seat(self, tenant_id: str, seat_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("DELETE", f"/v1/tenants/{tenant_id}/seats/{seat_id}")
        )


class ProjectsResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def save(self, tenant_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"/v1/tenants/{tenant_id}/applications", json=body
            )
        )

    def get(self, tenant_id: str, application_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", f"/v1/tenants/{tenant_id}/applications/{application_id}"
            )
        )

    def delete(self, tenant_id: str, application_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE", f"/v1/tenants/{tenant_id}/applications/{application_id}"
            )
        )

    def set_default_environment(
        self, tenant_id: str, application_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PUT",
                f"/v1/tenants/{tenant_id}/applications/{application_id}/default-environment",
                json=body,
            )
        )


class EnvironmentsResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list(self, tenant_id: str, application_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET",
                f"/v1/tenants/{tenant_id}/applications/{application_id}/environments",
            )
        )

    def create(self, tenant_id: str, application_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"/v1/tenants/{tenant_id}/applications/{application_id}/environments",
                json=body,
            )
        )

    def update(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PATCH",
                f"/v1/tenants/{tenant_id}/environments/{environment_id}",
                json=body,
            )
        )

    def delete(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE", f"/v1/tenants/{tenant_id}/environments/{environment_id}"
            )
        )

    def list_connections(
        self, tenant_id: str, application_id: str, environment_id: str
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET",
                f"/v1/tenants/{tenant_id}/applications/{application_id}/environments/{environment_id}/connections",
            )
        )

    def list_redirect_uris(
        self, tenant_id: str, application_id: str, environment_id: str
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET",
                f"/v1/tenants/{tenant_id}/applications/{application_id}/environments/{environment_id}/redirect-uris",
            )
        )

    def save_connection(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/connections", json=body
            )
        )

    def resolve_saml_metadata(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/connections/resolve-saml-metadata",
                json=body,
            )
        )

    def get_sso_metadata(
        self,
        tenant_id: str,
        environment_id: str,
        connection_id: Optional[str] = None,
        provider_id: Optional[str] = None,
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET",
                f"{_env(tenant_id, environment_id)}/connections/sso-metadata",
                params=_params(connectionId=connection_id, providerId=provider_id),
            )
        )

    def delete_connection(
        self, tenant_id: str, environment_id: str, connection_id: str
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE",
                f"{_env(tenant_id, environment_id)}/connections/{connection_id}",
            )
        )

    def save_redirect_uris(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PUT", f"{_env(tenant_id, environment_id)}/redirect-uris", json=body
            )
        )


class UsersResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list(
        self,
        tenant_id: str,
        environment_id: str,
        offset: Optional[int] = None,
        limit: Optional[int] = None,
        search_query: Optional[str] = None,
    ) -> EnvUsersResponse:
        return EnvUsersResponse.from_dict(
            self._client.request(
                "GET",
                f"/v1/tenants/{tenant_id}/environments/{environment_id}/users",
                params=_params(offset=offset, limit=limit, searchQuery=search_query),
            )
        )

    def create(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"/v1/tenants/{tenant_id}/environments/{environment_id}/users",
                json=body,
            )
        )

    def search(
        self,
        tenant_id: str,
        environment_id: str,
        q: Optional[str] = None,
        offset: Optional[int] = None,
        limit: Optional[int] = None,
    ) -> EnvUsersResponse:
        return EnvUsersResponse.from_dict(
            self._client.request(
                "GET",
                f"/v1/tenants/{tenant_id}/environments/{environment_id}/users/search",
                params=_params(q=q, offset=offset, limit=limit),
            )
        )

    def count(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET",
                f"/v1/tenants/{tenant_id}/environments/{environment_id}/users/count",
            )
        )

    def get(self, tenant_id: str, environment_id: str, user_id: str) -> EnvUserResponse:
        return EnvUserResponse.from_dict(
            self._client.request(
                "GET",
                f"/v1/tenants/{tenant_id}/environments/{environment_id}/users/{user_id}",
            )
        )

    def update(
        self, tenant_id: str, environment_id: str, user_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PUT",
                f"/v1/tenants/{tenant_id}/environments/{environment_id}/users/{user_id}",
                json=body,
            )
        )

    def delete(self, tenant_id: str, environment_id: str, user_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE",
                f"/v1/tenants/{tenant_id}/environments/{environment_id}/users/{user_id}",
            )
        )

    def set_active(
        self, tenant_id: str, environment_id: str, user_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PATCH",
                f"/v1/tenants/{tenant_id}/environments/{environment_id}/users/{user_id}/active",
                json=body,
            )
        )

    def list_groups(self, tenant_id: str, environment_id: str, user_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET",
                f"/v1/tenants/{tenant_id}/environments/{environment_id}/users/{user_id}/groups",
            )
        )

    def revoke_session(self, environment_id: str, session_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE", f"/v1/environments/{environment_id}/sessions/{session_id}"
            )
        )

    def totp_status(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/me/mfa/totp")
        )

    def bulk_delete(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/users/bulk/delete", json=body
            )
        )

    def bulk_set_active(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/users/bulk/set-active",
                json=body,
            )
        )

    def import_users(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/users/import", json=body
            )
        )

    def disable_mfa(
        self, tenant_id: str, environment_id: str, user_id: str
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE",
                f"{_env(tenant_id, environment_id)}/users/{user_id}/mfa",
            )
        )

    def list_sessions(
        self, tenant_id: str, environment_id: str, user_id: str
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET",
                f"{_env(tenant_id, environment_id)}/users/{user_id}/sessions",
            )
        )


class GroupsResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def create(self, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(self._client.request("POST", "/v1/groups", json=body))

    def list(self, tenant_id: str, environment_id: str) -> EnvGroupsResponse:
        return EnvGroupsResponse.from_dict(
            self._client.request(
                "GET",
                f"/v1/tenants/{tenant_id}/environments/{environment_id}/groups",
            )
        )

    def delete(self, tenant_id: str, environment_id: str, group_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE",
                f"/v1/tenants/{tenant_id}/environments/{environment_id}/groups/{group_id}",
            )
        )

    def list_members(self, tenant_id: str, environment_id: str, group_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET",
                f"/v1/tenants/{tenant_id}/environments/{environment_id}/groups/{group_id}/members",
            )
        )

    def add_member(
        self, tenant_id: str, environment_id: str, group_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"/v1/tenants/{tenant_id}/environments/{environment_id}/groups/{group_id}/members",
                json=body,
            )
        )

    def remove_member(
        self, tenant_id: str, environment_id: str, group_id: str, user_id: str
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE",
                f"/v1/tenants/{tenant_id}/environments/{environment_id}/groups/{group_id}/members/{user_id}",
            )
        )


def _env(tenant_id: str, environment_id: str) -> str:
    return f"/v1/tenants/{tenant_id}/environments/{environment_id}"


class RbacResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list_roles(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(self._client.request("GET", f"{_env(tenant_id, environment_id)}/roles"))

    def create_role(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("POST", f"{_env(tenant_id, environment_id)}/roles", json=body)
        )

    def delete_role(self, tenant_id: str, environment_id: str, role_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("DELETE", f"{_env(tenant_id, environment_id)}/roles/{role_id}")
        )

    def list_role_permissions(self, tenant_id: str, environment_id: str, role_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", f"{_env(tenant_id, environment_id)}/roles/{role_id}/permissions"
            )
        )

    def set_role_permissions(
        self, tenant_id: str, environment_id: str, role_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PUT",
                f"{_env(tenant_id, environment_id)}/roles/{role_id}/permissions",
                json=body,
            )
        )

    def list_permissions(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/permissions")
        )

    def create_permission(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("POST", f"{_env(tenant_id, environment_id)}/permissions", json=body)
        )

    def delete_permission(self, tenant_id: str, environment_id: str, permission_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE", f"{_env(tenant_id, environment_id)}/permissions/{permission_id}"
            )
        )

    def list_resources(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/resources")
        )

    def create_resource(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("POST", f"{_env(tenant_id, environment_id)}/resources", json=body)
        )

    def delete_resource(self, tenant_id: str, environment_id: str, resource_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE", f"{_env(tenant_id, environment_id)}/resources/{resource_id}"
            )
        )

    def list_group_roles(self, tenant_id: str, environment_id: str, group_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", f"{_env(tenant_id, environment_id)}/groups/{group_id}/roles"
            )
        )

    def add_group_role(
        self, tenant_id: str, environment_id: str, group_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/groups/{group_id}/roles",
                json=body,
            )
        )

    def remove_group_role(
        self, tenant_id: str, environment_id: str, group_id: str, role_id: str
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE",
                f"{_env(tenant_id, environment_id)}/groups/{group_id}/roles/{role_id}",
            )
        )

    def list_group_role_mappings(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/group-role-mappings")
        )

    def create_group_role_mapping(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/group-role-mappings", json=body
            )
        )

    def apply_group_role_mappings(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/group-role-mappings/apply"
            )
        )

    def delete_group_role_mapping(
        self, tenant_id: str, environment_id: str, mapping_id: str
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE",
                f"{_env(tenant_id, environment_id)}/group-role-mappings/{mapping_id}",
            )
        )

    def list_abac_policies(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/abac-policies")
        )

    def save_abac_policy(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/abac-policies", json=body
            )
        )

    def validate_abac_policy(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/abac-policies/validate",
                json=body,
            )
        )

    def delete_abac_policy(self, tenant_id: str, environment_id: str, policy_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE", f"{_env(tenant_id, environment_id)}/abac-policies/{policy_id}"
            )
        )

    def my_permissions(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/me/permissions")
        )


class AuditResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list_logs(
        self, tenant_id: str, environment_id: str, params: Optional[Dict[str, Any]] = None
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/audit/logs", params=params)
        )

    def event_metadata(
        self, tenant_id: str, environment_id: str, params: Optional[Dict[str, Any]] = None
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", f"{_env(tenant_id, environment_id)}/audit/event-metadata", params=params
            )
        )

    def event_types(
        self, tenant_id: str, environment_id: str, params: Optional[Dict[str, Any]] = None
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", f"{_env(tenant_id, environment_id)}/audit/event-types", params=params
            )
        )

    def event_types_catalog(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", f"{_env(tenant_id, environment_id)}/audit/event-types/catalog"
            )
        )


class EventsResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list(
        self, tenant_id: str, environment_id: str, params: Optional[Dict[str, Any]] = None
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/events", params=params)
        )

    def list_types(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/events/types")
        )

    def ingest(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/events/ingest", json=body
            )
        )


class WebhooksResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/webhooks")
        )

    def create(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("POST", f"{_env(tenant_id, environment_id)}/webhooks", json=body)
        )

    def update(
        self, tenant_id: str, environment_id: str, channel_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PUT",
                f"{_env(tenant_id, environment_id)}/webhooks/{channel_id}",
                json=body,
            )
        )

    def delete(self, tenant_id: str, environment_id: str, channel_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE", f"{_env(tenant_id, environment_id)}/webhooks/{channel_id}"
            )
        )

    def rotate_secret(self, tenant_id: str, environment_id: str, channel_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/webhooks/{channel_id}/rotate-secret",
            )
        )

    def list_deliveries(
        self, tenant_id: str, environment_id: str, params: Optional[Dict[str, Any]] = None
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET",
                f"{_env(tenant_id, environment_id)}/webhooks/deliveries",
                params=params,
            )
        )

    def redeliver(self, tenant_id: str, environment_id: str, delivery_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/webhooks/deliveries/{delivery_id}/redeliver",
            )
        )


class NotificationChannelsResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/notification-channels")
        )

    def create(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/notification-channels", json=body
            )
        )

    def update(
        self, tenant_id: str, environment_id: str, channel_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PUT",
                f"{_env(tenant_id, environment_id)}/notification-channels/{channel_id}",
                json=body,
            )
        )

    def delete(self, tenant_id: str, environment_id: str, channel_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE",
                f"{_env(tenant_id, environment_id)}/notification-channels/{channel_id}",
            )
        )

    def test(
        self, tenant_id: str, environment_id: str, channel_id: str, body: Optional[Dict[str, Any]] = None
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/notification-channels/{channel_id}/test",
                json=body,
            )
        )


class ServiceAccountsResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list(self) -> JsonMap:
        return JsonMap.from_dict(self._client.request("GET", "/v1/service-accounts"))

    def create(self, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(self._client.request("POST", "/v1/service-accounts", json=body))

    def get(self, service_account_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"/v1/service-accounts/{service_account_id}")
        )

    def delete(self, service_account_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("DELETE", f"/v1/service-accounts/{service_account_id}")
        )


class PersonalAccessTokensResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list(self) -> JsonMap:
        return JsonMap.from_dict(self._client.request("GET", "/v1/personal-access-tokens"))

    def create(self, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("POST", "/v1/personal-access-tokens", json=body)
        )

    def revoke(self, token_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("POST", f"/v1/personal-access-tokens/{token_id}/revoke")
        )


class ApiSecretsResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/api-secrets")
        )

    def create(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/api-secrets", json=body
            )
        )

    def revoke(self, tenant_id: str, environment_id: str, secret_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/api-secrets/{secret_id}/revoke",
            )
        )


class AuthzenResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def configuration(self) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", "/.well-known/authzen-configuration", omit_auth=True
            )
        )

    def evaluate(self, body: Dict[str, Any], token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                "/access/v1/evaluation",
                json=body,
                access_token=token or self._client.environment_secret,
            )
        )

    def evaluate_batch(self, body: Dict[str, Any], token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                "/access/v1/evaluations",
                json=body,
                access_token=token or self._client.environment_secret,
            )
        )

    def search_action(self, body: Dict[str, Any], token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                "/access/v1/search/action",
                json=body,
                access_token=token or self._client.environment_secret,
            )
        )

    def search_resource(self, body: Dict[str, Any], token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                "/access/v1/search/resource",
                json=body,
                access_token=token or self._client.environment_secret,
            )
        )

    def search_subject(self, body: Dict[str, Any], token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                "/access/v1/search/subject",
                json=body,
                access_token=token or self._client.environment_secret,
            )
        )


class ScimResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def _token(self, token: Optional[str] = None) -> Optional[str]:
        return token or self._client.scim_token

    def list_users(self, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", "/v1/scim/v2/Users", access_token=self._token(token))
        )

    def create_user(self, body: Dict[str, Any], token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", "/v1/scim/v2/Users", json=body, access_token=self._token(token)
            )
        )

    def get_user(self, user_id: str, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", f"/v1/scim/v2/Users/{user_id}", access_token=self._token(token)
            )
        )

    def replace_user(
        self, user_id: str, body: Dict[str, Any], token: Optional[str] = None
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PUT",
                f"/v1/scim/v2/Users/{user_id}",
                json=body,
                access_token=self._token(token),
            )
        )

    def patch_user(
        self, user_id: str, body: Dict[str, Any], token: Optional[str] = None
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PATCH",
                f"/v1/scim/v2/Users/{user_id}",
                json=body,
                access_token=self._token(token),
            )
        )

    def delete_user(self, user_id: str, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE", f"/v1/scim/v2/Users/{user_id}", access_token=self._token(token)
            )
        )

    def list_groups(self, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", "/v1/scim/v2/Groups", access_token=self._token(token))
        )

    def create_group(self, body: Dict[str, Any], token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", "/v1/scim/v2/Groups", json=body, access_token=self._token(token)
            )
        )

    def get_group(self, group_id: str, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", f"/v1/scim/v2/Groups/{group_id}", access_token=self._token(token)
            )
        )

    def replace_group(
        self, group_id: str, body: Dict[str, Any], token: Optional[str] = None
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PUT",
                f"/v1/scim/v2/Groups/{group_id}",
                json=body,
                access_token=self._token(token),
            )
        )

    def patch_group(
        self, group_id: str, body: Dict[str, Any], token: Optional[str] = None
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PATCH",
                f"/v1/scim/v2/Groups/{group_id}",
                json=body,
                access_token=self._token(token),
            )
        )

    def delete_group(self, group_id: str, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE",
                f"/v1/scim/v2/Groups/{group_id}",
                access_token=self._token(token),
            )
        )

    def resource_types(self, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", "/v1/scim/v2/ResourceTypes", access_token=self._token(token)
            )
        )

    def resource_type(self, type_id: str, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET",
                f"/v1/scim/v2/ResourceTypes/{type_id}",
                access_token=self._token(token),
            )
        )

    def schemas(self, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", "/v1/scim/v2/Schemas", access_token=self._token(token)
            )
        )

    def schema(self, schema_id: str, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", f"/v1/scim/v2/Schemas/{schema_id}", access_token=self._token(token)
            )
        )

    def service_provider_config(self, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET",
                "/v1/scim/v2/ServiceProviderConfig",
                access_token=self._token(token),
            )
        )


class HrisResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def _token(self, token: Optional[str] = None) -> Optional[str]:
        return token or self._client.hris_token

    def list_departments(self, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", "/v1/hris/v1/Departments", access_token=self._token(token)
            )
        )

    def create_department(self, body: Dict[str, Any], token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                "/v1/hris/v1/Departments",
                json=body,
                access_token=self._token(token),
            )
        )

    def get_department(self, department_id: str, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET",
                f"/v1/hris/v1/Departments/{department_id}",
                access_token=self._token(token),
            )
        )

    def replace_department(
        self, department_id: str, body: Dict[str, Any], token: Optional[str] = None
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PUT",
                f"/v1/hris/v1/Departments/{department_id}",
                json=body,
                access_token=self._token(token),
            )
        )

    def patch_department(
        self, department_id: str, body: Dict[str, Any], token: Optional[str] = None
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PATCH",
                f"/v1/hris/v1/Departments/{department_id}",
                json=body,
                access_token=self._token(token),
            )
        )

    def delete_department(self, department_id: str, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE",
                f"/v1/hris/v1/Departments/{department_id}",
                access_token=self._token(token),
            )
        )

    def list_employees(self, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", "/v1/hris/v1/Employees", access_token=self._token(token)
            )
        )

    def create_employee(self, body: Dict[str, Any], token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", "/v1/hris/v1/Employees", json=body, access_token=self._token(token)
            )
        )

    def get_employee(self, employee_id: str, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET",
                f"/v1/hris/v1/Employees/{employee_id}",
                access_token=self._token(token),
            )
        )

    def replace_employee(
        self, employee_id: str, body: Dict[str, Any], token: Optional[str] = None
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PUT",
                f"/v1/hris/v1/Employees/{employee_id}",
                json=body,
                access_token=self._token(token),
            )
        )

    def patch_employee(
        self, employee_id: str, body: Dict[str, Any], token: Optional[str] = None
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PATCH",
                f"/v1/hris/v1/Employees/{employee_id}",
                json=body,
                access_token=self._token(token),
            )
        )

    def delete_employee(self, employee_id: str, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE",
                f"/v1/hris/v1/Employees/{employee_id}",
                access_token=self._token(token),
            )
        )

    def service_config(self, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", "/v1/hris/v1/ServiceConfig", access_token=self._token(token)
            )
        )


class McpResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def _runtime(self, token: Optional[str] = None) -> Optional[str]:
        return token or self._client.environment_secret

    def ingest_events(self, body: Dict[str, Any], token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", "/v1/mcp/events", json=body, access_token=self._runtime(token)
            )
        )

    def resolve(self, subject: str, token: Optional[str] = None) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET",
                "/v1/mcp/trust-store/resolve",
                params={"subject": subject},
                access_token=self._runtime(token),
            )
        )

    def list_entries(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/mcp/trust-store")
        )

    def create_entry(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/mcp/trust-store", json=body
            )
        )

    def get_entry(self, tenant_id: str, environment_id: str, entry_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", f"{_env(tenant_id, environment_id)}/mcp/trust-store/{entry_id}"
            )
        )

    def update_entry(
        self, tenant_id: str, environment_id: str, entry_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PATCH",
                f"{_env(tenant_id, environment_id)}/mcp/trust-store/{entry_id}",
                json=body,
            )
        )

    def delete_entry(self, tenant_id: str, environment_id: str, entry_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE",
                f"{_env(tenant_id, environment_id)}/mcp/trust-store/{entry_id}",
            )
        )

    def add_key(
        self, tenant_id: str, environment_id: str, entry_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/mcp/trust-store/{entry_id}/keys",
                json=body,
            )
        )

    def revoke_key(
        self, tenant_id: str, environment_id: str, entry_id: str, key_id: str
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE",
                f"{_env(tenant_id, environment_id)}/mcp/trust-store/{entry_id}/keys/{key_id}",
            )
        )

    def rotate_key(
        self,
        tenant_id: str,
        environment_id: str,
        entry_id: str,
        key_id: str,
        body: Optional[Dict[str, Any]] = None,
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/mcp/trust-store/{entry_id}/keys/{key_id}/rotate",
                json=body,
            )
        )

    def revoke_entry(self, tenant_id: str, environment_id: str, entry_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/mcp/trust-store/{entry_id}/revoke",
            )
        )

    def verify_entry(
        self, tenant_id: str, environment_id: str, entry_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/mcp/trust-store/{entry_id}/verify",
                json=body,
            )
        )


class OtelResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def export_logs(self, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(self._client.request("POST", "/v1/logs", json=body))

    def export_metrics(self, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(self._client.request("POST", "/v1/metrics", json=body))

    def export_traces(self, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(self._client.request("POST", "/v1/traces", json=body))

    def export_logs_prefixed(self, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(self._client.request("POST", "/v1/otel/v1/logs", json=body))

    def export_metrics_prefixed(self, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("POST", "/v1/otel/v1/metrics", json=body)
        )

    def export_traces_prefixed(self, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("POST", "/v1/otel/v1/traces", json=body)
        )


class OidcClientsResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def _path(self, tenant_id: str, application_id: str, environment_id: str) -> str:
        return (
            f"/v1/tenants/{tenant_id}/applications/{application_id}"
            f"/environments/{environment_id}/oidc-clients"
        )

    def list(self, tenant_id: str, application_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", self._path(tenant_id, application_id, environment_id))
        )

    def register(
        self, tenant_id: str, application_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", self._path(tenant_id, application_id, environment_id), json=body
            )
        )

    def update(
        self,
        tenant_id: str,
        application_id: str,
        environment_id: str,
        client_id: str,
        body: Dict[str, Any],
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PATCH",
                f"{self._path(tenant_id, application_id, environment_id)}/{client_id}",
                json=body,
            )
        )

    def delete(
        self, tenant_id: str, application_id: str, environment_id: str, client_id: str
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE",
                f"{self._path(tenant_id, application_id, environment_id)}/{client_id}",
            )
        )


class ActionsResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/actions")
        )

    def save(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/actions", json=body
            )
        )

    def executions(
        self,
        tenant_id: str,
        environment_id: str,
        action_id: Optional[str] = None,
        limit: Optional[int] = None,
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET",
                f"{_env(tenant_id, environment_id)}/actions/executions",
                params=_params(actionId=action_id, limit=limit),
            )
        )

    def test(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/actions/test", json=body
            )
        )

    def delete(self, tenant_id: str, environment_id: str, action_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE", f"{_env(tenant_id, environment_id)}/actions/{action_id}"
            )
        )


class AddonsResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/addons")
        )

    def save(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/addons", json=body
            )
        )

    def delete(self, tenant_id: str, environment_id: str, provider: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE", f"{_env(tenant_id, environment_id)}/addons/{provider}"
            )
        )


class BillingResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list_features(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/billing/features")
        )

    def save_feature(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/billing/features", json=body
            )
        )

    def delete_feature(
        self, tenant_id: str, environment_id: str, feature_id: str
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE",
                f"{_env(tenant_id, environment_id)}/billing/features/{feature_id}",
            )
        )

    def list_plans(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/billing/plans")
        )

    def save_plan(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/billing/plans", json=body
            )
        )

    def delete_plan(self, tenant_id: str, environment_id: str, plan_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE", f"{_env(tenant_id, environment_id)}/billing/plans/{plan_id}"
            )
        )

    def sync_stripe(self, tenant_id: str, environment_id: str, plan_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/billing/plans/{plan_id}/sync-stripe",
            )
        )


class SettingsResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def _get(self, tenant_id: str, environment_id: str, suffix: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/{suffix}")
        )

    def _put(
        self, tenant_id: str, environment_id: str, suffix: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PUT", f"{_env(tenant_id, environment_id)}/{suffix}", json=body
            )
        )

    def get_bot_detection_policy(self, tenant_id: str, environment_id: str) -> JsonMap:
        return self._get(tenant_id, environment_id, "bot-detection-policy")

    def update_bot_detection_policy(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return self._put(tenant_id, environment_id, "bot-detection-policy", body)

    def get_breached_password_policy(self, tenant_id: str, environment_id: str) -> JsonMap:
        return self._get(tenant_id, environment_id, "breached-password-policy")

    def update_breached_password_policy(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return self._put(tenant_id, environment_id, "breached-password-policy", body)

    def get_brute_force_policy(self, tenant_id: str, environment_id: str) -> JsonMap:
        return self._get(tenant_id, environment_id, "brute-force-policy")

    def update_brute_force_policy(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return self._put(tenant_id, environment_id, "brute-force-policy", body)

    def get_device_risk_policy(self, tenant_id: str, environment_id: str) -> JsonMap:
        return self._get(tenant_id, environment_id, "device-risk-policy")

    def update_device_risk_policy(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return self._put(tenant_id, environment_id, "device-risk-policy", body)

    def list_jwt_claim_mappings(self, tenant_id: str, environment_id: str) -> JsonMap:
        return self._get(tenant_id, environment_id, "jwt-claim-mappings")

    def save_jwt_claim_mapping(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/jwt-claim-mappings",
                json=body,
            )
        )

    def delete_jwt_claim_mapping(
        self, tenant_id: str, environment_id: str, mapping_id: str
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE",
                f"{_env(tenant_id, environment_id)}/jwt-claim-mappings/{mapping_id}",
            )
        )

    def get_password_policy(self, tenant_id: str, environment_id: str) -> JsonMap:
        return self._get(tenant_id, environment_id, "password-policy")

    def update_password_policy(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return self._put(tenant_id, environment_id, "password-policy", body)

    def get_rate_limit_policy(self, tenant_id: str, environment_id: str) -> JsonMap:
        return self._get(tenant_id, environment_id, "rate-limit-policy")

    def update_rate_limit_policy(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return self._put(tenant_id, environment_id, "rate-limit-policy", body)

    def get_restrictions(self, tenant_id: str, environment_id: str) -> JsonMap:
        return self._get(tenant_id, environment_id, "restrictions")

    def update_restrictions(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return self._put(tenant_id, environment_id, "restrictions", body)

    def get_session_config(self, tenant_id: str, environment_id: str) -> JsonMap:
        return self._get(tenant_id, environment_id, "session-config")

    def update_session_config(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return self._put(tenant_id, environment_id, "session-config", body)


class ElevateResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def activate_grant(
        self, tenant_id: str, environment_id: str, grant_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/elevate/access-grants/{grant_id}/activate",
                json=body,
            )
        )

    def revoke_grant(
        self, tenant_id: str, environment_id: str, grant_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/elevate/access-grants/{grant_id}/revoke",
                json=body,
            )
        )

    def list_requests(
        self, tenant_id: str, environment_id: str, status: Optional[str] = None
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET",
                f"{_env(tenant_id, environment_id)}/elevate/access-requests",
                params=_params(status=status),
            )
        )

    def create_request(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/elevate/access-requests",
                json=body,
            )
        )

    def get_request(
        self, tenant_id: str, environment_id: str, request_id: str
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET",
                f"{_env(tenant_id, environment_id)}/elevate/access-requests/{request_id}",
            )
        )

    def approve_request(
        self, tenant_id: str, environment_id: str, request_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/elevate/access-requests/{request_id}/approve",
                json=body,
            )
        )

    def cancel_request(
        self, tenant_id: str, environment_id: str, request_id: str
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/elevate/access-requests/{request_id}/cancel",
            )
        )

    def deny_request(
        self, tenant_id: str, environment_id: str, request_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/elevate/access-requests/{request_id}/deny",
                json=body,
            )
        )

    def get_policy(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/elevate/policy")
        )

    def update_policy(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PUT", f"{_env(tenant_id, environment_id)}/elevate/policy", json=body
            )
        )


class EmailProvidersResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/email-providers")
        )

    def save(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/email-providers", json=body
            )
        )

    def test(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/email-providers/test",
                json=body,
            )
        )

    def delete(self, tenant_id: str, environment_id: str, provider: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE",
                f"{_env(tenant_id, environment_id)}/email-providers/{provider}",
            )
        )

    def activate(self, tenant_id: str, environment_id: str, provider: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/email-providers/{provider}/activate",
            )
        )


class FeatureFlagsResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/feature-flags")
        )

    def save(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/feature-flags", json=body
            )
        )

    def delete(self, tenant_id: str, environment_id: str, flag_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE", f"{_env(tenant_id, environment_id)}/feature-flags/{flag_id}"
            )
        )


class FormsResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list_attachments(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", f"{_env(tenant_id, environment_id)}/form-attachments"
            )
        )

    def list(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/forms")
        )

    def save(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/forms", json=body
            )
        )

    def delete(self, tenant_id: str, environment_id: str, form_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE", f"{_env(tenant_id, environment_id)}/forms/{form_id}"
            )
        )


class ProvisioningTokensResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list_hris(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/hris-tokens")
        )

    def create_hris(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/hris-tokens", json=body
            )
        )

    def revoke_hris(self, tenant_id: str, environment_id: str, token_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/hris-tokens/{token_id}/revoke",
            )
        )

    def rotate_hris(self, tenant_id: str, environment_id: str, token_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/hris-tokens/{token_id}/rotate",
            )
        )

    def list_scim(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/scim-tokens")
        )

    def create_scim(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/scim-tokens", json=body
            )
        )

    def revoke_scim(self, tenant_id: str, environment_id: str, token_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/scim-tokens/{token_id}/revoke",
            )
        )

    def rotate_scim(self, tenant_id: str, environment_id: str, token_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/scim-tokens/{token_id}/rotate",
            )
        )


class ImpersonationResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", f"{_env(tenant_id, environment_id)}/impersonation-grants"
            )
        )

    def create(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/impersonation-grants",
                json=body,
            )
        )

    def revoke(self, tenant_id: str, environment_id: str, grant_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/impersonation-grants/{grant_id}/revoke",
            )
        )


class PortalResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def generate_link(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/portal/generate-link",
                json=body,
            )
        )


class SecurityResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def posture(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", f"{_env(tenant_id, environment_id)}/security/posture"
            )
        )


class ThreatsResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list(
        self, tenant_id: str, environment_id: str, params: Optional[Dict[str, Any]] = None
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", f"{_env(tenant_id, environment_id)}/threats", params=params
            )
        )

    def create(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/threats", json=body
            )
        )

    def get(self, tenant_id: str, environment_id: str, threat_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "GET", f"{_env(tenant_id, environment_id)}/threats/{threat_id}"
            )
        )

    def update(
        self, tenant_id: str, environment_id: str, threat_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "PATCH",
                f"{_env(tenant_id, environment_id)}/threats/{threat_id}",
                json=body,
            )
        )

    def delete(self, tenant_id: str, environment_id: str, threat_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE", f"{_env(tenant_id, environment_id)}/threats/{threat_id}"
            )
        )

    def resolve(
        self, tenant_id: str, environment_id: str, threat_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/threats/{threat_id}/resolve",
                json=body,
            )
        )


class VanityDomainsResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def list(self, tenant_id: str, environment_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request("GET", f"{_env(tenant_id, environment_id)}/vanity-domains")
        )

    def create(self, tenant_id: str, environment_id: str, body: Dict[str, Any]) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/vanity-domains", json=body
            )
        )

    def delete(self, tenant_id: str, environment_id: str, domain_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "DELETE",
                f"{_env(tenant_id, environment_id)}/vanity-domains/{domain_id}",
            )
        )

    def check(self, tenant_id: str, environment_id: str, domain_id: str) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST",
                f"{_env(tenant_id, environment_id)}/vanity-domains/{domain_id}/check",
            )
        )


class WidgetsResource:
    def __init__(self, client: "AuthdogClient") -> None:
        self._client = client

    def create_token(
        self, tenant_id: str, environment_id: str, body: Dict[str, Any]
    ) -> JsonMap:
        return JsonMap.from_dict(
            self._client.request(
                "POST", f"{_env(tenant_id, environment_id)}/widgets/token", json=body
            )
        )
