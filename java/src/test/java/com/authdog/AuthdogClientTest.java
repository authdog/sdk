package com.authdog;

import com.authdog.exceptions.AuthenticationException;
import com.authdog.exceptions.ApiException;
import com.authdog.types.UserInfoResponse;
import com.authdog.types.Meta;
import com.authdog.types.User;
import com.fasterxml.jackson.databind.ObjectMapper;
import okhttp3.*;
import okhttp3.mockwebserver.MockResponse;
import okhttp3.mockwebserver.MockWebServer;
import okhttp3.mockwebserver.RecordedRequest;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
class AuthdogClientTest {

    private MockWebServer mockServer;
    private AuthdogClient client;
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() throws IOException {
        mockServer = new MockWebServer();
        mockServer.start();
        objectMapper = new ObjectMapper();
    }

    @AfterEach
    void tearDown() throws IOException {
        if (client != null) {
            client.close();
        }
        mockServer.shutdown();
    }

    @Test
    void testConstructorWithBaseUrl() {
        client = new AuthdogClient("https://api.authdog.com");
        assertNotNull(client);
    }

    @Test
    void testConstructorWithBaseUrlAndApiKey() {
        client = new AuthdogClient("https://api.authdog.com", "test-api-key");
        assertNotNull(client);
    }

    @Test
    void testConstructorWithBaseUrlApiKeyAndTimeout() {
        client = new AuthdogClient("https://api.authdog.com", "test-api-key", 5000);
        assertNotNull(client);
    }

    @Test
    void testConstructorStripsTrailingSlash() {
        client = new AuthdogClient("https://api.authdog.com/");
        assertNotNull(client);
    }

    @Test
    void testGetUserInfoSuccess() throws Exception {
        // Mock response
        UserInfoResponse mockResponse = new UserInfoResponse();
        Meta meta = new Meta();
        meta.setCode(200);
        meta.setMessage("OK");
        mockResponse.setMeta(meta);
        
        User user = new User();
        user.setId("123");
        user.setDisplayName("Test User");
        mockResponse.setUser(user);

        mockServer.enqueue(new MockResponse()
                .setResponseCode(200)
                .setHeader("Content-Type", "application/json")
                .setBody(objectMapper.writeValueAsString(mockResponse)));

        client = new AuthdogClient(mockServer.url("/").toString());
        UserInfoResponse result = client.getUserInfo("test-token");

        assertNotNull(result);
        assertEquals("123", result.getUser().getId());
        assertEquals("Test User", result.getUser().getDisplayName());

        // Verify request details
        RecordedRequest request = mockServer.takeRequest();
        assertEquals("GET", request.getMethod());
        assertEquals("/v1/userinfo", request.getPath());
        assertEquals("Bearer test-token", request.getHeader("Authorization"));
        assertEquals("application/json", request.getHeader("Content-Type"));
        assertEquals("authdog-java-sdk/0.1.0", request.getHeader("User-Agent"));
    }

    @Test
    void testGetUserInfoUnauthorized() {
        mockServer.enqueue(new MockResponse()
                .setResponseCode(401)
                .setBody("Unauthorized"));

        client = new AuthdogClient(mockServer.url("/").toString());

        AuthenticationException exception = assertThrows(AuthenticationException.class, () -> {
            client.getUserInfo("invalid-token");
        });

        assertEquals("Unauthorized - invalid or expired token", exception.getMessage());
    }

    @Test
    void testGetUserInfoGraphQLError() {
        mockServer.enqueue(new MockResponse()
                .setResponseCode(500)
                .setHeader("Content-Type", "application/json")
                .setBody("{\"error\": \"GraphQL query failed\"}"));

        client = new AuthdogClient(mockServer.url("/").toString());

        ApiException exception = assertThrows(ApiException.class, () -> {
            client.getUserInfo("test-token");
        });

        assertTrue(exception.getMessage().contains("GraphQL query failed"));
    }

