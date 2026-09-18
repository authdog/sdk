package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Environment form operations.
 */
public final class FormsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a forms helper.
     * @param clientParam Authdog client
     */
    public FormsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List form attachments.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return attachments envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listAttachments(final String tenantId,
                                    final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/form-attachments",
                null, null, JsonNode.class);
    }

    /**
     * List forms.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return forms envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId) + "/forms",
                null, null, JsonNode.class);
    }

    /**
     * Create or update a form.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return form envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode save(final String tenantId,
                         final String environmentId,
                         final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId) + "/forms",
                body, null, JsonNode.class);
    }

    /**
     * Delete a form.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param formId form ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode delete(final String tenantId,
                           final String environmentId,
                           final String formId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/forms/" + formId,
                null, null, JsonNode.class);
    }
}
