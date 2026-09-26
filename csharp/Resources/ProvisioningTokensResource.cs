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
    /// SCIM and HRIS provisioning-token Wave 3 operations
    /// </summary>
    public class ProvisioningTokensResource
    {
        private readonly AuthdogClient _client;

        public ProvisioningTokensResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListHrisAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/hris-tokens");

        public JObject ListHris(string tenantId, string environmentId) =>
            ListHrisAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> CreateHrisAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/hris-tokens",
                body);

        public JObject CreateHris(string tenantId, string environmentId, object body) =>
            CreateHrisAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> RevokeHrisAsync(string tenantId, string environmentId, string tokenId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/hris-tokens/{tokenId}/revoke");

        public JObject RevokeHris(string tenantId, string environmentId, string tokenId) =>
            RevokeHrisAsync(tenantId, environmentId, tokenId).GetAwaiter().GetResult();

        public Task<JObject> RotateHrisAsync(string tenantId, string environmentId, string tokenId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/hris-tokens/{tokenId}/rotate");

        public JObject RotateHris(string tenantId, string environmentId, string tokenId) =>
            RotateHrisAsync(tenantId, environmentId, tokenId).GetAwaiter().GetResult();

        public Task<JObject> ListScimAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/scim-tokens");

        public JObject ListScim(string tenantId, string environmentId) =>
            ListScimAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> CreateScimAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/scim-tokens",
                body);

        public JObject CreateScim(string tenantId, string environmentId, object body) =>
            CreateScimAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> RevokeScimAsync(string tenantId, string environmentId, string tokenId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/scim-tokens/{tokenId}/revoke");

        public JObject RevokeScim(string tenantId, string environmentId, string tokenId) =>
            RevokeScimAsync(tenantId, environmentId, tokenId).GetAwaiter().GetResult();

        public Task<JObject> RotateScimAsync(string tenantId, string environmentId, string tokenId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/scim-tokens/{tokenId}/rotate");

        public JObject RotateScim(string tenantId, string environmentId, string tokenId) =>
            RotateScimAsync(tenantId, environmentId, tokenId).GetAwaiter().GetResult();
    }
}
