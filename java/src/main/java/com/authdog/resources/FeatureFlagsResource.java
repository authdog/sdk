package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Environment feature flag operations.
 */
public final class FeatureFlagsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a feature flags helper.
     * @param clientParam Authdog client
     */
    public FeatureFlagsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List feature flags.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return flags envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/feature-flags",
                null, null, JsonNode.class);
    }

    /**
     * Create or update a feature flag.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return flag envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode save(final String tenantId,
                         final String environmentId,
                         final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/feature-flags",
                body, null, JsonNode.class);
    }

    /**
     * Delete a feature flag.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param flagId flag ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode delete(final String tenantId,
                           final String environmentId,
                           final String flagId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/feature-flags/" + flagId,
                null, null, JsonNode.class);
    }
}
