package com.authdog.exceptions;

/**
 * Base exception class for all Authdog SDK errors.
 */
public class AuthdogException extends RuntimeException {

    /**
     * Constructor with message.
     * @param messageParam Error message
     */
    public AuthdogException(final String messageParam) {
        super(messageParam);
    }

    /**
     * Constructor with message and cause.
     * @param messageParam Error message
     * @param causeParam Cause of the exception
     */
    public AuthdogException(final String messageParam,
                            final Throwable causeParam) {
        super(messageParam, causeParam);
    }
}
