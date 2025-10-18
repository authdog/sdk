package authdog

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

func BenchmarkClient_GetUserInfo(b *testing.B) {
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
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(mockResponse); err != nil {
			b.Errorf("Failed to encode response: %v", err)
		}
	}))
	defer server.Close()

	client := NewClient(ClientConfig{
		BaseURL: server.URL,
	})

	ctx := context.Background()
	b.ResetTimer()

	for i := 0; i < b.N; i++ {
		_, err := client.GetUserInfo(ctx, "test-token")
		if err != nil {
			b.Fatalf("GetUserInfo() error = %v", err)
		}
	}
}

func BenchmarkClient_NewClient(b *testing.B) {
	config := ClientConfig{
		BaseURL: "https://api.authdog.com",
		APIKey:  "test-api-key",
		Timeout: 10 * time.Second,
	}

	b.ResetTimer()

	for i := 0; i < b.N; i++ {
		client := NewClient(config)
		_ = client // Prevent optimization
	}
}
