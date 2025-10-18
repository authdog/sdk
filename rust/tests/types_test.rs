use authdog::types::*;

#[test]
fn test_user_info_response_deserialization() {
    let json_string = r#"
    {
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
    }
    "#;

    let result: Result<UserInfoResponse, _> = serde_json::from_str(json_string);
    assert!(result.is_ok());

    let user_info = result.unwrap();
    assert_eq!(user_info.meta.code, 200);
    assert_eq!(user_info.meta.message, "Success");
    assert_eq!(user_info.session.remaining_seconds, 3600);
    assert_eq!(user_info.user.id, "user123");
    assert_eq!(user_info.user.external_id, "ext123");
    assert_eq!(user_info.user.user_name, "testuser");
    assert_eq!(user_info.user.display_name, "Test User");
    assert_eq!(user_info.user.nick_name, Some("test".to_string()));
    assert_eq!(
        user_info.user.profile_url,
        Some("https://example.com/profile".to_string())
    );
    assert_eq!(user_info.user.title, Some("Developer".to_string()));
    assert_eq!(user_info.user.user_type, Some("employee".to_string()));
    assert_eq!(user_info.user.preferred_language, Some("en".to_string()));
    assert_eq!(user_info.user.locale, "en-US");
    assert_eq!(user_info.user.timezone, Some("UTC".to_string()));
    assert!(user_info.user.active);
    assert_eq!(user_info.user.environment_id, "env123");
}

#[test]
fn test_user_info_response_with_null_optional_fields() {
    let json_string = r#"
    {
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
    }
    "#;

    let result: Result<UserInfoResponse, _> = serde_json::from_str(json_string);
    assert!(result.is_ok());

    let user_info = result.unwrap();
    assert_eq!(user_info.user.nick_name, None);
    assert_eq!(user_info.user.profile_url, None);
    assert_eq!(user_info.user.title, None);
    assert_eq!(user_info.user.user_type, None);
    assert_eq!(user_info.user.preferred_language, None);
    assert_eq!(user_info.user.timezone, None);
    assert_eq!(user_info.user.names.formatted, None);
    assert_eq!(user_info.user.names.middle_name, None);
    assert_eq!(user_info.user.names.honorific_prefix, None);
    assert_eq!(user_info.user.names.honorific_suffix, None);
}

#[test]
fn test_meta_deserialization() {
    let json_string = r#"{"code": 200, "message": "Success"}"#;
    let result: Result<Meta, _> = serde_json::from_str(json_string);
    assert!(result.is_ok());

    let meta = result.unwrap();
    assert_eq!(meta.code, 200);
    assert_eq!(meta.message, "Success");
}

#[test]
fn test_session_deserialization() {
    let json_string = r#"{"remainingSeconds": 3600}"#;
    let result: Result<Session, _> = serde_json::from_str(json_string);
    assert!(result.is_ok());

    let session = result.unwrap();
    assert_eq!(session.remaining_seconds, 3600);
}

#[test]
fn test_names_deserialization_with_optional_fields() {
    let json_string = r#"
    {
        "id": "name123",
        "formatted": "Test User",
        "familyName": "User",
        "givenName": "Test",
        "middleName": "Middle",
        "honorificPrefix": "Mr.",
        "honorificSuffix": "Jr."
    }
    "#;

    let result: Result<Names, _> = serde_json::from_str(json_string);
    assert!(result.is_ok());

    let names = result.unwrap();
    assert_eq!(names.id, "name123");
    assert_eq!(names.formatted, Some("Test User".to_string()));
    assert_eq!(names.family_name, "User");
    assert_eq!(names.given_name, "Test");
    assert_eq!(names.middle_name, Some("Middle".to_string()));
    assert_eq!(names.honorific_prefix, Some("Mr.".to_string()));
    assert_eq!(names.honorific_suffix, Some("Jr.".to_string()));
}

