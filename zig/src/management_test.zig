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
