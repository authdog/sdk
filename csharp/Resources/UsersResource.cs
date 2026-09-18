using System.Net.Http;
using System.Threading.Tasks;
using Authdog.Types;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Directory user Wave 1 operations
    /// </summary>
    public class UsersResource
    {
        private readonly AuthdogClient _client;

        public UsersResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<EnvUsersResponse> ListAsync(
            string tenantId,
            string environmentId,
            int? offset = null,
            int? limit = null,
            string? searchQuery = null) =>
            _client.RequestAsync<EnvUsersResponse>(
                HttpMethod.Get,
                $"/v1/tenants/{tenantId}/environments/{environmentId}/users",
                query: AuthdogClient.Params(
                    ("offset", offset),
                    ("limit", limit),
                    ("searchQuery", searchQuery)));

        public EnvUsersResponse List(
            string tenantId,
            string environmentId,
            int? offset = null,
            int? limit = null,
            string? searchQuery = null) =>
            ListAsync(tenantId, environmentId, offset, limit, searchQuery).GetAwaiter().GetResult();

        public Task<JObject> CreateAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"/v1/tenants/{tenantId}/environments/{environmentId}/users",
                body);

        public JObject Create(string tenantId, string environmentId, object body) =>
            CreateAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<EnvUsersResponse> SearchAsync(
            string tenantId,
            string environmentId,
            string? q = null,
            int? offset = null,
            int? limit = null) =>
            _client.RequestAsync<EnvUsersResponse>(
                HttpMethod.Get,
                $"/v1/tenants/{tenantId}/environments/{environmentId}/users/search",
                query: AuthdogClient.Params(("q", q), ("offset", offset), ("limit", limit)));

        public EnvUsersResponse Search(
            string tenantId,
            string environmentId,
            string? q = null,
            int? offset = null,
            int? limit = null) =>
            SearchAsync(tenantId, environmentId, q, offset, limit).GetAwaiter().GetResult();

        public Task<JObject> CountAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"/v1/tenants/{tenantId}/environments/{environmentId}/users/count");

        public JObject Count(string tenantId, string environmentId) =>
            CountAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> GetAsync(string tenantId, string environmentId, string userId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"/v1/tenants/{tenantId}/environments/{environmentId}/users/{userId}");

        public JObject Get(string tenantId, string environmentId, string userId) =>
            GetAsync(tenantId, environmentId, userId).GetAwaiter().GetResult();

        public Task<JObject> UpdateAsync(string tenantId, string environmentId, string userId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Put,
                $"/v1/tenants/{tenantId}/environments/{environmentId}/users/{userId}",
                body);

        public JObject Update(string tenantId, string environmentId, string userId, object body) =>
            UpdateAsync(tenantId, environmentId, userId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteAsync(string tenantId, string environmentId, string userId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"/v1/tenants/{tenantId}/environments/{environmentId}/users/{userId}");

        public JObject Delete(string tenantId, string environmentId, string userId) =>
            DeleteAsync(tenantId, environmentId, userId).GetAwaiter().GetResult();

        public Task<JObject> SetActiveAsync(string tenantId, string environmentId, string userId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Patch,
                $"/v1/tenants/{tenantId}/environments/{environmentId}/users/{userId}/active",
                body);

        public JObject SetActive(string tenantId, string environmentId, string userId, object body) =>
            SetActiveAsync(tenantId, environmentId, userId, body).GetAwaiter().GetResult();

        public Task<JObject> ListGroupsAsync(string tenantId, string environmentId, string userId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"/v1/tenants/{tenantId}/environments/{environmentId}/users/{userId}/groups");

        public JObject ListGroups(string tenantId, string environmentId, string userId) =>
            ListGroupsAsync(tenantId, environmentId, userId).GetAwaiter().GetResult();

        public Task<JObject> RevokeSessionAsync(string environmentId, string sessionId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"/v1/environments/{environmentId}/sessions/{sessionId}");

        public JObject RevokeSession(string environmentId, string sessionId) =>
            RevokeSessionAsync(environmentId, sessionId).GetAwaiter().GetResult();

        public Task<JObject> TotpStatusAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/me/mfa/totp");

        public JObject TotpStatus(string tenantId, string environmentId) =>
            TotpStatusAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> BulkDeleteAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/users/bulk/delete",
                body);

        public JObject BulkDelete(string tenantId, string environmentId, object body) =>
            BulkDeleteAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> BulkSetActiveAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/users/bulk/set-active",
                body);

        public JObject BulkSetActive(string tenantId, string environmentId, object body) =>
            BulkSetActiveAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> ImportUsersAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/users/import",
                body);

        public JObject ImportUsers(string tenantId, string environmentId, object body) =>
            ImportUsersAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> DisableMfaAsync(string tenantId, string environmentId, string userId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/users/{userId}/mfa");

        public JObject DisableMfa(string tenantId, string environmentId, string userId) =>
            DisableMfaAsync(tenantId, environmentId, userId).GetAwaiter().GetResult();

        public Task<JObject> ListSessionsAsync(string tenantId, string environmentId, string userId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/users/{userId}/sessions");

        public JObject ListSessions(string tenantId, string environmentId, string userId) =>
            ListSessionsAsync(tenantId, environmentId, userId).GetAwaiter().GetResult();
    }
}
