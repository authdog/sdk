package com.authdog.resources;

import com.authdog.AuthdogClient;
import com.authdog.exceptions.ApiException;
import com.authdog.exceptions.AuthenticationException;
import com.fasterxml.jackson.databind.JsonNode;

/**
 * Personal access token operations.
 */
public final class PersonalAccessTokensResource {
    /**
     * Authdog client.
     */
    private final AuthdogClient client;

    /**
     * Create a personal access tokens helper.
     * @param clientParam Authdog client
     */
    public PersonalAccessTokensResource(
            final AuthdogClient clientParam) {
        this.client = clientParam;
    }

    /**
     * List personal access tokens.
     * @return tokens envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode list()
            throws AuthenticationException, ApiException {
        return client.request("GET", "/v1/personal-access-tokens",
                null, null, JsonNode.class);
    }

    /**
     * Create a personal access token.
     * @param body request body
     * @return created token envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode create(final Object body)
            throws AuthenticationException, ApiException {
        return client.request("POST", "/v1/personal-access-tokens",
                body, null, JsonNode.class);
    }

    /**
     * Revoke a personal access token.
     * @param tokenId token ID
     * @return revoke envelope
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public JsonNode revoke(final String tokenId)
            throws AuthenticationException, ApiException {
        return client.request("POST",
                "/v1/personal-access-tokens/" + tokenId + "/revoke",
                null, null, JsonNode.class);
    }
}
