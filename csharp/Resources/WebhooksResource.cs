using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Environment webhook Wave 2 operations
    /// </summary>
    public class WebhooksResource
    {
        private readonly AuthdogClient _client;

        public WebhooksResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/webhooks");

        public JObject List(string tenantId, string environmentId) =>
            ListAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> CreateAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/webhooks",
                body);

        public JObject Create(string tenantId, string environmentId, object body) =>
            CreateAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> UpdateAsync(string tenantId, string environmentId, string channelId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Put,
                $"{AuthdogClient.Env(tenantId, environmentId)}/webhooks/{channelId}",
                body);

        public JObject Update(string tenantId, string environmentId, string channelId, object body) =>
            UpdateAsync(tenantId, environmentId, channelId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteAsync(string tenantId, string environmentId, string channelId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/webhooks/{channelId}");

        public JObject Delete(string tenantId, string environmentId, string channelId) =>
            DeleteAsync(tenantId, environmentId, channelId).GetAwaiter().GetResult();

        public Task<JObject> RotateSecretAsync(string tenantId, string environmentId, string channelId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/webhooks/{channelId}/rotate-secret");

        public JObject RotateSecret(string tenantId, string environmentId, string channelId) =>
            RotateSecretAsync(tenantId, environmentId, channelId).GetAwaiter().GetResult();

        public Task<JObject> ListDeliveriesAsync(string tenantId, string environmentId, object? query = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/webhooks/deliveries",
                query: AuthdogClient.QueryFrom(query));

        public JObject ListDeliveries(string tenantId, string environmentId, object? query = null) =>
            ListDeliveriesAsync(tenantId, environmentId, query).GetAwaiter().GetResult();

        public Task<JObject> RedeliverAsync(string tenantId, string environmentId, string deliveryId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/webhooks/deliveries/{deliveryId}/redeliver");

        public JObject Redeliver(string tenantId, string environmentId, string deliveryId) =>
            RedeliverAsync(tenantId, environmentId, deliveryId).GetAwaiter().GetResult();
    }
}
