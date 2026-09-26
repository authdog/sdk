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
    /// OpenTelemetry export Wave 3 operations
    /// </summary>
    public class OtelResource
    {
        private readonly AuthdogClient _client;

        public OtelResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ExportLogsAsync(object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, "/v1/logs", body);

        public JObject ExportLogs(object body) =>
            ExportLogsAsync(body).GetAwaiter().GetResult();

        public Task<JObject> ExportMetricsAsync(object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, "/v1/metrics", body);

        public JObject ExportMetrics(object body) =>
            ExportMetricsAsync(body).GetAwaiter().GetResult();

        public Task<JObject> ExportTracesAsync(object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, "/v1/traces", body);

        public JObject ExportTraces(object body) =>
            ExportTracesAsync(body).GetAwaiter().GetResult();

        public Task<JObject> ExportLogsPrefixedAsync(object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, "/v1/otel/v1/logs", body);

        public JObject ExportLogsPrefixed(object body) =>
            ExportLogsPrefixedAsync(body).GetAwaiter().GetResult();

        public Task<JObject> ExportMetricsPrefixedAsync(object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, "/v1/otel/v1/metrics", body);

        public JObject ExportMetricsPrefixed(object body) =>
            ExportMetricsPrefixedAsync(body).GetAwaiter().GetResult();

        public Task<JObject> ExportTracesPrefixedAsync(object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, "/v1/otel/v1/traces", body);

        public JObject ExportTracesPrefixed(object body) =>
            ExportTracesPrefixedAsync(body).GetAwaiter().GetResult();
    }
}
