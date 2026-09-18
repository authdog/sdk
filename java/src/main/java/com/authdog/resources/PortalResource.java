package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * User portal operations.
 */
public final class PortalResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a portal helper.
     * @param clientParam Authdog client
     */
    public PortalResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * Generate a portal magic link.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return link envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode generateLink(final String tenantId,
                                 final String environmentId,
                                 final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/portal/generate-link",
                body, null, JsonNode.class);
    }
}
