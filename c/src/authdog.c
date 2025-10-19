#include "authdog.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <curl/curl.h>

// Internal structures
struct authdog_client {
    authdog_config_t config;
    CURL *curl;
};

// Response buffer structure for libcurl
typedef struct {
    char *data;
    size_t size;
} response_buffer_t;

// Callback function for libcurl to write response data
static size_t write_callback(void *contents, size_t size, size_t nmemb, response_buffer_t *buffer) {
    size_t total_size = size * nmemb;
    
    char *ptr = realloc(buffer->data, buffer->size + total_size + 1);
    if (!ptr) {
        return 0;
    }
    
    buffer->data = ptr;
    memcpy(&(buffer->data[buffer->size]), contents, total_size);
    buffer->size += total_size;
    buffer->data[buffer->size] = 0;
    
    return total_size;
}

// Parse JSON response (simple implementation)
static authdog_error_t parse_user_info(const char *json, authdog_user_info_t **user_info) {
    if (!json || !user_info) {
        return AUTHDOG_ERROR_INVALID_PARAM;
    }
    
    *user_info = malloc(sizeof(authdog_user_info_t));
    if (!*user_info) {
        return AUTHDOG_ERROR_MEMORY_ALLOCATION;
    }
    
    memset(*user_info, 0, sizeof(authdog_user_info_t));
    
    // Simple JSON parsing - in a real implementation, use a proper JSON library
    const char *id_start = strstr(json, "\"id\":\"");
    const char *email_start = strstr(json, "\"email\":\"");
    const char *name_start = strstr(json, "\"name\":\"");
    const char *photo_start = strstr(json, "\"photo_url\":\"");
    
    if (id_start) {
        id_start += 6; // Skip "id":"
        const char *id_end = strchr(id_start, '"');
        if (id_end) {
            size_t id_len = id_end - id_start;
            (*user_info)->id = malloc(id_len + 1);
            if ((*user_info)->id) {
                strncpy((*user_info)->id, id_start, id_len);
                (*user_info)->id[id_len] = '\0';
            }
        }
    }
    
    if (email_start) {
        email_start += 8; // Skip "email":"
        const char *email_end = strchr(email_start, '"');
        if (email_end) {
            size_t email_len = email_end - email_start;
            (*user_info)->email = malloc(email_len + 1);
            if ((*user_info)->email) {
                strncpy((*user_info)->email, email_start, email_len);
                (*user_info)->email[email_len] = '\0';
            }
        }
    }
    
    if (name_start) {
        name_start += 7; // Skip "name":"
        const char *name_end = strchr(name_start, '"');
        if (name_end) {
            size_t name_len = name_end - name_start;
            (*user_info)->name = malloc(name_len + 1);
            if ((*user_info)->name) {
                strncpy((*user_info)->name, name_start, name_len);
                (*user_info)->name[name_len] = '\0';
            }
        }
    }
    
    if (photo_start) {
        photo_start += 12; // Skip "photo_url":"
        const char *photo_end = strchr(photo_start, '"');
        if (photo_end) {
            size_t photo_len = photo_end - photo_start;
            (*user_info)->photo_url = malloc(photo_len + 1);
            if ((*user_info)->photo_url) {
                strncpy((*user_info)->photo_url, photo_start, photo_len);
                (*user_info)->photo_url[photo_len] = '\0';
            }
        }
    }
    
    return AUTHDOG_SUCCESS;
}

authdog_client_t* authdog_client_create(const authdog_config_t *config) {
    if (!config || !config->base_url) {
        return NULL;
    }
    
    authdog_client_t *client = malloc(sizeof(authdog_client_t));
    if (!client) {
        return NULL;
    }
    
    memset(client, 0, sizeof(authdog_client_t));
    
    // Copy configuration
    client->config.base_url = strdup(config->base_url);
    if (config->access_token) {
        client->config.access_token = strdup(config->access_token);
    }
    if (config->api_key) {
        client->config.api_key = strdup(config->api_key);
    }
    client->config.timeout_ms = config->timeout_ms > 0 ? config->timeout_ms : 30000;
    
    // Initialize curl
    client->curl = curl_easy_init();
    if (!client->curl) {
        authdog_client_destroy(client);
        return NULL;
    }
    
    return client;
}

void authdog_client_destroy(authdog_client_t *client) {
    if (!client) {
        return;
    }
    
    if (client->curl) {
        curl_easy_cleanup(client->curl);
    }
    
    if (client->config.base_url) {
        free(client->config.base_url);
    }
    if (client->config.access_token) {
        free(client->config.access_token);
    }
    if (client->config.api_key) {
        free(client->config.api_key);
    }
    
    free(client);
}

authdog_error_t authdog_get_user_info(authdog_client_t *client, authdog_user_info_t **user_info) {
    if (!client || !user_info) {
        return AUTHDOG_ERROR_INVALID_PARAM;
    }
    
    CURL *curl = client->curl;
    CURLcode res;
    response_buffer_t buffer = {0};
    struct curl_slist *headers = NULL;
    
    // Build URL
    char url[1024];
    snprintf(url, sizeof(url), "%s/v1/userinfo", client->config.base_url);
    
    // Set headers
    headers = curl_slist_append(headers, "Content-Type: application/json");
    headers = curl_slist_append(headers, "User-Agent: authdog-c-sdk/0.1.0");
    
    const char *token = client->config.api_key ? client->config.api_key : client->config.access_token;
    if (token) {
        char auth_header[256];
        snprintf(auth_header, sizeof(auth_header), "Authorization: Bearer %s", token);
        headers = curl_slist_append(headers, auth_header);
    }
    
    // Configure curl
    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &buffer);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT_MS, client->config.timeout_ms);
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    
    // Perform request
    res = curl_easy_perform(curl);
    
    // Clean up headers
    curl_slist_free_all(headers);
    
    if (res != CURLE_OK) {
        free(buffer.data);
        return AUTHDOG_ERROR_NETWORK;
    }
    
    // Check HTTP status code
    long http_code = 0;
    curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &http_code);
    
    if (http_code == 401) {
        free(buffer.data);
        return AUTHDOG_ERROR_AUTHENTICATION;
    } else if (http_code >= 500) {
        free(buffer.data);
        return AUTHDOG_ERROR_SERVER;
    } else if (http_code != 200) {
        free(buffer.data);
        return AUTHDOG_ERROR_UNKNOWN;
    }
    
    // Parse response
    authdog_error_t error = parse_user_info(buffer.data, user_info);
    free(buffer.data);
    
    return error;
}

void authdog_user_info_free(authdog_user_info_t *user_info) {
    if (!user_info) {
        return;
    }
    
    if (user_info->id) {
        free(user_info->id);
    }
    if (user_info->email) {
        free(user_info->email);
    }
    if (user_info->name) {
        free(user_info->name);
    }
    if (user_info->photo_url) {
        free(user_info->photo_url);
    }
    
    free(user_info);
}

const char* authdog_error_message(authdog_error_t error) {
    switch (error) {
        case AUTHDOG_SUCCESS:
            return "Success";
        case AUTHDOG_ERROR_INVALID_PARAM:
            return "Invalid parameter";
        case AUTHDOG_ERROR_MEMORY_ALLOCATION:
            return "Memory allocation failed";
        case AUTHDOG_ERROR_NETWORK:
            return "Network error";
        case AUTHDOG_ERROR_AUTHENTICATION:
            return "Authentication failed";
        case AUTHDOG_ERROR_SERVER:
            return "Server error";
        case AUTHDOG_ERROR_UNKNOWN:
        default:
            return "Unknown error";
    }
}
