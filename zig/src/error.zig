const std = @import("std");

/// Public error set for Authdog operations.
///
/// Callers can distinguish authentication vs API vs parse failures
/// without reading message strings:
/// - `AuthenticationFailed` — HTTP 401
/// - `ApiError` — other HTTP failures and transport errors
/// - `ParseError` — HTTP 200 with invalid JSON
pub const AuthdogError = error{
    AuthenticationFailed,
    ApiError,
    ParseError,
};

pub const authentication_message = "Unauthorized - invalid or expired token";
pub const graphql_message = "GraphQL query failed";
pub const fetch_user_info_message = "Failed to fetch user info";
pub const parse_message = "Failed to parse response";
pub const request_failed_message = "Request failed";

pub fn isAuthenticationError(err: anyerror) bool {
    return err == error.AuthenticationFailed;
}

pub fn isApiError(err: anyerror) bool {
    return err == error.ApiError;
}

test "error taxonomy is matchable" {
    try std.testing.expect(isAuthenticationError(error.AuthenticationFailed));
    try std.testing.expect(!isAuthenticationError(error.ApiError));
    try std.testing.expect(isApiError(error.ApiError));
    try std.testing.expect(!isApiError(error.AuthenticationFailed));
    try std.testing.expect(!isApiError(error.ParseError));
}
