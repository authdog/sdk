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
