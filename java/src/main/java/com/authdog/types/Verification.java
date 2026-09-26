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
 * Email verification status.
 */
public final class Verification {
    /**
     * Verification ID.
     */
    @JsonProperty("id")
    private String id;

    /**
     * Email address.
     */
    @JsonProperty("email")
    private String email;

    /**
     * Verification status.
     */
    @JsonProperty("verified")
    private boolean verified;

    /**
     * Creation timestamp.
     */
    @JsonProperty("createdAt")
    private String createdAt;

    /**
     * Last update timestamp.
     */
    @JsonProperty("updatedAt")
    private String updatedAt;

    /**
     * Default constructor.
     */
    public Verification() {
    }

    /**
     * Get verification ID.
     * @return Verification ID
     */
    public String getId() {
        return id;
    }

    /**
     * Set verification ID.
     * @param idParam Verification ID
     */
    public void setId(final String idParam) {
        this.id = idParam;
    }

    /**
     * Get email address.
     * @return Email address
     */
    public String getEmail() {
        return email;
    }

    /**
     * Set email address.
     * @param emailParam Email address
     */
    public void setEmail(final String emailParam) {
        this.email = emailParam;
    }

    /**
     * Check if email is verified.
     * @return Verification status
     */
    public boolean isVerified() {
        return verified;
    }

    /**
     * Set verification status.
     * @param verifiedParam Verification status
     */
    public void setVerified(final boolean verifiedParam) {
        this.verified = verifiedParam;
    }

    /**
     * Get creation timestamp.
     * @return Creation timestamp
     */
    public String getCreatedAt() {
        return createdAt;
    }

    /**
     * Set creation timestamp.
     * @param createdAtParam Creation timestamp
     */
    public void setCreatedAt(final String createdAtParam) {
        this.createdAt = createdAtParam;
    }

    /**
     * Get last update timestamp.
     * @return Last update timestamp
     */
    public String getUpdatedAt() {
        return updatedAt;
    }

    /**
     * Set last update timestamp.
     * @param updatedAtParam Last update timestamp
     */
    public void setUpdatedAt(final String updatedAtParam) {
        this.updatedAt = updatedAtParam;
    }
}
