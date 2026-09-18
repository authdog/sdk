use authdog::{AuthdogClient, AuthdogClientConfig, AuthdogError};
use serde_json::{json, Value};
use std::time::Duration;
use wiremock::matchers::{header, method, path};
use wiremock::{Mock, MockServer, ResponseTemplate};

fn client_config(base_url: String) -> AuthdogClientConfig {
    AuthdogClientConfig {
        base_url,
        api_key: Some("key-1".to_string()),
        timeout: Some(Duration::from_secs(10)),
        ..Default::default()
    }
}

async fn client_against(mock_server: &MockServer) -> AuthdogClient {
    AuthdogClient::new(client_config(mock_server.uri())).unwrap()
}

async fn mount_json(mock_server: &MockServer, status: u16, payload: &Value) {
    Mock::given(wiremock::matchers::any())
        .respond_with(ResponseTemplate::new(status).set_body_json(payload))
        .mount(mock_server)
        .await;
}

#[tokio::test]
async fn test_health_public() {
    let mock_server = MockServer::start().await;

    Mock::given(method("GET"))
        .and(path("/v1/health"))
        .respond_with(ResponseTemplate::new(200).set_body_json(json!({ "ok": true })))
        .expect(1)
        .mount(&mock_server)
        .await;

    let client = client_against(&mock_server).await;
    let probe = client.health().await.unwrap();
    assert!(probe.ok);
}

#[tokio::test]
async fn test_management_uses_constructor_key() {
    let mock_server = MockServer::start().await;

    Mock::given(method("GET"))
        .and(path("/v1/organizations"))
        .and(header("Authorization", "Bearer key-1"))
        .respond_with(
            ResponseTemplate::new(200).set_body_json(json!({ "organizations": [], "total": 0 })),
        )
        .expect(1)
        .mount(&mock_server)
        .await;

    let client = client_against(&mock_server).await;
    let result = client.organizations().list().await.unwrap();
    assert!(result.organizations.is_empty());
    assert_eq!(result.total, 0);
}

#[tokio::test]
async fn test_management_401_is_authentication_error() {
    let mock_server = MockServer::start().await;
    mount_json(&mock_server, 401, &json!({})).await;

    let client = client_against(&mock_server).await;
    let error = client.organizations().list().await.unwrap_err();
    assert!(error.is_authentication());
    assert!(!error.is_api());
    assert_eq!(error.to_string(), "Unauthorized - invalid or expired token");
}

#[tokio::test]
async fn test_management_404_includes_status_and_error() {
    let mock_server = MockServer::start().await;
    mount_json(&mock_server, 404, &json!({ "error": "not found" })).await;

    let client = client_against(&mock_server).await;
    let error = client.organizations().get("missing").await.unwrap_err();
    assert!(error.is_api());
    assert!(!error.is_authentication());
    assert!(error.to_string().contains("HTTP error 404"));
    assert!(error.to_string().contains("not found"));
}

#[tokio::test]
async fn test_management_transport_error() {
    let config = AuthdogClientConfig {
        base_url: "http://127.0.0.1:1".to_string(),
        api_key: Some("key-1".to_string()),
        timeout: Some(Duration::from_millis(200)),
        ..Default::default()
    };
    let client = AuthdogClient::new(config).unwrap();
    let error = client.tenants().list(None).await.unwrap_err();
    assert!(error.is_api());
    assert!(error.to_string().contains("Request failed"));
}

#[derive(Clone)]
struct Wave1Case {
    name: &'static str,
    method: &'static str,
    path: &'static str,
    body: Option<Value>,
}

fn wave1_cases() -> Vec<Wave1Case> {
    vec![
        Wave1Case {
            name: "org_list",
            method: "GET",
            path: "/v1/organizations",
            body: None,
        },
        Wave1Case {
            name: "org_create",
            method: "POST",
            path: "/v1/organizations",
            body: Some(json!({ "name": "Acme" })),
        },
        Wave1Case {
            name: "org_get",
            method: "GET",
            path: "/v1/organizations/org_1",
            body: None,
        },
        Wave1Case {
            name: "org_update",
            method: "PATCH",
            path: "/v1/organizations/org_1",
            body: Some(json!({ "name": "New" })),
        },
        Wave1Case {
            name: "org_delete",
            method: "DELETE",
            path: "/v1/organizations/org_1",
            body: None,
        },
        Wave1Case {
            name: "org_accept_invitation",
            method: "POST",
            path: "/v1/organizations/invitations/accept",
            body: Some(json!({ "token": "t" })),
        },
        Wave1Case {
            name: "org_join",
            method: "POST",
            path: "/v1/organizations/join",
            body: Some(json!({ "invitationCode": "c" })),
        },
        Wave1Case {
            name: "org_list_invitations",
            method: "GET",
            path: "/v1/organizations/org_1/invitations",
            body: None,
        },
        Wave1Case {
            name: "org_create_invitation",
            method: "POST",
            path: "/v1/organizations/org_1/invitations",
            body: Some(json!({ "email": "a@b.c" })),
        },
        Wave1Case {
            name: "org_cancel_invitation",
            method: "POST",
            path: "/v1/organizations/org_1/invitations/inv_1/cancel",
            body: None,
        },
        Wave1Case {
            name: "org_send_invite",
            method: "POST",
            path: "/v1/organizations/org_1/invites",
            body: Some(json!({ "email": "a@b.c" })),
        },
        Wave1Case {
            name: "org_list_members",
            method: "GET",
            path: "/v1/organizations/org_1/members",
            body: None,
        },
        Wave1Case {
            name: "org_remove_member",
            method: "DELETE",
            path: "/v1/organizations/org_1/members/mem_1",
            body: None,
        },
        Wave1Case {
            name: "org_set_member_active",
            method: "PATCH",
            path: "/v1/organizations/org_1/members/mem_1/active",
            body: Some(json!({ "active": false })),
        },
        Wave1Case {
            name: "org_link_tenant",
            method: "POST",
            path: "/v1/organizations/org_1/tenants",
            body: Some(json!({ "tenantId": "ten_1" })),
        },
        Wave1Case {
            name: "org_unlink_tenant",
            method: "DELETE",
            path: "/v1/organizations/org_1/tenants/ten_1",
            body: None,
        },
        Wave1Case {
            name: "tenant_list",
            method: "GET",
            path: "/v1/tenants",
            body: None,
        },
        Wave1Case {
            name: "tenant_create",
            method: "POST",
            path: "/v1/tenants",
            body: Some(json!({ "name": "T" })),
        },
        Wave1Case {
            name: "tenant_join",
            method: "POST",
            path: "/v1/tenants/join",
            body: Some(json!({ "invitationCode": "c" })),
        },
        Wave1Case {
            name: "tenant_get",
            method: "GET",
            path: "/v1/tenants/ten_1",
            body: None,
        },
        Wave1Case {
            name: "tenant_update",
            method: "PATCH",
            path: "/v1/tenants/ten_1",
            body: Some(json!({ "name": "N" })),
        },
        Wave1Case {
            name: "tenant_delete",
            method: "DELETE",
            path: "/v1/tenants/ten_1",
            body: None,
        },
        Wave1Case {
            name: "tenant_list_domains",
            method: "GET",
            path: "/v1/tenants/ten_1/domains",
            body: None,
        },
        Wave1Case {
            name: "tenant_create_domain",
            method: "POST",
            path: "/v1/tenants/ten_1/domains",
            body: Some(json!({ "domain": "a.com", "validationMethod": "dns" })),
        },
        Wave1Case {
            name: "tenant_delete_domain",
            method: "DELETE",
            path: "/v1/tenants/ten_1/domains/dom_1",
            body: None,
        },
        Wave1Case {
            name: "tenant_retry_domain",
            method: "POST",
            path: "/v1/tenants/ten_1/domains/dom_1/retry",
            body: None,
        },
        Wave1Case {
            name: "tenant_send_invite",
            method: "POST",
            path: "/v1/tenants/ten_1/invites",
            body: Some(json!({ "email": "a@b.c" })),
        },
        Wave1Case {
            name: "tenant_list_projects",
            method: "GET",
            path: "/v1/tenants/ten_1/projects",
            body: None,
        },
        Wave1Case {
            name: "tenant_list_seats",
            method: "GET",
            path: "/v1/tenants/ten_1/seats",
            body: None,
        },
        Wave1Case {
            name: "tenant_update_seat",
            method: "PATCH",
            path: "/v1/tenants/ten_1/seats/seat_1",
            body: Some(json!({ "active": true })),
        },
        Wave1Case {
            name: "tenant_delete_seat",
            method: "DELETE",
            path: "/v1/tenants/ten_1/seats/seat_1",
            body: None,
        },
        Wave1Case {
            name: "project_save",
            method: "POST",
            path: "/v1/tenants/ten_1/applications",
            body: Some(json!({ "name": "App" })),
        },
        Wave1Case {
            name: "project_get",
            method: "GET",
            path: "/v1/tenants/ten_1/applications/app_1",
            body: None,
        },
        Wave1Case {
            name: "project_delete",
            method: "DELETE",
            path: "/v1/tenants/ten_1/applications/app_1",
            body: None,
        },
        Wave1Case {
            name: "project_set_default_environment",
            method: "PUT",
            path: "/v1/tenants/ten_1/applications/app_1/default-environment",
            body: Some(json!({ "environmentId": "env_1" })),
        },
        Wave1Case {
            name: "env_list",
            method: "GET",
            path: "/v1/tenants/ten_1/applications/app_1/environments",
            body: None,
        },
        Wave1Case {
            name: "env_create",
            method: "POST",
            path: "/v1/tenants/ten_1/applications/app_1/environments",
            body: Some(json!({ "name": "prod" })),
        },
        Wave1Case {
            name: "env_update",
            method: "PATCH",
            path: "/v1/tenants/ten_1/environments/env_1",
            body: Some(json!({ "name": "prod" })),
        },
        Wave1Case {
            name: "env_delete",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1",
            body: None,
        },
        Wave1Case {
            name: "users_list",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/users",
            body: None,
        },
        Wave1Case {
            name: "users_create",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/users",
            body: Some(json!({ "email": "a@b.c", "password": "x" })),
        },
        Wave1Case {
            name: "users_search",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/users/search",
            body: None,
        },
        Wave1Case {
            name: "users_count",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/users/count",
            body: None,
        },
        Wave1Case {
            name: "users_get",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/users/usr_1",
            body: None,
        },
        Wave1Case {
            name: "users_update",
            method: "PUT",
            path: "/v1/tenants/ten_1/environments/env_1/users/usr_1",
            body: Some(json!({ "displayName": "Ada" })),
        },
        Wave1Case {
            name: "users_delete",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/users/usr_1",
            body: None,
        },
        Wave1Case {
            name: "users_set_active",
            method: "PATCH",
            path: "/v1/tenants/ten_1/environments/env_1/users/usr_1/active",
            body: Some(json!({ "active": false })),
        },
        Wave1Case {
            name: "users_list_groups",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/users/usr_1/groups",
            body: None,
        },
        Wave1Case {
            name: "groups_create",
            method: "POST",
            path: "/v1/groups",
            body: Some(json!({ "environmentId": "env_1", "name": "Admins" })),
        },
        Wave1Case {
            name: "groups_list",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/groups",
            body: None,
        },
        Wave1Case {
            name: "groups_delete",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/groups/grp_1",
            body: None,
        },
        Wave1Case {
            name: "groups_list_members",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/groups/grp_1/members",
            body: None,
        },
        Wave1Case {
            name: "groups_add_member",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/groups/grp_1/members",
            body: Some(json!({ "userId": "usr_1" })),
        },
        Wave1Case {
            name: "groups_remove_member",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/groups/grp_1/members/usr_1",
            body: None,
        },
    ]
}

