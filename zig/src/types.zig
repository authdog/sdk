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

pub const Probe = struct {
    ok: bool = false,
};

pub const Organization = struct {
    id: []const u8,
    name: []const u8,
    description: ?[]const u8,
    billing_email: ?[]const u8,
    logo_uri: ?[]const u8,
    active: bool,
    created_at: []const u8,
    updated_at: []const u8,
};

pub const OrganizationsList = struct {
    organizations: []const Organization,
    total: i64,
    arena: *std.heap.ArenaAllocator,

    pub fn deinit(self: OrganizationsList) void {
        const child = self.arena.child_allocator;
        self.arena.deinit();
        child.destroy(self.arena);
    }
};

pub const Tenant = struct {
    id: []const u8,
    name: []const u8,
    description: ?[]const u8,
    company: ?[]const u8,
    active: bool,
    created_at: []const u8,
    updated_at: []const u8,
    organization_ids: []const []const u8,
};

pub const TenantsList = struct {
    tenants: []const Tenant,
    total: i64,
    arena: *std.heap.ArenaAllocator,

    pub fn deinit(self: TenantsList) void {
        const child = self.arena.child_allocator;
        self.arena.deinit();
        child.destroy(self.arena);
    }
};

pub const EnvUserEmail = struct {
    id: []const u8,
    value: []const u8,
    email_type: ?[]const u8,
};

pub const EnvUser = struct {
    id: []const u8,
    environment_id: ?[]const u8,
    external_id: ?[]const u8,
    user_name: ?[]const u8,
    display_name: ?[]const u8,
    nick_name: ?[]const u8,
    profile_url: ?[]const u8,
    active: ?bool,
    change_pw: ?bool,
    provider: ?[]const u8,
    emails: []const EnvUserEmail,
    last_login: ?[]const u8,
    created_at: ?[]const u8,
    updated_at: ?[]const u8,
};

pub const EnvUsersResponse = struct {
    users: []const EnvUser,
    arena: *std.heap.ArenaAllocator,

    pub fn deinit(self: EnvUsersResponse) void {
        const child = self.arena.child_allocator;
        self.arena.deinit();
        child.destroy(self.arena);
    }
};

pub const EnvGroup = struct {
    id: []const u8,
    environment_id: []const u8,
    name: []const u8,
    slug: []const u8,
    description: ?[]const u8,
    member_count: i64,
    joined_at: ?[]const u8,
    created_at: []const u8,
    updated_at: []const u8,
};

pub const EnvGroupsResponse = struct {
    groups: []const EnvGroup,
    arena: *std.heap.ArenaAllocator,

    pub fn deinit(self: EnvGroupsResponse) void {
        const child = self.arena.child_allocator;
        self.arena.deinit();
        child.destroy(self.arena);
    }
};

const WireOrganization = struct {
    id: []const u8 = "",
    name: []const u8 = "",
    description: ?[]const u8 = null,
    billingEmail: ?[]const u8 = null,
    logoUri: ?[]const u8 = null,
    active: bool = false,
    createdAt: []const u8 = "",
    updatedAt: []const u8 = "",
};

const WireOrganizationsList = struct {
    organizations: []const WireOrganization = &.{},
    total: i64 = 0,
};

const WireTenant = struct {
    id: []const u8 = "",
    name: []const u8 = "",
    description: ?[]const u8 = null,
    company: ?[]const u8 = null,
    active: bool = false,
    createdAt: []const u8 = "",
    updatedAt: []const u8 = "",
    organizationIds: []const []const u8 = &.{},
};

const WireTenantsList = struct {
    tenants: []const WireTenant = &.{},
    total: i64 = 0,
};

const WireEnvUserEmail = struct {
    id: []const u8 = "",
    value: []const u8 = "",
    type: ?[]const u8 = null,
};

const WireEnvUser = struct {
    id: []const u8 = "",
    environmentId: ?[]const u8 = null,
    externalId: ?[]const u8 = null,
    userName: ?[]const u8 = null,
    displayName: ?[]const u8 = null,
    nickName: ?[]const u8 = null,
    profileUrl: ?[]const u8 = null,
    active: ?bool = null,
    changePw: ?bool = null,
    provider: ?[]const u8 = null,
    emails: []const WireEnvUserEmail = &.{},
    lastLogin: ?[]const u8 = null,
    createdAt: ?[]const u8 = null,
    updatedAt: ?[]const u8 = null,
};

