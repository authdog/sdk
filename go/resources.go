package authdog

import (
	"context"
	"net/http"
	"net/url"
	"strconv"
)

func queryIf(key, value string) url.Values {
	q := url.Values{}
	if value != "" {
		q.Set(key, value)
	}
	return q
}

func optionalIntQuery(q url.Values, key string, value *int) {
	if value != nil {
		q.Set(key, strconv.Itoa(*value))
	}
}

// UsersListOptions are optional query parameters for Users.List.
type UsersListOptions struct {
	Offset      *int
	Limit       *int
	SearchQuery string
}

// UsersSearchOptions are optional query parameters for Users.Search.
type UsersSearchOptions struct {
	Q      string
	Offset *int
	Limit  *int
}

// OrganizationsService is the organizations management namespace.
type OrganizationsService struct {
	client *Client
}

func (s *OrganizationsService) List(ctx context.Context) (*OrganizationsList, error) {
	var out OrganizationsList
	if err := s.client.requestJSON(ctx, http.MethodGet, "/v1/organizations", nil, nil, &out); err != nil {
		return nil, err
	}
	return &out, nil
}

func (s *OrganizationsService) Create(ctx context.Context, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/organizations", body, nil)
}

func (s *OrganizationsService) Get(ctx context.Context, organizationID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/organizations/"+organizationID, nil, nil)
}

func (s *OrganizationsService) Update(ctx context.Context, organizationID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPatch, "/v1/organizations/"+organizationID, body, nil)
}

func (s *OrganizationsService) Delete(ctx context.Context, organizationID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, "/v1/organizations/"+organizationID, nil, nil)
}

func (s *OrganizationsService) AcceptInvitation(ctx context.Context, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/organizations/invitations/accept", body, nil)
}

func (s *OrganizationsService) Join(ctx context.Context, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/organizations/join", body, nil)
}

func (s *OrganizationsService) ListInvitations(ctx context.Context, organizationID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/organizations/"+organizationID+"/invitations", nil, nil)
}

func (s *OrganizationsService) CreateInvitation(ctx context.Context, organizationID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/organizations/"+organizationID+"/invitations", body, nil)
}

func (s *OrganizationsService) CancelInvitation(ctx context.Context, organizationID, invitationID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/organizations/"+organizationID+"/invitations/"+invitationID+"/cancel", nil, nil)
}

func (s *OrganizationsService) SendInvite(ctx context.Context, organizationID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/organizations/"+organizationID+"/invites", body, nil)
}

func (s *OrganizationsService) ListMembers(ctx context.Context, organizationID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/organizations/"+organizationID+"/members", nil, nil)
}

func (s *OrganizationsService) RemoveMember(ctx context.Context, organizationID, memberID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, "/v1/organizations/"+organizationID+"/members/"+memberID, nil, nil)
}

func (s *OrganizationsService) SetMemberActive(ctx context.Context, organizationID, memberID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPatch, "/v1/organizations/"+organizationID+"/members/"+memberID+"/active", body, nil)
}

func (s *OrganizationsService) LinkTenant(ctx context.Context, organizationID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/organizations/"+organizationID+"/tenants", body, nil)
}

func (s *OrganizationsService) UnlinkTenant(ctx context.Context, organizationID, tenantID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, "/v1/organizations/"+organizationID+"/tenants/"+tenantID, nil, nil)
}

func (s *OrganizationsService) ListKeys(ctx context.Context, organizationID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/organizations/"+organizationID+"/keys", nil, nil)
}

func (s *OrganizationsService) CreateKey(ctx context.Context, organizationID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/organizations/"+organizationID+"/keys", body, nil)
}

func (s *OrganizationsService) RevokeKey(ctx context.Context, organizationID, keyID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/organizations/"+organizationID+"/keys/"+keyID+"/revoke", nil, nil)
}

func (s *OrganizationsService) RotateKey(ctx context.Context, organizationID, keyID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/organizations/"+organizationID+"/keys/"+keyID+"/rotate", nil, nil)
}

