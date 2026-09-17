package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Environment RBAC operations.
 */
public final class RbacResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create an RBAC helper.
     * @param clientParam Authdog client
     */
    public RbacResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List roles in an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return roles envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listRoles(final String tenantId,
                              final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId) + "/roles",
                null, null, JsonNode.class);
    }

    /**
     * Create or update a role.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return role envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createRole(final String tenantId,
                               final String environmentId,
                               final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId) + "/roles",
                body, null, JsonNode.class);
    }

    /**
     * Delete a role.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param roleId role ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteRole(final String tenantId,
                               final String environmentId,
                               final String roleId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/roles/" + roleId,
                null, null, JsonNode.class);
    }

    /**
     * List permissions assigned to a role.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param roleId role ID
     * @return permissions envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listRolePermissions(final String tenantId,
                                        final String environmentId,
                                        final String roleId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/roles/" + roleId + "/permissions",
                null, null, JsonNode.class);
    }

    /**
     * Set permissions for a role.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param roleId role ID
     * @param body request body
     * @return update envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode setRolePermissions(final String tenantId,
                                       final String environmentId,
                                       final String roleId,
                                       final Object body)
            throws AuthenticationException, ApiException {
        return client.request("PUT",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/roles/" + roleId + "/permissions",
                body, null, JsonNode.class);
    }

    /**
     * List permissions in an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return permissions envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listPermissions(final String tenantId,
                                    final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/permissions",
                null, null, JsonNode.class);
    }

    /**
     * Create or update a permission.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return permission envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createPermission(final String tenantId,
                                     final String environmentId,
                                     final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/permissions",
                body, null, JsonNode.class);
    }

    /**
     * Delete a permission.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param permissionId permission ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deletePermission(final String tenantId,
                                     final String environmentId,
                                     final String permissionId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/permissions/" + permissionId,
                null, null, JsonNode.class);
    }

    /**
     * List resources in an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return resources envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listResources(final String tenantId,
                                  final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/resources",
                null, null, JsonNode.class);
    }

    /**
     * Create or update a resource.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return resource envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createResource(final String tenantId,
                                   final String environmentId,
                                   final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/resources",
                body, null, JsonNode.class);
    }

    /**
     * Delete a resource.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param resourceId resource ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteResource(final String tenantId,
                                   final String environmentId,
                                   final String resourceId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/resources/" + resourceId,
                null, null, JsonNode.class);
    }

    /**
     * List roles assigned to a group.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param groupId group ID
     * @return group roles envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listGroupRoles(final String tenantId,
                                   final String environmentId,
                                   final String groupId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/groups/" + groupId + "/roles",
                null, null, JsonNode.class);
    }

    /**
     * Assign a role to a group.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param groupId group ID
     * @param body request body
     * @return add-role envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode addGroupRole(final String tenantId,
                                 final String environmentId,
                                 final String groupId,
                                 final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/groups/" + groupId + "/roles",
                body, null, JsonNode.class);
    }

    /**
     * Remove a role from a group.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param groupId group ID
     * @param roleId role ID
     * @return remove envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode removeGroupRole(final String tenantId,
                                    final String environmentId,
                                    final String groupId,
                                    final String roleId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/groups/" + groupId + "/roles/" + roleId,
                null, null, JsonNode.class);
    }

    /**
     * List group-to-role mappings.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return mappings envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listGroupRoleMappings(final String tenantId,
                                          final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/group-role-mappings",
                null, null, JsonNode.class);
    }

    /**
     * Create a group-to-role mapping.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return mapping envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createGroupRoleMapping(
            final String tenantId,
            final String environmentId,
            final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/group-role-mappings",
                body, null, JsonNode.class);
    }

    /**
     * Apply group-to-role mappings to existing groups.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return apply envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode applyGroupRoleMappings(
            final String tenantId,
            final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/group-role-mappings/apply",
                null, null, JsonNode.class);
    }

    /**
     * Delete a group-to-role mapping.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param mappingId mapping ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteGroupRoleMapping(
            final String tenantId,
            final String environmentId,
            final String mappingId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/group-role-mappings/" + mappingId,
                null, null, JsonNode.class);
    }

    /**
     * List ABAC policies.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return policies envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listAbacPolicies(final String tenantId,
                                     final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/abac-policies",
                null, null, JsonNode.class);
    }

    /**
     * Create or update an ABAC policy.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return policy envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode saveAbacPolicy(final String tenantId,
                                   final String environmentId,
                                   final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/abac-policies",
                body, null, JsonNode.class);
    }

    /**
     * Validate an ABAC policy's Rego source.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return validation envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode validateAbacPolicy(final String tenantId,
                                       final String environmentId,
                                       final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/abac-policies/validate",
                body, null, JsonNode.class);
    }

    /**
     * Delete an ABAC policy.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param policyId policy ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteAbacPolicy(final String tenantId,
                                     final String environmentId,
                                     final String policyId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/abac-policies/" + policyId,
                null, null, JsonNode.class);
    }

    /**
     * List the caller's effective permissions.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return permissions envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode myPermissions(final String tenantId,
                                  final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/me/permissions",
                null, null, JsonNode.class);
    }
}
