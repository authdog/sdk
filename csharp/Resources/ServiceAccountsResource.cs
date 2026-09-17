using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Service account Wave 2 operations
    /// </summary>
    public class ServiceAccountsResource
    {
        private readonly AuthdogClient _client;

        public ServiceAccountsResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListAsync() =>
            _client.RequestAsync<JObject>(HttpMethod.Get, "/v1/service-accounts");

        public JObject List() => ListAsync().GetAwaiter().GetResult();

        public Task<JObject> CreateAsync(object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, "/v1/service-accounts", body);

        public JObject Create(object body) => CreateAsync(body).GetAwaiter().GetResult();

        public Task<JObject> GetAsync(string serviceAccountId) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, $"/v1/service-accounts/{serviceAccountId}");

        public JObject Get(string serviceAccountId) => GetAsync(serviceAccountId).GetAwaiter().GetResult();

        public Task<JObject> DeleteAsync(string serviceAccountId) =>
            _client.RequestAsync<JObject>(HttpMethod.Delete, $"/v1/service-accounts/{serviceAccountId}");

        public JObject Delete(string serviceAccountId) =>
            DeleteAsync(serviceAccountId).GetAwaiter().GetResult();
    }
}
