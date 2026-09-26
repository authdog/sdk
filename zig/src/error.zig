// MIT License
//
// Copyright (c) 2025 Authdog
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
