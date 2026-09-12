const std = @import("std");

pub const Meta = struct {
    code: i64,
    message: []const u8,
};

pub const Session = struct {
    remaining_seconds: i32,
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
    photo_type: []const u8,
};

pub const Email = struct {
    id: []const u8,
    value: []const u8,
    email_type: ?[]const u8,
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
    photos: []const Photo,
    phone_numbers: []const std.json.Value,
    addresses: []const std.json.Value,
    emails: []const Email,
    verifications: []const Verification,
    provider: []const u8,
    created_at: []const u8,
    updated_at: []const u8,
    environment_id: []const u8,
};

pub const UserInfoResponse = struct {
    meta: Meta,
    session: Session,
    user: User,
    arena: *std.heap.ArenaAllocator,

    pub fn deinit(self: UserInfoResponse) void {
        const child = self.arena.child_allocator;
        self.arena.deinit();
        child.destroy(self.arena);
    }
};

const WireMeta = struct {
    code: i64,
    message: []const u8,
};

const WireSession = struct {
    remainingSeconds: i64,
};

const WireNames = struct {
    id: []const u8,
    formatted: ?[]const u8 = null,
    familyName: []const u8,
    givenName: []const u8,
    middleName: ?[]const u8 = null,
    honorificPrefix: ?[]const u8 = null,
    honorificSuffix: ?[]const u8 = null,
};

const WirePhoto = struct {
    id: []const u8,
    value: []const u8,
    type: []const u8,
};

const WireEmail = struct {
    id: []const u8,
    value: []const u8,
    type: ?[]const u8 = null,
};

const WireVerification = struct {
    id: []const u8,
    email: []const u8,
    verified: bool,
    createdAt: []const u8,
    updatedAt: []const u8,
};

const WireUser = struct {
    id: []const u8,
    externalId: []const u8,
    userName: []const u8,
    displayName: []const u8,
    nickName: ?[]const u8 = null,
    profileUrl: ?[]const u8 = null,
    title: ?[]const u8 = null,
    userType: ?[]const u8 = null,
    preferredLanguage: ?[]const u8 = null,
    locale: []const u8,
    timezone: ?[]const u8 = null,
    active: bool,
    names: WireNames,
    photos: []const WirePhoto = &.{},
    phoneNumbers: []const std.json.Value = &.{},
    addresses: []const std.json.Value = &.{},
    emails: []const WireEmail = &.{},
    verifications: []const WireVerification = &.{},
    provider: []const u8,
    createdAt: []const u8,
    updatedAt: []const u8,
    environmentId: []const u8,
};

const WireResponse = struct {
    meta: WireMeta,
    session: WireSession,
    user: WireUser,
};

const WireError = struct {
    @"error": []const u8,
};

pub fn apiErrorString(allocator: std.mem.Allocator, json_str: []const u8) ?[]const u8 {
    const parsed = std.json.parseFromSlice(WireError, allocator, json_str, .{
        .ignore_unknown_fields = true,
    }) catch return null;
    defer parsed.deinit();
    if (std.mem.eql(u8, parsed.value.@"error", "GraphQL query failed")) {
        return "GraphQL query failed";
    }
    if (std.mem.eql(u8, parsed.value.@"error", "Failed to fetch user info")) {
        return "Failed to fetch user info";
    }
    return null;
}

