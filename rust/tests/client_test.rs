use authdog::{AuthdogClient, AuthdogClientConfig, AuthdogError, AuthenticationError, APIError};
use mockito::{mock, server_url, Matcher};
use serde_json::json;
use std::time::Duration;
use tokio_test;

#[tokio::test]
async fn test_client_constructor_with_base_url() {
    let config = AuthdogClientConfig {
        base_url: "https://api.authdog.com".to_string(),
        api_key: None,
        timeout: Some(Duration::from_secs(10)),
    };
    
    let client = AuthdogClient::new(config);
    assert!(client.is_ok());
}

#[tokio::test]
async fn test_client_constructor_with_trailing_slash() {
    let config = AuthdogClientConfig {
        base_url: "https://api.authdog.com/".to_string(),
        api_key: None,
        timeout: Some(Duration::from_secs(10)),
    };
    
    let client = AuthdogClient::new(config);
    assert!(client.is_ok());
}

#[tokio::test]
async fn test_client_constructor_with_api_key() {
    let config = AuthdogClientConfig {
        base_url: "https://api.authdog.com".to_string(),
        api_key: Some("test-api-key".to_string()),
        timeout: Some(Duration::from_secs(10)),
    };
    
    let client = AuthdogClient::new(config);
    assert!(client.is_ok());
}

#[tokio::test]
async fn test_client_constructor_with_timeout() {
    let config = AuthdogClientConfig {
        base_url: "https://api.authdog.com".to_string(),
        api_key: None,
        timeout: Some(Duration::from_secs(30)),
    };
    
    let client = AuthdogClient::new(config);
    assert!(client.is_ok());
}

#[tokio::test]
async fn test_client_constructor_without_timeout() {
    let config = AuthdogClientConfig {
        base_url: "https://api.authdog.com".to_string(),
        api_key: None,
        timeout: None,
    };
    
    let client = AuthdogClient::new(config);
    assert!(client.is_ok());
}

#[tokio::test]
async fn test_get_user_info_with_valid_token() {
    let mock_response = json!({
        "meta": {
            "code": 200,
            "message": "Success"
        },
        "session": {
            "remainingSeconds": 3600
        },
        "user": {
            "id": "user123",
            "externalId": "ext123",
            "userName": "testuser",
            "displayName": "Test User",
            "nickName": "test",
            "profileUrl": "https://example.com/profile",
            "title": "Developer",
            "userType": "employee",
            "preferredLanguage": "en",
            "locale": "en-US",
            "timezone": "UTC",
            "active": true,
            "names": {
                "id": "name123",
                "formatted": "Test User",
                "familyName": "User",
                "givenName": "Test",
                "middleName": "Middle",
                "honorificPrefix": "Mr.",
                "honorificSuffix": "Jr."
            },
            "photos": [
                {
                    "id": "photo123",
                    "value": "https://example.com/photo.jpg",
                    "type": "profile"
                }
            ],
            "phoneNumbers": [],
            "addresses": [],
            "emails": [
                {
                    "id": "email123",
                    "value": "test@example.com",
                    "type": "work"
                }
            ],
            "verifications": [
                {
                    "id": "verification123",
                    "email": "test@example.com",
                    "verified": true,
                    "createdAt": "2023-01-01T00:00:00Z",
                    "updatedAt": "2023-01-01T00:00:00Z"
                }
            ],
            "provider": "test",
            "createdAt": "2023-01-01T00:00:00Z",
            "updatedAt": "2023-01-01T00:00:00Z",
            "environmentId": "env123"
        }
    });

    let _mock = mock("GET", "/v1/userinfo")
        .with_status(200)
        .with_header("content-type", "application/json")
        .with_body(mock_response.to_string())
        .create();

    let config = AuthdogClientConfig {
        base_url: server_url(),
        api_key: None,
        timeout: Some(Duration::from_secs(10)),
    };

    let client = AuthdogClient::new(config).unwrap();
    let result = client.get_user_info("valid-token").await;

    assert!(result.is_ok());
    let user_info = result.unwrap();
    assert_eq!(user_info.user.id, "user123");
    assert_eq!(user_info.user.user_name, "testuser");
    assert_eq!(user_info.user.display_name, "Test User");
    assert_eq!(user_info.meta.code, 200);
    assert_eq!(user_info.session.remaining_seconds, 3600);
}

#[tokio::test]
async fn test_get_user_info_with_unauthorized_response() {
    let _mock = mock("GET", "/v1/userinfo")
        .with_status(401)
        .with_header("content-type", "application/json")
        .with_body("Unauthorized")
        .create();

    let config = AuthdogClientConfig {
        base_url: server_url(),
        api_key: None,
        timeout: Some(Duration::from_secs(10)),
    };

    let client = AuthdogClient::new(config).unwrap();
    let result = client.get_user_info("invalid-token").await;

    assert!(result.is_err());
    let error = result.unwrap_err();
    assert!(error.to_string().contains("Unauthorized"));
}

