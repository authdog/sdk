package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;
import java.util.Map;

/**
 * Environment audit log operations.
 */
public final class AuditResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create an audit helper.
     * @param clientParam Authdog client
     */
    public AuditResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List environment audit logs.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return logs envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listLogs(final String tenantId,
                             final String environmentId)
            throws AuthenticationException, ApiException {
        return listLogs(tenantId, environmentId, null);
    }

    /**
     * List environment audit logs with caller query parameters.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param params optional query parameters
     * @return logs envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listLogs(final String tenantId,
                             final String environmentId,
                             final Map<String, String> params)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/audit/logs",
                null, params, JsonNode.class);
    }

    /**
     * Get environment audit event metadata.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return metadata envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode eventMetadata(final String tenantId,
                                  final String environmentId)
            throws AuthenticationException, ApiException {
        return eventMetadata(tenantId, environmentId, null);
    }

    /**
     * Get environment audit event metadata with query parameters.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param params optional query parameters
     * @return metadata envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode eventMetadata(final String tenantId,
                                  final String environmentId,
                                  final Map<String, String> params)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/audit/event-metadata",
                null, params, JsonNode.class);
    }

    /**
     * Get grouped environment audit event types.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return event types envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode eventTypes(final String tenantId,
                               final String environmentId)
            throws AuthenticationException, ApiException {
        return eventTypes(tenantId, environmentId, null);
    }

    /**
     * Get grouped environment audit event types with query
     * parameters.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param params optional query parameters
     * @return event types envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode eventTypes(final String tenantId,
                               final String environmentId,
                               final Map<String, String> params)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/audit/event-types",
                null, params, JsonNode.class);
    }

    /**
     * Get the audit event type catalog.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return catalog envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode eventTypesCatalog(final String tenantId,
                                      final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/audit/event-types/catalog",
                null, null, JsonNode.class);
    }
}
