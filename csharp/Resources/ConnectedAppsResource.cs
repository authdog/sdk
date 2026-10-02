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
    /// Connected-app grants and the OIDC client allowlist
    /// </summary>
    public class ConnectedAppsResource
    {
        private readonly AuthdogClient _client;

        public ConnectedAppsResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListAsync(
            string tenantId,
            string environmentId,
            string? userId = null,
            string? clientId = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/connected-apps",
                query: AuthdogClient.Params(("userId", userId), ("clientId", clientId)));

        public JObject List(string tenantId, string environmentId, string? userId = null, string? clientId = null) =>
            ListAsync(tenantId, environmentId, userId, clientId).GetAwaiter().GetResult();

        public Task<JObject> RevokeAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/connected-apps/revoke",
                body);

        public JObject Revoke(string tenantId, string environmentId, object body) =>
            RevokeAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> ListAllowlistAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/client-allowlist");

        public JObject ListAllowlist(string tenantId, string environmentId) =>
            ListAllowlistAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> SaveAllowlistAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/client-allowlist",
                body);

        public JObject SaveAllowlist(string tenantId, string environmentId, object body) =>
            SaveAllowlistAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteAllowlistAsync(string tenantId, string environmentId, string clientId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/client-allowlist/{clientId}");

        public JObject DeleteAllowlist(string tenantId, string environmentId, string clientId) =>
            DeleteAllowlistAsync(tenantId, environmentId, clientId).GetAwaiter().GetResult();
    }
}
