using Newtonsoft.Json;

namespace Authdog.Types
{
    /// <summary>
    /// Liveness probe from GET /v1/health
    /// </summary>
    public class Probe
    {
        [JsonProperty("ok")]
        public bool Ok { get; set; }
    }
}
