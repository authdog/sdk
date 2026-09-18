using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Environment policy and settings Wave 3 operations
    /// </summary>
    public class SettingsResource
    {
        private readonly AuthdogClient _client;

        public SettingsResource(AuthdogClient client)
        {
            _client = client;
        }

        private Task<JObject> GetAsync(string tenantId, string environmentId, string suffix) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/{suffix}");

        private Task<JObject> PutAsync(string tenantId, string environmentId, string suffix, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Put,
                $"{AuthdogClient.Env(tenantId, environmentId)}/{suffix}",
                body);

        public Task<JObject> GetBotDetectionPolicyAsync(string tenantId, string environmentId) =>
            GetAsync(tenantId, environmentId, "bot-detection-policy");

        public JObject GetBotDetectionPolicy(string tenantId, string environmentId) =>
            GetBotDetectionPolicyAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> UpdateBotDetectionPolicyAsync(string tenantId, string environmentId, object body) =>
            PutAsync(tenantId, environmentId, "bot-detection-policy", body);

        public JObject UpdateBotDetectionPolicy(string tenantId, string environmentId, object body) =>
            UpdateBotDetectionPolicyAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> GetBreachedPasswordPolicyAsync(string tenantId, string environmentId) =>
            GetAsync(tenantId, environmentId, "breached-password-policy");

        public JObject GetBreachedPasswordPolicy(string tenantId, string environmentId) =>
            GetBreachedPasswordPolicyAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> UpdateBreachedPasswordPolicyAsync(string tenantId, string environmentId, object body) =>
            PutAsync(tenantId, environmentId, "breached-password-policy", body);

        public JObject UpdateBreachedPasswordPolicy(string tenantId, string environmentId, object body) =>
            UpdateBreachedPasswordPolicyAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> GetBruteForcePolicyAsync(string tenantId, string environmentId) =>
            GetAsync(tenantId, environmentId, "brute-force-policy");

        public JObject GetBruteForcePolicy(string tenantId, string environmentId) =>
            GetBruteForcePolicyAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> UpdateBruteForcePolicyAsync(string tenantId, string environmentId, object body) =>
            PutAsync(tenantId, environmentId, "brute-force-policy", body);

        public JObject UpdateBruteForcePolicy(string tenantId, string environmentId, object body) =>
            UpdateBruteForcePolicyAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> GetDeviceRiskPolicyAsync(string tenantId, string environmentId) =>
            GetAsync(tenantId, environmentId, "device-risk-policy");

        public JObject GetDeviceRiskPolicy(string tenantId, string environmentId) =>
            GetDeviceRiskPolicyAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> UpdateDeviceRiskPolicyAsync(string tenantId, string environmentId, object body) =>
            PutAsync(tenantId, environmentId, "device-risk-policy", body);

        public JObject UpdateDeviceRiskPolicy(string tenantId, string environmentId, object body) =>
            UpdateDeviceRiskPolicyAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> ListJwtClaimMappingsAsync(string tenantId, string environmentId) =>
            GetAsync(tenantId, environmentId, "jwt-claim-mappings");

        public JObject ListJwtClaimMappings(string tenantId, string environmentId) =>
            ListJwtClaimMappingsAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> SaveJwtClaimMappingAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/jwt-claim-mappings",
                body);

        public JObject SaveJwtClaimMapping(string tenantId, string environmentId, object body) =>
            SaveJwtClaimMappingAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteJwtClaimMappingAsync(string tenantId, string environmentId, string mappingId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/jwt-claim-mappings/{mappingId}");

        public JObject DeleteJwtClaimMapping(string tenantId, string environmentId, string mappingId) =>
            DeleteJwtClaimMappingAsync(tenantId, environmentId, mappingId).GetAwaiter().GetResult();

        public Task<JObject> GetPasswordPolicyAsync(string tenantId, string environmentId) =>
            GetAsync(tenantId, environmentId, "password-policy");

        public JObject GetPasswordPolicy(string tenantId, string environmentId) =>
            GetPasswordPolicyAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> UpdatePasswordPolicyAsync(string tenantId, string environmentId, object body) =>
            PutAsync(tenantId, environmentId, "password-policy", body);

        public JObject UpdatePasswordPolicy(string tenantId, string environmentId, object body) =>
            UpdatePasswordPolicyAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> GetRateLimitPolicyAsync(string tenantId, string environmentId) =>
            GetAsync(tenantId, environmentId, "rate-limit-policy");

        public JObject GetRateLimitPolicy(string tenantId, string environmentId) =>
            GetRateLimitPolicyAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> UpdateRateLimitPolicyAsync(string tenantId, string environmentId, object body) =>
            PutAsync(tenantId, environmentId, "rate-limit-policy", body);

        public JObject UpdateRateLimitPolicy(string tenantId, string environmentId, object body) =>
            UpdateRateLimitPolicyAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> GetRestrictionsAsync(string tenantId, string environmentId) =>
            GetAsync(tenantId, environmentId, "restrictions");

        public JObject GetRestrictions(string tenantId, string environmentId) =>
            GetRestrictionsAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> UpdateRestrictionsAsync(string tenantId, string environmentId, object body) =>
            PutAsync(tenantId, environmentId, "restrictions", body);

        public JObject UpdateRestrictions(string tenantId, string environmentId, object body) =>
            UpdateRestrictionsAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> GetSessionConfigAsync(string tenantId, string environmentId) =>
            GetAsync(tenantId, environmentId, "session-config");

        public JObject GetSessionConfig(string tenantId, string environmentId) =>
            GetSessionConfigAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> UpdateSessionConfigAsync(string tenantId, string environmentId, object body) =>
            PutAsync(tenantId, environmentId, "session-config", body);

        public JObject UpdateSessionConfig(string tenantId, string environmentId, object body) =>
            UpdateSessionConfigAsync(tenantId, environmentId, body).GetAwaiter().GetResult();
    }
}
