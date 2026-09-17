package authdog

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"reflect"
	"strings"
	"testing"
	"time"
)

func managementClient(t *testing.T, handler http.HandlerFunc) *Client {
	t.Helper()
	server := httptest.NewServer(handler)
	t.Cleanup(server.Close)
	return NewClient(ClientConfig{
		BaseURL: server.URL,
		APIKey:  "key-1",
	})
}

func writeJSON(t *testing.T, w http.ResponseWriter, status int, payload interface{}) {
	t.Helper()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if payload == nil {
		return
	}
	if err := json.NewEncoder(w).Encode(payload); err != nil {
		t.Errorf("failed to encode response: %v", err)
	}
}

func TestHealth_Public(t *testing.T) {
	var gotMethod, gotPath string
	client := managementClient(t, func(w http.ResponseWriter, r *http.Request) {
		gotMethod = r.Method
		gotPath = r.URL.Path
		writeJSON(t, w, http.StatusOK, Probe{OK: true})
	})

	probe, err := client.Health(context.Background())
	if err != nil {
		t.Fatalf("Health() error = %v", err)
	}
	if probe == nil || !probe.OK {
		t.Fatalf("Health() = %+v, want ok=true", probe)
	}
	if gotMethod != http.MethodGet {
		t.Errorf("method = %s, want GET", gotMethod)
	}
	if gotPath != "/v1/health" {
		t.Errorf("path = %s, want /v1/health", gotPath)
	}
}

func TestOrganizations_ListEmpty(t *testing.T) {
	var gotAuth string
	client := managementClient(t, func(w http.ResponseWriter, r *http.Request) {
		gotAuth = r.Header.Get("Authorization")
		writeJSON(t, w, http.StatusOK, OrganizationsList{Organizations: []Organization{}, Total: 0})
	})

	result, err := client.Organizations.List(context.Background())
	if err != nil {
		t.Fatalf("Organizations.List() error = %v", err)
	}
	if gotAuth != "Bearer key-1" {
		t.Errorf("Authorization = %q, want Bearer key-1", gotAuth)
	}
	if result.Total != 0 {
		t.Errorf("total = %d, want 0", result.Total)
	}
	if len(result.Organizations) != 0 {
		t.Errorf("organizations = %#v, want empty", result.Organizations)
	}
}

func TestManagement_401_IsAuthenticationError(t *testing.T) {
	client := managementClient(t, func(w http.ResponseWriter, r *http.Request) {
		writeJSON(t, w, http.StatusUnauthorized, map[string]string{})
	})

	_, err := client.Organizations.List(context.Background())
	if err == nil {
		t.Fatal("Organizations.List() error = nil, want AuthenticationError")
	}
	if !IsAuthenticationError(err) {
		t.Errorf("error type = %T, want *AuthenticationError", err)
	}
	if err.Error() != "Unauthorized - invalid or expired token" {
		t.Errorf("error message = %q", err.Error())
	}
}

func TestManagement_404_IncludesStatusAndError(t *testing.T) {
	client := managementClient(t, func(w http.ResponseWriter, r *http.Request) {
		writeJSON(t, w, http.StatusNotFound, map[string]string{"error": "not found"})
	})

	_, err := client.Organizations.Get(context.Background(), "missing")
	if err == nil {
		t.Fatal("Organizations.Get() error = nil, want APIError")
	}
	apiErr, ok := err.(*APIError)
	if !ok {
		t.Fatalf("error type = %T, want *APIError", err)
	}
	if apiErr.StatusCode != http.StatusNotFound {
		t.Errorf("StatusCode = %d, want 404", apiErr.StatusCode)
	}
	if !strings.Contains(apiErr.Error(), "HTTP error 404") {
		t.Errorf("message = %q, want HTTP error 404", apiErr.Error())
	}
	if !strings.Contains(apiErr.Error(), "not found") {
		t.Errorf("message = %q, want 'not found'", apiErr.Error())
	}
}

func TestManagement_TransportError(t *testing.T) {
	client := NewClient(ClientConfig{
		BaseURL: "http://invalid-url-that-does-not-exist",
		APIKey:  "key-1",
		Timeout: time.Millisecond,
	})

	_, err := client.Tenants.List(context.Background(), "")
	if err == nil {
		t.Fatal("Tenants.List() error = nil, want APIError")
	}
	if !IsAPIError(err) {
		t.Errorf("error type = %T, want *APIError", err)
	}
	if !strings.Contains(err.Error(), "request failed:") {
		t.Errorf("message = %q, want request failed:", err.Error())
	}
}

func TestGetUserInfo_APIKeyDoesNotOverrideAccessToken(t *testing.T) {
	client := managementClient(t, func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Authorization") != "Bearer token-2" {
			t.Errorf("Authorization = %q, want Bearer token-2", r.Header.Get("Authorization"))
		}
		writeJSON(t, w, http.StatusOK, UserInfoResponse{
			Meta: Meta{Code: 200, Message: "OK"},
			User: User{ID: "123", DisplayName: "Ada"},
		})
	})

	result, err := client.GetUserInfo(context.Background(), "token-2")
	if err != nil {
		t.Fatalf("GetUserInfo() error = %v", err)
	}
	if result.User.ID != "123" {
		t.Errorf("user ID = %q, want 123", result.User.ID)
	}
}

