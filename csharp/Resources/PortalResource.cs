using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// User-portal Wave 3 operations
    /// </summary>
    public class PortalResource
    {
        private readonly AuthdogClient _client;

        public PortalResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> GenerateLinkAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/portal/generate-link",
                body);

        public JObject GenerateLink(string tenantId, string environmentId, object body) =>
            GenerateLinkAsync(tenantId, environmentId, body).GetAwaiter().GetResult();
    }
}
