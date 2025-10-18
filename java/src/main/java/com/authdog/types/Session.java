package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Session information.
 */
public final class Session {
    /**
     * Remaining seconds in session.
     */
    @JsonProperty("remainingSeconds")
    private int remainingSeconds;

    /**
     * Default constructor.
     */
    public Session() {
    }

    /**
     * Constructor with parameters.
     * @param remainingSecondsParam Remaining seconds in session
     */
    public Session(final int remainingSecondsParam) {
        this.remainingSeconds = remainingSecondsParam;
    }

    /**
     * Get remaining seconds in session.
     * @return Remaining seconds in session
     */
    public int getRemainingSeconds() {
        return remainingSeconds;
    }

    /**
     * Set remaining seconds in session.
     * @param remainingSecondsParam Remaining seconds in session
     */
    public void setRemainingSeconds(final int remainingSecondsParam) {
        this.remainingSeconds = remainingSecondsParam;
    }
}
