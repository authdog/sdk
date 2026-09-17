package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Organization returned by management APIs.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public final class Organization {
    /**
     * Organization ID.
     */
    @JsonProperty("id")
    private String id;

    /**
     * Organization name.
     */
    @JsonProperty("name")
    private String name;

    /**
     * Organization description.
     */
    @JsonProperty("description")
    private String description;

    /**
     * Billing email.
     */
    @JsonProperty("billingEmail")
    private String billingEmail;

    /**
     * Logo URI.
     */
    @JsonProperty("logoUri")
    private String logoUri;

    /**
     * Active status.
     */
    @JsonProperty("active")
    private boolean active;

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
    public Organization() {
    }

    /**
     * Get organization ID.
     * @return Organization ID
     */
    public String getId() {
        return id;
    }

    /**
     * Set organization ID.
     * @param idParam Organization ID
     */
    public void setId(final String idParam) {
        this.id = idParam;
    }

    /**
     * Get organization name.
     * @return Organization name
     */
    public String getName() {
        return name;
    }

    /**
     * Set organization name.
     * @param nameParam Organization name
     */
    public void setName(final String nameParam) {
        this.name = nameParam;
    }

    /**
     * Get organization description.
     * @return Organization description
     */
    public String getDescription() {
        return description;
    }

    /**
     * Set organization description.
     * @param descriptionParam Organization description
     */
    public void setDescription(final String descriptionParam) {
        this.description = descriptionParam;
    }

    /**
     * Get billing email.
     * @return Billing email
     */
    public String getBillingEmail() {
        return billingEmail;
    }

    /**
     * Set billing email.
     * @param billingEmailParam Billing email
     */
    public void setBillingEmail(final String billingEmailParam) {
        this.billingEmail = billingEmailParam;
    }

    /**
     * Get logo URI.
     * @return Logo URI
     */
    public String getLogoUri() {
        return logoUri;
    }

    /**
     * Set logo URI.
     * @param logoUriParam Logo URI
     */
    public void setLogoUri(final String logoUriParam) {
        this.logoUri = logoUriParam;
    }

    /**
     * Check if the organization is active.
     * @return Active status
     */
    public boolean isActive() {
        return active;
    }

    /**
     * Set active status.
     * @param activeParam Active status
     */
    public void setActive(final boolean activeParam) {
        this.active = activeParam;
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