#[test]
fn test_photo_deserialization() {
    let json_string = r#"
    {
        "id": "photo123",
        "value": "https://example.com/photo.jpg",
        "type": "profile"
    }
    "#;

    let result: Result<Photo, _> = serde_json::from_str(json_string);
    assert!(result.is_ok());

    let photo = result.unwrap();
    assert_eq!(photo.id, "photo123");
    assert_eq!(photo.value, "https://example.com/photo.jpg");
    assert_eq!(photo.photo_type, "profile");
}

#[test]
fn test_email_deserialization_with_optional_type() {
    let json_string = r#"
    {
        "id": "email123",
        "value": "test@example.com",
        "type": "work"
    }
    "#;

    let result: Result<Email, _> = serde_json::from_str(json_string);
    assert!(result.is_ok());

    let email = result.unwrap();
    assert_eq!(email.id, "email123");
    assert_eq!(email.value, "test@example.com");
    assert_eq!(email.email_type, Some("work".to_string()));
}

#[test]
fn test_email_deserialization_without_type() {
    let json_string = r#"
    {
        "id": "email123",
        "value": "test@example.com"
    }
    "#;

    let result: Result<Email, _> = serde_json::from_str(json_string);
    assert!(result.is_ok());

    let email = result.unwrap();
    assert_eq!(email.id, "email123");
    assert_eq!(email.value, "test@example.com");
    assert_eq!(email.email_type, None);
}

#[test]
fn test_verification_deserialization() {
    let json_string = r#"
    {
        "id": "verification123",
        "email": "test@example.com",
        "verified": true,
        "createdAt": "2023-01-01T00:00:00Z",
        "updatedAt": "2023-01-01T00:00:00Z"
    }
    "#;

    let result: Result<Verification, _> = serde_json::from_str(json_string);
    assert!(result.is_ok());

    let verification = result.unwrap();
    assert_eq!(verification.id, "verification123");
    assert_eq!(verification.email, "test@example.com");
    assert!(verification.verified);
    assert_eq!(verification.created_at, "2023-01-01T00:00:00Z");
    assert_eq!(verification.updated_at, "2023-01-01T00:00:00Z");
}

#[test]
fn test_error_response_deserialization() {
    let json_string = r#"{"error": "GraphQL query failed"}"#;
    let result: Result<ErrorResponse, _> = serde_json::from_str(json_string);
    assert!(result.is_ok());

    let error_response = result.unwrap();
    assert_eq!(error_response.error, "GraphQL query failed");
}

#[test]
fn test_types_implement_clone() {
    let user_info = UserInfoResponse {
        meta: Meta {
            code: 200,
            message: "Success".to_string(),
        },
        session: Session {
            remaining_seconds: 3600,
        },
        user: User {
            id: "user123".to_string(),
            external_id: "ext123".to_string(),
            user_name: "testuser".to_string(),
            display_name: "Test User".to_string(),
            nick_name: None,
            profile_url: None,
            title: None,
            user_type: None,
            preferred_language: None,
            locale: "en-US".to_string(),
            timezone: None,
            active: true,
            names: Names {
                id: "name123".to_string(),
                formatted: None,
                family_name: "User".to_string(),
                given_name: "Test".to_string(),
                middle_name: None,
                honorific_prefix: None,
                honorific_suffix: None,
            },
            photos: vec![],
            phone_numbers: vec![],
            addresses: vec![],
            emails: vec![],
            verifications: vec![],
            provider: "test".to_string(),
            created_at: "2023-01-01T00:00:00Z".to_string(),
            updated_at: "2023-01-01T00:00:00Z".to_string(),
            environment_id: "env123".to_string(),
        },
    };

    let cloned = user_info.clone();
    assert_eq!(cloned.meta.code, user_info.meta.code);
    assert_eq!(cloned.user.id, user_info.user.id);
}

#[test]
fn test_types_implement_debug() {
    let meta = Meta {
        code: 200,
        message: "Success".to_string(),
    };

    let debug_string = format!("{:?}", meta);
    assert!(debug_string.contains("200"));
    assert!(debug_string.contains("Success"));
}
