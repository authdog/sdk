package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * SCIM 2.0 directory operations.
 */
public final class ScimResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a SCIM helper.
     * @param clientParam Authdog client
     */
    public ScimResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List SCIM users.
     * @return users envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listUsers()
            throws AuthenticationException, ApiException {
        return listUsers(null);
    }

    /**
     * List SCIM users with a token override.
     * @param token optional SCIM token override
     * @return users envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listUsers(final String token)
            throws AuthenticationException, ApiException {
        return call("GET", "/v1/scim/v2/Users", null, token);
    }

    /**
     * Create a SCIM user.
     * @param body request body
     * @return created user envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createUser(final Object body)
            throws AuthenticationException, ApiException {
        return createUser(body, null);
    }

    /**
     * Create a SCIM user with a token override.
     * @param body request body
     * @param token optional SCIM token override
     * @return created user envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createUser(final Object body, final String token)
            throws AuthenticationException, ApiException {
        return call("POST", "/v1/scim/v2/Users", body, token);
    }

    /**
     * Get a SCIM user.
     * @param userId user ID
     * @return user envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getUser(final String userId)
            throws AuthenticationException, ApiException {
        return getUser(userId, null);
    }

    /**
     * Get a SCIM user with a token override.
     * @param userId user ID
     * @param token optional SCIM token override
     * @return user envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getUser(final String userId, final String token)
            throws AuthenticationException, ApiException {
        return call("GET", "/v1/scim/v2/Users/" + userId, null, token);
    }

    /**
     * Replace a SCIM user.
     * @param userId user ID
     * @param body request body
     * @return user envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode replaceUser(final String userId, final Object body)
            throws AuthenticationException, ApiException {
        return replaceUser(userId, body, null);
    }

    /**
     * Replace a SCIM user with a token override.
     * @param userId user ID
     * @param body request body
     * @param token optional SCIM token override
     * @return user envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode replaceUser(final String userId, final Object body,
                                final String token)
            throws AuthenticationException, ApiException {
        return call("PUT", "/v1/scim/v2/Users/" + userId, body, token);
    }

    /**
     * Patch a SCIM user.
     * @param userId user ID
     * @param body request body
     * @return user envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode patchUser(final String userId, final Object body)
            throws AuthenticationException, ApiException {
        return patchUser(userId, body, null);
    }

    /**
     * Patch a SCIM user with a token override.
     * @param userId user ID
     * @param body request body
     * @param token optional SCIM token override
     * @return user envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode patchUser(final String userId, final Object body,
                              final String token)
            throws AuthenticationException, ApiException {
        return call("PATCH", "/v1/scim/v2/Users/" + userId, body,
                token);
    }

    /**
     * Delete a SCIM user.
     * @param userId user ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteUser(final String userId)
            throws AuthenticationException, ApiException {
        return deleteUser(userId, null);
    }

    /**
     * Delete a SCIM user with a token override.
     * @param userId user ID
     * @param token optional SCIM token override
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteUser(final String userId, final String token)
            throws AuthenticationException, ApiException {
        return call("DELETE", "/v1/scim/v2/Users/" + userId, null,
                token);
    }

    /**
     * List SCIM groups.
     * @return groups envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listGroups()
            throws AuthenticationException, ApiException {
        return listGroups(null);
    }

    /**
     * List SCIM groups with a token override.
     * @param token optional SCIM token override
     * @return groups envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listGroups(final String token)
            throws AuthenticationException, ApiException {
        return call("GET", "/v1/scim/v2/Groups", null, token);
    }

    /**
     * Create a SCIM group.
     * @param body request body
     * @return created group envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createGroup(final Object body)
            throws AuthenticationException, ApiException {
        return createGroup(body, null);
    }

    /**
     * Create a SCIM group with a token override.
     * @param body request body
     * @param token optional SCIM token override
     * @return created group envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createGroup(final Object body, final String token)
            throws AuthenticationException, ApiException {
        return call("POST", "/v1/scim/v2/Groups", body, token);
    }

    /**
     * Get a SCIM group.
     * @param groupId group ID
     * @return group envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getGroup(final String groupId)
            throws AuthenticationException, ApiException {
        return getGroup(groupId, null);
    }

    /**
     * Get a SCIM group with a token override.
     * @param groupId group ID
     * @param token optional SCIM token override
     * @return group envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getGroup(final String groupId, final String token)
            throws AuthenticationException, ApiException {
        return call("GET", "/v1/scim/v2/Groups/" + groupId, null,
                token);
    }

    /**
     * Replace a SCIM group.
     * @param groupId group ID
     * @param body request body
     * @return group envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode replaceGroup(final String groupId, final Object body)
            throws AuthenticationException, ApiException {
        return replaceGroup(groupId, body, null);
    }

    /**
     * Replace a SCIM group with a token override.
     * @param groupId group ID
     * @param body request body
     * @param token optional SCIM token override
     * @return group envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode replaceGroup(final String groupId, final Object body,
                                 final String token)
            throws AuthenticationException, ApiException {
        return call("PUT", "/v1/scim/v2/Groups/" + groupId, body,
                token);
    }

    /**
     * Patch a SCIM group.
     * @param groupId group ID
     * @param body request body
     * @return group envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode patchGroup(final String groupId, final Object body)
            throws AuthenticationException, ApiException {
        return patchGroup(groupId, body, null);
    }

    /**
     * Patch a SCIM group with a token override.
     * @param groupId group ID
     * @param body request body
     * @param token optional SCIM token override
     * @return group envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode patchGroup(final String groupId, final Object body,
                               final String token)
            throws AuthenticationException, ApiException {
        return call("PATCH", "/v1/scim/v2/Groups/" + groupId, body,
                token);
    }

    /**
     * Delete a SCIM group.
     * @param groupId group ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteGroup(final String groupId)
            throws AuthenticationException, ApiException {
        return deleteGroup(groupId, null);
    }

    /**
     * Delete a SCIM group with a token override.
     * @param groupId group ID
     * @param token optional SCIM token override
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteGroup(final String groupId, final String token)
            throws AuthenticationException, ApiException {
        return call("DELETE", "/v1/scim/v2/Groups/" + groupId, null,
                token);
    }

    /**
     * List SCIM resource types.
     * @return resource types envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode resourceTypes()
            throws AuthenticationException, ApiException {
        return resourceTypes(null);
    }

    /**
     * List SCIM resource types with a token override.
     * @param token optional SCIM token override
     * @return resource types envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode resourceTypes(final String token)
            throws AuthenticationException, ApiException {
        return call("GET", "/v1/scim/v2/ResourceTypes", null, token);
    }

    /**
     * Get a SCIM resource type.
     * @param typeId resource type ID
     * @return resource type envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode resourceType(final String typeId)
            throws AuthenticationException, ApiException {
        return resourceType(typeId, null);
    }

    /**
     * Get a SCIM resource type with a token override.
     * @param typeId resource type ID
     * @param token optional SCIM token override
     * @return resource type envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode resourceType(final String typeId, final String token)
            throws AuthenticationException, ApiException {
        return call("GET", "/v1/scim/v2/ResourceTypes/" + typeId, null,
                token);
    }

    /**
     * List SCIM schemas.
     * @return schemas envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode schemas()
            throws AuthenticationException, ApiException {
        return schemas(null);
    }

    /**
     * List SCIM schemas with a token override.
     * @param token optional SCIM token override
     * @return schemas envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode schemas(final String token)
            throws AuthenticationException, ApiException {
        return call("GET", "/v1/scim/v2/Schemas", null, token);
    }

    /**
     * Get a SCIM schema.
     * @param schemaId schema ID
     * @return schema envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode schema(final String schemaId)
            throws AuthenticationException, ApiException {
        return schema(schemaId, null);
    }

    /**
     * Get a SCIM schema with a token override.
     * @param schemaId schema ID
     * @param token optional SCIM token override
     * @return schema envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode schema(final String schemaId, final String token)
            throws AuthenticationException, ApiException {
        return call("GET", "/v1/scim/v2/Schemas/" + schemaId, null,
                token);
    }

    /**
     * Get the SCIM service provider configuration.
     * @return configuration envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode serviceProviderConfig()
            throws AuthenticationException, ApiException {
        return serviceProviderConfig(null);
    }

    /**
     * Get the SCIM service provider configuration with a token.
     * @param token optional SCIM token override
     * @return configuration envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode serviceProviderConfig(final String token)
            throws AuthenticationException, ApiException {
        return call("GET", "/v1/scim/v2/ServiceProviderConfig", null,
                token);
    }

    /**
     * Send a SCIM request with the SCIM token.
     * @param method HTTP method
     * @param path request path
     * @param body request body
     * @param token optional SCIM token override
     * @return response envelope
     */
    private JsonNode call(final String method, final String path,
                          final Object body, final String token) {
        final String accessToken = token != null
                ? token : client.getScimToken();
        return client.request(method, path, body, null, JsonNode.class,
                accessToken);
    }
}
