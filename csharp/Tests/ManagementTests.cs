using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Authdog;
using Authdog.Exceptions;
using FluentAssertions;
using Moq;
using Moq.Protected;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Xunit;

namespace Authdog.Sdk.Tests
{
    public class ManagementTests : IDisposable
    {
        [Fact]
        public async Task HealthAsync_ReturnsProbe()
        {
            var (client, captured, _) = ClientFor(JsonResponse(new { ok = true }));

            var probe = await client.HealthAsync();

            probe.Ok.Should().BeTrue();
            captured()!.Method.Should().Be(HttpMethod.Get);
            captured()!.RequestUri!.AbsolutePath.Should().Be("/v1/health");
        }

        [Fact]
        public void Health_SynchronousVersion_ReturnsProbe()
        {
            var (client, captured, _) = ClientFor(JsonResponse(new { ok = true }));

            var probe = client.Health();

            probe.Ok.Should().BeTrue();
            captured()!.Method.Should().Be(HttpMethod.Get);
            captured()!.RequestUri!.AbsolutePath.Should().Be("/v1/health");
        }

        [Fact]
        public async Task OrganizationsList_Empty_UsesConstructorApiKeyPerRequest()
        {
            var (client, captured, httpClient) = ClientFor(JsonResponse(new { organizations = Array.Empty<object>(), total = 0 }));

            var result = await client.Organizations.ListAsync();

            result.Organizations.Should().BeEmpty();
            result.Total.Should().Be(0);
            captured()!.Headers.Authorization.Should().NotBeNull();
            captured()!.Headers.Authorization!.ToString().Should().Be("Bearer key-1");
            httpClient.DefaultRequestHeaders.Contains("Authorization").Should().BeFalse();
        }

        [Fact]
        public async Task TenantsList_Empty()
        {
            var (client, _, _) = ClientFor(JsonResponse(new { tenants = Array.Empty<object>(), total = 0 }));

            var result = await client.Tenants.ListAsync();

            result.Tenants.Should().BeEmpty();
            result.Total.Should().Be(0);
        }

        [Fact]
        public async Task GroupsList_Empty()
        {
            var (client, _, _) = ClientFor(JsonResponse(new { groups = Array.Empty<object>() }));

            var result = await client.Groups.ListAsync("ten_1", "env_1");

            result.Groups.Should().BeEmpty();
        }

        [Fact]
        public async Task UsersList_ParsesEmptyAndItem()
        {
            var (client, _, _) = ClientFor(JsonResponse(new
            {
                users = new[]
                {
                    new
                    {
                        id = "usr_1",
                        displayName = "Ada",
                        emails = new[] { new { value = "ada@example.com" } }
                    }
                }
            }));

            var listed = await client.Users.ListAsync("ten_1", "env_1");
            listed.Users.Should().HaveCount(1);
            listed.Users[0].Id.Should().Be("usr_1");
            listed.Users[0].DisplayName.Should().Be("Ada");
            listed.Users[0].Emails[0].Value.Should().Be("ada@example.com");

            var (emptyClient, _, _) = ClientFor(JsonResponse(new { users = Array.Empty<object>() }));
            (await emptyClient.Users.ListAsync("ten_1", "env_1")).Users.Should().BeEmpty();
        }

        [Fact]
        public async Task Management_401_ThrowsAuthenticationException()
        {
            var (client, _, _) = ClientFor(JsonResponse(new { }, HttpStatusCode.Unauthorized));

            var exception = await Assert.ThrowsAsync<AuthenticationException>(() => client.Organizations.ListAsync());
            exception.Message.Should().Be("Unauthorized - invalid or expired token");
        }

        [Fact]
        public async Task Management_404_IncludesStatusAndError()
        {
            var (client, _, _) = ClientFor(JsonResponse(new { error = "not found" }, HttpStatusCode.NotFound));

            var exception = await Assert.ThrowsAsync<ApiException>(() => client.Organizations.GetAsync("missing"));
            exception.Message.Should().Contain("HTTP error 404");
            exception.Message.Should().Contain("not found");
            exception.StatusCode.Should().Be(404);
        }

        [Fact]
        public async Task Management_HttpRequestException_ThrowsApiException()
        {
            var handler = new Mock<HttpMessageHandler>();
            handler.Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>())
                .ThrowsAsync(new HttpRequestException("Connection failed"));

            using var httpClient = new HttpClient(handler.Object);
            using var client = new AuthdogClient("https://api.authdog.com", "key-1", httpClient);

            var exception = await Assert.ThrowsAsync<ApiException>(() => client.Tenants.ListAsync());
            exception.Message.Should().Be("Request failed: Connection failed");
            exception.InnerException.Should().BeOfType<HttpRequestException>();
        }

