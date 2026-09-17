const std = @import("std");
const client_mod = @import("client.zig");
const errors = @import("error.zig");

const AuthdogClient = client_mod.AuthdogClient;
const MockHttp = client_mod.MockHttp;

fn startClient(mock: *MockHttp, api_key: ?[]const u8) !struct { url: []u8, client: AuthdogClient } {
    const url = try mock.baseUrl();
    errdefer std.testing.allocator.free(url);
    const client = try AuthdogClient.init(std.testing.allocator, .{
        .base_url = url,
        .api_key = api_key,
    });
    return .{ .url = url, .client = client };
}

const Wave1Case = struct {
    name: []const u8,
    method: std.http.Method,
    path: []const u8,
    body: ?[]const u8 = null,
    response: []const u8 = "{}",
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
