package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * User email.
 */
public final class Email {
    /**
     * Email ID.
     */
    @JsonProperty("id")
    private String id;

    /**
     * Email value/address.
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
    public Email() {
    }

    /**
     * Constructor with parameters.
     * @param idParam Email ID
     * @param valueParam Email value/address
     * @param typeParam Email type
     */
    public Email(final String idParam, final String valueParam,
                 final String typeParam) {
        this.id = idParam;
        this.value = valueParam;
        this.type = typeParam;
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
     * Get email value/address.
     * @return Email value/address
     */
    public String getValue() {
        return value;
    }

    /**
     * Set email value/address.
     * @param valueParam Email value/address
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
