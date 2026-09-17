using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Personal access token Wave 2 operations
    /// </summary>
    public class PersonalAccessTokensResource
    {
        private readonly AuthdogClient _client;

        public PersonalAccessTokensResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListAsync() =>
            _client.RequestAsync<JObject>(HttpMethod.Get, "/v1/personal-access-tokens");

        public JObject List() => ListAsync().GetAwaiter().GetResult();

        public Task<JObject> CreateAsync(object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, "/v1/personal-access-tokens", body);

        public JObject Create(object body) => CreateAsync(body).GetAwaiter().GetResult();

        public Task<JObject> RevokeAsync(string tokenId) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, $"/v1/personal-access-tokens/{tokenId}/revoke");

        public JObject Revoke(string tokenId) => RevokeAsync(tokenId).GetAwaiter().GetResult();
    }
}
