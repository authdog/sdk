use serde::{Deserialize, Serialize};

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
    #[serde(rename = "remainingSeconds")]
    pub remaining_seconds: i32,
}

/// User information
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct User {
    pub id: String,
    #[serde(rename = "externalId")]
    pub external_id: String,
    #[serde(rename = "userName")]
    pub user_name: String,
    #[serde(rename = "displayName")]
    pub display_name: String,
    #[serde(rename = "nickName")]
    pub nick_name: Option<String>,
    #[serde(rename = "profileUrl")]
    pub profile_url: Option<String>,
    pub title: Option<String>,
    #[serde(rename = "userType")]
    pub user_type: Option<String>,
    #[serde(rename = "preferredLanguage")]
    pub preferred_language: Option<String>,
    pub locale: String,
    pub timezone: Option<String>,
    pub active: bool,
    pub names: Names,
    pub photos: Vec<Photo>,
    #[serde(rename = "phoneNumbers")]
    pub phone_numbers: Vec<serde_json::Value>,
    pub addresses: Vec<serde_json::Value>,
    pub emails: Vec<Email>,
    pub verifications: Vec<Verification>,
    pub provider: String,
    #[serde(rename = "createdAt")]
    pub created_at: String,
    #[serde(rename = "updatedAt")]
    pub updated_at: String,
    #[serde(rename = "environmentId")]
    pub environment_id: String,
}

/// User name information
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Names {
    pub id: String,
    pub formatted: Option<String>,
    #[serde(rename = "familyName")]
    pub family_name: String,
    #[serde(rename = "givenName")]
    pub given_name: String,
    #[serde(rename = "middleName")]
    pub middle_name: Option<String>,
    #[serde(rename = "honorificPrefix")]
    pub honorific_prefix: Option<String>,
    #[serde(rename = "honorificSuffix")]
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
    #[serde(rename = "createdAt")]
    pub created_at: String,
    #[serde(rename = "updatedAt")]
    pub updated_at: String,
}

/// Error response from the API
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ErrorResponse {
    pub error: String,
}
