package com.authdog.exceptions

/**
 * Exception thrown when API requests fail
 */
class ApiException(message: String = "API request failed", cause: Option[Throwable] = None) 
  extends AuthdogException(message, cause)

object ApiException {
  def apply(message: String): ApiException = new ApiException(message)
  def apply(message: String, cause: Throwable): ApiException = new ApiException(message, Some(cause))
}
