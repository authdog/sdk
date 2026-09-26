// MIT License
//
// Copyright (c) 2025 Authdog
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
