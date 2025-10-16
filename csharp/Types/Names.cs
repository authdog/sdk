using Newtonsoft.Json;

namespace Authdog.Types
{
    /// <summary>
    /// User name information
    /// </summary>
    public class Names
    {
        [JsonProperty("id")]
        public string Id { get; set; } = string.Empty;

        [JsonProperty("formatted")]
        public string? Formatted { get; set; }

        [JsonProperty("familyName")]
        public string FamilyName { get; set; } = string.Empty;

        [JsonProperty("givenName")]
        public string GivenName { get; set; } = string.Empty;

        [JsonProperty("middleName")]
        public string? MiddleName { get; set; }

        [JsonProperty("honorificPrefix")]
        public string? HonorificPrefix { get; set; }

        [JsonProperty("honorificSuffix")]
        public string? HonorificSuffix { get; set; }
    }
}
