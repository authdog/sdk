using Newtonsoft.Json;

namespace Authdog.Types
{
    /// <summary>
    /// Response from the /v1/userinfo endpoint
    /// </summary>
    public class UserInfoResponse
    {
        [JsonProperty("meta")]
        public Meta Meta { get; set; } = new();

        [JsonProperty("session")]
        public Session Session { get; set; } = new();

        [JsonProperty("user")]
        public User User { get; set; } = new();
    }
}
