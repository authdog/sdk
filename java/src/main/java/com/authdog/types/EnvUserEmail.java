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
 * Email on a directory user.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public final class EnvUserEmail {
    /**
     * Email ID.
     */
    @JsonProperty("id")
    private String id;

    /**
     * Email address.
     */
    @JsonProperty("value")
    private String value;

    /**
     * Email type.
     */
    @JsonProperty("type")
    private String type;

    /**
     * Default constructor.
     */
    public EnvUserEmail() {
    }

    /**
     * Get email ID.
     * @return Email ID
     */
    public String getId() {
        return id;
    }

    /**
     * Set email ID.
     * @param idParam Email ID
     */
    public void setId(final String idParam) {
        this.id = idParam;
    }

    /**
     * Get email address.
     * @return Email address
     */
    public String getValue() {
        return value;
    }

    /**
     * Set email address.
     * @param valueParam Email address
     */
    public void setValue(final String valueParam) {
        this.value = valueParam;
    }

    /**
     * Get email type.
     * @return Email type
     */
    public String getType() {
        return type;
    }

    /**
     * Set email type.
     * @param typeParam Email type
     */
    public void setType(final String typeParam) {
        this.type = typeParam;
    }
}
