package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Project environment.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public final class Environment {
    /**
     * Environment ID.
     */
    @JsonProperty("id")
    private String id;

    /**
     * Environment name.
     */
    @JsonProperty("name")
    private String name;

    /**
     * Environment description.
     */
    @JsonProperty("description")
    private String description;

    /**
     * Traffic weight.
     */
    @JsonProperty("weight")
    private Double weight;

    /**
     * Whether the environment is live.
     */
    @JsonProperty("isLive")
    private Boolean live;

    /**
     * Whether this is the default environment.
     */
    @JsonProperty("isDefault")
    private Boolean defaultEnvironment;

    /**
     * Creation timestamp.
     */
    @JsonProperty("createdAt")
    private String createdAt;

    /**
     * Last update timestamp.
     */
    @JsonProperty("updatedAt")
    private String updatedAt;

    /**
     * Default constructor.
     */
    public Environment() {
    }

    /**
     * Get environment ID.
     * @return Environment ID
     */
    public String getId() {
        return id;
    }

    /**
     * Set environment ID.
     * @param idParam Environment ID
     */
    public void setId(final String idParam) {
        this.id = idParam;
    }

    /**
     * Get environment name.
     * @return Environment name
     */
    public String getName() {
        return name;
    }

    /**
     * Set environment name.
     * @param nameParam Environment name
     */
    public void setName(final String nameParam) {
        this.name = nameParam;
    }

    /**
     * Get environment description.
     * @return Environment description
     */
    public String getDescription() {
        return description;
    }

    /**
     * Set environment description.
     * @param descriptionParam Environment description
     */
    public void setDescription(final String descriptionParam) {
        this.description = descriptionParam;
    }

    /**
     * Get traffic weight.
     * @return Traffic weight
     */
    public Double getWeight() {
        return weight;
    }

    /**
     * Set traffic weight.
     * @param weightParam Traffic weight
     */
    public void setWeight(final Double weightParam) {
        this.weight = weightParam;
    }

    /**
     * Get live flag.
     * @return Whether the environment is live
     */
    public Boolean getLive() {
        return live;
    }

    /**
     * Set live flag.
     * @param liveParam Whether the environment is live
     */
    public void setLive(final Boolean liveParam) {
        this.live = liveParam;
    }

    /**
     * Get default-environment flag.
     * @return Whether this is the default environment
     */
    public Boolean getDefaultEnvironment() {
        return defaultEnvironment;
    }

    /**
     * Set default-environment flag.
     * @param defaultEnvironmentParam Whether this is the default
     *     environment
     */
    public void setDefaultEnvironment(
            final Boolean defaultEnvironmentParam) {
        this.defaultEnvironment = defaultEnvironmentParam;
    }

    /**
     * Get creation timestamp.
     * @return Creation timestamp
     */
    public String getCreatedAt() {
        return createdAt;
    }

    /**
     * Set creation timestamp.
     * @param createdAtParam Creation timestamp
     */
    public void setCreatedAt(final String createdAtParam) {
        this.createdAt = createdAtParam;
    }

    /**
     * Get last update timestamp.
     * @return Last update timestamp
     */
    public String getUpdatedAt() {
        return updatedAt;
    }

    /**
     * Set last update timestamp.
     * @param updatedAtParam Last update timestamp
     */
    public void setUpdatedAt(final String updatedAtParam) {
        this.updatedAt = updatedAtParam;
    }
}
