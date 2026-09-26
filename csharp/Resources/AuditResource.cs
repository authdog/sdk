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
