package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Environment lifecycle operations.
 */
public final class EnvironmentsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create an environments helper.
     * @param clientParam Authdog client
     */
    public EnvironmentsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List environments for a project.
     * @param tenantId tenant ID
     * @param applicationId application ID
     * @return environments envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String applicationId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/tenants/" + tenantId + "/applications/"
                        + applicationId + "/environments",
                null, null, JsonNode.class);
    }

    /**
     * Create an environment.
     * @param tenantId tenant ID
     * @param applicationId application ID
     * @param body request body
     * @return created environment envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode create(final String tenantId,
                           final String applicationId,
                           final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                "/v1/tenants/" + tenantId + "/applications/"
                        + applicationId + "/environments",
                body, null, JsonNode.class);
    }

    /**
     * Update an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return updated environment envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode update(final String tenantId,
                           final String environmentId,
                           final Object body)
            throws AuthenticationException, ApiException {
        return client.request("PATCH",
                "/v1/tenants/" + tenantId + "/environments/"
                        + environmentId,
                body, null, JsonNode.class);
    }

    /**
     * Delete an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode delete(final String tenantId,
                           final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                "/v1/tenants/" + tenantId + "/environments/"
                        + environmentId,
                null, null, JsonNode.class);
    }
}
