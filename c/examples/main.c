#include "authdog.h"
#include <stdio.h>
#include <stdlib.h>

int main() {
    printf("Authdog C SDK Example\n");
    printf("====================\n\n");
    
    // Create client configuration
    authdog_config_t config = {
        .base_url = "https://api.authdog.com",
        .access_token = "your_access_token_here",
        .api_key = NULL,
        .timeout_ms = 10000
    };
    
    // Create client
    authdog_client_t *client = authdog_client_create(&config);
    if (!client) {
        printf("Failed to create client\n");
        return 1;
    }
    
    printf("Client created successfully\n");
    
    // Get user info
    authdog_user_info_t *user_info = NULL;
    authdog_error_t error = authdog_get_user_info(client, &user_info);
    
    if (error == AUTHDOG_SUCCESS && user_info) {
        printf("User info retrieved successfully:\n");
        printf("  ID: %s\n", user_info->id ? user_info->id : "N/A");
        printf("  Email: %s\n", user_info->email ? user_info->email : "N/A");
        printf("  Name: %s\n", user_info->name ? user_info->name : "N/A");
        printf("  Photo URL: %s\n", user_info->photo_url ? user_info->photo_url : "N/A");
        
        authdog_user_info_free(user_info);
    } else {
        printf("Failed to get user info: %s\n", authdog_error_message(error));
    }
    
    // Clean up
    authdog_client_destroy(client);
    
    printf("\nExample completed\n");
    return 0;
}
