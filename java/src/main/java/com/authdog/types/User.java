package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

/**
 * User information
 */
public class User {
    @JsonProperty("id")
    private String id;
    
    @JsonProperty("externalId")
    private String externalId;
    
    @JsonProperty("userName")
    private String userName;
    
    @JsonProperty("displayName")
    private String displayName;
    
    @JsonProperty("nickName")
    private String nickName;
    
    @JsonProperty("profileUrl")
    private String profileUrl;
    
    @JsonProperty("title")
    private String title;
    
    @JsonProperty("userType")
    private String userType;
    
    @JsonProperty("preferredLanguage")
    private String preferredLanguage;
    
    @JsonProperty("locale")
    private String locale;
    
    @JsonProperty("timezone")
    private String timezone;
    
    @JsonProperty("active")
    private boolean active;
    
    @JsonProperty("names")
    private Names names;
    
    @JsonProperty("photos")
    private List<Photo> photos;
    
    @JsonProperty("phoneNumbers")
    private List<Object> phoneNumbers;
    
    @JsonProperty("addresses")
    private List<Object> addresses;
    
    @JsonProperty("emails")
    private List<Email> emails;
    
    @JsonProperty("verifications")
    private List<Verification> verifications;
    
    @JsonProperty("provider")
    private String provider;
    
    @JsonProperty("createdAt")
    private String createdAt;
    
    @JsonProperty("updatedAt")
    private String updatedAt;
    
    @JsonProperty("environmentId")
    private String environmentId;
    
    public User() {}
    
    public String getId() {
        return id;
    }
    
    public void setId(String id) {
        this.id = id;
    }
    
    public String getExternalId() {
        return externalId;
    }
    
    public void setExternalId(String externalId) {
        this.externalId = externalId;
    }
    
    public String getUserName() {
        return userName;
    }
    
    public void setUserName(String userName) {
        this.userName = userName;
    }
    
    public String getDisplayName() {
        return displayName;
    }
    
    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }
    
    public String getNickName() {
        return nickName;
    }
    
    public void setNickName(String nickName) {
        this.nickName = nickName;
    }
    
    public String getProfileUrl() {
        return profileUrl;
    }
    
    public void setProfileUrl(String profileUrl) {
        this.profileUrl = profileUrl;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getUserType() {
        return userType;
    }
    
    public void setUserType(String userType) {
        this.userType = userType;
    }
    
    public String getPreferredLanguage() {
        return preferredLanguage;
    }
    
    public void setPreferredLanguage(String preferredLanguage) {
        this.preferredLanguage = preferredLanguage;
    }
    
    public String getLocale() {
        return locale;
    }
    
    public void setLocale(String locale) {
        this.locale = locale;
    }
    
    public String getTimezone() {
        return timezone;
    }
    
    public void setTimezone(String timezone) {
        this.timezone = timezone;
    }
    
    public boolean isActive() {
        return active;
    }
    
    public void setActive(boolean active) {
        this.active = active;
    }
    
    public Names getNames() {
        return names;
    }
    
    public void setNames(Names names) {
        this.names = names;
    }
    
    public List<Photo> getPhotos() {
        return photos;
    }
    
    public void setPhotos(List<Photo> photos) {
        this.photos = photos;
    }
    
    public List<Object> getPhoneNumbers() {
        return phoneNumbers;
    }
    
    public void setPhoneNumbers(List<Object> phoneNumbers) {
        this.phoneNumbers = phoneNumbers;
    }
    
    public List<Object> getAddresses() {
        return addresses;
    }
    
    public void setAddresses(List<Object> addresses) {
        this.addresses = addresses;
    }
    
    public List<Email> getEmails() {
        return emails;
    }
    
    public void setEmails(List<Email> emails) {
        this.emails = emails;
    }
    
    public List<Verification> getVerifications() {
        return verifications;
    }
    
    public void setVerifications(List<Verification> verifications) {
        this.verifications = verifications;
    }
    
    public String getProvider() {
        return provider;
    }
    
    public void setProvider(String provider) {
        this.provider = provider;
    }
    
    public String getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
    
    public String getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public String getEnvironmentId() {
        return environmentId;
    }
    
    public void setEnvironmentId(String environmentId) {
        this.environmentId = environmentId;
    }
}
