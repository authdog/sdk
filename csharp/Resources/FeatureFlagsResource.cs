using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Environment feature-flag Wave 3 operations
    /// </summary>
    public class FeatureFlagsResource
    {
        private readonly AuthdogClient _client;

        public FeatureFlagsResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/feature-flags");

        public JObject List(string tenantId, string environmentId) =>
            ListAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> SaveAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/feature-flags",
                body);

        public JObject Save(string tenantId, string environmentId, object body) =>
            SaveAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteAsync(string tenantId, string environmentId, string flagId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/feature-flags/{flagId}");

        public JObject Delete(string tenantId, string environmentId, string flagId) =>
            DeleteAsync(tenantId, environmentId, flagId).GetAwaiter().GetResult();
    }
}