func (s *OrganizationsService) UpdateKeyTenants(ctx context.Context, organizationID, keyID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPut, "/v1/organizations/"+organizationID+"/keys/"+keyID+"/tenants", body, nil)
}

func (s *OrganizationsService) ListAuditLogs(ctx context.Context, organizationID string, query url.Values) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/organizations/"+organizationID+"/audit/logs", nil, query)
}

// TenantsService is the tenants management namespace.
type TenantsService struct {
	client *Client
}

func (s *TenantsService) List(ctx context.Context, organizationID string) (*TenantsList, error) {
	var out TenantsList
	if err := s.client.requestJSON(ctx, http.MethodGet, "/v1/tenants", nil, queryIf("organization_id", organizationID), &out); err != nil {
		return nil, err
	}
	return &out, nil
}

func (s *TenantsService) Create(ctx context.Context, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/tenants", body, nil)
}

func (s *TenantsService) Join(ctx context.Context, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/tenants/join", body, nil)
}

func (s *TenantsService) Get(ctx context.Context, tenantID, organizationID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/tenants/"+tenantID, nil, queryIf("organization_id", organizationID))
}

func (s *TenantsService) Update(ctx context.Context, tenantID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPatch, "/v1/tenants/"+tenantID, body, nil)
}

func (s *TenantsService) Delete(ctx context.Context, tenantID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, "/v1/tenants/"+tenantID, nil, nil)
}

func (s *TenantsService) ListDomains(ctx context.Context, tenantID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/tenants/"+tenantID+"/domains", nil, nil)
}

func (s *TenantsService) CreateDomain(ctx context.Context, tenantID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/tenants/"+tenantID+"/domains", body, nil)
}

func (s *TenantsService) DeleteDomain(ctx context.Context, tenantID, domainID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, "/v1/tenants/"+tenantID+"/domains/"+domainID, nil, nil)
}

func (s *TenantsService) RetryDomain(ctx context.Context, tenantID, domainID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/tenants/"+tenantID+"/domains/"+domainID+"/retry", nil, nil)
}

func (s *TenantsService) SendInvite(ctx context.Context, tenantID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/tenants/"+tenantID+"/invites", body, nil)
}

func (s *TenantsService) ListProjects(ctx context.Context, tenantID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/tenants/"+tenantID+"/projects", nil, nil)
}

func (s *TenantsService) ListSeats(ctx context.Context, tenantID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/tenants/"+tenantID+"/seats", nil, nil)
}

func (s *TenantsService) UpdateSeat(ctx context.Context, tenantID, seatID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPatch, "/v1/tenants/"+tenantID+"/seats/"+seatID, body, nil)
}

func (s *TenantsService) DeleteSeat(ctx context.Context, tenantID, seatID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, "/v1/tenants/"+tenantID+"/seats/"+seatID, nil, nil)
}

// ProjectsService is the projects (applications) namespace.
type ProjectsService struct {
	client *Client
}

func (s *ProjectsService) Save(ctx context.Context, tenantID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/tenants/"+tenantID+"/applications", body, nil)
}

func (s *ProjectsService) Get(ctx context.Context, tenantID, applicationID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/tenants/"+tenantID+"/applications/"+applicationID, nil, nil)
}

func (s *ProjectsService) Delete(ctx context.Context, tenantID, applicationID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, "/v1/tenants/"+tenantID+"/applications/"+applicationID, nil, nil)
}

func (s *ProjectsService) SetDefaultEnvironment(ctx context.Context, tenantID, applicationID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPut, "/v1/tenants/"+tenantID+"/applications/"+applicationID+"/default-environment", body, nil)
}

// EnvironmentsService is the environment lifecycle namespace.
type EnvironmentsService struct {
	client *Client
}

func (s *EnvironmentsService) List(ctx context.Context, tenantID, applicationID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/tenants/"+tenantID+"/applications/"+applicationID+"/environments", nil, nil)
}

func (s *EnvironmentsService) Create(ctx context.Context, tenantID, applicationID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/tenants/"+tenantID+"/applications/"+applicationID+"/environments", body, nil)
}

func (s *EnvironmentsService) Update(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPatch, "/v1/tenants/"+tenantID+"/environments/"+environmentID, body, nil)
}

