package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;
import java.util.Map;

/**
 * Environment lifecycle operations.
 */
public final class EnvironmentsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create an environments helper.
     * @param clientParam Authdog client
     */
    public EnvironmentsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List environments for a project.
     * @param tenantId tenant ID
     * @param applicationId application ID
     * @return environments envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String applicationId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/tenants/" + tenantId + "/applications/"
                        + applicationId + "/environments",
                null, null, JsonNode.class);
    }

    /**
     * Create an environment.
     * @param tenantId tenant ID
     * @param applicationId application ID
     * @param body request body
     * @return created environment envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode create(final String tenantId,
                           final String applicationId,
                           final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                "/v1/tenants/" + tenantId + "/applications/"
                        + applicationId + "/environments",
                body, null, JsonNode.class);
    }

    /**
     * Update an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return updated environment envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode update(final String tenantId,
                           final String environmentId,
                           final Object body)
            throws AuthenticationException, ApiException {
        return client.request("PATCH",
                "/v1/tenants/" + tenantId + "/environments/"
                        + environmentId,
                body, null, JsonNode.class);
    }

    /**
     * Delete an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode delete(final String tenantId,
                           final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                "/v1/tenants/" + tenantId + "/environments/"
                        + environmentId,
                null, null, JsonNode.class);
    }

    /**
     * List connections for a project environment.
     * @param tenantId tenant ID
     * @param applicationId application ID
     * @param environmentId environment ID
     * @return connections envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listConnections(final String tenantId,
                                    final String applicationId,
                                    final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/tenants/" + tenantId + "/applications/"
                        + applicationId + "/environments/"
                        + environmentId + "/connections",
                null, null, JsonNode.class);
    }

    /**
     * List redirect URIs for a project environment.
     * @param tenantId tenant ID
     * @param applicationId application ID
     * @param environmentId environment ID
     * @return redirect URIs envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listRedirectUris(final String tenantId,
                                     final String applicationId,
                                     final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/tenants/" + tenantId + "/applications/"
                        + applicationId + "/environments/"
                        + environmentId + "/redirect-uris",
                null, null, JsonNode.class);
    }

    /**
     * Create or update a connection.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return connection envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode saveConnection(final String tenantId,
                                   final String environmentId,
                                   final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/connections",
                body, null, JsonNode.class);
    }

    /**
     * Resolve SAML metadata for a connection.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return metadata envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode resolveSamlMetadata(final String tenantId,
                                        final String environmentId,
                                        final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/connections/resolve-saml-metadata",
                body, null, JsonNode.class);
    }

    /**
     * Get SSO metadata for an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return SSO metadata envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getSsoMetadata(final String tenantId,
                                   final String environmentId)
            throws AuthenticationException, ApiException {
        return getSsoMetadata(tenantId, environmentId, null, null);
    }

    /**
     * Get SSO metadata with optional connection filters.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param connectionId optional connection ID
     * @param providerId optional provider ID
     * @return SSO metadata envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getSsoMetadata(final String tenantId,
                                   final String environmentId,
                                   final String connectionId,
                                   final String providerId)
            throws AuthenticationException, ApiException {
        final Map<String, String> params = QueryParams.create();
        QueryParams.put(params, "connectionId", connectionId);
        QueryParams.put(params, "providerId", providerId);
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/connections/sso-metadata",
                null, QueryParams.orNull(params), JsonNode.class);
    }

    /**
     * Delete a connection.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param connectionId connection ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteConnection(final String tenantId,
                                     final String environmentId,
                                     final String connectionId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/connections/" + connectionId,
                null, null, JsonNode.class);
    }

    /**
     * Replace redirect URIs for an environment.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return redirect URIs envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode saveRedirectUris(final String tenantId,
                                     final String environmentId,
                                     final Object body)
            throws AuthenticationException, ApiException {
        return client.request("PUT",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/redirect-uris",
                body, null, JsonNode.class);
    }
}