func TestUsers_ListEmptyIsSuccess(t *testing.T) {
	client := managementClient(t, func(w http.ResponseWriter, r *http.Request) {
		writeJSON(t, w, http.StatusOK, EnvUsersResponse{Users: []EnvUser{}})
	})

	listed, err := client.Users.List(context.Background(), "ten_1", "env_1", nil)
	if err != nil {
		t.Fatalf("Users.List() error = %v", err)
	}
	if listed == nil || len(listed.Users) != 0 {
		t.Errorf("users = %#v, want empty success", listed)
	}
}

func TestUsers_ListParsesItem(t *testing.T) {
	client := managementClient(t, func(w http.ResponseWriter, r *http.Request) {
		writeJSON(t, w, http.StatusOK, map[string]interface{}{
			"users": []map[string]interface{}{
				{
					"id":          "usr_1",
					"displayName": "Ada",
					"emails":      []map[string]interface{}{{"value": "ada@example.com"}},
				},
			},
		})
	})

	listed, err := client.Users.List(context.Background(), "ten_1", "env_1", nil)
	if err != nil {
		t.Fatalf("Users.List() error = %v", err)
	}
	if len(listed.Users) != 1 {
		t.Fatalf("len(users) = %d, want 1", len(listed.Users))
	}
	if listed.Users[0].ID != "usr_1" {
		t.Errorf("id = %q, want usr_1", listed.Users[0].ID)
	}
	if listed.Users[0].DisplayName == nil || *listed.Users[0].DisplayName != "Ada" {
		t.Errorf("displayName = %#v, want Ada", listed.Users[0].DisplayName)
	}
	if len(listed.Users[0].Emails) != 1 || listed.Users[0].Emails[0].Value != "ada@example.com" {
		t.Errorf("emails = %#v", listed.Users[0].Emails)
	}
}

type wave1Case struct {
	name   string
	call   func(ctx context.Context, c *Client) error
	method string
	path   string
	body   map[string]interface{}
}

