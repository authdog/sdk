# Authdog Zig SDK

Official Zig SDK for Authdog authentication and user management.

## Installation

Add this to your `build.zig.zon`:

```zig
.dependencies = .{
    .authdog = .{
        .url = "https://github.com/authdog/sdk/archive/refs/heads/main.tar.gz",
        .hash = "YOUR_PACKAGE_HASH",
    },
},
```

Then in your `build.zig`:

```zig
const authdog_dep = b.dependency("authdog", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("authdog", authdog_dep.module("authdog"));
```

Requires Zig 0.16.0 or later. The SDK uses only the Zig standard library.

## Usage

```zig
const std = @import("std");
const authdog = @import("authdog");

pub fn main() !void {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    defer _ = debug_allocator.deinit();

    var client = try authdog.AuthdogClient.init(debug_allocator.allocator(), .{
        .base_url = "https://api.authdog.com",
        .api_key = null, // optional; not sent on getUserInfo
        .timeout_ms = 10_000, // optional, default 10 seconds
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
    if (user_info.user.emails.len > 0) {
        std.log.info("Email: {s}", .{user_info.user.emails[0].value});
    }
}
```

`GET /v1/userinfo` always sends `Authorization: Bearer <access-token>`. A constructor API key does not replace that header.

`health()` plus `organizations`, `tenants`, `projects`, `environments`,
`users`, `groups`, `rbac`, `audit`, `events`, `webhooks`,
`notificationChannels`, `serviceAccounts`, `personalAccessTokens`,
and `apiSecrets` wrap Waves 1–2 of the public API. Management calls
send the constructor API key when present. See `specs/004-api-parity/`.

## Errors

| Error | When |
|-------|------|
| `AuthenticationFailed` | HTTP 401 — `Unauthorized - invalid or expired token` |
| `ApiError` | Other HTTP failures and transport errors |
| `ParseError` | HTTP 200 with a body that is not valid user-info JSON |

Use `isAuthenticationError` / `isApiError` to branch on type. Use `client.lastErrorMessage()` for the stable message text.

## Development

```bash
zig build test
zig build
zig build example
zig fmt --check src/ examples/
```

Or from the repo root: `moon run zig:test`.
