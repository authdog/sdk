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
    /// MCP runtime and trust-store Wave 3 operations
    /// </summary>
    public class McpResource
    {
        private readonly AuthdogClient _client;

        public McpResource(AuthdogClient client)
        {
            _client = client;
        }

        private string? Runtime(string? token) => token ?? _client.EnvironmentSecret;

        public Task<JObject> IngestEventsAsync(object body, string? token = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                "/v1/mcp/events",
                body,
                accessToken: Runtime(token));

        public JObject IngestEvents(object body, string? token = null) =>
            IngestEventsAsync(body, token).GetAwaiter().GetResult();

        public Task<JObject> ResolveAsync(string subject, string? token = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                "/v1/mcp/trust-store/resolve",
                query: AuthdogClient.Params(("subject", subject)),
                accessToken: Runtime(token));

        public JObject Resolve(string subject, string? token = null) =>
            ResolveAsync(subject, token).GetAwaiter().GetResult();

        public Task<JObject> ListEntriesAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/mcp/trust-store");

        public JObject ListEntries(string tenantId, string environmentId) =>
            ListEntriesAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> CreateEntryAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/mcp/trust-store",
                body);

        public JObject CreateEntry(string tenantId, string environmentId, object body) =>
            CreateEntryAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> GetEntryAsync(string tenantId, string environmentId, string entryId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/mcp/trust-store/{entryId}");

        public JObject GetEntry(string tenantId, string environmentId, string entryId) =>
            GetEntryAsync(tenantId, environmentId, entryId).GetAwaiter().GetResult();

        public Task<JObject> UpdateEntryAsync(string tenantId, string environmentId, string entryId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Patch,
                $"{AuthdogClient.Env(tenantId, environmentId)}/mcp/trust-store/{entryId}",
                body);

        public JObject UpdateEntry(string tenantId, string environmentId, string entryId, object body) =>
            UpdateEntryAsync(tenantId, environmentId, entryId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteEntryAsync(string tenantId, string environmentId, string entryId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/mcp/trust-store/{entryId}");

        public JObject DeleteEntry(string tenantId, string environmentId, string entryId) =>
            DeleteEntryAsync(tenantId, environmentId, entryId).GetAwaiter().GetResult();

        public Task<JObject> AddKeyAsync(string tenantId, string environmentId, string entryId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/mcp/trust-store/{entryId}/keys",
                body);

        public JObject AddKey(string tenantId, string environmentId, string entryId, object body) =>
            AddKeyAsync(tenantId, environmentId, entryId, body).GetAwaiter().GetResult();

        public Task<JObject> RevokeKeyAsync(string tenantId, string environmentId, string entryId, string keyId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/mcp/trust-store/{entryId}/keys/{keyId}");

        public JObject RevokeKey(string tenantId, string environmentId, string entryId, string keyId) =>
            RevokeKeyAsync(tenantId, environmentId, entryId, keyId).GetAwaiter().GetResult();

        public Task<JObject> RotateKeyAsync(
            string tenantId,
            string environmentId,
            string entryId,
            string keyId,
            object? body = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/mcp/trust-store/{entryId}/keys/{keyId}/rotate",
                body);

        public JObject RotateKey(
            string tenantId,
            string environmentId,
            string entryId,
            string keyId,
            object? body = null) =>
            RotateKeyAsync(tenantId, environmentId, entryId, keyId, body).GetAwaiter().GetResult();

        public Task<JObject> RevokeEntryAsync(string tenantId, string environmentId, string entryId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/mcp/trust-store/{entryId}/revoke");

        public JObject RevokeEntry(string tenantId, string environmentId, string entryId) =>
            RevokeEntryAsync(tenantId, environmentId, entryId).GetAwaiter().GetResult();

        public Task<JObject> VerifyEntryAsync(string tenantId, string environmentId, string entryId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/mcp/trust-store/{entryId}/verify",
                body);

        public JObject VerifyEntry(string tenantId, string environmentId, string entryId, object body) =>
            VerifyEntryAsync(tenantId, environmentId, entryId, body).GetAwaiter().GetResult();

        public Task<JObject> VerifyKeyAsync(string tenantId, string environmentId, string entryId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/mcp/trust-store/{entryId}/verify-key",
                body);

        public JObject VerifyKey(string tenantId, string environmentId, string entryId, object body) =>
            VerifyKeyAsync(tenantId, environmentId, entryId, body).GetAwaiter().GetResult();

        public Task<JObject> VerifySvidAsync(string tenantId, string environmentId, string entryId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/mcp/trust-store/{entryId}/verify-svid",
                body);

        public JObject VerifySvid(string tenantId, string environmentId, string entryId, object body) =>
            VerifySvidAsync(tenantId, environmentId, entryId, body).GetAwaiter().GetResult();
    }
}
