#include "authdog/authdog_client.h"
#include <cpr/cpr.h>
#include <nlohmann/json.hpp>
#include <iostream>
#include <sstream>

namespace authdog {

class AuthdogClient::Impl {
public:
    ClientConfig config;
    
    Impl(const ClientConfig& cfg) : config(cfg) {
        // Remove trailing slash from base URL
        if (!config.baseUrl.empty() && config.baseUrl.back() == '/') {
            config.baseUrl.pop_back();
        }
    }
    
    UserInfoResponse getUserInfo(const std::string& accessToken) {
        std::string url = config.baseUrl + "/v1/userinfo";
        
        cpr::Header headers = {
            {"Content-Type", "application/json"},
            {"User-Agent", "authdog-cpp-sdk/0.1.0"},
            {"Authorization", "Bearer " + accessToken}
        };
        
        // Add API key if provided
        if (config.apiKey) {
            headers["Authorization"] = "Bearer " + *config.apiKey;
        }
        
        auto response = cpr::Get(
            cpr::Url{url},
            headers,
            cpr::Timeout{config.timeoutSeconds * 1000}
        );
        
        if (response.status_code == 0) {
            throw ApiException("Request failed: " + response.error.message);
        }
        
        if (response.status_code == 401) {
            throw AuthenticationException("Unauthorized - invalid or expired token");
        }
        
        if (response.status_code == 500) {
            try {
                auto errorData = nlohmann::json::parse(response.text);
                if (errorData.contains("error")) {
                    std::string errorMessage = errorData["error"];
                    if (errorMessage == "GraphQL query failed") {
                        throw ApiException("GraphQL query failed");
                    } else if (errorMessage == "Failed to fetch user info") {
                        throw ApiException("Failed to fetch user info");
                    }
                }
            } catch (const nlohmann::json::exception&) {
                // Ignore JSON parsing errors for error responses
            }
        }
        
        if (!response.status_code == 200) {
            throw ApiException("HTTP error " + std::to_string(response.status_code) + ": " + response.text);
        }
        
        try {
            auto jsonData = nlohmann::json::parse(response.text);
            return jsonData.get<UserInfoResponse>();
        } catch (const nlohmann::json::exception& e) {
            throw ApiException("Failed to parse response: " + std::string(e.what()));
        }
    }
};

AuthdogClient::AuthdogClient(const ClientConfig& config) 
    : pImpl(std::make_unique<Impl>(config)) {
}

AuthdogClient::AuthdogClient(const std::string& baseUrl) 
    : AuthdogClient(ClientConfig{baseUrl}) {
}

AuthdogClient::~AuthdogClient() = default;

AuthdogClient::AuthdogClient(AuthdogClient&&) noexcept = default;
AuthdogClient& AuthdogClient::operator=(AuthdogClient&&) noexcept = default;

UserInfoResponse AuthdogClient::getUserInfo(const std::string& accessToken) {
    return pImpl->getUserInfo(accessToken);
}

void AuthdogClient::close() {
    // CPR doesn't require explicit cleanup
}

} // namespace authdog
