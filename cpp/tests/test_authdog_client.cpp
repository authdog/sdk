#include <gtest/gtest.h>
#include "authdog/authdog_client.h"
#include "authdog/exceptions.h"

class AuthdogClientTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Set up test client
        authdog::ClientConfig config;
        config.baseUrl = "https://api.authdog.com";
        client = std::make_unique<authdog::AuthdogClient>(config);
    }
    
    void TearDown() override {
        client.reset();
    }
    
    std::unique_ptr<authdog::AuthdogClient> client;
};

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

TEST_F(AuthdogClientTest, GetUserInfoWithInvalidToken) {
    EXPECT_THROW({
        try {
            client->getUserInfo("invalid-token");
        } catch (const authdog::AuthenticationException& e) {
            EXPECT_STREQ(e.what(), "Unauthorized - invalid or expired token");
            throw;
        }
    }, authdog::AuthenticationException);
}

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
