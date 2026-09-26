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
    /// Environment OIDC client Wave 3 operations
    /// </summary>
    public class OidcClientsResource
    {
        private readonly AuthdogClient _client;

        public OidcClientsResource(AuthdogClient client)
        {
            _client = client;
        }

        private static string Path(string tenantId, string applicationId, string environmentId) =>
            $"/v1/tenants/{tenantId}/applications/{applicationId}/environments/{environmentId}/oidc-clients";

        public Task<JObject> ListAsync(string tenantId, string applicationId, string environmentId) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, Path(tenantId, applicationId, environmentId));

        public JObject List(string tenantId, string applicationId, string environmentId) =>
            ListAsync(tenantId, applicationId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> RegisterAsync(string tenantId, string applicationId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, Path(tenantId, applicationId, environmentId), body);

        public JObject Register(string tenantId, string applicationId, string environmentId, object body) =>
            RegisterAsync(tenantId, applicationId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> UpdateAsync(
            string tenantId,
            string applicationId,
            string environmentId,
            string clientId,
            object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Patch,
                $"{Path(tenantId, applicationId, environmentId)}/{clientId}",
                body);

        public JObject Update(
            string tenantId,
            string applicationId,
            string environmentId,
            string clientId,
            object body) =>
            UpdateAsync(tenantId, applicationId, environmentId, clientId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteAsync(string tenantId, string applicationId, string environmentId, string clientId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{Path(tenantId, applicationId, environmentId)}/{clientId}");

        public JObject Delete(string tenantId, string applicationId, string environmentId, string clientId) =>
            DeleteAsync(tenantId, applicationId, environmentId, clientId).GetAwaiter().GetResult();
    }
}
