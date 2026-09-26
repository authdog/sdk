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
    /// Environment vanity-domain Wave 3 operations
    /// </summary>
    public class VanityDomainsResource
    {
        private readonly AuthdogClient _client;

        public VanityDomainsResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/vanity-domains");

        public JObject List(string tenantId, string environmentId) =>
            ListAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> CreateAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/vanity-domains",
                body);

        public JObject Create(string tenantId, string environmentId, object body) =>
            CreateAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteAsync(string tenantId, string environmentId, string domainId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/vanity-domains/{domainId}");

        public JObject Delete(string tenantId, string environmentId, string domainId) =>
            DeleteAsync(tenantId, environmentId, domainId).GetAwaiter().GetResult();

        public Task<JObject> CheckAsync(string tenantId, string environmentId, string domainId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/vanity-domains/{domainId}/check");

        public JObject Check(string tenantId, string environmentId, string domainId) =>
            CheckAsync(tenantId, environmentId, domainId).GetAwaiter().GetResult();
    }
}
