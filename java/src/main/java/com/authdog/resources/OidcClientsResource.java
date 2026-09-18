package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Environment OIDC client operations.
 */
public final class OidcClientsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create an OIDC clients helper.
     * @param clientParam Authdog client
     */
    public OidcClientsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List OIDC clients for a project environment.
     * @param tenantId tenant ID
     * @param applicationId application ID
     * @param environmentId environment ID
     * @return clients envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String applicationId,
                         final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                path(tenantId, applicationId, environmentId),
                null, null, JsonNode.class);
    }

    /**
     * Register an OIDC client.
     * @param tenantId tenant ID
     * @param applicationId application ID
     * @param environmentId environment ID
     * @param body request body
     * @return created client envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode register(final String tenantId,
                             final String applicationId,
                             final String environmentId,
                             final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                path(tenantId, applicationId, environmentId),
                body, null, JsonNode.class);
    }

    /**
     * Update an OIDC client.
     * @param tenantId tenant ID
     * @param applicationId application ID
     * @param environmentId environment ID
     * @param clientId client ID
     * @param body request body
     * @return updated client envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode update(final String tenantId,
                           final String applicationId,
                           final String environmentId,
                           final String clientId,
                           final Object body)
            throws AuthenticationException, ApiException {
        return client.request("PATCH",
                path(tenantId, applicationId, environmentId)
                        + "/" + clientId,
                body, null, JsonNode.class);
    }

    /**
     * Delete an OIDC client.
     * @param tenantId tenant ID
     * @param applicationId application ID
     * @param environmentId environment ID
     * @param clientId client ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode delete(final String tenantId,
                           final String applicationId,
                           final String environmentId,
                           final String clientId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                path(tenantId, applicationId, environmentId)
                        + "/" + clientId,
                null, null, JsonNode.class);
    }

    /**
     * Build the OIDC clients path prefix.
     * @param tenantId tenant ID
     * @param applicationId application ID
     * @param environmentId environment ID
     * @return path prefix
     */
    private String path(final String tenantId,
                        final String applicationId,
                        final String environmentId) {
        return "/v1/tenants/" + tenantId + "/applications/"
                + applicationId + "/environments/" + environmentId
                + "/oidc-clients";
    }
}
