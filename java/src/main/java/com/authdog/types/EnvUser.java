package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Directory user in an environment.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public final class EnvUser {
    /**
     * User ID.
     */
    @JsonProperty("id")
    private String id;

    /**
     * Environment ID.
     */
    @JsonProperty("environmentId")
    private String environmentId;

    /**
     * External user ID.
     */
    @JsonProperty("externalId")
    private String externalId;

    /**
     * Username.
     */
    @JsonProperty("userName")
    private String userName;

    /**
     * Display name.
     */
    @JsonProperty("displayName")
    private String displayName;

    /**
     * Nickname.
     */
    @JsonProperty("nickName")
    private String nickName;

    /**
     * Profile URL.
     */
    @JsonProperty("profileUrl")
    private String profileUrl;

    /**
     * Active status.
     */
    @JsonProperty("active")
    private Boolean active;

    /**
     * Whether the user must change password.
     */
    @JsonProperty("changePw")
    private Boolean changePw;

    /**
     * Identity provider.
     */
    @JsonProperty("provider")
    private String provider;

    /**
     * Email addresses.
     */
    @JsonProperty("emails")
    private List<EnvUserEmail> emails;

    /**
     * Last login timestamp.
     */
    @JsonProperty("lastLogin")
    private String lastLogin;

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
    public EnvUser() {
    }

    /**
     * Get user ID.
     * @return User ID
     */
    public String getId() {
        return id;
    }

    /**
     * Set user ID.
     * @param idParam User ID
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
     * Get external user ID.
     * @return External user ID
     */
    public String getExternalId() {
        return externalId;
    }

    /**
     * Set external user ID.
     * @param externalIdParam External user ID
     */
    public void setExternalId(final String externalIdParam) {
        this.externalId = externalIdParam;
    }

    /**
     * Get username.
     * @return Username
     */
    public String getUserName() {
        return userName;
    }

    /**
     * Set username.
     * @param userNameParam Username
     */
    public void setUserName(final String userNameParam) {
        this.userName = userNameParam;
    }

    /**
     * Get display name.
     * @return Display name
     */
    public String getDisplayName() {
        return displayName;
    }

    /**
     * Set display name.
     * @param displayNameParam Display name
     */
    public void setDisplayName(final String displayNameParam) {
        this.displayName = displayNameParam;
    }

    /**
     * Get nickname.
     * @return Nickname
     */
    public String getNickName() {
        return nickName;
    }

    /**
     * Set nickname.
     * @param nickNameParam Nickname
     */
    public void setNickName(final String nickNameParam) {
        this.nickName = nickNameParam;
    }

    /**
     * Get profile URL.
     * @return Profile URL
     */
    public String getProfileUrl() {
        return profileUrl;
    }

    /**
     * Set profile URL.
     * @param profileUrlParam Profile URL
     */
    public void setProfileUrl(final String profileUrlParam) {
        this.profileUrl = profileUrlParam;
    }

    /**
     * Get active status.
     * @return Active status
     */
    public Boolean getActive() {
        return active;
    }

    /**
     * Set active status.
     * @param activeParam Active status
     */
    public void setActive(final Boolean activeParam) {
        this.active = activeParam;
    }

    /**
     * Get change-password flag.
     * @return Whether the user must change password
     */
    public Boolean getChangePw() {
        return changePw;
    }

    /**
     * Set change-password flag.
     * @param changePwParam Whether the user must change password
     */
    public void setChangePw(final Boolean changePwParam) {
        this.changePw = changePwParam;
    }

    /**
     * Get identity provider.
     * @return Identity provider
     */
    public String getProvider() {
        return provider;
    }

    /**
     * Set identity provider.
     * @param providerParam Identity provider
     */
    public void setProvider(final String providerParam) {
        this.provider = providerParam;
    }

    /**
     * Get email addresses.
     * @return Email addresses, never null
     */
    public List<EnvUserEmail> getEmails() {
        return emails == null
                ? Collections.emptyList()
                : Collections.unmodifiableList(emails);
    }

    /**
     * Set email addresses.
     * @param emailsParam Email addresses
     */
    public void setEmails(final List<EnvUserEmail> emailsParam) {
        this.emails = emailsParam == null
                ? null : new ArrayList<>(emailsParam);
    }

    /**
     * Get last login timestamp.
     * @return Last login timestamp
     */
    public String getLastLogin() {
        return lastLogin;
    }

    /**
     * Set last login timestamp.
     * @param lastLoginParam Last login timestamp
     */
    public void setLastLogin(final String lastLoginParam) {
        this.lastLogin = lastLoginParam;
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
