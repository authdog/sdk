using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Environment events Wave 2 operations
    /// </summary>
    public class EventsResource
    {
        private readonly AuthdogClient _client;

        public EventsResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListAsync(string tenantId, string environmentId, object? query = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/events",
                query: AuthdogClient.QueryFrom(query));

        public JObject List(string tenantId, string environmentId, object? query = null) =>
            ListAsync(tenantId, environmentId, query).GetAwaiter().GetResult();

        public Task<JObject> ListTypesAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/events/types");

        public JObject ListTypes(string tenantId, string environmentId) =>
            ListTypesAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> IngestAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/events/ingest",
                body);

        public JObject Ingest(string tenantId, string environmentId, object body) =>
            IngestAsync(tenantId, environmentId, body).GetAwaiter().GetResult();
    }
}
