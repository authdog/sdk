package authdog

import (
	"context"
	"net/http"
	"net/url"
)

func optionalToken(tokens []string) string {
	if len(tokens) > 0 {
		return tokens[0]
	}
	return ""
}

// SSOMetadataOptions are optional query parameters for Environments.GetSSOMetadata.
type SSOMetadataOptions struct {
	ConnectionID string
	ProviderID   string
}

// ActionsExecutionsOptions are optional query parameters for Actions.Executions.
type ActionsExecutionsOptions struct {
	ActionID string
	Limit    *int
}

func (s *EnvironmentsService) ListConnections(ctx context.Context, tenantID, applicationID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/tenants/"+tenantID+"/applications/"+applicationID+"/environments/"+environmentID+"/connections", nil, nil)
}

func (s *EnvironmentsService) ListRedirectURIs(ctx context.Context, tenantID, applicationID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/tenants/"+tenantID+"/applications/"+applicationID+"/environments/"+environmentID+"/redirect-uris", nil, nil)
}

func (s *EnvironmentsService) SaveConnection(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/connections", body, nil)
}

func (s *EnvironmentsService) ResolveSAMLMetadata(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/connections/resolve-saml-metadata", body, nil)
}

func (s *EnvironmentsService) GetSSOMetadata(ctx context.Context, tenantID, environmentID string, opts *SSOMetadataOptions) (map[string]interface{}, error) {
	q := url.Values{}
	if opts != nil {
		if opts.ConnectionID != "" {
			q.Set("connectionId", opts.ConnectionID)
		}
		if opts.ProviderID != "" {
			q.Set("providerId", opts.ProviderID)
		}
	}
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/connections/sso-metadata", nil, q)
}

func (s *EnvironmentsService) DeleteConnection(ctx context.Context, tenantID, environmentID, connectionID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/connections/"+connectionID, nil, nil)
}

func (s *EnvironmentsService) SaveRedirectURIs(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPut, envPath(tenantID, environmentID)+"/redirect-uris", body, nil)
}

func (s *UsersService) RevokeSession(ctx context.Context, environmentID, sessionID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, "/v1/environments/"+environmentID+"/sessions/"+sessionID, nil, nil)
}

func (s *UsersService) TOTPStatus(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/me/mfa/totp", nil, nil)
}

func (s *UsersService) BulkDelete(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/users/bulk/delete", body, nil)
}

func (s *UsersService) BulkSetActive(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/users/bulk/set-active", body, nil)
}

func (s *UsersService) ImportUsers(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/users/import", body, nil)
}

func (s *UsersService) DisableMFA(ctx context.Context, tenantID, environmentID, userID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/users/"+userID+"/mfa", nil, nil)
}

func (s *UsersService) ListSessions(ctx context.Context, tenantID, environmentID, userID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/users/"+userID+"/sessions", nil, nil)
}

// AuthzenService is the AuthZEN discovery and evaluation namespace.
type AuthzenService struct {
	client *Client
}

func (s *AuthzenService) Configuration(ctx context.Context) (map[string]interface{}, error) {
	return s.client.requestMapOmitAuth(ctx, http.MethodGet, "/.well-known/authzen-configuration", nil, nil)
}

func (s *AuthzenService) Evaluate(ctx context.Context, body interface{}, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodPost, "/access/v1/evaluation", body, nil, s.client.pickToken(optionalToken(token), s.client.environmentSecret))
}

func (s *AuthzenService) EvaluateBatch(ctx context.Context, body interface{}, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodPost, "/access/v1/evaluations", body, nil, s.client.pickToken(optionalToken(token), s.client.environmentSecret))
}

func (s *AuthzenService) SearchAction(ctx context.Context, body interface{}, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodPost, "/access/v1/search/action", body, nil, s.client.pickToken(optionalToken(token), s.client.environmentSecret))
}

func (s *AuthzenService) SearchResource(ctx context.Context, body interface{}, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodPost, "/access/v1/search/resource", body, nil, s.client.pickToken(optionalToken(token), s.client.environmentSecret))
}

func (s *AuthzenService) SearchSubject(ctx context.Context, body interface{}, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodPost, "/access/v1/search/subject", body, nil, s.client.pickToken(optionalToken(token), s.client.environmentSecret))
}

// ScimService is the SCIM 2.0 namespace.
type ScimService struct {
	client *Client
}

