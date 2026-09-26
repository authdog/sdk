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
const authdog = @import("authdog");

pub fn main() !void {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    defer _ = debug_allocator.deinit();
    const allocator = debug_allocator.allocator();

    var client = try authdog.AuthdogClient.init(allocator, .{
        .base_url = "https://api.authdog.com",
        .api_key = null,
    });
    defer client.deinit();

    const user_info = client.getUserInfo("your-access-token") catch |err| {
        if (authdog.isAuthenticationError(err)) {
            std.log.err("{s}", .{client.lastErrorMessage()});
        } else if (authdog.isApiError(err)) {
            std.log.err("API error: {s}", .{client.lastErrorMessage()});
        } else {
            std.log.err("SDK error: {s}", .{client.lastErrorMessage()});
        }
        return;
    };
    defer user_info.deinit();

    std.log.info("User: {s}", .{user_info.user.display_name});
    std.log.info("ID: {s}", .{user_info.user.id});
    std.log.info("Provider: {s}", .{user_info.user.provider});

    if (user_info.user.emails.len > 0) {
        std.log.info("Email: {s}", .{user_info.user.emails[0].value});
    }
}
