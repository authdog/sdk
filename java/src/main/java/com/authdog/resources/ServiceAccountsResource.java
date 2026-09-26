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
 * Service account operations.
 */
public final class ServiceAccountsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a service accounts helper.
     * @param clientParam Authdog client
     */
    public ServiceAccountsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List service accounts.
     * @return service accounts envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list()
            throws AuthenticationException, ApiException {
        return client.request("GET", "/v1/service-accounts", null,
                null, JsonNode.class);
    }

    /**
     * Create a service account.
     * @param body request body
     * @return created service account envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode create(final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST", "/v1/service-accounts", body,
                null, JsonNode.class);
    }

    /**
     * Get a service account.
     * @param serviceAccountId service account ID
     * @return service account envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode get(final String serviceAccountId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/service-accounts/" + serviceAccountId, null,
                null, JsonNode.class);
    }

    /**
     * Delete a service account.
     * @param serviceAccountId service account ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode delete(final String serviceAccountId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                "/v1/service-accounts/" + serviceAccountId, null,
                null, JsonNode.class);
    }
}
