use crate::error::{APIError, AuthdogError, AuthenticationError};
use crate::types::{ErrorResponse, Probe, UserInfoResponse};
use reqwest::{Client, Method};
use serde::de::DeserializeOwned;
use serde_json::{self, Value};
use std::time::Duration;

pub use crate::resources::{
    ActionsResource, AddonsResource, ApiSecretsResource, AuditResource, AuthzenResource,
    BillingResource, ElevateResource, EmailProvidersResource, EnvironmentsResource, EventsResource,
    FeatureFlagsResource, FormsResource, GroupsResource, HrisResource, ImpersonationResource,
    McpResource, NotificationChannelsResource, OidcClientsResource, OrganizationsResource,
    OtelResource, PersonalAccessTokensResource, PortalResource, ProjectsResource,
    ProvisioningTokensResource, RbacResource, ScimResource, SecurityResource,
    ServiceAccountsResource, SettingsResource, TenantsResource, ThreatsResource, UsersResource,
    VanityDomainsResource, WebhooksResource, WidgetsResource,
};

/// Configuration for the Authdog client
#[derive(Debug, Clone)]
pub struct AuthdogClientConfig {
    pub base_url: String,
    pub api_key: Option<String>,
    pub timeout: Option<Duration>,
    pub environment_secret: Option<String>,
    pub scim_token: Option<String>,
    pub hris_token: Option<String>,
}

impl Default for AuthdogClientConfig {
    fn default() -> Self {
        Self {
            base_url: "https://api.authdog.com".to_string(),
            api_key: None,
            timeout: Some(Duration::from_secs(10)),
            environment_secret: None,
            scim_token: None,
            hris_token: None,
        }
    }
}

/// Main client for interacting with Authdog API
pub struct AuthdogClient {
    client: Client,
    config: AuthdogClientConfig,
}

impl AuthdogClient {
    /// Create a new Authdog client
    pub fn new(config: AuthdogClientConfig) -> Result<Self, AuthdogError> {
        let mut client_builder = Client::builder().user_agent("authdog-rust-sdk/0.1.0");

        if let Some(timeout) = config.timeout {
            client_builder = client_builder.timeout(timeout);
        }

        let client = client_builder
            .build()
            .map_err(|e| AuthdogError::new(format!("Failed to create HTTP client: {}", e)))?;

        Ok(Self { client, config })
    }

    fn base_url(&self) -> &str {
        self.config.base_url.trim_end_matches('/')
    }

    pub(crate) fn environment_secret(&self) -> Option<&str> {
        self.config.environment_secret.as_deref()
    }

    pub(crate) fn scim_token(&self) -> Option<&str> {
        self.config.scim_token.as_deref()
    }

    pub(crate) fn hris_token(&self) -> Option<&str> {
        self.config.hris_token.as_deref()
    }

    /// Send a JSON request and map HTTP failures onto the error taxonomy.
    ///
    /// Constructor `api_key` is sent as `Authorization: Bearer`. Per-call
    /// `get_user_info` remains a separate path so the access token still wins.
    /// `omit_auth` sends no Authorization header (AuthZEN discovery).
    /// `access_token` overrides the constructor key when present.
    pub(crate) async fn request(
        &self,
        method: &str,
        path: &str,
        body: Option<&Value>,
        query: &[(String, String)],
    ) -> Result<Value, AuthdogError> {
        self.request_inner(method, path, body, query, None, false)
            .await
    }

    pub(crate) async fn request_with_auth(
        &self,
        method: &str,
        path: &str,
        body: Option<&Value>,
        query: &[(String, String)],
        access_token: Option<&str>,
        omit_auth: bool,
    ) -> Result<Value, AuthdogError> {
        self.request_inner(method, path, body, query, access_token, omit_auth)
            .await
    }

