package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.authdog.types.TenantsList;
import com.fasterxml.jackson.databind.JsonNode;
import java.util.Map;

/**
 * Tenant management operations.
 */
public final class TenantsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a tenants helper.
     * @param clientParam Authdog client
     */
    public TenantsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List tenants.
     * @return tenants list
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public TenantsList list()
            throws AuthenticationException, ApiException {
        return list(null);
    }

    /**
     * List tenants, optionally filtered by organization.
     * @param organizationId organization ID filter
     * @return tenants list
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public TenantsList list(final String organizationId)
            throws AuthenticationException, ApiException {
        final Map<String, String> params = QueryParams.create();
        QueryParams.put(params, "organization_id", organizationId);
        return client.request("GET", "/v1/tenants", null,
                QueryParams.orNull(params), TenantsList.class);
    }

    /**
     * Create a tenant.
     * @param body request body
     * @return created tenant envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode create(final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST", "/v1/tenants", body, null,
                JsonNode.class);
    }

    /**
     * Join a tenant with an invitation code.
     * @param body request body
     * @return join envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode join(final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST", "/v1/tenants/join", body, null,
                JsonNode.class);
    }

    /**
     * Get a tenant.
     * @param tenantId tenant ID
     * @return tenant envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode get(final String tenantId)
            throws AuthenticationException, ApiException {
        return get(tenantId, null);
    }

    /**
     * Get a tenant, optionally scoped by organization.
     * @param tenantId tenant ID
     * @param organizationId organization ID filter
     * @return tenant envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode get(final String tenantId,
                        final String organizationId)
            throws AuthenticationException, ApiException {
        final Map<String, String> params = QueryParams.create();
        QueryParams.put(params, "organization_id", organizationId);
        return client.request("GET", "/v1/tenants/" + tenantId, null,
                QueryParams.orNull(params), JsonNode.class);
    }

    /**
     * Update a tenant.
     * @param tenantId tenant ID
     * @param body request body
     * @return updated tenant envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode update(final String tenantId, final Object body)
            throws AuthenticationException, ApiException {
        return client.request("PATCH", "/v1/tenants/" + tenantId, body,
                null, JsonNode.class);
    }

    /**
     * Delete a tenant.
     * @param tenantId tenant ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode delete(final String tenantId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE", "/v1/tenants/" + tenantId, null,
                null, JsonNode.class);
    }

    /**
     * List tenant domains.
     * @param tenantId tenant ID
     * @return domains envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listDomains(final String tenantId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/tenants/" + tenantId + "/domains", null, null,
                JsonNode.class);
    }

    /**
     * Create a tenant domain.
     * @param tenantId tenant ID
     * @param body request body
     * @return domain envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createDomain(final String tenantId,
                                 final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                "/v1/tenants/" + tenantId + "/domains", body, null,
                JsonNode.class);
    }

    /**
     * Delete a tenant domain.
     * @param tenantId tenant ID
     * @param domainId domain ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteDomain(final String tenantId,
                                 final String domainId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                "/v1/tenants/" + tenantId + "/domains/" + domainId,
                null, null, JsonNode.class);
    }

    /**
     * Retry tenant domain verification.
     * @param tenantId tenant ID
     * @param domainId domain ID
     * @return retry envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode retryDomain(final String tenantId,
                                final String domainId)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                "/v1/tenants/" + tenantId + "/domains/" + domainId
                        + "/retry",
                null, null, JsonNode.class);
    }

    /**
     * Invite a user to the tenant.
     * @param tenantId tenant ID
     * @param body request body
     * @return invite envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode sendInvite(final String tenantId, final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                "/v1/tenants/" + tenantId + "/invites", body, null,
                JsonNode.class);
    }

    /**
     * List tenant projects.
     * @param tenantId tenant ID
     * @return projects envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listProjects(final String tenantId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/tenants/" + tenantId + "/projects", null, null,
                JsonNode.class);
    }

    /**
     * List tenant seats.
     * @param tenantId tenant ID
     * @return seats envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listSeats(final String tenantId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/tenants/" + tenantId + "/seats", null, null,
                JsonNode.class);
    }

    /**
     * Update a tenant seat.
     * @param tenantId tenant ID
     * @param seatId seat ID
     * @param body request body
     * @return seat envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode updateSeat(final String tenantId,
                               final String seatId, final Object body)
            throws AuthenticationException, ApiException {
        return client.request("PATCH",
                "/v1/tenants/" + tenantId + "/seats/" + seatId, body,
                null, JsonNode.class);
    }

    /**
     * Delete a tenant seat.
     * @param tenantId tenant ID
     * @param seatId seat ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode deleteSeat(final String tenantId,
                               final String seatId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                "/v1/tenants/" + tenantId + "/seats/" + seatId, null,
                null, JsonNode.class);
    }
}
