package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

/**
 * User information.
 */
public final class User {
    /**
     * User ID.
     */
    @JsonProperty("id")
    private String id;

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
     * User title.
     */
    @JsonProperty("title")
    private String title;

    /**
     * User type.
     */
    @JsonProperty("userType")
    private String userType;

    /**
     * Preferred language.
     */
    @JsonProperty("preferredLanguage")
    private String preferredLanguage;

    /**
     * Locale.
     */
    @JsonProperty("locale")
    private String locale;

    /**
     * Timezone.
     */
    @JsonProperty("timezone")
    private String timezone;

    /**
     * Active status.
     */
    @JsonProperty("active")
    private boolean active;

    /**
     * Name information.
     */
    @JsonProperty("names")
    private Names names;

    /**
     * User photos.
     */
    @JsonProperty("photos")
    private List<Photo> photos;

    /**
     * Phone numbers.
     */
    @JsonProperty("phoneNumbers")
    private List<Object> phoneNumbers;

    /**
     * Addresses.
     */
    @JsonProperty("addresses")
    private List<Object> addresses;

    /**
     * Email addresses.
     */
    @JsonProperty("emails")
    private List<Email> emails;

    /**
     * Verification status.
     */
    @JsonProperty("verifications")
    private List<Verification> verifications;

    /**
     * Provider.
     */
    @JsonProperty("provider")
    private String provider;

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
     * Environment ID.
     */
    @JsonProperty("environmentId")
    private String environmentId;

    /**
     * Default constructor.
     */
    public User() {
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
     * Get user title.
     * @return User title
     */
    public String getTitle() {
        return title;
    }

    /**
     * Set user title.
     * @param titleParam User title
     */
    public void setTitle(final String titleParam) {
        this.title = titleParam;
    }

    /**
     * Get user type.
     * @return User type
     */
    public String getUserType() {
        return userType;
    }

    /**
     * Set user type.
     * @param userTypeParam User type
     */
    public void setUserType(final String userTypeParam) {
        this.userType = userTypeParam;
    }

    /**
     * Get preferred language.
     * @return Preferred language
     */
    public String getPreferredLanguage() {
        return preferredLanguage;
    }

    /**
     * Set preferred language.
     * @param preferredLanguageParam Preferred language
     */
    public void setPreferredLanguage(final String preferredLanguageParam) {
        this.preferredLanguage = preferredLanguageParam;
    }

    /**
     * Get locale.
     * @return Locale
     */
    public String getLocale() {
        return locale;
    }

    /**
     * Set locale.
     * @param localeParam Locale
     */
    public void setLocale(final String localeParam) {
        this.locale = localeParam;
    }

    /**
     * Get timezone.
     * @return Timezone
     */
    public String getTimezone() {
        return timezone;
    }

    /**
     * Set timezone.
     * @param timezoneParam Timezone
     */
    public void setTimezone(final String timezoneParam) {
        this.timezone = timezoneParam;
    }

    /**
     * Check if user is active.
     * @return Active status
     */
    public boolean isActive() {
        return active;
    }

    /**
     * Set active status.
     * @param activeParam Active status
     */
    public void setActive(final boolean activeParam) {
        this.active = activeParam;
    }

    /**
     * Get name information.
     * @return Name information
     */
    public Names getNames() {
        return names;
    }

    /**
     * Set name information.
     * @param namesParam Name information
     */
    public void setNames(final Names namesParam) {
        this.names = namesParam;
    }

    /**
     * Get user photos.
     * @return User photos
     */
    public List<Photo> getPhotos() {
        return photos;
    }

    /**
     * Set user photos.
     * @param photosParam User photos
     */
    public void setPhotos(final List<Photo> photosParam) {
        this.photos = photosParam;
    }

    /**
     * Get phone numbers.
     * @return Phone numbers
     */
    public List<Object> getPhoneNumbers() {
        return phoneNumbers;
    }

    /**
     * Set phone numbers.
     * @param phoneNumbersParam Phone numbers
     */
    public void setPhoneNumbers(final List<Object> phoneNumbersParam) {
        this.phoneNumbers = phoneNumbersParam;
    }

    /**
     * Get addresses.
     * @return Addresses
     */
    public List<Object> getAddresses() {
        return addresses;
    }

    /**
     * Set addresses.
     * @param addressesParam Addresses
     */
    public void setAddresses(final List<Object> addressesParam) {
        this.addresses = addressesParam;
    }

    /**
     * Get email addresses.
     * @return Email addresses
     */
    public List<Email> getEmails() {
        return emails;
    }

    /**
     * Set email addresses.
     * @param emailsParam Email addresses
     */
    public void setEmails(final List<Email> emailsParam) {
        this.emails = emailsParam;
    }

    /**
     * Get verification status.
     * @return Verification status
     */
    public List<Verification> getVerifications() {
        return verifications;
    }

    /**
     * Set verification status.
     * @param verificationsParam Verification status
     */
    public void setVerifications(final List<Verification> verificationsParam) {
        this.verifications = verificationsParam;
    }

    /**
     * Get provider.
     * @return Provider
     */
    public String getProvider() {
        return provider;
    }

    /**
     * Set provider.
     * @param providerParam Provider
     */
    public void setProvider(final String providerParam) {
        this.provider = providerParam;
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
}