const WireEnvUsersResponse = struct {
    users: []const WireEnvUser = &.{},
};

const WireEnvGroup = struct {
    id: []const u8 = "",
    environmentId: []const u8 = "",
    name: []const u8 = "",
    slug: []const u8 = "",
    description: ?[]const u8 = null,
    memberCount: i64 = 0,
    joinedAt: ?[]const u8 = null,
    createdAt: []const u8 = "",
    updatedAt: []const u8 = "",
};

const WireEnvGroupsResponse = struct {
    groups: []const WireEnvGroup = &.{},
};

const WireErrorField = struct {
    @"error": ?[]const u8 = null,
};

fn organizationFromWire(src: WireOrganization) Organization {
    return .{
        .id = src.id,
        .name = src.name,
        .description = src.description,
        .billing_email = src.billingEmail,
        .logo_uri = src.logoUri,
        .active = src.active,
        .created_at = src.createdAt,
        .updated_at = src.updatedAt,
    };
}

fn tenantFromWire(src: WireTenant) Tenant {
    return .{
        .id = src.id,
        .name = src.name,
        .description = src.description,
        .company = src.company,
        .active = src.active,
        .created_at = src.createdAt,
        .updated_at = src.updatedAt,
        .organization_ids = src.organizationIds,
    };
}

fn envUserFromWire(allocator: std.mem.Allocator, src: WireEnvUser) !EnvUser {
    const emails = try allocator.alloc(EnvUserEmail, src.emails.len);
    for (src.emails, emails) |item, *dst| {
        dst.* = .{
            .id = item.id,
            .value = item.value,
            .email_type = item.type,
        };
    }
    return .{
        .id = src.id,
        .environment_id = src.environmentId,
        .external_id = src.externalId,
        .user_name = src.userName,
        .display_name = src.displayName,
        .nick_name = src.nickName,
        .profile_url = src.profileUrl,
        .active = src.active,
        .change_pw = src.changePw,
        .provider = src.provider,
        .emails = emails,
        .last_login = src.lastLogin,
        .created_at = src.createdAt,
        .updated_at = src.updatedAt,
    };
}

fn envGroupFromWire(src: WireEnvGroup) EnvGroup {
    return .{
        .id = src.id,
        .environment_id = src.environmentId,
        .name = src.name,
        .slug = src.slug,
        .description = src.description,
        .member_count = src.memberCount,
        .joined_at = src.joinedAt,
        .created_at = src.createdAt,
        .updated_at = src.updatedAt,
    };
}

fn parseMapped(
    comptime Wire: type,
    comptime Result: type,
    allocator: std.mem.Allocator,
    json_str: []const u8,
    comptime mapFn: fn (*std.heap.ArenaAllocator, Wire) anyerror!Result,
) !Result {
    const parsed = std.json.parseFromSlice(Wire, allocator, json_str, .{
        .ignore_unknown_fields = true,
        .allocate = .alloc_always,
    }) catch return error.ParseError;
    errdefer parsed.deinit();
    return mapFn(parsed.arena, parsed.value);
}

pub fn parseProbe(allocator: std.mem.Allocator, json_str: []const u8) !Probe {
    const parsed = std.json.parseFromSlice(struct { ok: bool = false }, allocator, json_str, .{
        .ignore_unknown_fields = true,
    }) catch return error.ParseError;
    defer parsed.deinit();
    return .{ .ok = parsed.value.ok };
}

pub fn parseOrganizationsList(allocator: std.mem.Allocator, json_str: []const u8) !OrganizationsList {
    return parseMapped(WireOrganizationsList, OrganizationsList, allocator, json_str, struct {
        fn map(arena: *std.heap.ArenaAllocator, wire: WireOrganizationsList) !OrganizationsList {
            const orgs = try arena.allocator().alloc(Organization, wire.organizations.len);
            for (wire.organizations, orgs) |src, *dst| {
                dst.* = organizationFromWire(src);
            }
            return .{
                .organizations = orgs,
                .total = wire.total,
                .arena = arena,
            };
        }
    }.map);
}

