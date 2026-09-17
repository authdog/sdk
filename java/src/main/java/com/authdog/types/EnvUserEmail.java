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
