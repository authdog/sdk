using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Environment notification channel Wave 2 operations
    /// </summary>
    public class NotificationChannelsResource
    {
        private readonly AuthdogClient _client;

        public NotificationChannelsResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/notification-channels");

        public JObject List(string tenantId, string environmentId) =>
            ListAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> CreateAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/notification-channels",
                body);

        public JObject Create(string tenantId, string environmentId, object body) =>
            CreateAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> UpdateAsync(string tenantId, string environmentId, string channelId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Put,
                $"{AuthdogClient.Env(tenantId, environmentId)}/notification-channels/{channelId}",
                body);

        public JObject Update(string tenantId, string environmentId, string channelId, object body) =>
            UpdateAsync(tenantId, environmentId, channelId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteAsync(string tenantId, string environmentId, string channelId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/notification-channels/{channelId}");

        public JObject Delete(string tenantId, string environmentId, string channelId) =>
            DeleteAsync(tenantId, environmentId, channelId).GetAwaiter().GetResult();

        public Task<JObject> TestAsync(
            string tenantId,
            string environmentId,
            string channelId,
            object? body = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/notification-channels/{channelId}/test",
                body);

        public JObject Test(string tenantId, string environmentId, string channelId, object? body = null) =>
            TestAsync(tenantId, environmentId, channelId, body).GetAwaiter().GetResult();
    }
}
