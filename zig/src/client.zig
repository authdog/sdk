const std = @import("std");
const errors = @import("error.zig");
const types = @import("types.zig");

pub const version = "0.1.0";
pub const user_agent = "authdog-zig-sdk/" ++ version;

const AuthdogError = errors.AuthdogError;
const UserInfoResponse = types.UserInfoResponse;

pub const AuthdogClientConfig = struct {
    base_url: []const u8,
    api_key: ?[]const u8 = null,
    timeout_ms: u32 = 10_000,
    /// Optional caller-owned I/O implementation. When omitted, the client
    /// creates and owns a threaded I/O runtime.
    io: ?std.Io = null,
};

pub const AuthdogClient = struct {
    allocator: std.mem.Allocator,
    base_url: []u8,
    api_key: ?[]u8,
    timeout_ms: u32,
    owned_io: ?*std.Io.Threaded,
    io: std.Io,
    last_error_message: ?[]u8,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, config: AuthdogClientConfig) !Self {
        const base_url = try allocator.dupe(u8, config.base_url);
        errdefer allocator.free(base_url);

        const api_key = if (config.api_key) |key| try allocator.dupe(u8, key) else null;
        errdefer if (api_key) |key| allocator.free(key);

        var owned_io: ?*std.Io.Threaded = null;
        const io = config.io orelse blk: {
            const runtime = try allocator.create(std.Io.Threaded);
            runtime.* = .init(allocator, .{});
            owned_io = runtime;
            break :blk runtime.io();
        };

        return .{
            .allocator = allocator,
            .base_url = base_url,
            .api_key = api_key,
            .timeout_ms = config.timeout_ms,
            .owned_io = owned_io,
            .io = io,
            .last_error_message = null,
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.base_url);
        if (self.api_key) |key| self.allocator.free(key);
        if (self.last_error_message) |msg| self.allocator.free(msg);
        if (self.owned_io) |runtime| {
            runtime.deinit();
            self.allocator.destroy(runtime);
        }
        self.* = undefined;
    }

    pub fn lastErrorMessage(self: *const Self) []const u8 {
        return self.last_error_message orelse "";
    }

    pub fn getUserInfo(self: *Self, access_token: []const u8) AuthdogError!UserInfoResponse {
        const trimmed = std.mem.trimEnd(u8, self.base_url, "/");
        const url = std.fmt.allocPrint(self.allocator, "{s}/v1/userinfo", .{trimmed}) catch {
            return self.fail(error.ApiError, errors.request_failed_message);
        };
        defer self.allocator.free(url);

        const authorization = std.fmt.allocPrint(self.allocator, "Bearer {s}", .{access_token}) catch {
            return self.fail(error.ApiError, errors.request_failed_message);
        };
        defer self.allocator.free(authorization);

        var http_client = std.http.Client{
            .allocator = self.allocator,
            .io = self.io,
        };
        defer http_client.deinit();

        var body_writer: std.Io.Writer.Allocating = .init(self.allocator);
        defer body_writer.deinit();

        const fetched = http_client.fetch(.{
            .location = .{ .url = url },
            .method = .GET,
            .headers = .{
                .authorization = .{ .override = authorization },
                .user_agent = .{ .override = user_agent },
                .content_type = .{ .override = "application/json" },
            },
            .response_writer = &body_writer.writer,
        }) catch return self.fail(error.ApiError, errors.request_failed_message);

        const body = body_writer.written();
        const status = @intFromEnum(fetched.status);

        switch (status) {
            200 => return types.parseUserInfo(self.allocator, body) catch {
                return self.fail(error.ParseError, errors.parse_message);
            },
            401 => return self.fail(error.AuthenticationFailed, errors.authentication_message),
            500 => {
                if (types.apiErrorString(self.allocator, body)) |known| {
                    return self.fail(error.ApiError, known);
                }
                return self.failFmt(error.ApiError, "HTTP error 500: {s}", .{body});
            },
            else => return self.failFmt(error.ApiError, "HTTP error {d}: {s}", .{ status, body }),
        }
    }

    fn fail(self: *Self, comptime err: AuthdogError, message: []const u8) AuthdogError {
        if (self.last_error_message) |old| {
            self.allocator.free(old);
            self.last_error_message = null;
        }
        self.last_error_message = self.allocator.dupe(u8, message) catch null;
        return err;
    }

    fn failFmt(self: *Self, comptime err: AuthdogError, comptime fmt: []const u8, args: anytype) AuthdogError {
        if (self.last_error_message) |old| {
            self.allocator.free(old);
            self.last_error_message = null;
        }
        self.last_error_message = std.fmt.allocPrint(self.allocator, fmt, args) catch {
            return self.fail(err, "API request failed");
        };
        return err;
    }
};

