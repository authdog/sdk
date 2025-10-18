package com.authdog;

import com.authdog.exceptions.AuthenticationException;
import com.authdog.exceptions.ApiException;
import com.authdog.types.UserInfoResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

/**
 * Main client for interacting with Authdog API.
 */
public class AuthdogClient implements AutoCloseable {
    /**
     * Default timeout in milliseconds.
     */
    private static final int DEFAULT_TIMEOUT_MS = 10000;

    /**
     * HTTP 200 status code.
     */
    private static final int HTTP_OK = 200;

    /**
     * HTTP 401 status code.
     */
    private static final int HTTP_UNAUTHORIZED = 401;

    /**
     * HTTP 500 status code.
     */
    private static final int HTTP_INTERNAL_SERVER_ERROR = 500;

    /**
     * HTTP client.
     */
    private final OkHttpClient httpClient;

    /**
     * Base URL.
     */
    private final String baseUrl;

    /**
     * API key.
     */
    private final String apiKey;

    /**
     * Object mapper.
     */
    private final ObjectMapper objectMapper;

    /**
     * Initialize the Authdog client.
     * @param baseUrlParam The base URL of the Authdog API
     */
    public AuthdogClient(final String baseUrlParam) {
        this(baseUrlParam, null, DEFAULT_TIMEOUT_MS);
    }

    /**
     * Initialize the Authdog client with API key.
     * @param baseUrlParam The base URL of the Authdog API
     * @param apiKeyParam Optional API key for authentication
     */
    public AuthdogClient(final String baseUrlParam, final String apiKeyParam) {
        this(baseUrlParam, apiKeyParam, DEFAULT_TIMEOUT_MS);
    }

    /**
     * Initialize the Authdog client with custom timeout.
     * @param baseUrlParam The base URL of the Authdog API
     * @param apiKeyParam Optional API key for authentication
     * @param timeoutMsParam Timeout in milliseconds
     */
    public AuthdogClient(final String baseUrlParam, final String apiKeyParam,
                        final int timeoutMsParam) {
        this.baseUrl = baseUrlParam.endsWith("/")
                ? baseUrlParam.substring(0, baseUrlParam.length() - 1)
                : baseUrlParam;
        this.apiKey = apiKeyParam;
        this.objectMapper = new ObjectMapper();

        this.httpClient = new OkHttpClient.Builder()
                .connectTimeout(timeoutMsParam, TimeUnit.MILLISECONDS)
                .readTimeout(timeoutMsParam, TimeUnit.MILLISECONDS)
                .writeTimeout(timeoutMsParam, TimeUnit.MILLISECONDS)
                .build();
    }
    /**
     * Get user information using an access token.
     * @param accessTokenParam The access token for authentication
     * @return UserInfoResponse containing user information
     * @throws AuthenticationException When authentication fails
     * @throws ApiException When API request fails
     */
    public UserInfoResponse getUserInfo(final String accessTokenParam)
            throws AuthenticationException, ApiException {
        String url = baseUrl + "/v1/userinfo";

        Request.Builder requestBuilder = new Request.Builder()
                .url(url)
                .addHeader("Content-Type", "application/json")
                .addHeader("User-Agent", "authdog-java-sdk/0.1.0");

        // Use API key if provided, otherwise use access token
        if (apiKey != null) {
            requestBuilder.header("Authorization", "Bearer " + apiKey);
        } else {
            requestBuilder.header("Authorization",
                    "Bearer " + accessTokenParam);
        }

        Request request = requestBuilder.build();

        try (Response response = httpClient.newCall(request).execute()) {
            ResponseBody body = response.body();
            String responseBody = body != null ? body.string() : "";

            if (response.code() == HTTP_UNAUTHORIZED) {
                throw new AuthenticationException(
                        "Unauthorized - invalid or expired token");
            }

            if (response.code() == HTTP_INTERNAL_SERVER_ERROR) {
                try {
                    // Try to parse error response
                    var errorNode = objectMapper.readTree(responseBody);
                    if (errorNode.has("error")) {
                        String errorMessage = errorNode.get("error").asText();
                        if ("GraphQL query failed".equals(errorMessage)) {
                            throw new ApiException("GraphQL query failed");
                        } else if ("Failed to fetch user info"
                                .equals(errorMessage)) {
                            throw new ApiException("Failed to fetch user info");
                        }
                    }
                } catch (IOException e) {
                    // Ignore JSON parsing errors for error responses
                }
                throw new ApiException("HTTP error 500: " + responseBody);
            }

            if (response.code() != HTTP_OK) {
                throw new ApiException("HTTP error " + response.code()
                        + ": " + responseBody);
            }

            try {
                return objectMapper.readValue(responseBody,
                        UserInfoResponse.class);
            } catch (Exception e) {
                throw new ApiException("Failed to parse response: "
                        + e.getMessage(), e);
            }

        } catch (IOException e) {
            throw new ApiException("Request failed: " + e.getMessage(), e);
        }
    }
    /**
     * Close the HTTP client.
     */
    @Override
    public void close() {
        httpClient.dispatcher().executorService().shutdown();
        httpClient.connectionPool().evictAll();
    }
}
