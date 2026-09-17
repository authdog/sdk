package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;
import java.util.Map;

/**
 * Environment webhook operations.
 */
public final class WebhooksResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a webhooks helper.
     * @param clientParam Authdog client
     */
    public WebhooksResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List webhook endpoints.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return webhooks envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/webhooks",
                null, null, JsonNode.class);
    }

    /**
     * Create a webhook endpoint.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return created webhook envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode create(final String tenantId,
                           final String environmentId,
                           final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/webhooks",
                body, null, JsonNode.class);
    }

    /**
     * Update a webhook endpoint.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param channelId webhook channel ID
     * @param body request body
     * @return updated webhook envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode update(final String tenantId,
                           final String environmentId,
                           final String channelId,
                           final Object body)
            throws AuthenticationException, ApiException {
        return client.request("PUT",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/webhooks/" + channelId,
                body, null, JsonNode.class);
    }

    /**
     * Delete a webhook endpoint.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param channelId webhook channel ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode delete(final String tenantId,
                           final String environmentId,
                           final String channelId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/webhooks/" + channelId,
                null, null, JsonNode.class);
    }

    /**
     * Rotate a webhook signing secret.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param channelId webhook channel ID
     * @return rotate envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode rotateSecret(final String tenantId,
                                 final String environmentId,
                                 final String channelId)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/webhooks/" + channelId
                        + "/rotate-secret",
                null, null, JsonNode.class);
    }

    /**
     * List webhook deliveries.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return deliveries envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listDeliveries(final String tenantId,
                                   final String environmentId)
            throws AuthenticationException, ApiException {
        return listDeliveries(tenantId, environmentId, null);
    }

    /**
     * List webhook deliveries with caller query parameters.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param params optional query parameters
     * @return deliveries envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listDeliveries(final String tenantId,
                                   final String environmentId,
                                   final Map<String, String> params)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/webhooks/deliveries",
                null, params, JsonNode.class);
    }

    /**
     * Redeliver a webhook delivery.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param deliveryId delivery ID
     * @return redeliver envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode redeliver(final String tenantId,
                              final String environmentId,
                              final String deliveryId)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/webhooks/deliveries/" + deliveryId
                        + "/redeliver",
                null, null, JsonNode.class);
    }
}