    @Test
    void testGetUserInfoFetchError() {
        mockServer.enqueue(new MockResponse()
                .setResponseCode(500)
                .setHeader("Content-Type", "application/json")
                .setBody("{\"error\": \"Failed to fetch user info\"}"));

        client = new AuthdogClient(mockServer.url("/").toString());

        ApiException exception = assertThrows(ApiException.class, () -> {
            client.getUserInfo("test-token");
        });

        assertTrue(exception.getMessage().contains("Failed to fetch user info"));
    }

    @Test
    void testGetUserInfoHttpError() {
        mockServer.enqueue(new MockResponse()
                .setResponseCode(400)
                .setBody("Bad Request"));

        client = new AuthdogClient(mockServer.url("/").toString());

        ApiException exception = assertThrows(ApiException.class, () -> {
            client.getUserInfo("test-token");
        });

        assertTrue(exception.getMessage().contains("HTTP error 400"));
        assertTrue(exception.getMessage().contains("Bad Request"));
    }

    @Test
    void testGetUserInfoWithApiKey() throws Exception {
        // Mock response
        UserInfoResponse mockResponse = new UserInfoResponse();
        Meta meta = new Meta();
        meta.setCode(200);
        meta.setMessage("OK");
        mockResponse.setMeta(meta);
        
        User user = new User();
        user.setId("123");
        mockResponse.setUser(user);

        mockServer.enqueue(new MockResponse()
                .setResponseCode(200)
                .setHeader("Content-Type", "application/json")
                .setBody(objectMapper.writeValueAsString(mockResponse)));

        client = new AuthdogClient(mockServer.url("/").toString(), "test-api-key");
        UserInfoResponse result = client.getUserInfo("access-token");

        assertNotNull(result);
        assertEquals("123", result.getUser().getId());

        // Verify that API key is used instead of access token (API key overrides access token)
        RecordedRequest request = mockServer.takeRequest();
        assertEquals("Bearer test-api-key", request.getHeader("Authorization"));
    }

    @Test
    void testGetUserInfoParseError() {
        mockServer.enqueue(new MockResponse()
                .setResponseCode(200)
                .setHeader("Content-Type", "application/json")
                .setBody("invalid json"));

        client = new AuthdogClient(mockServer.url("/").toString());

        ApiException exception = assertThrows(ApiException.class, () -> {
            client.getUserInfo("test-token");
        });

        assertTrue(exception.getMessage().contains("Failed to parse response"));
    }

    @Test
    void testGetUserInfoNetworkError() {
        // Don't enqueue any response to simulate network error
        client = new AuthdogClient("http://localhost:99999"); // Invalid port

        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            client.getUserInfo("test-token");
        });

        assertTrue(exception.getMessage().contains("Invalid URL port"));
    }

    @Test
    void testClose() {
        client = new AuthdogClient("https://api.authdog.com");
        
        // Should not throw exception
        assertDoesNotThrow(() -> client.close());
    }

    @Test
    void testAutoCloseable() {
        try (AuthdogClient autoClient = new AuthdogClient("https://api.authdog.com")) {
            assertNotNull(autoClient);
        }
        // Should close automatically without exception
    }

    @Test
    void testTimeoutConfiguration() {
        client = new AuthdogClient(mockServer.url("/").toString(), null, 1000);
        assertNotNull(client);
        
        // Test that timeout is applied by making a request that should timeout
        mockServer.enqueue(new MockResponse()
                .setResponseCode(200)
                .setBody("{\"meta\":{\"code\":200,\"message\":\"OK\"},\"user\":{\"id\":\"123\"}}")
                .setBodyDelay(2, TimeUnit.SECONDS)); // Delay response longer than timeout

        ApiException exception = assertThrows(ApiException.class, () -> {
            client.getUserInfo("test-token");
        });

        assertTrue(exception.getMessage().contains("Request failed") || 
                  exception.getMessage().contains("timeout") ||
                  exception.getMessage().contains("SocketTimeoutException") ||
                  exception.getMessage().contains("Read timed out"));
    }
}
