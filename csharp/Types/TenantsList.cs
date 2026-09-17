using Newtonsoft.Json;

namespace Authdog.Types
{
    /// <summary>
    /// List envelope for tenants
    /// </summary>
    public class TenantsList
    {
        [JsonProperty("tenants")]
        public List<Tenant> Tenants { get; set; } = new();

        [JsonProperty("total")]
        public int Total { get; set; }
    }
}
