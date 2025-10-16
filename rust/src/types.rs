use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// User information response from the /userinfo endpoint
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserInfoResponse {
    pub meta: Meta,
    pub session: Session,
    pub user: User,
}

/// Metadata in the response
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Meta {
    pub code: i32,
    pub message: String,
}

/// Session information
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Session {
    pub remaining_seconds: i32,
}

/// User information
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct User {
    pub id: String,
    #[serde(rename = "externalId")]
    pub external_id: String,
    pub user_name: String,
    pub display_name: String,
    pub nick_name: Option<String>,
    pub profile_url: Option<String>,
    pub title: Option<String>,
    pub user_type: Option<String>,
    pub preferred_language: Option<String>,
    pub locale: String,
    pub timezone: Option<String>,
    pub active: bool,
    pub names: Names,
    pub photos: Vec<Photo>,
    pub phone_numbers: Vec<serde_json::Value>,
    pub addresses: Vec<serde_json::Value>,
    pub emails: Vec<Email>,
    pub verifications: Vec<Verification>,
    pub provider: String,
    pub created_at: String,
    pub updated_at: String,
    #[serde(rename = "environmentId")]
    pub environment_id: String,
}

/// User name information
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Names {
    pub id: String,
    pub formatted: Option<String>,
    pub family_name: String,
    pub given_name: String,
    pub middle_name: Option<String>,
    pub honorific_prefix: Option<String>,
    pub honorific_suffix: Option<String>,
}

/// User photo
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Photo {
    pub id: String,
    pub value: String,
    #[serde(rename = "type")]
    pub photo_type: String,
}

/// User email
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Email {
    pub id: String,
    pub value: String,
    #[serde(rename = "type")]
    pub email_type: Option<String>,
}

/// Email verification status
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Verification {
    pub id: String,
    pub email: String,
    pub verified: bool,
    pub created_at: String,
    pub updated_at: String,
}

/// Error response from the API
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ErrorResponse {
    pub error: String,
}
