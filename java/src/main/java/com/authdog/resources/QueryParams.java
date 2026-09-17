package com.authdog.resources;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Builds query maps while omitting null values.
 */
final class QueryParams {
    private QueryParams() {
    }

    /**
     * Put a value when it is not null.
     * @param targetParam destination map
     * @param keyParam query key
     * @param valueParam query value
     */
    static void put(final Map<String, String> targetParam,
                    final String keyParam, final Object valueParam) {
        if (valueParam != null) {
            targetParam.put(keyParam, String.valueOf(valueParam));
        }
    }

    /**
     * Return the map, or {@code null} when empty.
     * @param valuesParam query values
     * @return map or null
     */
    static Map<String, String> orNull(
            final Map<String, String> valuesParam) {
        return valuesParam.isEmpty() ? null : valuesParam;
    }

    /**
     * Create a possibly empty query map.
     * @return new map
     */
    static Map<String, String> create() {
        return new LinkedHashMap<>();
    }
}
