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
