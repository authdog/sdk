package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Paginated list of tenants.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public final class TenantsList {
    /**
     * Tenants in this page.
     */
    @JsonProperty("tenants")
    private List<Tenant> tenants;

    /**
     * Total number of tenants.
     */
    @JsonProperty("total")
    private int total;

    /**
     * Default constructor.
     */
    public TenantsList() {
    }

    /**
     * Get tenants.
     * @return Tenants, never null
     */
    public List<Tenant> getTenants() {
        return tenants == null
                ? Collections.emptyList()
                : Collections.unmodifiableList(tenants);
    }

    /**
     * Set tenants.
     * @param tenantsParam Tenants
     */
    public void setTenants(final List<Tenant> tenantsParam) {
        this.tenants = tenantsParam == null
                ? null : new ArrayList<>(tenantsParam);
    }

    /**
     * Get total count.
     * @return Total number of tenants
     */
    public int getTotal() {
        return total;
    }

    /**
     * Set total count.
     * @param totalParam Total number of tenants
     */
    public void setTotal(final int totalParam) {
        this.total = totalParam;
    }
}
