package com.authdog;

import com.authdog.exceptions.AuthenticationException;
import com.authdog.exceptions.ApiException;
import com.authdog.resources.EnvironmentsResource;
import com.authdog.resources.GroupsResource;
import com.authdog.resources.OrganizationsResource;
import com.authdog.resources.ProjectsResource;
import com.authdog.resources.TenantsResource;
import com.authdog.resources.UsersResource;
import com.authdog.types.Probe;
import com.authdog.types.UserInfoResponse;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import okhttp3.HttpUrl;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.ResponseBody;

import java.io.IOException;
import java.util.Map;
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
     * HTTP 400 status code.
     */
    private static final int HTTP_BAD_REQUEST = 400;

    /**
     * HTTP 401 status code.
     */
    private static final int HTTP_UNAUTHORIZED = 401;

    /**
     * HTTP 500 status code.
     */
    private static final int HTTP_INTERNAL_SERVER_ERROR = 500;

    /**
     * JSON media type.
     */
    private static final MediaType JSON_MEDIA =
            MediaType.get("application/json");

    /**
     * Empty JSON request body.
     */
    private static final RequestBody EMPTY_BODY =
            RequestBody.create("", JSON_MEDIA);

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
     * Organizations resource.
     */
    private final OrganizationsResource organizations;

    /**
     * Tenants resource.
     */
    private final TenantsResource tenants;

    /**
     * Projects resource.
     */
    private final ProjectsResource projects;

    /**
     * Environments resource.
     */
    private final EnvironmentsResource environments;

    /**
     * Users resource.
     */
    private final UsersResource users;

    /**
     * Groups resource.
     */
    private final GroupsResource groups;

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
        this.organizations = new OrganizationsResource(this);
        this.tenants = new TenantsResource(this);
        this.projects = new ProjectsResource(this);
        this.environments = new EnvironmentsResource(this);
        this.users = new UsersResource(this);
        this.groups = new GroupsResource(this);
    }

    /**
     * Management API key used as a Bearer credential.
     * Userinfo uses the access token argument instead.
     * @return API key or null
     */
    public String getApiKey() {
        return apiKey;
    }

    /**
     * Organization management helpers.
     * @return organizations resource
     */
    public OrganizationsResource organizations() {
        return organizations;
    }

    /**
     * Tenant management helpers.
     * @return tenants resource
     */
    public TenantsResource tenants() {
        return tenants;
    }

    /**
     * Project management helpers.
     * @return projects resource
     */
    public ProjectsResource projects() {
        return projects;
    }

    /**
     * Environment management helpers.
     * @return environments resource
     */
    public EnvironmentsResource environments() {
        return environments;
    }

    /**
     * Directory user helpers.
     * @return users resource
     */
    public UsersResource users() {
        return users;
    }

    /**
     * Directory group helpers.
     * @return groups resource
     */
    public GroupsResource groups() {
        return groups;
    }

    /**
     * Liveness probe. Public; works without a management credential.
     * @return probe result
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public Probe health() throws AuthenticationException, ApiException {
        return request("GET", "/v1/health", null, null, Probe.class);
    }

    /**
     * Send a JSON management request.
     * @param <T> response type
     * @param methodParam HTTP method
     * @param pathParam request path beginning with /
     * @param bodyParam optional JSON body
     * @param queryParam optional query parameters
     * @param typeParam Jackson type
     * @return parsed response
     * @throws AuthenticationException when unauthorized
     * @throws ApiException when the request fails
     */
    public <T> T request(final String methodParam, final String pathParam,
                         final Object bodyParam,
                         final Map<String, String> queryParam,
                         final Class<T> typeParam)
            throws AuthenticationException, ApiException {
        final Request.Builder builder = new Request.Builder()
                .url(buildUrl(pathParam, queryParam))
                .addHeader("Content-Type", "application/json")
                .addHeader("User-Agent", "authdog-java-sdk/0.1.0");
        if (apiKey != null) {
            builder.header("Authorization", "Bearer " + apiKey);
        }
        applyMethod(builder, methodParam, encodeBody(bodyParam));

        try (Response response = httpClient.newCall(builder.build())
                .execute()) {
            final ResponseBody body = response.body();
            String responseBody = body != null ? body.string() : "";
            throwIfUnsuccessful(response.code(), responseBody);
            if (responseBody.isEmpty()) {
                responseBody = "{}";
            }
            try {
                return objectMapper.readValue(responseBody, typeParam);
            } catch (Exception e) {
                throw new ApiException("Failed to parse response: "
                        + e.getMessage(), e);
            }
        } catch (IOException e) {
            throw new ApiException("Request failed: " + e.getMessage(), e);
        }
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
                .addHeader("User-Agent", "authdog-java-sdk/0.1.0")
                .header("Authorization", "Bearer " + accessTokenParam);

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

    /**
     * Build the request URL.
     * @param pathParam request path
     * @param queryParam optional query parameters
     * @return absolute URL
     */
    private HttpUrl buildUrl(final String pathParam,
                             final Map<String, String> queryParam) {
        final HttpUrl parsed = HttpUrl.parse(baseUrl + pathParam);
        if (parsed == null) {
            throw new ApiException("Request failed: invalid URL");
        }
        if (queryParam == null || queryParam.isEmpty()) {
            return parsed;
        }
        final HttpUrl.Builder urlBuilder = parsed.newBuilder();
        for (final Map.Entry<String, String> entry
                : queryParam.entrySet()) {
            if (entry.getValue() != null) {
                urlBuilder.addQueryParameter(entry.getKey(),
                        entry.getValue());
            }
        }
        return urlBuilder.build();
    }

    /**
     * Encode an optional JSON body.
     * @param bodyParam request body
     * @return OkHttp body
     */
    private RequestBody encodeBody(final Object bodyParam) {
        if (bodyParam == null) {
            return EMPTY_BODY;
        }
        try {
            return RequestBody.create(
                    objectMapper.writeValueAsString(bodyParam),
                    JSON_MEDIA);
        } catch (IOException e) {
            throw new ApiException("Request failed: " + e.getMessage(), e);
        }
    }

    /**
     * Apply the HTTP method to the request builder.
     * @param builderParam request builder
     * @param methodParam HTTP method
     * @param bodyParam encoded body
     */
    private void applyMethod(final Request.Builder builderParam,
                             final String methodParam,
                             final RequestBody bodyParam) {
        switch (methodParam) {
            case "GET":
                builderParam.get();
                break;
            case "POST":
                builderParam.post(bodyParam);
                break;
            case "PUT":
                builderParam.put(bodyParam);
                break;
            case "PATCH":
                builderParam.patch(bodyParam);
                break;
            case "DELETE":
                builderParam.delete();
                break;
            default:
                throw new ApiException("Request failed: unsupported HTTP "
                        + "method");
        }
    }

    /**
     * Map unsuccessful HTTP responses onto SDK exceptions.
     * @param codeParam HTTP status
     * @param responseBodyParam response body
     */
    private void throwIfUnsuccessful(final int codeParam,
                                     final String responseBodyParam) {
        if (codeParam == HTTP_UNAUTHORIZED) {
            throw new AuthenticationException(
                    "Unauthorized - invalid or expired token");
        }
        if (codeParam >= HTTP_BAD_REQUEST) {
            throw new ApiException("HTTP error " + codeParam + ": "
                    + extractErrorText(responseBodyParam));
        }
    }

    /**
     * Prefer a JSON {@code error} field when present.
     * @param responseBodyParam response body
     * @return error text
     */
    private String extractErrorText(final String responseBodyParam) {
        try {
            final JsonNode node = objectMapper.readTree(responseBodyParam);
            if (node != null && node.has("error")
                    && !node.get("error").isNull()) {
                return node.get("error").asText();
            }
        } catch (IOException e) {
            // Use the raw body when the error payload is not JSON.
        }
        return responseBodyParam;
    }
}
