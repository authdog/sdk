package com.authdog.exceptions;

/**
 * Exception thrown when authentication fails.
 */
public class AuthenticationException extends AuthdogException {

    /**
     * Constructor with message.
     * @param messageParam Error message
     */
    public AuthenticationException(final String messageParam) {
        super(messageParam);
    }

    /**
     * Constructor with message and cause.
     * @param messageParam Error message
     * @param causeParam Cause of the exception
     */
    public AuthenticationException(final String messageParam,
                                   final Throwable causeParam) {
        super(messageParam, causeParam);
    }
}
