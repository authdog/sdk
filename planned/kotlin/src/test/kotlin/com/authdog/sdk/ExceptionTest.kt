package com.authdog.sdk

import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class ExceptionTest {

    @Test
    fun `AuthdogError inherits from Exception`() {
        val error = AuthdogError("Test error")
        assertTrue(error is Exception)
        assertEquals("Test error", error.message)
    }

    @Test
    fun `AuthenticationError inherits from AuthdogError`() {
        val error = AuthenticationError("Auth failed")
        assertTrue(error is AuthdogError)
        assertTrue(error is Exception)
        assertEquals("Auth failed", error.message)
    }

    @Test
    fun `APIError inherits from AuthdogError`() {
        val error = APIError("API failed")
        assertTrue(error is AuthdogError)
        assertTrue(error is Exception)
        assertEquals("API failed", error.message)
    }

    @Test
    fun `exceptions can be caught as base exception`() {
        val authError = AuthenticationError("Auth failed")
        val apiError = APIError("API failed")
        
        try {
            throw authError
        } catch (e: AuthdogError) {
            assertEquals("Auth failed", e.message)
        }
        
        try {
            throw apiError
        } catch (e: AuthdogError) {
            assertEquals("API failed", e.message)
        }
    }

    @Test
    fun `exceptions can be caught as system exception`() {
        val authError = AuthenticationError("Auth failed")
        val apiError = APIError("API failed")
        
        try {
            throw authError
        } catch (e: Exception) {
            assertEquals("Auth failed", e.message)
        }
        
        try {
            throw apiError
        } catch (e: Exception) {
            assertEquals("API failed", e.message)
        }
    }

    @Test
    fun `exceptions can be thrown and caught`() {
        fun throwAuthError() {
            throw AuthenticationError("Test auth error")
        }
        
        fun throwApiError() {
            throw APIError("Test API error")
        }
        
        try {
            throwAuthError()
        } catch (e: AuthenticationError) {
            assertEquals("Test auth error", e.message)
        }
        
        try {
            throwApiError()
        } catch (e: APIError) {
            assertEquals("Test API error", e.message)
        }
    }
}
