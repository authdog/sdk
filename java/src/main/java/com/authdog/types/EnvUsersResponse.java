package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Directory user list envelope.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public final class EnvUsersResponse {
    /**
     * Users in the environment.
     */
    @JsonProperty("users")
    private List<EnvUser> users;

    /**
     * Default constructor.
     */
    public EnvUsersResponse() {
    }

    /**
     * Get users.
     * @return Users, never null
     */
    public List<EnvUser> getUsers() {
        return users == null
                ? Collections.emptyList()
                : Collections.unmodifiableList(users);
    }

    /**
     * Set users.
     * @param usersParam Users
     */
    public void setUsers(final List<EnvUser> usersParam) {
        this.users = usersParam == null
                ? null : new ArrayList<>(usersParam);
    }
}
