using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Environment Wave 1 operations
    /// </summary>
    public class EnvironmentsResource
    {
        private readonly AuthdogClient _client;

        public EnvironmentsResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListAsync(string tenantId, string applicationId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"/v1/tenants/{tenantId}/applications/{applicationId}/environments");

        public JObject List(string tenantId, string applicationId) =>
            ListAsync(tenantId, applicationId).GetAwaiter().GetResult();

        public Task<JObject> CreateAsync(string tenantId, string applicationId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"/v1/tenants/{tenantId}/applications/{applicationId}/environments",
                body);

        public JObject Create(string tenantId, string applicationId, object body) =>
            CreateAsync(tenantId, applicationId, body).GetAwaiter().GetResult();

        public Task<JObject> UpdateAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Patch,
                $"/v1/tenants/{tenantId}/environments/{environmentId}",
                body);

        public JObject Update(string tenantId, string environmentId, object body) =>
            UpdateAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"/v1/tenants/{tenantId}/environments/{environmentId}");

        public JObject Delete(string tenantId, string environmentId) =>
            DeleteAsync(tenantId, environmentId).GetAwaiter().GetResult();
    }
}
