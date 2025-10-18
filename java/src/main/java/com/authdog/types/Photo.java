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
