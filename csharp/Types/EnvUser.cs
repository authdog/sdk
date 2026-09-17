using Newtonsoft.Json;

namespace Authdog.Types
{
    /// <summary>
    /// Directory user in an environment (distinct from user-info User)
    /// </summary>
    public class EnvUser
    {
        [JsonProperty("id")]
        public string Id { get; set; } = string.Empty;

        [JsonProperty("environmentId")]
        public string? EnvironmentId { get; set; }

        [JsonProperty("externalId")]
        public string? ExternalId { get; set; }

        [JsonProperty("userName")]
        public string? UserName { get; set; }

        [JsonProperty("displayName")]
        public string? DisplayName { get; set; }

        [JsonProperty("nickName")]
        public string? NickName { get; set; }

        [JsonProperty("profileUrl")]
        public string? ProfileUrl { get; set; }

        [JsonProperty("active")]
        public bool? Active { get; set; }

        [JsonProperty("changePw")]
        public bool? ChangePw { get; set; }

        [JsonProperty("provider")]
        public string? Provider { get; set; }

        [JsonProperty("emails")]
        public List<EnvUserEmail> Emails { get; set; } = new();

        [JsonProperty("lastLogin")]
        public string? LastLogin { get; set; }

        [JsonProperty("createdAt")]
        public string? CreatedAt { get; set; }

        [JsonProperty("updatedAt")]
        public string? UpdatedAt { get; set; }
    }
}
