use authdog::{AuthdogError, AuthenticationError, APIError};

#[test]
fn test_authdog_error_creation() {
    let error = AuthdogError::new("Test error".to_string());
    assert_eq!(error.to_string(), "Test error");
}

#[test]
fn test_authdog_error_implements_error_trait() {
    let error = AuthdogError::new("Test error".to_string());
    let _: &dyn std::error::Error = &error;
}

#[test]
fn test_authentication_error_creation() {
    let error = AuthenticationError::new("Auth failed".to_string());
    assert_eq!(error.to_string(), "Auth failed");
}

#[test]
fn test_authentication_error_implements_error_trait() {
    let error = AuthenticationError::new("Auth failed".to_string());
    let _: &dyn std::error::Error = &error;
}

#[test]
fn test_authentication_error_from_conversion() {
    let auth_error = AuthenticationError::new("Auth failed".to_string());
    let authdog_error: AuthdogError = auth_error.into();
    assert_eq!(authdog_error.to_string(), "Auth failed");
}

#[test]
fn test_api_error_creation() {
    let error = APIError::new("API failed".to_string());
    assert_eq!(error.to_string(), "API failed");
}

#[test]
fn test_api_error_implements_error_trait() {
    let error = APIError::new("API failed".to_string());
    let _: &dyn std::error::Error = &error;
}

#[test]
fn test_api_error_from_conversion() {
    let api_error = APIError::new("API failed".to_string());
    let authdog_error: AuthdogError = api_error.into();
    assert_eq!(authdog_error.to_string(), "API failed");
}

#[test]
fn test_errors_can_be_caught_as_authdog_error() {
    let auth_error = AuthenticationError::new("Auth failed".to_string());
    let api_error = APIError::new("API failed".to_string());
    
    // Test that errors can be converted to AuthdogError
    let authdog_error1: AuthdogError = auth_error.into();
    let authdog_error2: AuthdogError = api_error.into();
    
    assert_eq!(authdog_error1.to_string(), "Auth failed");
    assert_eq!(authdog_error2.to_string(), "API failed");
}

#[test]
fn test_errors_can_be_caught_as_system_error() {
    let auth_error = AuthenticationError::new("Auth failed".to_string());
    let api_error = APIError::new("API failed".to_string());
    
    // Test that errors implement std::error::Error
    let _: &dyn std::error::Error = &auth_error;
    let _: &dyn std::error::Error = &api_error;
}

#[test]
fn test_errors_can_be_thrown_and_caught() {
    fn throw_auth_error() -> Result<(), AuthenticationError> {
        Err(AuthenticationError::new("Test auth error".to_string()))
    }
    
    fn throw_api_error() -> Result<(), APIError> {
        Err(APIError::new("Test API error".to_string()))
    }
    
    match throw_auth_error() {
        Err(e) => assert_eq!(e.to_string(), "Test auth error"),
        Ok(_) => panic!("Expected error"),
    }
    
    match throw_api_error() {
        Err(e) => assert_eq!(e.to_string(), "Test API error"),
        Ok(_) => panic!("Expected error"),
    }
}