func (s *EnvironmentsService) Delete(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, "/v1/tenants/"+tenantID+"/environments/"+environmentID, nil, nil)
}

// UsersService is the directory users namespace.
type UsersService struct {
	client *Client
}

func (s *UsersService) List(ctx context.Context, tenantID, environmentID string, opts *UsersListOptions) (*EnvUsersResponse, error) {
	q := url.Values{}
	if opts != nil {
		optionalIntQuery(q, "offset", opts.Offset)
		optionalIntQuery(q, "limit", opts.Limit)
		if opts.SearchQuery != "" {
			q.Set("searchQuery", opts.SearchQuery)
		}
	}
	var out EnvUsersResponse
	path := "/v1/tenants/" + tenantID + "/environments/" + environmentID + "/users"
	if err := s.client.requestJSON(ctx, http.MethodGet, path, nil, q, &out); err != nil {
		return nil, err
	}
	return &out, nil
}

func (s *UsersService) Create(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/tenants/"+tenantID+"/environments/"+environmentID+"/users", body, nil)
}

func (s *UsersService) Search(ctx context.Context, tenantID, environmentID string, opts *UsersSearchOptions) (*EnvUsersResponse, error) {
	q := url.Values{}
	if opts != nil {
		if opts.Q != "" {
			q.Set("q", opts.Q)
		}
		optionalIntQuery(q, "offset", opts.Offset)
		optionalIntQuery(q, "limit", opts.Limit)
	}
	var out EnvUsersResponse
	path := "/v1/tenants/" + tenantID + "/environments/" + environmentID + "/users/search"
	if err := s.client.requestJSON(ctx, http.MethodGet, path, nil, q, &out); err != nil {
		return nil, err
	}
	return &out, nil
}

func (s *UsersService) Count(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/tenants/"+tenantID+"/environments/"+environmentID+"/users/count", nil, nil)
}

func (s *UsersService) Get(ctx context.Context, tenantID, environmentID, userID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/tenants/"+tenantID+"/environments/"+environmentID+"/users/"+userID, nil, nil)
}

func (s *UsersService) Update(ctx context.Context, tenantID, environmentID, userID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPut, "/v1/tenants/"+tenantID+"/environments/"+environmentID+"/users/"+userID, body, nil)
}

func (s *UsersService) Delete(ctx context.Context, tenantID, environmentID, userID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, "/v1/tenants/"+tenantID+"/environments/"+environmentID+"/users/"+userID, nil, nil)
}

func (s *UsersService) SetActive(ctx context.Context, tenantID, environmentID, userID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPatch, "/v1/tenants/"+tenantID+"/environments/"+environmentID+"/users/"+userID+"/active", body, nil)
}

func (s *UsersService) ListGroups(ctx context.Context, tenantID, environmentID, userID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/tenants/"+tenantID+"/environments/"+environmentID+"/users/"+userID+"/groups", nil, nil)
}

// GroupsService is the directory groups namespace.
type GroupsService struct {
	client *Client
}

func (s *GroupsService) Create(ctx context.Context, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/groups", body, nil)
}

func (s *GroupsService) List(ctx context.Context, tenantID, environmentID string) (*EnvGroupsResponse, error) {
	var out EnvGroupsResponse
	path := "/v1/tenants/" + tenantID + "/environments/" + environmentID + "/groups"
	if err := s.client.requestJSON(ctx, http.MethodGet, path, nil, nil, &out); err != nil {
		return nil, err
	}
	return &out, nil
}

func (s *GroupsService) Delete(ctx context.Context, tenantID, environmentID, groupID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, "/v1/tenants/"+tenantID+"/environments/"+environmentID+"/groups/"+groupID, nil, nil)
}

func (s *GroupsService) ListMembers(ctx context.Context, tenantID, environmentID, groupID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/tenants/"+tenantID+"/environments/"+environmentID+"/groups/"+groupID+"/members", nil, nil)
}

func (s *GroupsService) AddMember(ctx context.Context, tenantID, environmentID, groupID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/tenants/"+tenantID+"/environments/"+environmentID+"/groups/"+groupID+"/members", body, nil)
}

