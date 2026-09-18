using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Environment security Wave 3 operations
    /// </summary>
    public class SecurityResource
    {
        private readonly AuthdogClient _client;

        public SecurityResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> PostureAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/security/posture");

        public JObject Posture(string tenantId, string environmentId) =>
            PostureAsync(tenantId, environmentId).GetAwaiter().GetResult();
    }
}
