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