func (s *ScimService) token(override []string) string {
	return s.client.pickToken(optionalToken(override), s.client.scimToken)
}

func (s *ScimService) ListUsers(ctx context.Context, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodGet, "/v1/scim/v2/Users", nil, nil, s.token(token))
}

func (s *ScimService) CreateUser(ctx context.Context, body interface{}, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodPost, "/v1/scim/v2/Users", body, nil, s.token(token))
}

func (s *ScimService) GetUser(ctx context.Context, userID string, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodGet, "/v1/scim/v2/Users/"+userID, nil, nil, s.token(token))
}

func (s *ScimService) ReplaceUser(ctx context.Context, userID string, body interface{}, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodPut, "/v1/scim/v2/Users/"+userID, body, nil, s.token(token))
}

func (s *ScimService) PatchUser(ctx context.Context, userID string, body interface{}, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodPatch, "/v1/scim/v2/Users/"+userID, body, nil, s.token(token))
}

func (s *ScimService) DeleteUser(ctx context.Context, userID string, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodDelete, "/v1/scim/v2/Users/"+userID, nil, nil, s.token(token))
}

func (s *ScimService) ListGroups(ctx context.Context, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodGet, "/v1/scim/v2/Groups", nil, nil, s.token(token))
}

func (s *ScimService) CreateGroup(ctx context.Context, body interface{}, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodPost, "/v1/scim/v2/Groups", body, nil, s.token(token))
}

func (s *ScimService) GetGroup(ctx context.Context, groupID string, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodGet, "/v1/scim/v2/Groups/"+groupID, nil, nil, s.token(token))
}

func (s *ScimService) ReplaceGroup(ctx context.Context, groupID string, body interface{}, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodPut, "/v1/scim/v2/Groups/"+groupID, body, nil, s.token(token))
}

func (s *ScimService) PatchGroup(ctx context.Context, groupID string, body interface{}, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodPatch, "/v1/scim/v2/Groups/"+groupID, body, nil, s.token(token))
}

func (s *ScimService) DeleteGroup(ctx context.Context, groupID string, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodDelete, "/v1/scim/v2/Groups/"+groupID, nil, nil, s.token(token))
}

func (s *ScimService) ResourceTypes(ctx context.Context, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodGet, "/v1/scim/v2/ResourceTypes", nil, nil, s.token(token))
}

func (s *ScimService) ResourceType(ctx context.Context, typeID string, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodGet, "/v1/scim/v2/ResourceTypes/"+typeID, nil, nil, s.token(token))
}

func (s *ScimService) Schemas(ctx context.Context, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodGet, "/v1/scim/v2/Schemas", nil, nil, s.token(token))
}

func (s *ScimService) Schema(ctx context.Context, schemaID string, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodGet, "/v1/scim/v2/Schemas/"+schemaID, nil, nil, s.token(token))
}

func (s *ScimService) ServiceProviderConfig(ctx context.Context, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodGet, "/v1/scim/v2/ServiceProviderConfig", nil, nil, s.token(token))
}

// HrisService is the HRIS namespace.
type HrisService struct {
	client *Client
}

func (s *HrisService) token(override []string) string {
	return s.client.pickToken(optionalToken(override), s.client.hrisToken)
}

func (s *HrisService) ListDepartments(ctx context.Context, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodGet, "/v1/hris/v1/Departments", nil, nil, s.token(token))
}

func (s *HrisService) CreateDepartment(ctx context.Context, body interface{}, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodPost, "/v1/hris/v1/Departments", body, nil, s.token(token))
}

func (s *HrisService) GetDepartment(ctx context.Context, departmentID string, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodGet, "/v1/hris/v1/Departments/"+departmentID, nil, nil, s.token(token))
}

func (s *HrisService) ReplaceDepartment(ctx context.Context, departmentID string, body interface{}, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodPut, "/v1/hris/v1/Departments/"+departmentID, body, nil, s.token(token))
}

func (s *HrisService) PatchDepartment(ctx context.Context, departmentID string, body interface{}, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodPatch, "/v1/hris/v1/Departments/"+departmentID, body, nil, s.token(token))
}

func (s *HrisService) DeleteDepartment(ctx context.Context, departmentID string, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodDelete, "/v1/hris/v1/Departments/"+departmentID, nil, nil, s.token(token))
}

