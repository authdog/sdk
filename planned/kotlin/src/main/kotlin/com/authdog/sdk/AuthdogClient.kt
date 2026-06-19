package com.authdog.sdk

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.decodeFromString
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.net.URI
import java.time.Duration
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

/**
 * Configuration for the Authdog client
 */
data class AuthdogClientConfig(
    val baseUrl: String,
    val apiKey: String? = null,
    val timeoutSeconds: Long = 10,
    val httpClient: HttpClient? = null
)

/**
 * Main client for interacting with Authdog API
 */
class AuthdogClient(private val config: AuthdogClientConfig) {
    private val httpClient: HttpClient = config.httpClient ?: HttpClient.newBuilder()
        .connectTimeout(Duration.ofSeconds(config.timeoutSeconds))
        .build()
    
    private val json = Json {
        ignoreUnknownKeys = true
        coerceInputValues = true
    }

    /**
     * Get user information using an access token
     * @param accessToken The access token for authentication
     * @return UserInfoResponse containing user information
     * @throws AuthenticationError When authentication fails
     * @throws APIError When API request fails
     */
    suspend fun getUserInfo(accessToken: String): UserInfoResponse = withContext(Dispatchers.IO) {
        val url = "${config.baseUrl.removeSuffix("/")}/v1/userinfo"
        
        val request = HttpRequest.newBuilder()
            .uri(URI.create(url))
            .header("Content-Type", "application/json")
            .header("User-Agent", "authdog-kotlin-sdk/0.1.0")
            .header("Authorization", "Bearer $accessToken")
            .GET()
            .build()

        val response = httpClient.send(request, HttpResponse.BodyHandlers.ofString())
        
        when (response.statusCode()) {
            200 -> {
                try {
                    json.decodeFromString<UserInfoResponse>(response.body())
                } catch (e: Exception) {
                    throw APIError("Failed to parse response: ${e.message}")
                }
            }
            401 -> throw AuthenticationError("Unauthorized - invalid or expired token")
            500 -> {
                try {
                    val errorResponse = json.decodeFromString<ErrorResponse>(response.body())
                    when (errorResponse.error) {
                        "GraphQL query failed" -> throw APIError("GraphQL query failed")
                        "Failed to fetch user info" -> throw APIError("Failed to fetch user info")
                        else -> throw APIError("HTTP error 500: ${response.body()}")
                    }
                } catch (e: Exception) {
                    throw APIError("HTTP error 500: ${response.body()}")
                }
            }
            else -> throw APIError("HTTP error ${response.statusCode()}: ${response.body()}")
        }
    }

    /**
     * Close the HTTP client (for cleanup)
     */
    fun close() {
        // HttpClient doesn't require explicit cleanup in Java/Kotlin
    }
}

/**
 * Error response from the API
 */
@Serializable
data class ErrorResponse(
    val error: String
)
