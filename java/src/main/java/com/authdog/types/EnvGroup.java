package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Directory group in an environment.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public final class EnvGroup {
    /**
     * Group ID.
     */
    @JsonProperty("id")
    private String id;

    /**
     * Environment ID.
     */
    @JsonProperty("environmentId")
    private String environmentId;

    /**
     * Group name.
     */
    @JsonProperty("name")
    private String name;

    /**
     * URL-safe slug.
     */
    @JsonProperty("slug")
    private String slug;

    /**
     * Group description.
     */
    @JsonProperty("description")
    private String description;

    /**
     * Number of members.
     */
    @JsonProperty("memberCount")
    private int memberCount;

    /**
     * When the current user joined, if present.
     */
    @JsonProperty("joinedAt")
    private String joinedAt;

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
    public EnvGroup() {
    }

    /**
     * Get group ID.
     * @return Group ID
     */
    public String getId() {
        return id;
    }

    /**
     * Set group ID.
     * @param idParam Group ID
     */
    public void setId(final String idParam) {
        this.id = idParam;
    }

    /**
     * Get environment ID.
     * @return Environment ID
     */
    public String getEnvironmentId() {
        return environmentId;
    }

    /**
     * Set environment ID.
     * @param environmentIdParam Environment ID
     */
    public void setEnvironmentId(final String environmentIdParam) {
        this.environmentId = environmentIdParam;
    }

    /**
     * Get group name.
     * @return Group name
     */
    public String getName() {
        return name;
    }

    /**
     * Set group name.
     * @param nameParam Group name
     */
    public void setName(final String nameParam) {
        this.name = nameParam;
    }

    /**
     * Get slug.
     * @return URL-safe slug
     */
    public String getSlug() {
        return slug;
    }

    /**
     * Set slug.
     * @param slugParam URL-safe slug
     */
    public void setSlug(final String slugParam) {
        this.slug = slugParam;
    }

    /**
     * Get group description.
     * @return Group description
     */
    public String getDescription() {
        return description;
    }

    /**
     * Set group description.
     * @param descriptionParam Group description
     */
    public void setDescription(final String descriptionParam) {
        this.description = descriptionParam;
    }

    /**
     * Get member count.
     * @return Number of members
     */
    public int getMemberCount() {
        return memberCount;
    }

    /**
     * Set member count.
     * @param memberCountParam Number of members
     */
    public void setMemberCount(final int memberCountParam) {
        this.memberCount = memberCountParam;
    }

    /**
     * Get joined-at timestamp.
     * @return When the current user joined
     */
    public String getJoinedAt() {
        return joinedAt;
    }

    /**
     * Set joined-at timestamp.
     * @param joinedAtParam When the current user joined
     */
    public void setJoinedAt(final String joinedAtParam) {
        this.joinedAt = joinedAtParam;
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