func (s *HrisService) ListEmployees(ctx context.Context, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodGet, "/v1/hris/v1/Employees", nil, nil, s.token(token))
}

func (s *HrisService) CreateEmployee(ctx context.Context, body interface{}, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodPost, "/v1/hris/v1/Employees", body, nil, s.token(token))
}

func (s *HrisService) GetEmployee(ctx context.Context, employeeID string, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodGet, "/v1/hris/v1/Employees/"+employeeID, nil, nil, s.token(token))
}

func (s *HrisService) ReplaceEmployee(ctx context.Context, employeeID string, body interface{}, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodPut, "/v1/hris/v1/Employees/"+employeeID, body, nil, s.token(token))
}

func (s *HrisService) PatchEmployee(ctx context.Context, employeeID string, body interface{}, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodPatch, "/v1/hris/v1/Employees/"+employeeID, body, nil, s.token(token))
}

func (s *HrisService) DeleteEmployee(ctx context.Context, employeeID string, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodDelete, "/v1/hris/v1/Employees/"+employeeID, nil, nil, s.token(token))
}

func (s *HrisService) ServiceConfig(ctx context.Context, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodGet, "/v1/hris/v1/ServiceConfig", nil, nil, s.token(token))
}

// McpService is the MCP trust-store and runtime namespace.
type McpService struct {
	client *Client
}

func (s *McpService) runtime(override []string) string {
	return s.client.pickToken(optionalToken(override), s.client.environmentSecret)
}

func (s *McpService) IngestEvents(ctx context.Context, body interface{}, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodPost, "/v1/mcp/events", body, nil, s.runtime(token))
}

func (s *McpService) Resolve(ctx context.Context, subject string, token ...string) (map[string]interface{}, error) {
	return s.client.requestMapToken(ctx, http.MethodGet, "/v1/mcp/trust-store/resolve", nil, queryIf("subject", subject), s.runtime(token))
}

func (s *McpService) ListEntries(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/mcp/trust-store", nil, nil)
}

func (s *McpService) CreateEntry(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/mcp/trust-store", body, nil)
}

func (s *McpService) GetEntry(ctx context.Context, tenantID, environmentID, entryID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/mcp/trust-store/"+entryID, nil, nil)
}

func (s *McpService) UpdateEntry(ctx context.Context, tenantID, environmentID, entryID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPatch, envPath(tenantID, environmentID)+"/mcp/trust-store/"+entryID, body, nil)
}

func (s *McpService) DeleteEntry(ctx context.Context, tenantID, environmentID, entryID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/mcp/trust-store/"+entryID, nil, nil)
}

func (s *McpService) AddKey(ctx context.Context, tenantID, environmentID, entryID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/mcp/trust-store/"+entryID+"/keys", body, nil)
}

func (s *McpService) RevokeKey(ctx context.Context, tenantID, environmentID, entryID, keyID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/mcp/trust-store/"+entryID+"/keys/"+keyID, nil, nil)
}

func (s *McpService) RotateKey(ctx context.Context, tenantID, environmentID, entryID, keyID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/mcp/trust-store/"+entryID+"/keys/"+keyID+"/rotate", body, nil)
}

func (s *McpService) RevokeEntry(ctx context.Context, tenantID, environmentID, entryID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/mcp/trust-store/"+entryID+"/revoke", nil, nil)
}

func (s *McpService) VerifyEntry(ctx context.Context, tenantID, environmentID, entryID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/mcp/trust-store/"+entryID+"/verify", body, nil)
}

// OtelService is the OpenTelemetry export namespace.
type OtelService struct {
	client *Client
}

func (s *OtelService) ExportLogs(ctx context.Context, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/logs", body, nil)
}

func (s *OtelService) ExportMetrics(ctx context.Context, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/metrics", body, nil)
}

func (s *OtelService) ExportTraces(ctx context.Context, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/traces", body, nil)
}

func (s *OtelService) ExportLogsPrefixed(ctx context.Context, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/otel/v1/logs", body, nil)
}

func (s *OtelService) ExportMetricsPrefixed(ctx context.Context, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/otel/v1/metrics", body, nil)
}

func (s *OtelService) ExportTracesPrefixed(ctx context.Context, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/otel/v1/traces", body, nil)
}

