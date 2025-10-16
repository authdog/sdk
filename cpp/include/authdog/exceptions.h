#pragma once

#include <stdexcept>
#include <string>

namespace authdog {

/**
 * Base exception class for all Authdog SDK errors
 */
class AuthdogException : public std::runtime_error {
public:
    explicit AuthdogException(const std::string& message) : std::runtime_error(message) {}
};

/**
 * Exception thrown when authentication fails
 */
class AuthenticationException : public AuthdogException {
public:
    explicit AuthenticationException(const std::string& message = "Authentication failed") 
        : AuthdogException(message) {}
};

/**
 * Exception thrown when API requests fail
 */
class ApiException : public AuthdogException {
public:
    explicit ApiException(const std::string& message = "API request failed") 
        : AuthdogException(message) {}
};

} // namespace authdog
