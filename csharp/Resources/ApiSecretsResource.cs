using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Environment API secret Wave 2 operations
    /// </summary>
    public class ApiSecretsResource
    {
        private readonly AuthdogClient _client;

        public ApiSecretsResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/api-secrets");

        public JObject List(string tenantId, string environmentId) =>
            ListAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> CreateAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/api-secrets",
                body);

        public JObject Create(string tenantId, string environmentId, object body) =>
            CreateAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> RevokeAsync(string tenantId, string environmentId, string secretId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/api-secrets/{secretId}/revoke");

        public JObject Revoke(string tenantId, string environmentId, string secretId) =>
            RevokeAsync(tenantId, environmentId, secretId).GetAwaiter().GetResult();
    }
}
