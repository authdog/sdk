package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Impersonation grant operations.
 */
public final class ImpersonationResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create an impersonation helper.
     * @param clientParam Authdog client
     */
    public ImpersonationResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List impersonation grants.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return grants envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/impersonation-grants",
                null, null, JsonNode.class);
    }

    /**
     * Create an impersonation grant.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return created grant envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode create(final String tenantId,
                           final String environmentId,
                           final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/impersonation-grants",
                body, null, JsonNode.class);
    }

    /**
     * Revoke an impersonation grant.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param grantId grant ID
     * @return revoke envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode revoke(final String tenantId,
                           final String environmentId,
                           final String grantId)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/impersonation-grants/" + grantId
                        + "/revoke",
                null, null, JsonNode.class);
    }
}
