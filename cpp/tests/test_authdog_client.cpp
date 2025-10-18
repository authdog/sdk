#include <gtest/gtest.h>
#include "authdog/authdog_client.h"
#include "authdog/exceptions.h"
#include "authdog/types.h"

class AuthdogClientTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Set up test client
        authdog::ClientConfig config;
        config.baseUrl = "https://api.authdog.com";
        config.timeoutSeconds = 5;
        client = std::make_unique<authdog::AuthdogClient>(config);
    }
    
    void TearDown() override {
        client.reset();
    }
    
    std::unique_ptr<authdog::AuthdogClient> client;
};

// Constructor Tests
TEST_F(AuthdogClientTest, ConstructorWithBaseUrl) {
    authdog::AuthdogClient testClient("https://api.authdog.com");
    EXPECT_NO_THROW(testClient.close());
}

TEST_F(AuthdogClientTest, ConstructorWithConfig) {
    authdog::ClientConfig config;
    config.baseUrl = "https://api.authdog.com";
    config.timeoutSeconds = 5;
    
    authdog::AuthdogClient testClient(config);
    EXPECT_NO_THROW(testClient.close());
}

TEST_F(AuthdogClientTest, ConstructorWithEmptyBaseUrl) {
    // Empty base URL should be handled gracefully
    authdog::AuthdogClient testClient("");
    EXPECT_NO_THROW(testClient.close());
}

TEST_F(AuthdogClientTest, ConstructorWithInvalidBaseUrl) {
    // Invalid URL should be handled gracefully
    authdog::AuthdogClient testClient("invalid-url");
    EXPECT_NO_THROW(testClient.close());
}

// Move Semantics Tests
TEST_F(AuthdogClientTest, MoveConstructor) {
    authdog::AuthdogClient originalClient("https://api.authdog.com");
    authdog::AuthdogClient movedClient = std::move(originalClient);
    
    EXPECT_NO_THROW(movedClient.close());
}

TEST_F(AuthdogClientTest, MoveAssignment) {
    authdog::AuthdogClient client1("https://api.authdog.com");
    authdog::AuthdogClient client2("https://api.authdog.com");
    
    client2 = std::move(client1);
    
    EXPECT_NO_THROW(client2.close());
}

// Configuration Tests
TEST_F(AuthdogClientTest, CustomTimeout) {
    authdog::ClientConfig config;
    config.baseUrl = "https://api.authdog.com";
    config.timeoutSeconds = 30;
    
    authdog::AuthdogClient testClient(config);
    EXPECT_NO_THROW(testClient.close());
}

TEST_F(AuthdogClientTest, ZeroTimeout) {
    authdog::ClientConfig config;
    config.baseUrl = "https://api.authdog.com";
    config.timeoutSeconds = 0;
    
    // Zero timeout should be handled gracefully
    authdog::AuthdogClient testClient(config);
    EXPECT_NO_THROW(testClient.close());
}

TEST_F(AuthdogClientTest, NegativeTimeout) {
    authdog::ClientConfig config;
    config.baseUrl = "https://api.authdog.com";
    config.timeoutSeconds = -1;
    
    // Negative timeout should be handled gracefully
    authdog::AuthdogClient testClient(config);
    EXPECT_NO_THROW(testClient.close());
}

// API Key Tests
TEST_F(AuthdogClientTest, ConstructorWithApiKey) {
    authdog::ClientConfig config;
    config.baseUrl = "https://api.authdog.com";
    config.apiKey = "test-api-key";
    
    authdog::AuthdogClient testClient(config);
    EXPECT_NO_THROW(testClient.close());
}

TEST_F(AuthdogClientTest, EmptyApiKey) {
    authdog::ClientConfig config;
    config.baseUrl = "https://api.authdog.com";
    config.apiKey = "";
    
    authdog::AuthdogClient testClient(config);
    EXPECT_NO_THROW(testClient.close());
}

// User Info Tests
TEST_F(AuthdogClientTest, GetUserInfoWithEmptyToken) {
    EXPECT_THROW({
        client->getUserInfo("");
    }, authdog::ApiException);
}

TEST_F(AuthdogClientTest, GetUserInfoWithInvalidToken) {
    EXPECT_THROW({
        client->getUserInfo("invalid-token");
    }, authdog::ApiException);
}

TEST_F(AuthdogClientTest, GetUserInfoWithValidTokenFormat) {
    // This test would require a valid token or mock server
    // For now, we'll test the exception handling
    EXPECT_THROW({
        client->getUserInfo("valid-token-format");
    }, authdog::ApiException);
}

// Error Handling Tests
TEST_F(AuthdogClientTest, NetworkErrorHandling) {
    authdog::ClientConfig config;
    config.baseUrl = "https://nonexistent-domain-12345.com";
    config.timeoutSeconds = 1;
    
    authdog::AuthdogClient testClient(config);
    
    EXPECT_THROW({
        testClient.getUserInfo("test-token");
    }, authdog::ApiException);
}

// Resource Management Tests
TEST_F(AuthdogClientTest, MultipleClientInstances) {
    const int num_clients = 5;
    std::vector<std::unique_ptr<authdog::AuthdogClient>> clients;
    
    for (int i = 0; i < num_clients; ++i) {
        authdog::ClientConfig config;
        config.baseUrl = "https://api.authdog.com";
        config.timeoutSeconds = 5;
        
        clients.push_back(std::make_unique<authdog::AuthdogClient>(config));
    }
    
    // All clients should be created successfully
    EXPECT_EQ(clients.size(), num_clients);
    
    // All clients should be closable
    for (auto& client : clients) {
        EXPECT_NO_THROW(client->close());
    }
}
