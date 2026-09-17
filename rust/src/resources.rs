use crate::client::AuthdogClient;
use crate::error::AuthdogError;
use crate::types::{EnvGroupsResponse, EnvUsersResponse, OrganizationsList, TenantsList};
use serde::Serialize;
use serde_json::Value;

fn to_value(body: impl Serialize) -> Result<Value, AuthdogError> {
    serde_json::to_value(body).map_err(|e| {
        crate::error::APIError::new(format!("Failed to serialize request: {}", e)).into()
    })
}

fn query_pairs(pairs: Vec<(&str, Option<String>)>) -> Vec<(String, String)> {
    pairs
        .into_iter()
        .filter_map(|(key, value)| value.map(|value| (key.to_string(), value)))
        .collect()
}

fn env(tenant_id: &str, environment_id: &str) -> String {
    format!("/v1/tenants/{}/environments/{}", tenant_id, environment_id)
}

/// Forward caller query params. Accepts a JSON object (`serde_json::Value`)
/// or any object that serializes like a `HashMap`.
fn query_from_params(params: Option<&Value>) -> Vec<(String, String)> {
    let Some(Value::Object(map)) = params else {
        return Vec::new();
    };
    map.iter()
        .filter_map(|(key, value)| match value {
            Value::Null => None,
            Value::String(s) => Some((key.clone(), s.clone())),
            Value::Number(n) => Some((key.clone(), n.to_string())),
            Value::Bool(b) => Some((key.clone(), b.to_string())),
            other => Some((key.clone(), other.to_string())),
        })
        .collect()
}

