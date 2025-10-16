using Newtonsoft.Json;

namespace Authdog.Types
{
    /// <summary>
    /// User information
    /// </summary>
    public class User
    {
        [JsonProperty("id")]
        public string Id { get; set; } = string.Empty;

        [JsonProperty("externalId")]
        public string ExternalId { get; set; } = string.Empty;

        [JsonProperty("userName")]
        public string UserName { get; set; } = string.Empty;

        [JsonProperty("displayName")]
        public string DisplayName { get; set; } = string.Empty;

        [JsonProperty("nickName")]
        public string? NickName { get; set; }

        [JsonProperty("profileUrl")]
        public string? ProfileUrl { get; set; }

        [JsonProperty("title")]
        public string? Title { get; set; }

        [JsonProperty("userType")]
        public string? UserType { get; set; }

        [JsonProperty("preferredLanguage")]
        public string? PreferredLanguage { get; set; }

        [JsonProperty("locale")]
        public string Locale { get; set; } = string.Empty;

        [JsonProperty("timezone")]
        public string? Timezone { get; set; }

        [JsonProperty("active")]
        public bool Active { get; set; }

        [JsonProperty("names")]
        public Names Names { get; set; } = new();

        [JsonProperty("photos")]
        public List<Photo> Photos { get; set; } = new();

        [JsonProperty("phoneNumbers")]
        public List<object> PhoneNumbers { get; set; } = new();

        [JsonProperty("addresses")]
        public List<object> Addresses { get; set; } = new();

        [JsonProperty("emails")]
        public List<Email> Emails { get; set; } = new();

        [JsonProperty("verifications")]
        public List<Verification> Verifications { get; set; } = new();

        [JsonProperty("provider")]
        public string Provider { get; set; } = string.Empty;

        [JsonProperty("createdAt")]
        public string CreatedAt { get; set; } = string.Empty;

        [JsonProperty("updatedAt")]
        public string UpdatedAt { get; set; } = string.Empty;

        [JsonProperty("environmentId")]
        public string EnvironmentId { get; set; } = string.Empty;
    }
}
