package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Response from the /v1/userinfo endpoint
 */
public class UserInfoResponse {
    @JsonProperty("meta")
    private Meta meta;
    
    @JsonProperty("session")
    private Session session;
    
    @JsonProperty("user")
    private User user;
    
    public UserInfoResponse() {}
    
    public Meta getMeta() {
        return meta;
    }
    
    public void setMeta(Meta meta) {
        this.meta = meta;
    }
    
    public Session getSession() {
        return session;
    }
    
    public void setSession(Session session) {
        this.session = session;
    }
    
    public User getUser() {
        return user;
    }
    
    public void setUser(User user) {
        this.user = user;
    }
}
