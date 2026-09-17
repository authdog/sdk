package com.authdog.resources;

/**
 * Environment-scoped management path helpers.
 */
final class EnvPaths {
    private EnvPaths() {
    }

    /**
     * Build {@code /v1/tenants/{tenant}/environments/{environment}}.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return path prefix
     */
    static String prefix(final String tenantId,
                         final String environmentId) {
        return "/v1/tenants/" + tenantId + "/environments/"
                + environmentId;
    }
}
