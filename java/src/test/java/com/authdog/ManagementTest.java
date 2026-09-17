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
import java.util.LinkedHashMap;
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
