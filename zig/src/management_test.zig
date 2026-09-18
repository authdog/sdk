const std = @import("std");
const client_mod = @import("client.zig");
const errors = @import("error.zig");

const AuthdogClient = client_mod.AuthdogClient;
const MockHttp = client_mod.MockHttp;

const StartedClient = struct {
    url: []u8,
    client: AuthdogClient,
};

fn startClient(mock: *MockHttp, api_key: ?[]const u8) !StartedClient {
    return startClientWith(mock, api_key, .{});
}

fn startClientWith(mock: *MockHttp, api_key: ?[]const u8, extras: struct {
    environment_secret: ?[]const u8 = null,
    scim_token: ?[]const u8 = null,
    hris_token: ?[]const u8 = null,
}) !StartedClient {
    const url = try mock.baseUrl();
    errdefer std.testing.allocator.free(url);
    const client = try AuthdogClient.init(std.testing.allocator, .{
        .base_url = url,
        .api_key = api_key,
        .environment_secret = extras.environment_secret,
        .scim_token = extras.scim_token,
        .hris_token = extras.hris_token,
    });
    return .{ .url = url, .client = client };
}

const Wave1Case = struct {
    name: []const u8,
    method: std.http.Method,
    path: []const u8,
    body: ?[]const u8 = null,
    response: []const u8 = "{}",
    expected_authorization: ?[]const u8 = "Bearer key-1",
    invoke: *const fn (*AuthdogClient) anyerror!void,
};

fn discardList(result: anytype) void {
    result.deinit();
}