    async fn request_inner(
        &self,
        method: &str,
        path: &str,
        body: Option<&Value>,
        query: &[(String, String)],
        access_token: Option<&str>,
        omit_auth: bool,
    ) -> Result<Value, AuthdogError> {
        let url = format!("{}{}", self.base_url(), path);
        let http_method = Method::from_bytes(method.as_bytes())
            .map_err(|_| AuthdogError::new(format!("Unsupported HTTP method: {}", method)))?;

        let mut request = self
            .client
            .request(http_method, &url)
            .header("Content-Type", "application/json");

        if omit_auth {
            // AuthZEN discovery: do not send Authorization.
        } else if let Some(token) = access_token {
            request = request.header("Authorization", format!("Bearer {}", token));
        } else if let Some(api_key) = &self.config.api_key {
            request = request.header("Authorization", format!("Bearer {}", api_key));
        }

        if !query.is_empty() {
            request = request.query(query);
        }

        if let Some(json_body) = body {
            request = request.json(json_body);
        }

        let response = request
            .send()
            .await
            .map_err(|e| APIError::new(format!("Request failed: {}", e)))?;

        let status = response.status();
        let text = response
            .text()
            .await
            .map_err(|e| APIError::new(format!("Request failed: {}", e)))?;

        if status.as_u16() == 401 {
            return Err(AuthenticationError::new(
                "Unauthorized - invalid or expired token".to_string(),
            )
            .into());
        }

        if !status.is_success() {
            let error_text = serde_json::from_str::<ErrorResponse>(&text)
                .ok()
                .map(|payload| payload.error)
                .filter(|error| !error.is_empty())
                .unwrap_or(text);
            return Err(APIError::with_status(status.as_u16(), error_text).into());
        }

        if text.trim().is_empty() {
            return Ok(Value::Object(serde_json::Map::new()));
        }

        serde_json::from_str(&text)
            .map_err(|_| APIError::new("Failed to parse response: invalid JSON".to_string()).into())
    }

    pub(crate) async fn request_parsed<T: DeserializeOwned>(
        &self,
        method: &str,
        path: &str,
        body: Option<&Value>,
        query: &[(String, String)],
    ) -> Result<T, AuthdogError> {
        self.request_parsed_with_auth(method, path, body, query, None, false)
            .await
    }

    pub(crate) async fn request_parsed_with_auth<T: DeserializeOwned>(
        &self,
        method: &str,
        path: &str,
        body: Option<&Value>,
        query: &[(String, String)],
        access_token: Option<&str>,
        omit_auth: bool,
    ) -> Result<T, AuthdogError> {
        let value = self
            .request_inner(method, path, body, query, access_token, omit_auth)
            .await?;
        serde_json::from_value(value)
            .map_err(|e| APIError::new(format!("Failed to parse response: {}", e)).into())
    }

    /// Liveness probe. Public; works without a management credential.
    pub async fn health(&self) -> Result<Probe, AuthdogError> {
        self.request_parsed("GET", "/v1/health", None, &[]).await
    }

