#include <iostream>
#include <string>
#include "authdog/authdog_client.h"
#include "authdog/exceptions.h"

int main() {
    try {
        // Initialize the client
        authdog::AuthdogClient client("https://api.authdog.com");
        
        // Get user information
        std::string accessToken = "your-access-token";
        auto userInfo = client.getUserInfo(accessToken);
        
        std::cout << "User: " << userInfo.user.displayName << std::endl;
        std::cout << "ID: " << userInfo.user.id << std::endl;
        std::cout << "Provider: " << userInfo.user.provider << std::endl;
        
        if (!userInfo.user.emails.empty()) {
            std::cout << "Email: " << userInfo.user.emails[0].value << std::endl;
        }
        
        // Close the client
        client.close();
        
    } catch (const authdog::AuthenticationException& e) {
        std::cerr << "Authentication failed: " << e.what() << std::endl;
        return 1;
    } catch (const authdog::ApiException& e) {
        std::cerr << "API error: " << e.what() << std::endl;
        return 1;
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}
