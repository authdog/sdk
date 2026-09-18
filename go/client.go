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
	baseURL           string
	apiKey            string
	environmentSecret string
	scimToken         string
	hrisToken         string
	httpClient        *http.Client

	Organizations        *OrganizationsService
	Tenants              *TenantsService
	Projects             *ProjectsService
	Environments         *EnvironmentsService
	Users                *UsersService
	Groups               *GroupsService
	Rbac                 *RbacService
	Audit                *AuditService
	Events               *EventsService
	Webhooks             *WebhooksService
	NotificationChannels *NotificationChannelsService
	ServiceAccounts      *ServiceAccountsService
	PersonalAccessTokens *PersonalAccessTokensService
	ApiSecrets           *ApiSecretsService
	Authzen              *AuthzenService
	Scim                 *ScimService
	Hris                 *HrisService
	Mcp                  *McpService
	Otel                 *OtelService
	OidcClients          *OidcClientsService
	Actions              *ActionsService
	Addons               *AddonsService
	Billing              *BillingService
	Settings             *SettingsService
	Elevate              *ElevateService
	EmailProviders       *EmailProvidersService
	FeatureFlags         *FeatureFlagsService
	Forms                *FormsService
	ProvisioningTokens   *ProvisioningTokensService
	Impersonation        *ImpersonationService
	Portal               *PortalService
	Security             *SecurityService
	Threats              *ThreatsService
	VanityDomains        *VanityDomainsService
	Widgets              *WidgetsService
}

// ClientConfig holds configuration for the Authdog client
type ClientConfig struct {
	BaseURL           string
	APIKey            string
	Timeout           time.Duration
	HTTPClient        *http.Client
	EnvironmentSecret string
	SCIMToken         string
	HRISToken         string
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
		baseURL:           config.BaseURL,
		apiKey:            config.APIKey,
		environmentSecret: config.EnvironmentSecret,
		scimToken:         config.SCIMToken,
		hrisToken:         config.HRISToken,
		httpClient:        httpClient,
	}
	c.Organizations = &OrganizationsService{client: c}
	c.Tenants = &TenantsService{client: c}
	c.Projects = &ProjectsService{client: c}
	c.Environments = &EnvironmentsService{client: c}
	c.Users = &UsersService{client: c}
	c.Groups = &GroupsService{client: c}
	c.Rbac = &RbacService{client: c}
	c.Audit = &AuditService{client: c}
	c.Events = &EventsService{client: c}
	c.Webhooks = &WebhooksService{client: c}
	c.NotificationChannels = &NotificationChannelsService{client: c}
	c.ServiceAccounts = &ServiceAccountsService{client: c}
	c.PersonalAccessTokens = &PersonalAccessTokensService{client: c}
	c.ApiSecrets = &ApiSecretsService{client: c}
	c.Authzen = &AuthzenService{client: c}
	c.Scim = &ScimService{client: c}
	c.Hris = &HrisService{client: c}
	c.Mcp = &McpService{client: c}
	c.Otel = &OtelService{client: c}
	c.OidcClients = &OidcClientsService{client: c}
	c.Actions = &ActionsService{client: c}
	c.Addons = &AddonsService{client: c}
	c.Billing = &BillingService{client: c}
	c.Settings = &SettingsService{client: c}
	c.Elevate = &ElevateService{client: c}
	c.EmailProviders = &EmailProvidersService{client: c}
	c.FeatureFlags = &FeatureFlagsService{client: c}
	c.Forms = &FormsService{client: c}
	c.ProvisioningTokens = &ProvisioningTokensService{client: c}
	c.Impersonation = &ImpersonationService{client: c}
	c.Portal = &PortalService{client: c}
	c.Security = &SecurityService{client: c}
	c.Threats = &ThreatsService{client: c}
	c.VanityDomains = &VanityDomainsService{client: c}
	c.Widgets = &WidgetsService{client: c}
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
// accessToken is a non-empty override. If omitAuth is true, Authorization is
// omitted entirely even when APIKey is set. GetUserInfo does not use this helper.
func (c *Client) request(ctx context.Context, method, path string, body interface{}, query url.Values, accessToken string, omitAuth bool) ([]byte, error) {
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
	if !omitAuth {
		if auth := c.authorization(accessToken); auth != "" {
			req.Header.Set("Authorization", auth)
		}
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
	return c.requestJSONToken(ctx, method, path, body, query, "", dest)
}

func (c *Client) requestJSONToken(ctx context.Context, method, path string, body interface{}, query url.Values, accessToken string, dest interface{}) error {
	data, err := c.request(ctx, method, path, body, query, accessToken, false)
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
	return c.requestMapToken(ctx, method, path, body, query, "")
}

func (c *Client) requestMapToken(ctx context.Context, method, path string, body interface{}, query url.Values, accessToken string) (map[string]interface{}, error) {
	var dest map[string]interface{}
	if err := c.requestJSONToken(ctx, method, path, body, query, accessToken, &dest); err != nil {
		return nil, err
	}
	if dest == nil {
		dest = map[string]interface{}{}
	}
	return dest, nil
}

func (c *Client) requestMapOmitAuth(ctx context.Context, method, path string, body interface{}, query url.Values) (map[string]interface{}, error) {
	data, err := c.request(ctx, method, path, body, query, "", true)
	if err != nil {
		return nil, err
	}
	var dest map[string]interface{}
	if err := json.Unmarshal(data, &dest); err != nil {
		return nil, &APIError{Message: "Failed to parse response: invalid JSON"}
	}
	if dest == nil {
		dest = map[string]interface{}{}
	}
	return dest, nil
}

func (c *Client) pickToken(override, fallback string) string {
	if override != "" {
		return override
	}
	return fallback
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