    pub fn organizations(&self) -> OrganizationsResource<'_> {
        OrganizationsResource::new(self)
    }

    pub fn tenants(&self) -> TenantsResource<'_> {
        TenantsResource::new(self)
    }

    pub fn projects(&self) -> ProjectsResource<'_> {
        ProjectsResource::new(self)
    }

    pub fn environments(&self) -> EnvironmentsResource<'_> {
        EnvironmentsResource::new(self)
    }

    pub fn users(&self) -> UsersResource<'_> {
        UsersResource::new(self)
    }

    pub fn groups(&self) -> GroupsResource<'_> {
        GroupsResource::new(self)
    }

    pub fn rbac(&self) -> RbacResource<'_> {
        RbacResource::new(self)
    }

    pub fn audit(&self) -> AuditResource<'_> {
        AuditResource::new(self)
    }

    pub fn events(&self) -> EventsResource<'_> {
        EventsResource::new(self)
    }

    pub fn webhooks(&self) -> WebhooksResource<'_> {
        WebhooksResource::new(self)
    }

    pub fn notification_channels(&self) -> NotificationChannelsResource<'_> {
        NotificationChannelsResource::new(self)
    }

    pub fn service_accounts(&self) -> ServiceAccountsResource<'_> {
        ServiceAccountsResource::new(self)
    }

    pub fn personal_access_tokens(&self) -> PersonalAccessTokensResource<'_> {
        PersonalAccessTokensResource::new(self)
    }

    pub fn api_secrets(&self) -> ApiSecretsResource<'_> {
        ApiSecretsResource::new(self)
    }

    pub fn authzen(&self) -> AuthzenResource<'_> {
        AuthzenResource::new(self)
    }

    pub fn scim(&self) -> ScimResource<'_> {
        ScimResource::new(self)
    }

    pub fn hris(&self) -> HrisResource<'_> {
        HrisResource::new(self)
    }

    pub fn mcp(&self) -> McpResource<'_> {
        McpResource::new(self)
    }

    pub fn otel(&self) -> OtelResource<'_> {
        OtelResource::new(self)
    }

    pub fn oidc_clients(&self) -> OidcClientsResource<'_> {
        OidcClientsResource::new(self)
    }

    pub fn actions(&self) -> ActionsResource<'_> {
        ActionsResource::new(self)
    }

    pub fn addons(&self) -> AddonsResource<'_> {
        AddonsResource::new(self)
    }

    pub fn billing(&self) -> BillingResource<'_> {
        BillingResource::new(self)
    }

    pub fn settings(&self) -> SettingsResource<'_> {
        SettingsResource::new(self)
    }

    pub fn elevate(&self) -> ElevateResource<'_> {
        ElevateResource::new(self)
    }

    pub fn email_providers(&self) -> EmailProvidersResource<'_> {
        EmailProvidersResource::new(self)
    }

    pub fn feature_flags(&self) -> FeatureFlagsResource<'_> {
        FeatureFlagsResource::new(self)
    }

    pub fn forms(&self) -> FormsResource<'_> {
        FormsResource::new(self)
    }

    pub fn provisioning_tokens(&self) -> ProvisioningTokensResource<'_> {
        ProvisioningTokensResource::new(self)
    }

    pub fn impersonation(&self) -> ImpersonationResource<'_> {
        ImpersonationResource::new(self)
    }

    pub fn portal(&self) -> PortalResource<'_> {
        PortalResource::new(self)
    }

    pub fn security(&self) -> SecurityResource<'_> {
        SecurityResource::new(self)
    }

    pub fn threats(&self) -> ThreatsResource<'_> {
        ThreatsResource::new(self)
    }

    pub fn vanity_domains(&self) -> VanityDomainsResource<'_> {
        VanityDomainsResource::new(self)
    }

    pub fn widgets(&self) -> WidgetsResource<'_> {
        WidgetsResource::new(self)
    }

    /// Get user information using an access token
    pub async fn get_user_info(
        &self,
        access_token: &str,
    ) -> Result<UserInfoResponse, AuthdogError> {
        let url = format!("{}/v1/userinfo", self.config.base_url.trim_end_matches('/'));

        let request = self
            .client
            .get(&url)
            .header("Content-Type", "application/json")
            .header("Authorization", format!("Bearer {}", access_token));

        let response = request
            .send()
            .await
            .map_err(|e| APIError::new(format!("Request failed: {}", e)))?;

        let status = response.status();
        let body = response
            .text()
            .await
            .map_err(|e| AuthdogError::new(format!("Failed to read response body: {}", e)))?;

        match status.as_u16() {
            200 => serde_json::from_str::<UserInfoResponse>(&body)
                .map_err(|e| AuthdogError::new(format!("Failed to parse response: {}", e))),
            401 => Err(AuthenticationError::new(
                "Unauthorized - invalid or expired token".to_string(),
            )
            .into()),
            500 => match serde_json::from_str::<ErrorResponse>(&body) {
                Ok(error_response) => match error_response.error.as_str() {
                    "GraphQL query failed" => {
                        Err(APIError::new("GraphQL query failed".to_string()).into())
                    }
                    "Failed to fetch user info" => {
                        Err(APIError::new("Failed to fetch user info".to_string()).into())
                    }
                    _ => Err(APIError::new(format!("HTTP error 500: {}", body)).into()),
                },
                Err(_) => Err(APIError::new(format!("HTTP error 500: {}", body)).into()),
            },
            _ => Err(APIError::new(format!("HTTP error {}: {}", status.as_u16(), body)).into()),
        }
    }
}

impl Drop for AuthdogClient {
    fn drop(&mut self) {
        // HTTP client doesn't require explicit cleanup in Rust
    }
}
