package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Environment addon operations.
 */
public final class AddonsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create an addons helper.
     * @param clientParam Authdog client
     */
    public AddonsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List addons in an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return addons envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId) + "/addons",
                null, null, JsonNode.class);
    }

    /**
     * Create or update an addon.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return addon envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode save(final String tenantId,
                         final String environmentId,
                         final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId) + "/addons",
                body, null, JsonNode.class);
    }

    /**
     * Delete an addon.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param provider addon provider
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode delete(final String tenantId,
                           final String environmentId,
                           final String provider)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/addons/" + provider,
                null, null, JsonNode.class);
    }
}
