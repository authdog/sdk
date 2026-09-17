package com.authdog.types;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Liveness probe returned by {@code GET /v1/health}.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public final class Probe {
    /**
     * Whether the service reported healthy.
     */
    @JsonProperty("ok")
    private boolean ok;

    /**
     * Default constructor.
     */
    public Probe() {
    }

    /**
     * Constructor with parameters.
     * @param okParam whether the probe succeeded
     */
    public Probe(final boolean okParam) {
        this.ok = okParam;
    }

    /**
     * Get probe success flag.
     * @return whether the service reported healthy
     */
    public boolean isOk() {
        return ok;
    }

    /**
     * Set probe success flag.
     * @param okParam whether the service reported healthy
     */
    public void setOk(final boolean okParam) {
        this.ok = okParam;
    }
}
