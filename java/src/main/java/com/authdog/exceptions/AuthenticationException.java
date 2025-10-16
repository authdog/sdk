package com.authdog.exceptions;

/**
 * Exception thrown when authentication fails
 */
public class AuthenticationException extends AuthdogException {
    
    public AuthenticationException(String message) {
        super(message);
    }
    
    public AuthenticationException(String message, Throwable cause) {
        super(message, cause);
    }
}