func (s *GroupsService) RemoveMember(ctx context.Context, tenantID, environmentID, groupID, userID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, "/v1/tenants/"+tenantID+"/environments/"+environmentID+"/groups/"+groupID+"/members/"+userID, nil, nil)
}

func envPath(tenantID, environmentID string) string {
	return "/v1/tenants/" + tenantID + "/environments/" + environmentID
}

// RbacService is the environment RBAC / ABAC namespace.
type RbacService struct {
	client *Client
}

func (s *RbacService) ListRoles(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/roles", nil, nil)
}

func (s *RbacService) CreateRole(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/roles", body, nil)
}

func (s *RbacService) DeleteRole(ctx context.Context, tenantID, environmentID, roleID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/roles/"+roleID, nil, nil)
}

func (s *RbacService) ListRolePermissions(ctx context.Context, tenantID, environmentID, roleID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/roles/"+roleID+"/permissions", nil, nil)
}

func (s *RbacService) SetRolePermissions(ctx context.Context, tenantID, environmentID, roleID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPut, envPath(tenantID, environmentID)+"/roles/"+roleID+"/permissions", body, nil)
}

func (s *RbacService) ListPermissions(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/permissions", nil, nil)
}

func (s *RbacService) CreatePermission(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/permissions", body, nil)
}

func (s *RbacService) DeletePermission(ctx context.Context, tenantID, environmentID, permissionID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/permissions/"+permissionID, nil, nil)
}

func (s *RbacService) ListResources(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/resources", nil, nil)
}

func (s *RbacService) CreateResource(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/resources", body, nil)
}

func (s *RbacService) DeleteResource(ctx context.Context, tenantID, environmentID, resourceID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/resources/"+resourceID, nil, nil)
}

func (s *RbacService) ListGroupRoles(ctx context.Context, tenantID, environmentID, groupID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/groups/"+groupID+"/roles", nil, nil)
}

func (s *RbacService) AddGroupRole(ctx context.Context, tenantID, environmentID, groupID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/groups/"+groupID+"/roles", body, nil)
}

func (s *RbacService) RemoveGroupRole(ctx context.Context, tenantID, environmentID, groupID, roleID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/groups/"+groupID+"/roles/"+roleID, nil, nil)
}

func (s *RbacService) ListGroupRoleMappings(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/group-role-mappings", nil, nil)
}

func (s *RbacService) CreateGroupRoleMapping(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/group-role-mappings", body, nil)
}

func (s *RbacService) ApplyGroupRoleMappings(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/group-role-mappings/apply", nil, nil)
}

func (s *RbacService) DeleteGroupRoleMapping(ctx context.Context, tenantID, environmentID, mappingID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/group-role-mappings/"+mappingID, nil, nil)
}

func (s *RbacService) ListAbacPolicies(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/abac-policies", nil, nil)
}

func (s *RbacService) SaveAbacPolicy(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/abac-policies", body, nil)
}

func (s *RbacService) ValidateAbacPolicy(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/abac-policies/validate", body, nil)
}

func (s *RbacService) DeleteAbacPolicy(ctx context.Context, tenantID, environmentID, policyID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/abac-policies/"+policyID, nil, nil)
}

func (s *RbacService) MyPermissions(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/me/permissions", nil, nil)
}

// AuditService is the environment audit log namespace.
type AuditService struct {
	client *Client
}

func (s *AuditService) ListLogs(ctx context.Context, tenantID, environmentID string, query url.Values) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/audit/logs", nil, query)
}

func (s *AuditService) EventMetadata(ctx context.Context, tenantID, environmentID string, query url.Values) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/audit/event-metadata", nil, query)
}

func (s *AuditService) EventTypes(ctx context.Context, tenantID, environmentID string, query url.Values) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/audit/event-types", nil, query)
}

func (s *AuditService) EventTypesCatalog(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/audit/event-types/catalog", nil, nil)
}

// EventsService is the environment events namespace.
type EventsService struct {
	client *Client
}

