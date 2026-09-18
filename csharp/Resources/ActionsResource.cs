using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Environment actions Wave 3 operations
    /// </summary>
    public class ActionsResource
    {
        private readonly AuthdogClient _client;

        public ActionsResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/actions");

        public JObject List(string tenantId, string environmentId) =>
            ListAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> SaveAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/actions",
                body);

        public JObject Save(string tenantId, string environmentId, object body) =>
            SaveAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> ExecutionsAsync(
            string tenantId,
            string environmentId,
            string? actionId = null,
            int? limit = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/actions/executions",
                query: AuthdogClient.Params(("actionId", actionId), ("limit", limit)));

        public JObject Executions(
            string tenantId,
            string environmentId,
            string? actionId = null,
            int? limit = null) =>
            ExecutionsAsync(tenantId, environmentId, actionId, limit).GetAwaiter().GetResult();

        public Task<JObject> TestAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/actions/test",
                body);

        public JObject Test(string tenantId, string environmentId, object body) =>
            TestAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteAsync(string tenantId, string environmentId, string actionId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/actions/{actionId}");

        public JObject Delete(string tenantId, string environmentId, string actionId) =>
            DeleteAsync(tenantId, environmentId, actionId).GetAwaiter().GetResult();
    }
}
