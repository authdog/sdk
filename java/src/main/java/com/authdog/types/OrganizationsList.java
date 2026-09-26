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
