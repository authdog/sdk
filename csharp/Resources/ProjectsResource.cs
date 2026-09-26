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
    /// Project (application) Wave 1 operations
    /// </summary>
    public class ProjectsResource
    {
        private readonly AuthdogClient _client;

        public ProjectsResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> SaveAsync(string tenantId, object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, $"/v1/tenants/{tenantId}/applications", body);

        public JObject Save(string tenantId, object body) => SaveAsync(tenantId, body).GetAwaiter().GetResult();

        public Task<JObject> GetAsync(string tenantId, string applicationId) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, $"/v1/tenants/{tenantId}/applications/{applicationId}");

        public JObject Get(string tenantId, string applicationId) =>
            GetAsync(tenantId, applicationId).GetAwaiter().GetResult();

        public Task<JObject> DeleteAsync(string tenantId, string applicationId) =>
            _client.RequestAsync<JObject>(HttpMethod.Delete, $"/v1/tenants/{tenantId}/applications/{applicationId}");

        public JObject Delete(string tenantId, string applicationId) =>
            DeleteAsync(tenantId, applicationId).GetAwaiter().GetResult();

        public Task<JObject> SetDefaultEnvironmentAsync(string tenantId, string applicationId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Put,
                $"/v1/tenants/{tenantId}/applications/{applicationId}/default-environment",
                body);

        public JObject SetDefaultEnvironment(string tenantId, string applicationId, object body) =>
            SetDefaultEnvironmentAsync(tenantId, applicationId, body).GetAwaiter().GetResult();
    }
}