const wave1_cases = [_]Wave1Case{
    .{
        .name = "organizations.list",
        .method = .GET,
        .path = "/v1/organizations",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                discardList(try c.organizations().list());
            }
        }.f,
    },
    .{
        .name = "organizations.create",
        .method = .POST,
        .path = "/v1/organizations",
        .body = "{\"name\":\"Acme\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().create("{\"name\":\"Acme\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.get",
        .method = .GET,
        .path = "/v1/organizations/org_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().get("org_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.update",
        .method = .PATCH,
        .path = "/v1/organizations/org_1",
        .body = "{\"name\":\"New\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().update("org_1", "{\"name\":\"New\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.delete",
        .method = .DELETE,
        .path = "/v1/organizations/org_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().delete("org_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.acceptInvitation",
        .method = .POST,
        .path = "/v1/organizations/invitations/accept",
        .body = "{\"token\":\"t\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().acceptInvitation("{\"token\":\"t\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.join",
        .method = .POST,
        .path = "/v1/organizations/join",
        .body = "{\"invitationCode\":\"c\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().join("{\"invitationCode\":\"c\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.listInvitations",
        .method = .GET,
        .path = "/v1/organizations/org_1/invitations",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().listInvitations("org_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.createInvitation",
        .method = .POST,
        .path = "/v1/organizations/org_1/invitations",
        .body = "{\"email\":\"a@b.c\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().createInvitation("org_1", "{\"email\":\"a@b.c\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.cancelInvitation",
        .method = .POST,
        .path = "/v1/organizations/org_1/invitations/inv_1/cancel",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().cancelInvitation("org_1", "inv_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.sendInvite",
        .method = .POST,
        .path = "/v1/organizations/org_1/invites",
        .body = "{\"email\":\"a@b.c\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().sendInvite("org_1", "{\"email\":\"a@b.c\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.listMembers",
        .method = .GET,
        .path = "/v1/organizations/org_1/members",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().listMembers("org_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.removeMember",
        .method = .DELETE,
        .path = "/v1/organizations/org_1/members/mem_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().removeMember("org_1", "mem_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.setMemberActive",
        .method = .PATCH,
        .path = "/v1/organizations/org_1/members/mem_1/active",
        .body = "{\"active\":false}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().setMemberActive("org_1", "mem_1", "{\"active\":false}")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.linkTenant",
        .method = .POST,
        .path = "/v1/organizations/org_1/tenants",
        .body = "{\"tenantId\":\"ten_1\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().linkTenant("org_1", "{\"tenantId\":\"ten_1\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.unlinkTenant",
        .method = .DELETE,
        .path = "/v1/organizations/org_1/tenants/ten_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().unlinkTenant("org_1", "ten_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "tenants.list",
        .method = .GET,
        .path = "/v1/tenants",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                discardList(try c.tenants().list(.{}));
            }
        }.f,
    },
    .{
        .name = "tenants.create",
        .method = .POST,
        .path = "/v1/tenants",
        .body = "{\"name\":\"T\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.tenants().create("{\"name\":\"T\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "tenants.join",
        .method = .POST,
        .path = "/v1/tenants/join",
        .body = "{\"invitationCode\":\"c\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.tenants().join("{\"invitationCode\":\"c\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "tenants.get",
        .method = .GET,
        .path = "/v1/tenants/ten_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.tenants().get("ten_1", .{})).deinit();
            }
        }.f,
    },
    .{
        .name = "tenants.update",
        .method = .PATCH,
        .path = "/v1/tenants/ten_1",
        .body = "{\"name\":\"N\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.tenants().update("ten_1", "{\"name\":\"N\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "tenants.delete",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.tenants().delete("ten_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "tenants.listDomains",
        .method = .GET,
        .path = "/v1/tenants/ten_1/domains",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.tenants().listDomains("ten_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "tenants.createDomain",
        .method = .POST,
        .path = "/v1/tenants/ten_1/domains",
        .body = "{\"domain\":\"a.com\",\"validationMethod\":\"dns\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.tenants().createDomain("ten_1", "{\"domain\":\"a.com\",\"validationMethod\":\"dns\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "tenants.deleteDomain",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/domains/dom_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.tenants().deleteDomain("ten_1", "dom_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "tenants.retryDomain",
        .method = .POST,
        .path = "/v1/tenants/ten_1/domains/dom_1/retry",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.tenants().retryDomain("ten_1", "dom_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "tenants.sendInvite",
        .method = .POST,
        .path = "/v1/tenants/ten_1/invites",
        .body = "{\"email\":\"a@b.c\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.tenants().sendInvite("ten_1", "{\"email\":\"a@b.c\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "tenants.listProjects",
        .method = .GET,
        .path = "/v1/tenants/ten_1/projects",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.tenants().listProjects("ten_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "tenants.listSeats",
        .method = .GET,
        .path = "/v1/tenants/ten_1/seats",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.tenants().listSeats("ten_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "tenants.updateSeat",
        .method = .PATCH,
        .path = "/v1/tenants/ten_1/seats/seat_1",
        .body = "{\"active\":true}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.tenants().updateSeat("ten_1", "seat_1", "{\"active\":true}")).deinit();
            }
        }.f,
    },
    .{
        .name = "tenants.deleteSeat",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/seats/seat_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.tenants().deleteSeat("ten_1", "seat_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "projects.save",
        .method = .POST,
        .path = "/v1/tenants/ten_1/applications",
        .body = "{\"name\":\"App\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.projects().save("ten_1", "{\"name\":\"App\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "projects.get",
        .method = .GET,
        .path = "/v1/tenants/ten_1/applications/app_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.projects().get("ten_1", "app_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "projects.delete",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/applications/app_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.projects().delete("ten_1", "app_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "projects.setDefaultEnvironment",
        .method = .PUT,
        .path = "/v1/tenants/ten_1/applications/app_1/default-environment",
        .body = "{\"environmentId\":\"env_1\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.projects().setDefaultEnvironment("ten_1", "app_1", "{\"environmentId\":\"env_1\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "environments.list",
        .method = .GET,
        .path = "/v1/tenants/ten_1/applications/app_1/environments",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.environments().list("ten_1", "app_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "environments.create",
        .method = .POST,
        .path = "/v1/tenants/ten_1/applications/app_1/environments",
        .body = "{\"name\":\"prod\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.environments().create("ten_1", "app_1", "{\"name\":\"prod\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "environments.update",
        .method = .PATCH,
        .path = "/v1/tenants/ten_1/environments/env_1",
        .body = "{\"name\":\"prod\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.environments().update("ten_1", "env_1", "{\"name\":\"prod\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "environments.delete",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.environments().delete("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "users.list",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/users",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                discardList(try c.users().list("ten_1", "env_1", .{}));
            }
        }.f,
    },
    .{
        .name = "users.create",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/users",
        .body = "{\"email\":\"a@b.c\",\"password\":\"x\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.users().create("ten_1", "env_1", "{\"email\":\"a@b.c\",\"password\":\"x\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "users.search",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/users/search?q=ada",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                discardList(try c.users().search("ten_1", "env_1", .{ .q = "ada" }));
            }
        }.f,
    },
    .{
        .name = "users.count",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/users/count",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.users().count("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "users.get",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/users/usr_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.users().get("ten_1", "env_1", "usr_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "users.update",
        .method = .PUT,
        .path = "/v1/tenants/ten_1/environments/env_1/users/usr_1",
        .body = "{\"displayName\":\"Ada\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.users().update("ten_1", "env_1", "usr_1", "{\"displayName\":\"Ada\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "users.delete",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/users/usr_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.users().delete("ten_1", "env_1", "usr_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "users.setActive",
        .method = .PATCH,
        .path = "/v1/tenants/ten_1/environments/env_1/users/usr_1/active",
        .body = "{\"active\":false}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.users().setActive("ten_1", "env_1", "usr_1", "{\"active\":false}")).deinit();
            }
        }.f,
    },
    .{
        .name = "users.listGroups",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/users/usr_1/groups",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.users().listGroups("ten_1", "env_1", "usr_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "groups.create",
        .method = .POST,
        .path = "/v1/groups",
        .body = "{\"environmentId\":\"env_1\",\"name\":\"Admins\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.groups().create("{\"environmentId\":\"env_1\",\"name\":\"Admins\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "groups.list",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/groups",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                discardList(try c.groups().list("ten_1", "env_1"));
            }
        }.f,
    },
    .{
        .name = "groups.delete",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/groups/grp_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.groups().delete("ten_1", "env_1", "grp_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "groups.listMembers",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/groups/grp_1/members",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.groups().listMembers("ten_1", "env_1", "grp_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "groups.addMember",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/groups/grp_1/members",
        .body = "{\"userId\":\"usr_1\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.groups().addMember("ten_1", "env_1", "grp_1", "{\"userId\":\"usr_1\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "groups.removeMember",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/groups/grp_1/members/usr_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.groups().removeMember("ten_1", "env_1", "grp_1", "usr_1")).deinit();
            }
        }.f,
    },
};

test "wave1 method and path" {
    for (wave1_cases) |case| {
        const mock = try MockHttp.start(std.testing.allocator, .ok, case.response, "Bearer key-1");
        defer mock.deinit();

        var started = try startClient(mock, "key-1");
        defer std.testing.allocator.free(started.url);
        defer started.client.deinit();

        case.invoke(&started.client) catch |err| {
            std.debug.print("wave1 case {s} failed: {s} ({s})\n", .{
                case.name,
                @errorName(err),
                started.client.lastErrorMessage(),
            });
            return err;
        };

        try std.testing.expectEqual(case.method, mock.seen_method.?);
        try std.testing.expectEqualStrings(case.path, mock.seen_target.?);
        try std.testing.expectEqualStrings("Bearer key-1", mock.seen_authorization.?);
        if (case.body) |body| {
            try std.testing.expectEqualStrings(body, mock.seen_body.?);
        } else {
            try std.testing.expectEqual(@as(?[]u8, null), mock.seen_body);
        }
    }
}

test "management uses constructor api key" {
    const mock = try MockHttp.start(std.testing.allocator, .ok, "{\"organizations\":[],\"total\":0}", "Bearer key-1");
    defer mock.deinit();

    var started = try startClient(mock, "key-1");
    defer std.testing.allocator.free(started.url);
    defer started.client.deinit();

    const listed = try started.client.organizations().list();
    defer listed.deinit();
    try std.testing.expectEqual(@as(usize, 0), listed.organizations.len);
    try std.testing.expectEqual(@as(i64, 0), listed.total);
    try std.testing.expectEqualStrings("Bearer key-1", mock.seen_authorization.?);
}

test "management 404 includes status and error" {
    const mock = try MockHttp.start(std.testing.allocator, .not_found, "{\"error\":\"not found\"}", null);
    defer mock.deinit();

    var started = try startClient(mock, "key-1");
    defer std.testing.allocator.free(started.url);
    defer started.client.deinit();

    try std.testing.expectError(error.ApiError, started.client.organizations().get("missing"));
    try std.testing.expect(errors.isApiError(error.ApiError));
    try std.testing.expect(std.mem.indexOf(u8, started.client.lastErrorMessage(), "HTTP error 404") != null);
    try std.testing.expect(std.mem.indexOf(u8, started.client.lastErrorMessage(), "not found") != null);
}

test "management transport error" {
    var client = try AuthdogClient.init(std.testing.allocator, .{
        .base_url = "http://127.0.0.1:1",
        .api_key = "key-1",
    });
    defer client.deinit();

    try std.testing.expectError(error.ApiError, client.tenants().list(.{}));
    try std.testing.expectEqualStrings(errors.request_failed_message, client.lastErrorMessage());
}

test "organizations list create get" {
    const list_body = "{\"organizations\":[{\"id\":\"org_1\",\"name\":\"Acme\",\"active\":true,\"createdAt\":\"t\",\"updatedAt\":\"t\"}],\"total\":1}";
    const mock = try MockHttp.start(std.testing.allocator, .ok, list_body, "Bearer key-1");
    defer mock.deinit();

    var started = try startClient(mock, "key-1");
    defer std.testing.allocator.free(started.url);
    defer started.client.deinit();

    const listed = try started.client.organizations().list();
    defer listed.deinit();
    try std.testing.expectEqual(@as(usize, 1), listed.organizations.len);
    try std.testing.expectEqualStrings("org_1", listed.organizations[0].id);
    try std.testing.expectEqualStrings("Acme", listed.organizations[0].name);
}

test "organizations create and get parse envelopes" {
    const create_body = "{\"organization\":{\"id\":\"org_1\",\"name\":\"Acme\"}}";
    const mock = try MockHttp.start(std.testing.allocator, .ok, create_body, "Bearer key-1");
    defer mock.deinit();

    var started = try startClient(mock, "key-1");
    defer std.testing.allocator.free(started.url);
    defer started.client.deinit();

    const created = try started.client.organizations().create("{\"name\":\"Acme\"}");
    defer created.deinit();
    const organization = created.value.object.get("organization").?;
    try std.testing.expectEqualStrings("org_1", organization.object.get("id").?.string);
}

test "tenants list and get" {
    const list_body = "{\"tenants\":[{\"id\":\"ten_1\",\"name\":\"T\",\"active\":true,\"createdAt\":\"t\",\"updatedAt\":\"t\",\"organizationIds\":[\"org_1\"]}],\"total\":1}";
    const mock = try MockHttp.start(std.testing.allocator, .ok, list_body, "Bearer key-1");
    defer mock.deinit();

    var started = try startClient(mock, "key-1");
    defer std.testing.allocator.free(started.url);
    defer started.client.deinit();

    const listed = try started.client.tenants().list(.{ .organization_id = "org_1" });
    defer listed.deinit();
    try std.testing.expectEqualStrings("/v1/tenants?organization_id=org_1", mock.seen_target.?);
    try std.testing.expectEqual(@as(usize, 1), listed.tenants.len);
    try std.testing.expectEqualStrings("ten_1", listed.tenants[0].id);
    try std.testing.expectEqualStrings("org_1", listed.tenants[0].organization_ids[0]);
}

test "users list empty and one user" {
    {
        const mock = try MockHttp.start(std.testing.allocator, .ok, "{\"users\":[]}", "Bearer key-1");
        defer mock.deinit();

        var started = try startClient(mock, "key-1");
        defer std.testing.allocator.free(started.url);
        defer started.client.deinit();

        const listed = try started.client.users().list("ten_1", "env_1", .{});
        defer listed.deinit();
        try std.testing.expectEqual(@as(usize, 0), listed.users.len);
    }

    {
        const mock = try MockHttp.start(
            std.testing.allocator,
            .ok,
            "{\"users\":[{\"id\":\"usr_1\",\"displayName\":\"Ada\",\"emails\":[{\"value\":\"ada@example.com\"}]}]}",
            "Bearer key-1",
        );
        defer mock.deinit();

        var started = try startClient(mock, "key-1");
        defer std.testing.allocator.free(started.url);
        defer started.client.deinit();

        const listed = try started.client.users().list("ten_1", "env_1", .{});
        defer listed.deinit();
        try std.testing.expectEqual(@as(usize, 1), listed.users.len);
        try std.testing.expectEqualStrings("usr_1", listed.users[0].id);
        try std.testing.expectEqualStrings("Ada", listed.users[0].display_name.?);
        try std.testing.expectEqualStrings("ada@example.com", listed.users[0].emails[0].value);
    }
}

test "groups list and create" {
    {
        const mock = try MockHttp.start(
            std.testing.allocator,
            .ok,
            "{\"groups\":[{\"id\":\"grp_1\",\"environmentId\":\"env_1\",\"name\":\"Admins\",\"slug\":\"admins\",\"memberCount\":2,\"createdAt\":\"t\",\"updatedAt\":\"t\"}]}",
            "Bearer key-1",
        );
        defer mock.deinit();

        var started = try startClient(mock, "key-1");
        defer std.testing.allocator.free(started.url);
        defer started.client.deinit();

        const listed = try started.client.groups().list("ten_1", "env_1");
        defer listed.deinit();
        try std.testing.expectEqual(@as(usize, 1), listed.groups.len);
        try std.testing.expectEqualStrings("grp_1", listed.groups[0].id);
        try std.testing.expectEqualStrings("Admins", listed.groups[0].name);
        try std.testing.expectEqual(@as(i64, 2), listed.groups[0].member_count);
    }

    {
        const mock = try MockHttp.start(std.testing.allocator, .ok, "{\"id\":\"grp_1\"}", "Bearer key-1");
        defer mock.deinit();

        var started = try startClient(mock, "key-1");
        defer std.testing.allocator.free(started.url);
        defer started.client.deinit();

        const created = try started.client.groups().create("{\"environmentId\":\"env_1\",\"name\":\"Admins\"}");
        defer created.deinit();
        try std.testing.expectEqualStrings("grp_1", created.value.object.get("id").?.string);
        try std.testing.expectEqual(std.http.Method.POST, mock.seen_method.?);
        try std.testing.expectEqualStrings("/v1/groups", mock.seen_target.?);
    }
}

test "environments list and projects get" {
    {
        const mock = try MockHttp.start(std.testing.allocator, .ok, "{\"environments\":[]}", "Bearer key-1");
        defer mock.deinit();

        var started = try startClient(mock, "key-1");
        defer std.testing.allocator.free(started.url);
        defer started.client.deinit();

        const listed = try started.client.environments().list("ten_1", "app_1");
        defer listed.deinit();
        try std.testing.expect(listed.value.object.get("environments") != null);
        try std.testing.expectEqualStrings("/v1/tenants/ten_1/applications/app_1/environments", mock.seen_target.?);
    }

    {
        const mock = try MockHttp.start(std.testing.allocator, .ok, "{\"id\":\"app_1\",\"name\":\"App\"}", "Bearer key-1");
        defer mock.deinit();

        var started = try startClient(mock, "key-1");
        defer std.testing.allocator.free(started.url);
        defer started.client.deinit();

        const project = try started.client.projects().get("ten_1", "app_1");
        defer project.deinit();
        try std.testing.expectEqualStrings("app_1", project.value.object.get("id").?.string);
        try std.testing.expectEqualStrings("/v1/tenants/ten_1/applications/app_1", mock.seen_target.?);
    }
}

const wave2_cases = [_]Wave1Case{
    .{
        .name = "organizations.listKeys",
        .method = .GET,
        .path = "/v1/organizations/org_1/keys",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().listKeys("org_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.createKey",
        .method = .POST,
        .path = "/v1/organizations/org_1/keys",
        .body = "{\"name\":\"ci\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().createKey("org_1", "{\"name\":\"ci\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.revokeKey",
        .method = .POST,
        .path = "/v1/organizations/org_1/keys/key_1/revoke",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().revokeKey("org_1", "key_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.rotateKey",
        .method = .POST,
        .path = "/v1/organizations/org_1/keys/key_1/rotate",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().rotateKey("org_1", "key_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.updateKeyTenants",
        .method = .PUT,
        .path = "/v1/organizations/org_1/keys/key_1/tenants",
        .body = "{\"tenantIds\":[\"ten_1\"]}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().updateKeyTenants("org_1", "key_1", "{\"tenantIds\":[\"ten_1\"]}")).deinit();
            }
        }.f,
    },
    .{
        .name = "organizations.listAuditLogs",
        .method = .GET,
        .path = "/v1/organizations/org_1/audit/logs",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.organizations().listAuditLogs("org_1", &.{})).deinit();
            }
        }.f,
    },
    .{
        .name = "serviceAccounts.list",
        .method = .GET,
        .path = "/v1/service-accounts",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.serviceAccounts().list()).deinit();
            }
        }.f,
    },
    .{
        .name = "serviceAccounts.create",
        .method = .POST,
        .path = "/v1/service-accounts",
        .body = "{\"name\":\"bot\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.serviceAccounts().create("{\"name\":\"bot\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "serviceAccounts.get",
        .method = .GET,
        .path = "/v1/service-accounts/sa_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.serviceAccounts().get("sa_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "serviceAccounts.delete",
        .method = .DELETE,
        .path = "/v1/service-accounts/sa_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.serviceAccounts().delete("sa_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "personalAccessTokens.list",
        .method = .GET,
        .path = "/v1/personal-access-tokens",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.personalAccessTokens().list()).deinit();
            }
        }.f,
    },
    .{
        .name = "personalAccessTokens.create",
        .method = .POST,
        .path = "/v1/personal-access-tokens",
        .body = "{\"name\":\"cli\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.personalAccessTokens().create("{\"name\":\"cli\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "personalAccessTokens.revoke",
        .method = .POST,
        .path = "/v1/personal-access-tokens/pat_1/revoke",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.personalAccessTokens().revoke("pat_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "apiSecrets.list",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/api-secrets",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.apiSecrets().list("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "apiSecrets.create",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/api-secrets",
        .body = "{\"name\":\"runtime\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.apiSecrets().create("ten_1", "env_1", "{\"name\":\"runtime\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "apiSecrets.revoke",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/api-secrets/sec_1/revoke",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.apiSecrets().revoke("ten_1", "env_1", "sec_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "audit.listLogs",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/audit/logs",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.audit().listLogs("ten_1", "env_1", &.{})).deinit();
            }
        }.f,
    },
    .{
        .name = "audit.eventMetadata",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/audit/event-metadata",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.audit().eventMetadata("ten_1", "env_1", &.{})).deinit();
            }
        }.f,
    },
    .{
        .name = "audit.eventTypes",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/audit/event-types",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.audit().eventTypes("ten_1", "env_1", &.{})).deinit();
            }
        }.f,
    },
    .{
        .name = "audit.eventTypesCatalog",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/audit/event-types/catalog",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.audit().eventTypesCatalog("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "events.list",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/events",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.events().list("ten_1", "env_1", &.{})).deinit();
            }
        }.f,
    },
    .{
        .name = "events.listTypes",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/events/types",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.events().listTypes("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "events.ingest",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/events/ingest",
        .body = "{\"events\":[]}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.events().ingest("ten_1", "env_1", "{\"events\":[]}")).deinit();
            }
        }.f,
    },
    .{
        .name = "webhooks.list",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/webhooks",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.webhooks().list("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "webhooks.create",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/webhooks",
        .body = "{\"url\":\"https://ex\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.webhooks().create("ten_1", "env_1", "{\"url\":\"https://ex\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "webhooks.update",
        .method = .PUT,
        .path = "/v1/tenants/ten_1/environments/env_1/webhooks/ch_1",
        .body = "{\"url\":\"https://ex\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.webhooks().update("ten_1", "env_1", "ch_1", "{\"url\":\"https://ex\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "webhooks.delete",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/webhooks/ch_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.webhooks().delete("ten_1", "env_1", "ch_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "webhooks.rotateSecret",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/webhooks/ch_1/rotate-secret",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.webhooks().rotateSecret("ten_1", "env_1", "ch_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "webhooks.listDeliveries",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/webhooks/deliveries",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.webhooks().listDeliveries("ten_1", "env_1", &.{})).deinit();
            }
        }.f,
    },
    .{
        .name = "webhooks.redeliver",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/webhooks/deliveries/del_1/redeliver",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.webhooks().redeliver("ten_1", "env_1", "del_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "notificationChannels.list",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/notification-channels",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.notificationChannels().list("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "notificationChannels.create",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/notification-channels",
        .body = "{\"type\":\"webhook\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.notificationChannels().create("ten_1", "env_1", "{\"type\":\"webhook\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "notificationChannels.update",
        .method = .PUT,
        .path = "/v1/tenants/ten_1/environments/env_1/notification-channels/ch_1",
        .body = "{\"name\":\"n\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.notificationChannels().update("ten_1", "env_1", "ch_1", "{\"name\":\"n\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "notificationChannels.delete",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/notification-channels/ch_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.notificationChannels().delete("ten_1", "env_1", "ch_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "notificationChannels.test",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/notification-channels/ch_1/test",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.notificationChannels().@"test"("ten_1", "env_1", "ch_1", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.listRoles",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/roles",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().listRoles("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.createRole",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/roles",
        .body = "{\"name\":\"admin\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().createRole("ten_1", "env_1", "{\"name\":\"admin\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.deleteRole",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/roles/role_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().deleteRole("ten_1", "env_1", "role_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.listRolePermissions",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/roles/role_1/permissions",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().listRolePermissions("ten_1", "env_1", "role_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.setRolePermissions",
        .method = .PUT,
        .path = "/v1/tenants/ten_1/environments/env_1/roles/role_1/permissions",
        .body = "{\"permissionIds\":[]}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().setRolePermissions("ten_1", "env_1", "role_1", "{\"permissionIds\":[]}")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.listPermissions",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/permissions",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().listPermissions("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.createPermission",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/permissions",
        .body = "{\"name\":\"read\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().createPermission("ten_1", "env_1", "{\"name\":\"read\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.deletePermission",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/permissions/perm_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().deletePermission("ten_1", "env_1", "perm_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.listResources",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/resources",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().listResources("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.createResource",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/resources",
        .body = "{\"name\":\"doc\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().createResource("ten_1", "env_1", "{\"name\":\"doc\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.deleteResource",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/resources/res_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().deleteResource("ten_1", "env_1", "res_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.listGroupRoles",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/groups/grp_1/roles",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().listGroupRoles("ten_1", "env_1", "grp_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.addGroupRole",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/groups/grp_1/roles",
        .body = "{\"roleId\":\"role_1\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().addGroupRole("ten_1", "env_1", "grp_1", "{\"roleId\":\"role_1\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.removeGroupRole",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/groups/grp_1/roles/role_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().removeGroupRole("ten_1", "env_1", "grp_1", "role_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.listGroupRoleMappings",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/group-role-mappings",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().listGroupRoleMappings("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.createGroupRoleMapping",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/group-role-mappings",
        .body = "{\"groupId\":\"grp_1\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().createGroupRoleMapping("ten_1", "env_1", "{\"groupId\":\"grp_1\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.applyGroupRoleMappings",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/group-role-mappings/apply",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().applyGroupRoleMappings("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.deleteGroupRoleMapping",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/group-role-mappings/map_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().deleteGroupRoleMapping("ten_1", "env_1", "map_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.listAbacPolicies",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/abac-policies",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().listAbacPolicies("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.saveAbacPolicy",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/abac-policies",
        .body = "{\"name\":\"p\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().saveAbacPolicy("ten_1", "env_1", "{\"name\":\"p\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.validateAbacPolicy",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/abac-policies/validate",
        .body = "{\"rego\":\"x\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().validateAbacPolicy("ten_1", "env_1", "{\"rego\":\"x\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.deleteAbacPolicy",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/abac-policies/pol_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().deleteAbacPolicy("ten_1", "env_1", "pol_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "rbac.myPermissions",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/me/permissions",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.rbac().myPermissions("ten_1", "env_1")).deinit();
            }
        }.f,
    },
};

test "wave2 method and path" {
    try std.testing.expectEqual(@as(usize, 58), wave2_cases.len);
    for (wave2_cases) |case| {
        const mock = try MockHttp.start(std.testing.allocator, .ok, case.response, "Bearer key-1");
        defer mock.deinit();

        var started = try startClient(mock, "key-1");
        defer std.testing.allocator.free(started.url);
        defer started.client.deinit();

        case.invoke(&started.client) catch |err| {
            std.debug.print("wave2 case {s} failed: {s} ({s})\n", .{
                case.name,
                @errorName(err),
                started.client.lastErrorMessage(),
            });
            return err;
        };

        try std.testing.expectEqual(case.method, mock.seen_method.?);
        try std.testing.expectEqualStrings(case.path, mock.seen_target.?);
        try std.testing.expectEqualStrings("Bearer key-1", mock.seen_authorization.?);
        if (case.body) |body| {
            try std.testing.expectEqualStrings(body, mock.seen_body.?);
        } else {
            try std.testing.expectEqual(@as(?[]u8, null), mock.seen_body);
        }
    }
}

test "wave2 create key exposes one-time secret" {
    const mock = try MockHttp.start(
        std.testing.allocator,
        .ok,
        "{\"token\":\"orgk_secret_once\",\"key\":{\"id\":\"key_1\"}}",
        "Bearer key-1",
    );
    defer mock.deinit();

    var started = try startClient(mock, "key-1");
    defer std.testing.allocator.free(started.url);
    defer started.client.deinit();

    const created = try started.client.organizations().createKey("org_1", "{\"name\":\"ci\"}");
    defer created.deinit();
    try std.testing.expectEqualStrings("orgk_secret_once", created.value.object.get("token").?.string);
}

test "wave2 audit forwards query params" {
    const mock = try MockHttp.start(std.testing.allocator, .ok, "{}", "Bearer key-1");
    defer mock.deinit();

    var started = try startClient(mock, "key-1");
    defer std.testing.allocator.free(started.url);
    defer started.client.deinit();

    const listed = try started.client.events().list("ten_1", "env_1", &.{
        .{ .name = "limit", .value = "50" },
        .{ .name = "after", .value = "cur_1" },
    });
    defer listed.deinit();
    try std.testing.expectEqualStrings("/v1/tenants/ten_1/environments/env_1/events?limit=50&after=cur_1", mock.seen_target.?);
}

const wave3_cases = [_]Wave1Case{
    .{
        .name = "authzen.configuration",
        .method = .GET,
        .path = "/.well-known/authzen-configuration",
        .expected_authorization = null,
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.authzen().configuration()).deinit();
            }
        }.f,
    },
    .{
        .name = "authzen.evaluate",
        .method = .POST,
        .path = "/access/v1/evaluation",
        .body = "{\"subject\":{}}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.authzen().evaluate("{\"subject\":{}}", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "authzen.evaluateBatch",
        .method = .POST,
        .path = "/access/v1/evaluations",
        .body = "{\"evaluations\":[]}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.authzen().evaluateBatch("{\"evaluations\":[]}", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "authzen.searchAction",
        .method = .POST,
        .path = "/access/v1/search/action",
        .body = "{\"subject\":{}}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.authzen().searchAction("{\"subject\":{}}", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "authzen.searchResource",
        .method = .POST,
        .path = "/access/v1/search/resource",
        .body = "{\"subject\":{}}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.authzen().searchResource("{\"subject\":{}}", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "authzen.searchSubject",
        .method = .POST,
        .path = "/access/v1/search/subject",
        .body = "{\"resource\":{}}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.authzen().searchSubject("{\"resource\":{}}", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "users.revokeSession",
        .method = .DELETE,
        .path = "/v1/environments/env_1/sessions/sess_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.users().revokeSession("env_1", "sess_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "hris.listDepartments",
        .method = .GET,
        .path = "/v1/hris/v1/Departments",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.hris().listDepartments(null)).deinit();
            }
        }.f,
    },
    .{
        .name = "hris.createDepartment",
        .method = .POST,
        .path = "/v1/hris/v1/Departments",
        .body = "{\"name\":\"Eng\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.hris().createDepartment("{\"name\":\"Eng\"}", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "hris.getDepartment",
        .method = .GET,
        .path = "/v1/hris/v1/Departments/dep_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.hris().getDepartment("dep_1", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "hris.replaceDepartment",
        .method = .PUT,
        .path = "/v1/hris/v1/Departments/dep_1",
        .body = "{\"name\":\"Eng\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.hris().replaceDepartment("dep_1", "{\"name\":\"Eng\"}", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "hris.patchDepartment",
        .method = .PATCH,
        .path = "/v1/hris/v1/Departments/dep_1",
        .body = "{\"name\":\"E\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.hris().patchDepartment("dep_1", "{\"name\":\"E\"}", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "hris.deleteDepartment",
        .method = .DELETE,
        .path = "/v1/hris/v1/Departments/dep_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.hris().deleteDepartment("dep_1", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "hris.listEmployees",
        .method = .GET,
        .path = "/v1/hris/v1/Employees",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.hris().listEmployees(null)).deinit();
            }
        }.f,
    },
    .{
        .name = "hris.createEmployee",
        .method = .POST,
        .path = "/v1/hris/v1/Employees",
        .body = "{\"name\":\"Ada\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.hris().createEmployee("{\"name\":\"Ada\"}", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "hris.getEmployee",
        .method = .GET,
        .path = "/v1/hris/v1/Employees/emp_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.hris().getEmployee("emp_1", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "hris.replaceEmployee",
        .method = .PUT,
        .path = "/v1/hris/v1/Employees/emp_1",
        .body = "{\"name\":\"Ada\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.hris().replaceEmployee("emp_1", "{\"name\":\"Ada\"}", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "hris.patchEmployee",
        .method = .PATCH,
        .path = "/v1/hris/v1/Employees/emp_1",
        .body = "{\"name\":\"A\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.hris().patchEmployee("emp_1", "{\"name\":\"A\"}", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "hris.deleteEmployee",
        .method = .DELETE,
        .path = "/v1/hris/v1/Employees/emp_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.hris().deleteEmployee("emp_1", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "hris.serviceConfig",
        .method = .GET,
        .path = "/v1/hris/v1/ServiceConfig",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.hris().serviceConfig(null)).deinit();
            }
        }.f,
    },
    .{
        .name = "otel.exportLogs",
        .method = .POST,
        .path = "/v1/logs",
        .body = "{\"resourceLogs\":[]}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.otel().exportLogs("{\"resourceLogs\":[]}")).deinit();
            }
        }.f,
    },
    .{
        .name = "mcp.ingestEvents",
        .method = .POST,
        .path = "/v1/mcp/events",
        .body = "{\"events\":[]}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.mcp().ingestEvents("{\"events\":[]}", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "mcp.resolve",
        .method = .GET,
        .path = "/v1/mcp/trust-store/resolve?subject=agent-1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.mcp().resolve("agent-1", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "otel.exportMetrics",
        .method = .POST,
        .path = "/v1/metrics",
        .body = "{\"resourceMetrics\":[]}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.otel().exportMetrics("{\"resourceMetrics\":[]}")).deinit();
            }
        }.f,
    },
    .{
        .name = "otel.exportLogsPrefixed",
        .method = .POST,
        .path = "/v1/otel/v1/logs",
        .body = "{\"resourceLogs\":[]}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.otel().exportLogsPrefixed("{\"resourceLogs\":[]}")).deinit();
            }
        }.f,
    },
    .{
        .name = "otel.exportMetricsPrefixed",
        .method = .POST,
        .path = "/v1/otel/v1/metrics",
        .body = "{\"resourceMetrics\":[]}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.otel().exportMetricsPrefixed("{\"resourceMetrics\":[]}")).deinit();
            }
        }.f,
    },
    .{
        .name = "otel.exportTracesPrefixed",
        .method = .POST,
        .path = "/v1/otel/v1/traces",
        .body = "{\"resourceSpans\":[]}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.otel().exportTracesPrefixed("{\"resourceSpans\":[]}")).deinit();
            }
        }.f,
    },
    .{
        .name = "scim.listGroups",
        .method = .GET,
        .path = "/v1/scim/v2/Groups",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.scim().listGroups(null)).deinit();
            }
        }.f,
    },
    .{
        .name = "scim.createGroup",
        .method = .POST,
        .path = "/v1/scim/v2/Groups",
        .body = "{\"displayName\":\"G\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.scim().createGroup("{\"displayName\":\"G\"}", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "scim.getGroup",
        .method = .GET,
        .path = "/v1/scim/v2/Groups/g_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.scim().getGroup("g_1", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "scim.replaceGroup",
        .method = .PUT,
        .path = "/v1/scim/v2/Groups/g_1",
        .body = "{\"displayName\":\"G\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.scim().replaceGroup("g_1", "{\"displayName\":\"G\"}", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "scim.patchGroup",
        .method = .PATCH,
        .path = "/v1/scim/v2/Groups/g_1",
        .body = "{\"Operations\":[]}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.scim().patchGroup("g_1", "{\"Operations\":[]}", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "scim.deleteGroup",
        .method = .DELETE,
        .path = "/v1/scim/v2/Groups/g_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.scim().deleteGroup("g_1", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "scim.resourceTypes",
        .method = .GET,
        .path = "/v1/scim/v2/ResourceTypes",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.scim().resourceTypes(null)).deinit();
            }
        }.f,
    },
    .{
        .name = "scim.resourceType",
        .method = .GET,
        .path = "/v1/scim/v2/ResourceTypes/User",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.scim().resourceType("User", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "scim.schemas",
        .method = .GET,
        .path = "/v1/scim/v2/Schemas",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.scim().schemas(null)).deinit();
            }
        }.f,
    },
    .{
        .name = "scim.schema",
        .method = .GET,
        .path = "/v1/scim/v2/Schemas/urn:ietf:params:scim:schemas:core:2.0:User",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.scim().schema("urn:ietf:params:scim:schemas:core:2.0:User", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "scim.serviceProviderConfig",
        .method = .GET,
        .path = "/v1/scim/v2/ServiceProviderConfig",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.scim().serviceProviderConfig(null)).deinit();
            }
        }.f,
    },
    .{
        .name = "scim.listUsers",
        .method = .GET,
        .path = "/v1/scim/v2/Users",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.scim().listUsers(null)).deinit();
            }
        }.f,
    },
    .{
        .name = "scim.createUser",
        .method = .POST,
        .path = "/v1/scim/v2/Users",
        .body = "{\"userName\":\"ada\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.scim().createUser("{\"userName\":\"ada\"}", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "scim.getUser",
        .method = .GET,
        .path = "/v1/scim/v2/Users/u_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.scim().getUser("u_1", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "scim.replaceUser",
        .method = .PUT,
        .path = "/v1/scim/v2/Users/u_1",
        .body = "{\"userName\":\"ada\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.scim().replaceUser("u_1", "{\"userName\":\"ada\"}", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "scim.patchUser",
        .method = .PATCH,
        .path = "/v1/scim/v2/Users/u_1",
        .body = "{\"Operations\":[]}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.scim().patchUser("u_1", "{\"Operations\":[]}", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "scim.deleteUser",
        .method = .DELETE,
        .path = "/v1/scim/v2/Users/u_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.scim().deleteUser("u_1", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "environments.listConnections",
        .method = .GET,
        .path = "/v1/tenants/ten_1/applications/app_1/environments/env_1/connections",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.environments().listConnections("ten_1", "app_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "oidcClients.list",
        .method = .GET,
        .path = "/v1/tenants/ten_1/applications/app_1/environments/env_1/oidc-clients",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.oidcClients().list("ten_1", "app_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "oidcClients.register",
        .method = .POST,
        .path = "/v1/tenants/ten_1/applications/app_1/environments/env_1/oidc-clients",
        .body = "{\"name\":\"cli\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.oidcClients().register("ten_1", "app_1", "env_1", "{\"name\":\"cli\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "oidcClients.update",
        .method = .PATCH,
        .path = "/v1/tenants/ten_1/applications/app_1/environments/env_1/oidc-clients/cid_1",
        .body = "{\"name\":\"n\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.oidcClients().update("ten_1", "app_1", "env_1", "cid_1", "{\"name\":\"n\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "oidcClients.delete",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/applications/app_1/environments/env_1/oidc-clients/cid_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.oidcClients().delete("ten_1", "app_1", "env_1", "cid_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "environments.listRedirectUris",
        .method = .GET,
        .path = "/v1/tenants/ten_1/applications/app_1/environments/env_1/redirect-uris",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.environments().listRedirectUris("ten_1", "app_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "actions.list",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/actions",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.actions().list("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "actions.save",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/actions",
        .body = "{\"url\":\"https://ex\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.actions().save("ten_1", "env_1", "{\"url\":\"https://ex\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "actions.executions",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/actions/executions",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.actions().executions("ten_1", "env_1", &.{})).deinit();
            }
        }.f,
    },
    .{
        .name = "actions.test",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/actions/test",
        .body = "{\"url\":\"https://ex\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.actions().@"test"("ten_1", "env_1", "{\"url\":\"https://ex\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "actions.delete",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/actions/act_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.actions().delete("ten_1", "env_1", "act_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "addons.list",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/addons",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.addons().list("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "addons.save",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/addons",
        .body = "{\"provider\":\"slack\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.addons().save("ten_1", "env_1", "{\"provider\":\"slack\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "addons.delete",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/addons/slack",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.addons().delete("ten_1", "env_1", "slack")).deinit();
            }
        }.f,
    },
    .{
        .name = "billing.listFeatures",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/billing/features",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.billing().listFeatures("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "billing.saveFeature",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/billing/features",
        .body = "{\"name\":\"pro\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.billing().saveFeature("ten_1", "env_1", "{\"name\":\"pro\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "billing.deleteFeature",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/billing/features/feat_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.billing().deleteFeature("ten_1", "env_1", "feat_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "billing.listPlans",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/billing/plans",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.billing().listPlans("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "billing.savePlan",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/billing/plans",
        .body = "{\"name\":\"pro\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.billing().savePlan("ten_1", "env_1", "{\"name\":\"pro\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "billing.deletePlan",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/billing/plans/plan_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.billing().deletePlan("ten_1", "env_1", "plan_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "billing.syncStripe",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/billing/plans/plan_1/sync-stripe",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.billing().syncStripe("ten_1", "env_1", "plan_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.getBotDetectionPolicy",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/bot-detection-policy",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().getBotDetectionPolicy("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.updateBotDetectionPolicy",
        .method = .PUT,
        .path = "/v1/tenants/ten_1/environments/env_1/bot-detection-policy",
        .body = "{\"enabled\":true}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().updateBotDetectionPolicy("ten_1", "env_1", "{\"enabled\":true}")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.getBreachedPasswordPolicy",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/breached-password-policy",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().getBreachedPasswordPolicy("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.updateBreachedPasswordPolicy",
        .method = .PUT,
        .path = "/v1/tenants/ten_1/environments/env_1/breached-password-policy",
        .body = "{\"enabled\":true}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().updateBreachedPasswordPolicy("ten_1", "env_1", "{\"enabled\":true}")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.getBruteForcePolicy",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/brute-force-policy",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().getBruteForcePolicy("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.updateBruteForcePolicy",
        .method = .PUT,
        .path = "/v1/tenants/ten_1/environments/env_1/brute-force-policy",
        .body = "{\"enabled\":true}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().updateBruteForcePolicy("ten_1", "env_1", "{\"enabled\":true}")).deinit();
            }
        }.f,
    },
    .{
        .name = "environments.saveConnection",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/connections",
        .body = "{\"provider\":\"okta\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.environments().saveConnection("ten_1", "env_1", "{\"provider\":\"okta\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "environments.resolveSamlMetadata",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/connections/resolve-saml-metadata",
        .body = "{\"url\":\"https://ex\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.environments().resolveSamlMetadata("ten_1", "env_1", "{\"url\":\"https://ex\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "environments.getSsoMetadata",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/connections/sso-metadata",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.environments().getSsoMetadata("ten_1", "env_1", &.{})).deinit();
            }
        }.f,
    },
    .{
        .name = "environments.deleteConnection",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/connections/con_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.environments().deleteConnection("ten_1", "env_1", "con_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.getDeviceRiskPolicy",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/device-risk-policy",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().getDeviceRiskPolicy("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.updateDeviceRiskPolicy",
        .method = .PUT,
        .path = "/v1/tenants/ten_1/environments/env_1/device-risk-policy",
        .body = "{\"enabled\":true}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().updateDeviceRiskPolicy("ten_1", "env_1", "{\"enabled\":true}")).deinit();
            }
        }.f,
    },
    .{
        .name = "elevate.activateGrant",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/elevate/access-grants/gr_1/activate",
        .body = "{\"reason\":\"x\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.elevate().activateGrant("ten_1", "env_1", "gr_1", "{\"reason\":\"x\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "elevate.revokeGrant",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/elevate/access-grants/gr_1/revoke",
        .body = "{\"reason\":\"x\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.elevate().revokeGrant("ten_1", "env_1", "gr_1", "{\"reason\":\"x\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "elevate.listRequests",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/elevate/access-requests",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.elevate().listRequests("ten_1", "env_1", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "elevate.createRequest",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/elevate/access-requests",
        .body = "{\"reason\":\"x\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.elevate().createRequest("ten_1", "env_1", "{\"reason\":\"x\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "elevate.getRequest",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/elevate/access-requests/req_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.elevate().getRequest("ten_1", "env_1", "req_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "elevate.approveRequest",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/elevate/access-requests/req_1/approve",
        .body = "{\"note\":\"ok\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.elevate().approveRequest("ten_1", "env_1", "req_1", "{\"note\":\"ok\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "elevate.cancelRequest",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/elevate/access-requests/req_1/cancel",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.elevate().cancelRequest("ten_1", "env_1", "req_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "elevate.denyRequest",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/elevate/access-requests/req_1/deny",
        .body = "{\"note\":\"no\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.elevate().denyRequest("ten_1", "env_1", "req_1", "{\"note\":\"no\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "elevate.getPolicy",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/elevate/policy",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.elevate().getPolicy("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "elevate.updatePolicy",
        .method = .PUT,
        .path = "/v1/tenants/ten_1/environments/env_1/elevate/policy",
        .body = "{\"enabled\":true}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.elevate().updatePolicy("ten_1", "env_1", "{\"enabled\":true}")).deinit();
            }
        }.f,
    },
    .{
        .name = "emailProviders.list",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/email-providers",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.emailProviders().list("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "emailProviders.save",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/email-providers",
        .body = "{\"provider\":\"ses\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.emailProviders().save("ten_1", "env_1", "{\"provider\":\"ses\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "emailProviders.test",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/email-providers/test",
        .body = "{\"to\":\"a@b.c\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.emailProviders().@"test"("ten_1", "env_1", "{\"to\":\"a@b.c\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "emailProviders.delete",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/email-providers/ses",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.emailProviders().delete("ten_1", "env_1", "ses")).deinit();
            }
        }.f,
    },
    .{
        .name = "emailProviders.activate",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/email-providers/ses/activate",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.emailProviders().activate("ten_1", "env_1", "ses")).deinit();
            }
        }.f,
    },
    .{
        .name = "featureFlags.list",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/feature-flags",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.featureFlags().list("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "featureFlags.save",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/feature-flags",
        .body = "{\"key\":\"x\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.featureFlags().save("ten_1", "env_1", "{\"key\":\"x\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "featureFlags.delete",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/feature-flags/flag_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.featureFlags().delete("ten_1", "env_1", "flag_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "forms.listAttachments",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/form-attachments",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.forms().listAttachments("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "forms.list",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/forms",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.forms().list("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "forms.save",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/forms",
        .body = "{\"name\":\"login\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.forms().save("ten_1", "env_1", "{\"name\":\"login\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "forms.delete",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/forms/form_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.forms().delete("ten_1", "env_1", "form_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "provisioningTokens.listHris",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/hris-tokens",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.provisioningTokens().listHris("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "provisioningTokens.createHris",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/hris-tokens",
        .body = "{\"name\":\"hr\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.provisioningTokens().createHris("ten_1", "env_1", "{\"name\":\"hr\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "provisioningTokens.revokeHris",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/hris-tokens/tok_1/revoke",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.provisioningTokens().revokeHris("ten_1", "env_1", "tok_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "provisioningTokens.rotateHris",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/hris-tokens/tok_1/rotate",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.provisioningTokens().rotateHris("ten_1", "env_1", "tok_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "impersonation.list",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/impersonation-grants",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.impersonation().list("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "impersonation.create",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/impersonation-grants",
        .body = "{\"userId\":\"usr_1\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.impersonation().create("ten_1", "env_1", "{\"userId\":\"usr_1\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "impersonation.revoke",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/impersonation-grants/gr_1/revoke",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.impersonation().revoke("ten_1", "env_1", "gr_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.listJwtClaimMappings",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/jwt-claim-mappings",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().listJwtClaimMappings("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.saveJwtClaimMapping",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/jwt-claim-mappings",
        .body = "{\"claim\":\"role\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().saveJwtClaimMapping("ten_1", "env_1", "{\"claim\":\"role\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.deleteJwtClaimMapping",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/jwt-claim-mappings/map_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().deleteJwtClaimMapping("ten_1", "env_1", "map_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "mcp.listEntries",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/mcp/trust-store",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.mcp().listEntries("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "mcp.createEntry",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/mcp/trust-store",
        .body = "{\"subject\":\"a\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.mcp().createEntry("ten_1", "env_1", "{\"subject\":\"a\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "mcp.getEntry",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.mcp().getEntry("ten_1", "env_1", "ent_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "mcp.updateEntry",
        .method = .PATCH,
        .path = "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1",
        .body = "{\"name\":\"n\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.mcp().updateEntry("ten_1", "env_1", "ent_1", "{\"name\":\"n\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "mcp.deleteEntry",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.mcp().deleteEntry("ten_1", "env_1", "ent_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "mcp.addKey",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/keys",
        .body = "{\"jwk\":{}}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.mcp().addKey("ten_1", "env_1", "ent_1", "{\"jwk\":{}}")).deinit();
            }
        }.f,
    },
    .{
        .name = "mcp.revokeKey",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/keys/key_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.mcp().revokeKey("ten_1", "env_1", "ent_1", "key_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "mcp.rotateKey",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/keys/key_1/rotate",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.mcp().rotateKey("ten_1", "env_1", "ent_1", "key_1", null)).deinit();
            }
        }.f,
    },
    .{
        .name = "mcp.revokeEntry",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/revoke",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.mcp().revokeEntry("ten_1", "env_1", "ent_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "mcp.verifyEntry",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/verify",
        .body = "{\"verified\":true}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.mcp().verifyEntry("ten_1", "env_1", "ent_1", "{\"verified\":true}")).deinit();
            }
        }.f,
    },
    .{
        .name = "users.totpStatus",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/me/mfa/totp",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.users().totpStatus("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.getPasswordPolicy",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/password-policy",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().getPasswordPolicy("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.updatePasswordPolicy",
        .method = .PUT,
        .path = "/v1/tenants/ten_1/environments/env_1/password-policy",
        .body = "{\"minLength\":8}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().updatePasswordPolicy("ten_1", "env_1", "{\"minLength\":8}")).deinit();
            }
        }.f,
    },
    .{
        .name = "portal.generateLink",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/portal/generate-link",
        .body = "{\"email\":\"a@b.c\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.portal().generateLink("ten_1", "env_1", "{\"email\":\"a@b.c\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.getRateLimitPolicy",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/rate-limit-policy",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().getRateLimitPolicy("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.updateRateLimitPolicy",
        .method = .PUT,
        .path = "/v1/tenants/ten_1/environments/env_1/rate-limit-policy",
        .body = "{\"limit\":10}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().updateRateLimitPolicy("ten_1", "env_1", "{\"limit\":10}")).deinit();
            }
        }.f,
    },
    .{
        .name = "environments.saveRedirectUris",
        .method = .PUT,
        .path = "/v1/tenants/ten_1/environments/env_1/redirect-uris",
        .body = "{\"uris\":[]}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.environments().saveRedirectUris("ten_1", "env_1", "{\"uris\":[]}")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.getRestrictions",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/restrictions",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().getRestrictions("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.updateRestrictions",
        .method = .PUT,
        .path = "/v1/tenants/ten_1/environments/env_1/restrictions",
        .body = "{\"signup\":false}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().updateRestrictions("ten_1", "env_1", "{\"signup\":false}")).deinit();
            }
        }.f,
    },
    .{
        .name = "provisioningTokens.listScim",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/scim-tokens",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.provisioningTokens().listScim("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "provisioningTokens.createScim",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/scim-tokens",
        .body = "{\"name\":\"scim\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.provisioningTokens().createScim("ten_1", "env_1", "{\"name\":\"scim\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "provisioningTokens.revokeScim",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/scim-tokens/tok_1/revoke",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.provisioningTokens().revokeScim("ten_1", "env_1", "tok_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "provisioningTokens.rotateScim",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/scim-tokens/tok_1/rotate",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.provisioningTokens().rotateScim("ten_1", "env_1", "tok_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "security.posture",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/security/posture",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.security().posture("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.getSessionConfig",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/session-config",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().getSessionConfig("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "settings.updateSessionConfig",
        .method = .PUT,
        .path = "/v1/tenants/ten_1/environments/env_1/session-config",
        .body = "{\"ttl\":3600}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.settings().updateSessionConfig("ten_1", "env_1", "{\"ttl\":3600}")).deinit();
            }
        }.f,
    },
    .{
        .name = "threats.list",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/threats",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.threats().list("ten_1", "env_1", &.{})).deinit();
            }
        }.f,
    },
    .{
        .name = "threats.create",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/threats",
        .body = "{\"type\":\"bot\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.threats().create("ten_1", "env_1", "{\"type\":\"bot\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "threats.get",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/threats/th_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.threats().get("ten_1", "env_1", "th_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "threats.update",
        .method = .PATCH,
        .path = "/v1/tenants/ten_1/environments/env_1/threats/th_1",
        .body = "{\"status\":\"open\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.threats().update("ten_1", "env_1", "th_1", "{\"status\":\"open\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "threats.delete",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/threats/th_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.threats().delete("ten_1", "env_1", "th_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "threats.resolve",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/threats/th_1/resolve",
        .body = "{\"status\":\"resolved\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.threats().resolve("ten_1", "env_1", "th_1", "{\"status\":\"resolved\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "users.bulkDelete",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/users/bulk/delete",
        .body = "{\"userIds\":[\"usr_1\"]}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.users().bulkDelete("ten_1", "env_1", "{\"userIds\":[\"usr_1\"]}")).deinit();
            }
        }.f,
    },
    .{
        .name = "users.bulkSetActive",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/users/bulk/set-active",
        .body = "{\"userIds\":[\"usr_1\"],\"active\":false}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.users().bulkSetActive("ten_1", "env_1", "{\"userIds\":[\"usr_1\"],\"active\":false}")).deinit();
            }
        }.f,
    },
    .{
        .name = "users.importUsers",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/users/import",
        .body = "{\"users\":[]}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.users().importUsers("ten_1", "env_1", "{\"users\":[]}")).deinit();
            }
        }.f,
    },
    .{
        .name = "users.disableMfa",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/users/usr_1/mfa",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.users().disableMfa("ten_1", "env_1", "usr_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "users.listSessions",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/users/usr_1/sessions",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.users().listSessions("ten_1", "env_1", "usr_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "vanityDomains.list",
        .method = .GET,
        .path = "/v1/tenants/ten_1/environments/env_1/vanity-domains",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.vanityDomains().list("ten_1", "env_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "vanityDomains.create",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/vanity-domains",
        .body = "{\"domain\":\"a.com\"}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.vanityDomains().create("ten_1", "env_1", "{\"domain\":\"a.com\"}")).deinit();
            }
        }.f,
    },
    .{
        .name = "vanityDomains.delete",
        .method = .DELETE,
        .path = "/v1/tenants/ten_1/environments/env_1/vanity-domains/dom_1",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.vanityDomains().delete("ten_1", "env_1", "dom_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "vanityDomains.check",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/vanity-domains/dom_1/check",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.vanityDomains().check("ten_1", "env_1", "dom_1")).deinit();
            }
        }.f,
    },
    .{
        .name = "widgets.createToken",
        .method = .POST,
        .path = "/v1/tenants/ten_1/environments/env_1/widgets/token",
        .body = "{\"ttl\":60}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.widgets().createToken("ten_1", "env_1", "{\"ttl\":60}")).deinit();
            }
        }.f,
    },
    .{
        .name = "otel.exportTraces",
        .method = .POST,
        .path = "/v1/traces",
        .body = "{\"resourceSpans\":[]}",
        .invoke = struct {
            fn f(c: *AuthdogClient) !void {
                (try c.otel().exportTraces("{\"resourceSpans\":[]}")).deinit();
            }
        }.f,
    },
};

