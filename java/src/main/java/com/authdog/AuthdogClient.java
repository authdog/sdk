package com.authdog;

import com.authdog.exceptions.AuthenticationException;
import com.authdog.exceptions.ApiException;
import com.authdog.types.UserInfoResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import okhttp3.*;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

/**
 * Main client for interacting with Authdog API
 */
public class AuthdogClient implements AutoCloseable {
    private final OkHttpClient httpClient;
    private final String baseUrl;
    private final String apiKey;
    private final ObjectMapper objectMapper;
    
    /**
     * Initialize the Authdog client
     * @param baseUrl The base URL of the Authdog API
     */
    public AuthdogClient(String baseUrl) {
        this(baseUrl, null, 10000);
    }
    
    /**
     * Initialize the Authdog client with API key
     * @param baseUrl The base URL of the Authdog API
     * @param apiKey Optional API key for authentication
     */
    public AuthdogClient(String baseUrl, String apiKey) {
        this(baseUrl, apiKey, 10000);
    }
    
    /**
     * Initialize the Authdog client with custom timeout
     * @param baseUrl The base URL of the Authdog API
     * @param apiKey Optional API key for authentication
     * @param timeoutMs Timeout in milliseconds
     */
    public AuthdogClient(String baseUrl, String apiKey, int timeoutMs) {
        this.baseUrl = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
        this.apiKey = apiKey;
        this.objectMapper = new ObjectMapper();
        
        this.httpClient = new OkHttpClient.Builder()
                .connectTimeout(timeoutMs, TimeUnit.MILLISECONDS)
                .readTimeout(timeoutMs, TimeUnit.MILLISECONDS)
                .writeTimeout(timeoutMs, TimeUnit.MILLISECONDS)
                .build();
    }
    
    /**
     * Get user information using an access token
     * @param accessToken The access token for authentication
     * @return UserInfoResponse containing user information
     * @throws AuthenticationException When authentication fails
     * @throws ApiException When API request fails
     */
    public UserInfoResponse getUserInfo(String accessToken) throws AuthenticationException, ApiException {
        String url = baseUrl + "/v1/userinfo";
        
        Request.Builder requestBuilder = new Request.Builder()
                .url(url)
                .addHeader("Content-Type", "application/json")
                .addHeader("User-Agent", "authdog-java-sdk/0.1.0")
                .addHeader("Authorization", "Bearer " + accessToken);
        
        // Add API key if provided
        if (apiKey != null) {
            requestBuilder.addHeader("Authorization", "Bearer " + apiKey);
        }
        
        Request request = requestBuilder.build();
        
        try (Response response = httpClient.newCall(request).execute()) {
            String responseBody = response.body() != null ? response.body().string() : "";
            
            if (response.code() == 401) {
                throw new AuthenticationException("Unauthorized - invalid or expired token");
            }
            
            if (response.code() == 500) {
                try {
                    // Try to parse error response
                    var errorNode = objectMapper.readTree(responseBody);
                    if (errorNode.has("error")) {
                        String errorMessage = errorNode.get("error").asText();
                        if ("GraphQL query failed".equals(errorMessage)) {
                            throw new ApiException("GraphQL query failed");
                        } else if ("Failed to fetch user info".equals(errorMessage)) {
                            throw new ApiException("Failed to fetch user info");
                        }
                    }
                } catch (Exception e) {
                    // Ignore JSON parsing errors for error responses
                }
                throw new ApiException("HTTP error 500: " + responseBody);
            }
            
            if (response.code() != 200) {
                throw new ApiException("HTTP error " + response.code() + ": " + responseBody);
            }
            
            try {
                return objectMapper.readValue(responseBody, UserInfoResponse.class);
            } catch (Exception e) {
                throw new ApiException("Failed to parse response: " + e.getMessage(), e);
            }
            
        } catch (IOException e) {
            throw new ApiException("Request failed: " + e.getMessage(), e);
        }
    }
    
    /**
     * Close the HTTP client
     */
    @Override
    public void close() {
        httpClient.dispatcher().executorService().shutdown();
        httpClient.connectionPool().evictAll();
    }
}