func wave1Cases() []wave1Case {
	return []wave1Case{
		{"orgs.list", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.List(ctx)
			return err
		}, "GET", "/v1/organizations", nil},
		{"orgs.create", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.Create(ctx, map[string]interface{}{"name": "Acme"})
			return err
		}, "POST", "/v1/organizations", map[string]interface{}{"name": "Acme"}},
		{"orgs.get", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.Get(ctx, "org_1")
			return err
		}, "GET", "/v1/organizations/org_1", nil},
		{"orgs.update", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.Update(ctx, "org_1", map[string]interface{}{"name": "New"})
			return err
		}, "PATCH", "/v1/organizations/org_1", map[string]interface{}{"name": "New"}},
		{"orgs.delete", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.Delete(ctx, "org_1")
			return err
		}, "DELETE", "/v1/organizations/org_1", nil},
		{"orgs.accept_invitation", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.AcceptInvitation(ctx, map[string]interface{}{"token": "t"})
			return err
		}, "POST", "/v1/organizations/invitations/accept", map[string]interface{}{"token": "t"}},
		{"orgs.join", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.Join(ctx, map[string]interface{}{"invitationCode": "c"})
			return err
		}, "POST", "/v1/organizations/join", map[string]interface{}{"invitationCode": "c"}},
		{"orgs.list_invitations", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.ListInvitations(ctx, "org_1")
			return err
		}, "GET", "/v1/organizations/org_1/invitations", nil},
		{"orgs.create_invitation", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.CreateInvitation(ctx, "org_1", map[string]interface{}{"email": "a@b.c"})
			return err
		}, "POST", "/v1/organizations/org_1/invitations", map[string]interface{}{"email": "a@b.c"}},
		{"orgs.cancel_invitation", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.CancelInvitation(ctx, "org_1", "inv_1")
			return err
		}, "POST", "/v1/organizations/org_1/invitations/inv_1/cancel", nil},
		{"orgs.send_invite", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.SendInvite(ctx, "org_1", map[string]interface{}{"email": "a@b.c"})
			return err
		}, "POST", "/v1/organizations/org_1/invites", map[string]interface{}{"email": "a@b.c"}},
		{"orgs.list_members", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.ListMembers(ctx, "org_1")
			return err
		}, "GET", "/v1/organizations/org_1/members", nil},
		{"orgs.remove_member", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.RemoveMember(ctx, "org_1", "mem_1")
			return err
		}, "DELETE", "/v1/organizations/org_1/members/mem_1", nil},
		{"orgs.set_member_active", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.SetMemberActive(ctx, "org_1", "mem_1", map[string]interface{}{"active": false})
			return err
		}, "PATCH", "/v1/organizations/org_1/members/mem_1/active", map[string]interface{}{"active": false}},
		{"orgs.link_tenant", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.LinkTenant(ctx, "org_1", map[string]interface{}{"tenantId": "ten_1"})
			return err
		}, "POST", "/v1/organizations/org_1/tenants", map[string]interface{}{"tenantId": "ten_1"}},
		{"orgs.unlink_tenant", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.UnlinkTenant(ctx, "org_1", "ten_1")
			return err
		}, "DELETE", "/v1/organizations/org_1/tenants/ten_1", nil},
		{"tenants.list", func(ctx context.Context, c *Client) error {
			_, err := c.Tenants.List(ctx, "")
			return err
		}, "GET", "/v1/tenants", nil},
		{"tenants.create", func(ctx context.Context, c *Client) error {
			_, err := c.Tenants.Create(ctx, map[string]interface{}{"name": "T"})
			return err
		}, "POST", "/v1/tenants", map[string]interface{}{"name": "T"}},
		{"tenants.join", func(ctx context.Context, c *Client) error {
			_, err := c.Tenants.Join(ctx, map[string]interface{}{"invitationCode": "c"})
			return err
		}, "POST", "/v1/tenants/join", map[string]interface{}{"invitationCode": "c"}},
		{"tenants.get", func(ctx context.Context, c *Client) error {
			_, err := c.Tenants.Get(ctx, "ten_1", "")
			return err
		}, "GET", "/v1/tenants/ten_1", nil},
		{"tenants.update", func(ctx context.Context, c *Client) error {
			_, err := c.Tenants.Update(ctx, "ten_1", map[string]interface{}{"name": "N"})
			return err
		}, "PATCH", "/v1/tenants/ten_1", map[string]interface{}{"name": "N"}},
		{"tenants.delete", func(ctx context.Context, c *Client) error {
			_, err := c.Tenants.Delete(ctx, "ten_1")
			return err
		}, "DELETE", "/v1/tenants/ten_1", nil},
		{"tenants.list_domains", func(ctx context.Context, c *Client) error {
			_, err := c.Tenants.ListDomains(ctx, "ten_1")
			return err
		}, "GET", "/v1/tenants/ten_1/domains", nil},
		{"tenants.create_domain", func(ctx context.Context, c *Client) error {
			_, err := c.Tenants.CreateDomain(ctx, "ten_1", map[string]interface{}{"domain": "a.com", "validationMethod": "dns"})
			return err
		}, "POST", "/v1/tenants/ten_1/domains", map[string]interface{}{"domain": "a.com", "validationMethod": "dns"}},
		{"tenants.delete_domain", func(ctx context.Context, c *Client) error {
			_, err := c.Tenants.DeleteDomain(ctx, "ten_1", "dom_1")
			return err
		}, "DELETE", "/v1/tenants/ten_1/domains/dom_1", nil},
		{"tenants.retry_domain", func(ctx context.Context, c *Client) error {
			_, err := c.Tenants.RetryDomain(ctx, "ten_1", "dom_1")
			return err
		}, "POST", "/v1/tenants/ten_1/domains/dom_1/retry", nil},
		{"tenants.send_invite", func(ctx context.Context, c *Client) error {
			_, err := c.Tenants.SendInvite(ctx, "ten_1", map[string]interface{}{"email": "a@b.c"})
			return err
		}, "POST", "/v1/tenants/ten_1/invites", map[string]interface{}{"email": "a@b.c"}},
		{"tenants.list_projects", func(ctx context.Context, c *Client) error {
			_, err := c.Tenants.ListProjects(ctx, "ten_1")
			return err
		}, "GET", "/v1/tenants/ten_1/projects", nil},
		{"tenants.list_seats", func(ctx context.Context, c *Client) error {
			_, err := c.Tenants.ListSeats(ctx, "ten_1")
			return err
		}, "GET", "/v1/tenants/ten_1/seats", nil},
		{"tenants.update_seat", func(ctx context.Context, c *Client) error {
			_, err := c.Tenants.UpdateSeat(ctx, "ten_1", "seat_1", map[string]interface{}{"active": true})
			return err
		}, "PATCH", "/v1/tenants/ten_1/seats/seat_1", map[string]interface{}{"active": true}},
		{"tenants.delete_seat", func(ctx context.Context, c *Client) error {
			_, err := c.Tenants.DeleteSeat(ctx, "ten_1", "seat_1")
			return err
		}, "DELETE", "/v1/tenants/ten_1/seats/seat_1", nil},
		{"projects.save", func(ctx context.Context, c *Client) error {
			_, err := c.Projects.Save(ctx, "ten_1", map[string]interface{}{"name": "App"})
			return err
		}, "POST", "/v1/tenants/ten_1/applications", map[string]interface{}{"name": "App"}},
		{"projects.get", func(ctx context.Context, c *Client) error {
			_, err := c.Projects.Get(ctx, "ten_1", "app_1")
			return err
		}, "GET", "/v1/tenants/ten_1/applications/app_1", nil},
		{"projects.delete", func(ctx context.Context, c *Client) error {
			_, err := c.Projects.Delete(ctx, "ten_1", "app_1")
			return err
		}, "DELETE", "/v1/tenants/ten_1/applications/app_1", nil},
		{"projects.set_default_environment", func(ctx context.Context, c *Client) error {
			_, err := c.Projects.SetDefaultEnvironment(ctx, "ten_1", "app_1", map[string]interface{}{"environmentId": "env_1"})
			return err
		}, "PUT", "/v1/tenants/ten_1/applications/app_1/default-environment", map[string]interface{}{"environmentId": "env_1"}},
		{"environments.list", func(ctx context.Context, c *Client) error {
			_, err := c.Environments.List(ctx, "ten_1", "app_1")
			return err
		}, "GET", "/v1/tenants/ten_1/applications/app_1/environments", nil},
		{"environments.create", func(ctx context.Context, c *Client) error {
			_, err := c.Environments.Create(ctx, "ten_1", "app_1", map[string]interface{}{"name": "prod"})
			return err
		}, "POST", "/v1/tenants/ten_1/applications/app_1/environments", map[string]interface{}{"name": "prod"}},
		{"environments.update", func(ctx context.Context, c *Client) error {
			_, err := c.Environments.Update(ctx, "ten_1", "env_1", map[string]interface{}{"name": "prod"})
			return err
		}, "PATCH", "/v1/tenants/ten_1/environments/env_1", map[string]interface{}{"name": "prod"}},
		{"environments.delete", func(ctx context.Context, c *Client) error {
			_, err := c.Environments.Delete(ctx, "ten_1", "env_1")
			return err
		}, "DELETE", "/v1/tenants/ten_1/environments/env_1", nil},
		{"users.list", func(ctx context.Context, c *Client) error {
			_, err := c.Users.List(ctx, "ten_1", "env_1", nil)
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/users", nil},
		{"users.create", func(ctx context.Context, c *Client) error {
			_, err := c.Users.Create(ctx, "ten_1", "env_1", map[string]interface{}{"email": "a@b.c", "password": "x"})
			return err
		}, "POST", "/v1/tenants/ten_1/environments/env_1/users", map[string]interface{}{"email": "a@b.c", "password": "x"}},
		{"users.search", func(ctx context.Context, c *Client) error {
			_, err := c.Users.Search(ctx, "ten_1", "env_1", &UsersSearchOptions{Q: "ada"})
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/users/search", nil},
		{"users.count", func(ctx context.Context, c *Client) error {
			_, err := c.Users.Count(ctx, "ten_1", "env_1")
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/users/count", nil},
		{"users.get", func(ctx context.Context, c *Client) error {
			_, err := c.Users.Get(ctx, "ten_1", "env_1", "usr_1")
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/users/usr_1", nil},
		{"users.update", func(ctx context.Context, c *Client) error {
			_, err := c.Users.Update(ctx, "ten_1", "env_1", "usr_1", map[string]interface{}{"displayName": "Ada"})
			return err
		}, "PUT", "/v1/tenants/ten_1/environments/env_1/users/usr_1", map[string]interface{}{"displayName": "Ada"}},
		{"users.delete", func(ctx context.Context, c *Client) error {
			_, err := c.Users.Delete(ctx, "ten_1", "env_1", "usr_1")
			return err
		}, "DELETE", "/v1/tenants/ten_1/environments/env_1/users/usr_1", nil},
		{"users.set_active", func(ctx context.Context, c *Client) error {
			_, err := c.Users.SetActive(ctx, "ten_1", "env_1", "usr_1", map[string]interface{}{"active": false})
			return err
		}, "PATCH", "/v1/tenants/ten_1/environments/env_1/users/usr_1/active", map[string]interface{}{"active": false}},
		{"users.list_groups", func(ctx context.Context, c *Client) error {
			_, err := c.Users.ListGroups(ctx, "ten_1", "env_1", "usr_1")
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/users/usr_1/groups", nil},
		{"groups.create", func(ctx context.Context, c *Client) error {
			_, err := c.Groups.Create(ctx, map[string]interface{}{"environmentId": "env_1", "name": "Admins"})
			return err
		}, "POST", "/v1/groups", map[string]interface{}{"environmentId": "env_1", "name": "Admins"}},
		{"groups.list", func(ctx context.Context, c *Client) error {
			_, err := c.Groups.List(ctx, "ten_1", "env_1")
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/groups", nil},
		{"groups.delete", func(ctx context.Context, c *Client) error {
			_, err := c.Groups.Delete(ctx, "ten_1", "env_1", "grp_1")
			return err
		}, "DELETE", "/v1/tenants/ten_1/environments/env_1/groups/grp_1", nil},
		{"groups.list_members", func(ctx context.Context, c *Client) error {
			_, err := c.Groups.ListMembers(ctx, "ten_1", "env_1", "grp_1")
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/groups/grp_1/members", nil},
		{"groups.add_member", func(ctx context.Context, c *Client) error {
			_, err := c.Groups.AddMember(ctx, "ten_1", "env_1", "grp_1", map[string]interface{}{"userId": "usr_1"})
			return err
		}, "POST", "/v1/tenants/ten_1/environments/env_1/groups/grp_1/members", map[string]interface{}{"userId": "usr_1"}},
		{"groups.remove_member", func(ctx context.Context, c *Client) error {
			_, err := c.Groups.RemoveMember(ctx, "ten_1", "env_1", "grp_1", "usr_1")
			return err
		}, "DELETE", "/v1/tenants/ten_1/environments/env_1/groups/grp_1/members/usr_1", nil},
	}
}

func TestWave1MethodAndPath(t *testing.T) {
	cases := wave1Cases()
	if len(cases) != 54 {
		t.Fatalf("wave1 resource cases = %d, want 54", len(cases))
	}

	for _, tt := range cases {
		t.Run(tt.name, func(t *testing.T) {
			var gotMethod, gotPath, gotAuth string
			var gotBody map[string]interface{}
			client := managementClient(t, func(w http.ResponseWriter, r *http.Request) {
				gotMethod = r.Method
				gotPath = r.URL.Path
				gotAuth = r.Header.Get("Authorization")
				if r.Body != nil {
					if err := json.NewDecoder(r.Body).Decode(&gotBody); err != nil && err != io.EOF {
						t.Errorf("decode body: %v", err)
					}
				}
				writeJSON(t, w, http.StatusOK, map[string]interface{}{})
			})

			if err := tt.call(context.Background(), client); err != nil {
				t.Fatalf("call error = %v", err)
			}
			if gotAuth != "Bearer key-1" {
				t.Errorf("Authorization = %q, want Bearer key-1", gotAuth)
			}
			if gotMethod != tt.method {
				t.Errorf("method = %s, want %s", gotMethod, tt.method)
			}
			if gotPath != tt.path {
				t.Errorf("path = %s, want %s", gotPath, tt.path)
			}
			if tt.body == nil {
				if gotBody != nil {
					t.Errorf("body = %#v, want nil", gotBody)
				}
			} else if !reflect.DeepEqual(gotBody, tt.body) {
				t.Errorf("body = %#v, want %#v", gotBody, tt.body)
			}
		})
	}
}

type wave2Case struct {
	name   string
	call   func(ctx context.Context, c *Client) error
	method string
	path   string
	body   map[string]interface{}
}

func wave2Cases() []wave2Case {
	return []wave2Case{
		{"orgs.list_keys", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.ListKeys(ctx, "org_1")
			return err
		}, "GET", "/v1/organizations/org_1/keys", nil},
		{"orgs.create_key", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.CreateKey(ctx, "org_1", map[string]interface{}{"name": "ci"})
			return err
		}, "POST", "/v1/organizations/org_1/keys", map[string]interface{}{"name": "ci"}},
		{"orgs.revoke_key", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.RevokeKey(ctx, "org_1", "key_1")
			return err
		}, "POST", "/v1/organizations/org_1/keys/key_1/revoke", nil},
		{"orgs.rotate_key", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.RotateKey(ctx, "org_1", "key_1")
			return err
		}, "POST", "/v1/organizations/org_1/keys/key_1/rotate", nil},
		{"orgs.update_key_tenants", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.UpdateKeyTenants(ctx, "org_1", "key_1", map[string]interface{}{"tenantIds": []interface{}{"ten_1"}})
			return err
		}, "PUT", "/v1/organizations/org_1/keys/key_1/tenants", map[string]interface{}{"tenantIds": []interface{}{"ten_1"}}},
		{"orgs.list_audit_logs", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.ListAuditLogs(ctx, "org_1", nil)
			return err
		}, "GET", "/v1/organizations/org_1/audit/logs", nil},
		{"service_accounts.list", func(ctx context.Context, c *Client) error {
			_, err := c.ServiceAccounts.List(ctx)
			return err
		}, "GET", "/v1/service-accounts", nil},
		{"service_accounts.create", func(ctx context.Context, c *Client) error {
			_, err := c.ServiceAccounts.Create(ctx, map[string]interface{}{"name": "bot"})
			return err
		}, "POST", "/v1/service-accounts", map[string]interface{}{"name": "bot"}},
		{"service_accounts.get", func(ctx context.Context, c *Client) error {
			_, err := c.ServiceAccounts.Get(ctx, "sa_1")
			return err
		}, "GET", "/v1/service-accounts/sa_1", nil},
		{"service_accounts.delete", func(ctx context.Context, c *Client) error {
			_, err := c.ServiceAccounts.Delete(ctx, "sa_1")
			return err
		}, "DELETE", "/v1/service-accounts/sa_1", nil},
		{"personal_access_tokens.list", func(ctx context.Context, c *Client) error {
			_, err := c.PersonalAccessTokens.List(ctx)
			return err
		}, "GET", "/v1/personal-access-tokens", nil},
		{"personal_access_tokens.create", func(ctx context.Context, c *Client) error {
			_, err := c.PersonalAccessTokens.Create(ctx, map[string]interface{}{"name": "cli"})
			return err
		}, "POST", "/v1/personal-access-tokens", map[string]interface{}{"name": "cli"}},
		{"personal_access_tokens.revoke", func(ctx context.Context, c *Client) error {
			_, err := c.PersonalAccessTokens.Revoke(ctx, "pat_1")
			return err
		}, "POST", "/v1/personal-access-tokens/pat_1/revoke", nil},
		{"api_secrets.list", func(ctx context.Context, c *Client) error {
			_, err := c.ApiSecrets.List(ctx, "ten_1", "env_1")
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/api-secrets", nil},
		{"api_secrets.create", func(ctx context.Context, c *Client) error {
			_, err := c.ApiSecrets.Create(ctx, "ten_1", "env_1", map[string]interface{}{"name": "runtime"})
			return err
		}, "POST", "/v1/tenants/ten_1/environments/env_1/api-secrets", map[string]interface{}{"name": "runtime"}},
		{"api_secrets.revoke", func(ctx context.Context, c *Client) error {
			_, err := c.ApiSecrets.Revoke(ctx, "ten_1", "env_1", "sec_1")
			return err
		}, "POST", "/v1/tenants/ten_1/environments/env_1/api-secrets/sec_1/revoke", nil},
		{"audit.list_logs", func(ctx context.Context, c *Client) error {
			_, err := c.Audit.ListLogs(ctx, "ten_1", "env_1", nil)
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/audit/logs", nil},
		{"audit.event_metadata", func(ctx context.Context, c *Client) error {
			_, err := c.Audit.EventMetadata(ctx, "ten_1", "env_1", nil)
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/audit/event-metadata", nil},
		{"audit.event_types", func(ctx context.Context, c *Client) error {
			_, err := c.Audit.EventTypes(ctx, "ten_1", "env_1", nil)
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/audit/event-types", nil},
		{"audit.event_types_catalog", func(ctx context.Context, c *Client) error {
			_, err := c.Audit.EventTypesCatalog(ctx, "ten_1", "env_1")
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/audit/event-types/catalog", nil},
		{"events.list", func(ctx context.Context, c *Client) error {
			_, err := c.Events.List(ctx, "ten_1", "env_1", nil)
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/events", nil},
		{"events.list_types", func(ctx context.Context, c *Client) error {
			_, err := c.Events.ListTypes(ctx, "ten_1", "env_1")
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/events/types", nil},
		{"events.ingest", func(ctx context.Context, c *Client) error {
			_, err := c.Events.Ingest(ctx, "ten_1", "env_1", map[string]interface{}{"events": []interface{}{}})
			return err
		}, "POST", "/v1/tenants/ten_1/environments/env_1/events/ingest", map[string]interface{}{"events": []interface{}{}}},
		{"webhooks.list", func(ctx context.Context, c *Client) error {
			_, err := c.Webhooks.List(ctx, "ten_1", "env_1")
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/webhooks", nil},
		{"webhooks.create", func(ctx context.Context, c *Client) error {
			_, err := c.Webhooks.Create(ctx, "ten_1", "env_1", map[string]interface{}{"url": "https://ex"})
			return err
		}, "POST", "/v1/tenants/ten_1/environments/env_1/webhooks", map[string]interface{}{"url": "https://ex"}},
		{"webhooks.update", func(ctx context.Context, c *Client) error {
			_, err := c.Webhooks.Update(ctx, "ten_1", "env_1", "ch_1", map[string]interface{}{"url": "https://ex"})
			return err
		}, "PUT", "/v1/tenants/ten_1/environments/env_1/webhooks/ch_1", map[string]interface{}{"url": "https://ex"}},
		{"webhooks.delete", func(ctx context.Context, c *Client) error {
			_, err := c.Webhooks.Delete(ctx, "ten_1", "env_1", "ch_1")
			return err
		}, "DELETE", "/v1/tenants/ten_1/environments/env_1/webhooks/ch_1", nil},
		{"webhooks.rotate_secret", func(ctx context.Context, c *Client) error {
			_, err := c.Webhooks.RotateSecret(ctx, "ten_1", "env_1", "ch_1")
			return err
		}, "POST", "/v1/tenants/ten_1/environments/env_1/webhooks/ch_1/rotate-secret", nil},
		{"webhooks.list_deliveries", func(ctx context.Context, c *Client) error {
			_, err := c.Webhooks.ListDeliveries(ctx, "ten_1", "env_1", nil)
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/webhooks/deliveries", nil},
		{"webhooks.redeliver", func(ctx context.Context, c *Client) error {
			_, err := c.Webhooks.Redeliver(ctx, "ten_1", "env_1", "del_1")
			return err
		}, "POST", "/v1/tenants/ten_1/environments/env_1/webhooks/deliveries/del_1/redeliver", nil},
		{"notification_channels.list", func(ctx context.Context, c *Client) error {
			_, err := c.NotificationChannels.List(ctx, "ten_1", "env_1")
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/notification-channels", nil},
		{"notification_channels.create", func(ctx context.Context, c *Client) error {
			_, err := c.NotificationChannels.Create(ctx, "ten_1", "env_1", map[string]interface{}{"type": "webhook"})
			return err
		}, "POST", "/v1/tenants/ten_1/environments/env_1/notification-channels", map[string]interface{}{"type": "webhook"}},
		{"notification_channels.update", func(ctx context.Context, c *Client) error {
			_, err := c.NotificationChannels.Update(ctx, "ten_1", "env_1", "ch_1", map[string]interface{}{"name": "n"})
			return err
		}, "PUT", "/v1/tenants/ten_1/environments/env_1/notification-channels/ch_1", map[string]interface{}{"name": "n"}},
		{"notification_channels.delete", func(ctx context.Context, c *Client) error {
			_, err := c.NotificationChannels.Delete(ctx, "ten_1", "env_1", "ch_1")
			return err
		}, "DELETE", "/v1/tenants/ten_1/environments/env_1/notification-channels/ch_1", nil},
		{"notification_channels.test", func(ctx context.Context, c *Client) error {
			_, err := c.NotificationChannels.Test(ctx, "ten_1", "env_1", "ch_1", nil)
			return err
		}, "POST", "/v1/tenants/ten_1/environments/env_1/notification-channels/ch_1/test", nil},
		{"rbac.list_roles", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.ListRoles(ctx, "ten_1", "env_1")
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/roles", nil},
		{"rbac.create_role", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.CreateRole(ctx, "ten_1", "env_1", map[string]interface{}{"name": "admin"})
			return err
		}, "POST", "/v1/tenants/ten_1/environments/env_1/roles", map[string]interface{}{"name": "admin"}},
		{"rbac.delete_role", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.DeleteRole(ctx, "ten_1", "env_1", "role_1")
			return err
		}, "DELETE", "/v1/tenants/ten_1/environments/env_1/roles/role_1", nil},
		{"rbac.list_role_permissions", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.ListRolePermissions(ctx, "ten_1", "env_1", "role_1")
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/roles/role_1/permissions", nil},
		{"rbac.set_role_permissions", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.SetRolePermissions(ctx, "ten_1", "env_1", "role_1", map[string]interface{}{"permissionIds": []interface{}{}})
			return err
		}, "PUT", "/v1/tenants/ten_1/environments/env_1/roles/role_1/permissions", map[string]interface{}{"permissionIds": []interface{}{}}},
		{"rbac.list_permissions", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.ListPermissions(ctx, "ten_1", "env_1")
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/permissions", nil},
		{"rbac.create_permission", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.CreatePermission(ctx, "ten_1", "env_1", map[string]interface{}{"name": "read"})
			return err
		}, "POST", "/v1/tenants/ten_1/environments/env_1/permissions", map[string]interface{}{"name": "read"}},
		{"rbac.delete_permission", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.DeletePermission(ctx, "ten_1", "env_1", "perm_1")
			return err
		}, "DELETE", "/v1/tenants/ten_1/environments/env_1/permissions/perm_1", nil},
		{"rbac.list_resources", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.ListResources(ctx, "ten_1", "env_1")
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/resources", nil},
		{"rbac.create_resource", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.CreateResource(ctx, "ten_1", "env_1", map[string]interface{}{"name": "doc"})
			return err
		}, "POST", "/v1/tenants/ten_1/environments/env_1/resources", map[string]interface{}{"name": "doc"}},
		{"rbac.delete_resource", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.DeleteResource(ctx, "ten_1", "env_1", "res_1")
			return err
		}, "DELETE", "/v1/tenants/ten_1/environments/env_1/resources/res_1", nil},
		{"rbac.list_group_roles", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.ListGroupRoles(ctx, "ten_1", "env_1", "grp_1")
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/groups/grp_1/roles", nil},
		{"rbac.add_group_role", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.AddGroupRole(ctx, "ten_1", "env_1", "grp_1", map[string]interface{}{"roleId": "role_1"})
			return err
		}, "POST", "/v1/tenants/ten_1/environments/env_1/groups/grp_1/roles", map[string]interface{}{"roleId": "role_1"}},
		{"rbac.remove_group_role", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.RemoveGroupRole(ctx, "ten_1", "env_1", "grp_1", "role_1")
			return err
		}, "DELETE", "/v1/tenants/ten_1/environments/env_1/groups/grp_1/roles/role_1", nil},
		{"rbac.list_group_role_mappings", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.ListGroupRoleMappings(ctx, "ten_1", "env_1")
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/group-role-mappings", nil},
		{"rbac.create_group_role_mapping", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.CreateGroupRoleMapping(ctx, "ten_1", "env_1", map[string]interface{}{"groupId": "grp_1"})
			return err
		}, "POST", "/v1/tenants/ten_1/environments/env_1/group-role-mappings", map[string]interface{}{"groupId": "grp_1"}},
		{"rbac.apply_group_role_mappings", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.ApplyGroupRoleMappings(ctx, "ten_1", "env_1")
			return err
		}, "POST", "/v1/tenants/ten_1/environments/env_1/group-role-mappings/apply", nil},
		{"rbac.delete_group_role_mapping", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.DeleteGroupRoleMapping(ctx, "ten_1", "env_1", "map_1")
			return err
		}, "DELETE", "/v1/tenants/ten_1/environments/env_1/group-role-mappings/map_1", nil},
		{"rbac.list_abac_policies", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.ListAbacPolicies(ctx, "ten_1", "env_1")
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/abac-policies", nil},
		{"rbac.save_abac_policy", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.SaveAbacPolicy(ctx, "ten_1", "env_1", map[string]interface{}{"name": "p"})
			return err
		}, "POST", "/v1/tenants/ten_1/environments/env_1/abac-policies", map[string]interface{}{"name": "p"}},
		{"rbac.validate_abac_policy", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.ValidateAbacPolicy(ctx, "ten_1", "env_1", map[string]interface{}{"rego": "x"})
			return err
		}, "POST", "/v1/tenants/ten_1/environments/env_1/abac-policies/validate", map[string]interface{}{"rego": "x"}},
		{"rbac.delete_abac_policy", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.DeleteAbacPolicy(ctx, "ten_1", "env_1", "pol_1")
			return err
		}, "DELETE", "/v1/tenants/ten_1/environments/env_1/abac-policies/pol_1", nil},
		{"rbac.my_permissions", func(ctx context.Context, c *Client) error {
			_, err := c.Rbac.MyPermissions(ctx, "ten_1", "env_1")
			return err
		}, "GET", "/v1/tenants/ten_1/environments/env_1/me/permissions", nil},
	}
}

func TestWave2MethodAndPath(t *testing.T) {
	cases := wave2Cases()
	if len(cases) != 58 {
		t.Fatalf("wave2 resource cases = %d, want 58", len(cases))
	}

	for _, tt := range cases {
		t.Run(tt.name, func(t *testing.T) {
			var gotMethod, gotPath, gotAuth string
			var gotBody map[string]interface{}
			client := managementClient(t, func(w http.ResponseWriter, r *http.Request) {
				gotMethod = r.Method
				gotPath = r.URL.Path
				gotAuth = r.Header.Get("Authorization")
				if r.Body != nil {
					if err := json.NewDecoder(r.Body).Decode(&gotBody); err != nil && err != io.EOF {
						t.Errorf("decode body: %v", err)
					}
				}
				writeJSON(t, w, http.StatusOK, map[string]interface{}{})
			})

			if err := tt.call(context.Background(), client); err != nil {
				t.Fatalf("call error = %v", err)
			}
			if gotAuth != "Bearer key-1" {
				t.Errorf("Authorization = %q, want Bearer key-1", gotAuth)
			}
			if gotMethod != tt.method {
				t.Errorf("method = %s, want %s", gotMethod, tt.method)
			}
			if gotPath != tt.path {
				t.Errorf("path = %s, want %s", gotPath, tt.path)
			}
			if tt.body == nil {
				if gotBody != nil {
					t.Errorf("body = %#v, want nil", gotBody)
				}
			} else if !reflect.DeepEqual(gotBody, tt.body) {
				t.Errorf("body = %#v, want %#v", gotBody, tt.body)
			}
		})
	}
}

func TestWave2_CreateKeyExposesOneTimeSecret(t *testing.T) {
	client := managementClient(t, func(w http.ResponseWriter, r *http.Request) {
		writeJSON(t, w, http.StatusOK, map[string]interface{}{
			"token": "orgk_secret_once",
			"key":   map[string]interface{}{"id": "key_1"},
		})
	})

	created, err := client.Organizations.CreateKey(context.Background(), "org_1", map[string]interface{}{"name": "ci"})
	if err != nil {
		t.Fatalf("CreateKey() error = %v", err)
	}
	if created["token"] != "orgk_secret_once" {
		t.Errorf("token = %#v, want orgk_secret_once", created["token"])
	}
}

func TestWave2_CreateRotateExposeOneTimeSecrets(t *testing.T) {
	cases := []struct {
		name   string
		secret string
		field  string
		call   func(ctx context.Context, c *Client) (map[string]interface{}, error)
	}{
		{"orgs.create_key", "orgk_secret_once", "token", func(ctx context.Context, c *Client) (map[string]interface{}, error) {
			return c.Organizations.CreateKey(ctx, "org_1", map[string]interface{}{"name": "ci"})
		}},
		{"orgs.rotate_key", "orgk_rotated", "token", func(ctx context.Context, c *Client) (map[string]interface{}, error) {
			return c.Organizations.RotateKey(ctx, "org_1", "key_1")
		}},
		{"service_accounts.create", "sa_secret_once", "token", func(ctx context.Context, c *Client) (map[string]interface{}, error) {
			return c.ServiceAccounts.Create(ctx, map[string]interface{}{"name": "bot"})
		}},
		{"personal_access_tokens.create", "pat_secret_once", "token", func(ctx context.Context, c *Client) (map[string]interface{}, error) {
			return c.PersonalAccessTokens.Create(ctx, map[string]interface{}{"name": "cli"})
		}},
		{"api_secrets.create", "api_secret_once", "secret", func(ctx context.Context, c *Client) (map[string]interface{}, error) {
			return c.ApiSecrets.Create(ctx, "ten_1", "env_1", map[string]interface{}{"name": "runtime"})
		}},
		{"webhooks.create", "whsec_once", "secret", func(ctx context.Context, c *Client) (map[string]interface{}, error) {
			return c.Webhooks.Create(ctx, "ten_1", "env_1", map[string]interface{}{"url": "https://ex"})
		}},
		{"webhooks.rotate_secret", "whsec_rotated", "secret", func(ctx context.Context, c *Client) (map[string]interface{}, error) {
			return c.Webhooks.RotateSecret(ctx, "ten_1", "env_1", "ch_1")
		}},
	}

	for _, tt := range cases {
		t.Run(tt.name, func(t *testing.T) {
			client := managementClient(t, func(w http.ResponseWriter, r *http.Request) {
				writeJSON(t, w, http.StatusOK, map[string]interface{}{tt.field: tt.secret})
			})
			got, err := tt.call(context.Background(), client)
			if err != nil {
				t.Fatalf("call error = %v", err)
			}
			if got[tt.field] != tt.secret {
				t.Errorf("%s = %#v, want %s", tt.field, got[tt.field], tt.secret)
			}
		})
	}
}

func TestWave2_QueryParamsForwarded(t *testing.T) {
	query := url.Values{}
	query.Set("limit", "50")
	query.Set("after", "cur_1")

	cases := []struct {
		name string
		call func(ctx context.Context, c *Client) error
		path string
	}{
		{"events.list", func(ctx context.Context, c *Client) error {
			_, err := c.Events.List(ctx, "ten_1", "env_1", query)
			return err
		}, "/v1/tenants/ten_1/environments/env_1/events"},
		{"audit.list_logs", func(ctx context.Context, c *Client) error {
			_, err := c.Audit.ListLogs(ctx, "ten_1", "env_1", query)
			return err
		}, "/v1/tenants/ten_1/environments/env_1/audit/logs"},
		{"audit.event_metadata", func(ctx context.Context, c *Client) error {
			_, err := c.Audit.EventMetadata(ctx, "ten_1", "env_1", query)
			return err
		}, "/v1/tenants/ten_1/environments/env_1/audit/event-metadata"},
		{"audit.event_types", func(ctx context.Context, c *Client) error {
			_, err := c.Audit.EventTypes(ctx, "ten_1", "env_1", query)
			return err
		}, "/v1/tenants/ten_1/environments/env_1/audit/event-types"},
		{"webhooks.list_deliveries", func(ctx context.Context, c *Client) error {
			_, err := c.Webhooks.ListDeliveries(ctx, "ten_1", "env_1", query)
			return err
		}, "/v1/tenants/ten_1/environments/env_1/webhooks/deliveries"},
		{"orgs.list_audit_logs", func(ctx context.Context, c *Client) error {
			_, err := c.Organizations.ListAuditLogs(ctx, "org_1", query)
			return err
		}, "/v1/organizations/org_1/audit/logs"},
	}

	for _, tt := range cases {
		t.Run(tt.name, func(t *testing.T) {
			var gotPath string
			var gotQuery url.Values
			client := managementClient(t, func(w http.ResponseWriter, r *http.Request) {
				gotPath = r.URL.Path
				gotQuery = r.URL.Query()
				writeJSON(t, w, http.StatusOK, map[string]interface{}{})
			})
			if err := tt.call(context.Background(), client); err != nil {
				t.Fatalf("call error = %v", err)
			}
			if gotPath != tt.path {
				t.Errorf("path = %s, want %s", gotPath, tt.path)
			}
			if gotQuery.Get("limit") != "50" {
				t.Errorf("limit = %q, want 50", gotQuery.Get("limit"))
			}
			if gotQuery.Get("after") != "cur_1" {
				t.Errorf("after = %q, want cur_1", gotQuery.Get("after"))
			}
		})
	}
}
