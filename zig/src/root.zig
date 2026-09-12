const std = @import("std");

pub const version = @import("client.zig").version;
pub const user_agent = @import("client.zig").user_agent;

pub const AuthdogError = @import("error.zig").AuthdogError;
pub const isAuthenticationError = @import("error.zig").isAuthenticationError;
pub const isApiError = @import("error.zig").isApiError;

pub const AuthdogClient = @import("client.zig").AuthdogClient;
pub const AuthdogClientConfig = @import("client.zig").AuthdogClientConfig;

pub const Meta = @import("types.zig").Meta;
pub const Session = @import("types.zig").Session;
pub const Names = @import("types.zig").Names;
pub const Photo = @import("types.zig").Photo;
pub const Email = @import("types.zig").Email;
pub const Verification = @import("types.zig").Verification;
pub const User = @import("types.zig").User;
pub const UserInfoResponse = @import("types.zig").UserInfoResponse;

test {
    std.testing.refAllDecls(@This());
    _ = @import("error.zig");
    _ = @import("types.zig");
    _ = @import("client.zig");
}
