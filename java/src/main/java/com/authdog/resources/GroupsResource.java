package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.authdog.types.EnvGroupsResponse;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Directory group operations.
 */
public final class GroupsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a groups helper.
     * @param clientParam Authdog client
     */
    public GroupsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * Create a group.
     * @param body request body
     * @return created group envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode create(final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST", "/v1/groups", body, null,
                JsonNode.class);
    }

    /**
     * List groups in an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return groups envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public EnvGroupsResponse list(final String tenantId,
                                  final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/tenants/" + tenantId + "/environments/"
                        + environmentId + "/groups",
                null, null, EnvGroupsResponse.class);
    }

    /**
     * Delete a group.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param groupId group ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode delete(final String tenantId,
                           final String environmentId,
                           final String groupId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                "/v1/tenants/" + tenantId + "/environments/"
                        + environmentId + "/groups/" + groupId,
                null, null, JsonNode.class);
    }

    /**
     * List members of a group.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param groupId group ID
     * @return members envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listMembers(final String tenantId,
                                final String environmentId,
                                final String groupId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/tenants/" + tenantId + "/environments/"
                        + environmentId + "/groups/" + groupId
                        + "/members",
                null, null, JsonNode.class);
    }

    /**
     * Add a user to a group.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param groupId group ID
     * @param body request body
     * @return add-member envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode addMember(final String tenantId,
                              final String environmentId,
                              final String groupId, final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                "/v1/tenants/" + tenantId + "/environments/"
                        + environmentId + "/groups/" + groupId
                        + "/members",
                body, null, JsonNode.class);
    }

    /**
     * Remove a user from a group.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param groupId group ID
     * @param userId user ID
     * @return remove envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode removeMember(final String tenantId,
                                 final String environmentId,
                                 final String groupId,
                                 final String userId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                "/v1/tenants/" + tenantId + "/environments/"
                        + environmentId + "/groups/" + groupId
                        + "/members/" + userId,
                null, null, JsonNode.class);
    }
}
