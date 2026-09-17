use crate::error::{APIError, AuthdogError, AuthenticationError};
use crate::types::{ErrorResponse, Probe, UserInfoResponse};
use reqwest::{Client, Method};
use serde::de::DeserializeOwned;
use serde_json::{self, Value};
use std::time::Duration;

pub use crate::resources::{
    EnvironmentsResource, GroupsResource, OrganizationsResource, ProjectsResource, TenantsResource,
    UsersResource,
};

/// Configuration for the Authdog client
#[derive(Debug, Clone)]
pub struct AuthdogClientConfig {
    pub base_url: String,
    pub api_key: Option<String>,
    pub timeout: Option<Duration>,
}

impl Default for AuthdogClientConfig {
    fn default() -> Self {
        Self {
            base_url: "https://api.authdog.com".to_string(),
            api_key: None,
            timeout: Some(Duration::from_secs(10)),
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

    /// Send a JSON request and map HTTP failures onto the error taxonomy.
    ///
    /// Constructor `api_key` is sent as `Authorization: Bearer`. Per-call
    /// `get_user_info` remains a separate path so the access token still wins.
    pub(crate) async fn request(
        &self,
        method: &str,
        path: &str,
        body: Option<&Value>,
        query: &[(String, String)],
    ) -> Result<Value, AuthdogError> {
        let url = format!("{}{}", self.base_url(), path);
        let http_method = Method::from_bytes(method.as_bytes())
            .map_err(|_| AuthdogError::new(format!("Unsupported HTTP method: {}", method)))?;

        let mut request = self
            .client
            .request(http_method, &url)
            .header("Content-Type", "application/json");

        if let Some(api_key) = &self.config.api_key {
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
        let value = self.request(method, path, body, query).await?;
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
