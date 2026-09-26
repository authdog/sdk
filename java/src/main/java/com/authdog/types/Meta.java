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
 * Metadata in the response.
 */
public final class Meta {
    /**
     * Response code.
     */
    @JsonProperty("code")
    private int code;

    /**
     * Response message.
     */
    @JsonProperty("message")
    private String message;

    /**
     * Default constructor.
     */
    public Meta() {
    }

    /**
     * Constructor with parameters.
     * @param codeParam Response code
     * @param messageParam Response message
     */
    public Meta(final int codeParam, final String messageParam) {
        this.code = codeParam;
        this.message = messageParam;
    }

    /**
     * Get the response code.
     * @return Response code
     */
    public int getCode() {
        return code;
    }

    /**
     * Set the response code.
     * @param codeParam Response code
     */
    public void setCode(final int codeParam) {
        this.code = codeParam;
    }

    /**
     * Get the response message.
     * @return Response message
     */
    public String getMessage() {
        return message;
    }

    /**
     * Set the response message.
     * @param messageParam Response message
     */
    public void setMessage(final String messageParam) {
        this.message = messageParam;
    }
}
