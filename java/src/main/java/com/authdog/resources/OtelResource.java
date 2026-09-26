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
 * OpenTelemetry export operations.
 */
public final class OtelResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create an OTEL helper.
     * @param clientParam Authdog client
     */
    public OtelResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * Export logs to the unprefixed OTEL path.
     * @param body request body
     * @return export envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode exportLogs(final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST", "/v1/logs", body, null,
                JsonNode.class);
    }

    /**
     * Export metrics to the unprefixed OTEL path.
     * @param body request body
     * @return export envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode exportMetrics(final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST", "/v1/metrics", body, null,
                JsonNode.class);
    }

    /**
     * Export traces to the unprefixed OTEL path.
     * @param body request body
     * @return export envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode exportTraces(final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST", "/v1/traces", body, null,
                JsonNode.class);
    }

    /**
     * Export logs to the prefixed OTEL path.
     * @param body request body
     * @return export envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode exportLogsPrefixed(final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST", "/v1/otel/v1/logs", body, null,
                JsonNode.class);
    }

    /**
     * Export metrics to the prefixed OTEL path.
     * @param body request body
     * @return export envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode exportMetricsPrefixed(final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST", "/v1/otel/v1/metrics", body, null,
                JsonNode.class);
    }

    /**
     * Export traces to the prefixed OTEL path.
     * @param body request body
     * @return export envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode exportTracesPrefixed(final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST", "/v1/otel/v1/traces", body, null,
                JsonNode.class);
    }
}