// OidcClientsService is the environment OIDC clients namespace.
type OidcClientsService struct {
	client *Client
}

func oidcClientsPath(tenantID, applicationID, environmentID string) string {
	return "/v1/tenants/" + tenantID + "/applications/" + applicationID + "/environments/" + environmentID + "/oidc-clients"
}

func (s *OidcClientsService) List(ctx context.Context, tenantID, applicationID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, oidcClientsPath(tenantID, applicationID, environmentID), nil, nil)
}

func (s *OidcClientsService) Register(ctx context.Context, tenantID, applicationID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, oidcClientsPath(tenantID, applicationID, environmentID), body, nil)
}

func (s *OidcClientsService) Update(ctx context.Context, tenantID, applicationID, environmentID, clientID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPatch, oidcClientsPath(tenantID, applicationID, environmentID)+"/"+clientID, body, nil)
}

func (s *OidcClientsService) Delete(ctx context.Context, tenantID, applicationID, environmentID, clientID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, oidcClientsPath(tenantID, applicationID, environmentID)+"/"+clientID, nil, nil)
}

// ActionsService is the environment actions namespace.
type ActionsService struct {
	client *Client
}

func (s *ActionsService) List(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/actions", nil, nil)
}

func (s *ActionsService) Save(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/actions", body, nil)
}

func (s *ActionsService) Executions(ctx context.Context, tenantID, environmentID string, opts *ActionsExecutionsOptions) (map[string]interface{}, error) {
	q := url.Values{}
	if opts != nil {
		if opts.ActionID != "" {
			q.Set("actionId", opts.ActionID)
		}
		optionalIntQuery(q, "limit", opts.Limit)
	}
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/actions/executions", nil, q)
}

func (s *ActionsService) Test(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/actions/test", body, nil)
}

func (s *ActionsService) Delete(ctx context.Context, tenantID, environmentID, actionID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/actions/"+actionID, nil, nil)
}

// AddonsService is the environment addons namespace.
type AddonsService struct {
	client *Client
}

func (s *AddonsService) List(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/addons", nil, nil)
}

func (s *AddonsService) Save(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/addons", body, nil)
}

func (s *AddonsService) Delete(ctx context.Context, tenantID, environmentID, provider string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/addons/"+provider, nil, nil)
}

// BillingService is the environment billing namespace.
type BillingService struct {
	client *Client
}

func (s *BillingService) ListFeatures(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/billing/features", nil, nil)
}

func (s *BillingService) SaveFeature(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/billing/features", body, nil)
}

func (s *BillingService) DeleteFeature(ctx context.Context, tenantID, environmentID, featureID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/billing/features/"+featureID, nil, nil)
}

func (s *BillingService) ListPlans(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/billing/plans", nil, nil)
}

func (s *BillingService) SavePlan(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/billing/plans", body, nil)
}

func (s *BillingService) DeletePlan(ctx context.Context, tenantID, environmentID, planID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/billing/plans/"+planID, nil, nil)
}

func (s *BillingService) SyncStripe(ctx context.Context, tenantID, environmentID, planID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/billing/plans/"+planID+"/sync-stripe", nil, nil)
}

// SettingsService is the environment policy/settings namespace.
type SettingsService struct {
	client *Client
}

func (s *SettingsService) get(ctx context.Context, tenantID, environmentID, suffix string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/"+suffix, nil, nil)
}

func (s *SettingsService) put(ctx context.Context, tenantID, environmentID, suffix string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPut, envPath(tenantID, environmentID)+"/"+suffix, body, nil)
}

func (s *SettingsService) GetBotDetectionPolicy(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.get(ctx, tenantID, environmentID, "bot-detection-policy")
}

func (s *SettingsService) UpdateBotDetectionPolicy(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.put(ctx, tenantID, environmentID, "bot-detection-policy", body)
}

func (s *SettingsService) GetBreachedPasswordPolicy(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.get(ctx, tenantID, environmentID, "breached-password-policy")
}

func (s *SettingsService) UpdateBreachedPasswordPolicy(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.put(ctx, tenantID, environmentID, "breached-password-policy", body)
}

func (s *SettingsService) GetBruteForcePolicy(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.get(ctx, tenantID, environmentID, "brute-force-policy")
}

func (s *SettingsService) UpdateBruteForcePolicy(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.put(ctx, tenantID, environmentID, "brute-force-policy", body)
}

