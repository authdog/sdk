using Newtonsoft.Json;

namespace Authdog.Types
{
    /// <summary>
    /// Application environment
    /// </summary>
    public class Environment
    {
        [JsonProperty("id")]
        public string Id { get; set; } = string.Empty;

        [JsonProperty("name")]
        public string Name { get; set; } = string.Empty;

        [JsonProperty("description")]
        public string? Description { get; set; }

        [JsonProperty("weight")]
        public double? Weight { get; set; }

        [JsonProperty("isLive")]
        public bool? IsLive { get; set; }

        [JsonProperty("isDefault")]
        public bool? IsDefault { get; set; }

        [JsonProperty("createdAt")]
        public string? CreatedAt { get; set; }

        [JsonProperty("updatedAt")]
        public string? UpdatedAt { get; set; }
    }
}