        [Fact]
        public async Task TenantsList_SendsOrganizationIdQuery()
        {
            var (client, captured, _) = ClientFor(JsonResponse(new { tenants = Array.Empty<object>(), total = 0 }));

            await client.Tenants.ListAsync("org_1");

            captured()!.RequestUri!.PathAndQuery.Should().Be("/v1/tenants?organization_id=org_1");
        }

        [Fact]
        public async Task UsersList_SendsSearchQueryParams()
        {
            var (client, captured, _) = ClientFor(JsonResponse(new { users = Array.Empty<object>() }));

            await client.Users.ListAsync("ten_1", "env_1", offset: 2, limit: 10, searchQuery: "ada");

            captured()!.RequestUri!.PathAndQuery.Should().Be(
                "/v1/tenants/ten_1/environments/env_1/users?offset=2&limit=10&searchQuery=ada");
        }

        [Theory]
        [MemberData(nameof(Wave1Cases))]
        public async Task Wave1_MethodAndPath(Func<AuthdogClient, Task> call, string method, string path, object? body)
        {
            var (client, captured, _) = ClientFor(JsonResponse(new { }));

            await call(client);

            captured().Should().NotBeNull();
            captured()!.Method.Method.Should().Be(method);
            captured()!.RequestUri!.AbsolutePath.Should().Be(path);
            if (body == null)
            {
                captured()!.Content.Should().BeNull();
            }
            else
            {
                var sent = await captured()!.Content!.ReadAsStringAsync();
                JToken.DeepEquals(JObject.FromObject(body), JObject.Parse(sent)).Should().BeTrue();
            }
        }

        public static IEnumerable<object[]> Wave1Cases()
        {
            foreach (var row in OrgTenantCases())
            {
                yield return row;
            }

            foreach (var row in DirectoryCases())
            {
                yield return row;
            }
        }

