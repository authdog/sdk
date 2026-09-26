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
 * User photo.
 */
public final class Photo {
    /**
     * Photo ID.
     */
    @JsonProperty("id")
    private String id;

    /**
     * Photo value/URL.
     */
    @JsonProperty("value")
    private String value;

    /**
     * Photo type.
     */
    @JsonProperty("type")
    private String type;

    /**
     * Default constructor.
     */
    public Photo() {
    }

    /**
     * Constructor with parameters.
     * @param idParam Photo ID
     * @param valueParam Photo value/URL
     * @param typeParam Photo type
     */
    public Photo(final String idParam, final String valueParam,
                 final String typeParam) {
        this.id = idParam;
        this.value = valueParam;
        this.type = typeParam;
    }

    /**
     * Get photo ID.
     * @return Photo ID
     */
    public String getId() {
        return id;
    }

    /**
     * Set photo ID.
     * @param idParam Photo ID
     */
    public void setId(final String idParam) {
        this.id = idParam;
    }

    /**
     * Get photo value/URL.
     * @return Photo value/URL
     */
    public String getValue() {
        return value;
    }

    /**
     * Set photo value/URL.
     * @param valueParam Photo value/URL
     */
    public void setValue(final String valueParam) {
        this.value = valueParam;
    }

    /**
     * Get photo type.
     * @return Photo type
     */
    public String getType() {
        return type;
    }

    /**
     * Set photo type.
     * @param typeParam Photo type
     */
    public void setType(final String typeParam) {
        this.type = typeParam;
    }
}
