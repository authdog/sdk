using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Environment threat Wave 3 operations
    /// </summary>
    public class ThreatsResource
    {
        private readonly AuthdogClient _client;

        public ThreatsResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListAsync(string tenantId, string environmentId, object? query = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/threats",
                query: AuthdogClient.QueryFrom(query));

        public JObject List(string tenantId, string environmentId, object? query = null) =>
            ListAsync(tenantId, environmentId, query).GetAwaiter().GetResult();

        public Task<JObject> CreateAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/threats",
                body);

        public JObject Create(string tenantId, string environmentId, object body) =>
            CreateAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> GetAsync(string tenantId, string environmentId, string threatId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/threats/{threatId}");

        public JObject Get(string tenantId, string environmentId, string threatId) =>
            GetAsync(tenantId, environmentId, threatId).GetAwaiter().GetResult();

        public Task<JObject> UpdateAsync(string tenantId, string environmentId, string threatId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Patch,
                $"{AuthdogClient.Env(tenantId, environmentId)}/threats/{threatId}",
                body);

        public JObject Update(string tenantId, string environmentId, string threatId, object body) =>
            UpdateAsync(tenantId, environmentId, threatId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteAsync(string tenantId, string environmentId, string threatId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/threats/{threatId}");

        public JObject Delete(string tenantId, string environmentId, string threatId) =>
            DeleteAsync(tenantId, environmentId, threatId).GetAwaiter().GetResult();

        public Task<JObject> ResolveAsync(string tenantId, string environmentId, string threatId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/threats/{threatId}/resolve",
                body);

        public JObject Resolve(string tenantId, string environmentId, string threatId, object body) =>
            ResolveAsync(tenantId, environmentId, threatId, body).GetAwaiter().GetResult();
    }
}
