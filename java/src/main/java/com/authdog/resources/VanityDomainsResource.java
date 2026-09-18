package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Environment vanity domain operations.
 */
public final class VanityDomainsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a vanity domains helper.
     * @param clientParam Authdog client
     */
    public VanityDomainsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List vanity domains.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return domains envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/vanity-domains",
                null, null, JsonNode.class);
    }

    /**
     * Create a vanity domain.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return created domain envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode create(final String tenantId,
                           final String environmentId,
                           final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/vanity-domains",
                body, null, JsonNode.class);
    }

    /**
     * Delete a vanity domain.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param domainId domain ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode delete(final String tenantId,
                           final String environmentId,
                           final String domainId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/vanity-domains/" + domainId,
                null, null, JsonNode.class);
    }

    /**
     * Check vanity domain DNS status.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param domainId domain ID
     * @return check envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode check(final String tenantId,
                          final String environmentId,
                          final String domainId)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/vanity-domains/" + domainId + "/check",
                null, null, JsonNode.class);
    }
}