async fn invoke(client: &AuthdogClient, case: &Wave1Case) -> Result<(), AuthdogError> {
    let empty = json!({});
    let body = case.body.as_ref().unwrap_or(&empty);
    match case.name {
        "org_list" => {
            client.organizations().list().await?;
        }
        "org_create" => {
            client.organizations().create(body).await?;
        }
        "org_get" => {
            client.organizations().get("org_1").await?;
        }
        "org_update" => {
            client.organizations().update("org_1", body).await?;
        }
        "org_delete" => {
            client.organizations().delete("org_1").await?;
        }
        "org_accept_invitation" => {
            client.organizations().accept_invitation(body).await?;
        }
        "org_join" => {
            client.organizations().join(body).await?;
        }
        "org_list_invitations" => {
            client.organizations().list_invitations("org_1").await?;
        }
        "org_create_invitation" => {
            client
                .organizations()
                .create_invitation("org_1", body)
                .await?;
        }
        "org_cancel_invitation" => {
            client
                .organizations()
                .cancel_invitation("org_1", "inv_1")
                .await?;
        }
        "org_send_invite" => {
            client.organizations().send_invite("org_1", body).await?;
        }
        "org_list_members" => {
            client.organizations().list_members("org_1").await?;
        }
        "org_remove_member" => {
            client
                .organizations()
                .remove_member("org_1", "mem_1")
                .await?;
        }
        "org_set_member_active" => {
            client
                .organizations()
                .set_member_active("org_1", "mem_1", body)
                .await?;
        }
        "org_link_tenant" => {
            client.organizations().link_tenant("org_1", body).await?;
        }
        "org_unlink_tenant" => {
            client
                .organizations()
                .unlink_tenant("org_1", "ten_1")
                .await?;
        }
        "tenant_list" => {
            client.tenants().list(None).await?;
        }
        "tenant_create" => {
            client.tenants().create(body).await?;
        }
        "tenant_join" => {
            client.tenants().join(body).await?;
        }
        "tenant_get" => {
            client.tenants().get("ten_1", None).await?;
        }
        "tenant_update" => {
            client.tenants().update("ten_1", body).await?;
        }
        "tenant_delete" => {
            client.tenants().delete("ten_1").await?;
        }
        "tenant_list_domains" => {
            client.tenants().list_domains("ten_1").await?;
        }
        "tenant_create_domain" => {
            client.tenants().create_domain("ten_1", body).await?;
        }
        "tenant_delete_domain" => {
            client.tenants().delete_domain("ten_1", "dom_1").await?;
        }
        "tenant_retry_domain" => {
            client.tenants().retry_domain("ten_1", "dom_1").await?;
        }
        "tenant_send_invite" => {
            client.tenants().send_invite("ten_1", body).await?;
        }
        "tenant_list_projects" => {
            client.tenants().list_projects("ten_1").await?;
        }
        "tenant_list_seats" => {
            client.tenants().list_seats("ten_1").await?;
        }
        "tenant_update_seat" => {
            client
                .tenants()
                .update_seat("ten_1", "seat_1", body)
                .await?;
        }
        "tenant_delete_seat" => {
            client.tenants().delete_seat("ten_1", "seat_1").await?;
        }
        "project_save" => {
            client.projects().save("ten_1", body).await?;
        }
        "project_get" => {
            client.projects().get("ten_1", "app_1").await?;
        }
        "project_delete" => {
            client.projects().delete("ten_1", "app_1").await?;
        }
        "project_set_default_environment" => {
            client
                .projects()
                .set_default_environment("ten_1", "app_1", body)
                .await?;
        }
        "env_list" => {
            client.environments().list("ten_1", "app_1").await?;
        }
        "env_create" => {
            client.environments().create("ten_1", "app_1", body).await?;
        }
        "env_update" => {
            client.environments().update("ten_1", "env_1", body).await?;
        }
        "env_delete" => {
            client.environments().delete("ten_1", "env_1").await?;
        }
        "users_list" => {
            client
                .users()
                .list("ten_1", "env_1", None, None, None)
                .await?;
        }
        "users_create" => {
            client.users().create("ten_1", "env_1", body).await?;
        }
        "users_search" => {
            client
                .users()
                .search("ten_1", "env_1", Some("ada"), None, None)
                .await?;
        }
        "users_count" => {
            client.users().count("ten_1", "env_1").await?;
        }
        "users_get" => {
            client.users().get("ten_1", "env_1", "usr_1").await?;
        }
        "users_update" => {
            client
                .users()
                .update("ten_1", "env_1", "usr_1", body)
                .await?;
        }
        "users_delete" => {
            client.users().delete("ten_1", "env_1", "usr_1").await?;
        }
        "users_set_active" => {
            client
                .users()
                .set_active("ten_1", "env_1", "usr_1", body)
                .await?;
        }
        "users_list_groups" => {
            client
                .users()
                .list_groups("ten_1", "env_1", "usr_1")
                .await?;
        }
        "groups_create" => {
            client.groups().create(body).await?;
        }
        "groups_list" => {
            client.groups().list("ten_1", "env_1").await?;
        }
        "groups_delete" => {
            client.groups().delete("ten_1", "env_1", "grp_1").await?;
        }
        "groups_list_members" => {
            client
                .groups()
                .list_members("ten_1", "env_1", "grp_1")
                .await?;
        }
        "groups_add_member" => {
            client
                .groups()
                .add_member("ten_1", "env_1", "grp_1", body)
                .await?;
        }
        "groups_remove_member" => {
            client
                .groups()
                .remove_member("ten_1", "env_1", "grp_1", "usr_1")
                .await?;
        }
        other => panic!("unknown case {other}"),
    }
    Ok(())
}

#[tokio::test]
async fn test_wave1_method_and_path() {
    for case in wave1_cases() {
        let mock_server = MockServer::start().await;
        Mock::given(method(case.method))
            .and(path(case.path))
            .respond_with(ResponseTemplate::new(200).set_body_json(json!({})))
            .expect(1)
            .mount(&mock_server)
            .await;

        let client = client_against(&mock_server).await;
        invoke(&client, &case)
            .await
            .unwrap_or_else(|err| panic!("{} failed: {err}", case.name));

        let requests = mock_server.received_requests().await.unwrap();
        assert_eq!(requests.len(), 1, "{}", case.name);
        let request = &requests[0];
        assert_eq!(request.method.as_str(), case.method, "{}", case.name);
        assert_eq!(request.url.path(), case.path, "{}", case.name);
        if let Some(expected) = &case.body {
            let actual: Value = serde_json::from_slice(&request.body).unwrap_or(Value::Null);
            assert_eq!(&actual, expected, "body mismatch for {}", case.name);
        }
    }
}

#[tokio::test]
async fn test_users_list_parses_empty_and_item() {
    let mock_server = MockServer::start().await;
    Mock::given(method("GET"))
        .and(path("/v1/tenants/ten_1/environments/env_1/users"))
        .respond_with(ResponseTemplate::new(200).set_body_json(json!({
            "users": [
                {
                    "id": "usr_1",
                    "displayName": "Ada",
                    "emails": [{ "value": "ada@example.com" }]
                }
            ]
        })))
        .mount(&mock_server)
        .await;

    let client = client_against(&mock_server).await;
    let listed = client
        .users()
        .list("ten_1", "env_1", None, None, None)
        .await
        .unwrap();
    assert_eq!(listed.users[0].id, "usr_1");
    assert_eq!(listed.users[0].display_name.as_deref(), Some("Ada"));
    assert_eq!(listed.users[0].emails[0].value, "ada@example.com");

    let empty_server = MockServer::start().await;
    Mock::given(method("GET"))
        .and(path("/v1/tenants/ten_1/environments/env_1/users"))
        .respond_with(ResponseTemplate::new(200).set_body_json(json!({ "users": [] })))
        .mount(&empty_server)
        .await;
    let client = client_against(&empty_server).await;
    let empty = client
        .users()
        .list("ten_1", "env_1", None, None, None)
        .await
        .unwrap();
    assert!(empty.users.is_empty());
}

