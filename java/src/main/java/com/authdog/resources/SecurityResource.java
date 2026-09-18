package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Environment security operations.
 */
public final class SecurityResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a security helper.
     * @param clientParam Authdog client
     */
    public SecurityResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * Get the environment security posture.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return posture envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode posture(final String tenantId,
                            final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/security/posture",
                null, null, JsonNode.class);
    }
}