const success_payload =
    \\{
    \\  "meta": { "code": 200, "message": "Success" },
    \\  "session": { "remainingSeconds": 3600 },
    \\  "user": {
    \\    "id": "user123",
    \\    "externalId": "ext123",
    \\    "userName": "testuser",
    \\    "displayName": "Test User",
    \\    "nickName": "test",
    \\    "profileUrl": "https://example.com/profile",
    \\    "title": "Developer",
    \\    "userType": "employee",
    \\    "preferredLanguage": "en",
    \\    "locale": "en-US",
    \\    "timezone": "UTC",
    \\    "active": true,
    \\    "names": {
    \\      "id": "name123",
    \\      "formatted": "Test User",
    \\      "familyName": "User",
    \\      "givenName": "Test",
    \\      "middleName": "Middle",
    \\      "honorificPrefix": "Mr.",
    \\      "honorificSuffix": "Jr."
    \\    },
    \\    "photos": [
    \\      { "id": "photo123", "value": "https://example.com/photo.jpg", "type": "profile" }
    \\    ],
    \\    "phoneNumbers": [],
    \\    "addresses": [],
    \\    "emails": [
    \\      { "id": "email123", "value": "test@example.com", "type": "work" }
    \\    ],
    \\    "verifications": [
    \\      {
    \\        "id": "verification123",
    \\        "email": "test@example.com",
    \\        "verified": true,
    \\        "createdAt": "2023-01-01T00:00:00Z",
    \\        "updatedAt": "2023-01-01T00:00:00Z"
    \\      }
    \\    ],
    \\    "provider": "test",
    \\    "createdAt": "2023-01-01T00:00:00Z",
    \\    "updatedAt": "2023-01-01T00:00:00Z",
    \\    "environmentId": "env123"
    \\  }
    \\}
;

const MockHttp = struct {
    allocator: std.mem.Allocator,
    io_impl: *std.Io.Threaded,
    server: std.Io.net.Server,
    port: u16,
    status: std.http.Status,
    body: []const u8,
    expected_authorization: ?[]const u8,
    seen_authorization: ?[]u8 = null,
    thread: std.Thread,

    fn start(
        allocator: std.mem.Allocator,
        status: std.http.Status,
        body: []const u8,
        expected_authorization: ?[]const u8,
    ) !*MockHttp {
        const mock = try allocator.create(MockHttp);
        errdefer allocator.destroy(mock);

        const io_impl = try allocator.create(std.Io.Threaded);
        errdefer allocator.destroy(io_impl);
        io_impl.* = .init(allocator, .{});

        const io = io_impl.io();
        const address = try std.Io.net.IpAddress.parse("127.0.0.1", 0);
        const server = try address.listen(io, .{ .reuse_address = true });

        mock.* = .{
            .allocator = allocator,
            .io_impl = io_impl,
            .server = server,
            .port = server.socket.address.getPort(),
            .status = status,
            .body = body,
            .expected_authorization = expected_authorization,
            .thread = undefined,
        };
        mock.thread = try std.Thread.spawn(.{}, serve, .{mock});
        return mock;
    }

    fn baseUrl(self: *MockHttp) ![]u8 {
        return std.fmt.allocPrint(self.allocator, "http://127.0.0.1:{d}", .{self.port});
    }

    fn deinit(self: *MockHttp) void {
        self.thread.join();
        const io = self.io_impl.io();
        self.server.deinit(io);
        self.io_impl.deinit();
        self.allocator.destroy(self.io_impl);
        if (self.seen_authorization) |value| self.allocator.free(value);
        self.allocator.destroy(self);
    }

    fn serve(self: *MockHttp) void {
        const io = self.io_impl.io();
        const stream = self.server.accept(io) catch return;
        defer stream.close(io);

        var in_buf: [8192]u8 = undefined;
        var out_buf: [1024]u8 = undefined;
        var stream_reader = stream.reader(io, &in_buf);
        var stream_writer = stream.writer(io, &out_buf);
        var http_server = std.http.Server.init(&stream_reader.interface, &stream_writer.interface);
        var request = http_server.receiveHead() catch return;

        var headers = request.iterateHeaders();
        while (headers.next()) |header| {
            if (std.ascii.eqlIgnoreCase(header.name, "authorization")) {
                self.seen_authorization = self.allocator.dupe(u8, header.value) catch null;
            }
        }

        request.respond(self.body, .{
            .status = self.status,
            .keep_alive = false,
        }) catch return;
    }
};

fn expectClient(
    allocator: std.mem.Allocator,
    base_url: []const u8,
    api_key: ?[]const u8,
) !AuthdogClient {
    return AuthdogClient.init(allocator, .{
        .base_url = base_url,
        .api_key = api_key,
    });
}

test "client constructor defaults timeout to 10 seconds" {
    var client = try AuthdogClient.init(std.testing.allocator, .{
        .base_url = "https://api.authdog.com/",
    });
    defer client.deinit();

    try std.testing.expectEqualStrings("https://api.authdog.com/", client.base_url);
    try std.testing.expectEqual(@as(?[]u8, null), client.api_key);
    try std.testing.expectEqual(@as(u32, 10_000), client.timeout_ms);
}

test "client constructor stores api key and timeout" {
    var client = try AuthdogClient.init(std.testing.allocator, .{
        .base_url = "https://api.authdog.com",
        .api_key = "test-api-key",
        .timeout_ms = 30_000,
    });
    defer client.deinit();

    try std.testing.expectEqualStrings("test-api-key", client.api_key.?);
    try std.testing.expectEqual(@as(u32, 30_000), client.timeout_ms);
}

