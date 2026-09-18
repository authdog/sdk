package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;
import java.util.Map;

/**
 * MCP runtime and trust-store operations.
 */
public final class McpResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create an MCP helper.
     * @param clientParam Authdog client
     */
    public McpResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * Ingest MCP runtime events.
     * @param body request body
     * @return ingest envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode ingestEvents(final Object body)
            throws AuthenticationException, ApiException {
        return ingestEvents(body, null);
    }

    /**
     * Ingest MCP runtime events with a token override.
     * @param body request body
     * @param token optional environment secret override
     * @return ingest envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode ingestEvents(final Object body, final String token)
            throws AuthenticationException, ApiException {
        return client.request("POST", "/v1/mcp/events", body, null,
                JsonNode.class, runtimeToken(token));
    }

    /**
     * Resolve a trust-store subject at runtime.
     * @param subject subject identifier
     * @return resolve envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode resolve(final String subject)
            throws AuthenticationException, ApiException {
        return resolve(subject, null);
    }

    /**
     * Resolve a trust-store subject with a token override.
     * @param subject subject identifier
     * @param token optional environment secret override
     * @return resolve envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode resolve(final String subject, final String token)
            throws AuthenticationException, ApiException {
        final Map<String, String> params = QueryParams.create();
        QueryParams.put(params, "subject", subject);
        return client.request("GET", "/v1/mcp/trust-store/resolve",
                null, QueryParams.orNull(params), JsonNode.class,
                runtimeToken(token));
    }

    /**
     * List trust-store entries for an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return entries envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listEntries(final String tenantId,
                                final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/mcp/trust-store",
                null, null, JsonNode.class);
    }

    /**
     * Create a trust-store entry.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return created entry envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createEntry(final String tenantId,
                                final String environmentId,
                                final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/mcp/trust-store",
                body, null, JsonNode.class);
    }

    /**
     * Get a trust-store entry.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param entryId entry ID
     * @return entry envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getEntry(final String tenantId,
                             final String environmentId,
                             final String entryId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/mcp/trust-store/" + entryId,
                null, null, JsonNode.class);
    }

    /**
     * Update a trust-store entry.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param entryId entry ID
     * @param body request body
     * @return updated entry envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode updateEntry(final String tenantId,
                                final String environmentId,
                                final String entryId,
                                final Object body)
            throws AuthenticationException, ApiException {
        return client.request("PATCH",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/mcp/trust-store/" + entryId,
                body, null, JsonNode.class);
    }

    /**
     * Delete a trust-store entry.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param entryId entry ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteEntry(final String tenantId,
                                final String environmentId,
                                final String entryId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/mcp/trust-store/" + entryId,
                null, null, JsonNode.class);
    }

    /**
     * Add a key to a trust-store entry.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param entryId entry ID
     * @param body request body
     * @return key envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode addKey(final String tenantId,
                           final String environmentId,
                           final String entryId,
                           final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/mcp/trust-store/" + entryId + "/keys",
                body, null, JsonNode.class);
    }

    /**
     * Revoke a key on a trust-store entry.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param entryId entry ID
     * @param keyId key ID
     * @return revoke envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode revokeKey(final String tenantId,
                              final String environmentId,
                              final String entryId,
                              final String keyId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/mcp/trust-store/" + entryId + "/keys/"
                        + keyId,
                null, null, JsonNode.class);
    }

    /**
     * Rotate a key on a trust-store entry.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param entryId entry ID
     * @param keyId key ID
     * @return rotate envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode rotateKey(final String tenantId,
                              final String environmentId,
                              final String entryId,
                              final String keyId)
            throws AuthenticationException, ApiException {
        return rotateKey(tenantId, environmentId, entryId, keyId, null);
    }

    /**
     * Rotate a key on a trust-store entry with an optional body.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param entryId entry ID
     * @param keyId key ID
     * @param body optional request body
     * @return rotate envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode rotateKey(final String tenantId,
                              final String environmentId,
                              final String entryId,
                              final String keyId,
                              final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/mcp/trust-store/" + entryId + "/keys/"
                        + keyId + "/rotate",
                body, null, JsonNode.class);
    }

    /**
     * Revoke a trust-store entry.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param entryId entry ID
     * @return revoke envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode revokeEntry(final String tenantId,
                                final String environmentId,
                                final String entryId)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/mcp/trust-store/" + entryId + "/revoke",
                null, null, JsonNode.class);
    }

    /**
     * Verify a trust-store entry.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param entryId entry ID
     * @param body request body
     * @return verify envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode verifyEntry(final String tenantId,
                                final String environmentId,
                                final String entryId,
                                final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/mcp/trust-store/" + entryId + "/verify",
                body, null, JsonNode.class);
    }

    /**
     * Resolve the MCP runtime Bearer token.
     * @param token optional override
     * @return token or environment secret
     */
    private String runtimeToken(final String token) {
        return token != null ? token : client.getEnvironmentSecret();
    }
}
