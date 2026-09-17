using Newtonsoft.Json;

namespace Authdog.Types
{
    /// <summary>
    /// List envelope for directory users
    /// </summary>
    public class EnvUsersResponse
    {
        [JsonProperty("users")]
        public List<EnvUser> Users { get; set; } = new();
    }
}
