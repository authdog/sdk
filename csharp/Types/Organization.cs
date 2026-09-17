using Newtonsoft.Json;

namespace Authdog.Types
{
    /// <summary>
    /// Customer organization
    /// </summary>
    public class Organization
    {
        [JsonProperty("id")]
        public string Id { get; set; } = string.Empty;

        [JsonProperty("name")]
        public string Name { get; set; } = string.Empty;

        [JsonProperty("description")]
        public string? Description { get; set; }

        [JsonProperty("billingEmail")]
        public string? BillingEmail { get; set; }

        [JsonProperty("logoUri")]
        public string? LogoUri { get; set; }

        [JsonProperty("active")]
        public bool Active { get; set; }

        [JsonProperty("createdAt")]
        public string CreatedAt { get; set; } = string.Empty;

        [JsonProperty("updatedAt")]
        public string UpdatedAt { get; set; } = string.Empty;
    }
}
