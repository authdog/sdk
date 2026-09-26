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
 * Environment billing operations.
 */
public final class BillingResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a billing helper.
     * @param clientParam Authdog client
     */
    public BillingResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List billing features.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return features envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listFeatures(final String tenantId,
                                 final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/billing/features",
                null, null, JsonNode.class);
    }

    /**
     * Create or update a billing feature.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return feature envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode saveFeature(final String tenantId,
                                final String environmentId,
                                final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/billing/features",
                body, null, JsonNode.class);
    }

    /**
     * Delete a billing feature.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param featureId feature ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteFeature(final String tenantId,
                                  final String environmentId,
                                  final String featureId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/billing/features/" + featureId,
                null, null, JsonNode.class);
    }

    /**
     * List billing plans.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @return plans envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listPlans(final String tenantId,
                              final String environmentId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/billing/plans",
                null, null, JsonNode.class);
    }

    /**
     * Create or update a billing plan.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param body request body
     * @return plan envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode savePlan(final String tenantId,
                             final String environmentId,
                             final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/billing/plans",
                body, null, JsonNode.class);
    }

    /**
     * Delete a billing plan.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param planId plan ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deletePlan(final String tenantId,
                               final String environmentId,
                               final String planId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/billing/plans/" + planId,
                null, null, JsonNode.class);
    }

    /**
     * Sync a billing plan with Stripe.
     * @param tenantId tenant ID
     * @param environmentId environment ID
     * @param planId plan ID
     * @return sync envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode syncStripe(final String tenantId,
                               final String environmentId,
                               final String planId)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                EnvPaths.prefix(tenantId, environmentId)
                        + "/billing/plans/" + planId + "/sync-stripe",
                null, null, JsonNode.class);
    }
}
