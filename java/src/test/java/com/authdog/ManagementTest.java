package com.authdog;

import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.authdog.types.EnvUsersResponse;
import com.authdog.types.OrganizationsList;
import com.authdog.types.TenantsList;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import okhttp3.mockwebserver.MockResponse;
import okhttp3.mockwebserver.MockWebServer;
import okhttp3.mockwebserver.RecordedRequest;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

import java.io.IOException;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Consumer;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ManagementTest {

    private MockWebServer mockServer;
    private AuthdogClient client;
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() throws IOException {
        mockServer = new MockWebServer();
        mockServer.start();
        objectMapper = new ObjectMapper();
    }

    @AfterEach
    void tearDown() throws IOException {
        if (client != null) {
            client.close();
        }
        mockServer.shutdown();
    }

    @Test
    void testOrganizationsListEmptyAndUsesApiKey() throws Exception {
        enqueueJson(200, "{\"organizations\":[],\"total\":0}");
        client = newClient();

        OrganizationsList listed = client.organizations().list();
        assertNotNull(listed);
        assertTrue(listed.getOrganizations().isEmpty());
        assertEquals(0, listed.getTotal());

        RecordedRequest request = mockServer.takeRequest();
        assertEquals("GET", request.getMethod());
        assertEquals("/v1/organizations", request.getPath());
        assertEquals("Bearer key-1", request.getHeader("Authorization"));
        assertEquals("application/json", request.getHeader("Content-Type"));
        assertEquals("authdog-java-sdk/0.1.0", request.getHeader("User-Agent"));
    }

    @Test
    void testTenantsListEmpty() throws Exception {
        enqueueJson(200, "{\"tenants\":[],\"total\":0}");
        client = newClient();

        TenantsList listed = client.tenants().list();
        assertTrue(listed.getTenants().isEmpty());
        assertEquals(0, listed.getTotal());
    }

    @Test
    void testUsersListEmptyAndItem() throws Exception {
        enqueueJson(200, "{\"users\":[{\"id\":\"usr_1\","
                + "\"displayName\":\"Ada\","
                + "\"emails\":[{\"value\":\"ada@example.com\"}]}]}");
        client = newClient();

        EnvUsersResponse listed = client.users().list("ten_1", "env_1");
        assertEquals(1, listed.getUsers().size());
        assertEquals("usr_1", listed.getUsers().get(0).getId());
        assertEquals("Ada", listed.getUsers().get(0).getDisplayName());
        assertEquals("ada@example.com",
                listed.getUsers().get(0).getEmails().get(0).getValue());

        enqueueJson(200, "{\"users\":[]}");
        assertTrue(client.users().list("ten_1", "env_1").getUsers().isEmpty());
    }

    @Test
    void testGroupsListEmpty() throws Exception {
        enqueueJson(200, "{\"groups\":[]}");
        client = newClient();
        assertTrue(client.groups().list("ten_1", "env_1").getGroups().isEmpty());
    }

    @Test
    void testManagement401IsAuthenticationException() {
        mockServer.enqueue(new MockResponse().setResponseCode(401)
                .setBody("{}"));
        client = newClient();

        AuthenticationException exception = assertThrows(
                AuthenticationException.class,
                () -> client.organizations().list());
        assertEquals("Unauthorized - invalid or expired token",
                exception.getMessage());
    }

    @Test
    void testManagement404IncludesStatusAndError() {
        mockServer.enqueue(new MockResponse()
                .setResponseCode(404)
                .setHeader("Content-Type", "application/json")
                .setBody("{\"error\":\"not found\"}"));
        client = newClient();

        ApiException exception = assertThrows(ApiException.class,
                () -> client.organizations().get("missing"));
        assertTrue(exception.getMessage().contains("HTTP error 404"));
        assertTrue(exception.getMessage().contains("not found"));
    }

    @Test
    void testManagementTransportError() throws Exception {
        String url = mockServer.url("/").toString();
        mockServer.shutdown();
        client = new AuthdogClient(url, "key-1");

        ApiException exception = assertThrows(ApiException.class,
                () -> client.tenants().list());
        assertTrue(exception.getMessage().contains("Request failed"));
    }

    @ParameterizedTest(name = "{0}")
    @MethodSource("wave1Cases")
    void testWave1MethodAndPath(final String name,
                                final Consumer<AuthdogClient> call,
                                final String method,
                                final String path,
                                final String body) throws Exception {
        enqueueJson(200, "{}");
        client = newClient();
        call.accept(client);

        RecordedRequest request = mockServer.takeRequest();
        assertEquals(method, request.getMethod());
        assertEquals(path, request.getPath());
        assertJsonBody(body, request.getBody().readUtf8());
        assertEquals("Bearer key-1", request.getHeader("Authorization"));
    }

    @ParameterizedTest(name = "{0}")
    @MethodSource("wave2Cases")
    void testWave2MethodAndPath(final String name,
                                final Consumer<AuthdogClient> call,
                                final String method,
                                final String path,
                                final String body) throws Exception {
        enqueueJson(200, "{}");
        client = newClient();
        call.accept(client);

        RecordedRequest request = mockServer.takeRequest();
        assertEquals(method, request.getMethod());
        assertEquals(path, request.getPath());
        assertJsonBody(body, request.getBody().readUtf8());
        assertEquals("Bearer key-1", request.getHeader("Authorization"));
    }

    @Test
    void testWave2CreateKeyExposesOneTimeSecret() throws Exception {
        enqueueJson(200,
                "{\"token\":\"orgk_secret_once\","
                        + "\"key\":{\"id\":\"key_1\"}}");
        client = newClient();

        JsonNode created = client.organizations()
                .createKey("org_1", mapOf("name", "ci"));
        assertEquals("orgk_secret_once",
                created.get("token").asText());
    }

    @Test
    void testWave2AuditForwardsQueryParams() throws Exception {
        enqueueJson(200, "{}");
        client = newClient();
        Map<String, String> params = new LinkedHashMap<>();
        params.put("limit", "50");
        params.put("after", "cur_1");
        client.events().list("ten_1", "env_1", params);

        RecordedRequest request = mockServer.takeRequest();
        assertEquals("GET", request.getMethod());
        assertEquals("/v1/tenants/ten_1/environments/env_1/events"
                + "?limit=50&after=cur_1", request.getPath());
    }

    static Stream<Arguments> wave1Cases() {
        return Stream.of(
                caseOf("orgs list",
                        c -> c.organizations().list(),
                        "GET", "/v1/organizations", null),
                caseOf("orgs create",
                        c -> c.organizations().create(mapOf("name", "Acme")),
                        "POST", "/v1/organizations",
                        "{\"name\":\"Acme\"}"),
                caseOf("orgs get",
                        c -> c.organizations().get("org_1"),
                        "GET", "/v1/organizations/org_1", null),
                caseOf("orgs update",
                        c -> c.organizations().update("org_1",
                                mapOf("name", "New")),
                        "PATCH", "/v1/organizations/org_1",
                        "{\"name\":\"New\"}"),
                caseOf("orgs delete",
                        c -> c.organizations().delete("org_1"),
                        "DELETE", "/v1/organizations/org_1", null),
                caseOf("orgs accept invitation",
                        c -> c.organizations().acceptInvitation(
                                mapOf("token", "t")),
                        "POST", "/v1/organizations/invitations/accept",
                        "{\"token\":\"t\"}"),
                caseOf("orgs join",
                        c -> c.organizations().join(
                                mapOf("invitationCode", "c")),
                        "POST", "/v1/organizations/join",
                        "{\"invitationCode\":\"c\"}"),
                caseOf("orgs list invitations",
                        c -> c.organizations().listInvitations("org_1"),
                        "GET", "/v1/organizations/org_1/invitations", null),
                caseOf("orgs create invitation",
                        c -> c.organizations().createInvitation("org_1",
                                mapOf("email", "a@b.c")),
                        "POST", "/v1/organizations/org_1/invitations",
                        "{\"email\":\"a@b.c\"}"),
                caseOf("orgs cancel invitation",
                        c -> c.organizations().cancelInvitation(
                                "org_1", "inv_1"),
                        "POST",
                        "/v1/organizations/org_1/invitations/inv_1/cancel",
                        null),
                caseOf("orgs send invite",
                        c -> c.organizations().sendInvite("org_1",
                                mapOf("email", "a@b.c")),
                        "POST", "/v1/organizations/org_1/invites",
                        "{\"email\":\"a@b.c\"}"),
                caseOf("orgs list members",
                        c -> c.organizations().listMembers("org_1"),
                        "GET", "/v1/organizations/org_1/members", null),
                caseOf("orgs remove member",
                        c -> c.organizations().removeMember("org_1", "mem_1"),
                        "DELETE", "/v1/organizations/org_1/members/mem_1",
                        null),
                caseOf("orgs set member active",
                        c -> c.organizations().setMemberActive("org_1",
                                "mem_1", mapOf("active", false)),
                        "PATCH",
                        "/v1/organizations/org_1/members/mem_1/active",
                        "{\"active\":false}"),
                caseOf("orgs link tenant",
                        c -> c.organizations().linkTenant("org_1",
                                mapOf("tenantId", "ten_1")),
                        "POST", "/v1/organizations/org_1/tenants",
                        "{\"tenantId\":\"ten_1\"}"),
                caseOf("orgs unlink tenant",
                        c -> c.organizations().unlinkTenant("org_1", "ten_1"),
                        "DELETE", "/v1/organizations/org_1/tenants/ten_1",
                        null),
                caseOf("tenants list",
                        c -> c.tenants().list(),
                        "GET", "/v1/tenants", null),
                caseOf("tenants create",
                        c -> c.tenants().create(mapOf("name", "T")),
                        "POST", "/v1/tenants", "{\"name\":\"T\"}"),
                caseOf("tenants join",
                        c -> c.tenants().join(mapOf("invitationCode", "c")),
                        "POST", "/v1/tenants/join",
                        "{\"invitationCode\":\"c\"}"),
                caseOf("tenants get",
                        c -> c.tenants().get("ten_1"),
                        "GET", "/v1/tenants/ten_1", null),
                caseOf("tenants update",
                        c -> c.tenants().update("ten_1", mapOf("name", "N")),
                        "PATCH", "/v1/tenants/ten_1", "{\"name\":\"N\"}"),
                caseOf("tenants delete",
                        c -> c.tenants().delete("ten_1"),
                        "DELETE", "/v1/tenants/ten_1", null),
                caseOf("tenants list domains",
                        c -> c.tenants().listDomains("ten_1"),
                        "GET", "/v1/tenants/ten_1/domains", null),
                caseOf("tenants create domain",
                        c -> c.tenants().createDomain("ten_1",
                                mapOf("domain", "a.com",
                                        "validationMethod", "dns")),
                        "POST", "/v1/tenants/ten_1/domains",
                        "{\"domain\":\"a.com\","
                                + "\"validationMethod\":\"dns\"}"),
                caseOf("tenants delete domain",
                        c -> c.tenants().deleteDomain("ten_1", "dom_1"),
                        "DELETE", "/v1/tenants/ten_1/domains/dom_1", null),
                caseOf("tenants retry domain",
                        c -> c.tenants().retryDomain("ten_1", "dom_1"),
                        "POST", "/v1/tenants/ten_1/domains/dom_1/retry",
                        null),
                caseOf("tenants send invite",
                        c -> c.tenants().sendInvite("ten_1",
                                mapOf("email", "a@b.c")),
                        "POST", "/v1/tenants/ten_1/invites",
                        "{\"email\":\"a@b.c\"}"),
                caseOf("tenants list projects",
                        c -> c.tenants().listProjects("ten_1"),
                        "GET", "/v1/tenants/ten_1/projects", null),
                caseOf("tenants list seats",
                        c -> c.tenants().listSeats("ten_1"),
                        "GET", "/v1/tenants/ten_1/seats", null),
                caseOf("tenants update seat",
                        c -> c.tenants().updateSeat("ten_1", "seat_1",
                                mapOf("active", true)),
                        "PATCH", "/v1/tenants/ten_1/seats/seat_1",
                        "{\"active\":true}"),
                caseOf("tenants delete seat",
                        c -> c.tenants().deleteSeat("ten_1", "seat_1"),
                        "DELETE", "/v1/tenants/ten_1/seats/seat_1", null),
                caseOf("projects save",
                        c -> c.projects().save("ten_1", mapOf("name", "App")),
                        "POST", "/v1/tenants/ten_1/applications",
                        "{\"name\":\"App\"}"),
                caseOf("projects get",
                        c -> c.projects().get("ten_1", "app_1"),
                        "GET", "/v1/tenants/ten_1/applications/app_1",
                        null),
                caseOf("projects delete",
                        c -> c.projects().delete("ten_1", "app_1"),
                        "DELETE", "/v1/tenants/ten_1/applications/app_1",
                        null),
                caseOf("projects set default environment",
                        c -> c.projects().setDefaultEnvironment("ten_1",
                                "app_1", mapOf("environmentId", "env_1")),
                        "PUT",
                        "/v1/tenants/ten_1/applications/app_1/"
                                + "default-environment",
                        "{\"environmentId\":\"env_1\"}"),
                caseOf("environments list",
                        c -> c.environments().list("ten_1", "app_1"),
                        "GET",
                        "/v1/tenants/ten_1/applications/app_1/environments",
                        null),
                caseOf("environments create",
                        c -> c.environments().create("ten_1", "app_1",
                                mapOf("name", "prod")),
                        "POST",
                        "/v1/tenants/ten_1/applications/app_1/environments",
                        "{\"name\":\"prod\"}"),
                caseOf("environments update",
                        c -> c.environments().update("ten_1", "env_1",
                                mapOf("name", "prod")),
                        "PATCH", "/v1/tenants/ten_1/environments/env_1",
                        "{\"name\":\"prod\"}"),
                caseOf("environments delete",
                        c -> c.environments().delete("ten_1", "env_1"),
                        "DELETE", "/v1/tenants/ten_1/environments/env_1",
                        null),
                caseOf("users list",
                        c -> c.users().list("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1/users",
                        null),
                caseOf("users create",
                        c -> c.users().create("ten_1", "env_1",
                                mapOf("email", "a@b.c", "password", "x")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1/users",
                        "{\"email\":\"a@b.c\",\"password\":\"x\"}"),
                caseOf("users search",
                        c -> c.users().search("ten_1", "env_1", "ada"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1/users/search"
                                + "?q=ada",
                        null),
                caseOf("users count",
                        c -> c.users().count("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1/users/count",
                        null),
                caseOf("users get",
                        c -> c.users().get("ten_1", "env_1", "usr_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1/users/usr_1",
                        null),
                caseOf("users update",
                        c -> c.users().update("ten_1", "env_1", "usr_1",
                                mapOf("displayName", "Ada")),
                        "PUT",
                        "/v1/tenants/ten_1/environments/env_1/users/usr_1",
                        "{\"displayName\":\"Ada\"}"),
                caseOf("users delete",
                        c -> c.users().delete("ten_1", "env_1", "usr_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1/users/usr_1",
                        null),
                caseOf("users set active",
                        c -> c.users().setActive("ten_1", "env_1", "usr_1",
                                mapOf("active", false)),
                        "PATCH",
                        "/v1/tenants/ten_1/environments/env_1/users/usr_1"
                                + "/active",
                        "{\"active\":false}"),
                caseOf("users list groups",
                        c -> c.users().listGroups("ten_1", "env_1", "usr_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1/users/usr_1"
                                + "/groups",
                        null),
                caseOf("groups create",
                        c -> c.groups().create(mapOf("environmentId",
                                "env_1", "name", "Admins")),
                        "POST", "/v1/groups",
                        "{\"environmentId\":\"env_1\",\"name\":\"Admins\"}"),
                caseOf("groups list",
                        c -> c.groups().list("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1/groups",
                        null),
                caseOf("groups delete",
                        c -> c.groups().delete("ten_1", "env_1", "grp_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1/groups/grp_1",
                        null),
                caseOf("groups list members",
                        c -> c.groups().listMembers("ten_1", "env_1",
                                "grp_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1/groups/grp_1"
                                + "/members",
                        null),
                caseOf("groups add member",
                        c -> c.groups().addMember("ten_1", "env_1", "grp_1",
                                mapOf("userId", "usr_1")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1/groups/grp_1"
                                + "/members",
                        "{\"userId\":\"usr_1\"}"),
                caseOf("groups remove member",
                        c -> c.groups().removeMember("ten_1", "env_1",
                                "grp_1", "usr_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1/groups/grp_1"
                                + "/members/usr_1",
                        null)
        );
    }

    static Stream<Arguments> wave2Cases() {
        return Stream.of(
                caseOf("orgs list keys",
                        c -> c.organizations().listKeys("org_1"),
                        "GET", "/v1/organizations/org_1/keys", null),
                caseOf("orgs create key",
                        c -> c.organizations().createKey("org_1",
                                mapOf("name", "ci")),
                        "POST", "/v1/organizations/org_1/keys",
                        "{\"name\":\"ci\"}"),
                caseOf("orgs revoke key",
                        c -> c.organizations().revokeKey("org_1",
                                "key_1"),
                        "POST",
                        "/v1/organizations/org_1/keys/key_1/revoke",
                        null),
                caseOf("orgs rotate key",
                        c -> c.organizations().rotateKey("org_1",
                                "key_1"),
                        "POST",
                        "/v1/organizations/org_1/keys/key_1/rotate",
                        null),
                caseOf("orgs update key tenants",
                        c -> c.organizations().updateKeyTenants(
                                "org_1", "key_1",
                                mapOf("tenantIds",
                                        List.of("ten_1"))),
                        "PUT",
                        "/v1/organizations/org_1/keys/key_1/tenants",
                        "{\"tenantIds\":[\"ten_1\"]}"),
                caseOf("orgs list audit logs",
                        c -> c.organizations().listAuditLogs(
                                "org_1"),
                        "GET", "/v1/organizations/org_1/audit/logs",
                        null),
                caseOf("service accounts list",
                        c -> c.serviceAccounts().list(),
                        "GET", "/v1/service-accounts", null),
                caseOf("service accounts create",
                        c -> c.serviceAccounts().create(
                                mapOf("name", "bot")),
                        "POST", "/v1/service-accounts",
                        "{\"name\":\"bot\"}"),
                caseOf("service accounts get",
                        c -> c.serviceAccounts().get("sa_1"),
                        "GET", "/v1/service-accounts/sa_1", null),
                caseOf("service accounts delete",
                        c -> c.serviceAccounts().delete("sa_1"),
                        "DELETE", "/v1/service-accounts/sa_1", null),
                caseOf("pats list",
                        c -> c.personalAccessTokens().list(),
                        "GET", "/v1/personal-access-tokens", null),
                caseOf("pats create",
                        c -> c.personalAccessTokens().create(
                                mapOf("name", "cli")),
                        "POST", "/v1/personal-access-tokens",
                        "{\"name\":\"cli\"}"),
                caseOf("pats revoke",
                        c -> c.personalAccessTokens().revoke(
                                "pat_1"),
                        "POST",
                        "/v1/personal-access-tokens/pat_1/revoke",
                        null),
                caseOf("api secrets list",
                        c -> c.apiSecrets().list("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/api-secrets",
                        null),
                caseOf("api secrets create",
                        c -> c.apiSecrets().create("ten_1", "env_1",
                                mapOf("name", "runtime")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/api-secrets",
                        "{\"name\":\"runtime\"}"),
                caseOf("api secrets revoke",
                        c -> c.apiSecrets().revoke("ten_1", "env_1",
                                "sec_1"),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/api-secrets/sec_1/revoke",
                        null),
                caseOf("audit list logs",
                        c -> c.audit().listLogs("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/audit/logs",
                        null),
                caseOf("audit event metadata",
                        c -> c.audit().eventMetadata("ten_1",
                                "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/audit/event-metadata",
                        null),
                caseOf("audit event types",
                        c -> c.audit().eventTypes("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/audit/event-types",
                        null),
                caseOf("audit event types catalog",
                        c -> c.audit().eventTypesCatalog("ten_1",
                                "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/audit/event-types/catalog",
                        null),
                caseOf("events list",
                        c -> c.events().list("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/events",
                        null),
                caseOf("events list types",
                        c -> c.events().listTypes("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/events/types",
                        null),
                caseOf("events ingest",
                        c -> c.events().ingest("ten_1", "env_1",
                                mapOf("events",
                                        Collections.emptyList())),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/events/ingest",
                        "{\"events\":[]}"),
                caseOf("webhooks list",
                        c -> c.webhooks().list("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/webhooks",
                        null),
                caseOf("webhooks create",
                        c -> c.webhooks().create("ten_1", "env_1",
                                mapOf("url", "https://ex")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/webhooks",
                        "{\"url\":\"https://ex\"}"),
                caseOf("webhooks update",
                        c -> c.webhooks().update("ten_1", "env_1",
                                "ch_1", mapOf("url", "https://ex")),
                        "PUT",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/webhooks/ch_1",
                        "{\"url\":\"https://ex\"}"),
                caseOf("webhooks delete",
                        c -> c.webhooks().delete("ten_1", "env_1",
                                "ch_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/webhooks/ch_1",
                        null),
                caseOf("webhooks rotate secret",
                        c -> c.webhooks().rotateSecret("ten_1",
                                "env_1", "ch_1"),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/webhooks/ch_1/rotate-secret",
                        null),
                caseOf("webhooks list deliveries",
                        c -> c.webhooks().listDeliveries("ten_1",
                                "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/webhooks/deliveries",
                        null),
                caseOf("webhooks redeliver",
                        c -> c.webhooks().redeliver("ten_1", "env_1",
                                "del_1"),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/webhooks/deliveries/del_1"
                                + "/redeliver",
                        null),
                caseOf("notification channels list",
                        c -> c.notificationChannels().list("ten_1",
                                "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/notification-channels",
                        null),
                caseOf("notification channels create",
                        c -> c.notificationChannels().create(
                                "ten_1", "env_1",
                                mapOf("type", "webhook")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/notification-channels",
                        "{\"type\":\"webhook\"}"),
                caseOf("notification channels update",
                        c -> c.notificationChannels().update(
                                "ten_1", "env_1", "ch_1",
                                mapOf("name", "n")),
                        "PUT",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/notification-channels/ch_1",
                        "{\"name\":\"n\"}"),
                caseOf("notification channels delete",
                        c -> c.notificationChannels().delete(
                                "ten_1", "env_1", "ch_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/notification-channels/ch_1",
                        null),
                caseOf("notification channels test",
                        c -> c.notificationChannels().test("ten_1",
                                "env_1", "ch_1"),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/notification-channels/ch_1"
                                + "/test",
                        null),
                caseOf("rbac list roles",
                        c -> c.rbac().listRoles("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/roles",
                        null),
                caseOf("rbac create role",
                        c -> c.rbac().createRole("ten_1", "env_1",
                                mapOf("name", "admin")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/roles",
                        "{\"name\":\"admin\"}"),
                caseOf("rbac delete role",
                        c -> c.rbac().deleteRole("ten_1", "env_1",
                                "role_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/roles/role_1",
                        null),
                caseOf("rbac list role permissions",
                        c -> c.rbac().listRolePermissions("ten_1",
                                "env_1", "role_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/roles/role_1/permissions",
                        null),
                caseOf("rbac set role permissions",
                        c -> c.rbac().setRolePermissions("ten_1",
                                "env_1", "role_1",
                                mapOf("permissionIds",
                                        Collections.emptyList())),
                        "PUT",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/roles/role_1/permissions",
                        "{\"permissionIds\":[]}"),
                caseOf("rbac list permissions",
                        c -> c.rbac().listPermissions("ten_1",
                                "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/permissions",
                        null),
                caseOf("rbac create permission",
                        c -> c.rbac().createPermission("ten_1",
                                "env_1", mapOf("name", "read")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/permissions",
                        "{\"name\":\"read\"}"),
                caseOf("rbac delete permission",
                        c -> c.rbac().deletePermission("ten_1",
                                "env_1", "perm_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/permissions/perm_1",
                        null),
                caseOf("rbac list resources",
                        c -> c.rbac().listResources("ten_1",
                                "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/resources",
                        null),
                caseOf("rbac create resource",
                        c -> c.rbac().createResource("ten_1",
                                "env_1", mapOf("name", "doc")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/resources",
                        "{\"name\":\"doc\"}"),
                caseOf("rbac delete resource",
                        c -> c.rbac().deleteResource("ten_1",
                                "env_1", "res_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/resources/res_1",
                        null),
                caseOf("rbac list group roles",
                        c -> c.rbac().listGroupRoles("ten_1",
                                "env_1", "grp_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/groups/grp_1/roles",
                        null),
                caseOf("rbac add group role",
                        c -> c.rbac().addGroupRole("ten_1", "env_1",
                                "grp_1",
                                mapOf("roleId", "role_1")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/groups/grp_1/roles",
                        "{\"roleId\":\"role_1\"}"),
                caseOf("rbac remove group role",
                        c -> c.rbac().removeGroupRole("ten_1",
                                "env_1", "grp_1", "role_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/groups/grp_1/roles/role_1",
                        null),
                caseOf("rbac list group role mappings",
                        c -> c.rbac().listGroupRoleMappings("ten_1",
                                "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/group-role-mappings",
                        null),
                caseOf("rbac create group role mapping",
                        c -> c.rbac().createGroupRoleMapping(
                                "ten_1", "env_1",
                                mapOf("groupId", "grp_1")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/group-role-mappings",
                        "{\"groupId\":\"grp_1\"}"),
                caseOf("rbac apply group role mappings",
                        c -> c.rbac().applyGroupRoleMappings(
                                "ten_1", "env_1"),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/group-role-mappings/apply",
                        null),
                caseOf("rbac delete group role mapping",
                        c -> c.rbac().deleteGroupRoleMapping(
                                "ten_1", "env_1", "map_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/group-role-mappings/map_1",
                        null),
                caseOf("rbac list abac policies",
                        c -> c.rbac().listAbacPolicies("ten_1",
                                "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/abac-policies",
                        null),
                caseOf("rbac save abac policy",
                        c -> c.rbac().saveAbacPolicy("ten_1",
                                "env_1", mapOf("name", "p")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/abac-policies",
                        "{\"name\":\"p\"}"),
                caseOf("rbac validate abac policy",
                        c -> c.rbac().validateAbacPolicy("ten_1",
                                "env_1", mapOf("rego", "x")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/abac-policies/validate",
                        "{\"rego\":\"x\"}"),
                caseOf("rbac delete abac policy",
                        c -> c.rbac().deleteAbacPolicy("ten_1",
                                "env_1", "pol_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/abac-policies/pol_1",
                        null),
                caseOf("rbac my permissions",
                        c -> c.rbac().myPermissions("ten_1",
                                "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/me/permissions",
                        null)
        );
    }

    private AuthdogClient newClient() {
        return new AuthdogClient(mockServer.url("/").toString(), "key-1");
    }

    private void enqueueJson(final int status, final String body) {
        mockServer.enqueue(new MockResponse()
                .setResponseCode(status)
                .setHeader("Content-Type", "application/json")
                .setBody(body));
    }

    private void assertJsonBody(final String expected,
                                final String actual) throws Exception {
        if (expected == null) {
            assertTrue(actual == null || actual.isEmpty()
                    || "{}".equals(actual));
            return;
        }
        JsonNode expectedNode = objectMapper.readTree(expected);
        JsonNode actualNode = objectMapper.readTree(actual);
        assertEquals(expectedNode, actualNode);
    }

    private static Arguments caseOf(final String name,
                                    final Consumer<AuthdogClient> call,
                                    final String method,
                                    final String path,
                                    final String body) {
        return Arguments.of(name, call, method, path, body);
    }

    private static Map<String, Object> mapOf(final Object... pairs) {
        Map<String, Object> values = new LinkedHashMap<>();
        for (int i = 0; i < pairs.length; i += 2) {
            values.put((String) pairs[i], pairs[i + 1]);
        }
        return values;
    }
}
