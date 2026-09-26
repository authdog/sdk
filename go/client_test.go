// MIT License
//
// Copyright (c) 2025 Authdog
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

package authdog

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

func TestNewClient(t *testing.T) {
	tests := []struct {
		name   string
		config ClientConfig
		want   *Client
	}{
		{
			name: "with API key",
			config: ClientConfig{
				BaseURL: "https://api.authdog.com",
				APIKey:  "test-api-key",
			},
			want: &Client{
				baseURL: "https://api.authdog.com",
				apiKey:  "test-api-key",
			},
		},
		{
			name: "without API key",
			config: ClientConfig{
				BaseURL: "https://api.authdog.com",
			},
			want: &Client{
				baseURL: "https://api.authdog.com",
				apiKey:  "",
			},
		},
		{
			name: "with custom timeout",
			config: ClientConfig{
				BaseURL: "https://api.authdog.com",
				Timeout: 30 * time.Second,
			},
			want: &Client{
				baseURL: "https://api.authdog.com",
				apiKey:  "",
			},
		},
		{
			name: "with custom HTTP client",
			config: ClientConfig{
				BaseURL:    "https://api.authdog.com",
				HTTPClient: &http.Client{Timeout: 5 * time.Second},
			},
			want: &Client{
				baseURL: "https://api.authdog.com",
				apiKey:  "",
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := NewClient(tt.config)
			if got.baseURL != tt.want.baseURL {
				t.Errorf("NewClient() baseURL = %v, want %v", got.baseURL, tt.want.baseURL)
			}
			if got.apiKey != tt.want.apiKey {
				t.Errorf("NewClient() apiKey = %v, want %v", got.apiKey, tt.want.apiKey)
			}
			if got.httpClient == nil {
				t.Error("NewClient() httpClient should not be nil")
			}
		})
	}
}

func TestClient_GetUserInfo_Success(t *testing.T) {
	// Mock response
	mockResponse := UserInfoResponse{
		Meta: Meta{
			Code:    200,
			Message: "OK",
		},
		User: User{
			ID:          "123",
			DisplayName: "Test User",
		},
	}

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Verify request details
		if r.URL.Path != "/v1/userinfo" {
			t.Errorf("Expected path /v1/userinfo, got %s", r.URL.Path)
		}
		if r.Method != "GET" {
			t.Errorf("Expected GET method, got %s", r.Method)
		}
		if r.Header.Get("Content-Type") != "application/json" {
			t.Errorf("Expected Content-Type application/json, got %s", r.Header.Get("Content-Type"))
		}
		if r.Header.Get("User-Agent") != "authdog-go-sdk/0.2.0" {
			t.Errorf("Expected User-Agent authdog-go-sdk/0.2.0, got %s", r.Header.Get("User-Agent"))
		}
		if r.Header.Get("Authorization") != "Bearer test-token" {
			t.Errorf("Expected Authorization Bearer test-token, got %s", r.Header.Get("Authorization"))
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(mockResponse); err != nil {
			t.Errorf("Failed to encode response: %v", err)
		}
	}))
	defer server.Close()

	client := NewClient(ClientConfig{
		BaseURL: server.URL,
	})

	ctx := context.Background()
	result, err := client.GetUserInfo(ctx, "test-token")

	if err != nil {
		t.Fatalf("GetUserInfo() error = %v, want nil", err)
	}
	if result.User.ID != "123" {
		t.Errorf("GetUserInfo() user ID = %v, want 123", result.User.ID)
	}
	if result.User.DisplayName != "Test User" {
		t.Errorf("GetUserInfo() user DisplayName = %v, want Test User", result.User.DisplayName)
	}
}

func TestClient_GetUserInfo_Unauthorized(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusUnauthorized)
	}))
	defer server.Close()

	client := NewClient(ClientConfig{
		BaseURL: server.URL,
	})

	ctx := context.Background()
	_, err := client.GetUserInfo(ctx, "invalid-token")

	if err == nil {
		t.Fatal("GetUserInfo() error = nil, want AuthenticationError")
	}
	if !IsAuthenticationError(err) {
		t.Errorf("GetUserInfo() error type = %T, want *AuthenticationError", err)
	}
	if !strings.Contains(err.Error(), "Unauthorized - invalid or expired token") {
		t.Errorf("GetUserInfo() error message = %v, want to contain 'Unauthorized - invalid or expired token'", err.Error())
	}
}

func TestClient_GetUserInfo_GraphQL_Error(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusInternalServerError)
		if err := json.NewEncoder(w).Encode(ErrorResponse{Error: "GraphQL query failed"}); err != nil {
			t.Errorf("Failed to encode response: %v", err)
		}
	}))
	defer server.Close()

	client := NewClient(ClientConfig{
		BaseURL: server.URL,
	})

	ctx := context.Background()
	_, err := client.GetUserInfo(ctx, "test-token")

	if err == nil {
		t.Fatal("GetUserInfo() error = nil, want APIError")
	}
	if !IsAPIError(err) {
		t.Errorf("GetUserInfo() error type = %T, want *APIError", err)
	}
	if !strings.Contains(err.Error(), "GraphQL query failed") {
		t.Errorf("GetUserInfo() error message = %v, want to contain 'GraphQL query failed'", err.Error())
	}
}

