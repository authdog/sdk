using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Environment forms Wave 3 operations
    /// </summary>
    public class FormsResource
    {
        private readonly AuthdogClient _client;

        public FormsResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListAttachmentsAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/form-attachments");

        public JObject ListAttachments(string tenantId, string environmentId) =>
            ListAttachmentsAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> ListAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/forms");

        public JObject List(string tenantId, string environmentId) =>
            ListAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> SaveAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/forms",
                body);

        public JObject Save(string tenantId, string environmentId, object body) =>
            SaveAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteAsync(string tenantId, string environmentId, string formId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/forms/{formId}");

        public JObject Delete(string tenantId, string environmentId, string formId) =>
            DeleteAsync(tenantId, environmentId, formId).GetAwaiter().GetResult();
    }
}
