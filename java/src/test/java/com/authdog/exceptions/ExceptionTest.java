/*
 * MIT License
 *
 * Copyright (c) 2025 Authdog
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package com.authdog.exceptions;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class ExceptionTest {

    @Test
    void testAuthdogExceptionWithMessage() {
        String message = "Test error message";
        AuthdogException exception = new AuthdogException(message);
        
        assertEquals(message, exception.getMessage());
        assertNull(exception.getCause());
    }

    @Test
    void testAuthdogExceptionWithMessageAndCause() {
        String message = "Test error message";
        Throwable cause = new RuntimeException("Root cause");
        AuthdogException exception = new AuthdogException(message, cause);
        
        assertEquals(message, exception.getMessage());
        assertEquals(cause, exception.getCause());
    }

    @Test
    void testAuthenticationExceptionWithMessage() {
        String message = "Authentication failed";
        AuthenticationException exception = new AuthenticationException(message);
        
        assertEquals(message, exception.getMessage());
        assertNull(exception.getCause());
    }

    @Test
    void testAuthenticationExceptionWithMessageAndCause() {
        String message = "Authentication failed";
        Throwable cause = new RuntimeException("Root cause");
        AuthenticationException exception = new AuthenticationException(message, cause);
        
        assertEquals(message, exception.getMessage());
        assertEquals(cause, exception.getCause());
    }

    @Test
    void testApiExceptionWithMessage() {
        String message = "API request failed";
        ApiException exception = new ApiException(message);
        
        assertEquals(message, exception.getMessage());
        assertNull(exception.getCause());
    }

    @Test
    void testApiExceptionWithMessageAndCause() {
        String message = "API request failed";
        Throwable cause = new RuntimeException("Root cause");
        ApiException exception = new ApiException(message, cause);
        
        assertEquals(message, exception.getMessage());
        assertEquals(cause, exception.getCause());
    }

    @Test
    void testExceptionInheritance() {
        // Test that exceptions properly extend RuntimeException
        assertTrue(new AuthdogException("test") instanceof RuntimeException);
        assertTrue(new AuthenticationException("test") instanceof RuntimeException);
        assertTrue(new ApiException("test") instanceof RuntimeException);
    }

    @Test
    void testExceptionTypes() {
        // Test that exceptions are instances of their specific types
        AuthdogException authdogException = new AuthdogException("test");
        AuthenticationException authException = new AuthenticationException("test");
        ApiException apiException = new ApiException("test");

        assertTrue(authdogException instanceof AuthdogException);
        assertTrue(authException instanceof AuthenticationException);
        assertTrue(apiException instanceof ApiException);
    }

    @Test
    void testExceptionChaining() {
        // Test exception chaining
        RuntimeException rootCause = new RuntimeException("Root cause");
        AuthdogException chainedException = new AuthdogException("Chained message", rootCause);
        
        assertEquals("Chained message", chainedException.getMessage());
        assertEquals(rootCause, chainedException.getCause());
        assertEquals("Root cause", chainedException.getCause().getMessage());
    }

    @Test
    void testExceptionToString() {
        // Test that toString() works correctly
        AuthdogException exception = new AuthdogException("Test message");
        String toString = exception.toString();
        
        assertTrue(toString.contains("AuthdogException"));
        assertTrue(toString.contains("Test message"));
    }

    @Test
    void testExceptionWithNullMessage() {
        // Test behavior with null message
        AuthdogException exception = new AuthdogException(null);
        
        assertNull(exception.getMessage());
    }

    @Test
    void testExceptionWithEmptyMessage() {
        // Test behavior with empty message
        AuthdogException exception = new AuthdogException("");
        
        assertEquals("", exception.getMessage());
    }

    @Test
    void testExceptionEquality() {
        // Test that different exception instances are not equal
        AuthdogException exception1 = new AuthdogException("message");
        AuthdogException exception2 = new AuthdogException("message");
        
        assertNotEquals(exception1, exception2);
        assertNotEquals(exception1.hashCode(), exception2.hashCode());
    }

    @Test
    void testExceptionStackTrace() {
        // Test that stack trace is properly populated
        AuthdogException exception = new AuthdogException("Test message");
        StackTraceElement[] stackTrace = exception.getStackTrace();
        
        assertNotNull(stackTrace);
        assertTrue(stackTrace.length > 0);
    }
}
