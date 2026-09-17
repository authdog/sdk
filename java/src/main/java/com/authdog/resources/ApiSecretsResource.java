package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Environment API secret operations.
 */
public final class ApiSecretsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create an API secrets helper.
     * @param clientParam Authdog client
     */
    public ApiSecretsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List API secrets for an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return secrets envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/api-secrets",
                null, null, JsonNode.class);
    }

    /**
     * Create an API secret.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return created secret envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode create(final String tenantId,
                           final String environmentId,
                           final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/api-secrets",
                body, null, JsonNode.class);
    }

    /**
     * Revoke an API secret.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param secretId secret ID
     * @return revoke envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode revoke(final String tenantId,
                           final String environmentId,
                           final String secretId)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/api-secrets/" + secretId + "/revoke",
                null, null, JsonNode.class);
    }
}