        private static IEnumerable<object[]> OrgTenantCases()
        {
            yield return Case(c => c.Organizations.ListAsync(), "GET", "/v1/organizations", null);
            yield return Case(c => c.Organizations.CreateAsync(new Dictionary<string, object> { ["name"] = "Acme" }), "POST", "/v1/organizations", new Dictionary<string, object> { ["name"] = "Acme" });
            yield return Case(c => c.Organizations.GetAsync("org_1"), "GET", "/v1/organizations/org_1", null);
            yield return Case(c => c.Organizations.UpdateAsync("org_1", new Dictionary<string, object> { ["name"] = "New" }), "PATCH", "/v1/organizations/org_1", new Dictionary<string, object> { ["name"] = "New" });
            yield return Case(c => c.Organizations.DeleteAsync("org_1"), "DELETE", "/v1/organizations/org_1", null);
            yield return Case(c => c.Organizations.AcceptInvitationAsync(new Dictionary<string, object> { ["token"] = "t" }), "POST", "/v1/organizations/invitations/accept", new Dictionary<string, object> { ["token"] = "t" });
            yield return Case(c => c.Organizations.JoinAsync(new Dictionary<string, object> { ["invitationCode"] = "c" }), "POST", "/v1/organizations/join", new Dictionary<string, object> { ["invitationCode"] = "c" });
            yield return Case(c => c.Organizations.ListInvitationsAsync("org_1"), "GET", "/v1/organizations/org_1/invitations", null);
            yield return Case(c => c.Organizations.CreateInvitationAsync("org_1", new Dictionary<string, object> { ["email"] = "a@b.c" }), "POST", "/v1/organizations/org_1/invitations", new Dictionary<string, object> { ["email"] = "a@b.c" });
            yield return Case(c => c.Organizations.CancelInvitationAsync("org_1", "inv_1"), "POST", "/v1/organizations/org_1/invitations/inv_1/cancel", null);
            yield return Case(c => c.Organizations.SendInviteAsync("org_1", new Dictionary<string, object> { ["email"] = "a@b.c" }), "POST", "/v1/organizations/org_1/invites", new Dictionary<string, object> { ["email"] = "a@b.c" });
            yield return Case(c => c.Organizations.ListMembersAsync("org_1"), "GET", "/v1/organizations/org_1/members", null);
            yield return Case(c => c.Organizations.RemoveMemberAsync("org_1", "mem_1"), "DELETE", "/v1/organizations/org_1/members/mem_1", null);
            yield return Case(c => c.Organizations.SetMemberActiveAsync("org_1", "mem_1", new Dictionary<string, object> { ["active"] = false }), "PATCH", "/v1/organizations/org_1/members/mem_1/active", new Dictionary<string, object> { ["active"] = false });
            yield return Case(c => c.Organizations.LinkTenantAsync("org_1", new Dictionary<string, object> { ["tenantId"] = "ten_1" }), "POST", "/v1/organizations/org_1/tenants", new Dictionary<string, object> { ["tenantId"] = "ten_1" });
            yield return Case(c => c.Organizations.UnlinkTenantAsync("org_1", "ten_1"), "DELETE", "/v1/organizations/org_1/tenants/ten_1", null);
            yield return Case(c => c.Tenants.ListAsync(), "GET", "/v1/tenants", null);
            yield return Case(c => c.Tenants.CreateAsync(new Dictionary<string, object> { ["name"] = "T" }), "POST", "/v1/tenants", new Dictionary<string, object> { ["name"] = "T" });
            yield return Case(c => c.Tenants.JoinAsync(new Dictionary<string, object> { ["invitationCode"] = "c" }), "POST", "/v1/tenants/join", new Dictionary<string, object> { ["invitationCode"] = "c" });
            yield return Case(c => c.Tenants.GetAsync("ten_1"), "GET", "/v1/tenants/ten_1", null);
            yield return Case(c => c.Tenants.UpdateAsync("ten_1", new Dictionary<string, object> { ["name"] = "N" }), "PATCH", "/v1/tenants/ten_1", new Dictionary<string, object> { ["name"] = "N" });
            yield return Case(c => c.Tenants.DeleteAsync("ten_1"), "DELETE", "/v1/tenants/ten_1", null);
            yield return Case(c => c.Tenants.ListDomainsAsync("ten_1"), "GET", "/v1/tenants/ten_1/domains", null);
            yield return Case(c => c.Tenants.CreateDomainAsync("ten_1", new Dictionary<string, object> { ["domain"] = "a.com", ["validationMethod"] = "dns" }), "POST", "/v1/tenants/ten_1/domains", new Dictionary<string, object> { ["domain"] = "a.com", ["validationMethod"] = "dns" });
            yield return Case(c => c.Tenants.DeleteDomainAsync("ten_1", "dom_1"), "DELETE", "/v1/tenants/ten_1/domains/dom_1", null);
            yield return Case(c => c.Tenants.RetryDomainAsync("ten_1", "dom_1"), "POST", "/v1/tenants/ten_1/domains/dom_1/retry", null);
            yield return Case(c => c.Tenants.SendInviteAsync("ten_1", new Dictionary<string, object> { ["email"] = "a@b.c" }), "POST", "/v1/tenants/ten_1/invites", new Dictionary<string, object> { ["email"] = "a@b.c" });
            yield return Case(c => c.Tenants.ListProjectsAsync("ten_1"), "GET", "/v1/tenants/ten_1/projects", null);
            yield return Case(c => c.Tenants.ListSeatsAsync("ten_1"), "GET", "/v1/tenants/ten_1/seats", null);
            yield return Case(c => c.Tenants.UpdateSeatAsync("ten_1", "seat_1", new Dictionary<string, object> { ["active"] = true }), "PATCH", "/v1/tenants/ten_1/seats/seat_1", new Dictionary<string, object> { ["active"] = true });
            yield return Case(c => c.Tenants.DeleteSeatAsync("ten_1", "seat_1"), "DELETE", "/v1/tenants/ten_1/seats/seat_1", null);
        }

