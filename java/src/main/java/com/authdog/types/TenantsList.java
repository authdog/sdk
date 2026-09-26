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
