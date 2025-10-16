package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * User photo
 */
public class Photo {
    @JsonProperty("id")
    private String id;
    
    @JsonProperty("value")
    private String value;
    
    @JsonProperty("type")
    private String type;
    
    public Photo() {}
    
    public Photo(String id, String value, String type) {
        this.id = id;
        this.value = value;
        this.type = type;
    }
    
    public String getId() {
        return id;
    }
    
    public void setId(String id) {
        this.id = id;
    }
    
    public String getValue() {
        return value;
    }
    
    public void setValue(String value) {
        this.value = value;
    }
    
    public String getType() {
        return type;
    }
    
    public void setType(String type) {
        this.type = type;
    }
}
