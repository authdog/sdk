package com.authdog.exceptions

/**
 * Exception thrown when authentication fails
 */
class AuthenticationException(message: String = "Authentication failed", cause: Option[Throwable] = None) 
  extends AuthdogException(message, cause)

object AuthenticationException {
  def apply(message: String): AuthenticationException = new AuthenticationException(message)
  def apply(message: String, cause: Throwable): AuthenticationException = new AuthenticationException(message, Some(cause))
}