pub fn parseTenantsList(allocator: std.mem.Allocator, json_str: []const u8) !TenantsList {
    return parseMapped(WireTenantsList, TenantsList, allocator, json_str, struct {
        fn map(arena: *std.heap.ArenaAllocator, wire: WireTenantsList) !TenantsList {
            const tenants = try arena.allocator().alloc(Tenant, wire.tenants.len);
            for (wire.tenants, tenants) |src, *dst| {
                dst.* = tenantFromWire(src);
            }
            return .{
                .tenants = tenants,
                .total = wire.total,
                .arena = arena,
            };
        }
    }.map);
}

pub fn parseEnvUsersResponse(allocator: std.mem.Allocator, json_str: []const u8) !EnvUsersResponse {
    return parseMapped(WireEnvUsersResponse, EnvUsersResponse, allocator, json_str, struct {
        fn map(arena: *std.heap.ArenaAllocator, wire: WireEnvUsersResponse) !EnvUsersResponse {
            const users = try arena.allocator().alloc(EnvUser, wire.users.len);
            for (wire.users, users) |src, *dst| {
                dst.* = try envUserFromWire(arena.allocator(), src);
            }
            return .{
                .users = users,
                .arena = arena,
            };
        }
    }.map);
}

pub fn parseEnvGroupsResponse(allocator: std.mem.Allocator, json_str: []const u8) !EnvGroupsResponse {
    return parseMapped(WireEnvGroupsResponse, EnvGroupsResponse, allocator, json_str, struct {
        fn map(arena: *std.heap.ArenaAllocator, wire: WireEnvGroupsResponse) !EnvGroupsResponse {
            const groups = try arena.allocator().alloc(EnvGroup, wire.groups.len);
            for (wire.groups, groups) |src, *dst| {
                dst.* = envGroupFromWire(src);
            }
            return .{
                .groups = groups,
                .arena = arena,
            };
        }
    }.map);
}

/// Copies a JSON object `error` string when present.
pub fn jsonErrorField(allocator: std.mem.Allocator, json_str: []const u8) ?[]u8 {
    const parsed = std.json.parseFromSlice(WireErrorField, allocator, json_str, .{
        .ignore_unknown_fields = true,
        .allocate = .alloc_always,
    }) catch return null;
    defer parsed.deinit();
    const message = parsed.value.@"error" orelse return null;
    if (message.len == 0) return null;
    return allocator.dupe(u8, message) catch null;
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

test "parse probe and empty management lists" {
    const probe = try parseProbe(std.testing.allocator, "{\"ok\":true}");
    try std.testing.expect(probe.ok);

    const orgs = try parseOrganizationsList(std.testing.allocator, "{}");
    defer orgs.deinit();
    try std.testing.expectEqual(@as(usize, 0), orgs.organizations.len);
    try std.testing.expectEqual(@as(i64, 0), orgs.total);

    const tenants = try parseTenantsList(std.testing.allocator, "{\"tenants\":[],\"total\":0}");
    defer tenants.deinit();
    try std.testing.expectEqual(@as(usize, 0), tenants.tenants.len);

    const users = try parseEnvUsersResponse(std.testing.allocator, "{\"users\":[]}");
    defer users.deinit();
    try std.testing.expectEqual(@as(usize, 0), users.users.len);

    const groups = try parseEnvGroupsResponse(std.testing.allocator, "{\"groups\":[]}");
    defer groups.deinit();
    try std.testing.expectEqual(@as(usize, 0), groups.groups.len);
}

test "parse env user list item maps camelCase" {
    const json =
        \\{
        \\  "users": [
        \\    {
        \\      "id": "usr_1",
        \\      "displayName": "Ada",
        \\      "emails": [{ "value": "ada@example.com" }]
        \\    }
        \\  ]
        \\}
    ;
    const listed = try parseEnvUsersResponse(std.testing.allocator, json);
    defer listed.deinit();
    try std.testing.expectEqual(@as(usize, 1), listed.users.len);
    try std.testing.expectEqualStrings("usr_1", listed.users[0].id);
    try std.testing.expectEqualStrings("Ada", listed.users[0].display_name.?);
    try std.testing.expectEqualStrings("ada@example.com", listed.users[0].emails[0].value);
}
