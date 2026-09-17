package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Directory group list envelope.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public final class EnvGroupsResponse {
    /**
     * Groups in the environment.
     */
    @JsonProperty("groups")
    private List<EnvGroup> groups;

    /**
     * Default constructor.
     */
    public EnvGroupsResponse() {
    }

    /**
     * Get groups.
     * @return Groups, never null
     */
    public List<EnvGroup> getGroups() {
        return groups == null
                ? Collections.emptyList()
                : Collections.unmodifiableList(groups);
    }

    /**
     * Set groups.
     * @param groupsParam Groups
     */
    public void setGroups(final List<EnvGroup> groupsParam) {
        this.groups = groupsParam == null
                ? null : new ArrayList<>(groupsParam);
    }
}
