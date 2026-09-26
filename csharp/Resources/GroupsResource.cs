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
using Authdog.Types;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Directory group Wave 1 operations
    /// </summary>
    public class GroupsResource
    {
        private readonly AuthdogClient _client;

        public GroupsResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> CreateAsync(object body) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, "/v1/groups", body);

        public JObject Create(object body) => CreateAsync(body).GetAwaiter().GetResult();

        public Task<EnvGroupsResponse> ListAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<EnvGroupsResponse>(
                HttpMethod.Get,
                $"/v1/tenants/{tenantId}/environments/{environmentId}/groups");

        public EnvGroupsResponse List(string tenantId, string environmentId) =>
            ListAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> DeleteAsync(string tenantId, string environmentId, string groupId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"/v1/tenants/{tenantId}/environments/{environmentId}/groups/{groupId}");

        public JObject Delete(string tenantId, string environmentId, string groupId) =>
            DeleteAsync(tenantId, environmentId, groupId).GetAwaiter().GetResult();

        public Task<JObject> ListMembersAsync(string tenantId, string environmentId, string groupId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"/v1/tenants/{tenantId}/environments/{environmentId}/groups/{groupId}/members");

        public JObject ListMembers(string tenantId, string environmentId, string groupId) =>
            ListMembersAsync(tenantId, environmentId, groupId).GetAwaiter().GetResult();

        public Task<JObject> AddMemberAsync(string tenantId, string environmentId, string groupId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"/v1/tenants/{tenantId}/environments/{environmentId}/groups/{groupId}/members",
                body);

        public JObject AddMember(string tenantId, string environmentId, string groupId, object body) =>
            AddMemberAsync(tenantId, environmentId, groupId, body).GetAwaiter().GetResult();

        public Task<JObject> RemoveMemberAsync(
            string tenantId,
            string environmentId,
            string groupId,
            string userId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"/v1/tenants/{tenantId}/environments/{environmentId}/groups/{groupId}/members/{userId}");

        public JObject RemoveMember(string tenantId, string environmentId, string groupId, string userId) =>
            RemoveMemberAsync(tenantId, environmentId, groupId, userId).GetAwaiter().GetResult();
    }
}
