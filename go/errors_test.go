package authdog

import (
	"errors"
	"testing"
)

func TestAuthdogError(t *testing.T) {
	err := &AuthdogError{Message: "test error"}
	if err.Error() != "test error" {
		t.Errorf("AuthdogError.Error() = %v, want 'test error'", err.Error())
	}
}

func TestAuthenticationError(t *testing.T) {
	err := &AuthenticationError{Message: "authentication failed"}
	if err.Error() != "authentication failed" {
		t.Errorf("AuthenticationError.Error() = %v, want 'authentication failed'", err.Error())
	}
}

func TestAPIError(t *testing.T) {
	err := &APIError{Message: "API request failed"}
	if err.Error() != "API request failed" {
		t.Errorf("APIError.Error() = %v, want 'API request failed'", err.Error())
	}
}

func TestIsAuthenticationError(t *testing.T) {
	tests := []struct {
		name string
		err  error
		want bool
	}{
		{
			name: "AuthenticationError",
			err:  &AuthenticationError{Message: "auth failed"},
			want: true,
		},
		{
			name: "APIError",
			err:  &APIError{Message: "api failed"},
			want: false,
		},
		{
			name: "AuthdogError",
			err:  &AuthdogError{Message: "base error"},
			want: false,
		},
		{
			name: "standard error",
			err:  errors.New("standard error"),
			want: false,
		},
		{
			name: "nil error",
			err:  nil,
			want: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := IsAuthenticationError(tt.err)
			if got != tt.want {
				t.Errorf("IsAuthenticationError() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestIsAPIError(t *testing.T) {
	tests := []struct {
		name string
		err  error
		want bool
	}{
		{
			name: "APIError",
			err:  &APIError{Message: "api failed"},
			want: true,
		},
		{
			name: "AuthenticationError",
			err:  &AuthenticationError{Message: "auth failed"},
			want: false,
		},
		{
			name: "AuthdogError",
			err:  &AuthdogError{Message: "base error"},
			want: false,
		},
		{
			name: "standard error",
			err:  errors.New("standard error"),
			want: false,
		},
		{
			name: "nil error",
			err:  nil,
			want: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := IsAPIError(tt.err)
			if got != tt.want {
				t.Errorf("IsAPIError() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestIsAuthdogError(t *testing.T) {
	tests := []struct {
		name string
		err  error
		want bool
	}{
		{
			name: "AuthdogError",
			err:  &AuthdogError{Message: "base error"},
			want: true,
		},
		{
			name: "AuthenticationError",
			err:  &AuthenticationError{Message: "auth failed"},
			want: false,
		},
		{
			name: "APIError",
			err:  &APIError{Message: "api failed"},
			want: false,
		},
		{
			name: "standard error",
			err:  errors.New("standard error"),
			want: false,
		},
		{
			name: "nil error",
			err:  nil,
			want: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := IsAuthdogError(tt.err)
			if got != tt.want {
				t.Errorf("IsAuthdogError() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestErrorTypes(t *testing.T) {
	// Test that error types implement the error interface
	var _ error = (*AuthdogError)(nil)
	var _ error = (*AuthenticationError)(nil)
	var _ error = (*APIError)(nil)
}

func TestErrorWrapping(t *testing.T) {
	// Test that errors can be wrapped and unwrapped properly
	originalErr := &AuthenticationError{Message: "original error"}

	// Simulate error wrapping (common pattern in Go)
	wrappedErr := &AuthenticationError{Message: "wrapped: " + originalErr.Error()}

	if wrappedErr.Error() != "wrapped: original error" {
		t.Errorf("Error wrapping failed: got %v, want 'wrapped: original error'", wrappedErr.Error())
	}
}

func TestErrorComparison(t *testing.T) {
	err1 := &AuthenticationError{Message: "same message"}
	err2 := &AuthenticationError{Message: "same message"}
	err3 := &AuthenticationError{Message: "different message"}

	// Test that errors with same message are not equal (different instances)
	if err1 == err2 {
		t.Error("Different error instances should not be equal")
	}

	// Test that errors with different messages are not equal
	if err1 == err3 {
		t.Error("Errors with different messages should not be equal")
	}

	// Test that error messages are equal
	if err1.Error() != err2.Error() {
		t.Error("Errors with same message should have equal Error() output")
	}
}