test "wave3 method and path" {
    try std.testing.expectEqual(@as(usize, 152), wave3_cases.len);
    for (wave3_cases) |case| {
        const mock = try MockHttp.start(std.testing.allocator, .ok, case.response, case.expected_authorization);
        defer mock.deinit();

        var started = try startClient(mock, "key-1");
        defer std.testing.allocator.free(started.url);
        defer started.client.deinit();

        case.invoke(&started.client) catch |err| {
            std.debug.print("wave3 case {s} failed: {s} ({s})\n", .{
                case.name,
                @errorName(err),
                started.client.lastErrorMessage(),
            });
            return err;
        };

        try std.testing.expectEqual(case.method, mock.seen_method.?);
        try std.testing.expectEqualStrings(case.path, mock.seen_target.?);
        if (case.expected_authorization) |auth| {
            try std.testing.expectEqualStrings(auth, mock.seen_authorization.?);
        } else {
            try std.testing.expectEqual(@as(?[]u8, null), mock.seen_authorization);
        }
        if (case.body) |body| {
            try std.testing.expectEqualStrings(body, mock.seen_body.?);
        } else {
            try std.testing.expectEqual(@as(?[]u8, null), mock.seen_body);
        }
    }
}

test "wave3 authzen discovery omits bearer" {
    const mock = try MockHttp.start(std.testing.allocator, .ok, "{}", "Bearer key-1");
    defer mock.deinit();

    var started = try startClient(mock, "key-1");
    defer std.testing.allocator.free(started.url);
    defer started.client.deinit();

    const result = try started.client.authzen().configuration();
    defer result.deinit();
    try std.testing.expectEqualStrings("/.well-known/authzen-configuration", mock.seen_target.?);
    try std.testing.expectEqual(@as(?[]u8, null), mock.seen_authorization);
}

