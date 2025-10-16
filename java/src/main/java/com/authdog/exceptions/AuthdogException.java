package com.authdog.exceptions;

/**
 * Base exception class for all Authdog SDK errors
 */
public class AuthdogException extends RuntimeException {
    
    public AuthdogException(String message) {
        super(message);
    }
    
    public AuthdogException(String message, Throwable cause) {
        super(message, cause);
    }
}
