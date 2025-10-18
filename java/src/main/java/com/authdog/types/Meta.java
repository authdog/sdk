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
