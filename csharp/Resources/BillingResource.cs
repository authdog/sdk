using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Environment billing Wave 3 operations
    /// </summary>
    public class BillingResource
    {
        private readonly AuthdogClient _client;

        public BillingResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListFeaturesAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/billing/features");

        public JObject ListFeatures(string tenantId, string environmentId) =>
            ListFeaturesAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> SaveFeatureAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/billing/features",
                body);

        public JObject SaveFeature(string tenantId, string environmentId, object body) =>
            SaveFeatureAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteFeatureAsync(string tenantId, string environmentId, string featureId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/billing/features/{featureId}");

        public JObject DeleteFeature(string tenantId, string environmentId, string featureId) =>
            DeleteFeatureAsync(tenantId, environmentId, featureId).GetAwaiter().GetResult();

        public Task<JObject> ListPlansAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/billing/plans");

        public JObject ListPlans(string tenantId, string environmentId) =>
            ListPlansAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> SavePlanAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/billing/plans",
                body);

        public JObject SavePlan(string tenantId, string environmentId, object body) =>
            SavePlanAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> DeletePlanAsync(string tenantId, string environmentId, string planId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/billing/plans/{planId}");

        public JObject DeletePlan(string tenantId, string environmentId, string planId) =>
            DeletePlanAsync(tenantId, environmentId, planId).GetAwaiter().GetResult();

        public Task<JObject> SyncStripeAsync(string tenantId, string environmentId, string planId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/billing/plans/{planId}/sync-stripe");

        public JObject SyncStripe(string tenantId, string environmentId, string planId) =>
            SyncStripeAsync(tenantId, environmentId, planId).GetAwaiter().GetResult();
    }
}
