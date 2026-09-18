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
