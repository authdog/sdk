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
