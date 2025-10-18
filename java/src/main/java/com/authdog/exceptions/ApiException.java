package com.authdog.exceptions;

/**
 * Exception thrown when API requests fail.
 */
public class ApiException extends AuthdogException {

    /**
     * Constructor with message.
     * @param messageParam Error message
     */
    public ApiException(final String messageParam) {
        super(messageParam);
    }

    /**
     * Constructor with message and cause.
     * @param messageParam Error message
     * @param causeParam Cause of the exception
     */
    public ApiException(final String messageParam, final Throwable causeParam) {
        super(messageParam, causeParam);
    }
}
