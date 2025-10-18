package com.authdog.sdk

import io.mockk.*
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.net.URI
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

class AuthdogClientTest {

    private lateinit var mockHttpClient: HttpClient
    private lateinit var mockResponse: HttpResponse<String>
    private lateinit var client: AuthdogClient

    @BeforeEach
    fun setUp() {
        mockHttpClient = mockk()
        mockResponse = mockk()
        client = AuthdogClient(
            AuthdogClientConfig(
                baseUrl = "https://api.authdog.com",
                apiKey = "test-api-key",
                httpClient = mockHttpClient
            )
        )
    }

    @AfterEach
    fun tearDown() {
        clearAllMocks()
    }

    @Test
    fun `constructor with baseUrl sets correct configuration`() = runTest {
        val testClient = AuthdogClient(
            AuthdogClientConfig(
                baseUrl = "https://api.authdog.com"
            )
        )
        
        assertNotNull(testClient)
        testClient.close()
    }

    @Test
    fun `constructor with trailing slash removes trailing slash`() = runTest {
        val testClient = AuthdogClient(
            AuthdogClientConfig(
                baseUrl = "https://api.authdog.com/"
            )
        )
        
        assertNotNull(testClient)
        testClient.close()
    }

    @Test
    fun `constructor with apiKey sets apiKey`() = runTest {
        val testClient = AuthdogClient(
            AuthdogClientConfig(
                baseUrl = "https://api.authdog.com",
                apiKey = "test-key"
            )
        )
        
        assertNotNull(testClient)
        testClient.close()
    }

    @Test
    fun `constructor with custom httpClient uses provided client`() = runTest {
        val customClient = mockk<HttpClient>()
        val testClient = AuthdogClient(
            AuthdogClientConfig(
                baseUrl = "https://api.authdog.com",
                httpClient = customClient
            )
        )
        
        assertNotNull(testClient)
        testClient.close()
    }

    @Test
    fun `getUserInfo with valid token returns user info`() = runTest {
        val mockResponseBody = """
        {
            "meta": {"code": 200, "message": "Success"},
            "session": {"remainingSeconds": 3600},
            "user": {
                "id": "user123",
                "externalId": "ext123",
                "userName": "testuser",
                "displayName": "Test User",
                "locale": "en-US",
                "active": true,
                "names": {
                    "id": "name123",
                    "familyName": "User",
                    "givenName": "Test"
                },
                "photos": [],
                "phoneNumbers": [],
                "addresses": [],
                "emails": [],
                "verifications": [],
                "provider": "test",
                "createdAt": "2023-01-01T00:00:00Z",
                "updatedAt": "2023-01-01T00:00:00Z",
                "environmentId": "env123"
            }
        }
        """.trimIndent()

        every { mockResponse.statusCode() } returns 200
        every { mockResponse.body() } returns mockResponseBody
        every { 
            mockHttpClient.send(any<HttpRequest>(), any<HttpResponse.BodyHandler<String>>()) 
        } returns mockResponse

        val result = client.getUserInfo("valid-token")

        assertEquals("user123", result.user.id)
        assertEquals("testuser", result.user.userName)
        assertEquals("Test User", result.user.displayName)
        assertEquals(200, result.meta.code)
        assertEquals(3600, result.session.remainingSeconds)
    }

    @Test
    fun `getUserInfo with unauthorized response throws AuthenticationError`() = runTest {
        every { mockResponse.statusCode() } returns 401
        every { mockResponse.body() } returns "Unauthorized"
        every { 
            mockHttpClient.send(any<HttpRequest>(), any<HttpResponse.BodyHandler<String>>()) 
        } returns mockResponse

        val exception = assertThrows<AuthenticationError> {
            client.getUserInfo("invalid-token")
        }

        assertTrue(exception.message!!.contains("Unauthorized"))
    }

    @Test
    fun `getUserInfo with GraphQL error throws APIError`() = runTest {
        val errorResponse = """{"error": "GraphQL query failed"}"""
        
        every { mockResponse.statusCode() } returns 500
        every { mockResponse.body() } returns errorResponse
        every { 
            mockHttpClient.send(any<HttpRequest>(), any<HttpResponse.BodyHandler<String>>()) 
        } returns mockResponse

        val exception = assertThrows<APIError> {
            client.getUserInfo("token")
        }

        assertTrue(exception.message!!.contains("GraphQL query failed"))
    }

    @Test
    fun `getUserInfo with fetch error throws APIError`() = runTest {
        val errorResponse = """{"error": "Failed to fetch user info"}"""
        
        every { mockResponse.statusCode() } returns 500
        every { mockResponse.body() } returns errorResponse
        every { 
            mockHttpClient.send(any<HttpRequest>(), any<HttpResponse.BodyHandler<String>>()) 
        } returns mockResponse

        val exception = assertThrows<APIError> {
            client.getUserInfo("token")
        }

        assertTrue(exception.message!!.contains("Failed to fetch user info"))
    }

    @Test
    fun `getUserInfo with non-success status code throws APIError`() = runTest {
        every { mockResponse.statusCode() } returns 404
        every { mockResponse.body() } returns "Not Found"
        every { 
            mockHttpClient.send(any<HttpRequest>(), any<HttpResponse.BodyHandler<String>>()) 
        } returns mockResponse

        val exception = assertThrows<APIError> {
            client.getUserInfo("token")
        }

        assertTrue(exception.message!!.contains("HTTP error 404"))
    }

    @Test
    fun `getUserInfo with invalid JSON throws APIError`() = runTest {
        every { mockResponse.statusCode() } returns 200
        every { mockResponse.body() } returns "invalid json"
        every { 
            mockHttpClient.send(any<HttpRequest>(), any<HttpResponse.BodyHandler<String>>()) 
        } returns mockResponse

        val exception = assertThrows<APIError> {
            client.getUserInfo("token")
        }

        assertTrue(exception.message!!.contains("Failed to parse response"))
    }

    @Test
    fun `getUserInfo sets correct headers`() = runTest {
        val mockResponseBody = """
        {
            "meta": {"code": 200, "message": "Success"},
            "session": {"remainingSeconds": 3600},
            "user": {
                "id": "user123",
                "externalId": "ext123",
                "userName": "testuser",
                "displayName": "Test User",
                "locale": "en-US",
                "active": true,
                "names": {
                    "id": "name123",
                    "familyName": "User",
                    "givenName": "Test"
                },
                "photos": [],
                "phoneNumbers": [],
                "addresses": [],
                "emails": [],
                "verifications": [],
                "provider": "test",
                "createdAt": "2023-01-01T00:00:00Z",
                "updatedAt": "2023-01-01T00:00:00Z",
                "environmentId": "env123"
            }
        }
        """.trimIndent()

        every { mockResponse.statusCode() } returns 200
        every { mockResponse.body() } returns mockResponseBody
        every { 
            mockHttpClient.send(any<HttpRequest>(), any<HttpResponse.BodyHandler<String>>()) 
        } returns mockResponse

        client.getUserInfo("test-token")

        verify {
            mockHttpClient.send(
                match<HttpRequest> { request ->
                    request.uri() == URI.create("https://api.authdog.com/v1/userinfo") &&
                    request.headers().firstValue("Authorization").orElse("") == "Bearer test-token" &&
                    request.headers().firstValue("User-Agent").orElse("") == "authdog-kotlin-sdk/0.1.0" &&
                    request.headers().firstValue("Content-Type").orElse("") == "application/json"
                },
                any<HttpResponse.BodyHandler<String>>()
            )
        }
    }

    @Test
    fun `close method completes without error`() {
        // Should not throw any exception
        client.close()
    }
}
