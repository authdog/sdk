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
}

impl APIError {
    pub fn new(message: String) -> Self {
        Self { message }
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
