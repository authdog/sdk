package authdog

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
	Message    string
	StatusCode int
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
	switch err.(type) {
	case *AuthdogError, *AuthenticationError, *APIError:
		return true
	default:
		return false
	}
}
