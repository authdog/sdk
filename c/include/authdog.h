#ifndef AUTHDOG_H
#define AUTHDOG_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h>
#include <stdint.h>

// Error codes
typedef enum {
    AUTHDOG_SUCCESS = 0,
    AUTHDOG_ERROR_INVALID_PARAM = -1,
    AUTHDOG_ERROR_MEMORY_ALLOCATION = -2,
    AUTHDOG_ERROR_NETWORK = -3,
    AUTHDOG_ERROR_AUTHENTICATION = -4,
    AUTHDOG_ERROR_SERVER = -5,
    AUTHDOG_ERROR_UNKNOWN = -99
} authdog_error_t;

// User info structure
typedef struct {
    char *id;
    char *email;
    char *name;
    char *photo_url;
} authdog_user_info_t;

// Client configuration
typedef struct {
    char *base_url;
    char *access_token;
    char *api_key;
    int timeout_ms;
} authdog_config_t;

// Client handle
typedef struct authdog_client authdog_client_t;

/**
 * Create a new Authdog client
 * @param config Client configuration
 * @return Client handle or NULL on error
 */
authdog_client_t* authdog_client_create(const authdog_config_t *config);

/**
 * Destroy an Authdog client
 * @param client Client handle
 */
void authdog_client_destroy(authdog_client_t *client);

/**
 * Get user information
 * @param client Client handle
 * @param user_info Output parameter for user info
 * @return Error code
 */
authdog_error_t authdog_get_user_info(authdog_client_t *client, authdog_user_info_t **user_info);

/**
 * Free user info structure
 * @param user_info User info to free
 */
void authdog_user_info_free(authdog_user_info_t *user_info);

/**
 * Get error message for error code
 * @param error Error code
 * @return Error message string
 */
const char* authdog_error_message(authdog_error_t error);

#ifdef __cplusplus
}
#endif

#endif // AUTHDOG_H
