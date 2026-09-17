using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Environment audit Wave 2 operations
    /// </summary>
    public class AuditResource
    {
        private readonly AuthdogClient _client;

        public AuditResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListLogsAsync(string tenantId, string environmentId, object? query = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/audit/logs",
                query: AuthdogClient.QueryFrom(query));

        public JObject ListLogs(string tenantId, string environmentId, object? query = null) =>
            ListLogsAsync(tenantId, environmentId, query).GetAwaiter().GetResult();

        public Task<JObject> EventMetadataAsync(string tenantId, string environmentId, object? query = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/audit/event-metadata",
                query: AuthdogClient.QueryFrom(query));

        public JObject EventMetadata(string tenantId, string environmentId, object? query = null) =>
            EventMetadataAsync(tenantId, environmentId, query).GetAwaiter().GetResult();

        public Task<JObject> EventTypesAsync(string tenantId, string environmentId, object? query = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/audit/event-types",
                query: AuthdogClient.QueryFrom(query));

        public JObject EventTypes(string tenantId, string environmentId, object? query = null) =>
            EventTypesAsync(tenantId, environmentId, query).GetAwaiter().GetResult();

        public Task<JObject> EventTypesCatalogAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/audit/event-types/catalog");

        public JObject EventTypesCatalog(string tenantId, string environmentId) =>
            EventTypesCatalogAsync(tenantId, environmentId).GetAwaiter().GetResult();
    }
}
