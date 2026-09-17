package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Project (application) management operations.
 */
public final class ProjectsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a projects helper.
     * @param clientParam Authdog client
     */
    public ProjectsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * Create or update a project.
     * @param tenantId tenant ID
     * @param body request body
     * @return project envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode save(final String tenantId, final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                "/v1/tenants/" + tenantId + "/applications", body, null,
                JsonNode.class);
    }

    /**
     * Get a project and its environments.
     * @param tenantId tenant ID
     * @param applicationId application ID
     * @return project envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode get(final String tenantId,
                        final String applicationId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/tenants/" + tenantId + "/applications/"
                        + applicationId,
                null, null, JsonNode.class);
    }

    /**
     * Delete a project.
     * @param tenantId tenant ID
     * @param applicationId application ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode delete(final String tenantId,
                           final String applicationId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                "/v1/tenants/" + tenantId + "/applications/"
                        + applicationId,
                null, null, JsonNode.class);
    }

    /**
     * Set a project's default environment.
     * @param tenantId tenant ID
     * @param applicationId application ID
     * @param body request body
     * @return update envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode setDefaultEnvironment(final String tenantId,
                                          final String applicationId,
                                          final Object body)
            throws AuthenticationException, ApiException {
        return client.request("PUT",
                "/v1/tenants/" + tenantId + "/applications/"
                        + applicationId + "/default-environment",
                body, null, JsonNode.class);
    }
}
