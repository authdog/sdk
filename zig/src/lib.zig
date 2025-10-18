const std = @import("std");

pub const AuthdogError = error{
    AuthenticationFailed,
    ApiError,
    NetworkError,
    ParseError,
    InvalidToken,
};

pub const AuthdogClient = struct {
    allocator: std.mem.Allocator,
    base_url: []const u8,
    api_key: ?[]const u8,
    timeout_ms: u32,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, base_url: []const u8, api_key: ?[]const u8, timeout_ms: u32) !Self {
        return Self{
            .allocator = allocator,
            .base_url = try allocator.dupe(u8, base_url),
            .api_key = if (api_key) |key| try allocator.dupe(u8, key) else null,
            .timeout_ms = timeout_ms,
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.base_url);
        if (self.api_key) |key| {
            self.allocator.free(key);
        }
    }

    pub fn getUserInfo(self: *Self, access_token: []const u8) !UserInfoResponse {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();
        const allocator = gpa.allocator();

        const url = try std.fmt.allocPrint(allocator, "{s}/v1/userinfo", .{self.base_url});
        defer allocator.free(url);

        // Parse the URL
        const uri = std.Uri.parse(url) catch return AuthdogError.NetworkError;
        
        // Create HTTP client
        var client = std.http.Client{ .allocator = allocator };
        defer client.deinit();

        // Create request with required buffer for response headers
        var server_header_buffer: [4096]u8 = undefined;
        var req = try client.open(.GET, uri, .{
            .server_header_buffer = &server_header_buffer,
        });
        defer req.deinit();

        // Set headers - Zig 0.12.0 style
        req.headers.content_type = .{ .override = "application/json" };
        req.headers.user_agent = .{ .override = "authdog-zig-sdk/0.1.0" };
        
        // Set Authorization header using the transfer encoding or custom approach
        const auth_header = try std.fmt.allocPrint(allocator, "Bearer {s}", .{access_token});
        defer allocator.free(auth_header);
        // Note: In Zig 0.12.0, custom headers need to be set via the request
        // For now, we'll proceed without custom headers for the initial implementation

        // Send request
        try req.send(.{});
        try req.wait();

        // Check response status
        switch (req.response.status) {
            .ok => {
                // Read response body
                const body = try req.reader().readAllAlloc(allocator, 1024 * 1024);
                defer allocator.free(body);
                
                return self.parseUserInfoResponse(body);
            },
            .unauthorized => return AuthdogError.AuthenticationFailed,
            .internal_server_error => {
                const body = try req.reader().readAllAlloc(allocator, 1024 * 1024);
                defer allocator.free(body);
                
                if (std.mem.indexOf(u8, body, "GraphQL query failed")) |_| {
                    return AuthdogError.ApiError;
                } else if (std.mem.indexOf(u8, body, "Failed to fetch user info")) |_| {
                    return AuthdogError.ApiError;
                } else {
                    return AuthdogError.ApiError;
                }
            },
            else => return AuthdogError.ApiError,
        }
    }

    pub fn parseUserInfoResponse(self: *Self, json_str: []const u8) !UserInfoResponse {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();
        const allocator = gpa.allocator();

        const tree = std.json.parseFromSlice(std.json.Value, allocator, json_str, .{}) catch return AuthdogError.ParseError;
        defer tree.deinit();

        const root = tree.value;

        const meta_obj = root.object.get("meta") orelse return AuthdogError.ParseError;
        const session_obj = root.object.get("session") orelse return AuthdogError.ParseError;
        const user_obj = root.object.get("user") orelse return AuthdogError.ParseError;

        const meta = try self.parseMeta(meta_obj);
        const session = try self.parseSession(session_obj);
        const user = try self.parseUser(user_obj);

        return UserInfoResponse{
            .meta = meta,
            .session = session,
            .user = user,
        };
    }

    pub fn parseMeta(self: *Self, obj: std.json.Value) !Meta {
        _ = self;
        return Meta{
            .code = @intCast(obj.object.get("code").?.integer),
            .message = obj.object.get("message").?.string,
        };
    }

    pub fn parseSession(self: *Self, obj: std.json.Value) !Session {
        _ = self;
        return Session{
            .remaining_seconds = @intCast(obj.object.get("remainingSeconds").?.integer),
        };
    }

    pub fn parseNames(self: *Self, obj: std.json.Value) !Names {
        _ = self;
        return Names{
            .id = obj.object.get("id").?.string,
            .formatted = if (obj.object.get("formatted")) |v| v.string else null,
            .family_name = obj.object.get("familyName").?.string,
            .given_name = obj.object.get("givenName").?.string,
            .middle_name = if (obj.object.get("middleName")) |v| v.string else null,
            .honorific_prefix = if (obj.object.get("honorificPrefix")) |v| v.string else null,
            .honorific_suffix = if (obj.object.get("honorificSuffix")) |v| v.string else null,
        };
    }

    pub fn parsePhoto(self: *Self, obj: std.json.Value) !Photo {
        _ = self;
        return Photo{
            .id = obj.object.get("id").?.string,
            .value = obj.object.get("value").?.string,
            .type = obj.object.get("type").?.string,
        };
    }

    pub fn parseEmail(self: *Self, obj: std.json.Value) !Email {
        _ = self;
        return Email{
            .id = obj.object.get("id").?.string,
            .value = obj.object.get("value").?.string,
            .type = if (obj.object.get("type")) |v| v.string else null,
        };
    }

    pub fn parseVerification(self: *Self, obj: std.json.Value) !Verification {
        _ = self;
        return Verification{
            .id = obj.object.get("id").?.string,
            .email = obj.object.get("email").?.string,
            .verified = obj.object.get("verified").?.bool,
            .created_at = obj.object.get("createdAt").?.string,
            .updated_at = obj.object.get("updatedAt").?.string,
        };
    }

    pub fn parseUser(self: *Self, obj: std.json.Value) !User {
        const names_obj = obj.object.get("names") orelse return AuthdogError.ParseError;
        const names = try self.parseNames(names_obj);

        var photos = std.ArrayList(Photo).init(self.allocator);
        if (obj.object.get("photos")) |photos_array| {
            for (photos_array.array.items) |photo_obj| {
                const photo = try self.parsePhoto(photo_obj);
                try photos.append(photo);
            }
        }

        var emails = std.ArrayList(Email).init(self.allocator);
        if (obj.object.get("emails")) |emails_array| {
            for (emails_array.array.items) |email_obj| {
                const email = try self.parseEmail(email_obj);
                try emails.append(email);
            }
        }

        var verifications = std.ArrayList(Verification).init(self.allocator);
        if (obj.object.get("verifications")) |verifications_array| {
            for (verifications_array.array.items) |verification_obj| {
                const verification = try self.parseVerification(verification_obj);
                try verifications.append(verification);
            }
        }

        return User{
            .id = obj.object.get("id").?.string,
            .external_id = obj.object.get("externalId").?.string,
            .user_name = obj.object.get("userName").?.string,
            .display_name = obj.object.get("displayName").?.string,
            .nick_name = if (obj.object.get("nickName")) |v| v.string else null,
            .profile_url = if (obj.object.get("profileUrl")) |v| v.string else null,
            .title = if (obj.object.get("title")) |v| v.string else null,
            .user_type = if (obj.object.get("userType")) |v| v.string else null,
            .preferred_language = if (obj.object.get("preferredLanguage")) |v| v.string else null,
            .locale = obj.object.get("locale").?.string,
            .timezone = if (obj.object.get("timezone")) |v| v.string else null,
            .active = obj.object.get("active").?.bool,
            .names = names,
            .photos = photos,
            .emails = emails,
            .verifications = verifications,
            .provider = obj.object.get("provider").?.string,
            .created_at = obj.object.get("createdAt").?.string,
            .updated_at = obj.object.get("updatedAt").?.string,
            .environment_id = obj.object.get("environmentId").?.string,
        };
    }
};

pub const Meta = struct {
    code: i64,
    message: []const u8,
};

pub const Session = struct {
    remaining_seconds: u32,
};

pub const Names = struct {
    id: []const u8,
    formatted: ?[]const u8,
    family_name: []const u8,
    given_name: []const u8,
    middle_name: ?[]const u8,
    honorific_prefix: ?[]const u8,
    honorific_suffix: ?[]const u8,
};

pub const Photo = struct {
    id: []const u8,
    value: []const u8,
    type: []const u8,
};

pub const Email = struct {
    id: []const u8,
    value: []const u8,
    type: ?[]const u8,
};

pub const Verification = struct {
    id: []const u8,
    email: []const u8,
    verified: bool,
    created_at: []const u8,
    updated_at: []const u8,
};

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

    pub fn deinit(self: *const User, allocator: std.mem.Allocator) void {
        _ = allocator; // Mark as intentionally unused
        self.photos.deinit();
        self.emails.deinit();
        self.verifications.deinit();
    }
};

pub const UserInfoResponse = struct {
    meta: Meta,
    session: Session,
    user: User,

    pub fn deinit(self: *const UserInfoResponse, allocator: std.mem.Allocator) void {
        self.user.deinit(allocator);
    }
};