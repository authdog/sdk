use crate::error::{AuthdogError, AuthenticationError, APIError};
use crate::types::{UserInfoResponse, ErrorResponse};
use reqwest::Client;
use serde_json;
use std::time::Duration;

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
        let mut client_builder = Client::builder()
            .user_agent("authdog-rust-sdk/0.1.0");

        if let Some(timeout) = config.timeout {
            client_builder = client_builder.timeout(timeout);
        }

        let client = client_builder.build()
            .map_err(|e| AuthdogError::new(format!("Failed to create HTTP client: {}", e)))?;

        Ok(Self { client, config })
    }

    /// Get user information using an access token
    pub async fn get_user_info(&self, access_token: &str) -> Result<UserInfoResponse, AuthdogError> {
        let url = format!("{}/v1/userinfo", self.config.base_url.trim_end_matches('/'));
        
        let mut request = self.client
            .get(&url)
            .header("Content-Type", "application/json")
            .header("Authorization", format!("Bearer {}", access_token));

        // Add API key if provided
        if let Some(api_key) = &self.config.api_key {
            request = request.header("Authorization", format!("Bearer {}", api_key));
        }

        let response = request.send().await
            .map_err(|e| AuthdogError::new(format!("Request failed: {}", e)))?;

        let status = response.status();
        let body = response.text().await
            .map_err(|e| AuthdogError::new(format!("Failed to read response body: {}", e)))?;

        match status.as_u16() {
            200 => {
                serde_json::from_str::<UserInfoResponse>(&body)
                    .map_err(|e| AuthdogError::new(format!("Failed to parse response: {}", e)))
            }
            401 => Err(AuthenticationError::new("Unauthorized - invalid or expired token")),
            500 => {
                match serde_json::from_str::<ErrorResponse>(&body) {
                    Ok(error_response) => {
                        match error_response.error.as_str() {
                            "GraphQL query failed" => Err(APIError::new("GraphQL query failed")),
                            "Failed to fetch user info" => Err(APIError::new("Failed to fetch user info")),
                            _ => Err(APIError::new(format!("HTTP error 500: {}", body))),
                        }
                    }
                    Err(_) => Err(APIError::new(format!("HTTP error 500: {}", body))),
                }
            }
            _ => Err(APIError::new(format!("HTTP error {}: {}", status.as_u16(), body))),
        }
    }
}

impl Drop for AuthdogClient {
    fn drop(&mut self) {
        // HTTP client doesn't require explicit cleanup in Rust
    }
}
