/*
 * MIT License
 *
 * Copyright (c) 2025 Authdog
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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
