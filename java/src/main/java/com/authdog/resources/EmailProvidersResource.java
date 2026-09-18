package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Environment email provider operations.
 */
public final class EmailProvidersResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create an email providers helper.
     * @param clientParam Authdog client
     */
    public EmailProvidersResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List email providers.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return providers envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/email-providers",
                null, null, JsonNode.class);
    }

    /**
     * Create or update an email provider.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return provider envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode save(final String tenantId,
                         final String environmentId,
                         final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/email-providers",
                body, null, JsonNode.class);
    }

    /**
     * Test an email provider.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return test envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode test(final String tenantId,
                         final String environmentId,
                         final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/email-providers/test",
                body, null, JsonNode.class);
    }

    /**
     * Delete an email provider.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param provider provider name
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
                        + "/email-providers/" + provider,
                null, null, JsonNode.class);
    }

    /**
     * Activate an email provider.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param provider provider name
     * @return activate envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode activate(final String tenantId,
                             final String environmentId,
                             final String provider)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/email-providers/" + provider
                        + "/activate",
                null, null, JsonNode.class);
    }
}