        private static IEnumerable<object[]> DirectoryCases()
        {
            yield return Case(c => c.Projects.SaveAsync("ten_1", new Dictionary<string, object> { ["name"] = "App" }), "POST", "/v1/tenants/ten_1/applications", new Dictionary<string, object> { ["name"] = "App" });
            yield return Case(c => c.Projects.GetAsync("ten_1", "app_1"), "GET", "/v1/tenants/ten_1/applications/app_1", null);
            yield return Case(c => c.Projects.DeleteAsync("ten_1", "app_1"), "DELETE", "/v1/tenants/ten_1/applications/app_1", null);
            yield return Case(c => c.Projects.SetDefaultEnvironmentAsync("ten_1", "app_1", new Dictionary<string, object> { ["environmentId"] = "env_1" }), "PUT", "/v1/tenants/ten_1/applications/app_1/default-environment", new Dictionary<string, object> { ["environmentId"] = "env_1" });
            yield return Case(c => c.Environments.ListAsync("ten_1", "app_1"), "GET", "/v1/tenants/ten_1/applications/app_1/environments", null);
            yield return Case(c => c.Environments.CreateAsync("ten_1", "app_1", new Dictionary<string, object> { ["name"] = "prod" }), "POST", "/v1/tenants/ten_1/applications/app_1/environments", new Dictionary<string, object> { ["name"] = "prod" });
            yield return Case(c => c.Environments.UpdateAsync("ten_1", "env_1", new Dictionary<string, object> { ["name"] = "prod" }), "PATCH", "/v1/tenants/ten_1/environments/env_1", new Dictionary<string, object> { ["name"] = "prod" });
            yield return Case(c => c.Environments.DeleteAsync("ten_1", "env_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1", null);
            yield return Case(c => c.Users.ListAsync("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/users", null);
            yield return Case(c => c.Users.CreateAsync("ten_1", "env_1", new Dictionary<string, object> { ["email"] = "a@b.c", ["password"] = "x" }), "POST", "/v1/tenants/ten_1/environments/env_1/users", new Dictionary<string, object> { ["email"] = "a@b.c", ["password"] = "x" });
            yield return Case(c => c.Users.SearchAsync("ten_1", "env_1", q: "ada"), "GET", "/v1/tenants/ten_1/environments/env_1/users/search", null);
            yield return Case(c => c.Users.CountAsync("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/users/count", null);
            yield return Case(c => c.Users.GetAsync("ten_1", "env_1", "usr_1"), "GET", "/v1/tenants/ten_1/environments/env_1/users/usr_1", null);
            yield return Case(c => c.Users.UpdateAsync("ten_1", "env_1", "usr_1", new Dictionary<string, object> { ["displayName"] = "Ada" }), "PUT", "/v1/tenants/ten_1/environments/env_1/users/usr_1", new Dictionary<string, object> { ["displayName"] = "Ada" });
            yield return Case(c => c.Users.DeleteAsync("ten_1", "env_1", "usr_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/users/usr_1", null);
            yield return Case(c => c.Users.SetActiveAsync("ten_1", "env_1", "usr_1", new Dictionary<string, object> { ["active"] = false }), "PATCH", "/v1/tenants/ten_1/environments/env_1/users/usr_1/active", new Dictionary<string, object> { ["active"] = false });
            yield return Case(c => c.Users.ListGroupsAsync("ten_1", "env_1", "usr_1"), "GET", "/v1/tenants/ten_1/environments/env_1/users/usr_1/groups", null);
            yield return Case(c => c.Groups.CreateAsync(new Dictionary<string, object> { ["environmentId"] = "env_1", ["name"] = "Admins" }), "POST", "/v1/groups", new Dictionary<string, object> { ["environmentId"] = "env_1", ["name"] = "Admins" });
            yield return Case(c => c.Groups.ListAsync("ten_1", "env_1"), "GET", "/v1/tenants/ten_1/environments/env_1/groups", null);
            yield return Case(c => c.Groups.DeleteAsync("ten_1", "env_1", "grp_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/groups/grp_1", null);
            yield return Case(c => c.Groups.ListMembersAsync("ten_1", "env_1", "grp_1"), "GET", "/v1/tenants/ten_1/environments/env_1/groups/grp_1/members", null);
            yield return Case(c => c.Groups.AddMemberAsync("ten_1", "env_1", "grp_1", new Dictionary<string, object> { ["userId"] = "usr_1" }), "POST", "/v1/tenants/ten_1/environments/env_1/groups/grp_1/members", new Dictionary<string, object> { ["userId"] = "usr_1" });
            yield return Case(c => c.Groups.RemoveMemberAsync("ten_1", "env_1", "grp_1", "usr_1"), "DELETE", "/v1/tenants/ten_1/environments/env_1/groups/grp_1/members/usr_1", null);
        }

        private static object[] Case(Func<AuthdogClient, Task> call, string method, string path, object? body) =>
            new object[] { call, method, path, body! };

        private static HttpResponseMessage JsonResponse(object payload, HttpStatusCode status = HttpStatusCode.OK)
        {
            return new HttpResponseMessage(status)
            {
                Content = new StringContent(JsonConvert.SerializeObject(payload), Encoding.UTF8, "application/json")
            };
        }

        private static (AuthdogClient Client, Func<HttpRequestMessage?> Captured, HttpClient HttpClient) ClientFor(
            HttpResponseMessage response,
            string? apiKey = "key-1")
        {
            var handler = new Mock<HttpMessageHandler>();
            HttpRequestMessage? captured = null;
            handler.Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>())
                .Callback<HttpRequestMessage, CancellationToken>((request, _) => captured = request)
                .ReturnsAsync(response);

            var httpClient = new HttpClient(handler.Object);
            var client = new AuthdogClient("https://api.authdog.com", apiKey, httpClient);
            return (client, () => captured, httpClient);
        }

        public void Dispose()
        {
        }
    }
}
