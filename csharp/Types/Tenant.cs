using Newtonsoft.Json;

namespace Authdog.Types
{
    /// <summary>
    /// Tenant
    /// </summary>
    public class Tenant
    {
        [JsonProperty("id")]
        public string Id { get; set; } = string.Empty;

        [JsonProperty("name")]
        public string Name { get; set; } = string.Empty;

        [JsonProperty("description")]
        public string? Description { get; set; }

        [JsonProperty("company")]
        public string? Company { get; set; }

        [JsonProperty("active")]
        public bool Active { get; set; }

        [JsonProperty("createdAt")]
        public string CreatedAt { get; set; } = string.Empty;

        [JsonProperty("updatedAt")]
        public string UpdatedAt { get; set; } = string.Empty;

        [JsonProperty("organizationIds")]
        public List<string> OrganizationIds { get; set; } = new();
    }
}
