use std::fmt;

/// Base error type for all Authdog SDK errors
#[derive(Debug)]
pub struct AuthdogError {
    message: String,
}

impl AuthdogError {
    pub fn new(message: String) -> Self {
        Self { message }
    }
}

impl fmt::Display for AuthdogError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.message)
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
        AuthdogError::new(err.message)
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
        AuthdogError::new(err.message)
    }
}