func (s *SettingsService) GetDeviceRiskPolicy(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.get(ctx, tenantID, environmentID, "device-risk-policy")
}

func (s *SettingsService) UpdateDeviceRiskPolicy(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.put(ctx, tenantID, environmentID, "device-risk-policy", body)
}

func (s *SettingsService) ListJWTClaimMappings(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.get(ctx, tenantID, environmentID, "jwt-claim-mappings")
}

func (s *SettingsService) SaveJWTClaimMapping(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/jwt-claim-mappings", body, nil)
}

func (s *SettingsService) DeleteJWTClaimMapping(ctx context.Context, tenantID, environmentID, mappingID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/jwt-claim-mappings/"+mappingID, nil, nil)
}

func (s *SettingsService) GetPasswordPolicy(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.get(ctx, tenantID, environmentID, "password-policy")
}

func (s *SettingsService) UpdatePasswordPolicy(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.put(ctx, tenantID, environmentID, "password-policy", body)
}

func (s *SettingsService) GetRateLimitPolicy(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.get(ctx, tenantID, environmentID, "rate-limit-policy")
}

func (s *SettingsService) UpdateRateLimitPolicy(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.put(ctx, tenantID, environmentID, "rate-limit-policy", body)
}

func (s *SettingsService) GetRestrictions(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.get(ctx, tenantID, environmentID, "restrictions")
}

func (s *SettingsService) UpdateRestrictions(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.put(ctx, tenantID, environmentID, "restrictions", body)
}

func (s *SettingsService) GetSessionConfig(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.get(ctx, tenantID, environmentID, "session-config")
}

func (s *SettingsService) UpdateSessionConfig(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.put(ctx, tenantID, environmentID, "session-config", body)
}

// ElevateService is the privileged-access elevate namespace.
type ElevateService struct {
	client *Client
}

func (s *ElevateService) ActivateGrant(ctx context.Context, tenantID, environmentID, grantID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/elevate/access-grants/"+grantID+"/activate", body, nil)
}

func (s *ElevateService) RevokeGrant(ctx context.Context, tenantID, environmentID, grantID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/elevate/access-grants/"+grantID+"/revoke", body, nil)
}

func (s *ElevateService) ListRequests(ctx context.Context, tenantID, environmentID, status string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/elevate/access-requests", nil, queryIf("status", status))
}

func (s *ElevateService) CreateRequest(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/elevate/access-requests", body, nil)
}

func (s *ElevateService) GetRequest(ctx context.Context, tenantID, environmentID, requestID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/elevate/access-requests/"+requestID, nil, nil)
}

func (s *ElevateService) ApproveRequest(ctx context.Context, tenantID, environmentID, requestID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/elevate/access-requests/"+requestID+"/approve", body, nil)
}

func (s *ElevateService) CancelRequest(ctx context.Context, tenantID, environmentID, requestID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/elevate/access-requests/"+requestID+"/cancel", nil, nil)
}

func (s *ElevateService) DenyRequest(ctx context.Context, tenantID, environmentID, requestID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/elevate/access-requests/"+requestID+"/deny", body, nil)
}

func (s *ElevateService) GetPolicy(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/elevate/policy", nil, nil)
}

func (s *ElevateService) UpdatePolicy(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPut, envPath(tenantID, environmentID)+"/elevate/policy", body, nil)
}

// EmailProvidersService is the environment email-providers namespace.
type EmailProvidersService struct {
	client *Client
}

func (s *EmailProvidersService) List(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/email-providers", nil, nil)
}

func (s *EmailProvidersService) Save(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/email-providers", body, nil)
}

func (s *EmailProvidersService) Test(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/email-providers/test", body, nil)
}

func (s *EmailProvidersService) Delete(ctx context.Context, tenantID, environmentID, provider string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/email-providers/"+provider, nil, nil)
}

func (s *EmailProvidersService) Activate(ctx context.Context, tenantID, environmentID, provider string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/email-providers/"+provider+"/activate", nil, nil)
}

// FeatureFlagsService is the environment feature-flags namespace.
type FeatureFlagsService struct {
	client *Client
}

func (s *FeatureFlagsService) List(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/feature-flags", nil, nil)
}

func (s *FeatureFlagsService) Save(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/feature-flags", body, nil)
}

