using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// AuthZEN discovery and evaluation Wave 3 operations
    /// </summary>
    public class AuthzenResource
    {
        private readonly AuthdogClient _client;

        public AuthzenResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ConfigurationAsync() =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                "/.well-known/authzen-configuration",
                omitAuth: true);

        public JObject Configuration() =>
            ConfigurationAsync().GetAwaiter().GetResult();

        public Task<JObject> EvaluateAsync(object body, string? token = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                "/access/v1/evaluation",
                body,
                accessToken: token ?? _client.EnvironmentSecret);

        public JObject Evaluate(object body, string? token = null) =>
            EvaluateAsync(body, token).GetAwaiter().GetResult();

        public Task<JObject> EvaluateBatchAsync(object body, string? token = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                "/access/v1/evaluations",
                body,
                accessToken: token ?? _client.EnvironmentSecret);

        public JObject EvaluateBatch(object body, string? token = null) =>
            EvaluateBatchAsync(body, token).GetAwaiter().GetResult();

        public Task<JObject> SearchActionAsync(object body, string? token = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                "/access/v1/search/action",
                body,
                accessToken: token ?? _client.EnvironmentSecret);

        public JObject SearchAction(object body, string? token = null) =>
            SearchActionAsync(body, token).GetAwaiter().GetResult();

        public Task<JObject> SearchResourceAsync(object body, string? token = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                "/access/v1/search/resource",
                body,
                accessToken: token ?? _client.EnvironmentSecret);

        public JObject SearchResource(object body, string? token = null) =>
            SearchResourceAsync(body, token).GetAwaiter().GetResult();

        public Task<JObject> SearchSubjectAsync(object body, string? token = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                "/access/v1/search/subject",
                body,
                accessToken: token ?? _client.EnvironmentSecret);

        public JObject SearchSubject(object body, string? token = null) =>
            SearchSubjectAsync(body, token).GetAwaiter().GetResult();
    }
}
