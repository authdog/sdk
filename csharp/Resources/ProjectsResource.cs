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
