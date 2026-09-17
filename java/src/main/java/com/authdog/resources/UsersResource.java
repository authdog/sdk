package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.authdog.types.EnvUsersResponse;
import com.fasterxml.jackson.databind.JsonNode;
import java.util.Map;

/**
 * Directory user operations.
 */
public final class UsersResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a users helper.
     * @param clientParam Authdog client
     */
    public UsersResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List users in an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return users envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public EnvUsersResponse list(final String tenantId,
                                 final String environmentId)
            throws AuthenticationException, ApiException {
        return list(tenantId, environmentId, null, null, null);
    }

    /**
     * List users in an environment with optional filters.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param offset page offset
     * @param limit page size
     * @param searchQuery search query
     * @return users envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public EnvUsersResponse list(final String tenantId,
                                 final String environmentId,
                                 final Integer offset,
                                 final Integer limit,
                                 final String searchQuery)
            throws AuthenticationException, ApiException {
        final Map<String, String> params = QueryParams.create();
        QueryParams.put(params, "offset", offset);
        QueryParams.put(params, "limit", limit);
        QueryParams.put(params, "searchQuery", searchQuery);
        return client.request("GET",
                "/v1/tenants/" + tenantId + "/environments/"
                        + environmentId + "/users",
                null, QueryParams.orNull(params),
                EnvUsersResponse.class);
    }

    /**
     * Create a user.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return created user envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode create(final String tenantId,
                           final String environmentId,
                           final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                "/v1/tenants/" + tenantId + "/environments/"
                        + environmentId + "/users",
                body, null, JsonNode.class);
    }

    /**
     * Search users in an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param q search query
     * @return users envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public EnvUsersResponse search(final String tenantId,
                                   final String environmentId,
                                   final String q)
            throws AuthenticationException, ApiException {
        return search(tenantId, environmentId, q, null, null);
    }

    /**
     * Search users in an environment with paging.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param q search query
     * @param offset page offset
     * @param limit page size
     * @return users envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public EnvUsersResponse search(final String tenantId,
                                   final String environmentId,
                                   final String q,
                                   final Integer offset,
                                   final Integer limit)
            throws AuthenticationException, ApiException {
        final Map<String, String> params = QueryParams.create();
        QueryParams.put(params, "q", q);
        QueryParams.put(params, "offset", offset);
        QueryParams.put(params, "limit", limit);
        return client.request("GET",
                "/v1/tenants/" + tenantId + "/environments/"
                        + environmentId + "/users/search",
                null, QueryParams.orNull(params),
                EnvUsersResponse.class);
    }

    /**
     * Count users in an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return count envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode count(final String tenantId,
                          final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/tenants/" + tenantId + "/environments/"
                        + environmentId + "/users/count",
                null, null, JsonNode.class);
    }

    /**
     * Get a user.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param userId user ID
     * @return user envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode get(final String tenantId,
                        final String environmentId,
                        final String userId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/tenants/" + tenantId + "/environments/"
                        + environmentId + "/users/" + userId,
                null, null, JsonNode.class);
    }

    /**
     * Update a user's profile.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param userId user ID
     * @param body request body
     * @return update envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode update(final String tenantId,
                           final String environmentId,
                           final String userId, final Object body)
            throws AuthenticationException, ApiException {
        return client.request("PUT",
                "/v1/tenants/" + tenantId + "/environments/"
                        + environmentId + "/users/" + userId,
                body, null, JsonNode.class);
    }

    /**
     * Delete a user from the environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param userId user ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode delete(final String tenantId,
                           final String environmentId,
                           final String userId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                "/v1/tenants/" + tenantId + "/environments/"
                        + environmentId + "/users/" + userId,
                null, null, JsonNode.class);
    }

    /**
     * Enable or disable a user.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param userId user ID
     * @param body request body
     * @return update envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode setActive(final String tenantId,
                              final String environmentId,
                              final String userId, final Object body)
            throws AuthenticationException, ApiException {
        return client.request("PATCH",
                "/v1/tenants/" + tenantId + "/environments/"
                        + environmentId + "/users/" + userId
                        + "/active",
                body, null, JsonNode.class);
    }

    /**
     * List groups a user belongs to.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param userId user ID
     * @return groups envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listGroups(final String tenantId,
                               final String environmentId,
                               final String userId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/tenants/" + tenantId + "/environments/"
                        + environmentId + "/users/" + userId
                        + "/groups",
                null, null, JsonNode.class);
    }
}
