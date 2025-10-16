using Newtonsoft.Json;

namespace Authdog.Types
{
    /// <summary>
    /// Email verification status
    /// </summary>
    public class Verification
    {
        [JsonProperty("id")]
        public string Id { get; set; } = string.Empty;

        [JsonProperty("email")]
        public string Email { get; set; } = string.Empty;

        [JsonProperty("verified")]
        public bool Verified { get; set; }

        [JsonProperty("createdAt")]
        public string CreatedAt { get; set; } = string.Empty;

        [JsonProperty("updatedAt")]
        public string UpdatedAt { get; set; } = string.Empty;
    }
}
