/*
 * MIT License
 *
 * Copyright (c) 2025 Authdog
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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
