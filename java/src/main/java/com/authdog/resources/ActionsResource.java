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
 * Environment action operations.
 */
public final class ActionsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create an actions helper.
     * @param clientParam Authdog client
     */
    public ActionsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List actions in an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return actions envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId) + "/actions",
                null, null, JsonNode.class);
    }

    /**
     * Create or update an action.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return action envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode save(final String tenantId,
                         final String environmentId,
                         final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId) + "/actions",
                body, null, JsonNode.class);
    }

    /**
     * List action executions.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return executions envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode executions(final String tenantId,
                               final String environmentId)
            throws AuthenticationException, ApiException {
        return executions(tenantId, environmentId, null, null);
    }

    /**
     * List action executions with optional filters.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param actionId optional action ID
     * @param limit optional page size
     * @return executions envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode executions(final String tenantId,
                               final String environmentId,
                               final String actionId,
                               final Integer limit)
            throws AuthenticationException, ApiException {
        final Map<String, String> params = QueryParams.create();
        QueryParams.put(params, "actionId", actionId);
        QueryParams.put(params, "limit", limit);
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/actions/executions",
                null, QueryParams.orNull(params), JsonNode.class);
    }

    /**
     * Test an action.
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
                        + "/actions/test",
                body, null, JsonNode.class);
    }

    /**
     * Delete an action.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param actionId action ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode delete(final String tenantId,
                           final String environmentId,
                           final String actionId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/actions/" + actionId,
                null, null, JsonNode.class);
    }
}