func (s *EventsService) List(ctx context.Context, tenantID, environmentID string, query url.Values) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/events", nil, query)
}

func (s *EventsService) ListTypes(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/events/types", nil, nil)
}

func (s *EventsService) Ingest(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/events/ingest", body, nil)
}

// WebhooksService is the environment webhook channels namespace.
type WebhooksService struct {
	client *Client
}

func (s *WebhooksService) List(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/webhooks", nil, nil)
}

func (s *WebhooksService) Create(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/webhooks", body, nil)
}

func (s *WebhooksService) Update(ctx context.Context, tenantID, environmentID, channelID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPut, envPath(tenantID, environmentID)+"/webhooks/"+channelID, body, nil)
}

func (s *WebhooksService) Delete(ctx context.Context, tenantID, environmentID, channelID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/webhooks/"+channelID, nil, nil)
}

func (s *WebhooksService) RotateSecret(ctx context.Context, tenantID, environmentID, channelID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/webhooks/"+channelID+"/rotate-secret", nil, nil)
}

func (s *WebhooksService) ListDeliveries(ctx context.Context, tenantID, environmentID string, query url.Values) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/webhooks/deliveries", nil, query)
}

func (s *WebhooksService) Redeliver(ctx context.Context, tenantID, environmentID, deliveryID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/webhooks/deliveries/"+deliveryID+"/redeliver", nil, nil)
}

// NotificationChannelsService is the environment notification-channels namespace.
type NotificationChannelsService struct {
	client *Client
}

func (s *NotificationChannelsService) List(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/notification-channels", nil, nil)
}

func (s *NotificationChannelsService) Create(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/notification-channels", body, nil)
}

func (s *NotificationChannelsService) Update(ctx context.Context, tenantID, environmentID, channelID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPut, envPath(tenantID, environmentID)+"/notification-channels/"+channelID, body, nil)
}

func (s *NotificationChannelsService) Delete(ctx context.Context, tenantID, environmentID, channelID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, envPath(tenantID, environmentID)+"/notification-channels/"+channelID, nil, nil)
}

func (s *NotificationChannelsService) Test(ctx context.Context, tenantID, environmentID, channelID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/notification-channels/"+channelID+"/test", body, nil)
}

// ServiceAccountsService is the organization service-accounts namespace.
type ServiceAccountsService struct {
	client *Client
}

func (s *ServiceAccountsService) List(ctx context.Context) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/service-accounts", nil, nil)
}

func (s *ServiceAccountsService) Create(ctx context.Context, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/service-accounts", body, nil)
}

func (s *ServiceAccountsService) Get(ctx context.Context, serviceAccountID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/service-accounts/"+serviceAccountID, nil, nil)
}

func (s *ServiceAccountsService) Delete(ctx context.Context, serviceAccountID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodDelete, "/v1/service-accounts/"+serviceAccountID, nil, nil)
}

// PersonalAccessTokensService is the personal-access-tokens namespace.
type PersonalAccessTokensService struct {
	client *Client
}

func (s *PersonalAccessTokensService) List(ctx context.Context) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, "/v1/personal-access-tokens", nil, nil)
}

func (s *PersonalAccessTokensService) Create(ctx context.Context, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/personal-access-tokens", body, nil)
}

func (s *PersonalAccessTokensService) Revoke(ctx context.Context, tokenID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, "/v1/personal-access-tokens/"+tokenID+"/revoke", nil, nil)
}

// ApiSecretsService is the environment API secrets namespace.
type ApiSecretsService struct {
	client *Client
}

func (s *ApiSecretsService) List(ctx context.Context, tenantID, environmentID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodGet, envPath(tenantID, environmentID)+"/api-secrets", nil, nil)
}

func (s *ApiSecretsService) Create(ctx context.Context, tenantID, environmentID string, body interface{}) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/api-secrets", body, nil)
}

func (s *ApiSecretsService) Revoke(ctx context.Context, tenantID, environmentID, secretID string) (map[string]interface{}, error) {
	return s.client.requestMap(ctx, http.MethodPost, envPath(tenantID, environmentID)+"/api-secrets/"+secretID+"/revoke", nil, nil)
}
