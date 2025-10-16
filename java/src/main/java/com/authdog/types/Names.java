package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * User name information
 */
public class Names {
    @JsonProperty("id")
    private String id;
    
    @JsonProperty("formatted")
    private String formatted;
    
    @JsonProperty("familyName")
    private String familyName;
    
    @JsonProperty("givenName")
    private String givenName;
    
    @JsonProperty("middleName")
    private String middleName;
    
    @JsonProperty("honorificPrefix")
    private String honorificPrefix;
    
    @JsonProperty("honorificSuffix")
    private String honorificSuffix;
    
    public Names() {}
    
    public String getId() {
        return id;
    }
    
    public void setId(String id) {
        this.id = id;
    }
    
    public String getFormatted() {
        return formatted;
    }
    
    public void setFormatted(String formatted) {
        this.formatted = formatted;
    }
    
    public String getFamilyName() {
        return familyName;
    }
    
    public void setFamilyName(String familyName) {
        this.familyName = familyName;
    }
    
    public String getGivenName() {
        return givenName;
    }
    
    public void setGivenName(String givenName) {
        this.givenName = givenName;
    }
    
    public String getMiddleName() {
        return middleName;
    }
    
    public void setMiddleName(String middleName) {
        this.middleName = middleName;
    }
    
    public String getHonorificPrefix() {
        return honorificPrefix;
    }
    
    public void setHonorificPrefix(String honorificPrefix) {
        this.honorificPrefix = honorificPrefix;
    }
    
    public String getHonorificSuffix() {
        return honorificSuffix;
    }
    
    public void setHonorificSuffix(String honorificSuffix) {
        this.honorificSuffix = honorificSuffix;
    }
}
