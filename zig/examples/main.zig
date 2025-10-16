const std = @import("std");
const authdog = @import("authdog");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Initialize the client
    var client = try authdog.AuthdogClient.init(allocator, "https://api.authdog.com", null, 10000);
    defer client.deinit();

    // Get user information
    const access_token = "your-access-token";
    const user_info = client.getUserInfo(access_token) catch |err| {
        switch (err) {
            authdog.AuthdogError.AuthenticationFailed => {
                std.log.err("Authentication failed: invalid or expired token", .{});
                return;
            },
            authdog.AuthdogError.ApiError => {
                std.log.err("API error: request failed", .{});
                return;
            },
            authdog.AuthdogError.NetworkError => {
                std.log.err("Network error: connection failed", .{});
                return;
            },
            authdog.AuthdogError.ParseError => {
                std.log.err("Parse error: invalid response format", .{});
                return;
            },
            authdog.AuthdogError.InvalidToken => {
                std.log.err("Invalid token provided", .{});
                return;
            },
        }
    };

    // Print user information
    std.log.info("User: {s}", .{user_info.user.display_name});
    std.log.info("ID: {s}", .{user_info.user.id});
    std.log.info("Provider: {s}", .{user_info.user.provider});

    if (user_info.user.emails.items.len > 0) {
        std.log.info("Email: {s}", .{user_info.user.emails.items[0].value});
    }

    if (user_info.user.photos.items.len > 0) {
        std.log.info("Photo: {s}", .{user_info.user.photos.items[0].value});
    }

    // Clean up
    user_info.deinit(allocator);
}
