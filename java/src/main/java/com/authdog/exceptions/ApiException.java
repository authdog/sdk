package com.authdog.exceptions;

/**
 * Exception thrown when API requests fail
 */
public class ApiException extends AuthdogException {
    
    public ApiException(String message) {
        super(message);
    }
    
    public ApiException(String message, Throwable cause) {
        super(message, cause);
    }
}
