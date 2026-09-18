using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Privileged-access elevate Wave 3 operations
    /// </summary>
    public class ElevateResource
    {
        private readonly AuthdogClient _client;

        public ElevateResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ActivateGrantAsync(string tenantId, string environmentId, string grantId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/elevate/access-grants/{grantId}/activate",
                body);

        public JObject ActivateGrant(string tenantId, string environmentId, string grantId, object body) =>
            ActivateGrantAsync(tenantId, environmentId, grantId, body).GetAwaiter().GetResult();

        public Task<JObject> RevokeGrantAsync(string tenantId, string environmentId, string grantId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/elevate/access-grants/{grantId}/revoke",
                body);

        public JObject RevokeGrant(string tenantId, string environmentId, string grantId, object body) =>
            RevokeGrantAsync(tenantId, environmentId, grantId, body).GetAwaiter().GetResult();

        public Task<JObject> ListRequestsAsync(string tenantId, string environmentId, string? status = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/elevate/access-requests",
                query: AuthdogClient.Params(("status", status)));

        public JObject ListRequests(string tenantId, string environmentId, string? status = null) =>
            ListRequestsAsync(tenantId, environmentId, status).GetAwaiter().GetResult();

        public Task<JObject> CreateRequestAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/elevate/access-requests",
                body);

        public JObject CreateRequest(string tenantId, string environmentId, object body) =>
            CreateRequestAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> GetRequestAsync(string tenantId, string environmentId, string requestId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/elevate/access-requests/{requestId}");

        public JObject GetRequest(string tenantId, string environmentId, string requestId) =>
            GetRequestAsync(tenantId, environmentId, requestId).GetAwaiter().GetResult();

        public Task<JObject> ApproveRequestAsync(string tenantId, string environmentId, string requestId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/elevate/access-requests/{requestId}/approve",
                body);

        public JObject ApproveRequest(string tenantId, string environmentId, string requestId, object body) =>
            ApproveRequestAsync(tenantId, environmentId, requestId, body).GetAwaiter().GetResult();

        public Task<JObject> CancelRequestAsync(string tenantId, string environmentId, string requestId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/elevate/access-requests/{requestId}/cancel");

        public JObject CancelRequest(string tenantId, string environmentId, string requestId) =>
            CancelRequestAsync(tenantId, environmentId, requestId).GetAwaiter().GetResult();

        public Task<JObject> DenyRequestAsync(string tenantId, string environmentId, string requestId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/elevate/access-requests/{requestId}/deny",
                body);

        public JObject DenyRequest(string tenantId, string environmentId, string requestId, object body) =>
            DenyRequestAsync(tenantId, environmentId, requestId, body).GetAwaiter().GetResult();

        public Task<JObject> GetPolicyAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/elevate/policy");

        public JObject GetPolicy(string tenantId, string environmentId) =>
            GetPolicyAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> UpdatePolicyAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Put,
                $"{AuthdogClient.Env(tenantId, environmentId)}/elevate/policy",
                body);

        public JObject UpdatePolicy(string tenantId, string environmentId, object body) =>
            UpdatePolicyAsync(tenantId, environmentId, body).GetAwaiter().GetResult();
    }
}
