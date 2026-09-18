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


    @ParameterizedTest(name = "{0}")
    @MethodSource("wave3Cases")
    void testWave3MethodAndPath(final String name,
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
        if ("/.well-known/authzen-configuration".equals(path)) {
            String auth = request.getHeader("Authorization");
            assertTrue(auth == null || auth.isEmpty());
        } else {
            assertEquals("Bearer key-1",
                    request.getHeader("Authorization"));
        }
    }

    @Test
    void testWave3CoversAllInventoryOperations() {
        assertEquals(152, wave3Cases().count());
    }

    @Test
    void testWave3AuthzenDiscoveryOmitsBearer() throws Exception {
        enqueueJson(200, "{}");
        client = newClient();
        client.authzen().configuration();

        RecordedRequest request = mockServer.takeRequest();
        assertEquals("GET", request.getMethod());
        assertEquals("/.well-known/authzen-configuration",
                request.getPath());
        String auth = request.getHeader("Authorization");
        assertTrue(auth == null || auth.isEmpty());
    }

    @Test
    void testWave3AuthzenEvaluateUsesEnvironmentSecret()
            throws Exception {
        enqueueJson(200, "{\"decision\":\"Permit\"}");
        client = new AuthdogClient(mockServer.url("/").toString(),
                "key-1", "adenv_secret", null, null);

        JsonNode result = client.authzen().evaluate(
                mapOf("subject", mapOf("id", "u")));
        assertEquals("Permit", result.get("decision").asText());

        RecordedRequest request = mockServer.takeRequest();
        assertEquals("POST", request.getMethod());
        assertEquals("/access/v1/evaluation", request.getPath());
        assertEquals("Bearer adenv_secret",
                request.getHeader("Authorization"));
    }

    @Test
    void testWave3ScimAndHrisUseSpecializedTokens() throws Exception {
        enqueueJson(200, "{}");
        enqueueJson(200, "{}");
        client = new AuthdogClient(mockServer.url("/").toString(),
                "key-1", null, "adscim_token", "adhris_token");

        client.scim().listUsers();
        RecordedRequest scimReq = mockServer.takeRequest();
        assertEquals("Bearer adscim_token",
                scimReq.getHeader("Authorization"));

        client.hris().listEmployees();
        RecordedRequest hrisReq = mockServer.takeRequest();
        assertEquals("Bearer adhris_token",
                hrisReq.getHeader("Authorization"));
    }

    @Test
    void testWave3CreateScimTokenExposesOneTimeSecret()
            throws Exception {
        enqueueJson(200,
                "{\"token\":\"adscim_once\",\"id\":\"tok_1\"}");
        client = newClient();

        JsonNode created = client.provisioningTokens()
                .createScim("ten_1", "env_1", mapOf("name", "scim"));
        assertEquals("adscim_once", created.get("token").asText());
    }

    @Test
    void testWave3QueryParamsForwarded() throws Exception {
        enqueueJson(200, "{}");
        enqueueJson(200, "{}");
        enqueueJson(200, "{}");
        client = newClient();

        client.mcp().resolve("agent-1");
        RecordedRequest resolve = mockServer.takeRequest();
        assertEquals("GET", resolve.getMethod());
        assertEquals("/v1/mcp/trust-store/resolve?subject=agent-1",
                resolve.getPath());

        Map<String, String> params = new LinkedHashMap<>();
        params.put("status", "open");
        params.put("limit", "10");
        client.threats().list("ten_1", "env_1", params);
        RecordedRequest threats = mockServer.takeRequest();
        assertEquals("/v1/tenants/ten_1/environments/env_1/threats"
                + "?status=open&limit=10", threats.getPath());

        client.elevate().listRequests("ten_1", "env_1", "pending");
        RecordedRequest elevate = mockServer.takeRequest();
        assertEquals("/v1/tenants/ten_1/environments/env_1"
                + "/elevate/access-requests?status=pending",
                elevate.getPath());
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

    static Stream<Arguments> wave3Cases() {
        return Stream.of(
                caseOf("authzen configuration",
                        c -> c.authzen().configuration(),
                        "GET",
                        "/.well-known/authzen-configuration",
                        null),
                caseOf("authzen evaluate",
                        c -> c.authzen().evaluate(mapOf("subject", mapOf())),
                        "POST",
                        "/access/v1/evaluation",
                        "{\"subject\":{}}"),
                caseOf("authzen evaluate batch",
                        c -> c.authzen().
                                evaluateBatch(
                                mapOf("evaluations", Collections.emptyList())),
                        "POST",
                        "/access/v1/evaluations",
                        "{\"evaluations\":[]}"),
                caseOf("authzen search action",
                        c -> c.authzen().searchAction(mapOf("subject", mapOf(
                                ))),
                        "POST",
                        "/access/v1/search/action",
                        "{\"subject\":{}}"),
                caseOf("authzen search resource",
                        c -> c.authzen().searchResource(mapOf("subject", mapOf(
                                ))),
                        "POST",
                        "/access/v1/search/resource",
                        "{\"subject\":{}}"),
                caseOf("authzen search subject",
                        c -> c.authzen().searchSubject(mapOf("resource", mapOf(
                                ))),
                        "POST",
                        "/access/v1/search/subject",
                        "{\"resource\":{}}"),
                caseOf("users revoke session",
                        c -> c.users().revokeSession("env_1", "sess_1"),
                        "DELETE",
                        "/v1/environments/env_1"
                                + "/sessions/sess_1",
                        null),
                caseOf("hris list departments",
                        c -> c.hris().listDepartments(),
                        "GET",
                        "/v1/hris/v1/Departments",
                        null),
                caseOf("hris create department",
                        c -> c.hris().createDepartment(mapOf("name", "Eng")),
                        "POST",
                        "/v1/hris/v1/Departments",
                        "{\"name\":\"Eng\"}"),
                caseOf("hris get department",
                        c -> c.hris().getDepartment("dep_1"),
                        "GET",
                        "/v1/hris/v1/Departments/dep_1",
                        null),
                caseOf("hris replace department",
                        c -> c.hris().replaceDepartment("dep_1", mapOf(
                                "name",
                                "Eng")),
                        "PUT",
                        "/v1/hris/v1/Departments/dep_1",
                        "{\"name\":\"Eng\"}"),
                caseOf("hris patch department",
                        c -> c.hris().patchDepartment("dep_1", mapOf(
                                "name",
                                "E")),
                        "PATCH",
                        "/v1/hris/v1/Departments/dep_1",
                        "{\"name\":\"E\"}"),
                caseOf("hris delete department",
                        c -> c.hris().deleteDepartment("dep_1"),
                        "DELETE",
                        "/v1/hris/v1/Departments/dep_1",
                        null),
                caseOf("hris list employees",
                        c -> c.hris().listEmployees(),
                        "GET",
                        "/v1/hris/v1/Employees",
                        null),
                caseOf("hris create employee",
                        c -> c.hris().createEmployee(mapOf("name", "Ada")),
                        "POST",
                        "/v1/hris/v1/Employees",
                        "{\"name\":\"Ada\"}"),
                caseOf("hris get employee",
                        c -> c.hris().getEmployee("emp_1"),
                        "GET",
                        "/v1/hris/v1/Employees/emp_1",
                        null),
                caseOf("hris replace employee",
                        c -> c.hris().replaceEmployee("emp_1", mapOf(
                                "name",
                                "Ada")),
                        "PUT",
                        "/v1/hris/v1/Employees/emp_1",
                        "{\"name\":\"Ada\"}"),
                caseOf("hris patch employee",
                        c -> c.hris().patchEmployee("emp_1", mapOf(
                                "name",
                                "A")),
                        "PATCH",
                        "/v1/hris/v1/Employees/emp_1",
                        "{\"name\":\"A\"}"),
                caseOf("hris delete employee",
                        c -> c.hris().deleteEmployee("emp_1"),
                        "DELETE",
                        "/v1/hris/v1/Employees/emp_1",
                        null),
                caseOf("hris service config",
                        c -> c.hris().serviceConfig(),
                        "GET",
                        "/v1/hris/v1/ServiceConfig",
                        null),
                caseOf("otel export logs",
                        c -> c.otel().
                                exportLogs(
                                mapOf("resourceLogs", Collections.emptyList())),
                        "POST",
                        "/v1/logs",
                        "{\"resourceLogs\":[]}"),
                caseOf("mcp ingest events",
                        c -> c.mcp().
                                ingestEvents(
                                mapOf("events", Collections.emptyList())),
                        "POST",
                        "/v1/mcp/events",
                        "{\"events\":[]}"),
                caseOf("mcp resolve",
                        c -> c.mcp().resolve("agent-1"),
                        "GET",
                        "/v1/mcp/trust-store/resolve?subject=agent-1",
                        null),
                caseOf("otel export metrics",
                        c -> c.otel().
                                exportMetrics(
                                mapOf("resourceMetrics", Collections.emptyList())),
                        "POST",
                        "/v1/metrics",
                        "{\"resourceMetrics\":[]}"),
                caseOf("otel export logs prefixed",
                        c -> c.otel().
                                exportLogsPrefixed(
                                mapOf("resourceLogs", Collections.emptyList())),
                        "POST",
                        "/v1/otel/v1/logs",
                        "{\"resourceLogs\":[]}"),
                caseOf("otel export metrics prefixed",
                        c -> c.otel().
                                exportMetricsPrefixed(
                                mapOf("resourceMetrics", Collections.emptyList())),
                        "POST",
                        "/v1/otel/v1/metrics",
                        "{\"resourceMetrics\":[]}"),
                caseOf("otel export traces prefixed",
                        c -> c.otel().
                                exportTracesPrefixed(
                                mapOf("resourceSpans", Collections.emptyList())),
                        "POST",
                        "/v1/otel/v1/traces",
                        "{\"resourceSpans\":[]}"),
                caseOf("scim list groups",
                        c -> c.scim().listGroups(),
                        "GET",
                        "/v1/scim/v2/Groups",
                        null),
                caseOf("scim create group",
                        c -> c.scim().createGroup(mapOf("displayName", "G")),
                        "POST",
                        "/v1/scim/v2/Groups",
                        "{\"displayName\":\"G\"}"),
                caseOf("scim get group",
                        c -> c.scim().getGroup("g_1"),
                        "GET",
                        "/v1/scim/v2/Groups/g_1",
                        null),
                caseOf("scim replace group",
                        c -> c.scim().replaceGroup("g_1", mapOf(
                                "displayName",
                                "G")),
                        "PUT",
                        "/v1/scim/v2/Groups/g_1",
                        "{\"displayName\":\"G\"}"),
                caseOf("scim patch group",
                        c -> c.scim().
                                patchGroup(
                                "g_1",
                                mapOf("Operations", Collections.emptyList())),
                        "PATCH",
                        "/v1/scim/v2/Groups/g_1",
                        "{\"Operations\":[]}"),
                caseOf("scim delete group",
                        c -> c.scim().deleteGroup("g_1"),
                        "DELETE",
                        "/v1/scim/v2/Groups/g_1",
                        null),
                caseOf("scim resource types",
                        c -> c.scim().resourceTypes(),
                        "GET",
                        "/v1/scim/v2/ResourceTypes",
                        null),
                caseOf("scim resource type",
                        c -> c.scim().resourceType("User"),
                        "GET",
                        "/v1/scim/v2/ResourceTypes/User",
                        null),
                caseOf("scim schemas",
                        c -> c.scim().schemas(),
                        "GET",
                        "/v1/scim/v2/Schemas",
                        null),
                caseOf("scim schema",
                        c -> c.scim().schema(
                                "urn:ietf:params:scim:schemas:core:2.0:User"),
                        "GET",
                        "/v1/scim/v2/Schemas/"
                                + "urn:ietf:params:scim:schemas:core:2.0:User",
                        null),
                caseOf("scim service provider config",
                        c -> c.scim().serviceProviderConfig(),
                        "GET",
                        "/v1/scim/v2/ServiceProviderConfig",
                        null),
                caseOf("scim list users",
                        c -> c.scim().listUsers(),
                        "GET",
                        "/v1/scim/v2/Users",
                        null),
                caseOf("scim create user",
                        c -> c.scim().createUser(mapOf("userName", "ada")),
                        "POST",
                        "/v1/scim/v2/Users",
                        "{\"userName\":\"ada\"}"),
                caseOf("scim get user",
                        c -> c.scim().getUser("u_1"),
                        "GET",
                        "/v1/scim/v2/Users/u_1",
                        null),
                caseOf("scim replace user",
                        c -> c.scim().replaceUser("u_1", mapOf(
                                "userName",
                                "ada")),
                        "PUT",
                        "/v1/scim/v2/Users/u_1",
                        "{\"userName\":\"ada\"}"),
                caseOf("scim patch user",
                        c -> c.scim().
                                patchUser(
                                "u_1",
                                mapOf("Operations", Collections.emptyList())),
                        "PATCH",
                        "/v1/scim/v2/Users/u_1",
                        "{\"Operations\":[]}"),
                caseOf("scim delete user",
                        c -> c.scim().deleteUser("u_1"),
                        "DELETE",
                        "/v1/scim/v2/Users/u_1",
                        null),
                caseOf("environments list connections",
                        c -> c.environments().listConnections(
                                "ten_1",
                                "app_1",
                                "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/applications/app_1/environments/env_1"
                                + "/connections",
                        null),
                caseOf("oidc clients list",
                        c -> c.oidcClients().list("ten_1", "app_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/applications/app_1/environments/env_1"
                                + "/oidc-clients",
                        null),
                caseOf("oidc clients register",
                        c -> c.oidcClients().
                                register(
                                "ten_1",
                                "app_1",
                                "env_1",
                                mapOf("name", "cli")),
                        "POST",
                        "/v1/tenants/ten_1/applications/app_1/environments/env_1"
                                + "/oidc-clients",
                        "{\"name\":\"cli\"}"),
                caseOf("oidc clients update",
                        c -> c.oidcClients().
                                update(
                                "ten_1",
                                "app_1",
                                "env_1",
                                "cid_1",
                                mapOf("name", "n")),
                        "PATCH",
                        "/v1/tenants/ten_1/applications/app_1/environments/env_1"
                                + "/oidc-clients/cid_1",
                        "{\"name\":\"n\"}"),
                caseOf("oidc clients delete",
                        c -> c.oidcClients().delete(
                                "ten_1",
                                "app_1",
                                "env_1",
                                "cid_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/applications/app_1/environments/env_1"
                                + "/oidc-clients/cid_1",
                        null),
                caseOf("environments list redirect uris",
                        c -> c.environments().listRedirectUris(
                                "ten_1",
                                "app_1",
                                "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/applications/app_1/environments/env_1"
                                + "/redirect-uris",
                        null),
                caseOf("actions list",
                        c -> c.actions().list("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/actions",
                        null),
                caseOf("actions save",
                        c -> c.actions().save("ten_1", "env_1", mapOf(
                                "url",
                                "https://ex")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/actions",
                        "{\"url\":\"https://ex\"}"),
                caseOf("actions executions",
                        c -> c.actions().executions("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/actions/executions",
                        null),
                caseOf("actions test",
                        c -> c.actions().test("ten_1", "env_1", mapOf(
                                "url",
                                "https://ex")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/actions/test",
                        "{\"url\":\"https://ex\"}"),
                caseOf("actions delete",
                        c -> c.actions().delete("ten_1", "env_1", "act_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/actions/act_1",
                        null),
                caseOf("addons list",
                        c -> c.addons().list("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/addons",
                        null),
                caseOf("addons save",
                        c -> c.addons().save("ten_1", "env_1", mapOf(
                                "provider",
                                "slack")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/addons",
                        "{\"provider\":\"slack\"}"),
                caseOf("addons delete",
                        c -> c.addons().delete("ten_1", "env_1", "slack"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/addons/slack",
                        null),
                caseOf("billing list features",
                        c -> c.billing().listFeatures("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/billing/features",
                        null),
                caseOf("billing save feature",
                        c -> c.billing().saveFeature("ten_1", "env_1", mapOf(
                                "name",
                                "pro")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/billing/features",
                        "{\"name\":\"pro\"}"),
                caseOf("billing delete feature",
                        c -> c.billing().deleteFeature(
                                "ten_1",
                                "env_1",
                                "feat_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/billing/features/feat_1",
                        null),
                caseOf("billing list plans",
                        c -> c.billing().listPlans("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/billing/plans",
                        null),
                caseOf("billing save plan",
                        c -> c.billing().savePlan("ten_1", "env_1", mapOf(
                                "name",
                                "pro")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/billing/plans",
                        "{\"name\":\"pro\"}"),
                caseOf("billing delete plan",
                        c -> c.billing().deletePlan("ten_1", "env_1", "plan_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/billing/plans/plan_1",
                        null),
                caseOf("billing sync stripe",
                        c -> c.billing().syncStripe("ten_1", "env_1", "plan_1"),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/billing/plans/plan_1/sync-stripe",
                        null),
                caseOf("settings get bot detection policy",
                        c -> c.settings().getBotDetectionPolicy(
                                "ten_1",
                                "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/bot-detection-policy",
                        null),
                caseOf("settings update bot detection policy",
                        c -> c.settings().
                                updateBotDetectionPolicy(
                                "ten_1",
                                "env_1",
                                mapOf("enabled", true)),
                        "PUT",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/bot-detection-policy",
                        "{\"enabled\":true}"),
                caseOf("settings get breached password policy",
                        c -> c.settings().getBreachedPasswordPolicy(
                                "ten_1",
                                "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/breached-password-policy",
                        null),
                caseOf("settings update breached password policy",
                        c -> c.settings().
                                updateBreachedPasswordPolicy(
                                "ten_1",
                                "env_1",
                                mapOf("enabled", true)),
                        "PUT",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/breached-password-policy",
                        "{\"enabled\":true}"),
                caseOf("settings get brute force policy",
                        c -> c.settings().getBruteForcePolicy("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/brute-force-policy",
                        null),
                caseOf("settings update brute force policy",
                        c -> c.settings().
                                updateBruteForcePolicy(
                                "ten_1",
                                "env_1",
                                mapOf("enabled", true)),
                        "PUT",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/brute-force-policy",
                        "{\"enabled\":true}"),
                caseOf("environments save connection",
                        c -> c.environments().
                                saveConnection(
                                "ten_1",
                                "env_1",
                                mapOf("provider", "okta")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/connections",
                        "{\"provider\":\"okta\"}"),
                caseOf("environments resolve saml metadata",
                        c -> c.environments().
                                resolveSamlMetadata(
                                "ten_1",
                                "env_1",
                                mapOf("url", "https://ex")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/connections/resolve-saml-metadata",
                        "{\"url\":\"https://ex\"}"),
                caseOf("environments get sso metadata",
                        c -> c.environments().getSsoMetadata("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/connections/sso-metadata",
                        null),
                caseOf("environments delete connection",
                        c -> c.environments().deleteConnection(
                                "ten_1",
                                "env_1",
                                "con_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/connections/con_1",
                        null),
                caseOf("settings get device risk policy",
                        c -> c.settings().getDeviceRiskPolicy("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/device-risk-policy",
                        null),
                caseOf("settings update device risk policy",
                        c -> c.settings().
                                updateDeviceRiskPolicy(
                                "ten_1",
                                "env_1",
                                mapOf("enabled", true)),
                        "PUT",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/device-risk-policy",
                        "{\"enabled\":true}"),
                caseOf("elevate activate grant",
                        c -> c.elevate().
                                activateGrant(
                                "ten_1",
                                "env_1",
                                "gr_1",
                                mapOf("reason", "x")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/elevate/access-grants/gr_1/activate",
                        "{\"reason\":\"x\"}"),
                caseOf("elevate revoke grant",
                        c -> c.elevate().
                                revokeGrant(
                                "ten_1",
                                "env_1",
                                "gr_1",
                                mapOf("reason", "x")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/elevate/access-grants/gr_1/revoke",
                        "{\"reason\":\"x\"}"),
                caseOf("elevate list requests",
                        c -> c.elevate().listRequests("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/elevate/access-requests",
                        null),
                caseOf("elevate create request",
                        c -> c.elevate().createRequest("ten_1", "env_1", mapOf(
                                "reason",
                                "x")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/elevate/access-requests",
                        "{\"reason\":\"x\"}"),
                caseOf("elevate get request",
                        c -> c.elevate().getRequest("ten_1", "env_1", "req_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/elevate/access-requests/req_1",
                        null),
                caseOf("elevate approve request",
                        c -> c.elevate().
                                approveRequest(
                                "ten_1",
                                "env_1",
                                "req_1",
                                mapOf("note", "ok")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/elevate/access-requests/req_1/approve",
                        "{\"note\":\"ok\"}"),
                caseOf("elevate cancel request",
                        c -> c.elevate().cancelRequest(
                                "ten_1",
                                "env_1",
                                "req_1"),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/elevate/access-requests/req_1/cancel",
                        null),
                caseOf("elevate deny request",
                        c -> c.elevate().
                                denyRequest(
                                "ten_1",
                                "env_1",
                                "req_1",
                                mapOf("note", "no")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/elevate/access-requests/req_1/deny",
                        "{\"note\":\"no\"}"),
                caseOf("elevate get policy",
                        c -> c.elevate().getPolicy("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/elevate/policy",
                        null),
                caseOf("elevate update policy",
                        c -> c.elevate().updatePolicy("ten_1", "env_1", mapOf(
                                "enabled",
                                true)),
                        "PUT",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/elevate/policy",
                        "{\"enabled\":true}"),
                caseOf("email providers list",
                        c -> c.emailProviders().list("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/email-providers",
                        null),
                caseOf("email providers save",
                        c -> c.emailProviders().save("ten_1", "env_1", mapOf(
                                "provider",
                                "ses")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/email-providers",
                        "{\"provider\":\"ses\"}"),
                caseOf("email providers test",
                        c -> c.emailProviders().test("ten_1", "env_1", mapOf(
                                "to",
                                "a@b.c")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/email-providers/test",
                        "{\"to\":\"a@b.c\"}"),
                caseOf("email providers delete",
                        c -> c.emailProviders().delete("ten_1", "env_1", "ses"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/email-providers/ses",
                        null),
                caseOf("email providers activate",
                        c -> c.emailProviders().activate(
                                "ten_1",
                                "env_1",
                                "ses"),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/email-providers/ses/activate",
                        null),
                caseOf("feature flags list",
                        c -> c.featureFlags().list("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/feature-flags",
                        null),
                caseOf("feature flags save",
                        c -> c.featureFlags().save("ten_1", "env_1", mapOf(
                                "key",
                                "x")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/feature-flags",
                        "{\"key\":\"x\"}"),
                caseOf("feature flags delete",
                        c -> c.featureFlags().delete(
                                "ten_1",
                                "env_1",
                                "flag_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/feature-flags/flag_1",
                        null),
                caseOf("forms list attachments",
                        c -> c.forms().listAttachments("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/form-attachments",
                        null),
                caseOf("forms list",
                        c -> c.forms().list("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/forms",
                        null),
                caseOf("forms save",
                        c -> c.forms().save("ten_1", "env_1", mapOf(
                                "name",
                                "login")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/forms",
                        "{\"name\":\"login\"}"),
                caseOf("forms delete",
                        c -> c.forms().delete("ten_1", "env_1", "form_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/forms/form_1",
                        null),
                caseOf("provisioning tokens list hris",
                        c -> c.provisioningTokens().listHris("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/hris-tokens",
                        null),
                caseOf("provisioning tokens create hris",
                        c -> c.provisioningTokens().
                                createHris(
                                "ten_1",
                                "env_1",
                                mapOf("name", "hr")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/hris-tokens",
                        "{\"name\":\"hr\"}"),
                caseOf("provisioning tokens revoke hris",
                        c -> c.provisioningTokens().revokeHris(
                                "ten_1",
                                "env_1",
                                "tok_1"),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/hris-tokens/tok_1/revoke",
                        null),
                caseOf("provisioning tokens rotate hris",
                        c -> c.provisioningTokens().rotateHris(
                                "ten_1",
                                "env_1",
                                "tok_1"),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/hris-tokens/tok_1/rotate",
                        null),
                caseOf("impersonation list",
                        c -> c.impersonation().list("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/impersonation-grants",
                        null),
                caseOf("impersonation create",
                        c -> c.impersonation().create("ten_1", "env_1", mapOf(
                                "userId",
                                "usr_1")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/impersonation-grants",
                        "{\"userId\":\"usr_1\"}"),
                caseOf("impersonation revoke",
                        c -> c.impersonation().revoke("ten_1", "env_1", "gr_1"),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/impersonation-grants/gr_1/revoke",
                        null),
                caseOf("settings list jwt claim mappings",
                        c -> c.settings().listJwtClaimMappings(
                                "ten_1",
                                "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/jwt-claim-mappings",
                        null),
                caseOf("settings save jwt claim mapping",
                        c -> c.settings().
                                saveJwtClaimMapping(
                                "ten_1",
                                "env_1",
                                mapOf("claim", "role")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/jwt-claim-mappings",
                        "{\"claim\":\"role\"}"),
                caseOf("settings delete jwt claim mapping",
                        c -> c.settings().deleteJwtClaimMapping(
                                "ten_1",
                                "env_1",
                                "map_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/jwt-claim-mappings/map_1",
                        null),
                caseOf("mcp list entries",
                        c -> c.mcp().listEntries("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/mcp/trust-store",
                        null),
                caseOf("mcp create entry",
                        c -> c.mcp().createEntry("ten_1", "env_1", mapOf(
                                "subject",
                                "a")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/mcp/trust-store",
                        "{\"subject\":\"a\"}"),
                caseOf("mcp get entry",
                        c -> c.mcp().getEntry("ten_1", "env_1", "ent_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/mcp/trust-store/ent_1",
                        null),
                caseOf("mcp update entry",
                        c -> c.mcp().
                                updateEntry(
                                "ten_1",
                                "env_1",
                                "ent_1",
                                mapOf("name", "n")),
                        "PATCH",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/mcp/trust-store/ent_1",
                        "{\"name\":\"n\"}"),
                caseOf("mcp delete entry",
                        c -> c.mcp().deleteEntry("ten_1", "env_1", "ent_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/mcp/trust-store/ent_1",
                        null),
                caseOf("mcp add key",
                        c -> c.mcp().
                                addKey(
                                "ten_1",
                                "env_1",
                                "ent_1",
                                mapOf("jwk", mapOf())),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/mcp/trust-store/ent_1/keys",
                        "{\"jwk\":{}}"),
                caseOf("mcp revoke key",
                        c -> c.mcp().revokeKey(
                                "ten_1",
                                "env_1",
                                "ent_1",
                                "key_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/mcp/trust-store/ent_1/keys/key_1",
                        null),
                caseOf("mcp rotate key",
                        c -> c.mcp().rotateKey(
                                "ten_1",
                                "env_1",
                                "ent_1",
                                "key_1"),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/mcp/trust-store/ent_1/keys/key_1/rotate",
                        null),
                caseOf("mcp revoke entry",
                        c -> c.mcp().revokeEntry("ten_1", "env_1", "ent_1"),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/mcp/trust-store/ent_1/revoke",
                        null),
                caseOf("mcp verify entry",
                        c -> c.mcp().
                                verifyEntry(
                                "ten_1",
                                "env_1",
                                "ent_1",
                                mapOf("verified", true)),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/mcp/trust-store/ent_1/verify",
                        "{\"verified\":true}"),
                caseOf("users totp status",
                        c -> c.users().totpStatus("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/me/mfa/totp",
                        null),
                caseOf("settings get password policy",
                        c -> c.settings().getPasswordPolicy("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/password-policy",
                        null),
                caseOf("settings update password policy",
                        c -> c.settings().
                                updatePasswordPolicy(
                                "ten_1",
                                "env_1",
                                mapOf("minLength", 8)),
                        "PUT",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/password-policy",
                        "{\"minLength\":8}"),
                caseOf("portal generate link",
                        c -> c.portal().generateLink("ten_1", "env_1", mapOf(
                                "email",
                                "a@b.c")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/portal/generate-link",
                        "{\"email\":\"a@b.c\"}"),
                caseOf("settings get rate limit policy",
                        c -> c.settings().getRateLimitPolicy("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/rate-limit-policy",
                        null),
                caseOf("settings update rate limit policy",
                        c -> c.settings().
                                updateRateLimitPolicy(
                                "ten_1",
                                "env_1",
                                mapOf("limit", 10)),
                        "PUT",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/rate-limit-policy",
                        "{\"limit\":10}"),
                caseOf("environments save redirect uris",
                        c -> c.environments().
                                saveRedirectUris(
                                "ten_1",
                                "env_1",
                                mapOf("uris", Collections.emptyList())),
                        "PUT",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/redirect-uris",
                        "{\"uris\":[]}"),
                caseOf("settings get restrictions",
                        c -> c.settings().getRestrictions("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/restrictions",
                        null),
                caseOf("settings update restrictions",
                        c -> c.settings().
                                updateRestrictions(
                                "ten_1",
                                "env_1",
                                mapOf("signup", false)),
                        "PUT",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/restrictions",
                        "{\"signup\":false}"),
                caseOf("provisioning tokens list scim",
                        c -> c.provisioningTokens().listScim("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/scim-tokens",
                        null),
                caseOf("provisioning tokens create scim",
                        c -> c.provisioningTokens().
                                createScim(
                                "ten_1",
                                "env_1",
                                mapOf("name", "scim")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/scim-tokens",
                        "{\"name\":\"scim\"}"),
                caseOf("provisioning tokens revoke scim",
                        c -> c.provisioningTokens().revokeScim(
                                "ten_1",
                                "env_1",
                                "tok_1"),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/scim-tokens/tok_1/revoke",
                        null),
                caseOf("provisioning tokens rotate scim",
                        c -> c.provisioningTokens().rotateScim(
                                "ten_1",
                                "env_1",
                                "tok_1"),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/scim-tokens/tok_1/rotate",
                        null),
                caseOf("security posture",
                        c -> c.security().posture("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/security/posture",
                        null),
                caseOf("settings get session config",
                        c -> c.settings().getSessionConfig("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/session-config",
                        null),
                caseOf("settings update session config",
                        c -> c.settings().
                                updateSessionConfig(
                                "ten_1",
                                "env_1",
                                mapOf("ttl", 3600)),
                        "PUT",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/session-config",
                        "{\"ttl\":3600}"),
                caseOf("threats list",
                        c -> c.threats().list("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/threats",
                        null),
                caseOf("threats create",
                        c -> c.threats().create("ten_1", "env_1", mapOf(
                                "type",
                                "bot")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/threats",
                        "{\"type\":\"bot\"}"),
                caseOf("threats get",
                        c -> c.threats().get("ten_1", "env_1", "th_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/threats/th_1",
                        null),
                caseOf("threats update",
                        c -> c.threats().update("ten_1", "env_1", "th_1", mapOf(
                                "status",
                                "open")),
                        "PATCH",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/threats/th_1",
                        "{\"status\":\"open\"}"),
                caseOf("threats delete",
                        c -> c.threats().delete("ten_1", "env_1", "th_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/threats/th_1",
                        null),
                caseOf("threats resolve",
                        c -> c.threats().
                                resolve(
                                "ten_1",
                                "env_1",
                                "th_1",
                                mapOf("status", "resolved")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/threats/th_1/resolve",
                        "{\"status\":\"resolved\"}"),
                caseOf("users bulk delete",
                        c -> c.users().
                                bulkDelete(
                                "ten_1",
                                "env_1",
                                mapOf("userIds", List.of("usr_1"))),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/users/bulk/delete",
                        "{\"userIds\":[\"usr_1\"]}"),
                caseOf("users bulk set active",
                        c -> c.users().
                                bulkSetActive(
                                "ten_1",
                                "env_1",
                                mapOf("userIds", List.of("usr_1"), "active", false)),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/users/bulk/set-active",
                        "{\"userIds\":[\"usr_1\"],\"active\":false}"),
                caseOf("users import users",
                        c -> c.users().
                                importUsers(
                                "ten_1",
                                "env_1",
                                mapOf("users", Collections.emptyList())),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/users/import",
                        "{\"users\":[]}"),
                caseOf("users disable mfa",
                        c -> c.users().disableMfa("ten_1", "env_1", "usr_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/users/usr_1/mfa",
                        null),
                caseOf("users list sessions",
                        c -> c.users().listSessions("ten_1", "env_1", "usr_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/users/usr_1/sessions",
                        null),
                caseOf("vanity domains list",
                        c -> c.vanityDomains().list("ten_1", "env_1"),
                        "GET",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/vanity-domains",
                        null),
                caseOf("vanity domains create",
                        c -> c.vanityDomains().create("ten_1", "env_1", mapOf(
                                "domain",
                                "a.com")),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/vanity-domains",
                        "{\"domain\":\"a.com\"}"),
                caseOf("vanity domains delete",
                        c -> c.vanityDomains().delete(
                                "ten_1",
                                "env_1",
                                "dom_1"),
                        "DELETE",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/vanity-domains/dom_1",
                        null),
                caseOf("vanity domains check",
                        c -> c.vanityDomains().check("ten_1", "env_1", "dom_1"),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/vanity-domains/dom_1/check",
                        null),
                caseOf("widgets create token",
                        c -> c.widgets().createToken("ten_1", "env_1", mapOf(
                                "ttl",
                                60)),
                        "POST",
                        "/v1/tenants/ten_1/environments/env_1"
                                + "/widgets/token",
                        "{\"ttl\":60}"),
                caseOf("otel export traces",
                        c -> c.otel().
                                exportTraces(
                                mapOf("resourceSpans", Collections.emptyList())),
                        "POST",
                        "/v1/traces",
                        "{\"resourceSpans\":[]}")
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
