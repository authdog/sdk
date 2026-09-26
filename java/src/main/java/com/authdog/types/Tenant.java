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

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Tenant returned by management APIs.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public final class Tenant {
    /**
     * Tenant ID.
     */
    @JsonProperty("id")
    private String id;

    /**
     * Tenant name.
     */
    @JsonProperty("name")
    private String name;

    /**
     * Tenant description.
     */
    @JsonProperty("description")
    private String description;

    /**
     * Company name.
     */
    @JsonProperty("company")
    private String company;

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
     * Linked organization IDs.
     */
    @JsonProperty("organizationIds")
    private List<String> organizationIds;

    /**
     * Default constructor.
     */
    public Tenant() {
    }

    /**
     * Get tenant ID.
     * @return Tenant ID
     */
    public String getId() {
        return id;
    }

    /**
     * Set tenant ID.
     * @param idParam Tenant ID
     */
    public void setId(final String idParam) {
        this.id = idParam;
    }

    /**
     * Get tenant name.
     * @return Tenant name
     */
    public String getName() {
        return name;
    }

    /**
     * Set tenant name.
     * @param nameParam Tenant name
     */
    public void setName(final String nameParam) {
        this.name = nameParam;
    }

    /**
     * Get tenant description.
     * @return Tenant description
     */
    public String getDescription() {
        return description;
    }

    /**
     * Set tenant description.
     * @param descriptionParam Tenant description
     */
    public void setDescription(final String descriptionParam) {
        this.description = descriptionParam;
    }

    /**
     * Get company name.
     * @return Company name
     */
    public String getCompany() {
        return company;
    }

    /**
     * Set company name.
     * @param companyParam Company name
     */
    public void setCompany(final String companyParam) {
        this.company = companyParam;
    }

    /**
     * Check if the tenant is active.
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

    /**
     * Get linked organization IDs.
     * @return Organization IDs, never null
     */
    public List<String> getOrganizationIds() {
        return organizationIds == null
                ? Collections.emptyList()
                : Collections.unmodifiableList(organizationIds);
    }

    /**
     * Set linked organization IDs.
     * @param organizationIdsParam Organization IDs
     */
    public void setOrganizationIds(
            final List<String> organizationIdsParam) {
        this.organizationIds = organizationIdsParam == null
                ? null : new ArrayList<>(organizationIdsParam);
    }
}
