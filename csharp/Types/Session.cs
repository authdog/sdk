using Newtonsoft.Json;

namespace Authdog.Types
{
    /// <summary>
    /// Session information
    /// </summary>
    public class Session
    {
        [JsonProperty("remainingSeconds")]
        public int RemainingSeconds { get; set; }
    }
}
