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
 * Environment event operations.
 */
public final class EventsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create an events helper.
     * @param clientParam Authdog client
     */
    public EventsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List events in an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return events envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String environmentId)
            throws AuthenticationException, ApiException {
        return list(tenantId, environmentId, null);
    }

    /**
     * List events in an environment with caller query parameters.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param params optional query parameters
     * @return events envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String environmentId,
                         final Map<String, String> params)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId) + "/events",
                null, params, JsonNode.class);
    }

    /**
     * List event types in an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return event types envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listTypes(final String tenantId,
                              final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/events/types",
                null, null, JsonNode.class);
    }

    /**
     * Ingest security events.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return ingest envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode ingest(final String tenantId,
                           final String environmentId,
                           final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/events/ingest",
                body, null, JsonNode.class);
    }
}
