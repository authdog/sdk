using System.Net.Http;
using System.Threading.Tasks;
using Authdog.Types;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Organization Wave 1 operations
    /// </summary>
    public class OrganizationsResource
    {
        private readonly AuthdogClient _client;

        public OrganizationsResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<OrganizationsList> ListAsync() =>
            _client.RequestAsync<OrganizationsList>(HttpMethod.Get, "/v1/organizations");

        public OrganizationsList List() => ListAsync().GetAwaiter().GetResult();

        public Task<JObject> CreateAsync(object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, "/v1/organizations", body);

        public JObject Create(object body) => CreateAsync(body).GetAwaiter().GetResult();

        public Task<JObject> GetAsync(string organizationId) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, $"/v1/organizations/{organizationId}");

        public JObject Get(string organizationId) => GetAsync(organizationId).GetAwaiter().GetResult();

        public Task<JObject> UpdateAsync(string organizationId, object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Patch, $"/v1/organizations/{organizationId}", body);

        public JObject Update(string organizationId, object body) =>
            UpdateAsync(organizationId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteAsync(string organizationId) =>
            _client.RequestAsync<JObject>(HttpMethod.Delete, $"/v1/organizations/{organizationId}");

        public JObject Delete(string organizationId) => DeleteAsync(organizationId).GetAwaiter().GetResult();

        public Task<JObject> AcceptInvitationAsync(object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, "/v1/organizations/invitations/accept", body);

        public JObject AcceptInvitation(object body) => AcceptInvitationAsync(body).GetAwaiter().GetResult();

        public Task<JObject> JoinAsync(object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, "/v1/organizations/join", body);

        public JObject Join(object body) => JoinAsync(body).GetAwaiter().GetResult();

        public Task<JObject> ListInvitationsAsync(string organizationId) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, $"/v1/organizations/{organizationId}/invitations");

        public JObject ListInvitations(string organizationId) =>
            ListInvitationsAsync(organizationId).GetAwaiter().GetResult();

        public Task<JObject> CreateInvitationAsync(string organizationId, object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, $"/v1/organizations/{organizationId}/invitations", body);

        public JObject CreateInvitation(string organizationId, object body) =>
            CreateInvitationAsync(organizationId, body).GetAwaiter().GetResult();

        public Task<JObject> CancelInvitationAsync(string organizationId, string invitationId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"/v1/organizations/{organizationId}/invitations/{invitationId}/cancel");

        public JObject CancelInvitation(string organizationId, string invitationId) =>
            CancelInvitationAsync(organizationId, invitationId).GetAwaiter().GetResult();

        public Task<JObject> SendInviteAsync(string organizationId, object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, $"/v1/organizations/{organizationId}/invites", body);

        public JObject SendInvite(string organizationId, object body) =>
            SendInviteAsync(organizationId, body).GetAwaiter().GetResult();

        public Task<JObject> ListMembersAsync(string organizationId) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, $"/v1/organizations/{organizationId}/members");

        public JObject ListMembers(string organizationId) =>
            ListMembersAsync(organizationId).GetAwaiter().GetResult();

        public Task<JObject> RemoveMemberAsync(string organizationId, string memberId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"/v1/organizations/{organizationId}/members/{memberId}");

        public JObject RemoveMember(string organizationId, string memberId) =>
            RemoveMemberAsync(organizationId, memberId).GetAwaiter().GetResult();

        public Task<JObject> SetMemberActiveAsync(string organizationId, string memberId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Patch,
                $"/v1/organizations/{organizationId}/members/{memberId}/active",
                body);

        public JObject SetMemberActive(string organizationId, string memberId, object body) =>
            SetMemberActiveAsync(organizationId, memberId, body).GetAwaiter().GetResult();

        public Task<JObject> LinkTenantAsync(string organizationId, object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, $"/v1/organizations/{organizationId}/tenants", body);

        public JObject LinkTenant(string organizationId, object body) =>
            LinkTenantAsync(organizationId, body).GetAwaiter().GetResult();

        public Task<JObject> UnlinkTenantAsync(string organizationId, string tenantId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"/v1/organizations/{organizationId}/tenants/{tenantId}");

        public JObject UnlinkTenant(string organizationId, string tenantId) =>
            UnlinkTenantAsync(organizationId, tenantId).GetAwaiter().GetResult();
    }
}
