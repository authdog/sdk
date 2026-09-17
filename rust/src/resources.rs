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
