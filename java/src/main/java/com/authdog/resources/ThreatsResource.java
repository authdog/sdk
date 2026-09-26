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
import java.util.Map;

/**
 * Environment threat operations.
 */
public final class ThreatsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a threats helper.
     * @param clientParam Authdog client
     */
    public ThreatsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List threats in an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return threats envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String environmentId)
            throws AuthenticationException, ApiException {
        return list(tenantId, environmentId, null);
    }

    /**
     * List threats with caller query parameters.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param params optional query parameters
     * @return threats envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String environmentId,
                         final Map<String, String> params)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId) + "/threats",
                null, params, JsonNode.class);
    }

    /**
     * Create a threat.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return created threat envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode create(final String tenantId,
                           final String environmentId,
                           final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId) + "/threats",
                body, null, JsonNode.class);
    }

    /**
     * Get a threat.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param threatId threat ID
     * @return threat envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode get(final String tenantId,
                        final String environmentId,
                        final String threatId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/threats/" + threatId,
                null, null, JsonNode.class);
    }

    /**
     * Update a threat.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param threatId threat ID
     * @param body request body
     * @return updated threat envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode update(final String tenantId,
                           final String environmentId,
                           final String threatId,
                           final Object body)
            throws AuthenticationException, ApiException {
        return client.request("PATCH",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/threats/" + threatId,
                body, null, JsonNode.class);
    }

    /**
     * Delete a threat.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param threatId threat ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode delete(final String tenantId,
                           final String environmentId,
                           final String threatId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/threats/" + threatId,
                null, null, JsonNode.class);
    }

    /**
     * Resolve a threat.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param threatId threat ID
     * @param body request body
     * @return resolve envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode resolve(final String tenantId,
                            final String environmentId,
                            final String threatId,
                            final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/threats/" + threatId + "/resolve",
                body, null, JsonNode.class);
    }
}