/// Organization management namespace.
pub struct OrganizationsResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> OrganizationsResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list(&self) -> Result<OrganizationsList, AuthdogError> {
        self.client
            .request_parsed("GET", "/v1/organizations", None, &[])
            .await
    }

    pub async fn create(&self, body: impl Serialize) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request("POST", "/v1/organizations", Some(&body), &[])
            .await
    }

    pub async fn get(&self, organization_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("/v1/organizations/{}", organization_id),
                None,
                &[],
            )
            .await
    }

    pub async fn update(
        &self,
        organization_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "PATCH",
                &format!("/v1/organizations/{}", organization_id),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete(&self, organization_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!("/v1/organizations/{}", organization_id),
                None,
                &[],
            )
            .await
    }

    pub async fn accept_invitation(&self, body: impl Serialize) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                "/v1/organizations/invitations/accept",
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn join(&self, body: impl Serialize) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request("POST", "/v1/organizations/join", Some(&body), &[])
            .await
    }

    pub async fn list_invitations(&self, organization_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("/v1/organizations/{}/invitations", organization_id),
                None,
                &[],
            )
            .await
    }

    pub async fn create_invitation(
        &self,
        organization_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("/v1/organizations/{}/invitations", organization_id),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn cancel_invitation(
        &self,
        organization_id: &str,
        invitation_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "/v1/organizations/{}/invitations/{}/cancel",
                    organization_id, invitation_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn send_invite(
        &self,
        organization_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("/v1/organizations/{}/invites", organization_id),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn list_members(&self, organization_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("/v1/organizations/{}/members", organization_id),
                None,
                &[],
            )
            .await
    }

    pub async fn remove_member(
        &self,
        organization_id: &str,
        member_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "/v1/organizations/{}/members/{}",
                    organization_id, member_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn set_member_active(
        &self,
        organization_id: &str,
        member_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "PATCH",
                &format!(
                    "/v1/organizations/{}/members/{}/active",
                    organization_id, member_id
                ),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn link_tenant(
        &self,
        organization_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("/v1/organizations/{}/tenants", organization_id),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn unlink_tenant(
        &self,
        organization_id: &str,
        tenant_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "/v1/organizations/{}/tenants/{}",
                    organization_id, tenant_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn list_keys(&self, organization_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("/v1/organizations/{}/keys", organization_id),
                None,
                &[],
            )
            .await
    }

    pub async fn create_key(
        &self,
        organization_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("/v1/organizations/{}/keys", organization_id),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn revoke_key(
        &self,
        organization_id: &str,
        key_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "/v1/organizations/{}/keys/{}/revoke",
                    organization_id, key_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn rotate_key(
        &self,
        organization_id: &str,
        key_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "/v1/organizations/{}/keys/{}/rotate",
                    organization_id, key_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn update_key_tenants(
        &self,
        organization_id: &str,
        key_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "PUT",
                &format!(
                    "/v1/organizations/{}/keys/{}/tenants",
                    organization_id, key_id
                ),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn list_audit_logs(
        &self,
        organization_id: &str,
        params: Option<&Value>,
    ) -> Result<Value, AuthdogError> {
        let query = query_from_params(params);
        self.client
            .request(
                "GET",
                &format!("/v1/organizations/{}/audit/logs", organization_id),
                None,
                &query,
            )
            .await
    }
}

/// Tenant management namespace.
pub struct TenantsResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> TenantsResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list(&self, organization_id: Option<&str>) -> Result<TenantsList, AuthdogError> {
        let query = query_pairs(vec![(
            "organization_id",
            organization_id.map(str::to_string),
        )]);
        self.client
            .request_parsed("GET", "/v1/tenants", None, &query)
            .await
    }

    pub async fn create(&self, body: impl Serialize) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request("POST", "/v1/tenants", Some(&body), &[])
            .await
    }

    pub async fn join(&self, body: impl Serialize) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request("POST", "/v1/tenants/join", Some(&body), &[])
            .await
    }

    pub async fn get(
        &self,
        tenant_id: &str,
        organization_id: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let query = query_pairs(vec![(
            "organization_id",
            organization_id.map(str::to_string),
        )]);
        self.client
            .request("GET", &format!("/v1/tenants/{}", tenant_id), None, &query)
            .await
    }

    pub async fn update(
        &self,
        tenant_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "PATCH",
                &format!("/v1/tenants/{}", tenant_id),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete(&self, tenant_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request("DELETE", &format!("/v1/tenants/{}", tenant_id), None, &[])
            .await
    }

    pub async fn list_domains(&self, tenant_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("/v1/tenants/{}/domains", tenant_id),
                None,
                &[],
            )
            .await
    }

    pub async fn create_domain(
        &self,
        tenant_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("/v1/tenants/{}/domains", tenant_id),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete_domain(
        &self,
        tenant_id: &str,
        domain_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!("/v1/tenants/{}/domains/{}", tenant_id, domain_id),
                None,
                &[],
            )
            .await
    }

    pub async fn retry_domain(
        &self,
        tenant_id: &str,
        domain_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!("/v1/tenants/{}/domains/{}/retry", tenant_id, domain_id),
                None,
                &[],
            )
            .await
    }

    pub async fn send_invite(
        &self,
        tenant_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("/v1/tenants/{}/invites", tenant_id),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn list_projects(&self, tenant_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("/v1/tenants/{}/projects", tenant_id),
                None,
                &[],
            )
            .await
    }

    pub async fn list_seats(&self, tenant_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("/v1/tenants/{}/seats", tenant_id),
                None,
                &[],
            )
            .await
    }

    pub async fn update_seat(
        &self,
        tenant_id: &str,
        seat_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "PATCH",
                &format!("/v1/tenants/{}/seats/{}", tenant_id, seat_id),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete_seat(&self, tenant_id: &str, seat_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!("/v1/tenants/{}/seats/{}", tenant_id, seat_id),
                None,
                &[],
            )
            .await
    }
}

/// Project (application) namespace.
pub struct ProjectsResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> ProjectsResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn save(&self, tenant_id: &str, body: impl Serialize) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("/v1/tenants/{}/applications", tenant_id),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn get(&self, tenant_id: &str, application_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("/v1/tenants/{}/applications/{}", tenant_id, application_id),
                None,
                &[],
            )
            .await
    }

    pub async fn delete(
        &self,
        tenant_id: &str,
        application_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!("/v1/tenants/{}/applications/{}", tenant_id, application_id),
                None,
                &[],
            )
            .await
    }

    pub async fn set_default_environment(
        &self,
        tenant_id: &str,
        application_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "PUT",
                &format!(
                    "/v1/tenants/{}/applications/{}/default-environment",
                    tenant_id, application_id
                ),
                Some(&body),
                &[],
            )
            .await
    }
}

