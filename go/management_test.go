package authdog

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
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