pub fn parseUserInfo(allocator: std.mem.Allocator, json_str: []const u8) !UserInfoResponse {
    const parsed = std.json.parseFromSlice(WireResponse, allocator, json_str, .{
        .ignore_unknown_fields = true,
        .allocate = .alloc_always,
    }) catch return error.ParseError;
    errdefer parsed.deinit();

    const arena = parsed.arena;
    const a = arena.allocator();
    const wire = parsed.value;

    const photos = try a.alloc(Photo, wire.user.photos.len);
    for (wire.user.photos, photos) |src, *dst| {
        dst.* = .{
            .id = src.id,
            .value = src.value,
            .photo_type = src.type,
        };
    }

    const emails = try a.alloc(Email, wire.user.emails.len);
    for (wire.user.emails, emails) |src, *dst| {
        dst.* = .{
            .id = src.id,
            .value = src.value,
            .email_type = src.type,
        };
    }

    const verifications = try a.alloc(Verification, wire.user.verifications.len);
    for (wire.user.verifications, verifications) |src, *dst| {
        dst.* = .{
            .id = src.id,
            .email = src.email,
            .verified = src.verified,
            .created_at = src.createdAt,
            .updated_at = src.updatedAt,
        };
    }

    return .{
        .meta = .{
            .code = wire.meta.code,
            .message = wire.meta.message,
        },
        .session = .{
            .remaining_seconds = std.math.cast(i32, wire.session.remainingSeconds) orelse return error.ParseError,
        },
        .user = .{
            .id = wire.user.id,
            .external_id = wire.user.externalId,
            .user_name = wire.user.userName,
            .display_name = wire.user.displayName,
            .nick_name = wire.user.nickName,
            .profile_url = wire.user.profileUrl,
            .title = wire.user.title,
            .user_type = wire.user.userType,
            .preferred_language = wire.user.preferredLanguage,
            .locale = wire.user.locale,
            .timezone = wire.user.timezone,
            .active = wire.user.active,
            .names = .{
                .id = wire.user.names.id,
                .formatted = wire.user.names.formatted,
                .family_name = wire.user.names.familyName,
                .given_name = wire.user.names.givenName,
                .middle_name = wire.user.names.middleName,
                .honorific_prefix = wire.user.names.honorificPrefix,
                .honorific_suffix = wire.user.names.honorificSuffix,
            },
            .photos = photos,
            .phone_numbers = wire.user.phoneNumbers,
            .addresses = wire.user.addresses,
            .emails = emails,
            .verifications = verifications,
            .provider = wire.user.provider,
            .created_at = wire.user.createdAt,
            .updated_at = wire.user.updatedAt,
            .environment_id = wire.user.environmentId,
        },
        .arena = arena,
    };
}

test "parse user info sample payload" {
    const json =
        \\{
        \\  "meta": { "code": 200, "message": "Success" },
        \\  "session": { "remainingSeconds": 3600 },
        \\  "user": {
        \\    "id": "user123",
        \\    "externalId": "ext123",
        \\    "userName": "testuser",
        \\    "displayName": "Test User",
        \\    "nickName": null,
        \\    "profileUrl": null,
        \\    "title": null,
        \\    "userType": null,
        \\    "preferredLanguage": null,
        \\    "locale": "en-US",
        \\    "timezone": null,
        \\    "active": true,
        \\    "names": {
        \\      "id": "name123",
        \\      "formatted": null,
        \\      "familyName": "User",
        \\      "givenName": "Test",
        \\      "middleName": null,
        \\      "honorificPrefix": null,
        \\      "honorificSuffix": null
        \\    },
        \\    "photos": [],
        \\    "phoneNumbers": [],
        \\    "addresses": [],
        \\    "emails": [
        \\      { "id": "email123", "value": "test@example.com", "type": null }
        \\    ],
        \\    "verifications": [],
        \\    "provider": "test",
        \\    "createdAt": "2023-01-01T00:00:00Z",
        \\    "updatedAt": "2023-01-01T00:00:00Z",
        \\    "environmentId": "env123",
        \\    "unknownFutureField": true
        \\  }
        \\}
    ;

    const response = try parseUserInfo(std.testing.allocator, json);
    defer response.deinit();

    try std.testing.expectEqual(@as(i64, 200), response.meta.code);
    try std.testing.expectEqualStrings("Success", response.meta.message);
    try std.testing.expectEqual(@as(i32, 3600), response.session.remaining_seconds);
    try std.testing.expectEqualStrings("user123", response.user.id);
    try std.testing.expectEqualStrings("Test User", response.user.display_name);
    try std.testing.expectEqual(@as(?[]const u8, null), response.user.nick_name);
    try std.testing.expectEqual(@as(usize, 0), response.user.photos.len);
    try std.testing.expectEqual(@as(usize, 1), response.user.emails.len);
    try std.testing.expectEqualStrings("test@example.com", response.user.emails[0].value);
    try std.testing.expectEqual(@as(?[]const u8, null), response.user.emails[0].email_type);
}

test "invalid json is a parse error" {
    try std.testing.expectError(error.ParseError, parseUserInfo(std.testing.allocator, "not-json"));
}
