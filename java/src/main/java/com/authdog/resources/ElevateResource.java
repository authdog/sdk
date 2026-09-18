package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;
import java.util.Map;

/**
 * Privileged access elevate operations.
 */
public final class ElevateResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create an elevate helper.
     * @param clientParam Authdog client
     */
    public ElevateResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * Activate an access grant.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param grantId grant ID
     * @param body request body
     * @return activate envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode activateGrant(final String tenantId,
                                  final String environmentId,
                                  final String grantId,
                                  final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/elevate/access-grants/" + grantId
                        + "/activate",
                body, null, JsonNode.class);
    }

    /**
     * Revoke an access grant.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param grantId grant ID
     * @param body request body
     * @return revoke envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode revokeGrant(final String tenantId,
                                final String environmentId,
                                final String grantId,
                                final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/elevate/access-grants/" + grantId
                        + "/revoke",
                body, null, JsonNode.class);
    }

    /**
     * List access requests.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return requests envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listRequests(final String tenantId,
                                 final String environmentId)
            throws AuthenticationException, ApiException {
        return listRequests(tenantId, environmentId, null);
    }

    /**
     * List access requests filtered by status.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param status optional status filter
     * @return requests envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listRequests(final String tenantId,
                                 final String environmentId,
                                 final String status)
            throws AuthenticationException, ApiException {
        final Map<String, String> params = QueryParams.create();
        QueryParams.put(params, "status", status);
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/elevate/access-requests",
                null, QueryParams.orNull(params), JsonNode.class);
    }

    /**
     * Create an access request.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return created request envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createRequest(final String tenantId,
                                  final String environmentId,
                                  final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/elevate/access-requests",
                body, null, JsonNode.class);
    }

    /**
     * Get an access request.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param requestId request ID
     * @return request envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getRequest(final String tenantId,
                               final String environmentId,
                               final String requestId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/elevate/access-requests/" + requestId,
                null, null, JsonNode.class);
    }

    /**
     * Approve an access request.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param requestId request ID
     * @param body request body
     * @return approve envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode approveRequest(final String tenantId,
                                   final String environmentId,
                                   final String requestId,
                                   final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/elevate/access-requests/" + requestId
                        + "/approve",
                body, null, JsonNode.class);
    }

    /**
     * Cancel an access request.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param requestId request ID
     * @return cancel envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode cancelRequest(final String tenantId,
                                  final String environmentId,
                                  final String requestId)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/elevate/access-requests/" + requestId
                        + "/cancel",
                null, null, JsonNode.class);
    }

    /**
     * Deny an access request.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param requestId request ID
     * @param body request body
     * @return deny envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode denyRequest(final String tenantId,
                                final String environmentId,
                                final String requestId,
                                final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/elevate/access-requests/" + requestId
                        + "/deny",
                body, null, JsonNode.class);
    }

    /**
     * Get the elevate policy.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return policy envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getPolicy(final String tenantId,
                              final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/elevate/policy",
                null, null, JsonNode.class);
    }

    /**
     * Update the elevate policy.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return policy envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode updatePolicy(final String tenantId,
                                 final String environmentId,
                                 final Object body)
            throws AuthenticationException, ApiException {
        return client.request("PUT",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/elevate/policy",
                body, null, JsonNode.class);
    }
}