func TestClient_GetUserInfo_Fetch_Error(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusInternalServerError)
		if err := json.NewEncoder(w).Encode(ErrorResponse{Error: "Failed to fetch user info"}); err != nil {
			t.Errorf("Failed to encode response: %v", err)
		}
	}))
	defer server.Close()

	client := NewClient(ClientConfig{
		BaseURL: server.URL,
	})

	ctx := context.Background()
	_, err := client.GetUserInfo(ctx, "test-token")

	if err == nil {
		t.Fatal("GetUserInfo() error = nil, want APIError")
	}
	if !IsAPIError(err) {
		t.Errorf("GetUserInfo() error type = %T, want *APIError", err)
	}
	if !strings.Contains(err.Error(), "Failed to fetch user info") {
		t.Errorf("GetUserInfo() error message = %v, want to contain 'Failed to fetch user info'", err.Error())
	}
}

func TestClient_GetUserInfo_HTTP_Error(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusBadRequest)
		if _, err := w.Write([]byte("Bad Request")); err != nil {
			t.Errorf("Failed to write response: %v", err)
		}
	}))
	defer server.Close()

	client := NewClient(ClientConfig{
		BaseURL: server.URL,
	})

	ctx := context.Background()
	_, err := client.GetUserInfo(ctx, "test-token")

	if err == nil {
		t.Fatal("GetUserInfo() error = nil, want APIError")
	}
	if !IsAPIError(err) {
		t.Errorf("GetUserInfo() error type = %T, want *APIError", err)
	}
	if !strings.Contains(err.Error(), "HTTP error 400") {
		t.Errorf("GetUserInfo() error message = %v, want to contain 'HTTP error 400'", err.Error())
	}
}

func TestClient_GetUserInfo_Request_Error(t *testing.T) {
	// Create a client with invalid URL to simulate request error
	client := NewClient(ClientConfig{
		BaseURL: "http://invalid-url-that-does-not-exist",
		Timeout: 1 * time.Millisecond, // Very short timeout to force error
	})

	ctx := context.Background()
	_, err := client.GetUserInfo(ctx, "test-token")

	if err == nil {
		t.Fatal("GetUserInfo() error = nil, want request error")
	}
	if !IsAPIError(err) {
		t.Errorf("GetUserInfo() error type = %T, want *APIError", err)
	}
	if !strings.Contains(err.Error(), "request failed") {
		t.Errorf("GetUserInfo() error message = %v, want to contain 'request failed'", err.Error())
	}
}

func TestClient_GetUserInfo_With_API_Key(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Authorization") != "Bearer access-token" {
			t.Errorf("Expected Authorization Bearer access-token, got %s", r.Header.Get("Authorization"))
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(UserInfoResponse{
			Meta: Meta{Code: 200, Message: "OK"},
			User: User{ID: "123"},
		}); err != nil {
			t.Errorf("Failed to encode response: %v", err)
		}
	}))
	defer server.Close()

	client := NewClient(ClientConfig{
		BaseURL: server.URL,
		APIKey:  "test-api-key",
	})

	ctx := context.Background()
	result, err := client.GetUserInfo(ctx, "access-token")

	if err != nil {
		t.Fatalf("GetUserInfo() error = %v, want nil", err)
	}
	if result.User.ID != "123" {
		t.Errorf("GetUserInfo() user ID = %v, want 123", result.User.ID)
	}
}

func TestClient_Close(t *testing.T) {
	client := NewClient(ClientConfig{
		BaseURL: "https://api.authdog.com",
	})

	// Close should not panic
	client.Close()
}

func TestClient_Context_Cancellation(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Simulate slow response
		time.Sleep(100 * time.Millisecond)
		w.WriteHeader(http.StatusOK)
	}))
	defer server.Close()

	client := NewClient(ClientConfig{
		BaseURL: server.URL,
		Timeout: 1 * time.Second,
	})

	// Create a context that will be cancelled immediately
	ctx, cancel := context.WithCancel(context.Background())
	cancel() // Cancel immediately

	_, err := client.GetUserInfo(ctx, "test-token")

	if err == nil {
		t.Fatal("GetUserInfo() error = nil, want context cancelled error")
	}
	if !strings.Contains(err.Error(), "context canceled") {
		t.Errorf("GetUserInfo() error message = %v, want to contain 'context canceled'", err.Error())
	}
}

func TestClient_Timeout(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Simulate slow response
		time.Sleep(200 * time.Millisecond)
		w.WriteHeader(http.StatusOK)
	}))
	defer server.Close()

	client := NewClient(ClientConfig{
		BaseURL: server.URL,
		Timeout: 50 * time.Millisecond, // Shorter than server response time
	})

	ctx := context.Background()
	_, err := client.GetUserInfo(ctx, "test-token")

	if err == nil {
		t.Fatal("GetUserInfo() error = nil, want timeout error")
	}
	if !strings.Contains(err.Error(), "timeout") && !strings.Contains(err.Error(), "deadline exceeded") {
		t.Errorf("GetUserInfo() error message = %v, want to contain 'timeout' or 'deadline exceeded'", err.Error())
	}
}
