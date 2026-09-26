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
 * SCIM and HRIS provisioning token operations.
 */
public final class ProvisioningTokensResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a provisioning tokens helper.
     * @param clientParam Authdog client
     */
    public ProvisioningTokensResource(
            final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List HRIS tokens.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return tokens envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listHris(final String tenantId,
                             final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/hris-tokens",
                null, null, JsonNode.class);
    }

    /**
     * Create an HRIS token.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return created token envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createHris(final String tenantId,
                               final String environmentId,
                               final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/hris-tokens",
                body, null, JsonNode.class);
    }

    /**
     * Revoke an HRIS token.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param tokenId token ID
     * @return revoke envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode revokeHris(final String tenantId,
                               final String environmentId,
                               final String tokenId)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/hris-tokens/" + tokenId + "/revoke",
                null, null, JsonNode.class);
    }

    /**
     * Rotate an HRIS token.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param tokenId token ID
     * @return rotate envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode rotateHris(final String tenantId,
                               final String environmentId,
                               final String tokenId)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/hris-tokens/" + tokenId + "/rotate",
                null, null, JsonNode.class);
    }

    /**
     * List SCIM tokens.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return tokens envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listScim(final String tenantId,
                             final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/scim-tokens",
                null, null, JsonNode.class);
    }

    /**
     * Create a SCIM token.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return created token envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createScim(final String tenantId,
                               final String environmentId,
                               final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/scim-tokens",
                body, null, JsonNode.class);
    }

    /**
     * Revoke a SCIM token.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param tokenId token ID
     * @return revoke envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode revokeScim(final String tenantId,
                               final String environmentId,
                               final String tokenId)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/scim-tokens/" + tokenId + "/revoke",
                null, null, JsonNode.class);
    }

    /**
     * Rotate a SCIM token.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param tokenId token ID
     * @return rotate envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode rotateScim(final String tenantId,
                               final String environmentId,
                               final String tokenId)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/scim-tokens/" + tokenId + "/rotate",
                null, null, JsonNode.class);
    }
}
