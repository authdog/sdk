package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * User name information.
 */
public final class Names {
    /**
     * Name ID.
     */
    @JsonProperty("id")
    private String id;

    /**
     * Formatted name.
     */
    @JsonProperty("formatted")
    private String formatted;

    /**
     * Family name.
     */
    @JsonProperty("familyName")
    private String familyName;

    /**
     * Given name.
     */
    @JsonProperty("givenName")
    private String givenName;

    /**
     * Middle name.
     */
    @JsonProperty("middleName")
    private String middleName;

    /**
     * Honorific prefix.
     */
    @JsonProperty("honorificPrefix")
    private String honorificPrefix;

    /**
     * Honorific suffix.
     */
    @JsonProperty("honorificSuffix")
    private String honorificSuffix;

    /**
     * Default constructor.
     */
    public Names() {
    }
    /**
     * Get name ID.
     * @return Name ID
     */
    public String getId() {
        return id;
    }

    /**
     * Set name ID.
     * @param idParam Name ID
     */
    public void setId(final String idParam) {
        this.id = idParam;
    }

    /**
     * Get formatted name.
     * @return Formatted name
     */
    public String getFormatted() {
        return formatted;
    }

    /**
     * Set formatted name.
     * @param formattedParam Formatted name
     */
    public void setFormatted(final String formattedParam) {
        this.formatted = formattedParam;
    }

    /**
     * Get family name.
     * @return Family name
     */
    public String getFamilyName() {
        return familyName;
    }

    /**
     * Set family name.
     * @param familyNameParam Family name
     */
    public void setFamilyName(final String familyNameParam) {
        this.familyName = familyNameParam;
    }

    /**
     * Get given name.
     * @return Given name
     */
    public String getGivenName() {
        return givenName;
    }

    /**
     * Set given name.
     * @param givenNameParam Given name
     */
    public void setGivenName(final String givenNameParam) {
        this.givenName = givenNameParam;
    }

    /**
     * Get middle name.
     * @return Middle name
     */
    public String getMiddleName() {
        return middleName;
    }

    /**
     * Set middle name.
     * @param middleNameParam Middle name
     */
    public void setMiddleName(final String middleNameParam) {
        this.middleName = middleNameParam;
    }

    /**
     * Get honorific prefix.
     * @return Honorific prefix
     */
    public String getHonorificPrefix() {
        return honorificPrefix;
    }

    /**
     * Set honorific prefix.
     * @param honorificPrefixParam Honorific prefix
     */
    public void setHonorificPrefix(final String honorificPrefixParam) {
        this.honorificPrefix = honorificPrefixParam;
    }

    /**
     * Get honorific suffix.
     * @return Honorific suffix
     */
    public String getHonorificSuffix() {
        return honorificSuffix;
    }

    /**
     * Set honorific suffix.
     * @param honorificSuffixParam Honorific suffix
     */
    public void setHonorificSuffix(final String honorificSuffixParam) {
        this.honorificSuffix = honorificSuffixParam;
    }
}
