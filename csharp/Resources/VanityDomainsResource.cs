using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Environment vanity-domain Wave 3 operations
    /// </summary>
    public class VanityDomainsResource
    {
        private readonly AuthdogClient _client;

        public VanityDomainsResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/vanity-domains");

        public JObject List(string tenantId, string environmentId) =>
            ListAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> CreateAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/vanity-domains",
                body);

        public JObject Create(string tenantId, string environmentId, object body) =>
            CreateAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteAsync(string tenantId, string environmentId, string domainId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/vanity-domains/{domainId}");

        public JObject Delete(string tenantId, string environmentId, string domainId) =>
            DeleteAsync(tenantId, environmentId, domainId).GetAwaiter().GetResult();

        public Task<JObject> CheckAsync(string tenantId, string environmentId, string domainId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/vanity-domains/{domainId}/check");

        public JObject Check(string tenantId, string environmentId, string domainId) =>
            CheckAsync(tenantId, environmentId, domainId).GetAwaiter().GetResult();
    }
}
