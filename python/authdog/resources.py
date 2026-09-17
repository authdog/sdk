"""Wave 1 and Wave 2 management resource namespaces."""

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
