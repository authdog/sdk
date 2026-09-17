use std::fmt;

/// Base error type for all Authdog SDK errors.
///
/// Variants stay distinguishable after `?` so callers can match
/// authentication vs API failures without reading message strings.
#[derive(Debug)]
pub enum AuthdogError {
    Authentication(AuthenticationError),
    Api(APIError),
    Other(String),
}

impl AuthdogError {
    pub fn new(message: String) -> Self {
        Self::Other(message)
    }

    pub fn is_authentication(&self) -> bool {
        matches!(self, Self::Authentication(_))
    }

    pub fn is_api(&self) -> bool {
        matches!(self, Self::Api(_))
    }
}

impl fmt::Display for AuthdogError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Authentication(err) => write!(f, "{}", err),
            Self::Api(err) => write!(f, "{}", err),
            Self::Other(message) => write!(f, "{}", message),
        }
    }
}

impl std::error::Error for AuthdogError {}

/// Raised when authentication fails
#[derive(Debug)]
pub struct AuthenticationError {
    message: String,
}

impl AuthenticationError {
    pub fn new(message: String) -> Self {
        Self { message }
    }
}

impl fmt::Display for AuthenticationError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.message)
    }
}

impl std::error::Error for AuthenticationError {}

impl From<AuthenticationError> for AuthdogError {
    fn from(err: AuthenticationError) -> Self {
        AuthdogError::Authentication(err)
    }
}

/// Raised when API requests fail
#[derive(Debug)]
pub struct APIError {
    message: String,
    status_code: Option<u16>,
}

impl APIError {
    pub fn new(message: String) -> Self {
        Self {
            message,
            status_code: None,
        }
    }

    pub fn with_status(status_code: u16, error_text: impl Into<String>) -> Self {
        let error_text = error_text.into();
        Self {
            message: format!("HTTP error {}: {}", status_code, error_text),
            status_code: Some(status_code),
        }
    }

    pub fn status_code(&self) -> Option<u16> {
        self.status_code
    }
}

impl fmt::Display for APIError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.message)
    }
}

impl std::error::Error for APIError {}

impl From<APIError> for AuthdogError {
    fn from(err: APIError) -> Self {
        AuthdogError::Api(err)
    }
}
