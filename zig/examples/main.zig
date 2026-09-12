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