/// Environment lifecycle namespace.
pub struct EnvironmentsResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> EnvironmentsResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list(&self, tenant_id: &str, application_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!(
                    "/v1/tenants/{}/applications/{}/environments",
                    tenant_id, application_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn create(
        &self,
        tenant_id: &str,
        application_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!(
                    "/v1/tenants/{}/applications/{}/environments",
                    tenant_id, application_id
                ),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn update(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "PATCH",
                &format!("/v1/tenants/{}/environments/{}", tenant_id, environment_id),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!("/v1/tenants/{}/environments/{}", tenant_id, environment_id),
                None,
                &[],
            )
            .await
    }
}

/// Directory user namespace.
pub struct UsersResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> UsersResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list(
        &self,
        tenant_id: &str,
        environment_id: &str,
        offset: Option<i64>,
        limit: Option<i64>,
        search_query: Option<&str>,
    ) -> Result<EnvUsersResponse, AuthdogError> {
        let query = query_pairs(vec![
            ("offset", offset.map(|value| value.to_string())),
            ("limit", limit.map(|value| value.to_string())),
            ("searchQuery", search_query.map(str::to_string)),
        ]);
        self.client
            .request_parsed(
                "GET",
                &format!(
                    "/v1/tenants/{}/environments/{}/users",
                    tenant_id, environment_id
                ),
                None,
                &query,
            )
            .await
    }

    pub async fn create(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!(
                    "/v1/tenants/{}/environments/{}/users",
                    tenant_id, environment_id
                ),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn search(
        &self,
        tenant_id: &str,
        environment_id: &str,
        q: Option<&str>,
        offset: Option<i64>,
        limit: Option<i64>,
    ) -> Result<EnvUsersResponse, AuthdogError> {
        let query = query_pairs(vec![
            ("q", q.map(str::to_string)),
            ("offset", offset.map(|value| value.to_string())),
            ("limit", limit.map(|value| value.to_string())),
        ]);
        self.client
            .request_parsed(
                "GET",
                &format!(
                    "/v1/tenants/{}/environments/{}/users/search",
                    tenant_id, environment_id
                ),
                None,
                &query,
            )
            .await
    }

    pub async fn count(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!(
                    "/v1/tenants/{}/environments/{}/users/count",
                    tenant_id, environment_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn get(
        &self,
        tenant_id: &str,
        environment_id: &str,
        user_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!(
                    "/v1/tenants/{}/environments/{}/users/{}",
                    tenant_id, environment_id, user_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn update(
        &self,
        tenant_id: &str,
        environment_id: &str,
        user_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "PUT",
                &format!(
                    "/v1/tenants/{}/environments/{}/users/{}",
                    tenant_id, environment_id, user_id
                ),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete(
        &self,
        tenant_id: &str,
        environment_id: &str,
        user_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "/v1/tenants/{}/environments/{}/users/{}",
                    tenant_id, environment_id, user_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn set_active(
        &self,
        tenant_id: &str,
        environment_id: &str,
        user_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "PATCH",
                &format!(
                    "/v1/tenants/{}/environments/{}/users/{}/active",
                    tenant_id, environment_id, user_id
                ),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn list_groups(
        &self,
        tenant_id: &str,
        environment_id: &str,
        user_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!(
                    "/v1/tenants/{}/environments/{}/users/{}/groups",
                    tenant_id, environment_id, user_id
                ),
                None,
                &[],
            )
            .await
    }
}

/// Directory group namespace.
pub struct GroupsResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> GroupsResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn create(&self, body: impl Serialize) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request("POST", "/v1/groups", Some(&body), &[])
            .await
    }

    pub async fn list(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<EnvGroupsResponse, AuthdogError> {
        self.client
            .request_parsed(
                "GET",
                &format!(
                    "/v1/tenants/{}/environments/{}/groups",
                    tenant_id, environment_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn delete(
        &self,
        tenant_id: &str,
        environment_id: &str,
        group_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "/v1/tenants/{}/environments/{}/groups/{}",
                    tenant_id, environment_id, group_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn list_members(
        &self,
        tenant_id: &str,
        environment_id: &str,
        group_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!(
                    "/v1/tenants/{}/environments/{}/groups/{}/members",
                    tenant_id, environment_id, group_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn add_member(
        &self,
        tenant_id: &str,
        environment_id: &str,
        group_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!(
                    "/v1/tenants/{}/environments/{}/groups/{}/members",
                    tenant_id, environment_id, group_id
                ),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn remove_member(
        &self,
        tenant_id: &str,
        environment_id: &str,
        group_id: &str,
        user_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "/v1/tenants/{}/environments/{}/groups/{}/members/{}",
                    tenant_id, environment_id, group_id, user_id
                ),
                None,
                &[],
            )
            .await
    }
}

/// RBAC (roles, permissions, resources, mappings, ABAC) namespace.
pub struct RbacResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> RbacResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list_roles(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/roles", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn create_role(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/roles", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete_role(
        &self,
        tenant_id: &str,
        environment_id: &str,
        role_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!("{}/roles/{}", env(tenant_id, environment_id), role_id),
                None,
                &[],
            )
            .await
    }

    pub async fn list_role_permissions(
        &self,
        tenant_id: &str,
        environment_id: &str,
        role_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!(
                    "{}/roles/{}/permissions",
                    env(tenant_id, environment_id),
                    role_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn set_role_permissions(
        &self,
        tenant_id: &str,
        environment_id: &str,
        role_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "PUT",
                &format!(
                    "{}/roles/{}/permissions",
                    env(tenant_id, environment_id),
                    role_id
                ),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn list_permissions(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/permissions", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn create_permission(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/permissions", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete_permission(
        &self,
        tenant_id: &str,
        environment_id: &str,
        permission_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "{}/permissions/{}",
                    env(tenant_id, environment_id),
                    permission_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn list_resources(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/resources", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn create_resource(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/resources", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete_resource(
        &self,
        tenant_id: &str,
        environment_id: &str,
        resource_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "{}/resources/{}",
                    env(tenant_id, environment_id),
                    resource_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn list_group_roles(
        &self,
        tenant_id: &str,
        environment_id: &str,
        group_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!(
                    "{}/groups/{}/roles",
                    env(tenant_id, environment_id),
                    group_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn add_group_role(
        &self,
        tenant_id: &str,
        environment_id: &str,
        group_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!(
                    "{}/groups/{}/roles",
                    env(tenant_id, environment_id),
                    group_id
                ),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn remove_group_role(
        &self,
        tenant_id: &str,
        environment_id: &str,
        group_id: &str,
        role_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "{}/groups/{}/roles/{}",
                    env(tenant_id, environment_id),
                    group_id,
                    role_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn list_group_role_mappings(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/group-role-mappings", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn create_group_role_mapping(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/group-role-mappings", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn apply_group_role_mappings(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "{}/group-role-mappings/apply",
                    env(tenant_id, environment_id)
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn delete_group_role_mapping(
        &self,
        tenant_id: &str,
        environment_id: &str,
        mapping_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "{}/group-role-mappings/{}",
                    env(tenant_id, environment_id),
                    mapping_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn list_abac_policies(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/abac-policies", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn save_abac_policy(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/abac-policies", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn validate_abac_policy(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/abac-policies/validate", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete_abac_policy(
        &self,
        tenant_id: &str,
        environment_id: &str,
        policy_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "{}/abac-policies/{}",
                    env(tenant_id, environment_id),
                    policy_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn my_permissions(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/me/permissions", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }
}

/// Environment audit log namespace.
pub struct AuditResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> AuditResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list_logs(
        &self,
        tenant_id: &str,
        environment_id: &str,
        params: Option<&Value>,
    ) -> Result<Value, AuthdogError> {
        let query = query_from_params(params);
        self.client
            .request(
                "GET",
                &format!("{}/audit/logs", env(tenant_id, environment_id)),
                None,
                &query,
            )
            .await
    }

    pub async fn event_metadata(
        &self,
        tenant_id: &str,
        environment_id: &str,
        params: Option<&Value>,
    ) -> Result<Value, AuthdogError> {
        let query = query_from_params(params);
        self.client
            .request(
                "GET",
                &format!("{}/audit/event-metadata", env(tenant_id, environment_id)),
                None,
                &query,
            )
            .await
    }

    pub async fn event_types(
        &self,
        tenant_id: &str,
        environment_id: &str,
        params: Option<&Value>,
    ) -> Result<Value, AuthdogError> {
        let query = query_from_params(params);
        self.client
            .request(
                "GET",
                &format!("{}/audit/event-types", env(tenant_id, environment_id)),
                None,
                &query,
            )
            .await
    }

    pub async fn event_types_catalog(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!(
                    "{}/audit/event-types/catalog",
                    env(tenant_id, environment_id)
                ),
                None,
                &[],
            )
            .await
    }
}

/// Environment events namespace.
pub struct EventsResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> EventsResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list(
        &self,
        tenant_id: &str,
        environment_id: &str,
        params: Option<&Value>,
    ) -> Result<Value, AuthdogError> {
        let query = query_from_params(params);
        self.client
            .request(
                "GET",
                &format!("{}/events", env(tenant_id, environment_id)),
                None,
                &query,
            )
            .await
    }

    pub async fn list_types(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/events/types", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn ingest(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/events/ingest", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }
}

/// Webhook channel namespace.
pub struct WebhooksResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> WebhooksResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list(&self, tenant_id: &str, environment_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/webhooks", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn create(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/webhooks", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn update(
        &self,
        tenant_id: &str,
        environment_id: &str,
        channel_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "PUT",
                &format!("{}/webhooks/{}", env(tenant_id, environment_id), channel_id),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete(
        &self,
        tenant_id: &str,
        environment_id: &str,
        channel_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!("{}/webhooks/{}", env(tenant_id, environment_id), channel_id),
                None,
                &[],
            )
            .await
    }

    pub async fn rotate_secret(
        &self,
        tenant_id: &str,
        environment_id: &str,
        channel_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "{}/webhooks/{}/rotate-secret",
                    env(tenant_id, environment_id),
                    channel_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn list_deliveries(
        &self,
        tenant_id: &str,
        environment_id: &str,
        params: Option<&Value>,
    ) -> Result<Value, AuthdogError> {
        let query = query_from_params(params);
        self.client
            .request(
                "GET",
                &format!("{}/webhooks/deliveries", env(tenant_id, environment_id)),
                None,
                &query,
            )
            .await
    }

    pub async fn redeliver(
        &self,
        tenant_id: &str,
        environment_id: &str,
        delivery_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "{}/webhooks/deliveries/{}/redeliver",
                    env(tenant_id, environment_id),
                    delivery_id
                ),
                None,
                &[],
            )
            .await
    }
}

/// Notification channel namespace.
pub struct NotificationChannelsResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> NotificationChannelsResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list(&self, tenant_id: &str, environment_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/notification-channels", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn create(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/notification-channels", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn update(
        &self,
        tenant_id: &str,
        environment_id: &str,
        channel_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "PUT",
                &format!(
                    "{}/notification-channels/{}",
                    env(tenant_id, environment_id),
                    channel_id
                ),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete(
        &self,
        tenant_id: &str,
        environment_id: &str,
        channel_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "{}/notification-channels/{}",
                    env(tenant_id, environment_id),
                    channel_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn test(
        &self,
        tenant_id: &str,
        environment_id: &str,
        channel_id: &str,
        body: Option<&Value>,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "{}/notification-channels/{}/test",
                    env(tenant_id, environment_id),
                    channel_id
                ),
                body,
                &[],
            )
            .await
    }
}

/// Service account namespace.
pub struct ServiceAccountsResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> ServiceAccountsResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list(&self) -> Result<Value, AuthdogError> {
        self.client
            .request("GET", "/v1/service-accounts", None, &[])
            .await
    }

    pub async fn create(&self, body: impl Serialize) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request("POST", "/v1/service-accounts", Some(&body), &[])
            .await
    }

    pub async fn get(&self, service_account_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("/v1/service-accounts/{}", service_account_id),
                None,
                &[],
            )
            .await
    }

    pub async fn delete(&self, service_account_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!("/v1/service-accounts/{}", service_account_id),
                None,
                &[],
            )
            .await
    }
}

/// Personal access token namespace.
pub struct PersonalAccessTokensResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> PersonalAccessTokensResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list(&self) -> Result<Value, AuthdogError> {
        self.client
            .request("GET", "/v1/personal-access-tokens", None, &[])
            .await
    }

    pub async fn create(&self, body: impl Serialize) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request("POST", "/v1/personal-access-tokens", Some(&body), &[])
            .await
    }

    pub async fn revoke(&self, token_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!("/v1/personal-access-tokens/{}/revoke", token_id),
                None,
                &[],
            )
            .await
    }
}

/// Environment API secret namespace.
pub struct ApiSecretsResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> ApiSecretsResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list(&self, tenant_id: &str, environment_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/api-secrets", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn create(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/api-secrets", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn revoke(
        &self,
        tenant_id: &str,
        environment_id: &str,
        secret_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "{}/api-secrets/{}/revoke",
                    env(tenant_id, environment_id),
                    secret_id
                ),
                None,
                &[],
            )
            .await
    }
}
