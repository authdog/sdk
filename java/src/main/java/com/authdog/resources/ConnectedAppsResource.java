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
 * Connected-app grants and the OIDC client allowlist.
 */
public final class ConnectedAppsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a connected-apps helper.
     * @param clientParam Authdog client
     */
    public ConnectedAppsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List connected-app grants.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return grants envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String environmentId)
            throws AuthenticationException, ApiException {
        return list(tenantId, environmentId, null, null);
    }

    /**
     * List connected-app grants filtered by user or client.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param userId optional user id
     * @param clientId optional OIDC client id
     * @return grants envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String environmentId,
                         final String userId,
                         final String clientId)
            throws AuthenticationException, ApiException {
        final Map<String, String> params = QueryParams.create();
        QueryParams.put(params, "userId", userId);
        QueryParams.put(params, "clientId", clientId);
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/connected-apps",
                null, QueryParams.orNull(params), JsonNode.class);
    }

    /**
     * Revoke a user's grant for an OIDC client.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return revocation envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode revoke(final String tenantId,
                           final String environmentId,
                           final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/connected-apps/revoke",
                body, null, JsonNode.class);
    }

    /**
     * List the OIDC client allowlist.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return allowlist envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listAllowlist(final String tenantId,
                                  final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/client-allowlist",
                null, null, JsonNode.class);
    }

    /**
     * Upsert an OIDC client allowlist entry.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return save envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode saveAllowlist(final String tenantId,
                                  final String environmentId,
                                  final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/client-allowlist",
                body, null, JsonNode.class);
    }

    /**
     * Remove an OIDC client from the allowlist.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param clientId OIDC client id
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteAllowlist(final String tenantId,
                                    final String environmentId,
                                    final String clientId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/client-allowlist/" + clientId,
                null, null, JsonNode.class);
    }
}
