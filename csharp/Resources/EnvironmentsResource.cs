// MIT License
//
// Copyright (c) 2025 Authdog
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