test "wave3 authzen evaluate uses environment secret" {
    const mock = try MockHttp.start(std.testing.allocator, .ok, "{\"decision\":\"Permit\"}", "Bearer adenv_secret");
    defer mock.deinit();

    var started = try startClientWith(mock, "key-1", .{ .environment_secret = "adenv_secret" });
    defer std.testing.allocator.free(started.url);
    defer started.client.deinit();

    const result = try started.client.authzen().evaluate("{\"subject\":{\"id\":\"u\"}}", null);
    defer result.deinit();
    try std.testing.expectEqualStrings("Permit", result.value.object.get("decision").?.string);
    try std.testing.expectEqualStrings("/access/v1/evaluation", mock.seen_target.?);
    try std.testing.expectEqualStrings("Bearer adenv_secret", mock.seen_authorization.?);
}

test "wave3 scim and hris use specialized tokens" {
    {
        const mock = try MockHttp.start(std.testing.allocator, .ok, "{}", "Bearer adscim_token");
        defer mock.deinit();

        var started = try startClientWith(mock, "key-1", .{ .scim_token = "adscim_token" });
        defer std.testing.allocator.free(started.url);
        defer started.client.deinit();

        const result = try started.client.scim().listUsers(null);
        defer result.deinit();
        try std.testing.expectEqualStrings("Bearer adscim_token", mock.seen_authorization.?);
    }

    {
        const mock = try MockHttp.start(std.testing.allocator, .ok, "{}", "Bearer adhris_token");
        defer mock.deinit();

        var started = try startClientWith(mock, "key-1", .{ .hris_token = "adhris_token" });
        defer std.testing.allocator.free(started.url);
        defer started.client.deinit();

        const result = try started.client.hris().listEmployees(null);
        defer result.deinit();
        try std.testing.expectEqualStrings("Bearer adhris_token", mock.seen_authorization.?);
    }
}

