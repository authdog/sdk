package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Environment policy and settings operations.
 */
public final class SettingsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a settings helper.
     * @param clientParam Authdog client
     */
    public SettingsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * Get the bot detection policy.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return policy envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getBotDetectionPolicy(final String tenantId,
                                          final String environmentId)
            throws AuthenticationException, ApiException {
        return get(tenantId, environmentId, "bot-detection-policy");
    }

    /**
     * Update the bot detection policy.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return policy envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode updateBotDetectionPolicy(final String tenantId,
                                             final String environmentId,
                                             final Object body)
            throws AuthenticationException, ApiException {
        return put(tenantId, environmentId, "bot-detection-policy",
                body);
    }

    /**
     * Get the breached password policy.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return policy envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getBreachedPasswordPolicy(final String tenantId,
                                              final String environmentId)
            throws AuthenticationException, ApiException {
        return get(tenantId, environmentId,
                "breached-password-policy");
    }

    /**
     * Update the breached password policy.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return policy envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode updateBreachedPasswordPolicy(
            final String tenantId,
            final String environmentId,
            final Object body)
            throws AuthenticationException, ApiException {
        return put(tenantId, environmentId,
                "breached-password-policy", body);
    }

    /**
     * Get the brute force policy.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return policy envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getBruteForcePolicy(final String tenantId,
                                        final String environmentId)
            throws AuthenticationException, ApiException {
        return get(tenantId, environmentId, "brute-force-policy");
    }

    /**
     * Update the brute force policy.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return policy envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode updateBruteForcePolicy(final String tenantId,
                                           final String environmentId,
                                           final Object body)
            throws AuthenticationException, ApiException {
        return put(tenantId, environmentId, "brute-force-policy",
                body);
    }

    /**
     * Get the device risk policy.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return policy envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getDeviceRiskPolicy(final String tenantId,
                                        final String environmentId)
            throws AuthenticationException, ApiException {
        return get(tenantId, environmentId, "device-risk-policy");
    }

    /**
     * Update the device risk policy.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return policy envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode updateDeviceRiskPolicy(final String tenantId,
                                           final String environmentId,
                                           final Object body)
            throws AuthenticationException, ApiException {
        return put(tenantId, environmentId, "device-risk-policy",
                body);
    }

    /**
     * List JWT claim mappings.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return mappings envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listJwtClaimMappings(final String tenantId,
                                         final String environmentId)
            throws AuthenticationException, ApiException {
        return get(tenantId, environmentId, "jwt-claim-mappings");
    }

    /**
     * Create or update a JWT claim mapping.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return mapping envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode saveJwtClaimMapping(final String tenantId,
                                        final String environmentId,
                                        final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/jwt-claim-mappings",
                body, null, JsonNode.class);
    }

    /**
     * Delete a JWT claim mapping.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param mappingId mapping ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteJwtClaimMapping(final String tenantId,
                                          final String environmentId,
                                          final String mappingId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/jwt-claim-mappings/" + mappingId,
                null, null, JsonNode.class);
    }

    /**
     * Get the password policy.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return policy envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getPasswordPolicy(final String tenantId,
                                      final String environmentId)
            throws AuthenticationException, ApiException {
        return get(tenantId, environmentId, "password-policy");
    }

    /**
     * Update the password policy.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return policy envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode updatePasswordPolicy(final String tenantId,
                                         final String environmentId,
                                         final Object body)
            throws AuthenticationException, ApiException {
        return put(tenantId, environmentId, "password-policy", body);
    }

    /**
     * Get the rate limit policy.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return policy envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getRateLimitPolicy(final String tenantId,
                                       final String environmentId)
            throws AuthenticationException, ApiException {
        return get(tenantId, environmentId, "rate-limit-policy");
    }

    /**
     * Update the rate limit policy.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return policy envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode updateRateLimitPolicy(final String tenantId,
                                          final String environmentId,
                                          final Object body)
            throws AuthenticationException, ApiException {
        return put(tenantId, environmentId, "rate-limit-policy", body);
    }

    /**
     * Get environment restrictions.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return restrictions envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getRestrictions(final String tenantId,
                                    final String environmentId)
            throws AuthenticationException, ApiException {
        return get(tenantId, environmentId, "restrictions");
    }

    /**
     * Update environment restrictions.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return restrictions envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode updateRestrictions(final String tenantId,
                                       final String environmentId,
                                       final Object body)
            throws AuthenticationException, ApiException {
        return put(tenantId, environmentId, "restrictions", body);
    }

    /**
     * Get the session configuration.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return session config envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode getSessionConfig(final String tenantId,
                                     final String environmentId)
            throws AuthenticationException, ApiException {
        return get(tenantId, environmentId, "session-config");
    }

    /**
     * Update the session configuration.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return session config envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode updateSessionConfig(final String tenantId,
                                        final String environmentId,
                                        final Object body)
            throws AuthenticationException, ApiException {
        return put(tenantId, environmentId, "session-config", body);
    }

    /**
     * GET a settings suffix.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param suffix path suffix
     * @return settings envelope
     */
    private JsonNode get(final String tenantId,
                         final String environmentId,
                         final String suffix) {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId) + "/"
                        + suffix,
                null, null, JsonNode.class);
    }

    /**
     * PUT a settings suffix.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param suffix path suffix
     * @param body request body
     * @return settings envelope
     */
    private JsonNode put(final String tenantId,
                         final String environmentId,
                         final String suffix,
                         final Object body) {
        return client.request("PUT",
                EnvPaths.prefix(tenantId, environmentId) + "/"
                        + suffix,
                body, null, JsonNode.class);
    }
}
