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
    /// SCIM 2.0 Wave 3 operations
    /// </summary>
    public class ScimResource
    {
        private readonly AuthdogClient _client;

        public ScimResource(AuthdogClient client)
        {
            _client = client;
        }

        private string? Token(string? token) => token ?? _client.ScimToken;

        public Task<JObject> ListUsersAsync(string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, "/v1/scim/v2/Users", accessToken: Token(token));

        public JObject ListUsers(string? token = null) =>
            ListUsersAsync(token).GetAwaiter().GetResult();

        public Task<JObject> CreateUserAsync(object body, string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, "/v1/scim/v2/Users", body, accessToken: Token(token));

        public JObject CreateUser(object body, string? token = null) =>
            CreateUserAsync(body, token).GetAwaiter().GetResult();

        public Task<JObject> GetUserAsync(string userId, string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, $"/v1/scim/v2/Users/{userId}", accessToken: Token(token));

        public JObject GetUser(string userId, string? token = null) =>
            GetUserAsync(userId, token).GetAwaiter().GetResult();

        public Task<JObject> ReplaceUserAsync(string userId, object body, string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Put, $"/v1/scim/v2/Users/{userId}", body, accessToken: Token(token));

        public JObject ReplaceUser(string userId, object body, string? token = null) =>
            ReplaceUserAsync(userId, body, token).GetAwaiter().GetResult();

        public Task<JObject> PatchUserAsync(string userId, object body, string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Patch, $"/v1/scim/v2/Users/{userId}", body, accessToken: Token(token));

        public JObject PatchUser(string userId, object body, string? token = null) =>
            PatchUserAsync(userId, body, token).GetAwaiter().GetResult();

        public Task<JObject> DeleteUserAsync(string userId, string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Delete, $"/v1/scim/v2/Users/{userId}", accessToken: Token(token));

        public JObject DeleteUser(string userId, string? token = null) =>
            DeleteUserAsync(userId, token).GetAwaiter().GetResult();

        public Task<JObject> ListGroupsAsync(string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, "/v1/scim/v2/Groups", accessToken: Token(token));

        public JObject ListGroups(string? token = null) =>
            ListGroupsAsync(token).GetAwaiter().GetResult();

        public Task<JObject> CreateGroupAsync(object body, string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Post, "/v1/scim/v2/Groups", body, accessToken: Token(token));

        public JObject CreateGroup(object body, string? token = null) =>
            CreateGroupAsync(body, token).GetAwaiter().GetResult();

        public Task<JObject> GetGroupAsync(string groupId, string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, $"/v1/scim/v2/Groups/{groupId}", accessToken: Token(token));

        public JObject GetGroup(string groupId, string? token = null) =>
            GetGroupAsync(groupId, token).GetAwaiter().GetResult();

        public Task<JObject> ReplaceGroupAsync(string groupId, object body, string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Put, $"/v1/scim/v2/Groups/{groupId}", body, accessToken: Token(token));

        public JObject ReplaceGroup(string groupId, object body, string? token = null) =>
            ReplaceGroupAsync(groupId, body, token).GetAwaiter().GetResult();

        public Task<JObject> PatchGroupAsync(string groupId, object body, string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Patch, $"/v1/scim/v2/Groups/{groupId}", body, accessToken: Token(token));

        public JObject PatchGroup(string groupId, object body, string? token = null) =>
            PatchGroupAsync(groupId, body, token).GetAwaiter().GetResult();

        public Task<JObject> DeleteGroupAsync(string groupId, string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Delete, $"/v1/scim/v2/Groups/{groupId}", accessToken: Token(token));

        public JObject DeleteGroup(string groupId, string? token = null) =>
            DeleteGroupAsync(groupId, token).GetAwaiter().GetResult();

        public Task<JObject> ResourceTypesAsync(string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, "/v1/scim/v2/ResourceTypes", accessToken: Token(token));

        public JObject ResourceTypes(string? token = null) =>
            ResourceTypesAsync(token).GetAwaiter().GetResult();

        public Task<JObject> ResourceTypeAsync(string typeId, string? token = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"/v1/scim/v2/ResourceTypes/{typeId}",
                accessToken: Token(token));

        public JObject ResourceType(string typeId, string? token = null) =>
            ResourceTypeAsync(typeId, token).GetAwaiter().GetResult();

        public Task<JObject> SchemasAsync(string? token = null) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, "/v1/scim/v2/Schemas", accessToken: Token(token));

        public JObject Schemas(string? token = null) =>
            SchemasAsync(token).GetAwaiter().GetResult();

        public Task<JObject> SchemaAsync(string schemaId, string? token = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"/v1/scim/v2/Schemas/{schemaId}",
                accessToken: Token(token));

        public JObject Schema(string schemaId, string? token = null) =>
            SchemaAsync(schemaId, token).GetAwaiter().GetResult();

        public Task<JObject> ServiceProviderConfigAsync(string? token = null) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                "/v1/scim/v2/ServiceProviderConfig",
                accessToken: Token(token));

        public JObject ServiceProviderConfig(string? token = null) =>
            ServiceProviderConfigAsync(token).GetAwaiter().GetResult();
    }
}
