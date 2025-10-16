package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Session information
 */
public class Session {
    @JsonProperty("remainingSeconds")
    private int remainingSeconds;
    
    public Session() {}
    
    public Session(int remainingSeconds) {
        this.remainingSeconds = remainingSeconds;
    }
    
    public int getRemainingSeconds() {
        return remainingSeconds;
    }
    
    public void setRemainingSeconds(int remainingSeconds) {
        this.remainingSeconds = remainingSeconds;
    }
}
