package com.authdog.sdk

/**
 * Base exception for all Authdog SDK errors
 */
open class AuthdogError(message: String) : Exception(message)

/**
 * Raised when authentication fails
 */
class AuthenticationError(message: String) : AuthdogError(message)

/**
 * Raised when API requests fail
 */
class APIError(message: String) : AuthdogError(message)
