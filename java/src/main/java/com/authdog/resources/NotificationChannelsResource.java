package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Environment notification channel operations.
 */
public final class NotificationChannelsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a notification channels helper.
     * @param clientParam Authdog client
     */
    public NotificationChannelsResource(
            final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List notification channels.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return channels envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list(final String tenantId,
                         final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/notification-channels",
                null, null, JsonNode.class);
    }

    /**
     * Create a notification channel.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return created channel envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode create(final String tenantId,
                           final String environmentId,
                           final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/notification-channels",
                body, null, JsonNode.class);
    }

    /**
     * Update a notification channel.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param channelId channel ID
     * @param body request body
     * @return updated channel envelope
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
                        + "/notification-channels/" + channelId,
                body, null, JsonNode.class);
    }

    /**
     * Delete a notification channel.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param channelId channel ID
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
                        + "/notification-channels/" + channelId,
                null, null, JsonNode.class);
    }

    /**
     * Test a notification channel.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param channelId channel ID
     * @return test envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode test(final String tenantId,
                         final String environmentId,
                         final String channelId)
            throws AuthenticationException, ApiException {
        return test(tenantId, environmentId, channelId, null);
    }

    /**
     * Test a notification channel with an optional body.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param channelId channel ID
     * @param body optional request body
     * @return test envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode test(final String tenantId,
                         final String environmentId,
                         final String channelId,
                         final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/notification-channels/" + channelId
                        + "/test",
                body, null, JsonNode.class);
    }
}
