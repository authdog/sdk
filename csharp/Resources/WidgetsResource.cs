using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Widget-token Wave 3 operations
    /// </summary>
    public class WidgetsResource
    {
        private readonly AuthdogClient _client;

        public WidgetsResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> CreateTokenAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/widgets/token",
                body);

        public JObject CreateToken(string tenantId, string environmentId, object body) =>
            CreateTokenAsync(tenantId, environmentId, body).GetAwaiter().GetResult();
    }
}
