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
