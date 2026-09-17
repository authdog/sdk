using Newtonsoft.Json;

namespace Authdog.Types
{
    /// <summary>
    /// List envelope for directory groups
    /// </summary>
    public class EnvGroupsResponse
    {
        [JsonProperty("groups")]
        public List<EnvGroup> Groups { get; set; } = new();
    }
}
