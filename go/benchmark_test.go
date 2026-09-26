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
