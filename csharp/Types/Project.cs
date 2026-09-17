using Newtonsoft.Json;

namespace Authdog.Types
{
    /// <summary>
    /// Project (application)
    /// </summary>
    public class Project
    {
        [JsonProperty("id")]
        public string Id { get; set; } = string.Empty;

        [JsonProperty("name")]
        public string Name { get; set; } = string.Empty;

        [JsonProperty("description")]
        public string? Description { get; set; }
    }
}
