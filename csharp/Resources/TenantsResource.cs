using System.Net.Http;
using System.Threading.Tasks;
using Authdog.Types;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Tenant Wave 1 operations
    /// </summary>
    public class TenantsResource
    {
        private readonly AuthdogClient _client;

        public TenantsResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<TenantsList> ListAsync(string? organizationId = null) =>
            _client.RequestAsync<TenantsList>(
                HttpMethod.Get,
                "/v1/tenants",
                query: AuthdogClient.Params(("organization_id", organizationId)));

        public TenantsList List(string? organizationId = null) =>
            ListAsync(organizationId).GetAwaiter().GetResult();

        public Task<JObject> CreateAsync(object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, "/v1/tenants", body);

        public JObject Create(object body) => CreateAsync(body).GetAwaiter().GetResult();

        public Task<JObject> JoinAsync(object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, "/v1/tenants/join", body);

        public JObject Join(object body) => JoinAsync(body).GetAwaiter().GetResult();

        public Task<JObject> GetAsync(string tenantId, string? organizationId = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"/v1/tenants/{tenantId}",
                query: AuthdogClient.Params(("organization_id", organizationId)));

        public JObject Get(string tenantId, string? organizationId = null) =>
            GetAsync(tenantId, organizationId).GetAwaiter().GetResult();

        public Task<JObject> UpdateAsync(string tenantId, object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Patch, $"/v1/tenants/{tenantId}", body);

        public JObject Update(string tenantId, object body) =>
            UpdateAsync(tenantId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteAsync(string tenantId) =>
            _client.RequestAsync<JObject>(HttpMethod.Delete, $"/v1/tenants/{tenantId}");

        public JObject Delete(string tenantId) => DeleteAsync(tenantId).GetAwaiter().GetResult();

        public Task<JObject> ListDomainsAsync(string tenantId) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, $"/v1/tenants/{tenantId}/domains");

        public JObject ListDomains(string tenantId) => ListDomainsAsync(tenantId).GetAwaiter().GetResult();

        public Task<JObject> CreateDomainAsync(string tenantId, object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, $"/v1/tenants/{tenantId}/domains", body);

        public JObject CreateDomain(string tenantId, object body) =>
            CreateDomainAsync(tenantId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteDomainAsync(string tenantId, string domainId) =>
            _client.RequestAsync<JObject>(HttpMethod.Delete, $"/v1/tenants/{tenantId}/domains/{domainId}");

        public JObject DeleteDomain(string tenantId, string domainId) =>
            DeleteDomainAsync(tenantId, domainId).GetAwaiter().GetResult();

        public Task<JObject> RetryDomainAsync(string tenantId, string domainId) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, $"/v1/tenants/{tenantId}/domains/{domainId}/retry");

        public JObject RetryDomain(string tenantId, string domainId) =>
            RetryDomainAsync(tenantId, domainId).GetAwaiter().GetResult();

        public Task<JObject> SendInviteAsync(string tenantId, object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, $"/v1/tenants/{tenantId}/invites", body);

        public JObject SendInvite(string tenantId, object body) =>
            SendInviteAsync(tenantId, body).GetAwaiter().GetResult();

        public Task<JObject> ListProjectsAsync(string tenantId) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, $"/v1/tenants/{tenantId}/projects");

        public JObject ListProjects(string tenantId) => ListProjectsAsync(tenantId).GetAwaiter().GetResult();

        public Task<JObject> ListSeatsAsync(string tenantId) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, $"/v1/tenants/{tenantId}/seats");

        public JObject ListSeats(string tenantId) => ListSeatsAsync(tenantId).GetAwaiter().GetResult();

        public Task<JObject> UpdateSeatAsync(string tenantId, string seatId, object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Patch, $"/v1/tenants/{tenantId}/seats/{seatId}", body);

        public JObject UpdateSeat(string tenantId, string seatId, object body) =>
            UpdateSeatAsync(tenantId, seatId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteSeatAsync(string tenantId, string seatId) =>
            _client.RequestAsync<JObject>(HttpMethod.Delete, $"/v1/tenants/{tenantId}/seats/{seatId}");

        public JObject DeleteSeat(string tenantId, string seatId) =>
            DeleteSeatAsync(tenantId, seatId).GetAwaiter().GetResult();
    }
}
