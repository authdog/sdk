package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Metadata in the response
 */
public class Meta {
    @JsonProperty("code")
    private int code;
    
    @JsonProperty("message")
    private String message;
    
    public Meta() {}
    
    public Meta(int code, String message) {
        this.code = code;
        this.message = message;
    }
    
    public int getCode() {
        return code;
    }
    
    public void setCode(int code) {
        this.code = code;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
}
