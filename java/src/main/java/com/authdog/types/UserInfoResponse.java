package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Response from the /v1/userinfo endpoint.
 */
public final class UserInfoResponse {
    /**
     * Response metadata.
     */
    @JsonProperty("meta")
    private Meta meta;

    /**
     * Session information.
     */
    @JsonProperty("session")
    private Session session;

    /**
     * User information.
     */
    @JsonProperty("user")
    private User user;

    /**
     * Default constructor.
     */
    public UserInfoResponse() {
    }

    /**
     * Get response metadata.
     * @return Response metadata
     */
    public Meta getMeta() {
        return meta;
    }

    /**
     * Set response metadata.
     * @param metaParam Response metadata
     */
    public void setMeta(final Meta metaParam) {
        this.meta = metaParam;
    }

    /**
     * Get session information.
     * @return Session information
     */
    public Session getSession() {
        return session;
    }

    /**
     * Set session information.
     * @param sessionParam Session information
     */
    public void setSession(final Session sessionParam) {
        this.session = sessionParam;
    }

    /**
     * Get user information.
     * @return User information
     */
    public User getUser() {
        return user;
    }

    /**
     * Set user information.
     * @param userParam User information
     */
    public void setUser(final User userParam) {
        this.user = userParam;
    }
}
