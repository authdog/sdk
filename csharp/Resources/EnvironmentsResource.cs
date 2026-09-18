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

        public Task<JObject> ListConnectionsAsync(string tenantId, string applicationId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"/v1/tenants/{tenantId}/applications/{applicationId}/environments/{environmentId}/connections");

        public JObject ListConnections(string tenantId, string applicationId, string environmentId) =>
            ListConnectionsAsync(tenantId, applicationId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> ListRedirectUrisAsync(string tenantId, string applicationId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"/v1/tenants/{tenantId}/applications/{applicationId}/environments/{environmentId}/redirect-uris");

        public JObject ListRedirectUris(string tenantId, string applicationId, string environmentId) =>
            ListRedirectUrisAsync(tenantId, applicationId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> SaveConnectionAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/connections",
                body);

        public JObject SaveConnection(string tenantId, string environmentId, object body) =>
            SaveConnectionAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> ResolveSamlMetadataAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/connections/resolve-saml-metadata",
                body);

        public JObject ResolveSamlMetadata(string tenantId, string environmentId, object body) =>
            ResolveSamlMetadataAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> GetSsoMetadataAsync(
            string tenantId,
            string environmentId,
            string? connectionId = null,
            string? providerId = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/connections/sso-metadata",
                query: AuthdogClient.Params(("connectionId", connectionId), ("providerId", providerId)));

        public JObject GetSsoMetadata(
            string tenantId,
            string environmentId,
            string? connectionId = null,
            string? providerId = null) =>
            GetSsoMetadataAsync(tenantId, environmentId, connectionId, providerId).GetAwaiter().GetResult();

        public Task<JObject> DeleteConnectionAsync(string tenantId, string environmentId, string connectionId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/connections/{connectionId}");

        public JObject DeleteConnection(string tenantId, string environmentId, string connectionId) =>
            DeleteConnectionAsync(tenantId, environmentId, connectionId).GetAwaiter().GetResult();

        public Task<JObject> SaveRedirectUrisAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Put,
                $"{AuthdogClient.Env(tenantId, environmentId)}/redirect-uris",
                body);

        public JObject SaveRedirectUris(string tenantId, string environmentId, object body) =>
            SaveRedirectUrisAsync(tenantId, environmentId, body).GetAwaiter().GetResult();
    }
}
