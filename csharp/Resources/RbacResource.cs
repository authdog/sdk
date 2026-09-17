using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Authdog
{
    /// <summary>
    /// Environment RBAC and ABAC Wave 2 operations
    /// </summary>
    public class RbacResource
    {
        private readonly AuthdogClient _client;

        public RbacResource(AuthdogClient client)
        {
            _client = client;
        }

        public Task<JObject> ListRolesAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(HttpMethod.Get, $"{AuthdogClient.Env(tenantId, environmentId)}/roles");

        public JObject ListRoles(string tenantId, string environmentId) =>
            ListRolesAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> CreateRoleAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/roles",
                body);

        public JObject CreateRole(string tenantId, string environmentId, object body) =>
            CreateRoleAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteRoleAsync(string tenantId, string environmentId, string roleId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/roles/{roleId}");

        public JObject DeleteRole(string tenantId, string environmentId, string roleId) =>
            DeleteRoleAsync(tenantId, environmentId, roleId).GetAwaiter().GetResult();

        public Task<JObject> ListRolePermissionsAsync(string tenantId, string environmentId, string roleId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/roles/{roleId}/permissions");

        public JObject ListRolePermissions(string tenantId, string environmentId, string roleId) =>
            ListRolePermissionsAsync(tenantId, environmentId, roleId).GetAwaiter().GetResult();

        public Task<JObject> SetRolePermissionsAsync(
            string tenantId,
            string environmentId,
            string roleId,
            object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Put,
                $"{AuthdogClient.Env(tenantId, environmentId)}/roles/{roleId}/permissions",
                body);

        public JObject SetRolePermissions(string tenantId, string environmentId, string roleId, object body) =>
            SetRolePermissionsAsync(tenantId, environmentId, roleId, body).GetAwaiter().GetResult();

        public Task<JObject> ListPermissionsAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/permissions");

        public JObject ListPermissions(string tenantId, string environmentId) =>
            ListPermissionsAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> CreatePermissionAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/permissions",
                body);

        public JObject CreatePermission(string tenantId, string environmentId, object body) =>
            CreatePermissionAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> DeletePermissionAsync(string tenantId, string environmentId, string permissionId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/permissions/{permissionId}");

        public JObject DeletePermission(string tenantId, string environmentId, string permissionId) =>
            DeletePermissionAsync(tenantId, environmentId, permissionId).GetAwaiter().GetResult();

        public Task<JObject> ListResourcesAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/resources");

        public JObject ListResources(string tenantId, string environmentId) =>
            ListResourcesAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> CreateResourceAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/resources",
                body);

        public JObject CreateResource(string tenantId, string environmentId, object body) =>
            CreateResourceAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteResourceAsync(string tenantId, string environmentId, string resourceId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/resources/{resourceId}");

        public JObject DeleteResource(string tenantId, string environmentId, string resourceId) =>
            DeleteResourceAsync(tenantId, environmentId, resourceId).GetAwaiter().GetResult();

        public Task<JObject> ListGroupRolesAsync(string tenantId, string environmentId, string groupId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/groups/{groupId}/roles");

        public JObject ListGroupRoles(string tenantId, string environmentId, string groupId) =>
            ListGroupRolesAsync(tenantId, environmentId, groupId).GetAwaiter().GetResult();

        public Task<JObject> AddGroupRoleAsync(
            string tenantId,
            string environmentId,
            string groupId,
            object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/groups/{groupId}/roles",
                body);

        public JObject AddGroupRole(string tenantId, string environmentId, string groupId, object body) =>
            AddGroupRoleAsync(tenantId, environmentId, groupId, body).GetAwaiter().GetResult();

        public Task<JObject> RemoveGroupRoleAsync(
            string tenantId,
            string environmentId,
            string groupId,
            string roleId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/groups/{groupId}/roles/{roleId}");

        public JObject RemoveGroupRole(string tenantId, string environmentId, string groupId, string roleId) =>
            RemoveGroupRoleAsync(tenantId, environmentId, groupId, roleId).GetAwaiter().GetResult();

        public Task<JObject> ListGroupRoleMappingsAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/group-role-mappings");

        public JObject ListGroupRoleMappings(string tenantId, string environmentId) =>
            ListGroupRoleMappingsAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> CreateGroupRoleMappingAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/group-role-mappings",
                body);

        public JObject CreateGroupRoleMapping(string tenantId, string environmentId, object body) =>
            CreateGroupRoleMappingAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> ApplyGroupRoleMappingsAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/group-role-mappings/apply");

        public JObject ApplyGroupRoleMappings(string tenantId, string environmentId) =>
            ApplyGroupRoleMappingsAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> DeleteGroupRoleMappingAsync(
            string tenantId,
            string environmentId,
            string mappingId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/group-role-mappings/{mappingId}");

        public JObject DeleteGroupRoleMapping(string tenantId, string environmentId, string mappingId) =>
            DeleteGroupRoleMappingAsync(tenantId, environmentId, mappingId).GetAwaiter().GetResult();

        public Task<JObject> ListAbacPoliciesAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/abac-policies");

        public JObject ListAbacPolicies(string tenantId, string environmentId) =>
            ListAbacPoliciesAsync(tenantId, environmentId).GetAwaiter().GetResult();

        public Task<JObject> SaveAbacPolicyAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/abac-policies",
                body);

        public JObject SaveAbacPolicy(string tenantId, string environmentId, object body) =>
            SaveAbacPolicyAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> ValidateAbacPolicyAsync(string tenantId, string environmentId, object body) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Post,
                $"{AuthdogClient.Env(tenantId, environmentId)}/abac-policies/validate",
                body);

        public JObject ValidateAbacPolicy(string tenantId, string environmentId, object body) =>
            ValidateAbacPolicyAsync(tenantId, environmentId, body).GetAwaiter().GetResult();

        public Task<JObject> DeleteAbacPolicyAsync(string tenantId, string environmentId, string policyId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Delete,
                $"{AuthdogClient.Env(tenantId, environmentId)}/abac-policies/{policyId}");

        public JObject DeleteAbacPolicy(string tenantId, string environmentId, string policyId) =>
            DeleteAbacPolicyAsync(tenantId, environmentId, policyId).GetAwaiter().GetResult();

        public Task<JObject> MyPermissionsAsync(string tenantId, string environmentId) =>
            _client.RequestAsync<JObject>(
                HttpMethod.Get,
                $"{AuthdogClient.Env(tenantId, environmentId)}/me/permissions");

        public JObject MyPermissions(string tenantId, string environmentId) =>
            MyPermissionsAsync(tenantId, environmentId).GetAwaiter().GetResult();
    }
}