test "wave3 create scim token exposes one-time secret" {
    const mock = try MockHttp.start(
        std.testing.allocator,
        .ok,
        "{\"token\":\"adscim_once\",\"id\":\"tok_1\"}",
        "Bearer key-1",
    );
    defer mock.deinit();

    var started = try startClient(mock, "key-1");
    defer std.testing.allocator.free(started.url);
    defer started.client.deinit();

    const created = try started.client.provisioningTokens().createScim("ten_1", "env_1", "{\"name\":\"scim\"}");
    defer created.deinit();
    try std.testing.expectEqualStrings("adscim_once", created.value.object.get("token").?.string);
}

test "wave3 query params forwarded" {
    {
        const mock = try MockHttp.start(std.testing.allocator, .ok, "{}", "Bearer key-1");
        defer mock.deinit();

        var started = try startClient(mock, "key-1");
        defer std.testing.allocator.free(started.url);
        defer started.client.deinit();

        const resolved = try started.client.mcp().resolve("agent-1", null);
        defer resolved.deinit();
        try std.testing.expectEqualStrings("/v1/mcp/trust-store/resolve?subject=agent-1", mock.seen_target.?);
    }

    {
        const mock = try MockHttp.start(std.testing.allocator, .ok, "{}", "Bearer key-1");
        defer mock.deinit();

        var started = try startClient(mock, "key-1");
        defer std.testing.allocator.free(started.url);
        defer started.client.deinit();

        const listed = try started.client.threats().list("ten_1", "env_1", &.{
            .{ .name = "status", .value = "open" },
            .{ .name = "limit", .value = "10" },
        });
        defer listed.deinit();
        try std.testing.expectEqualStrings("/v1/tenants/ten_1/environments/env_1/threats?status=open&limit=10", mock.seen_target.?);
    }

    {
        const mock = try MockHttp.start(std.testing.allocator, .ok, "{}", "Bearer key-1");
        defer mock.deinit();

        var started = try startClient(mock, "key-1");
        defer std.testing.allocator.free(started.url);
        defer started.client.deinit();

        const listed = try started.client.elevate().listRequests("ten_1", "env_1", "pending");
        defer listed.deinit();
        try std.testing.expectEqualStrings("/v1/tenants/ten_1/environments/env_1/elevate/access-requests?status=pending", mock.seen_target.?);
    }
}
