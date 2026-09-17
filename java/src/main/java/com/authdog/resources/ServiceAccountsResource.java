package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Service account operations.
 */
public final class ServiceAccountsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a service accounts helper.
     * @param clientParam Authdog client
     */
    public ServiceAccountsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List service accounts.
     * @return service accounts envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list()
            throws AuthenticationException, ApiException {
        return client.request("GET", "/v1/service-accounts", null,
                null, JsonNode.class);
    }

    /**
     * Create a service account.
     * @param body request body
     * @return created service account envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode create(final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST", "/v1/service-accounts", body,
                null, JsonNode.class);
    }

    /**
     * Get a service account.
     * @param serviceAccountId service account ID
     * @return service account envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode get(final String serviceAccountId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/service-accounts/" + serviceAccountId, null,
                null, JsonNode.class);
    }

    /**
     * Delete a service account.
     * @param serviceAccountId service account ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode delete(final String serviceAccountId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                "/v1/service-accounts/" + serviceAccountId, null,
                null, JsonNode.class);
    }
}
