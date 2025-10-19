#include "authdog.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Test configuration
#define TEST_BASE_URL "https://api.authdog.com"
#define TEST_ACCESS_TOKEN "test_token"
#define TEST_API_KEY "test_api_key"

// Mock test data
static const char* mock_user_info_json = 
    "{\"id\":\"123\",\"email\":\"test@example.com\",\"name\":\"Test User\",\"photo_url\":\"https://example.com/photo.jpg\"}";

// Test helper functions
static void test_client_creation() {
    printf("Testing client creation...\n");
    
    authdog_config_t config = {
        .base_url = TEST_BASE_URL,
        .access_token = TEST_ACCESS_TOKEN,
        .api_key = NULL,
        .timeout_ms = 5000
    };
    
    authdog_client_t *client = authdog_client_create(&config);
    assert(client != NULL);
    assert(strcmp(client->config.base_url, TEST_BASE_URL) == 0);
    assert(strcmp(client->config.access_token, TEST_ACCESS_TOKEN) == 0);
    assert(client->config.timeout_ms == 5000);
    
    authdog_client_destroy(client);
    printf("✓ Client creation test passed\n");
}

static void test_client_creation_invalid_params() {
    printf("Testing client creation with invalid parameters...\n");
    
    // Test NULL config
    authdog_client_t *client = authdog_client_create(NULL);
    assert(client == NULL);
    
    // Test NULL base_url
    authdog_config_t config = {
        .base_url = NULL,
        .access_token = TEST_ACCESS_TOKEN,
        .api_key = NULL,
        .timeout_ms = 5000
    };
    
    client = authdog_client_create(&config);
    assert(client == NULL);
    
    printf("✓ Invalid parameters test passed\n");
}

static void test_user_info_free_null() {
    printf("Testing user info free with NULL...\n");
    
    // Test NULL pointer
    authdog_user_info_free(NULL);
    
    printf("✓ User info free NULL test passed\n");
}

static void test_error_messages() {
    printf("Testing error messages...\n");
    
    assert(strcmp(authdog_error_message(AUTHDOG_SUCCESS), "Success") == 0);
    assert(strcmp(authdog_error_message(AUTHDOG_ERROR_INVALID_PARAM), "Invalid parameter") == 0);
    assert(strcmp(authdog_error_message(AUTHDOG_ERROR_MEMORY_ALLOCATION), "Memory allocation failed") == 0);
    assert(strcmp(authdog_error_message(AUTHDOG_ERROR_NETWORK), "Network error") == 0);
    assert(strcmp(authdog_error_message(AUTHDOG_ERROR_AUTHENTICATION), "Authentication failed") == 0);
    assert(strcmp(authdog_error_message(AUTHDOG_ERROR_SERVER), "Server error") == 0);
    assert(strcmp(authdog_error_message(AUTHDOG_ERROR_UNKNOWN), "Unknown error") == 0);
    
    printf("✓ Error messages test passed\n");
}

static void test_user_info_free() {
    printf("Testing user info free...\n");
    
    authdog_user_info_t *user_info = malloc(sizeof(authdog_user_info_t));
    user_info->id = strdup("123");
    user_info->email = strdup("test@example.com");
    user_info->name = strdup("Test User");
    user_info->photo_url = strdup("https://example.com/photo.jpg");
    
    authdog_user_info_free(user_info);
    
    printf("✓ User info free test passed\n");
}

int main() {
    printf("Running Authdog C SDK tests...\n\n");
    
    test_client_creation();
    test_client_creation_invalid_params();
    test_user_info_free_null();
    test_error_messages();
    test_user_info_free();
    
    printf("\nAll tests passed! ✓\n");
    return 0;
}
