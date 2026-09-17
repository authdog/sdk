package authdog

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"time"
)

// Client represents the Authdog API client
type Client struct {
	baseURL    string
	apiKey     string
	httpClient *http.Client

	Organizations *OrganizationsService
	Tenants       *TenantsService
	Projects      *ProjectsService
	Environments  *EnvironmentsService
	Users         *UsersService
	Groups        *GroupsService
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

	c := &Client{
		baseURL:    config.BaseURL,
		apiKey:     config.APIKey,
		httpClient: httpClient,
	}
	c.Organizations = &OrganizationsService{client: c}
	c.Tenants = &TenantsService{client: c}
	c.Projects = &ProjectsService{client: c}
	c.Environments = &EnvironmentsService{client: c}
	c.Users = &UsersService{client: c}
	c.Groups = &GroupsService{client: c}
	return c
}

func (c *Client) authorization(accessToken string) string {
	token := c.apiKey
	if accessToken != "" {
		token = accessToken
	}
	if token == "" {
		return ""
	}
	return fmt.Sprintf("Bearer %s", token)
}

// request sends a JSON request. Constructor APIKey is used as Bearer unless
// accessToken is a non-empty override. GetUserInfo does not use this helper.
func (c *Client) request(ctx context.Context, method, path string, body interface{}, query url.Values, accessToken string) ([]byte, error) {
	reqURL := fmt.Sprintf("%s%s", c.baseURL, path)
	if len(query) > 0 {
		reqURL = fmt.Sprintf("%s?%s", reqURL, query.Encode())
	}

	var reader io.Reader
	if body != nil {
		encoded, err := json.Marshal(body)
		if err != nil {
			return nil, &APIError{Message: fmt.Sprintf("failed to marshal request: %v", err)}
		}
		reader = bytes.NewReader(encoded)
	}

	req, err := http.NewRequestWithContext(ctx, method, reqURL, reader)
	if err != nil {
		return nil, &APIError{Message: fmt.Sprintf("request failed: %v", err)}
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("User-Agent", "authdog-go-sdk/0.1.0")
	if auth := c.authorization(accessToken); auth != "" {
		req.Header.Set("Authorization", auth)
	}

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, &APIError{Message: fmt.Sprintf("request failed: %v", err)}
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, &APIError{Message: fmt.Sprintf("request failed: %v", err)}
	}

	if resp.StatusCode == http.StatusUnauthorized {
		return nil, &AuthenticationError{Message: "Unauthorized - invalid or expired token"}
	}

	if resp.StatusCode >= 400 {
		errorText := string(respBody)
		var errorResp ErrorResponse
		if err := json.Unmarshal(respBody, &errorResp); err == nil && errorResp.Error != "" {
			errorText = errorResp.Error
		}
		return nil, &APIError{
			Message:    fmt.Sprintf("HTTP error %d: %s", resp.StatusCode, errorText),
			StatusCode: resp.StatusCode,
		}
	}

	if len(bytes.TrimSpace(respBody)) == 0 {
		return []byte("{}"), nil
	}
	return respBody, nil
}

func (c *Client) requestJSON(ctx context.Context, method, path string, body interface{}, query url.Values, dest interface{}) error {
	data, err := c.request(ctx, method, path, body, query, "")
	if err != nil {
		return err
	}
	if dest == nil {
		return nil
	}
	if err := json.Unmarshal(data, dest); err != nil {
		return &APIError{Message: "Failed to parse response: invalid JSON"}
	}
	return nil
}

func (c *Client) requestMap(ctx context.Context, method, path string, body interface{}, query url.Values) (map[string]interface{}, error) {
	var dest map[string]interface{}
	if err := c.requestJSON(ctx, method, path, body, query, &dest); err != nil {
		return nil, err
	}
	if dest == nil {
		dest = map[string]interface{}{}
	}
	return dest, nil
}

// Health is a public liveness probe (GET /v1/health).
func (c *Client) Health(ctx context.Context) (*Probe, error) {
	var probe Probe
	if err := c.requestJSON(ctx, http.MethodGet, "/v1/health", nil, nil, &probe); err != nil {
		return nil, err
	}
	return &probe, nil
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

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, &APIError{Message: fmt.Sprintf("request failed: %v", err)}
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
