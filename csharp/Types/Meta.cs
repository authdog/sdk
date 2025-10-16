using Newtonsoft.Json;

namespace Authdog.Types
{
    /// <summary>
    /// Metadata in the response
    /// </summary>
    public class Meta
    {
        [JsonProperty("code")]
        public int Code { get; set; }

        [JsonProperty("message")]
        public string Message { get; set; } = string.Empty;
    }
}
