package authdog

import "fmt"

// AuthdogError represents the base error type for all Authdog SDK errors
type AuthdogError struct {
	Message string
}

func (e *AuthdogError) Error() string {
	return e.Message
}

// AuthenticationError represents authentication failures
type AuthenticationError struct {
	Message string
}

func (e *AuthenticationError) Error() string {
	return e.Message
}

// APIError represents API request failures
type APIError struct {
	Message string
}

func (e *APIError) Error() string {
	return e.Message
}

// Helper functions to check error types
func IsAuthenticationError(err error) bool {
	_, ok := err.(*AuthenticationError)
	return ok
}

func IsAPIError(err error) bool {
	_, ok := err.(*APIError)
	return ok
}

func IsAuthdogError(err error) bool {
	_, ok := err.(*AuthdogError)
	return ok
}