test "get user info success and trailing slash" {
    const mock = try MockHttp.start(std.testing.allocator, .ok, success_payload, "Bearer valid-token");
    defer mock.deinit();

    const base_url = try mock.baseUrl();
    defer std.testing.allocator.free(base_url);

    const slashed = try std.fmt.allocPrint(std.testing.allocator, "{s}/", .{base_url});
    defer std.testing.allocator.free(slashed);

    var client = try expectClient(std.testing.allocator, slashed, null);
    defer client.deinit();

    const user_info = try client.getUserInfo("valid-token");
    defer user_info.deinit();

    try std.testing.expectEqualStrings("user123", user_info.user.id);
    try std.testing.expectEqualStrings("testuser", user_info.user.user_name);
    try std.testing.expectEqualStrings("Test User", user_info.user.display_name);
    try std.testing.expectEqual(@as(i64, 200), user_info.meta.code);
    try std.testing.expectEqual(@as(i32, 3600), user_info.session.remaining_seconds);
    try std.testing.expectEqualStrings("Bearer valid-token", mock.seen_authorization.?);
}

test "access token wins over constructor api key" {
    const mock = try MockHttp.start(std.testing.allocator, .ok, success_payload, "Bearer access-token");
    defer mock.deinit();

    const base_url = try mock.baseUrl();
    defer std.testing.allocator.free(base_url);

    var client = try expectClient(std.testing.allocator, base_url, "test-api-key");
    defer client.deinit();

    const user_info = try client.getUserInfo("access-token");
    defer user_info.deinit();

    try std.testing.expectEqualStrings("Bearer access-token", mock.seen_authorization.?);
}

test "401 maps to authentication error" {
    const mock = try MockHttp.start(std.testing.allocator, .unauthorized, "Unauthorized", null);
    defer mock.deinit();

    const base_url = try mock.baseUrl();
    defer std.testing.allocator.free(base_url);

    var client = try expectClient(std.testing.allocator, base_url, null);
    defer client.deinit();

    try std.testing.expectError(error.AuthenticationFailed, client.getUserInfo("invalid-token"));
    try std.testing.expect(errors.isAuthenticationError(error.AuthenticationFailed));
    try std.testing.expect(!errors.isApiError(error.AuthenticationFailed));
    try std.testing.expectEqualStrings(errors.authentication_message, client.lastErrorMessage());
}

test "500 graphql maps to api error" {
    const mock = try MockHttp.start(
        std.testing.allocator,
        .internal_server_error,
        "{\"error\":\"GraphQL query failed\"}",
        null,
    );
    defer mock.deinit();

    const base_url = try mock.baseUrl();
    defer std.testing.allocator.free(base_url);

    var client = try expectClient(std.testing.allocator, base_url, null);
    defer client.deinit();

    try std.testing.expectError(error.ApiError, client.getUserInfo("token"));
    try std.testing.expect(errors.isApiError(error.ApiError));
    try std.testing.expectEqualStrings(errors.graphql_message, client.lastErrorMessage());
}

test "500 fetch user info maps to api error" {
    const mock = try MockHttp.start(
        std.testing.allocator,
        .internal_server_error,
        "{\"error\":\"Failed to fetch user info\"}",
        null,
    );
    defer mock.deinit();

    const base_url = try mock.baseUrl();
    defer std.testing.allocator.free(base_url);

    var client = try expectClient(std.testing.allocator, base_url, null);
    defer client.deinit();

    try std.testing.expectError(error.ApiError, client.getUserInfo("token"));
    try std.testing.expectEqualStrings(errors.fetch_user_info_message, client.lastErrorMessage());
}

test "other http status maps to api error with status code" {
    const mock = try MockHttp.start(std.testing.allocator, .not_found, "Not Found", null);
    defer mock.deinit();

    const base_url = try mock.baseUrl();
    defer std.testing.allocator.free(base_url);

    var client = try expectClient(std.testing.allocator, base_url, null);
    defer client.deinit();

    try std.testing.expectError(error.ApiError, client.getUserInfo("token"));
    try std.testing.expect(std.mem.indexOf(u8, client.lastErrorMessage(), "HTTP error 404") != null);
}

test "invalid json on 200 is a parse error" {
    const mock = try MockHttp.start(std.testing.allocator, .ok, "invalid json", null);
    defer mock.deinit();

    const base_url = try mock.baseUrl();
    defer std.testing.allocator.free(base_url);

    var client = try expectClient(std.testing.allocator, base_url, null);
    defer client.deinit();

    try std.testing.expectError(error.ParseError, client.getUserInfo("token"));
    try std.testing.expectEqualStrings(errors.parse_message, client.lastErrorMessage());
}

test "transport failure maps to api error" {
    var client = try expectClient(std.testing.allocator, "http://127.0.0.1:1", null);
    defer client.deinit();

    try std.testing.expectError(error.ApiError, client.getUserInfo("token"));
    try std.testing.expect(errors.isApiError(error.ApiError));
    try std.testing.expectEqualStrings(errors.request_failed_message, client.lastErrorMessage());
}
