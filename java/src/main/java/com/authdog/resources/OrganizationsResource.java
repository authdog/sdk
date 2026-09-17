package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.authdog.types.OrganizationsList;
import com.fasterxml.jackson.databind.JsonNode;
import java.util.Map;

/**
 * Organization management operations.
 */
public final class OrganizationsResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create an organizations helper.
     * @param clientParam Authdog client
     */
    public OrganizationsResource(final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List organizations.
     * @return organizations list
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public OrganizationsList list()
            throws AuthenticationException, ApiException {
        return client.request("GET", "/v1/organizations", null, null,
                OrganizationsList.class);
    }

    /**
     * Create an organization.
     * @param body request body
     * @return created organization envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode create(final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST", "/v1/organizations", body, null,
                JsonNode.class);
    }

    /**
     * Get an organization.
     * @param organizationId organization ID
     * @return organization envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode get(final String organizationId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/organizations/" + organizationId, null, null,
                JsonNode.class);
    }

    /**
     * Update an organization.
     * @param organizationId organization ID
     * @param body request body
     * @return updated organization envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode update(final String organizationId, final Object body)
            throws AuthenticationException, ApiException {
        return client.request("PATCH",
                "/v1/organizations/" + organizationId, body, null,
                JsonNode.class);
    }

    /**
     * Delete an organization.
     * @param organizationId organization ID
     * @return delete envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode delete(final String organizationId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                "/v1/organizations/" + organizationId, null, null,
                JsonNode.class);
    }

    /**
     * Accept an organization invitation.
     * @param body request body
     * @return invitation envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode acceptInvitation(final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                "/v1/organizations/invitations/accept", body, null,
                JsonNode.class);
    }

    /**
     * Join an organization with an invitation code.
     * @param body request body
     * @return join envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode join(final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST", "/v1/organizations/join", body,
                null, JsonNode.class);
    }

    /**
     * List invitations for an organization.
     * @param organizationId organization ID
     * @return invitations envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listInvitations(final String organizationId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/organizations/" + organizationId + "/invitations",
                null, null, JsonNode.class);
    }

    /**
     * Create an organization invitation.
     * @param organizationId organization ID
     * @param body request body
     * @return invitation envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createInvitation(final String organizationId,
                                     final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                "/v1/organizations/" + organizationId + "/invitations",
                body, null, JsonNode.class);
    }

    /**
     * Cancel an organization invitation.
     * @param organizationId organization ID
     * @param invitationId invitation ID
     * @return cancel envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode cancelInvitation(final String organizationId,
                                     final String invitationId)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                "/v1/organizations/" + organizationId
                        + "/invitations/" + invitationId + "/cancel",
                null, null, JsonNode.class);
    }

    /**
     * Send an organization invite.
     * @param organizationId organization ID
     * @param body request body
     * @return invite envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode sendInvite(final String organizationId,
                               final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                "/v1/organizations/" + organizationId + "/invites",
                body, null, JsonNode.class);
    }

    /**
     * List organization members.
     * @param organizationId organization ID
     * @return members envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listMembers(final String organizationId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/organizations/" + organizationId + "/members",
                null, null, JsonNode.class);
    }

    /**
     * Remove an organization member.
     * @param organizationId organization ID
     * @param memberId member ID
     * @return remove envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode removeMember(final String organizationId,
                                 final String memberId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                "/v1/organizations/" + organizationId
                        + "/members/" + memberId,
                null, null, JsonNode.class);
    }

    /**
     * Enable or disable an organization member.
     * @param organizationId organization ID
     * @param memberId member ID
     * @param body request body
     * @return update envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode setMemberActive(final String organizationId,
                                    final String memberId,
                                    final Object body)
            throws AuthenticationException, ApiException {
        return client.request("PATCH",
                "/v1/organizations/" + organizationId
                        + "/members/" + memberId + "/active",
                body, null, JsonNode.class);
    }

    /**
     * Link a tenant to an organization.
     * @param organizationId organization ID
     * @param body request body
     * @return link envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode linkTenant(final String organizationId,
                               final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                "/v1/organizations/" + organizationId + "/tenants",
                body, null, JsonNode.class);
    }

    /**
     * Unlink a tenant from an organization.
     * @param organizationId organization ID
     * @param tenantId tenant ID
     * @return unlink envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode unlinkTenant(final String organizationId,
                                 final String tenantId)
            throws AuthenticationException, ApiException {
        return client.request("DELETE",
                "/v1/organizations/" + organizationId
                        + "/tenants/" + tenantId,
                null, null, JsonNode.class);
    }

    /**
     * List organization API keys.
     * @param organizationId organization ID
     * @return keys envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listKeys(final String organizationId)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/organizations/" + organizationId + "/keys",
                null, null, JsonNode.class);
    }

    /**
     * Create an organization API key.
     * @param organizationId organization ID
     * @param body request body
     * @return created key envelope, including a one-time secret
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode createKey(final String organizationId,
                              final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                "/v1/organizations/" + organizationId + "/keys",
                body, null, JsonNode.class);
    }

    /**
     * Revoke an organization API key.
     * @param organizationId organization ID
     * @param keyId key ID
     * @return revoke envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode revokeKey(final String organizationId,
                              final String keyId)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                "/v1/organizations/" + organizationId + "/keys/"
                        + keyId + "/revoke",
                null, null, JsonNode.class);
    }

    /**
     * Rotate an organization API key.
     * @param organizationId organization ID
     * @param keyId key ID
     * @return rotate envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode rotateKey(final String organizationId,
                              final String keyId)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                "/v1/organizations/" + organizationId + "/keys/"
                        + keyId + "/rotate",
                null, null, JsonNode.class);
    }

    /**
     * Replace the tenants an organization key can access.
     * @param organizationId organization ID
     * @param keyId key ID
     * @param body request body
     * @return update envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode updateKeyTenants(final String organizationId,
                                     final String keyId,
                                     final Object body)
            throws AuthenticationException, ApiException {
        return client.request("PUT",
                "/v1/organizations/" + organizationId + "/keys/"
                        + keyId + "/tenants",
                body, null, JsonNode.class);
    }

    /**
     * List organization audit logs.
     * @param organizationId organization ID
     * @return logs envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listAuditLogs(final String organizationId)
            throws AuthenticationException, ApiException {
        return listAuditLogs(organizationId, null);
    }

    /**
     * List organization audit logs with caller query parameters.
     * @param organizationId organization ID
     * @param params optional query parameters
     * @return logs envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode listAuditLogs(final String organizationId,
                                  final Map<String, String> params)
            throws AuthenticationException, ApiException {
        return client.request("GET",
                "/v1/organizations/" + organizationId
                        + "/audit/logs",
                null, params, JsonNode.class);
    }
}
