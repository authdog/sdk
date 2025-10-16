package authdog

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

// Client represents the Authdog API client
type Client struct {
	baseURL    string
	apiKey     string
	httpClient *http.Client
}

// ClientConfig holds configuration for the Authdog client
type ClientConfig struct {
	BaseURL    string
	APIKey     string
	Timeout    time.Duration
	HTTPClient *http.Client
}

// NewClient creates a new Authdog client
func NewClient(config ClientConfig) *Client {
	httpClient := config.HTTPClient
	if httpClient == nil {
		timeout := config.Timeout
		if timeout == 0 {
			timeout = 10 * time.Second
		}
		httpClient = &http.Client{
			Timeout: timeout,
		}
	}

	return &Client{
		baseURL:    config.BaseURL,
		apiKey:     config.APIKey,
		httpClient: httpClient,
	}
}

// GetUserInfo retrieves user information using an access token
func (c *Client) GetUserInfo(ctx context.Context, accessToken string) (*UserInfoResponse, error) {
	url := fmt.Sprintf("%s/v1/userinfo", c.baseURL)
	
	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	// Set headers
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("User-Agent", "authdog-go-sdk/0.1.0")
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", accessToken))

	// Add API key if provided
	if c.apiKey != "" {
		req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", c.apiKey))
	}

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body: %w", err)
	}

	switch resp.StatusCode {
	case http.StatusOK:
		var userInfo UserInfoResponse
		if err := json.Unmarshal(body, &userInfo); err != nil {
			return nil, fmt.Errorf("failed to unmarshal response: %w", err)
		}
		return &userInfo, nil
	case http.StatusUnauthorized:
		return nil, &AuthenticationError{Message: "Unauthorized - invalid or expired token"}
	case http.StatusInternalServerError:
		var errorResp ErrorResponse
		if err := json.Unmarshal(body, &errorResp); err == nil {
			if errorResp.Error == "GraphQL query failed" {
				return nil, &APIError{Message: "GraphQL query failed"}
			} else if errorResp.Error == "Failed to fetch user info" {
				return nil, &APIError{Message: "Failed to fetch user info"}
			}
		}
		return nil, &APIError{Message: fmt.Sprintf("HTTP error %d: %s", resp.StatusCode, string(body))}
	default:
		return nil, &APIError{Message: fmt.Sprintf("HTTP error %d: %s", resp.StatusCode, string(body))}
	}
}

// Close closes the HTTP client (for cleanup)
func (c *Client) Close() {
	// HTTP client doesn't need explicit cleanup in Go
}