func (s *FeatureFlagsService) Delete(ctx context.Context, tenantID, environmentID, flagID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/feature-flags/"+flagID, nil, nil)
}

// FormsService is the environment forms namespace.
type FormsService struct {
	client *Client
}

func (s *FormsService) ListAttachments(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/form-attachments", nil, nil)
}

func (s *FormsService) List(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/forms", nil, nil)
}

func (s *FormsService) Save(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/forms", body, nil)
}

func (s *FormsService) Delete(ctx context.Context, tenantID, environmentID, formID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/forms/"+formID, nil, nil)
}

// ProvisioningTokensService is the SCIM/HRIS provisioning-token namespace.
type ProvisioningTokensService struct {
	client *Client
}

func (s *ProvisioningTokensService) ListHris(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/hris-tokens", nil, nil)
}

func (s *ProvisioningTokensService) CreateHris(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/hris-tokens", body, nil)
}

func (s *ProvisioningTokensService) RevokeHris(ctx context.Context, tenantID, environmentID, tokenID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/hris-tokens/"+tokenID+"/revoke", nil, nil)
}

func (s *ProvisioningTokensService) RotateHris(ctx context.Context, tenantID, environmentID, tokenID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/hris-tokens/"+tokenID+"/rotate", nil, nil)
}

func (s *ProvisioningTokensService) ListScim(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/scim-tokens", nil, nil)
}

func (s *ProvisioningTokensService) CreateScim(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/scim-tokens", body, nil)
}

func (s *ProvisioningTokensService) RevokeScim(ctx context.Context, tenantID, environmentID, tokenID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/scim-tokens/"+tokenID+"/revoke", nil, nil)
}

func (s *ProvisioningTokensService) RotateScim(ctx context.Context, tenantID, environmentID, tokenID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/scim-tokens/"+tokenID+"/rotate", nil, nil)
}

// ImpersonationService is the impersonation-grants namespace.
type ImpersonationService struct {
	client *Client
}

func (s *ImpersonationService) List(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/impersonation-grants", nil, nil)
}

func (s *ImpersonationService) Create(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/impersonation-grants", body, nil)
}

func (s *ImpersonationService) Revoke(ctx context.Context, tenantID, environmentID, grantID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/impersonation-grants/"+grantID+"/revoke", nil, nil)
}

// PortalService is the environment portal namespace.
type PortalService struct {
	client *Client
}

func (s *PortalService) GenerateLink(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/portal/generate-link", body, nil)
}

// SecurityService is the environment security namespace.
type SecurityService struct {
	client *Client
}

func (s *SecurityService) Posture(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/security/posture", nil, nil)
}

// ThreatsService is the environment threats namespace.
type ThreatsService struct {
	client *Client
}

func (s *ThreatsService) List(ctx context.Context, tenantID, environmentID string, query url.Values) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/threats", nil, query)
}

func (s *ThreatsService) Create(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/threats", body, nil)
}

func (s *ThreatsService) Get(ctx context.Context, tenantID, environmentID, threatID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/threats/"+threatID, nil, nil)
}

func (s *ThreatsService) Update(ctx context.Context, tenantID, environmentID, threatID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPatch, envPath(tenantID, environmentID)+"/threats/"+threatID, body, nil)
}

func (s *ThreatsService) Delete(ctx context.Context, tenantID, environmentID, threatID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/threats/"+threatID, nil, nil)
}

func (s *ThreatsService) Resolve(ctx context.Context, tenantID, environmentID, threatID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/threats/"+threatID+"/resolve", body, nil)
}

// VanityDomainsService is the environment vanity-domains namespace.
type VanityDomainsService struct {
	client *Client
}

func (s *VanityDomainsService) List(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/vanity-domains", nil, nil)
}

func (s *VanityDomainsService) Create(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/vanity-domains", body, nil)
}

func (s *VanityDomainsService) Delete(ctx context.Context, tenantID, environmentID, domainID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/vanity-domains/"+domainID, nil, nil)
}

func (s *VanityDomainsService) Check(ctx context.Context, tenantID, environmentID, domainID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/vanity-domains/"+domainID+"/check", nil, nil)
}

// WidgetsService is the environment widgets namespace.
type WidgetsService struct {
	client *Client
}

func (s *WidgetsService) CreateToken(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/widgets/token", body, nil)
}