#[tokio::test]
async fn test_get_user_info_with_graphql_error() {
    let error_response = json!({
        "error": "GraphQL query failed"
    });

    let _mock = mock("GET", "/v1/userinfo")
        .with_status(500)
        .with_header("content-type", "application/json")
        .with_body(error_response.to_string())
        .create();

    let config = AuthdogClientConfig {
        base_url: server_url(),
        api_key: None,
        timeout: Some(Duration::from_secs(10)),
    };

    let client = AuthdogClient::new(config).unwrap();
    let result = client.get_user_info("token").await;

    assert!(result.is_err());
    let error = result.unwrap_err();
    assert!(error.to_string().contains("GraphQL query failed"));
}

#[tokio::test]
async fn test_get_user_info_with_fetch_error() {
    let error_response = json!({
        "error": "Failed to fetch user info"
    });

    let _mock = mock("GET", "/v1/userinfo")
        .with_status(500)
        .with_header("content-type", "application/json")
        .with_body(error_response.to_string())
        .create();

    let config = AuthdogClientConfig {
        base_url: server_url(),
        api_key: None,
        timeout: Some(Duration::from_secs(10)),
    };

    let client = AuthdogClient::new(config).unwrap();
    let result = client.get_user_info("token").await;

    assert!(result.is_err());
    let error = result.unwrap_err();
    assert!(error.to_string().contains("Failed to fetch user info"));
}

#[tokio::test]
async fn test_get_user_info_with_non_success_status_code() {
    let _mock = mock("GET", "/v1/userinfo")
        .with_status(404)
        .with_header("content-type", "application/json")
        .with_body("Not Found")
        .create();

    let config = AuthdogClientConfig {
        base_url: server_url(),
        api_key: None,
        timeout: Some(Duration::from_secs(10)),
    };

    let client = AuthdogClient::new(config).unwrap();
    let result = client.get_user_info("token").await;

    assert!(result.is_err());
    let error = result.unwrap_err();
    assert!(error.to_string().contains("HTTP error 404"));
}

#[tokio::test]
async fn test_get_user_info_with_invalid_json() {
    let _mock = mock("GET", "/v1/userinfo")
        .with_status(200)
        .with_header("content-type", "application/json")
        .with_body("invalid json")
        .create();

    let config = AuthdogClientConfig {
        base_url: server_url(),
        api_key: None,
        timeout: Some(Duration::from_secs(10)),
    };

    let client = AuthdogClient::new(config).unwrap();
    let result = client.get_user_info("token").await;

    assert!(result.is_err());
    let error = result.unwrap_err();
    assert!(error.to_string().contains("Failed to parse response"));
}

#[tokio::test]
async fn test_get_user_info_sets_correct_headers() {
    let mock_response = json!({
        "meta": {
            "code": 200,
            "message": "Success"
        },
        "session": {
            "remainingSeconds": 3600
        },
        "user": {
            "id": "user123",
            "externalId": "ext123",
            "userName": "testuser",
            "displayName": "Test User",
            "locale": "en-US",
            "active": true,
            "names": {
                "id": "name123",
                "familyName": "User",
                "givenName": "Test"
            },
            "photos": [],
            "phoneNumbers": [],
            "addresses": [],
            "emails": [],
            "verifications": [],
            "provider": "test",
            "createdAt": "2023-01-01T00:00:00Z",
            "updatedAt": "2023-01-01T00:00:00Z",
            "environmentId": "env123"
        }
    });

    let _mock = mock("GET", "/v1/userinfo")
        .match_header("authorization", "Bearer test-token")
        .match_header("content-type", "application/json")
        .match_header("user-agent", "authdog-rust-sdk/0.1.0")
        .with_status(200)
        .with_header("content-type", "application/json")
        .with_body(mock_response.to_string())
        .create();

    let config = AuthdogClientConfig {
        base_url: server_url(),
        api_key: None,
        timeout: Some(Duration::from_secs(10)),
    };

    let client = AuthdogClient::new(config).unwrap();
    let result = client.get_user_info("test-token").await;

    assert!(result.is_ok());
}

#[tokio::test]
async fn test_get_user_info_with_api_key() {
    let mock_response = json!({
        "meta": {
            "code": 200,
            "message": "Success"
        },
        "session": {
            "remainingSeconds": 3600
        },
        "user": {
            "id": "user123",
            "externalId": "ext123",
            "userName": "testuser",
            "displayName": "Test User",
            "locale": "en-US",
            "active": true,
            "names": {
                "id": "name123",
                "familyName": "User",
                "givenName": "Test"
            },
            "photos": [],
            "phoneNumbers": [],
            "addresses": [],
            "emails": [],
            "verifications": [],
            "provider": "test",
            "createdAt": "2023-01-01T00:00:00Z",
            "updatedAt": "2023-01-01T00:00:00Z",
            "environmentId": "env123"
        }
    });

    let _mock = mock("GET", "/v1/userinfo")
        .match_header("authorization", "Bearer test-api-key")
        .with_status(200)
        .with_header("content-type", "application/json")
        .with_body(mock_response.to_string())
        .create();

    let config = AuthdogClientConfig {
        base_url: server_url(),
        api_key: Some("test-api-key".to_string()),
        timeout: Some(Duration::from_secs(10)),
    };

    let client = AuthdogClient::new(config).unwrap();
    let result = client.get_user_info("access-token").await;

    assert!(result.is_ok());
}
