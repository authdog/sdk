package com.authdog.exceptions

/**
 * Base exception class for all Authdog SDK errors
 */
class AuthdogException(message: String, cause: Option[Throwable] = None) 
  extends RuntimeException(message, cause.orNull)

object AuthdogException {
  def apply(message: String): AuthdogException = new AuthdogException(message)
  def apply(message: String, cause: Throwable): AuthdogException = new AuthdogException(message, Some(cause))
}
