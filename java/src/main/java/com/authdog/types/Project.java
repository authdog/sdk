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

/**
 * Project (application) summary.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public final class Project {
    /**
     * Project ID.
     */
    @JsonProperty("id")
    private String id;

    /**
     * Project name.
     */
    @JsonProperty("name")
    private String name;

    /**
     * Project description.
     */
    @JsonProperty("description")
    private String description;

    /**
     * Default constructor.
     */
    public Project() {
    }

    /**
     * Get project ID.
     * @return Project ID
     */
    public String getId() {
        return id;
    }

    /**
     * Set project ID.
     * @param idParam Project ID
     */
    public void setId(final String idParam) {
        this.id = idParam;
    }

    /**
     * Get project name.
     * @return Project name
     */
    public String getName() {
        return name;
    }

    /**
     * Set project name.
     * @param nameParam Project name
     */
    public void setName(final String nameParam) {
        this.name = nameParam;
    }

    /**
     * Get project description.
     * @return Project description
     */
    public String getDescription() {
        return description;
    }

    /**
     * Set project description.
     * @param descriptionParam Project description
     */
    public void setDescription(final String descriptionParam) {
        this.description = descriptionParam;
    }
}