#[tokio::test]
async fn test_userinfo_still_sends_access_token() {
    let mock_response = json!({
        "meta": { "code": 200, "message": "Success" },
        "session": { "remainingSeconds": 3600 },
        "user": {
            "id": "123",
            "externalId": "ext123",
            "userName": "ada",
            "displayName": "Ada",
            "nickName": null,
            "profileUrl": null,
            "title": null,
            "userType": null,
            "preferredLanguage": null,
            "locale": "en-US",
            "timezone": null,
            "active": true,
            "names": {
                "id": "name123",
                "formatted": null,
                "familyName": "Lovelace",
                "givenName": "Ada",
                "middleName": null,
                "honorificPrefix": null,
                "honorificSuffix": null
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

    let mock_server = MockServer::start().await;
    Mock::given(method("GET"))
        .and(path("/v1/userinfo"))
        .and(header("Authorization", "Bearer token-2"))
        .respond_with(ResponseTemplate::new(200).set_body_json(&mock_response))
        .expect(1)
        .mount(&mock_server)
        .await;

    let client = client_against(&mock_server).await;
    let result = client.get_user_info("token-2").await.unwrap();
    assert_eq!(result.user.id, "123");
}

#[derive(Clone)]
struct Wave2Case {
    name: &'static str,
    method: &'static str,
    path: &'static str,
    body: Option<Value>,
}

fn wave2_cases() -> Vec<Wave2Case> {
    vec![
        Wave2Case {
            name: "org_list_keys",
            method: "GET",
            path: "/v1/organizations/org_1/keys",
            body: None,
        },
        Wave2Case {
            name: "org_create_key",
            method: "POST",
            path: "/v1/organizations/org_1/keys",
            body: Some(json!({ "name": "ci" })),
        },
        Wave2Case {
            name: "org_revoke_key",
            method: "POST",
            path: "/v1/organizations/org_1/keys/key_1/revoke",
            body: None,
        },
        Wave2Case {
            name: "org_rotate_key",
            method: "POST",
            path: "/v1/organizations/org_1/keys/key_1/rotate",
            body: None,
        },
        Wave2Case {
            name: "org_update_key_tenants",
            method: "PUT",
            path: "/v1/organizations/org_1/keys/key_1/tenants",
            body: Some(json!({ "tenantIds": ["ten_1"] })),
        },
        Wave2Case {
            name: "org_list_audit_logs",
            method: "GET",
            path: "/v1/organizations/org_1/audit/logs",
            body: None,
        },
        Wave2Case {
            name: "sa_list",
            method: "GET",
            path: "/v1/service-accounts",
            body: None,
        },
        Wave2Case {
            name: "sa_create",
            method: "POST",
            path: "/v1/service-accounts",
            body: Some(json!({ "name": "bot" })),
        },
        Wave2Case {
            name: "sa_get",
            method: "GET",
            path: "/v1/service-accounts/sa_1",
            body: None,
        },
        Wave2Case {
            name: "sa_delete",
            method: "DELETE",
            path: "/v1/service-accounts/sa_1",
            body: None,
        },
        Wave2Case {
            name: "pat_list",
            method: "GET",
            path: "/v1/personal-access-tokens",
            body: None,
        },
        Wave2Case {
            name: "pat_create",
            method: "POST",
            path: "/v1/personal-access-tokens",
            body: Some(json!({ "name": "cli" })),
        },
        Wave2Case {
            name: "pat_revoke",
            method: "POST",
            path: "/v1/personal-access-tokens/pat_1/revoke",
            body: None,
        },
        Wave2Case {
            name: "secrets_list",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/api-secrets",
            body: None,
        },
        Wave2Case {
            name: "secrets_create",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/api-secrets",
            body: Some(json!({ "name": "runtime" })),
        },
        Wave2Case {
            name: "secrets_revoke",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/api-secrets/sec_1/revoke",
            body: None,
        },
        Wave2Case {
            name: "audit_list_logs",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/audit/logs",
            body: None,
        },
        Wave2Case {
            name: "audit_event_metadata",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/audit/event-metadata",
            body: None,
        },
        Wave2Case {
            name: "audit_event_types",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/audit/event-types",
            body: None,
        },
        Wave2Case {
            name: "audit_event_types_catalog",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/audit/event-types/catalog",
            body: None,
        },
        Wave2Case {
            name: "events_list",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/events",
            body: None,
        },
        Wave2Case {
            name: "events_list_types",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/events/types",
            body: None,
        },
        Wave2Case {
            name: "events_ingest",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/events/ingest",
            body: Some(json!({ "events": [] })),
        },
        Wave2Case {
            name: "webhooks_list",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/webhooks",
            body: None,
        },
        Wave2Case {
            name: "webhooks_create",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/webhooks",
            body: Some(json!({ "url": "https://ex" })),
        },
        Wave2Case {
            name: "webhooks_update",
            method: "PUT",
            path: "/v1/tenants/ten_1/environments/env_1/webhooks/ch_1",
            body: Some(json!({ "url": "https://ex" })),
        },
        Wave2Case {
            name: "webhooks_delete",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/webhooks/ch_1",
            body: None,
        },
        Wave2Case {
            name: "webhooks_rotate_secret",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/webhooks/ch_1/rotate-secret",
            body: None,
        },
        Wave2Case {
            name: "webhooks_list_deliveries",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/webhooks/deliveries",
            body: None,
        },
        Wave2Case {
            name: "webhooks_redeliver",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/webhooks/deliveries/del_1/redeliver",
            body: None,
        },
        Wave2Case {
            name: "nc_list",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/notification-channels",
            body: None,
        },
        Wave2Case {
            name: "nc_create",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/notification-channels",
            body: Some(json!({ "type": "webhook" })),
        },
        Wave2Case {
            name: "nc_update",
            method: "PUT",
            path: "/v1/tenants/ten_1/environments/env_1/notification-channels/ch_1",
            body: Some(json!({ "name": "n" })),
        },
        Wave2Case {
            name: "nc_delete",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/notification-channels/ch_1",
            body: None,
        },
        Wave2Case {
            name: "nc_test",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/notification-channels/ch_1/test",
            body: None,
        },
        Wave2Case {
            name: "rbac_list_roles",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/roles",
            body: None,
        },
        Wave2Case {
            name: "rbac_create_role",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/roles",
            body: Some(json!({ "name": "admin" })),
        },
        Wave2Case {
            name: "rbac_delete_role",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/roles/role_1",
            body: None,
        },
        Wave2Case {
            name: "rbac_list_role_permissions",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/roles/role_1/permissions",
            body: None,
        },
        Wave2Case {
            name: "rbac_set_role_permissions",
            method: "PUT",
            path: "/v1/tenants/ten_1/environments/env_1/roles/role_1/permissions",
            body: Some(json!({ "permissionIds": [] })),
        },
        Wave2Case {
            name: "rbac_list_permissions",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/permissions",
            body: None,
        },
        Wave2Case {
            name: "rbac_create_permission",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/permissions",
            body: Some(json!({ "name": "read" })),
        },
        Wave2Case {
            name: "rbac_delete_permission",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/permissions/perm_1",
            body: None,
        },
        Wave2Case {
            name: "rbac_list_resources",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/resources",
            body: None,
        },
        Wave2Case {
            name: "rbac_create_resource",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/resources",
            body: Some(json!({ "name": "doc" })),
        },
        Wave2Case {
            name: "rbac_delete_resource",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/resources/res_1",
            body: None,
        },
        Wave2Case {
            name: "rbac_list_group_roles",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/groups/grp_1/roles",
            body: None,
        },
        Wave2Case {
            name: "rbac_add_group_role",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/groups/grp_1/roles",
            body: Some(json!({ "roleId": "role_1" })),
        },
        Wave2Case {
            name: "rbac_remove_group_role",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/groups/grp_1/roles/role_1",
            body: None,
        },
        Wave2Case {
            name: "rbac_list_group_role_mappings",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/group-role-mappings",
            body: None,
        },
        Wave2Case {
            name: "rbac_create_group_role_mapping",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/group-role-mappings",
            body: Some(json!({ "groupId": "grp_1" })),
        },
        Wave2Case {
            name: "rbac_apply_group_role_mappings",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/group-role-mappings/apply",
            body: None,
        },
        Wave2Case {
            name: "rbac_delete_group_role_mapping",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/group-role-mappings/map_1",
            body: None,
        },
        Wave2Case {
            name: "rbac_list_abac_policies",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/abac-policies",
            body: None,
        },
        Wave2Case {
            name: "rbac_save_abac_policy",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/abac-policies",
            body: Some(json!({ "name": "p" })),
        },
        Wave2Case {
            name: "rbac_validate_abac_policy",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/abac-policies/validate",
            body: Some(json!({ "rego": "x" })),
        },
        Wave2Case {
            name: "rbac_delete_abac_policy",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/abac-policies/pol_1",
            body: None,
        },
        Wave2Case {
            name: "rbac_my_permissions",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/me/permissions",
            body: None,
        },
    ]
}

async fn invoke_wave2(client: &AuthdogClient, case: &Wave2Case) -> Result<(), AuthdogError> {
    let empty = json!({});
    let body = case.body.as_ref().unwrap_or(&empty);
    match case.name {
        "org_list_keys" => {
            client.organizations().list_keys("org_1").await?;
        }
        "org_create_key" => {
            client.organizations().create_key("org_1", body).await?;
        }
        "org_revoke_key" => {
            client.organizations().revoke_key("org_1", "key_1").await?;
        }
        "org_rotate_key" => {
            client.organizations().rotate_key("org_1", "key_1").await?;
        }
        "org_update_key_tenants" => {
            client
                .organizations()
                .update_key_tenants("org_1", "key_1", body)
                .await?;
        }
        "org_list_audit_logs" => {
            client
                .organizations()
                .list_audit_logs("org_1", None)
                .await?;
        }
        "sa_list" => {
            client.service_accounts().list().await?;
        }
        "sa_create" => {
            client.service_accounts().create(body).await?;
        }
        "sa_get" => {
            client.service_accounts().get("sa_1").await?;
        }
        "sa_delete" => {
            client.service_accounts().delete("sa_1").await?;
        }
        "pat_list" => {
            client.personal_access_tokens().list().await?;
        }
        "pat_create" => {
            client.personal_access_tokens().create(body).await?;
        }
        "pat_revoke" => {
            client.personal_access_tokens().revoke("pat_1").await?;
        }
        "secrets_list" => {
            client.api_secrets().list("ten_1", "env_1").await?;
        }
        "secrets_create" => {
            client.api_secrets().create("ten_1", "env_1", body).await?;
        }
        "secrets_revoke" => {
            client
                .api_secrets()
                .revoke("ten_1", "env_1", "sec_1")
                .await?;
        }
        "audit_list_logs" => {
            client.audit().list_logs("ten_1", "env_1", None).await?;
        }
        "audit_event_metadata" => {
            client
                .audit()
                .event_metadata("ten_1", "env_1", None)
                .await?;
        }
        "audit_event_types" => {
            client.audit().event_types("ten_1", "env_1", None).await?;
        }
        "audit_event_types_catalog" => {
            client.audit().event_types_catalog("ten_1", "env_1").await?;
        }
        "events_list" => {
            client.events().list("ten_1", "env_1", None).await?;
        }
        "events_list_types" => {
            client.events().list_types("ten_1", "env_1").await?;
        }
        "events_ingest" => {
            client.events().ingest("ten_1", "env_1", body).await?;
        }
        "webhooks_list" => {
            client.webhooks().list("ten_1", "env_1").await?;
        }
        "webhooks_create" => {
            client.webhooks().create("ten_1", "env_1", body).await?;
        }
        "webhooks_update" => {
            client
                .webhooks()
                .update("ten_1", "env_1", "ch_1", body)
                .await?;
        }
        "webhooks_delete" => {
            client.webhooks().delete("ten_1", "env_1", "ch_1").await?;
        }
        "webhooks_rotate_secret" => {
            client
                .webhooks()
                .rotate_secret("ten_1", "env_1", "ch_1")
                .await?;
        }
        "webhooks_list_deliveries" => {
            client
                .webhooks()
                .list_deliveries("ten_1", "env_1", None)
                .await?;
        }
        "webhooks_redeliver" => {
            client
                .webhooks()
                .redeliver("ten_1", "env_1", "del_1")
                .await?;
        }
        "nc_list" => {
            client
                .notification_channels()
                .list("ten_1", "env_1")
                .await?;
        }
        "nc_create" => {
            client
                .notification_channels()
                .create("ten_1", "env_1", body)
                .await?;
        }
        "nc_update" => {
            client
                .notification_channels()
                .update("ten_1", "env_1", "ch_1", body)
                .await?;
        }
        "nc_delete" => {
            client
                .notification_channels()
                .delete("ten_1", "env_1", "ch_1")
                .await?;
        }
        "nc_test" => {
            client
                .notification_channels()
                .test("ten_1", "env_1", "ch_1", None)
                .await?;
        }
        "rbac_list_roles" => {
            client.rbac().list_roles("ten_1", "env_1").await?;
        }
        "rbac_create_role" => {
            client.rbac().create_role("ten_1", "env_1", body).await?;
        }
        "rbac_delete_role" => {
            client
                .rbac()
                .delete_role("ten_1", "env_1", "role_1")
                .await?;
        }
        "rbac_list_role_permissions" => {
            client
                .rbac()
                .list_role_permissions("ten_1", "env_1", "role_1")
                .await?;
        }
        "rbac_set_role_permissions" => {
            client
                .rbac()
                .set_role_permissions("ten_1", "env_1", "role_1", body)
                .await?;
        }
        "rbac_list_permissions" => {
            client.rbac().list_permissions("ten_1", "env_1").await?;
        }
        "rbac_create_permission" => {
            client
                .rbac()
                .create_permission("ten_1", "env_1", body)
                .await?;
        }
        "rbac_delete_permission" => {
            client
                .rbac()
                .delete_permission("ten_1", "env_1", "perm_1")
                .await?;
        }
        "rbac_list_resources" => {
            client.rbac().list_resources("ten_1", "env_1").await?;
        }
        "rbac_create_resource" => {
            client
                .rbac()
                .create_resource("ten_1", "env_1", body)
                .await?;
        }
        "rbac_delete_resource" => {
            client
                .rbac()
                .delete_resource("ten_1", "env_1", "res_1")
                .await?;
        }
        "rbac_list_group_roles" => {
            client
                .rbac()
                .list_group_roles("ten_1", "env_1", "grp_1")
                .await?;
        }
        "rbac_add_group_role" => {
            client
                .rbac()
                .add_group_role("ten_1", "env_1", "grp_1", body)
                .await?;
        }
        "rbac_remove_group_role" => {
            client
                .rbac()
                .remove_group_role("ten_1", "env_1", "grp_1", "role_1")
                .await?;
        }
        "rbac_list_group_role_mappings" => {
            client
                .rbac()
                .list_group_role_mappings("ten_1", "env_1")
                .await?;
        }
        "rbac_create_group_role_mapping" => {
            client
                .rbac()
                .create_group_role_mapping("ten_1", "env_1", body)
                .await?;
        }
        "rbac_apply_group_role_mappings" => {
            client
                .rbac()
                .apply_group_role_mappings("ten_1", "env_1")
                .await?;
        }
        "rbac_delete_group_role_mapping" => {
            client
                .rbac()
                .delete_group_role_mapping("ten_1", "env_1", "map_1")
                .await?;
        }
        "rbac_list_abac_policies" => {
            client.rbac().list_abac_policies("ten_1", "env_1").await?;
        }
        "rbac_save_abac_policy" => {
            client
                .rbac()
                .save_abac_policy("ten_1", "env_1", body)
                .await?;
        }
        "rbac_validate_abac_policy" => {
            client
                .rbac()
                .validate_abac_policy("ten_1", "env_1", body)
                .await?;
        }
        "rbac_delete_abac_policy" => {
            client
                .rbac()
                .delete_abac_policy("ten_1", "env_1", "pol_1")
                .await?;
        }
        "rbac_my_permissions" => {
            client.rbac().my_permissions("ten_1", "env_1").await?;
        }
        other => panic!("unknown case {other}"),
    }
    Ok(())
}

#[tokio::test]
async fn test_wave2_method_and_path() {
    let cases = wave2_cases();
    assert_eq!(cases.len(), 58, "expected all 58 Wave 2 paths");
    for case in cases {
        let mock_server = MockServer::start().await;
        Mock::given(method(case.method))
            .and(path(case.path))
            .respond_with(ResponseTemplate::new(200).set_body_json(json!({})))
            .expect(1)
            .mount(&mock_server)
            .await;

        let client = client_against(&mock_server).await;
        invoke_wave2(&client, &case)
            .await
            .unwrap_or_else(|err| panic!("{} failed: {err}", case.name));

        let requests = mock_server.received_requests().await.unwrap();
        assert_eq!(requests.len(), 1, "{}", case.name);
        let request = &requests[0];
        assert_eq!(request.method.as_str(), case.method, "{}", case.name);
        assert_eq!(request.url.path(), case.path, "{}", case.name);
        if let Some(expected) = &case.body {
            let actual: Value = serde_json::from_slice(&request.body).unwrap_or(Value::Null);
            assert_eq!(&actual, expected, "body mismatch for {}", case.name);
        }
    }
}

#[tokio::test]
async fn test_wave2_create_key_exposes_one_time_secret() {
    let mock_server = MockServer::start().await;
    Mock::given(method("POST"))
        .and(path("/v1/organizations/org_1/keys"))
        .respond_with(ResponseTemplate::new(200).set_body_json(json!({
            "token": "orgk_secret_once",
            "key": { "id": "key_1" }
        })))
        .mount(&mock_server)
        .await;

    let client = client_against(&mock_server).await;
    let created = client
        .organizations()
        .create_key("org_1", json!({ "name": "ci" }))
        .await
        .unwrap();
    assert_eq!(
        created.get("token").and_then(Value::as_str),
        Some("orgk_secret_once")
    );
}

#[tokio::test]
async fn test_wave2_audit_forwards_query_params() {
    let mock_server = MockServer::start().await;
    Mock::given(method("GET"))
        .and(path("/v1/tenants/ten_1/environments/env_1/events"))
        .respond_with(ResponseTemplate::new(200).set_body_json(json!({})))
        .mount(&mock_server)
        .await;

    let client = client_against(&mock_server).await;
    client
        .events()
        .list(
            "ten_1",
            "env_1",
            Some(&json!({ "limit": 50, "after": "cur_1" })),
        )
        .await
        .unwrap();

    let requests = mock_server.received_requests().await.unwrap();
    assert_eq!(requests.len(), 1);
    let request = &requests[0];
    assert_eq!(
        request.url.path(),
        "/v1/tenants/ten_1/environments/env_1/events"
    );
    let pairs: std::collections::HashMap<String, String> =
        request.url.query_pairs().into_owned().collect();
    assert_eq!(pairs.get("limit").map(String::as_str), Some("50"));
    assert_eq!(pairs.get("after").map(String::as_str), Some("cur_1"));
}

#[derive(Clone)]
struct Wave3Case {
    name: &'static str,
    method: &'static str,
    path: &'static str,
    body: Option<Value>,
}

fn wave3_cases() -> Vec<Wave3Case> {
    vec![
        Wave3Case {
            name: "authzen_configuration",
            method: "GET",
            path: "/.well-known/authzen-configuration",
            body: None,
        },
        Wave3Case {
            name: "authzen_evaluate",
            method: "POST",
            path: "/access/v1/evaluation",
            body: Some(json!({ "subject": {} })),
        },
        Wave3Case {
            name: "authzen_evaluate_batch",
            method: "POST",
            path: "/access/v1/evaluations",
            body: Some(json!({ "evaluations": [] })),
        },
        Wave3Case {
            name: "authzen_search_action",
            method: "POST",
            path: "/access/v1/search/action",
            body: Some(json!({ "subject": {} })),
        },
        Wave3Case {
            name: "authzen_search_resource",
            method: "POST",
            path: "/access/v1/search/resource",
            body: Some(json!({ "subject": {} })),
        },
        Wave3Case {
            name: "authzen_search_subject",
            method: "POST",
            path: "/access/v1/search/subject",
            body: Some(json!({ "resource": {} })),
        },
        Wave3Case {
            name: "users_revoke_session",
            method: "DELETE",
            path: "/v1/environments/env_1/sessions/sess_1",
            body: None,
        },
        Wave3Case {
            name: "hris_list_departments",
            method: "GET",
            path: "/v1/hris/v1/Departments",
            body: None,
        },
        Wave3Case {
            name: "hris_create_department",
            method: "POST",
            path: "/v1/hris/v1/Departments",
            body: Some(json!({ "name": "Eng" })),
        },
        Wave3Case {
            name: "hris_get_department",
            method: "GET",
            path: "/v1/hris/v1/Departments/dep_1",
            body: None,
        },
        Wave3Case {
            name: "hris_replace_department",
            method: "PUT",
            path: "/v1/hris/v1/Departments/dep_1",
            body: Some(json!({ "name": "Eng" })),
        },
        Wave3Case {
            name: "hris_patch_department",
            method: "PATCH",
            path: "/v1/hris/v1/Departments/dep_1",
            body: Some(json!({ "name": "E" })),
        },
        Wave3Case {
            name: "hris_delete_department",
            method: "DELETE",
            path: "/v1/hris/v1/Departments/dep_1",
            body: None,
        },
        Wave3Case {
            name: "hris_list_employees",
            method: "GET",
            path: "/v1/hris/v1/Employees",
            body: None,
        },
        Wave3Case {
            name: "hris_create_employee",
            method: "POST",
            path: "/v1/hris/v1/Employees",
            body: Some(json!({ "name": "Ada" })),
        },
        Wave3Case {
            name: "hris_get_employee",
            method: "GET",
            path: "/v1/hris/v1/Employees/emp_1",
            body: None,
        },
        Wave3Case {
            name: "hris_replace_employee",
            method: "PUT",
            path: "/v1/hris/v1/Employees/emp_1",
            body: Some(json!({ "name": "Ada" })),
        },
        Wave3Case {
            name: "hris_patch_employee",
            method: "PATCH",
            path: "/v1/hris/v1/Employees/emp_1",
            body: Some(json!({ "name": "A" })),
        },
        Wave3Case {
            name: "hris_delete_employee",
            method: "DELETE",
            path: "/v1/hris/v1/Employees/emp_1",
            body: None,
        },
        Wave3Case {
            name: "hris_service_config",
            method: "GET",
            path: "/v1/hris/v1/ServiceConfig",
            body: None,
        },
        Wave3Case {
            name: "otel_export_logs",
            method: "POST",
            path: "/v1/logs",
            body: Some(json!({ "resourceLogs": [] })),
        },
        Wave3Case {
            name: "mcp_ingest_events",
            method: "POST",
            path: "/v1/mcp/events",
            body: Some(json!({ "events": [] })),
        },
        Wave3Case {
            name: "mcp_resolve",
            method: "GET",
            path: "/v1/mcp/trust-store/resolve",
            body: None,
        },
        Wave3Case {
            name: "otel_export_metrics",
            method: "POST",
            path: "/v1/metrics",
            body: Some(json!({ "resourceMetrics": [] })),
        },
        Wave3Case {
            name: "otel_export_logs_prefixed",
            method: "POST",
            path: "/v1/otel/v1/logs",
            body: Some(json!({ "resourceLogs": [] })),
        },
        Wave3Case {
            name: "otel_export_metrics_prefixed",
            method: "POST",
            path: "/v1/otel/v1/metrics",
            body: Some(json!({ "resourceMetrics": [] })),
        },
        Wave3Case {
            name: "otel_export_traces_prefixed",
            method: "POST",
            path: "/v1/otel/v1/traces",
            body: Some(json!({ "resourceSpans": [] })),
        },
        Wave3Case {
            name: "scim_list_groups",
            method: "GET",
            path: "/v1/scim/v2/Groups",
            body: None,
        },
        Wave3Case {
            name: "scim_create_group",
            method: "POST",
            path: "/v1/scim/v2/Groups",
            body: Some(json!({ "displayName": "G" })),
        },
        Wave3Case {
            name: "scim_get_group",
            method: "GET",
            path: "/v1/scim/v2/Groups/g_1",
            body: None,
        },
        Wave3Case {
            name: "scim_replace_group",
            method: "PUT",
            path: "/v1/scim/v2/Groups/g_1",
            body: Some(json!({ "displayName": "G" })),
        },
        Wave3Case {
            name: "scim_patch_group",
            method: "PATCH",
            path: "/v1/scim/v2/Groups/g_1",
            body: Some(json!({ "Operations": [] })),
        },
        Wave3Case {
            name: "scim_delete_group",
            method: "DELETE",
            path: "/v1/scim/v2/Groups/g_1",
            body: None,
        },
        Wave3Case {
            name: "scim_resource_types",
            method: "GET",
            path: "/v1/scim/v2/ResourceTypes",
            body: None,
        },
        Wave3Case {
            name: "scim_resource_type",
            method: "GET",
            path: "/v1/scim/v2/ResourceTypes/User",
            body: None,
        },
        Wave3Case {
            name: "scim_schemas",
            method: "GET",
            path: "/v1/scim/v2/Schemas",
            body: None,
        },
        Wave3Case {
            name: "scim_schema",
            method: "GET",
            path: "/v1/scim/v2/Schemas/urn:ietf:params:scim:schemas:core:2.0:User",
            body: None,
        },
        Wave3Case {
            name: "scim_service_provider_config",
            method: "GET",
            path: "/v1/scim/v2/ServiceProviderConfig",
            body: None,
        },
        Wave3Case {
            name: "scim_list_users",
            method: "GET",
            path: "/v1/scim/v2/Users",
            body: None,
        },
        Wave3Case {
            name: "scim_create_user",
            method: "POST",
            path: "/v1/scim/v2/Users",
            body: Some(json!({ "userName": "ada" })),
        },
        Wave3Case {
            name: "scim_get_user",
            method: "GET",
            path: "/v1/scim/v2/Users/u_1",
            body: None,
        },
        Wave3Case {
            name: "scim_replace_user",
            method: "PUT",
            path: "/v1/scim/v2/Users/u_1",
            body: Some(json!({ "userName": "ada" })),
        },
        Wave3Case {
            name: "scim_patch_user",
            method: "PATCH",
            path: "/v1/scim/v2/Users/u_1",
            body: Some(json!({ "Operations": [] })),
        },
        Wave3Case {
            name: "scim_delete_user",
            method: "DELETE",
            path: "/v1/scim/v2/Users/u_1",
            body: None,
        },
        Wave3Case {
            name: "env_list_connections",
            method: "GET",
            path: "/v1/tenants/ten_1/applications/app_1/environments/env_1/connections",
            body: None,
        },
        Wave3Case {
            name: "oidc_list",
            method: "GET",
            path: "/v1/tenants/ten_1/applications/app_1/environments/env_1/oidc-clients",
            body: None,
        },
        Wave3Case {
            name: "oidc_register",
            method: "POST",
            path: "/v1/tenants/ten_1/applications/app_1/environments/env_1/oidc-clients",
            body: Some(json!({ "name": "cli" })),
        },
        Wave3Case {
            name: "oidc_update",
            method: "PATCH",
            path: "/v1/tenants/ten_1/applications/app_1/environments/env_1/oidc-clients/cid_1",
            body: Some(json!({ "name": "n" })),
        },
        Wave3Case {
            name: "oidc_delete",
            method: "DELETE",
            path: "/v1/tenants/ten_1/applications/app_1/environments/env_1/oidc-clients/cid_1",
            body: None,
        },
        Wave3Case {
            name: "env_list_redirect_uris",
            method: "GET",
            path: "/v1/tenants/ten_1/applications/app_1/environments/env_1/redirect-uris",
            body: None,
        },
        Wave3Case {
            name: "actions_list",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/actions",
            body: None,
        },
        Wave3Case {
            name: "actions_save",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/actions",
            body: Some(json!({ "url": "https://ex" })),
        },
        Wave3Case {
            name: "actions_executions",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/actions/executions",
            body: None,
        },
        Wave3Case {
            name: "actions_test",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/actions/test",
            body: Some(json!({ "url": "https://ex" })),
        },
        Wave3Case {
            name: "actions_delete",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/actions/act_1",
            body: None,
        },
        Wave3Case {
            name: "addons_list",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/addons",
            body: None,
        },
        Wave3Case {
            name: "addons_save",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/addons",
            body: Some(json!({ "provider": "slack" })),
        },
        Wave3Case {
            name: "addons_delete",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/addons/slack",
            body: None,
        },
        Wave3Case {
            name: "billing_list_features",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/billing/features",
            body: None,
        },
        Wave3Case {
            name: "billing_save_feature",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/billing/features",
            body: Some(json!({ "name": "pro" })),
        },
        Wave3Case {
            name: "billing_delete_feature",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/billing/features/feat_1",
            body: None,
        },
        Wave3Case {
            name: "billing_list_plans",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/billing/plans",
            body: None,
        },
        Wave3Case {
            name: "billing_save_plan",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/billing/plans",
            body: Some(json!({ "name": "pro" })),
        },
        Wave3Case {
            name: "billing_delete_plan",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/billing/plans/plan_1",
            body: None,
        },
        Wave3Case {
            name: "billing_sync_stripe",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/billing/plans/plan_1/sync-stripe",
            body: None,
        },
        Wave3Case {
            name: "settings_get_bot_detection_policy",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/bot-detection-policy",
            body: None,
        },
        Wave3Case {
            name: "settings_update_bot_detection_policy",
            method: "PUT",
            path: "/v1/tenants/ten_1/environments/env_1/bot-detection-policy",
            body: Some(json!({ "enabled": true })),
        },
        Wave3Case {
            name: "settings_get_breached_password_policy",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/breached-password-policy",
            body: None,
        },
        Wave3Case {
            name: "settings_update_breached_password_policy",
            method: "PUT",
            path: "/v1/tenants/ten_1/environments/env_1/breached-password-policy",
            body: Some(json!({ "enabled": true })),
        },
        Wave3Case {
            name: "settings_get_brute_force_policy",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/brute-force-policy",
            body: None,
        },
        Wave3Case {
            name: "settings_update_brute_force_policy",
            method: "PUT",
            path: "/v1/tenants/ten_1/environments/env_1/brute-force-policy",
            body: Some(json!({ "enabled": true })),
        },
        Wave3Case {
            name: "env_save_connection",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/connections",
            body: Some(json!({ "provider": "okta" })),
        },
        Wave3Case {
            name: "env_resolve_saml_metadata",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/connections/resolve-saml-metadata",
            body: Some(json!({ "url": "https://ex" })),
        },
        Wave3Case {
            name: "env_get_sso_metadata",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/connections/sso-metadata",
            body: None,
        },
        Wave3Case {
            name: "env_delete_connection",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/connections/con_1",
            body: None,
        },
        Wave3Case {
            name: "settings_get_device_risk_policy",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/device-risk-policy",
            body: None,
        },
        Wave3Case {
            name: "settings_update_device_risk_policy",
            method: "PUT",
            path: "/v1/tenants/ten_1/environments/env_1/device-risk-policy",
            body: Some(json!({ "enabled": true })),
        },
        Wave3Case {
            name: "elevate_activate_grant",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/elevate/access-grants/gr_1/activate",
            body: Some(json!({ "reason": "x" })),
        },
        Wave3Case {
            name: "elevate_revoke_grant",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/elevate/access-grants/gr_1/revoke",
            body: Some(json!({ "reason": "x" })),
        },
        Wave3Case {
            name: "elevate_list_requests",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/elevate/access-requests",
            body: None,
        },
        Wave3Case {
            name: "elevate_create_request",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/elevate/access-requests",
            body: Some(json!({ "reason": "x" })),
        },
        Wave3Case {
            name: "elevate_get_request",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/elevate/access-requests/req_1",
            body: None,
        },
        Wave3Case {
            name: "elevate_approve_request",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/elevate/access-requests/req_1/approve",
            body: Some(json!({ "note": "ok" })),
        },
        Wave3Case {
            name: "elevate_cancel_request",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/elevate/access-requests/req_1/cancel",
            body: None,
        },
        Wave3Case {
            name: "elevate_deny_request",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/elevate/access-requests/req_1/deny",
            body: Some(json!({ "note": "no" })),
        },
        Wave3Case {
            name: "elevate_get_policy",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/elevate/policy",
            body: None,
        },
        Wave3Case {
            name: "elevate_update_policy",
            method: "PUT",
            path: "/v1/tenants/ten_1/environments/env_1/elevate/policy",
            body: Some(json!({ "enabled": true })),
        },
        Wave3Case {
            name: "email_providers_list",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/email-providers",
            body: None,
        },
        Wave3Case {
            name: "email_providers_save",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/email-providers",
            body: Some(json!({ "provider": "ses" })),
        },
        Wave3Case {
            name: "email_providers_test",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/email-providers/test",
            body: Some(json!({ "to": "a@b.c" })),
        },
        Wave3Case {
            name: "email_providers_delete",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/email-providers/ses",
            body: None,
        },
        Wave3Case {
            name: "email_providers_activate",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/email-providers/ses/activate",
            body: None,
        },
        Wave3Case {
            name: "feature_flags_list",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/feature-flags",
            body: None,
        },
        Wave3Case {
            name: "feature_flags_save",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/feature-flags",
            body: Some(json!({ "key": "x" })),
        },
        Wave3Case {
            name: "feature_flags_delete",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/feature-flags/flag_1",
            body: None,
        },
        Wave3Case {
            name: "forms_list_attachments",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/form-attachments",
            body: None,
        },
        Wave3Case {
            name: "forms_list",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/forms",
            body: None,
        },
        Wave3Case {
            name: "forms_save",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/forms",
            body: Some(json!({ "name": "login" })),
        },
        Wave3Case {
            name: "forms_delete",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/forms/form_1",
            body: None,
        },
        Wave3Case {
            name: "provisioning_list_hris",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/hris-tokens",
            body: None,
        },
        Wave3Case {
            name: "provisioning_create_hris",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/hris-tokens",
            body: Some(json!({ "name": "hr" })),
        },
        Wave3Case {
            name: "provisioning_revoke_hris",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/hris-tokens/tok_1/revoke",
            body: None,
        },
        Wave3Case {
            name: "provisioning_rotate_hris",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/hris-tokens/tok_1/rotate",
            body: None,
        },
        Wave3Case {
            name: "impersonation_list",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/impersonation-grants",
            body: None,
        },
        Wave3Case {
            name: "impersonation_create",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/impersonation-grants",
            body: Some(json!({ "userId": "usr_1" })),
        },
        Wave3Case {
            name: "impersonation_revoke",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/impersonation-grants/gr_1/revoke",
            body: None,
        },
        Wave3Case {
            name: "settings_list_jwt_claim_mappings",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/jwt-claim-mappings",
            body: None,
        },
        Wave3Case {
            name: "settings_save_jwt_claim_mapping",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/jwt-claim-mappings",
            body: Some(json!({ "claim": "role" })),
        },
        Wave3Case {
            name: "settings_delete_jwt_claim_mapping",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/jwt-claim-mappings/map_1",
            body: None,
        },
        Wave3Case {
            name: "mcp_list_entries",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/mcp/trust-store",
            body: None,
        },
        Wave3Case {
            name: "mcp_create_entry",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/mcp/trust-store",
            body: Some(json!({ "subject": "a" })),
        },
        Wave3Case {
            name: "mcp_get_entry",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1",
            body: None,
        },
        Wave3Case {
            name: "mcp_update_entry",
            method: "PATCH",
            path: "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1",
            body: Some(json!({ "name": "n" })),
        },
        Wave3Case {
            name: "mcp_delete_entry",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1",
            body: None,
        },
        Wave3Case {
            name: "mcp_add_key",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/keys",
            body: Some(json!({ "jwk": {} })),
        },
        Wave3Case {
            name: "mcp_revoke_key",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/keys/key_1",
            body: None,
        },
        Wave3Case {
            name: "mcp_rotate_key",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/keys/key_1/rotate",
            body: None,
        },
        Wave3Case {
            name: "mcp_revoke_entry",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/revoke",
            body: None,
        },
        Wave3Case {
            name: "mcp_verify_entry",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/verify",
            body: Some(json!({ "verified": true })),
        },
        Wave3Case {
            name: "users_totp_status",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/me/mfa/totp",
            body: None,
        },
        Wave3Case {
            name: "settings_get_password_policy",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/password-policy",
            body: None,
        },
        Wave3Case {
            name: "settings_update_password_policy",
            method: "PUT",
            path: "/v1/tenants/ten_1/environments/env_1/password-policy",
            body: Some(json!({ "minLength": 8 })),
        },
        Wave3Case {
            name: "portal_generate_link",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/portal/generate-link",
            body: Some(json!({ "email": "a@b.c" })),
        },
        Wave3Case {
            name: "settings_get_rate_limit_policy",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/rate-limit-policy",
            body: None,
        },
        Wave3Case {
            name: "settings_update_rate_limit_policy",
            method: "PUT",
            path: "/v1/tenants/ten_1/environments/env_1/rate-limit-policy",
            body: Some(json!({ "limit": 10 })),
        },
        Wave3Case {
            name: "env_save_redirect_uris",
            method: "PUT",
            path: "/v1/tenants/ten_1/environments/env_1/redirect-uris",
            body: Some(json!({ "uris": [] })),
        },
        Wave3Case {
            name: "settings_get_restrictions",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/restrictions",
            body: None,
        },
        Wave3Case {
            name: "settings_update_restrictions",
            method: "PUT",
            path: "/v1/tenants/ten_1/environments/env_1/restrictions",
            body: Some(json!({ "signup": false })),
        },
        Wave3Case {
            name: "provisioning_list_scim",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/scim-tokens",
            body: None,
        },
        Wave3Case {
            name: "provisioning_create_scim",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/scim-tokens",
            body: Some(json!({ "name": "scim" })),
        },
        Wave3Case {
            name: "provisioning_revoke_scim",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/scim-tokens/tok_1/revoke",
            body: None,
        },
        Wave3Case {
            name: "provisioning_rotate_scim",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/scim-tokens/tok_1/rotate",
            body: None,
        },
        Wave3Case {
            name: "security_posture",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/security/posture",
            body: None,
        },
        Wave3Case {
            name: "settings_get_session_config",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/session-config",
            body: None,
        },
        Wave3Case {
            name: "settings_update_session_config",
            method: "PUT",
            path: "/v1/tenants/ten_1/environments/env_1/session-config",
            body: Some(json!({ "ttl": 3600 })),
        },
        Wave3Case {
            name: "threats_list",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/threats",
            body: None,
        },
        Wave3Case {
            name: "threats_create",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/threats",
            body: Some(json!({ "type": "bot" })),
        },
        Wave3Case {
            name: "threats_get",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/threats/th_1",
            body: None,
        },
        Wave3Case {
            name: "threats_update",
            method: "PATCH",
            path: "/v1/tenants/ten_1/environments/env_1/threats/th_1",
            body: Some(json!({ "status": "open" })),
        },
        Wave3Case {
            name: "threats_delete",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/threats/th_1",
            body: None,
        },
        Wave3Case {
            name: "threats_resolve",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/threats/th_1/resolve",
            body: Some(json!({ "status": "resolved" })),
        },
        Wave3Case {
            name: "users_bulk_delete",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/users/bulk/delete",
            body: Some(json!({ "userIds": ["usr_1"] })),
        },
        Wave3Case {
            name: "users_bulk_set_active",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/users/bulk/set-active",
            body: Some(json!({ "userIds": ["usr_1"], "active": false })),
        },
        Wave3Case {
            name: "users_import_users",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/users/import",
            body: Some(json!({ "users": [] })),
        },
        Wave3Case {
            name: "users_disable_mfa",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/users/usr_1/mfa",
            body: None,
        },
        Wave3Case {
            name: "users_list_sessions",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/users/usr_1/sessions",
            body: None,
        },
        Wave3Case {
            name: "vanity_domains_list",
            method: "GET",
            path: "/v1/tenants/ten_1/environments/env_1/vanity-domains",
            body: None,
        },
        Wave3Case {
            name: "vanity_domains_create",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/vanity-domains",
            body: Some(json!({ "domain": "a.com" })),
        },
        Wave3Case {
            name: "vanity_domains_delete",
            method: "DELETE",
            path: "/v1/tenants/ten_1/environments/env_1/vanity-domains/dom_1",
            body: None,
        },
        Wave3Case {
            name: "vanity_domains_check",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/vanity-domains/dom_1/check",
            body: None,
        },
        Wave3Case {
            name: "widgets_create_token",
            method: "POST",
            path: "/v1/tenants/ten_1/environments/env_1/widgets/token",
            body: Some(json!({ "ttl": 60 })),
        },
        Wave3Case {
            name: "otel_export_traces",
            method: "POST",
            path: "/v1/traces",
            body: Some(json!({ "resourceSpans": [] })),
        },
    ]
}

async fn invoke_wave3(client: &AuthdogClient, case: &Wave3Case) -> Result<(), AuthdogError> {
    let empty = json!({});
    let body = case.body.as_ref().unwrap_or(&empty);
    match case.name {
        "authzen_configuration" => {
            client.authzen().configuration().await?;
        }
        "authzen_evaluate" => {
            client.authzen().evaluate(body, None).await?;
        }
        "authzen_evaluate_batch" => {
            client.authzen().evaluate_batch(body, None).await?;
        }
        "authzen_search_action" => {
            client.authzen().search_action(body, None).await?;
        }
        "authzen_search_resource" => {
            client.authzen().search_resource(body, None).await?;
        }
        "authzen_search_subject" => {
            client.authzen().search_subject(body, None).await?;
        }
        "users_revoke_session" => {
            client.users().revoke_session("env_1", "sess_1").await?;
        }
        "hris_list_departments" => {
            client.hris().list_departments(None).await?;
        }
        "hris_create_department" => {
            client.hris().create_department(body, None).await?;
        }
        "hris_get_department" => {
            client.hris().get_department("dep_1", None).await?;
        }
        "hris_replace_department" => {
            client
                .hris()
                .replace_department("dep_1", body, None)
                .await?;
        }
        "hris_patch_department" => {
            client.hris().patch_department("dep_1", body, None).await?;
        }
        "hris_delete_department" => {
            client.hris().delete_department("dep_1", None).await?;
        }
        "hris_list_employees" => {
            client.hris().list_employees(None).await?;
        }
        "hris_create_employee" => {
            client.hris().create_employee(body, None).await?;
        }
        "hris_get_employee" => {
            client.hris().get_employee("emp_1", None).await?;
        }
        "hris_replace_employee" => {
            client.hris().replace_employee("emp_1", body, None).await?;
        }
        "hris_patch_employee" => {
            client.hris().patch_employee("emp_1", body, None).await?;
        }
        "hris_delete_employee" => {
            client.hris().delete_employee("emp_1", None).await?;
        }
        "hris_service_config" => {
            client.hris().service_config(None).await?;
        }
        "otel_export_logs" => {
            client.otel().export_logs(body).await?;
        }
        "mcp_ingest_events" => {
            client.mcp().ingest_events(body, None).await?;
        }
        "mcp_resolve" => {
            client.mcp().resolve("agent-1", None).await?;
        }
        "otel_export_metrics" => {
            client.otel().export_metrics(body).await?;
        }
        "otel_export_logs_prefixed" => {
            client.otel().export_logs_prefixed(body).await?;
        }
        "otel_export_metrics_prefixed" => {
            client.otel().export_metrics_prefixed(body).await?;
        }
        "otel_export_traces_prefixed" => {
            client.otel().export_traces_prefixed(body).await?;
        }
        "scim_list_groups" => {
            client.scim().list_groups(None).await?;
        }
        "scim_create_group" => {
            client.scim().create_group(body, None).await?;
        }
        "scim_get_group" => {
            client.scim().get_group("g_1", None).await?;
        }
        "scim_replace_group" => {
            client.scim().replace_group("g_1", body, None).await?;
        }
        "scim_patch_group" => {
            client.scim().patch_group("g_1", body, None).await?;
        }
        "scim_delete_group" => {
            client.scim().delete_group("g_1", None).await?;
        }
        "scim_resource_types" => {
            client.scim().resource_types(None).await?;
        }
        "scim_resource_type" => {
            client.scim().resource_type("User", None).await?;
        }
        "scim_schemas" => {
            client.scim().schemas(None).await?;
        }
        "scim_schema" => {
            client
                .scim()
                .schema("urn:ietf:params:scim:schemas:core:2.0:User", None)
                .await?;
        }
        "scim_service_provider_config" => {
            client.scim().service_provider_config(None).await?;
        }
        "scim_list_users" => {
            client.scim().list_users(None).await?;
        }
        "scim_create_user" => {
            client.scim().create_user(body, None).await?;
        }
        "scim_get_user" => {
            client.scim().get_user("u_1", None).await?;
        }
        "scim_replace_user" => {
            client.scim().replace_user("u_1", body, None).await?;
        }
        "scim_patch_user" => {
            client.scim().patch_user("u_1", body, None).await?;
        }
        "scim_delete_user" => {
            client.scim().delete_user("u_1", None).await?;
        }
        "env_list_connections" => {
            client
                .environments()
                .list_connections("ten_1", "app_1", "env_1")
                .await?;
        }
        "oidc_list" => {
            client
                .oidc_clients()
                .list("ten_1", "app_1", "env_1")
                .await?;
        }
        "oidc_register" => {
            client
                .oidc_clients()
                .register("ten_1", "app_1", "env_1", body)
                .await?;
        }
        "oidc_update" => {
            client
                .oidc_clients()
                .update("ten_1", "app_1", "env_1", "cid_1", body)
                .await?;
        }
        "oidc_delete" => {
            client
                .oidc_clients()
                .delete("ten_1", "app_1", "env_1", "cid_1")
                .await?;
        }
        "env_list_redirect_uris" => {
            client
                .environments()
                .list_redirect_uris("ten_1", "app_1", "env_1")
                .await?;
        }
        "actions_list" => {
            client.actions().list("ten_1", "env_1").await?;
        }
        "actions_save" => {
            client.actions().save("ten_1", "env_1", body).await?;
        }
        "actions_executions" => {
            client
                .actions()
                .executions("ten_1", "env_1", None, None)
                .await?;
        }
        "actions_test" => {
            client.actions().test("ten_1", "env_1", body).await?;
        }
        "actions_delete" => {
            client.actions().delete("ten_1", "env_1", "act_1").await?;
        }
        "addons_list" => {
            client.addons().list("ten_1", "env_1").await?;
        }
        "addons_save" => {
            client.addons().save("ten_1", "env_1", body).await?;
        }
        "addons_delete" => {
            client.addons().delete("ten_1", "env_1", "slack").await?;
        }
        "billing_list_features" => {
            client.billing().list_features("ten_1", "env_1").await?;
        }
        "billing_save_feature" => {
            client
                .billing()
                .save_feature("ten_1", "env_1", body)
                .await?;
        }
        "billing_delete_feature" => {
            client
                .billing()
                .delete_feature("ten_1", "env_1", "feat_1")
                .await?;
        }
        "billing_list_plans" => {
            client.billing().list_plans("ten_1", "env_1").await?;
        }
        "billing_save_plan" => {
            client.billing().save_plan("ten_1", "env_1", body).await?;
        }
        "billing_delete_plan" => {
            client
                .billing()
                .delete_plan("ten_1", "env_1", "plan_1")
                .await?;
        }
        "billing_sync_stripe" => {
            client
                .billing()
                .sync_stripe("ten_1", "env_1", "plan_1")
                .await?;
        }
        "settings_get_bot_detection_policy" => {
            client
                .settings()
                .get_bot_detection_policy("ten_1", "env_1")
                .await?;
        }
        "settings_update_bot_detection_policy" => {
            client
                .settings()
                .update_bot_detection_policy("ten_1", "env_1", body)
                .await?;
        }
        "settings_get_breached_password_policy" => {
            client
                .settings()
                .get_breached_password_policy("ten_1", "env_1")
                .await?;
        }
        "settings_update_breached_password_policy" => {
            client
                .settings()
                .update_breached_password_policy("ten_1", "env_1", body)
                .await?;
        }
        "settings_get_brute_force_policy" => {
            client
                .settings()
                .get_brute_force_policy("ten_1", "env_1")
                .await?;
        }
        "settings_update_brute_force_policy" => {
            client
                .settings()
                .update_brute_force_policy("ten_1", "env_1", body)
                .await?;
        }
        "env_save_connection" => {
            client
                .environments()
                .save_connection("ten_1", "env_1", body)
                .await?;
        }
        "env_resolve_saml_metadata" => {
            client
                .environments()
                .resolve_saml_metadata("ten_1", "env_1", body)
                .await?;
        }
        "env_get_sso_metadata" => {
            client
                .environments()
                .get_sso_metadata("ten_1", "env_1", None, None)
                .await?;
        }
        "env_delete_connection" => {
            client
                .environments()
                .delete_connection("ten_1", "env_1", "con_1")
                .await?;
        }
        "settings_get_device_risk_policy" => {
            client
                .settings()
                .get_device_risk_policy("ten_1", "env_1")
                .await?;
        }
        "settings_update_device_risk_policy" => {
            client
                .settings()
                .update_device_risk_policy("ten_1", "env_1", body)
                .await?;
        }
        "elevate_activate_grant" => {
            client
                .elevate()
                .activate_grant("ten_1", "env_1", "gr_1", body)
                .await?;
        }
        "elevate_revoke_grant" => {
            client
                .elevate()
                .revoke_grant("ten_1", "env_1", "gr_1", body)
                .await?;
        }
        "elevate_list_requests" => {
            client
                .elevate()
                .list_requests("ten_1", "env_1", None)
                .await?;
        }
        "elevate_create_request" => {
            client
                .elevate()
                .create_request("ten_1", "env_1", body)
                .await?;
        }
        "elevate_get_request" => {
            client
                .elevate()
                .get_request("ten_1", "env_1", "req_1")
                .await?;
        }
        "elevate_approve_request" => {
            client
                .elevate()
                .approve_request("ten_1", "env_1", "req_1", body)
                .await?;
        }
        "elevate_cancel_request" => {
            client
                .elevate()
                .cancel_request("ten_1", "env_1", "req_1")
                .await?;
        }
        "elevate_deny_request" => {
            client
                .elevate()
                .deny_request("ten_1", "env_1", "req_1", body)
                .await?;
        }
        "elevate_get_policy" => {
            client.elevate().get_policy("ten_1", "env_1").await?;
        }
        "elevate_update_policy" => {
            client
                .elevate()
                .update_policy("ten_1", "env_1", body)
                .await?;
        }
        "email_providers_list" => {
            client.email_providers().list("ten_1", "env_1").await?;
        }
        "email_providers_save" => {
            client
                .email_providers()
                .save("ten_1", "env_1", body)
                .await?;
        }
        "email_providers_test" => {
            client
                .email_providers()
                .test("ten_1", "env_1", body)
                .await?;
        }
        "email_providers_delete" => {
            client
                .email_providers()
                .delete("ten_1", "env_1", "ses")
                .await?;
        }
        "email_providers_activate" => {
            client
                .email_providers()
                .activate("ten_1", "env_1", "ses")
                .await?;
        }
        "feature_flags_list" => {
            client.feature_flags().list("ten_1", "env_1").await?;
        }
        "feature_flags_save" => {
            client.feature_flags().save("ten_1", "env_1", body).await?;
        }
        "feature_flags_delete" => {
            client
                .feature_flags()
                .delete("ten_1", "env_1", "flag_1")
                .await?;
        }
        "forms_list_attachments" => {
            client.forms().list_attachments("ten_1", "env_1").await?;
        }
        "forms_list" => {
            client.forms().list("ten_1", "env_1").await?;
        }
        "forms_save" => {
            client.forms().save("ten_1", "env_1", body).await?;
        }
        "forms_delete" => {
            client.forms().delete("ten_1", "env_1", "form_1").await?;
        }
        "provisioning_list_hris" => {
            client
                .provisioning_tokens()
                .list_hris("ten_1", "env_1")
                .await?;
        }
        "provisioning_create_hris" => {
            client
                .provisioning_tokens()
                .create_hris("ten_1", "env_1", body)
                .await?;
        }
        "provisioning_revoke_hris" => {
            client
                .provisioning_tokens()
                .revoke_hris("ten_1", "env_1", "tok_1")
                .await?;
        }
        "provisioning_rotate_hris" => {
            client
                .provisioning_tokens()
                .rotate_hris("ten_1", "env_1", "tok_1")
                .await?;
        }
        "impersonation_list" => {
            client.impersonation().list("ten_1", "env_1").await?;
        }
        "impersonation_create" => {
            client
                .impersonation()
                .create("ten_1", "env_1", body)
                .await?;
        }
        "impersonation_revoke" => {
            client
                .impersonation()
                .revoke("ten_1", "env_1", "gr_1")
                .await?;
        }
        "settings_list_jwt_claim_mappings" => {
            client
                .settings()
                .list_jwt_claim_mappings("ten_1", "env_1")
                .await?;
        }
        "settings_save_jwt_claim_mapping" => {
            client
                .settings()
                .save_jwt_claim_mapping("ten_1", "env_1", body)
                .await?;
        }
        "settings_delete_jwt_claim_mapping" => {
            client
                .settings()
                .delete_jwt_claim_mapping("ten_1", "env_1", "map_1")
                .await?;
        }
        "mcp_list_entries" => {
            client.mcp().list_entries("ten_1", "env_1").await?;
        }
        "mcp_create_entry" => {
            client.mcp().create_entry("ten_1", "env_1", body).await?;
        }
        "mcp_get_entry" => {
            client.mcp().get_entry("ten_1", "env_1", "ent_1").await?;
        }
        "mcp_update_entry" => {
            client
                .mcp()
                .update_entry("ten_1", "env_1", "ent_1", body)
                .await?;
        }
        "mcp_delete_entry" => {
            client.mcp().delete_entry("ten_1", "env_1", "ent_1").await?;
        }
        "mcp_add_key" => {
            client
                .mcp()
                .add_key("ten_1", "env_1", "ent_1", body)
                .await?;
        }
        "mcp_revoke_key" => {
            client
                .mcp()
                .revoke_key("ten_1", "env_1", "ent_1", "key_1")
                .await?;
        }
        "mcp_rotate_key" => {
            client
                .mcp()
                .rotate_key("ten_1", "env_1", "ent_1", "key_1", None)
                .await?;
        }
        "mcp_revoke_entry" => {
            client.mcp().revoke_entry("ten_1", "env_1", "ent_1").await?;
        }
        "mcp_verify_entry" => {
            client
                .mcp()
                .verify_entry("ten_1", "env_1", "ent_1", body)
                .await?;
        }
        "users_totp_status" => {
            client.users().totp_status("ten_1", "env_1").await?;
        }
        "settings_get_password_policy" => {
            client
                .settings()
                .get_password_policy("ten_1", "env_1")
                .await?;
        }
        "settings_update_password_policy" => {
            client
                .settings()
                .update_password_policy("ten_1", "env_1", body)
                .await?;
        }
        "portal_generate_link" => {
            client
                .portal()
                .generate_link("ten_1", "env_1", body)
                .await?;
        }
        "settings_get_rate_limit_policy" => {
            client
                .settings()
                .get_rate_limit_policy("ten_1", "env_1")
                .await?;
        }
        "settings_update_rate_limit_policy" => {
            client
                .settings()
                .update_rate_limit_policy("ten_1", "env_1", body)
                .await?;
        }
        "env_save_redirect_uris" => {
            client
                .environments()
                .save_redirect_uris("ten_1", "env_1", body)
                .await?;
        }
        "settings_get_restrictions" => {
            client.settings().get_restrictions("ten_1", "env_1").await?;
        }
        "settings_update_restrictions" => {
            client
                .settings()
                .update_restrictions("ten_1", "env_1", body)
                .await?;
        }
        "provisioning_list_scim" => {
            client
                .provisioning_tokens()
                .list_scim("ten_1", "env_1")
                .await?;
        }
        "provisioning_create_scim" => {
            client
                .provisioning_tokens()
                .create_scim("ten_1", "env_1", body)
                .await?;
        }
        "provisioning_revoke_scim" => {
            client
                .provisioning_tokens()
                .revoke_scim("ten_1", "env_1", "tok_1")
                .await?;
        }
        "provisioning_rotate_scim" => {
            client
                .provisioning_tokens()
                .rotate_scim("ten_1", "env_1", "tok_1")
                .await?;
        }
        "security_posture" => {
            client.security().posture("ten_1", "env_1").await?;
        }
        "settings_get_session_config" => {
            client
                .settings()
                .get_session_config("ten_1", "env_1")
                .await?;
        }
        "settings_update_session_config" => {
            client
                .settings()
                .update_session_config("ten_1", "env_1", body)
                .await?;
        }
        "threats_list" => {
            client.threats().list("ten_1", "env_1", None).await?;
        }
        "threats_create" => {
            client.threats().create("ten_1", "env_1", body).await?;
        }
        "threats_get" => {
            client.threats().get("ten_1", "env_1", "th_1").await?;
        }
        "threats_update" => {
            client
                .threats()
                .update("ten_1", "env_1", "th_1", body)
                .await?;
        }
        "threats_delete" => {
            client.threats().delete("ten_1", "env_1", "th_1").await?;
        }
        "threats_resolve" => {
            client
                .threats()
                .resolve("ten_1", "env_1", "th_1", body)
                .await?;
        }
        "users_bulk_delete" => {
            client.users().bulk_delete("ten_1", "env_1", body).await?;
        }
        "users_bulk_set_active" => {
            client
                .users()
                .bulk_set_active("ten_1", "env_1", body)
                .await?;
        }
        "users_import_users" => {
            client.users().import_users("ten_1", "env_1", body).await?;
        }
        "users_disable_mfa" => {
            client
                .users()
                .disable_mfa("ten_1", "env_1", "usr_1")
                .await?;
        }
        "users_list_sessions" => {
            client
                .users()
                .list_sessions("ten_1", "env_1", "usr_1")
                .await?;
        }
        "vanity_domains_list" => {
            client.vanity_domains().list("ten_1", "env_1").await?;
        }
        "vanity_domains_create" => {
            client
                .vanity_domains()
                .create("ten_1", "env_1", body)
                .await?;
        }
        "vanity_domains_delete" => {
            client
                .vanity_domains()
                .delete("ten_1", "env_1", "dom_1")
                .await?;
        }
        "vanity_domains_check" => {
            client
                .vanity_domains()
                .check("ten_1", "env_1", "dom_1")
                .await?;
        }
        "widgets_create_token" => {
            client
                .widgets()
                .create_token("ten_1", "env_1", body)
                .await?;
        }
        "otel_export_traces" => {
            client.otel().export_traces(body).await?;
        }
        other => panic!("unknown case {other}"),
    }
    Ok(())
}

#[tokio::test]
async fn test_wave3_method_and_path() {
    let cases = wave3_cases();
    assert_eq!(cases.len(), 152, "expected all 152 Wave 3 paths");
    for case in cases {
        let mock_server = MockServer::start().await;
        Mock::given(method(case.method))
            .and(path(case.path))
            .respond_with(ResponseTemplate::new(200).set_body_json(json!({})))
            .expect(1)
            .mount(&mock_server)
            .await;

        let client = client_against(&mock_server).await;
        invoke_wave3(&client, &case)
            .await
            .unwrap_or_else(|err| panic!("{} failed: {err}", case.name));

        let requests = mock_server.received_requests().await.unwrap();
        assert_eq!(requests.len(), 1, "{}", case.name);
        let request = &requests[0];
        assert_eq!(request.method.as_str(), case.method, "{}", case.name);
        assert_eq!(request.url.path(), case.path, "{}", case.name);
        if let Some(expected) = &case.body {
            let actual: Value = serde_json::from_slice(&request.body).unwrap_or(Value::Null);
            assert_eq!(&actual, expected, "body mismatch for {}", case.name);
        }
    }
}

#[tokio::test]
async fn test_wave3_authzen_discovery_omits_bearer() {
    let mock_server = MockServer::start().await;
    Mock::given(method("GET"))
        .and(path("/.well-known/authzen-configuration"))
        .respond_with(ResponseTemplate::new(200).set_body_json(json!({})))
        .mount(&mock_server)
        .await;

    let client = client_against(&mock_server).await;
    client.authzen().configuration().await.unwrap();

    let requests = mock_server.received_requests().await.unwrap();
    assert_eq!(requests.len(), 1);
    assert_eq!(requests[0].url.path(), "/.well-known/authzen-configuration");
    assert!(
        !requests[0].headers.contains_key("authorization"),
        "AuthZEN discovery must send no Authorization header"
    );
}

#[tokio::test]
async fn test_wave3_authzen_evaluate_uses_environment_secret() {
    let mock_server = MockServer::start().await;
    Mock::given(method("POST"))
        .and(path("/access/v1/evaluation"))
        .and(header("Authorization", "Bearer adenv_secret"))
        .respond_with(ResponseTemplate::new(200).set_body_json(json!({ "decision": "Permit" })))
        .expect(1)
        .mount(&mock_server)
        .await;

    let config = AuthdogClientConfig {
        base_url: mock_server.uri(),
        api_key: Some("key-1".to_string()),
        environment_secret: Some("adenv_secret".to_string()),
        timeout: Some(Duration::from_secs(10)),
        ..Default::default()
    };
    let client = AuthdogClient::new(config).unwrap();
    let result = client
        .authzen()
        .evaluate(json!({ "subject": { "id": "u" } }), None)
        .await
        .unwrap();
    assert_eq!(
        result.get("decision").and_then(Value::as_str),
        Some("Permit")
    );
}

#[tokio::test]
async fn test_wave3_scim_and_hris_use_specialized_tokens() {
    let mock_server = MockServer::start().await;
    Mock::given(method("GET"))
        .and(path("/v1/scim/v2/Users"))
        .and(header("Authorization", "Bearer adscim_token"))
        .respond_with(ResponseTemplate::new(200).set_body_json(json!({})))
        .expect(1)
        .mount(&mock_server)
        .await;
    Mock::given(method("GET"))
        .and(path("/v1/hris/v1/Employees"))
        .and(header("Authorization", "Bearer adhris_token"))
        .respond_with(ResponseTemplate::new(200).set_body_json(json!({})))
        .expect(1)
        .mount(&mock_server)
        .await;

    let config = AuthdogClientConfig {
        base_url: mock_server.uri(),
        api_key: Some("key-1".to_string()),
        scim_token: Some("adscim_token".to_string()),
        hris_token: Some("adhris_token".to_string()),
        timeout: Some(Duration::from_secs(10)),
        ..Default::default()
    };
    let client = AuthdogClient::new(config).unwrap();
    client.scim().list_users(None).await.unwrap();
    client.hris().list_employees(None).await.unwrap();
}

#[tokio::test]
async fn test_wave3_create_scim_token_exposes_one_time_secret() {
    let mock_server = MockServer::start().await;
    Mock::given(method("POST"))
        .and(path("/v1/tenants/ten_1/environments/env_1/scim-tokens"))
        .respond_with(ResponseTemplate::new(200).set_body_json(json!({
            "token": "adscim_once",
            "id": "tok_1"
        })))
        .mount(&mock_server)
        .await;

    let client = client_against(&mock_server).await;
    let created = client
        .provisioning_tokens()
        .create_scim("ten_1", "env_1", json!({ "name": "scim" }))
        .await
        .unwrap();
    assert_eq!(
        created.get("token").and_then(Value::as_str),
        Some("adscim_once")
    );
}

#[tokio::test]
async fn test_wave3_query_params_forwarded() {
    let mock_server = MockServer::start().await;
    Mock::given(wiremock::matchers::any())
        .respond_with(ResponseTemplate::new(200).set_body_json(json!({})))
        .mount(&mock_server)
        .await;

    let client = client_against(&mock_server).await;
    client.mcp().resolve("agent-1", None).await.unwrap();
    client
        .threats()
        .list(
            "ten_1",
            "env_1",
            Some(&json!({ "status": "open", "limit": 10 })),
        )
        .await
        .unwrap();
    client
        .elevate()
        .list_requests("ten_1", "env_1", Some("pending"))
        .await
        .unwrap();

    let requests = mock_server.received_requests().await.unwrap();
    assert_eq!(requests.len(), 3);
    assert_eq!(requests[0].url.path(), "/v1/mcp/trust-store/resolve");
    let resolve_pairs: std::collections::HashMap<String, String> =
        requests[0].url.query_pairs().into_owned().collect();
    assert_eq!(
        resolve_pairs.get("subject").map(String::as_str),
        Some("agent-1")
    );

    let threat_pairs: std::collections::HashMap<String, String> =
        requests[1].url.query_pairs().into_owned().collect();
    assert_eq!(threat_pairs.get("status").map(String::as_str), Some("open"));
    assert_eq!(threat_pairs.get("limit").map(String::as_str), Some("10"));

    let elevate_pairs: std::collections::HashMap<String, String> =
        requests[2].url.query_pairs().into_owned().collect();
    assert_eq!(
        elevate_pairs.get("status").map(String::as_str),
        Some("pending")
    );
}
