package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Paginated list of organizations.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public final class OrganizationsList {
    /**
     * Organizations in this page.
     */
    @JsonProperty("organizations")
    private List<Organization> organizations;

    /**
     * Total number of organizations.
     */
    @JsonProperty("total")
    private int total;

    /**
     * Default constructor.
     */
    public OrganizationsList() {
    }

    /**
     * Get organizations.
     * @return Organizations, never null
     */
    public List<Organization> getOrganizations() {
        return organizations == null
                ? Collections.emptyList()
                : Collections.unmodifiableList(organizations);
    }

    /**
     * Set organizations.
     * @param organizationsParam Organizations
     */
    public void setOrganizations(
            final List<Organization> organizationsParam) {
        this.organizations = organizationsParam == null
                ? null : new ArrayList<>(organizationsParam);
    }

    /**
     * Get total count.
     * @return Total number of organizations
     */
    public int getTotal() {
        return total;
    }

    /**
     * Set total count.
     * @param totalParam Total number of organizations
     */
    public void setTotal(final int totalParam) {
        this.total = totalParam;
    }
}
