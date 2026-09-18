using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Environment email-provider Wave 3 operations
    /// </summary>
    public class EmailProvidersResource
    {
        private readonly AuthdogClient _client;

        public EmailProvidersResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/email-providers");

        public JObject List(string tenantId, string environmentId) =>
            ListAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> SaveAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/email-providers",
                body);

        public JObject Save(string tenantId, string environmentId, object body) =>
            SaveAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> TestAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/email-providers/test",
                body);

        public JObject Test(string tenantId, string environmentId, object body) =>
            TestAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteAsync(string tenantId, string environmentId, string provider) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/email-providers/{provider}");

        public JObject Delete(string tenantId, string environmentId, string provider) =>
            DeleteAsync(tenantId, environmentId, provider).GetAwaiter().GetResult();

        public Task<JObject> ActivateAsync(string tenantId, string environmentId, string provider) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/email-providers/{provider}/activate");

        public JObject Activate(string tenantId, string environmentId, string provider) =>
            ActivateAsync(tenantId, environmentId, provider).GetAwaiter().GetResult();
    }
}
