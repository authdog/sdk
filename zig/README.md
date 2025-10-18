# Authdog Zig SDK

Official Zig SDK for Authdog authentication and user management platform.

## Features

- **User Information Retrieval**: Get detailed user information using access tokens
- **Comprehensive Type System**: Full support for all Authdog data types
- **Error Handling**: Robust error handling with specific error types
- **Memory Safe**: Leverages Zig's memory safety features
- **Zero Dependencies**: Minimal external dependencies

## Installation

### Using Zig Package Manager

Add this to your `build.zig.zon`:

```zig
.dependencies = .{
    .authdog = .{
        .url = "https://github.com/authdog/sdk/archive/main.tar.gz",
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

### Manual Installation

1. Clone this repository
2. Copy the `src/` directory to your project
3. Add the dependencies to your `build.zig.zon`:

```zig
.dependencies = .{
    .@"ziggy-http" = .{
        .url = "https://github.com/karlseguin/ziggy-http/archive/refs/heads/main.tar.gz",
        .hash = "12200000000000000000000000000000000000000000000000000000000000000000",
    },
    .json = .{
        .url = "https://github.com/karlseguin/json.zig/archive/refs/heads/main.tar.gz",
        .hash = "12200000000000000000000000000000000000000000000000000000000000000000",
    },
},
```

## Quick Start

```zig
const std = @import("std");
const authdog = @import("authdog");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Initialize the client
    var client = try authdog.AuthdogClient.init(
        allocator, 
        "https://api.authdog.com", 
        null, // API key (optional)
        10000 // timeout in milliseconds
    );
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
    defer user_info.deinit(allocator);

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
}
```

## API Reference

### AuthdogClient

The main client for interacting with the Authdog API.

#### `init(allocator, base_url, api_key, timeout_ms)`

Initialize a new Authdog client.

- `allocator`: Memory allocator to use
- `base_url`: Base URL for the Authdog API (e.g., "https://api.authdog.com")
- `api_key`: Optional API key for authentication
- `timeout_ms`: Request timeout in milliseconds

Returns: `AuthdogClient` or error

#### `deinit()`

Clean up the client and free allocated memory.

#### `getUserInfo(access_token)`

Retrieve user information using an access token.

- `access_token`: The user's access token

Returns: `UserInfoResponse` or error

### Error Types

The SDK defines the following error types:

- `AuthenticationFailed`: Invalid or expired token
- `ApiError`: API request failed
- `NetworkError`: Network connection failed
- `ParseError`: Invalid response format
- `InvalidToken`: Invalid token provided

### Data Types

#### UserInfoResponse

Contains the complete user information response:

```zig
pub const UserInfoResponse = struct {
    meta: Meta,
    session: Session,
    user: User,
    
    pub fn deinit(self: *UserInfoResponse, allocator: std.mem.Allocator) void;
};
```

#### User

Represents a user with all their information:

```zig
pub const User = struct {
    id: []const u8,
    external_id: []const u8,
    user_name: []const u8,
    display_name: []const u8,
    nick_name: ?[]const u8,
    profile_url: ?[]const u8,
    title: ?[]const u8,
    user_type: ?[]const u8,
    preferred_language: ?[]const u8,
    locale: []const u8,
    timezone: ?[]const u8,
    active: bool,
    names: Names,
    photos: std.ArrayList(Photo),
    emails: std.ArrayList(Email),
    verifications: std.ArrayList(Verification),
    provider: []const u8,
    created_at: []const u8,
    updated_at: []const u8,
    environment_id: []const u8,
    
    pub fn deinit(self: *User, allocator: std.mem.Allocator) void;
};
```

#### Other Types

- `Meta`: Response metadata (code, message)
- `Session`: Session information (remaining seconds)
- `Names`: User name information
- `Photo`: User photo(s)
- `Email`: User email(s)
- `Verification`: Email verification status

## Testing

### Running Tests

```bash
# Run all tests
zig build test

# Run tests with verbose output
zig build test --summary all

# Run tests for specific functionality
zig test src/test.zig
```

### Test Coverage

The test suite covers:

- ✅ Client initialization and cleanup
- ✅ JSON parsing for all data types
- ✅ Error handling scenarios
- ✅ Memory management
- ✅ Optional field handling
- ✅ Array parsing (photos, emails, verifications)
- ✅ Nested object parsing

### Writing Tests

Tests are located in `src/test.zig`. Each test function should:

1. Use `std.testing.expect*` functions for assertions
2. Properly clean up allocated memory
3. Handle errors appropriately
4. Test both success and failure cases

Example test:

```zig
test "example test" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Test setup
    var client = try authdog.AuthdogClient.init(allocator, "https://api.authdog.com", null, 5000);
    defer client.deinit();

    // Test assertions
    try std.testing.expectEqualStrings("https://api.authdog.com", client.base_url);
    try std.testing.expectEqual(@as(u32, 5000), client.timeout_ms);
}
```

## Building

### Build Commands

```bash
# Build the library
zig build

# Build and run tests
zig build test

# Build the example
zig build-exe examples/main.zig -I src --main-pkg-path src

# Generate documentation
zig build docs

# Build with specific optimization
zig build -Doptimize=ReleaseFast
```

### Build Configuration

The build system supports:

- **Debug builds**: Default, includes debug information
- **Release builds**: Optimized for performance (`-Doptimize=ReleaseFast`)
- **ReleaseSmall**: Optimized for size (`-Doptimize=ReleaseSmall`)
- **ReleaseSafe**: Optimized with safety checks (`-Doptimize=ReleaseSafe`)

## Dependencies

- **ziggy-http**: HTTP client library
- **json.zig**: JSON parsing library

## Requirements

- Zig 0.11.0 or later
- Internet connection for API calls

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

### Development Setup

```bash
# Clone the repository
git clone https://github.com/authdog/sdk.git
cd sdk/zig

# Install dependencies
zig build deps

# Run tests
zig build test

# Build example
zig build-exe examples/main.zig -I src --main-pkg-path src
```

## License

MIT License - see LICENSE file for details.

## Support

For issues and questions:

- GitHub Issues: [Create an issue](https://github.com/authdog/sdk/issues)
- Documentation: [Authdog Documentation](https://docs.authdog.com)
- Community: [Authdog Community](https://community.authdog.com)
