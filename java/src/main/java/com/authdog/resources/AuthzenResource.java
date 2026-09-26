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
 * AuthZEN discovery and evaluation operations.
 */
public final class AuthzenResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create an AuthZEN helper.
     * @param clientParam Authdog client
     */
    public AuthzenResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * Fetch the public AuthZEN configuration document.
     * @return configuration envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode configuration()
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/.well-known/authzen-configuration",
                null, null, JsonNode.class, null, true);
    }

    /**
     * Evaluate a single AuthZEN decision.
     * @param body request body
     * @return evaluation envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode evaluate(final Object body)
            throws AuthenticationException, ApiException {
        return evaluate(body, null);
    }

    /**
     * Evaluate a single AuthZEN decision with a token override.
     * @param body request body
     * @param token optional environment secret override
     * @return evaluation envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode evaluate(final Object body, final String token)
            throws AuthenticationException, ApiException {
        return call("POST", "/access/v1/evaluation", body, token);
    }

    /**
     * Evaluate a batch of AuthZEN decisions.
     * @param body request body
     * @return evaluations envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode evaluateBatch(final Object body)
            throws AuthenticationException, ApiException {
        return evaluateBatch(body, null);
    }

    /**
     * Evaluate a batch of AuthZEN decisions with a token override.
     * @param body request body
     * @param token optional environment secret override
     * @return evaluations envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode evaluateBatch(final Object body, final String token)
            throws AuthenticationException, ApiException {
        return call("POST", "/access/v1/evaluations", body, token);
    }

    /**
     * Search actions for a subject.
     * @param body request body
     * @return search envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode searchAction(final Object body)
            throws AuthenticationException, ApiException {
        return searchAction(body, null);
    }

    /**
     * Search actions for a subject with a token override.
     * @param body request body
     * @param token optional environment secret override
     * @return search envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode searchAction(final Object body, final String token)
            throws AuthenticationException, ApiException {
        return call("POST", "/access/v1/search/action", body, token);
    }

    /**
     * Search resources for a subject.
     * @param body request body
     * @return search envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode searchResource(final Object body)
            throws AuthenticationException, ApiException {
        return searchResource(body, null);
    }

    /**
     * Search resources for a subject with a token override.
     * @param body request body
     * @param token optional environment secret override
     * @return search envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode searchResource(final Object body, final String token)
            throws AuthenticationException, ApiException {
        return call("POST", "/access/v1/search/resource", body, token);
    }

    /**
     * Search subjects for a resource.
     * @param body request body
     * @return search envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode searchSubject(final Object body)
            throws AuthenticationException, ApiException {
        return searchSubject(body, null);
    }

    /**
     * Search subjects for a resource with a token override.
     * @param body request body
     * @param token optional environment secret override
     * @return search envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode searchSubject(final Object body, final String token)
            throws AuthenticationException, ApiException {
        return call("POST", "/access/v1/search/subject", body, token);
    }

    /**
     * Send an AuthZEN request with the environment secret.
     * @param method HTTP method
     * @param path request path
     * @param body request body
     * @param token optional environment secret override
     * @return response envelope
     */
    private JsonNode call(final String method, final String path,
                          final Object body, final String token) {
        final String accessToken = token != null
                ? token : client.getEnvironmentSecret();
        return client.request(method, path, body, null, JsonNode.class,
                accessToken);
    }
}
