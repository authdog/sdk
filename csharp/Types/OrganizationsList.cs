using Newtonsoft.Json;

namespace Authdog.Types
{
    /// <summary>
    /// List envelope for organizations
    /// </summary>
    public class OrganizationsList
    {
        [JsonProperty("organizations")]
        public List<Organization> Organizations { get; set; } = new();

        [JsonProperty("total")]
        public int Total { get; set; }
    }
}
