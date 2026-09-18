package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Environment widget operations.
 */
public final class WidgetsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a widgets helper.
     * @param clientParam Authdog client
     */
    public WidgetsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * Create a widget token.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return token envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createToken(final String tenantId,
                                final String environmentId,
                                final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/widgets/token",
                body, null, JsonNode.class);
    }
}
