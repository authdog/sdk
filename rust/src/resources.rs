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

fn app_env(tenant_id: &str, application_id: &str, environment_id: &str) -> String {
    format!(
        "/v1/tenants/{}/applications/{}/environments/{}",
        tenant_id, application_id, environment_id
    )
}

fn pick_token<'a>(token: Option<&'a str>, fallback: Option<&'a str>) -> Option<&'a str> {
    token.or(fallback)
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

    pub async fn list_connections(
        &self,
        tenant_id: &str,
        application_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!(
                    "{}/connections",
                    app_env(tenant_id, application_id, environment_id)
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn list_redirect_uris(
        &self,
        tenant_id: &str,
        application_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!(
                    "{}/redirect-uris",
                    app_env(tenant_id, application_id, environment_id)
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn save_connection(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/connections", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn resolve_saml_metadata(
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
                    "{}/connections/resolve-saml-metadata",
                    env(tenant_id, environment_id)
                ),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn get_sso_metadata(
        &self,
        tenant_id: &str,
        environment_id: &str,
        connection_id: Option<&str>,
        provider_id: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let query = query_pairs(vec![
            ("connectionId", connection_id.map(str::to_string)),
            ("providerId", provider_id.map(str::to_string)),
        ]);
        self.client
            .request(
                "GET",
                &format!(
                    "{}/connections/sso-metadata",
                    env(tenant_id, environment_id)
                ),
                None,
                &query,
            )
            .await
    }

    pub async fn delete_connection(
        &self,
        tenant_id: &str,
        environment_id: &str,
        connection_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "{}/connections/{}",
                    env(tenant_id, environment_id),
                    connection_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn save_redirect_uris(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "PUT",
                &format!("{}/redirect-uris", env(tenant_id, environment_id)),
                Some(&body),
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

    pub async fn revoke_session(
        &self,
        environment_id: &str,
        session_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "/v1/environments/{}/sessions/{}",
                    environment_id, session_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn totp_status(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/me/mfa/totp", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn bulk_delete(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/users/bulk/delete", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn bulk_set_active(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/users/bulk/set-active", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn import_users(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/users/import", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn disable_mfa(
        &self,
        tenant_id: &str,
        environment_id: &str,
        user_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!("{}/users/{}/mfa", env(tenant_id, environment_id), user_id),
                None,
                &[],
            )
            .await
    }

    pub async fn list_sessions(
        &self,
        tenant_id: &str,
        environment_id: &str,
        user_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!(
                    "{}/users/{}/sessions",
                    env(tenant_id, environment_id),
                    user_id
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

/// AuthZEN discovery and evaluation namespace.
pub struct AuthzenResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> AuthzenResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn configuration(&self) -> Result<Value, AuthdogError> {
        self.client
            .request_with_auth(
                "GET",
                "/.well-known/authzen-configuration",
                None,
                &[],
                None,
                true,
            )
            .await
    }

    pub async fn evaluate(
        &self,
        body: impl Serialize,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request_with_auth(
                "POST",
                "/access/v1/evaluation",
                Some(&body),
                &[],
                pick_token(token, self.client.environment_secret()),
                false,
            )
            .await
    }

    pub async fn evaluate_batch(
        &self,
        body: impl Serialize,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request_with_auth(
                "POST",
                "/access/v1/evaluations",
                Some(&body),
                &[],
                pick_token(token, self.client.environment_secret()),
                false,
            )
            .await
    }

    pub async fn search_action(
        &self,
        body: impl Serialize,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request_with_auth(
                "POST",
                "/access/v1/search/action",
                Some(&body),
                &[],
                pick_token(token, self.client.environment_secret()),
                false,
            )
            .await
    }

    pub async fn search_resource(
        &self,
        body: impl Serialize,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request_with_auth(
                "POST",
                "/access/v1/search/resource",
                Some(&body),
                &[],
                pick_token(token, self.client.environment_secret()),
                false,
            )
            .await
    }

    pub async fn search_subject(
        &self,
        body: impl Serialize,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request_with_auth(
                "POST",
                "/access/v1/search/subject",
                Some(&body),
                &[],
                pick_token(token, self.client.environment_secret()),
                false,
            )
            .await
    }
}

/// SCIM 2.0 namespace. Uses `scim_token` when set.
pub struct ScimResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> ScimResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    async fn send(
        &self,
        method: &str,
        path: &str,
        body: Option<&Value>,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request_with_auth(
                method,
                path,
                body,
                &[],
                token.or(self.client.scim_token()),
                false,
            )
            .await
    }

    pub async fn list_users(&self, token: Option<&str>) -> Result<Value, AuthdogError> {
        self.send("GET", "/v1/scim/v2/Users", None, token).await
    }

    pub async fn create_user(
        &self,
        body: impl Serialize,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.send("POST", "/v1/scim/v2/Users", Some(&body), token)
            .await
    }

    pub async fn get_user(
        &self,
        user_id: &str,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        self.send(
            "GET",
            &format!("/v1/scim/v2/Users/{}", user_id),
            None,
            token,
        )
        .await
    }

    pub async fn replace_user(
        &self,
        user_id: &str,
        body: impl Serialize,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.send(
            "PUT",
            &format!("/v1/scim/v2/Users/{}", user_id),
            Some(&body),
            token,
        )
        .await
    }

    pub async fn patch_user(
        &self,
        user_id: &str,
        body: impl Serialize,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.send(
            "PATCH",
            &format!("/v1/scim/v2/Users/{}", user_id),
            Some(&body),
            token,
        )
        .await
    }

    pub async fn delete_user(
        &self,
        user_id: &str,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        self.send(
            "DELETE",
            &format!("/v1/scim/v2/Users/{}", user_id),
            None,
            token,
        )
        .await
    }

    pub async fn list_groups(&self, token: Option<&str>) -> Result<Value, AuthdogError> {
        self.send("GET", "/v1/scim/v2/Groups", None, token).await
    }

    pub async fn create_group(
        &self,
        body: impl Serialize,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.send("POST", "/v1/scim/v2/Groups", Some(&body), token)
            .await
    }

    pub async fn get_group(
        &self,
        group_id: &str,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        self.send(
            "GET",
            &format!("/v1/scim/v2/Groups/{}", group_id),
            None,
            token,
        )
        .await
    }

    pub async fn replace_group(
        &self,
        group_id: &str,
        body: impl Serialize,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.send(
            "PUT",
            &format!("/v1/scim/v2/Groups/{}", group_id),
            Some(&body),
            token,
        )
        .await
    }

    pub async fn patch_group(
        &self,
        group_id: &str,
        body: impl Serialize,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.send(
            "PATCH",
            &format!("/v1/scim/v2/Groups/{}", group_id),
            Some(&body),
            token,
        )
        .await
    }

    pub async fn delete_group(
        &self,
        group_id: &str,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        self.send(
            "DELETE",
            &format!("/v1/scim/v2/Groups/{}", group_id),
            None,
            token,
        )
        .await
    }

    pub async fn resource_types(&self, token: Option<&str>) -> Result<Value, AuthdogError> {
        self.send("GET", "/v1/scim/v2/ResourceTypes", None, token)
            .await
    }

    pub async fn resource_type(
        &self,
        type_id: &str,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        self.send(
            "GET",
            &format!("/v1/scim/v2/ResourceTypes/{}", type_id),
            None,
            token,
        )
        .await
    }

    pub async fn schemas(&self, token: Option<&str>) -> Result<Value, AuthdogError> {
        self.send("GET", "/v1/scim/v2/Schemas", None, token).await
    }

    pub async fn schema(
        &self,
        schema_id: &str,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        self.send(
            "GET",
            &format!("/v1/scim/v2/Schemas/{}", schema_id),
            None,
            token,
        )
        .await
    }

    pub async fn service_provider_config(
        &self,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        self.send("GET", "/v1/scim/v2/ServiceProviderConfig", None, token)
            .await
    }
}

/// HRIS namespace. Uses `hris_token` when set.
pub struct HrisResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> HrisResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    async fn send(
        &self,
        method: &str,
        path: &str,
        body: Option<&Value>,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request_with_auth(
                method,
                path,
                body,
                &[],
                token.or(self.client.hris_token()),
                false,
            )
            .await
    }

    pub async fn list_departments(&self, token: Option<&str>) -> Result<Value, AuthdogError> {
        self.send("GET", "/v1/hris/v1/Departments", None, token)
            .await
    }

    pub async fn create_department(
        &self,
        body: impl Serialize,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.send("POST", "/v1/hris/v1/Departments", Some(&body), token)
            .await
    }

    pub async fn get_department(
        &self,
        department_id: &str,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        self.send(
            "GET",
            &format!("/v1/hris/v1/Departments/{}", department_id),
            None,
            token,
        )
        .await
    }

    pub async fn replace_department(
        &self,
        department_id: &str,
        body: impl Serialize,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.send(
            "PUT",
            &format!("/v1/hris/v1/Departments/{}", department_id),
            Some(&body),
            token,
        )
        .await
    }

    pub async fn patch_department(
        &self,
        department_id: &str,
        body: impl Serialize,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.send(
            "PATCH",
            &format!("/v1/hris/v1/Departments/{}", department_id),
            Some(&body),
            token,
        )
        .await
    }

    pub async fn delete_department(
        &self,
        department_id: &str,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        self.send(
            "DELETE",
            &format!("/v1/hris/v1/Departments/{}", department_id),
            None,
            token,
        )
        .await
    }

    pub async fn list_employees(&self, token: Option<&str>) -> Result<Value, AuthdogError> {
        self.send("GET", "/v1/hris/v1/Employees", None, token).await
    }

    pub async fn create_employee(
        &self,
        body: impl Serialize,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.send("POST", "/v1/hris/v1/Employees", Some(&body), token)
            .await
    }

    pub async fn get_employee(
        &self,
        employee_id: &str,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        self.send(
            "GET",
            &format!("/v1/hris/v1/Employees/{}", employee_id),
            None,
            token,
        )
        .await
    }

    pub async fn replace_employee(
        &self,
        employee_id: &str,
        body: impl Serialize,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.send(
            "PUT",
            &format!("/v1/hris/v1/Employees/{}", employee_id),
            Some(&body),
            token,
        )
        .await
    }

    pub async fn patch_employee(
        &self,
        employee_id: &str,
        body: impl Serialize,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.send(
            "PATCH",
            &format!("/v1/hris/v1/Employees/{}", employee_id),
            Some(&body),
            token,
        )
        .await
    }

    pub async fn delete_employee(
        &self,
        employee_id: &str,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        self.send(
            "DELETE",
            &format!("/v1/hris/v1/Employees/{}", employee_id),
            None,
            token,
        )
        .await
    }

    pub async fn service_config(&self, token: Option<&str>) -> Result<Value, AuthdogError> {
        self.send("GET", "/v1/hris/v1/ServiceConfig", None, token)
            .await
    }
}

/// MCP runtime and trust-store namespace.
pub struct McpResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> McpResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn ingest_events(
        &self,
        body: impl Serialize,
        token: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request_with_auth(
                "POST",
                "/v1/mcp/events",
                Some(&body),
                &[],
                token.or(self.client.environment_secret()),
                false,
            )
            .await
    }

    pub async fn resolve(&self, subject: &str, token: Option<&str>) -> Result<Value, AuthdogError> {
        let query = query_pairs(vec![("subject", Some(subject.to_string()))]);
        self.client
            .request_with_auth(
                "GET",
                "/v1/mcp/trust-store/resolve",
                None,
                &query,
                token.or(self.client.environment_secret()),
                false,
            )
            .await
    }

    pub async fn list_entries(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/mcp/trust-store", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn create_entry(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/mcp/trust-store", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn get_entry(
        &self,
        tenant_id: &str,
        environment_id: &str,
        entry_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!(
                    "{}/mcp/trust-store/{}",
                    env(tenant_id, environment_id),
                    entry_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn update_entry(
        &self,
        tenant_id: &str,
        environment_id: &str,
        entry_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "PATCH",
                &format!(
                    "{}/mcp/trust-store/{}",
                    env(tenant_id, environment_id),
                    entry_id
                ),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete_entry(
        &self,
        tenant_id: &str,
        environment_id: &str,
        entry_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "{}/mcp/trust-store/{}",
                    env(tenant_id, environment_id),
                    entry_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn add_key(
        &self,
        tenant_id: &str,
        environment_id: &str,
        entry_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!(
                    "{}/mcp/trust-store/{}/keys",
                    env(tenant_id, environment_id),
                    entry_id
                ),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn revoke_key(
        &self,
        tenant_id: &str,
        environment_id: &str,
        entry_id: &str,
        key_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "{}/mcp/trust-store/{}/keys/{}",
                    env(tenant_id, environment_id),
                    entry_id,
                    key_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn rotate_key(
        &self,
        tenant_id: &str,
        environment_id: &str,
        entry_id: &str,
        key_id: &str,
        body: Option<&Value>,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "{}/mcp/trust-store/{}/keys/{}/rotate",
                    env(tenant_id, environment_id),
                    entry_id,
                    key_id
                ),
                body,
                &[],
            )
            .await
    }

    pub async fn revoke_entry(
        &self,
        tenant_id: &str,
        environment_id: &str,
        entry_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "{}/mcp/trust-store/{}/revoke",
                    env(tenant_id, environment_id),
                    entry_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn verify_entry(
        &self,
        tenant_id: &str,
        environment_id: &str,
        entry_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!(
                    "{}/mcp/trust-store/{}/verify",
                    env(tenant_id, environment_id),
                    entry_id
                ),
                Some(&body),
                &[],
            )
            .await
    }
}

/// OpenTelemetry export namespace.
pub struct OtelResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> OtelResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn export_logs(&self, body: impl Serialize) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request("POST", "/v1/logs", Some(&body), &[])
            .await
    }

    pub async fn export_metrics(&self, body: impl Serialize) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request("POST", "/v1/metrics", Some(&body), &[])
            .await
    }

    pub async fn export_traces(&self, body: impl Serialize) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request("POST", "/v1/traces", Some(&body), &[])
            .await
    }

    pub async fn export_logs_prefixed(&self, body: impl Serialize) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request("POST", "/v1/otel/v1/logs", Some(&body), &[])
            .await
    }

    pub async fn export_metrics_prefixed(
        &self,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request("POST", "/v1/otel/v1/metrics", Some(&body), &[])
            .await
    }

    pub async fn export_traces_prefixed(
        &self,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request("POST", "/v1/otel/v1/traces", Some(&body), &[])
            .await
    }
}

/// Environment OIDC client namespace.
pub struct OidcClientsResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> OidcClientsResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    fn path(tenant_id: &str, application_id: &str, environment_id: &str) -> String {
        format!(
            "{}/oidc-clients",
            app_env(tenant_id, application_id, environment_id)
        )
    }

    pub async fn list(
        &self,
        tenant_id: &str,
        application_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &Self::path(tenant_id, application_id, environment_id),
                None,
                &[],
            )
            .await
    }

    pub async fn register(
        &self,
        tenant_id: &str,
        application_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &Self::path(tenant_id, application_id, environment_id),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn update(
        &self,
        tenant_id: &str,
        application_id: &str,
        environment_id: &str,
        client_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "PATCH",
                &format!(
                    "{}/{}",
                    Self::path(tenant_id, application_id, environment_id),
                    client_id
                ),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete(
        &self,
        tenant_id: &str,
        application_id: &str,
        environment_id: &str,
        client_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "{}/{}",
                    Self::path(tenant_id, application_id, environment_id),
                    client_id
                ),
                None,
                &[],
            )
            .await
    }
}

/// Environment actions namespace.
pub struct ActionsResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> ActionsResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list(&self, tenant_id: &str, environment_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/actions", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn save(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/actions", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn executions(
        &self,
        tenant_id: &str,
        environment_id: &str,
        action_id: Option<&str>,
        limit: Option<i64>,
    ) -> Result<Value, AuthdogError> {
        let query = query_pairs(vec![
            ("actionId", action_id.map(str::to_string)),
            ("limit", limit.map(|value| value.to_string())),
        ]);
        self.client
            .request(
                "GET",
                &format!("{}/actions/executions", env(tenant_id, environment_id)),
                None,
                &query,
            )
            .await
    }

    pub async fn test(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/actions/test", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete(
        &self,
        tenant_id: &str,
        environment_id: &str,
        action_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!("{}/actions/{}", env(tenant_id, environment_id), action_id),
                None,
                &[],
            )
            .await
    }
}

/// Environment add-ons namespace.
pub struct AddonsResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> AddonsResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list(&self, tenant_id: &str, environment_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/addons", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn save(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/addons", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete(
        &self,
        tenant_id: &str,
        environment_id: &str,
        provider: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!("{}/addons/{}", env(tenant_id, environment_id), provider),
                None,
                &[],
            )
            .await
    }
}

/// Environment billing namespace.
pub struct BillingResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> BillingResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list_features(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/billing/features", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn save_feature(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/billing/features", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete_feature(
        &self,
        tenant_id: &str,
        environment_id: &str,
        feature_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "{}/billing/features/{}",
                    env(tenant_id, environment_id),
                    feature_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn list_plans(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/billing/plans", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn save_plan(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/billing/plans", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete_plan(
        &self,
        tenant_id: &str,
        environment_id: &str,
        plan_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "{}/billing/plans/{}",
                    env(tenant_id, environment_id),
                    plan_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn sync_stripe(
        &self,
        tenant_id: &str,
        environment_id: &str,
        plan_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "{}/billing/plans/{}/sync-stripe",
                    env(tenant_id, environment_id),
                    plan_id
                ),
                None,
                &[],
            )
            .await
    }
}

/// Environment policy and settings namespace.
pub struct SettingsResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> SettingsResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    async fn get(
        &self,
        tenant_id: &str,
        environment_id: &str,
        suffix: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/{}", env(tenant_id, environment_id), suffix),
                None,
                &[],
            )
            .await
    }

    async fn put(
        &self,
        tenant_id: &str,
        environment_id: &str,
        suffix: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "PUT",
                &format!("{}/{}", env(tenant_id, environment_id), suffix),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn get_bot_detection_policy(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.get(tenant_id, environment_id, "bot-detection-policy")
            .await
    }

    pub async fn update_bot_detection_policy(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        self.put(tenant_id, environment_id, "bot-detection-policy", body)
            .await
    }

    pub async fn get_breached_password_policy(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.get(tenant_id, environment_id, "breached-password-policy")
            .await
    }

    pub async fn update_breached_password_policy(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        self.put(tenant_id, environment_id, "breached-password-policy", body)
            .await
    }

    pub async fn get_brute_force_policy(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.get(tenant_id, environment_id, "brute-force-policy")
            .await
    }

    pub async fn update_brute_force_policy(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        self.put(tenant_id, environment_id, "brute-force-policy", body)
            .await
    }

    pub async fn get_device_risk_policy(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.get(tenant_id, environment_id, "device-risk-policy")
            .await
    }

    pub async fn update_device_risk_policy(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        self.put(tenant_id, environment_id, "device-risk-policy", body)
            .await
    }

    pub async fn list_jwt_claim_mappings(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.get(tenant_id, environment_id, "jwt-claim-mappings")
            .await
    }

    pub async fn save_jwt_claim_mapping(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/jwt-claim-mappings", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete_jwt_claim_mapping(
        &self,
        tenant_id: &str,
        environment_id: &str,
        mapping_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "{}/jwt-claim-mappings/{}",
                    env(tenant_id, environment_id),
                    mapping_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn get_password_policy(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.get(tenant_id, environment_id, "password-policy").await
    }

    pub async fn update_password_policy(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        self.put(tenant_id, environment_id, "password-policy", body)
            .await
    }

    pub async fn get_rate_limit_policy(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.get(tenant_id, environment_id, "rate-limit-policy")
            .await
    }

    pub async fn update_rate_limit_policy(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        self.put(tenant_id, environment_id, "rate-limit-policy", body)
            .await
    }

    pub async fn get_restrictions(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.get(tenant_id, environment_id, "restrictions").await
    }

    pub async fn update_restrictions(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        self.put(tenant_id, environment_id, "restrictions", body)
            .await
    }

    pub async fn get_session_config(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.get(tenant_id, environment_id, "session-config").await
    }

    pub async fn update_session_config(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        self.put(tenant_id, environment_id, "session-config", body)
            .await
    }
}

/// Just-in-time elevate namespace.
pub struct ElevateResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> ElevateResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn activate_grant(
        &self,
        tenant_id: &str,
        environment_id: &str,
        grant_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!(
                    "{}/elevate/access-grants/{}/activate",
                    env(tenant_id, environment_id),
                    grant_id
                ),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn revoke_grant(
        &self,
        tenant_id: &str,
        environment_id: &str,
        grant_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!(
                    "{}/elevate/access-grants/{}/revoke",
                    env(tenant_id, environment_id),
                    grant_id
                ),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn list_requests(
        &self,
        tenant_id: &str,
        environment_id: &str,
        status: Option<&str>,
    ) -> Result<Value, AuthdogError> {
        let query = query_pairs(vec![("status", status.map(str::to_string))]);
        self.client
            .request(
                "GET",
                &format!("{}/elevate/access-requests", env(tenant_id, environment_id)),
                None,
                &query,
            )
            .await
    }

    pub async fn create_request(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/elevate/access-requests", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn get_request(
        &self,
        tenant_id: &str,
        environment_id: &str,
        request_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!(
                    "{}/elevate/access-requests/{}",
                    env(tenant_id, environment_id),
                    request_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn approve_request(
        &self,
        tenant_id: &str,
        environment_id: &str,
        request_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!(
                    "{}/elevate/access-requests/{}/approve",
                    env(tenant_id, environment_id),
                    request_id
                ),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn cancel_request(
        &self,
        tenant_id: &str,
        environment_id: &str,
        request_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "{}/elevate/access-requests/{}/cancel",
                    env(tenant_id, environment_id),
                    request_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn deny_request(
        &self,
        tenant_id: &str,
        environment_id: &str,
        request_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!(
                    "{}/elevate/access-requests/{}/deny",
                    env(tenant_id, environment_id),
                    request_id
                ),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn get_policy(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/elevate/policy", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn update_policy(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "PUT",
                &format!("{}/elevate/policy", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }
}

/// Environment email provider namespace.
pub struct EmailProvidersResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> EmailProvidersResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list(&self, tenant_id: &str, environment_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/email-providers", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn save(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/email-providers", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn test(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/email-providers/test", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete(
        &self,
        tenant_id: &str,
        environment_id: &str,
        provider: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "{}/email-providers/{}",
                    env(tenant_id, environment_id),
                    provider
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn activate(
        &self,
        tenant_id: &str,
        environment_id: &str,
        provider: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "{}/email-providers/{}/activate",
                    env(tenant_id, environment_id),
                    provider
                ),
                None,
                &[],
            )
            .await
    }
}

/// Environment feature-flag namespace.
pub struct FeatureFlagsResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> FeatureFlagsResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list(&self, tenant_id: &str, environment_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/feature-flags", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn save(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/feature-flags", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete(
        &self,
        tenant_id: &str,
        environment_id: &str,
        flag_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "{}/feature-flags/{}",
                    env(tenant_id, environment_id),
                    flag_id
                ),
                None,
                &[],
            )
            .await
    }
}

/// Environment forms namespace.
pub struct FormsResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> FormsResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list_attachments(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/form-attachments", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn list(&self, tenant_id: &str, environment_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/forms", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn save(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/forms", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete(
        &self,
        tenant_id: &str,
        environment_id: &str,
        form_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!("{}/forms/{}", env(tenant_id, environment_id), form_id),
                None,
                &[],
            )
            .await
    }
}

/// SCIM and HRIS provisioning token namespace.
pub struct ProvisioningTokensResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> ProvisioningTokensResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list_hris(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/hris-tokens", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn create_hris(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/hris-tokens", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn revoke_hris(
        &self,
        tenant_id: &str,
        environment_id: &str,
        token_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "{}/hris-tokens/{}/revoke",
                    env(tenant_id, environment_id),
                    token_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn rotate_hris(
        &self,
        tenant_id: &str,
        environment_id: &str,
        token_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "{}/hris-tokens/{}/rotate",
                    env(tenant_id, environment_id),
                    token_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn list_scim(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/scim-tokens", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }

    pub async fn create_scim(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/scim-tokens", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn revoke_scim(
        &self,
        tenant_id: &str,
        environment_id: &str,
        token_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "{}/scim-tokens/{}/revoke",
                    env(tenant_id, environment_id),
                    token_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn rotate_scim(
        &self,
        tenant_id: &str,
        environment_id: &str,
        token_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "{}/scim-tokens/{}/rotate",
                    env(tenant_id, environment_id),
                    token_id
                ),
                None,
                &[],
            )
            .await
    }
}

/// Impersonation grant namespace.
pub struct ImpersonationResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> ImpersonationResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list(&self, tenant_id: &str, environment_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/impersonation-grants", env(tenant_id, environment_id)),
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
                &format!("{}/impersonation-grants", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn revoke(
        &self,
        tenant_id: &str,
        environment_id: &str,
        grant_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "{}/impersonation-grants/{}/revoke",
                    env(tenant_id, environment_id),
                    grant_id
                ),
                None,
                &[],
            )
            .await
    }
}

/// User portal namespace.
pub struct PortalResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> PortalResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn generate_link(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/portal/generate-link", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }
}

/// Security posture namespace.
pub struct SecurityResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> SecurityResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn posture(
        &self,
        tenant_id: &str,
        environment_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/security/posture", env(tenant_id, environment_id)),
                None,
                &[],
            )
            .await
    }
}

/// Threats namespace.
pub struct ThreatsResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> ThreatsResource<'a> {
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
                &format!("{}/threats", env(tenant_id, environment_id)),
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
                &format!("{}/threats", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn get(
        &self,
        tenant_id: &str,
        environment_id: &str,
        threat_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/threats/{}", env(tenant_id, environment_id), threat_id),
                None,
                &[],
            )
            .await
    }

    pub async fn update(
        &self,
        tenant_id: &str,
        environment_id: &str,
        threat_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "PATCH",
                &format!("{}/threats/{}", env(tenant_id, environment_id), threat_id),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete(
        &self,
        tenant_id: &str,
        environment_id: &str,
        threat_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!("{}/threats/{}", env(tenant_id, environment_id), threat_id),
                None,
                &[],
            )
            .await
    }

    pub async fn resolve(
        &self,
        tenant_id: &str,
        environment_id: &str,
        threat_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!(
                    "{}/threats/{}/resolve",
                    env(tenant_id, environment_id),
                    threat_id
                ),
                Some(&body),
                &[],
            )
            .await
    }
}

/// Environment vanity domain namespace.
pub struct VanityDomainsResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> VanityDomainsResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn list(&self, tenant_id: &str, environment_id: &str) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "GET",
                &format!("{}/vanity-domains", env(tenant_id, environment_id)),
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
                &format!("{}/vanity-domains", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }

    pub async fn delete(
        &self,
        tenant_id: &str,
        environment_id: &str,
        domain_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "DELETE",
                &format!(
                    "{}/vanity-domains/{}",
                    env(tenant_id, environment_id),
                    domain_id
                ),
                None,
                &[],
            )
            .await
    }

    pub async fn check(
        &self,
        tenant_id: &str,
        environment_id: &str,
        domain_id: &str,
    ) -> Result<Value, AuthdogError> {
        self.client
            .request(
                "POST",
                &format!(
                    "{}/vanity-domains/{}/check",
                    env(tenant_id, environment_id),
                    domain_id
                ),
                None,
                &[],
            )
            .await
    }
}

/// Widget token namespace.
pub struct WidgetsResource<'a> {
    client: &'a AuthdogClient,
}

impl<'a> WidgetsResource<'a> {
    pub(crate) fn new(client: &'a AuthdogClient) -> Self {
        Self { client }
    }

    pub async fn create_token(
        &self,
        tenant_id: &str,
        environment_id: &str,
        body: impl Serialize,
    ) -> Result<Value, AuthdogError> {
        let body = to_value(body)?;
        self.client
            .request(
                "POST",
                &format!("{}/widgets/token", env(tenant_id, environment_id)),
                Some(&body),
                &[],
            )
            .await
    }
}
