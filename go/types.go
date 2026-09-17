package authdog

import "time"

// UserInfoResponse represents the response from the /userinfo endpoint
type UserInfoResponse struct {
	Meta    Meta    `json:"meta"`
	Session Session `json:"session"`
	User    User    `json:"user"`
}

// Meta represents metadata in the response
type Meta struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

// Session represents session information
type Session struct {
	RemainingSeconds int `json:"remainingSeconds"`
}

// User represents user information
type User struct {
	ID                string         `json:"id"`
	ExternalID        string         `json:"externalId"`
	UserName          string         `json:"userName"`
	DisplayName       string         `json:"displayName"`
	NickName          *string        `json:"nickName"`
	ProfileURL        *string        `json:"profileUrl"`
	Title             *string        `json:"title"`
	UserType          *string        `json:"userType"`
	PreferredLanguage *string        `json:"preferredLanguage"`
	Locale            string         `json:"locale"`
	Timezone          *string        `json:"timezone"`
	Active            bool           `json:"active"`
	Names             Names          `json:"names"`
	Photos            []Photo        `json:"photos"`
	PhoneNumbers      []interface{}  `json:"phoneNumbers"`
	Addresses         []interface{}  `json:"addresses"`
	Emails            []Email        `json:"emails"`
	Verifications     []Verification `json:"verifications"`
	Provider          string         `json:"provider"`
	CreatedAt         time.Time      `json:"createdAt"`
	UpdatedAt         string         `json:"updatedAt"`
	EnvironmentID     string         `json:"environmentId"`
}

// Names represents user name information
type Names struct {
	ID              string  `json:"id"`
	Formatted       *string `json:"formatted"`
	FamilyName      string  `json:"familyName"`
	GivenName       string  `json:"givenName"`
	MiddleName      *string `json:"middleName"`
	HonorificPrefix *string `json:"honorificPrefix"`
	HonorificSuffix *string `json:"honorificSuffix"`
}

// Photo represents a user photo
type Photo struct {
	ID    string `json:"id"`
	Value string `json:"value"`
	Type  string `json:"type"`
}

// Email represents a user email
type Email struct {
	ID    string  `json:"id"`
	Value string  `json:"value"`
	Type  *string `json:"type"`
}

// Verification represents email verification status
type Verification struct {
	ID        string    `json:"id"`
	Email     string    `json:"email"`
	Verified  bool      `json:"verified"`
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt string    `json:"updatedAt"`
}

// ErrorResponse represents an error response
type ErrorResponse struct {
	Error string `json:"error"`
}

// Probe is the liveness response from GET /v1/health
type Probe struct {
	OK bool `json:"ok"`
}

// Organization is a management organization entity
type Organization struct {
	ID           string  `json:"id"`
	Name         string  `json:"name"`
	Description  *string `json:"description"`
	BillingEmail *string `json:"billingEmail"`
	LogoURI      *string `json:"logoUri"`
	Active       bool    `json:"active"`
	CreatedAt    string  `json:"createdAt"`
	UpdatedAt    string  `json:"updatedAt"`
}

// OrganizationsList is the list envelope for organizations
type OrganizationsList struct {
	Organizations []Organization `json:"organizations"`
	Total         int            `json:"total"`
}

// Tenant is a management tenant entity
type Tenant struct {
	ID              string   `json:"id"`
	Name            string   `json:"name"`
	Description     *string  `json:"description"`
	Company         *string  `json:"company"`
	Active          bool     `json:"active"`
	CreatedAt       string   `json:"createdAt"`
	UpdatedAt       string   `json:"updatedAt"`
	OrganizationIDs []string `json:"organizationIds"`
}

// TenantsList is the list envelope for tenants
type TenantsList struct {
	Tenants []Tenant `json:"tenants"`
	Total   int      `json:"total"`
}

// EnvUserEmail is an email on a directory user
type EnvUserEmail struct {
	ID    string  `json:"id"`
	Value string  `json:"value"`
	Type  *string `json:"type"`
}

// EnvUser is a directory user (distinct from user-info User)
type EnvUser struct {
	ID            string         `json:"id"`
	EnvironmentID *string        `json:"environmentId"`
	ExternalID    *string        `json:"externalId"`
	UserName      *string        `json:"userName"`
	DisplayName   *string        `json:"displayName"`
	NickName      *string        `json:"nickName"`
	ProfileURL    *string        `json:"profileUrl"`
	Active        *bool          `json:"active"`
	ChangePW      *bool          `json:"changePw"`
	Provider      *string        `json:"provider"`
	Emails        []EnvUserEmail `json:"emails"`
	LastLogin     *string        `json:"lastLogin"`
	CreatedAt     *string        `json:"createdAt"`
	UpdatedAt     *string        `json:"updatedAt"`
}

// EnvUsersResponse is the list envelope for directory users
type EnvUsersResponse struct {
	Users []EnvUser `json:"users"`
}

// EnvGroup is a directory group
type EnvGroup struct {
	ID            string  `json:"id"`
	EnvironmentID string  `json:"environmentId"`
	Name          string  `json:"name"`
	Slug          string  `json:"slug"`
	Description   *string `json:"description"`
	MemberCount   int     `json:"memberCount"`
	JoinedAt      *string `json:"joinedAt"`
	CreatedAt     string  `json:"createdAt"`
	UpdatedAt     string  `json:"updatedAt"`
}

// EnvGroupsResponse is the list envelope for directory groups
type EnvGroupsResponse struct {
	Groups []EnvGroup `json:"groups"`
}

// Environment is a project environment entity
type Environment struct {
	ID          string   `json:"id"`
	Name        string   `json:"name"`
	Description *string  `json:"description"`
	Weight      *float64 `json:"weight"`
	IsLive      *bool    `json:"isLive"`
	IsDefault   *bool    `json:"isDefault"`
	CreatedAt   *string  `json:"createdAt"`
	UpdatedAt   *string  `json:"updatedAt"`
}

// Project is a project (application) entity
type Project struct {
	ID          string  `json:"id"`
	Name        string  `json:"name"`
	Description *string `json:"description"`
}
