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
	ID                 string        `json:"id"`
	ExternalID         string        `json:"externalId"`
	UserName           string        `json:"userName"`
	DisplayName        string        `json:"displayName"`
	NickName           *string       `json:"nickName"`
	ProfileURL         *string       `json:"profileUrl"`
	Title              *string       `json:"title"`
	UserType           *string       `json:"userType"`
	PreferredLanguage  *string       `json:"preferredLanguage"`
	Locale             string        `json:"locale"`
	Timezone           *string       `json:"timezone"`
	Active             bool          `json:"active"`
	Names              Names         `json:"names"`
	Photos             []Photo       `json:"photos"`
	PhoneNumbers       []interface{} `json:"phoneNumbers"`
	Addresses          []interface{} `json:"addresses"`
	Emails             []Email       `json:"emails"`
	Verifications      []Verification `json:"verifications"`
	Provider           string        `json:"provider"`
	CreatedAt          time.Time     `json:"createdAt"`
	UpdatedAt          string        `json:"updatedAt"`
	EnvironmentID      string        `json:"environmentId"`
}

// Names represents user name information
type Names struct {
	ID               string  `json:"id"`
	Formatted        *string `json:"formatted"`
	FamilyName       string  `json:"familyName"`
	GivenName        string  `json:"givenName"`
	MiddleName       *string `json:"middleName"`
	HonorificPrefix  *string `json:"honorificPrefix"`
	HonorificSuffix  *string `json:"honorificSuffix"`
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
