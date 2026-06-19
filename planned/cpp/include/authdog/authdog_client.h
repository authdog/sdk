#pragma once

#include <string>
#include <memory>
#include <optional>
#include "types.h"
#include "exceptions.h"

namespace authdog {

/**
 * Configuration for the Authdog client
 */
struct ClientConfig {
    std::string baseUrl;
    std::optional<std::string> apiKey;
    int timeoutSeconds = 10;
};

/**
 * Main client for interacting with Authdog API
 */
class AuthdogClient {
public:
    /**
     * Initialize the Authdog client
     * @param config Client configuration
     */
    explicit AuthdogClient(const ClientConfig& config);
    
    /**
     * Initialize the Authdog client with base URL only
     * @param baseUrl The base URL of the Authdog API
     */
    explicit AuthdogClient(const std::string& baseUrl);
    
    /**
     * Destructor
     */
    ~AuthdogClient();
    
    // Disable copy constructor and assignment operator
    AuthdogClient(const AuthdogClient&) = delete;
    AuthdogClient& operator=(const AuthdogClient&) = delete;
    
    // Enable move constructor and assignment operator
    AuthdogClient(AuthdogClient&&) noexcept;
    AuthdogClient& operator=(AuthdogClient&&) noexcept;
    
    /**
     * Get user information using an access token
     * @param accessToken The access token for authentication
     * @return UserInfoResponse containing user information
     * @throws AuthenticationException When authentication fails
     * @throws ApiException When API request fails
     */
    UserInfoResponse getUserInfo(const std::string& accessToken);
    
    /**
     * Close the HTTP client (for cleanup)
     */
    void close();

private:
    class Impl;
    std::unique_ptr<Impl> pImpl;
};

} // namespace authdog
