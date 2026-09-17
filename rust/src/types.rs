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

/// Liveness probe from `GET /v1/health`
#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq)]
#[serde(default)]
pub struct Probe {
    pub ok: bool,
}

/// Organization entity
#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq)]
#[serde(default, rename_all = "camelCase")]
pub struct Organization {
    pub id: String,
    pub name: String,
    pub description: Option<String>,
    pub billing_email: Option<String>,
    pub logo_uri: Option<String>,
    pub active: bool,
    pub created_at: String,
    pub updated_at: String,
}

/// List envelope for organizations
#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq)]
#[serde(default)]
pub struct OrganizationsList {
    pub organizations: Vec<Organization>,
    pub total: i64,
}

/// Tenant entity
#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq)]
#[serde(default, rename_all = "camelCase")]
pub struct Tenant {
    pub id: String,
    pub name: String,
    pub description: Option<String>,
    pub company: Option<String>,
    pub active: bool,
    pub created_at: String,
    pub updated_at: String,
    pub organization_ids: Vec<String>,
}

/// List envelope for tenants
#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq)]
#[serde(default)]
pub struct TenantsList {
    pub tenants: Vec<Tenant>,
    pub total: i64,
}

/// Email on a directory user
#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq)]
#[serde(default)]
pub struct EnvUserEmail {
    pub id: String,
    pub value: String,
    #[serde(rename = "type")]
    pub email_type: Option<String>,
}

/// Directory user (distinct from user-info `User`)
#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq)]
#[serde(default, rename_all = "camelCase")]
pub struct EnvUser {
    pub id: String,
    pub environment_id: Option<String>,
    pub external_id: Option<String>,
    pub user_name: Option<String>,
    pub display_name: Option<String>,
    pub nick_name: Option<String>,
    pub profile_url: Option<String>,
    pub active: Option<bool>,
    pub change_pw: Option<bool>,
    pub provider: Option<String>,
    pub emails: Vec<EnvUserEmail>,
    pub last_login: Option<String>,
    pub created_at: Option<String>,
    pub updated_at: Option<String>,
}

/// List envelope for directory users
#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq)]
#[serde(default)]
pub struct EnvUsersResponse {
    pub users: Vec<EnvUser>,
}

/// Directory group
#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq)]
#[serde(default, rename_all = "camelCase")]
pub struct EnvGroup {
    pub id: String,
    pub environment_id: String,
    pub name: String,
    pub slug: String,
    pub description: Option<String>,
    pub member_count: i64,
    pub joined_at: Option<String>,
    pub created_at: String,
    pub updated_at: String,
}

/// List envelope for directory groups
#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq)]
#[serde(default)]
pub struct EnvGroupsResponse {
    pub groups: Vec<EnvGroup>,
}

/// Environment entity
#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq)]
#[serde(default, rename_all = "camelCase")]
pub struct Environment {
    pub id: String,
    pub name: String,
    pub description: Option<String>,
    pub weight: Option<f64>,
    pub is_live: Option<bool>,
    pub is_default: Option<bool>,
    pub created_at: Option<String>,
    pub updated_at: Option<String>,
}

/// Project (application) entity
#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq)]
#[serde(default)]
pub struct Project {
    pub id: String,
    pub name: String,
    pub description: Option<String>,
}
