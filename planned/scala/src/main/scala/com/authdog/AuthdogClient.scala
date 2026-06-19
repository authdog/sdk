package com.authdog

import com.authdog.exceptions.{ApiException, AuthenticationException}
import com.authdog.types.UserInfoResponse
import sttp.client3._
import sttp.client3.circe._
import io.circe.generic.auto._
import scala.concurrent.duration._
import scala.util.Try

/**
 * Main client for interacting with Authdog API
 */
class AuthdogClient(
  baseUrl: String,
  apiKey: Option[String] = None,
  timeout: Duration = 10.seconds
) {
  private val backend = HttpURLConnectionBackend()
  private val cleanBaseUrl = baseUrl.stripSuffix("/")
  
  /**
   * Get user information using an access token
   * @param accessToken The access token for authentication
   * @return UserInfoResponse containing user information
   * @throws AuthenticationException When authentication fails
   * @throws ApiException When API request fails
   */
  def getUserInfo(accessToken: String): UserInfoResponse = {
    val request = basicRequest
      .get(uri"$cleanBaseUrl/v1/userinfo")
      .header("Content-Type", "application/json")
      .header("User-Agent", "authdog-scala-sdk/0.1.0")
      .header("Authorization", s"Bearer $accessToken")
      .readTimeout(timeout)
      .response(asJson[UserInfoResponse])
    
    // Add API key if provided
    val finalRequest = apiKey match {
      case Some(key) => request.header("Authorization", s"Bearer $key")
      case None => request
    }
    
    val response = finalRequest.send(backend)
    
    response.body match {
      case Right(userInfo) => userInfo
      case Left(error) =>
        response.code.code match {
          case 401 => throw AuthenticationException("Unauthorized - invalid or expired token")
          case 500 => 
            // Try to parse error response
            Try {
              import io.circe.parser._
              parse(error.toString).flatMap(_.hcursor.get[String]("error")).toOption match {
                case Some("GraphQL query failed") => throw ApiException("GraphQL query failed")
                case Some("Failed to fetch user info") => throw ApiException("Failed to fetch user info")
                case _ => throw ApiException(s"HTTP error 500: $error")
              }
            }.getOrElse(throw ApiException(s"HTTP error 500: $error"))
          case statusCode => throw ApiException(s"HTTP error $statusCode: $error")
        }
    }
  }
  
  /**
   * Close the HTTP client (for cleanup)
   */
  def close(): Unit = {
    backend.close()
  }
}

object AuthdogClient {
  /**
   * Create a new Authdog client
   * @param baseUrl The base URL of the Authdog API
   * @return AuthdogClient instance
   */
  def apply(baseUrl: String): AuthdogClient = new AuthdogClient(baseUrl)
  
  /**
   * Create a new Authdog client with API key
   * @param baseUrl The base URL of the Authdog API
   * @param apiKey Optional API key for authentication
   * @return AuthdogClient instance
   */
  def apply(baseUrl: String, apiKey: String): AuthdogClient = new AuthdogClient(baseUrl, Some(apiKey))
  
  /**
   * Create a new Authdog client with custom timeout
   * @param baseUrl The base URL of the Authdog API
   * @param apiKey Optional API key for authentication
   * @param timeout Request timeout
   * @return AuthdogClient instance
   */
  def apply(baseUrl: String, apiKey: Option[String], timeout: Duration): AuthdogClient = 
    new AuthdogClient(baseUrl, apiKey, timeout)
}
