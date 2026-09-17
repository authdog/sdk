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
            let actual: Value =
                serde_json::from_slice(&request.body).unwrap_or_else(|_| json!(null));
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
