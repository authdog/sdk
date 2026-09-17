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

    pub const QueryParam = struct {
        name: []const u8,
        value: ?[]const u8 = null,
    };

    const ExchangeOptions = struct {
        method: std.http.Method,
        path: []const u8,
        query: []const QueryParam = &.{},
        payload: ?[]const u8 = null,
        /// When set, Authorization is only this access token (user-info).
        access_token: ?[]const u8 = null,
        /// When true and `access_token` is null, send constructor `api_key` if present.
        use_api_key: bool = true,
    };

    const ExchangeResult = struct {
        status: u16,
        body: []u8,
    };

    const parse_json_message = "Failed to parse response: invalid JSON";

    fn writeQueryValue(writer: *std.Io.Writer, value: []const u8) std.Io.Writer.Error!void {
        const hex = "0123456789ABCDEF";
        for (value) |c| {
            switch (c) {
                'A'...'Z', 'a'...'z', '0'...'9', '-', '_', '.', '~' => try writer.writeByte(c),
                else => {
                    const buf = [_]u8{ '%', hex[c >> 4], hex[c & 0x0F] };
                    try writer.writeAll(&buf);
                },
            }
        }
    }

    fn buildUrl(self: *Self, path: []const u8, query: []const QueryParam) AuthdogError![]u8 {
        const trimmed = std.mem.trimEnd(u8, self.base_url, "/");
        var aw: std.Io.Writer.Allocating = .init(self.allocator);
        defer aw.deinit();

        aw.writer.print("{s}{s}", .{ trimmed, path }) catch {
            return self.fail(error.ApiError, errors.request_failed_message);
        };

        var first = true;
        for (query) |param| {
            const value = param.value orelse continue;
            aw.writer.writeByte(if (first) '?' else '&') catch {
                return self.fail(error.ApiError, errors.request_failed_message);
            };
            first = false;
            aw.writer.writeAll(param.name) catch {
                return self.fail(error.ApiError, errors.request_failed_message);
            };
            aw.writer.writeByte('=') catch {
                return self.fail(error.ApiError, errors.request_failed_message);
            };
            writeQueryValue(&aw.writer, value) catch {
                return self.fail(error.ApiError, errors.request_failed_message);
            };
        }

        return aw.toOwnedSlice() catch {
            return self.fail(error.ApiError, errors.request_failed_message);
        };
    }

    fn exchange(self: *Self, options: ExchangeOptions) AuthdogError!ExchangeResult {
        const url = try self.buildUrl(options.path, options.query);
        defer self.allocator.free(url);

        var authorization: ?[]u8 = null;
        defer if (authorization) |value| self.allocator.free(value);

        const auth_header: std.http.Client.Request.Headers.Value = blk: {
            if (options.access_token) |token| {
                authorization = std.fmt.allocPrint(self.allocator, "Bearer {s}", .{token}) catch {
                    return self.fail(error.ApiError, errors.request_failed_message);
                };
                break :blk .{ .override = authorization.? };
            }
            if (options.use_api_key) {
                if (self.api_key) |key| {
                    authorization = std.fmt.allocPrint(self.allocator, "Bearer {s}", .{key}) catch {
                        return self.fail(error.ApiError, errors.request_failed_message);
                    };
                    break :blk .{ .override = authorization.? };
                }
            }
            break :blk .omit;
        };

        var http_client = std.http.Client{
            .allocator = self.allocator,
            .io = self.io,
        };
        defer http_client.deinit();

        var body_writer: std.Io.Writer.Allocating = .init(self.allocator);
        defer body_writer.deinit();

        const payload: ?[]const u8 = options.payload orelse if (options.method.requestHasBody()) @as([]const u8, "") else null;

        const fetched = http_client.fetch(.{
            .location = .{ .url = url },
            .method = options.method,
            .payload = payload,
            .headers = .{
                .authorization = auth_header,
                .user_agent = .{ .override = user_agent },
                .content_type = .{ .override = "application/json" },
            },
            .response_writer = &body_writer.writer,
        }) catch return self.fail(error.ApiError, errors.request_failed_message);

        const body = body_writer.toOwnedSlice() catch {
            return self.fail(error.ApiError, errors.request_failed_message);
        };
        return .{
            .status = @intFromEnum(fetched.status),
            .body = body,
        };
    }

    /// Management JSON request: constructor `api_key` is sent as Bearer when present.
    pub fn request(
        self: *Self,
        method: std.http.Method,
        path: []const u8,
        query: []const QueryParam,
        payload: ?[]const u8,
    ) AuthdogError![]u8 {
        const result = try self.exchange(.{
            .method = method,
            .path = path,
            .query = query,
            .payload = payload,
            .use_api_key = true,
        });
        const body = result.body;

        if (result.status == 401) {
            defer self.allocator.free(body);
            return self.fail(error.AuthenticationFailed, errors.authentication_message);
        }
        if (result.status >= 400) {
            defer self.allocator.free(body);
            return self.failHttp(result.status, body);
        }
        if (body.len == 0) {
            self.allocator.free(body);
            return self.allocator.dupe(u8, "{}") catch {
                return self.fail(error.ApiError, errors.request_failed_message);
            };
        }
        return body;
    }

    fn requestValue(
        self: *Self,
        method: std.http.Method,
        path: []const u8,
        query: []const QueryParam,
        payload: ?[]const u8,
    ) AuthdogError!std.json.Parsed(std.json.Value) {
        const body = try self.request(method, path, query, payload);
        defer self.allocator.free(body);
        return std.json.parseFromSlice(std.json.Value, self.allocator, body, .{
            .ignore_unknown_fields = true,
            .allocate = .alloc_always,
        }) catch return self.fail(error.ApiError, parse_json_message);
    }

    fn requestParse(
        self: *Self,
        comptime T: type,
        comptime parseFn: fn (std.mem.Allocator, []const u8) anyerror!T,
        method: std.http.Method,
        path: []const u8,
        query: []const QueryParam,
        payload: ?[]const u8,
    ) AuthdogError!T {
        const body = try self.request(method, path, query, payload);
        defer self.allocator.free(body);
        return parseFn(self.allocator, body) catch {
            return self.fail(error.ApiError, parse_json_message);
        };
    }

    fn requestValuePath(
        self: *Self,
        method: std.http.Method,
        comptime path_fmt: []const u8,
        path_args: anytype,
        query: []const QueryParam,
        payload: ?[]const u8,
    ) AuthdogError!std.json.Parsed(std.json.Value) {
        const path = std.fmt.allocPrint(self.allocator, path_fmt, path_args) catch {
            return self.fail(error.ApiError, errors.request_failed_message);
        };
        defer self.allocator.free(path);
        return self.requestValue(method, path, query, payload);
    }

    fn requestParsePath(
        self: *Self,
        comptime T: type,
        comptime parseFn: fn (std.mem.Allocator, []const u8) anyerror!T,
        method: std.http.Method,
        comptime path_fmt: []const u8,
        path_args: anytype,
        query: []const QueryParam,
        payload: ?[]const u8,
    ) AuthdogError!T {
        const path = std.fmt.allocPrint(self.allocator, path_fmt, path_args) catch {
            return self.fail(error.ApiError, errors.request_failed_message);
        };
        defer self.allocator.free(path);
        return self.requestParse(T, parseFn, method, path, query, payload);
    }

    pub fn getUserInfo(self: *Self, access_token: []const u8) AuthdogError!UserInfoResponse {
        const result = try self.exchange(.{
            .method = .GET,
            .path = "/v1/userinfo",
            .access_token = access_token,
            .use_api_key = false,
        });
        defer self.allocator.free(result.body);

        switch (result.status) {
            200 => return types.parseUserInfo(self.allocator, result.body) catch {
                return self.fail(error.ParseError, errors.parse_message);
            },
            401 => return self.fail(error.AuthenticationFailed, errors.authentication_message),
            500 => {
                if (types.apiErrorString(self.allocator, result.body)) |known| {
                    return self.fail(error.ApiError, known);
                }
                return self.failFmt(error.ApiError, "HTTP error 500: {s}", .{result.body});
            },
            else => return self.failFmt(error.ApiError, "HTTP error {d}: {s}", .{ result.status, result.body }),
        }
    }

    pub fn health(self: *Self) AuthdogError!types.Probe {
        return self.requestParse(types.Probe, types.parseProbe, .GET, "/v1/health", &.{}, null);
    }

    pub fn organizations(self: *Self) OrganizationsResource {
        return .{ .client = self };
    }

    pub fn tenants(self: *Self) TenantsResource {
        return .{ .client = self };
    }

    pub fn projects(self: *Self) ProjectsResource {
        return .{ .client = self };
    }

    pub fn environments(self: *Self) EnvironmentsResource {
        return .{ .client = self };
    }

    pub fn users(self: *Self) UsersResource {
        return .{ .client = self };
    }

    pub fn groups(self: *Self) GroupsResource {
        return .{ .client = self };
    }

    pub fn rbac(self: *Self) RbacResource {
        return .{ .client = self };
    }

    pub fn audit(self: *Self) AuditResource {
        return .{ .client = self };
    }

    pub fn events(self: *Self) EventsResource {
        return .{ .client = self };
    }

    pub fn webhooks(self: *Self) WebhooksResource {
        return .{ .client = self };
    }

    pub fn notificationChannels(self: *Self) NotificationChannelsResource {
        return .{ .client = self };
    }

    pub fn serviceAccounts(self: *Self) ServiceAccountsResource {
        return .{ .client = self };
    }

    pub fn personalAccessTokens(self: *Self) PersonalAccessTokensResource {
        return .{ .client = self };
    }

    pub fn apiSecrets(self: *Self) ApiSecretsResource {
        return .{ .client = self };
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

    fn failHttp(self: *Self, status: u16, body: []const u8) AuthdogError {
        if (types.jsonErrorField(self.allocator, body)) |message| {
            defer self.allocator.free(message);
            return self.failFmt(error.ApiError, "HTTP error {d}: {s}", .{ status, message });
        }
        return self.failFmt(error.ApiError, "HTTP error {d}: {s}", .{ status, body });
    }
};

pub const OrganizationsResource = struct {
    client: *AuthdogClient,

    pub fn list(self: @This()) AuthdogError!types.OrganizationsList {
        return self.client.requestParse(types.OrganizationsList, types.parseOrganizationsList, .GET, "/v1/organizations", &.{}, null);
    }

    pub fn create(self: @This(), body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValue(.POST, "/v1/organizations", &.{}, body);
    }

    pub fn get(self: @This(), organization_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/organizations/{s}", .{organization_id}, &.{}, null);
    }

    pub fn update(self: @This(), organization_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.PATCH, "/v1/organizations/{s}", .{organization_id}, &.{}, body);
    }

    pub fn delete(self: @This(), organization_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/organizations/{s}", .{organization_id}, &.{}, null);
    }

    pub fn acceptInvitation(self: @This(), body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValue(.POST, "/v1/organizations/invitations/accept", &.{}, body);
    }

    pub fn join(self: @This(), body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValue(.POST, "/v1/organizations/join", &.{}, body);
    }

    pub fn listInvitations(self: @This(), organization_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/organizations/{s}/invitations", .{organization_id}, &.{}, null);
    }

    pub fn createInvitation(self: @This(), organization_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/organizations/{s}/invitations", .{organization_id}, &.{}, body);
    }

    pub fn cancelInvitation(self: @This(), organization_id: []const u8, invitation_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/organizations/{s}/invitations/{s}/cancel", .{ organization_id, invitation_id }, &.{}, null);
    }

    pub fn sendInvite(self: @This(), organization_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/organizations/{s}/invites", .{organization_id}, &.{}, body);
    }

    pub fn listMembers(self: @This(), organization_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/organizations/{s}/members", .{organization_id}, &.{}, null);
    }

    pub fn removeMember(self: @This(), organization_id: []const u8, member_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/organizations/{s}/members/{s}", .{ organization_id, member_id }, &.{}, null);
    }

    pub fn setMemberActive(self: @This(), organization_id: []const u8, member_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.PATCH, "/v1/organizations/{s}/members/{s}/active", .{ organization_id, member_id }, &.{}, body);
    }

    pub fn linkTenant(self: @This(), organization_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/organizations/{s}/tenants", .{organization_id}, &.{}, body);
    }

    pub fn unlinkTenant(self: @This(), organization_id: []const u8, tenant_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/organizations/{s}/tenants/{s}", .{ organization_id, tenant_id }, &.{}, null);
    }

    pub fn listKeys(self: @This(), organization_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/organizations/{s}/keys", .{organization_id}, &.{}, null);
    }

    pub fn createKey(self: @This(), organization_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/organizations/{s}/keys", .{organization_id}, &.{}, body);
    }

    pub fn revokeKey(self: @This(), organization_id: []const u8, key_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/organizations/{s}/keys/{s}/revoke", .{ organization_id, key_id }, &.{}, null);
    }

    pub fn rotateKey(self: @This(), organization_id: []const u8, key_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/organizations/{s}/keys/{s}/rotate", .{ organization_id, key_id }, &.{}, null);
    }

    pub fn updateKeyTenants(self: @This(), organization_id: []const u8, key_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.PUT, "/v1/organizations/{s}/keys/{s}/tenants", .{ organization_id, key_id }, &.{}, body);
    }

    pub fn listAuditLogs(self: @This(), organization_id: []const u8, query: []const AuthdogClient.QueryParam) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/organizations/{s}/audit/logs", .{organization_id}, query, null);
    }
};

pub const TenantsResource = struct {
    client: *AuthdogClient,

    pub const ListOptions = struct {
        organization_id: ?[]const u8 = null,
    };

    pub fn list(self: @This(), options: ListOptions) AuthdogError!types.TenantsList {
        const query = [_]AuthdogClient.QueryParam{.{
            .name = "organization_id",
            .value = options.organization_id,
        }};
        return self.client.requestParse(types.TenantsList, types.parseTenantsList, .GET, "/v1/tenants", &query, null);
    }

    pub fn create(self: @This(), body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValue(.POST, "/v1/tenants", &.{}, body);
    }

    pub fn join(self: @This(), body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValue(.POST, "/v1/tenants/join", &.{}, body);
    }

    pub const GetOptions = struct {
        organization_id: ?[]const u8 = null,
    };

    pub fn get(self: @This(), tenant_id: []const u8, options: GetOptions) AuthdogError!std.json.Parsed(std.json.Value) {
        const query = [_]AuthdogClient.QueryParam{.{
            .name = "organization_id",
            .value = options.organization_id,
        }};
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}", .{tenant_id}, &query, null);
    }

    pub fn update(self: @This(), tenant_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.PATCH, "/v1/tenants/{s}", .{tenant_id}, &.{}, body);
    }

    pub fn delete(self: @This(), tenant_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}", .{tenant_id}, &.{}, null);
    }

    pub fn listDomains(self: @This(), tenant_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/domains", .{tenant_id}, &.{}, null);
    }

    pub fn createDomain(self: @This(), tenant_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/domains", .{tenant_id}, &.{}, body);
    }

    pub fn deleteDomain(self: @This(), tenant_id: []const u8, domain_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/domains/{s}", .{ tenant_id, domain_id }, &.{}, null);
    }

    pub fn retryDomain(self: @This(), tenant_id: []const u8, domain_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/domains/{s}/retry", .{ tenant_id, domain_id }, &.{}, null);
    }

    pub fn sendInvite(self: @This(), tenant_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/invites", .{tenant_id}, &.{}, body);
    }

    pub fn listProjects(self: @This(), tenant_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/projects", .{tenant_id}, &.{}, null);
    }

    pub fn listSeats(self: @This(), tenant_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/seats", .{tenant_id}, &.{}, null);
    }

    pub fn updateSeat(self: @This(), tenant_id: []const u8, seat_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.PATCH, "/v1/tenants/{s}/seats/{s}", .{ tenant_id, seat_id }, &.{}, body);
    }

    pub fn deleteSeat(self: @This(), tenant_id: []const u8, seat_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/seats/{s}", .{ tenant_id, seat_id }, &.{}, null);
    }
};

pub const ProjectsResource = struct {
    client: *AuthdogClient,

    pub fn save(self: @This(), tenant_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/applications", .{tenant_id}, &.{}, body);
    }

    pub fn get(self: @This(), tenant_id: []const u8, application_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/applications/{s}", .{ tenant_id, application_id }, &.{}, null);
    }

    pub fn delete(self: @This(), tenant_id: []const u8, application_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/applications/{s}", .{ tenant_id, application_id }, &.{}, null);
    }

    pub fn setDefaultEnvironment(self: @This(), tenant_id: []const u8, application_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.PUT, "/v1/tenants/{s}/applications/{s}/default-environment", .{ tenant_id, application_id }, &.{}, body);
    }
};

pub const EnvironmentsResource = struct {
    client: *AuthdogClient,

    pub fn list(self: @This(), tenant_id: []const u8, application_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/applications/{s}/environments", .{ tenant_id, application_id }, &.{}, null);
    }

    pub fn create(self: @This(), tenant_id: []const u8, application_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/applications/{s}/environments", .{ tenant_id, application_id }, &.{}, body);
    }

    pub fn update(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.PATCH, "/v1/tenants/{s}/environments/{s}", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn delete(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}", .{ tenant_id, environment_id }, &.{}, null);
    }
};

pub const UsersResource = struct {
    client: *AuthdogClient,

    pub const ListOptions = struct {
        offset: ?i64 = null,
        limit: ?i64 = null,
        search_query: ?[]const u8 = null,
    };

    pub fn list(
        self: @This(),
        tenant_id: []const u8,
        environment_id: []const u8,
        options: ListOptions,
    ) AuthdogError!types.EnvUsersResponse {
        var offset_buf: [32]u8 = undefined;
        var limit_buf: [32]u8 = undefined;
        var params: [3]AuthdogClient.QueryParam = undefined;
        var n: usize = 0;
        if (options.offset) |value| {
            params[n] = .{
                .name = "offset",
                .value = std.fmt.bufPrint(&offset_buf, "{d}", .{value}) catch {
                    return self.client.fail(error.ApiError, errors.request_failed_message);
                },
            };
            n += 1;
        }
        if (options.limit) |value| {
            params[n] = .{
                .name = "limit",
                .value = std.fmt.bufPrint(&limit_buf, "{d}", .{value}) catch {
                    return self.client.fail(error.ApiError, errors.request_failed_message);
                },
            };
            n += 1;
        }
        if (options.search_query) |value| {
            params[n] = .{ .name = "searchQuery", .value = value };
            n += 1;
        }
        return self.client.requestParsePath(
            types.EnvUsersResponse,
            types.parseEnvUsersResponse,
            .GET,
            "/v1/tenants/{s}/environments/{s}/users",
            .{ tenant_id, environment_id },
            params[0..n],
            null,
        );
    }

    pub fn create(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/users", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub const SearchOptions = struct {
        q: ?[]const u8 = null,
        offset: ?i64 = null,
        limit: ?i64 = null,
    };

    pub fn search(
        self: @This(),
        tenant_id: []const u8,
        environment_id: []const u8,
        options: SearchOptions,
    ) AuthdogError!types.EnvUsersResponse {
        var offset_buf: [32]u8 = undefined;
        var limit_buf: [32]u8 = undefined;
        var params: [3]AuthdogClient.QueryParam = undefined;
        var n: usize = 0;
        if (options.q) |value| {
            params[n] = .{ .name = "q", .value = value };
            n += 1;
        }
        if (options.offset) |value| {
            params[n] = .{
                .name = "offset",
                .value = std.fmt.bufPrint(&offset_buf, "{d}", .{value}) catch {
                    return self.client.fail(error.ApiError, errors.request_failed_message);
                },
            };
            n += 1;
        }
        if (options.limit) |value| {
            params[n] = .{
                .name = "limit",
                .value = std.fmt.bufPrint(&limit_buf, "{d}", .{value}) catch {
                    return self.client.fail(error.ApiError, errors.request_failed_message);
                },
            };
            n += 1;
        }
        return self.client.requestParsePath(
            types.EnvUsersResponse,
            types.parseEnvUsersResponse,
            .GET,
            "/v1/tenants/{s}/environments/{s}/users/search",
            .{ tenant_id, environment_id },
            params[0..n],
            null,
        );
    }

    pub fn count(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/users/count", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn get(self: @This(), tenant_id: []const u8, environment_id: []const u8, user_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/users/{s}", .{ tenant_id, environment_id, user_id }, &.{}, null);
    }

    pub fn update(self: @This(), tenant_id: []const u8, environment_id: []const u8, user_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.PUT, "/v1/tenants/{s}/environments/{s}/users/{s}", .{ tenant_id, environment_id, user_id }, &.{}, body);
    }

    pub fn delete(self: @This(), tenant_id: []const u8, environment_id: []const u8, user_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/users/{s}", .{ tenant_id, environment_id, user_id }, &.{}, null);
    }

    pub fn setActive(self: @This(), tenant_id: []const u8, environment_id: []const u8, user_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.PATCH, "/v1/tenants/{s}/environments/{s}/users/{s}/active", .{ tenant_id, environment_id, user_id }, &.{}, body);
    }

    pub fn listGroups(self: @This(), tenant_id: []const u8, environment_id: []const u8, user_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/users/{s}/groups", .{ tenant_id, environment_id, user_id }, &.{}, null);
    }
};

pub const GroupsResource = struct {
    client: *AuthdogClient,

    pub fn create(self: @This(), body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValue(.POST, "/v1/groups", &.{}, body);
    }

    pub fn list(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!types.EnvGroupsResponse {
        return self.client.requestParsePath(
            types.EnvGroupsResponse,
            types.parseEnvGroupsResponse,
            .GET,
            "/v1/tenants/{s}/environments/{s}/groups",
            .{ tenant_id, environment_id },
            &.{},
            null,
        );
    }

    pub fn delete(self: @This(), tenant_id: []const u8, environment_id: []const u8, group_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/groups/{s}", .{ tenant_id, environment_id, group_id }, &.{}, null);
    }

    pub fn listMembers(self: @This(), tenant_id: []const u8, environment_id: []const u8, group_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/groups/{s}/members", .{ tenant_id, environment_id, group_id }, &.{}, null);
    }

    pub fn addMember(self: @This(), tenant_id: []const u8, environment_id: []const u8, group_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/groups/{s}/members", .{ tenant_id, environment_id, group_id }, &.{}, body);
    }

    pub fn removeMember(self: @This(), tenant_id: []const u8, environment_id: []const u8, group_id: []const u8, user_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/groups/{s}/members/{s}", .{ tenant_id, environment_id, group_id, user_id }, &.{}, null);
    }
};

pub const RbacResource = struct {
    client: *AuthdogClient,

    pub fn listRoles(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/roles", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn createRole(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/roles", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn deleteRole(self: @This(), tenant_id: []const u8, environment_id: []const u8, role_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/roles/{s}", .{ tenant_id, environment_id, role_id }, &.{}, null);
    }

    pub fn listRolePermissions(self: @This(), tenant_id: []const u8, environment_id: []const u8, role_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/roles/{s}/permissions", .{ tenant_id, environment_id, role_id }, &.{}, null);
    }

    pub fn setRolePermissions(self: @This(), tenant_id: []const u8, environment_id: []const u8, role_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.PUT, "/v1/tenants/{s}/environments/{s}/roles/{s}/permissions", .{ tenant_id, environment_id, role_id }, &.{}, body);
    }

    pub fn listPermissions(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/permissions", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn createPermission(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/permissions", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn deletePermission(self: @This(), tenant_id: []const u8, environment_id: []const u8, permission_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/permissions/{s}", .{ tenant_id, environment_id, permission_id }, &.{}, null);
    }

    pub fn listResources(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/resources", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn createResource(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/resources", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn deleteResource(self: @This(), tenant_id: []const u8, environment_id: []const u8, resource_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/resources/{s}", .{ tenant_id, environment_id, resource_id }, &.{}, null);
    }

    pub fn listGroupRoles(self: @This(), tenant_id: []const u8, environment_id: []const u8, group_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/groups/{s}/roles", .{ tenant_id, environment_id, group_id }, &.{}, null);
    }

    pub fn addGroupRole(self: @This(), tenant_id: []const u8, environment_id: []const u8, group_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/groups/{s}/roles", .{ tenant_id, environment_id, group_id }, &.{}, body);
    }

    pub fn removeGroupRole(self: @This(), tenant_id: []const u8, environment_id: []const u8, group_id: []const u8, role_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/groups/{s}/roles/{s}", .{ tenant_id, environment_id, group_id, role_id }, &.{}, null);
    }

    pub fn listGroupRoleMappings(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/group-role-mappings", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn createGroupRoleMapping(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/group-role-mappings", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn applyGroupRoleMappings(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/group-role-mappings/apply", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn deleteGroupRoleMapping(self: @This(), tenant_id: []const u8, environment_id: []const u8, mapping_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/group-role-mappings/{s}", .{ tenant_id, environment_id, mapping_id }, &.{}, null);
    }

    pub fn listAbacPolicies(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/abac-policies", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn saveAbacPolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/abac-policies", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn validateAbacPolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/abac-policies/validate", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn deleteAbacPolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8, policy_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/abac-policies/{s}", .{ tenant_id, environment_id, policy_id }, &.{}, null);
    }

    pub fn myPermissions(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/me/permissions", .{ tenant_id, environment_id }, &.{}, null);
    }
};

pub const AuditResource = struct {
    client: *AuthdogClient,

    pub fn listLogs(self: @This(), tenant_id: []const u8, environment_id: []const u8, query: []const AuthdogClient.QueryParam) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/audit/logs", .{ tenant_id, environment_id }, query, null);
    }

    pub fn eventMetadata(self: @This(), tenant_id: []const u8, environment_id: []const u8, query: []const AuthdogClient.QueryParam) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/audit/event-metadata", .{ tenant_id, environment_id }, query, null);
    }

    pub fn eventTypes(self: @This(), tenant_id: []const u8, environment_id: []const u8, query: []const AuthdogClient.QueryParam) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/audit/event-types", .{ tenant_id, environment_id }, query, null);
    }

    pub fn eventTypesCatalog(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/audit/event-types/catalog", .{ tenant_id, environment_id }, &.{}, null);
    }
};

pub const EventsResource = struct {
    client: *AuthdogClient,

    pub fn list(self: @This(), tenant_id: []const u8, environment_id: []const u8, query: []const AuthdogClient.QueryParam) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/events", .{ tenant_id, environment_id }, query, null);
    }

    pub fn listTypes(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/events/types", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn ingest(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/events/ingest", .{ tenant_id, environment_id }, &.{}, body);
    }
};

pub const WebhooksResource = struct {
    client: *AuthdogClient,

    pub fn list(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/webhooks", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn create(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/webhooks", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn update(self: @This(), tenant_id: []const u8, environment_id: []const u8, channel_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.PUT, "/v1/tenants/{s}/environments/{s}/webhooks/{s}", .{ tenant_id, environment_id, channel_id }, &.{}, body);
    }

    pub fn delete(self: @This(), tenant_id: []const u8, environment_id: []const u8, channel_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/webhooks/{s}", .{ tenant_id, environment_id, channel_id }, &.{}, null);
    }

    pub fn rotateSecret(self: @This(), tenant_id: []const u8, environment_id: []const u8, channel_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/webhooks/{s}/rotate-secret", .{ tenant_id, environment_id, channel_id }, &.{}, null);
    }

    pub fn listDeliveries(self: @This(), tenant_id: []const u8, environment_id: []const u8, query: []const AuthdogClient.QueryParam) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/webhooks/deliveries", .{ tenant_id, environment_id }, query, null);
    }

    pub fn redeliver(self: @This(), tenant_id: []const u8, environment_id: []const u8, delivery_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/webhooks/deliveries/{s}/redeliver", .{ tenant_id, environment_id, delivery_id }, &.{}, null);
    }
};

pub const NotificationChannelsResource = struct {
    client: *AuthdogClient,

    pub fn list(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/notification-channels", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn create(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/notification-channels", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn update(self: @This(), tenant_id: []const u8, environment_id: []const u8, channel_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.PUT, "/v1/tenants/{s}/environments/{s}/notification-channels/{s}", .{ tenant_id, environment_id, channel_id }, &.{}, body);
    }

    pub fn delete(self: @This(), tenant_id: []const u8, environment_id: []const u8, channel_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/notification-channels/{s}", .{ tenant_id, environment_id, channel_id }, &.{}, null);
    }

    pub fn @"test"(self: @This(), tenant_id: []const u8, environment_id: []const u8, channel_id: []const u8, body: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/notification-channels/{s}/test", .{ tenant_id, environment_id, channel_id }, &.{}, body);
    }
};

pub const ServiceAccountsResource = struct {
    client: *AuthdogClient,

    pub fn list(self: @This()) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValue(.GET, "/v1/service-accounts", &.{}, null);
    }

    pub fn create(self: @This(), body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValue(.POST, "/v1/service-accounts", &.{}, body);
    }

    pub fn get(self: @This(), service_account_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/service-accounts/{s}", .{service_account_id}, &.{}, null);
    }

    pub fn delete(self: @This(), service_account_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/service-accounts/{s}", .{service_account_id}, &.{}, null);
    }
};

pub const PersonalAccessTokensResource = struct {
    client: *AuthdogClient,

    pub fn list(self: @This()) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValue(.GET, "/v1/personal-access-tokens", &.{}, null);
    }

    pub fn create(self: @This(), body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValue(.POST, "/v1/personal-access-tokens", &.{}, body);
    }

    pub fn revoke(self: @This(), token_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/personal-access-tokens/{s}/revoke", .{token_id}, &.{}, null);
    }
};

pub const ApiSecretsResource = struct {
    client: *AuthdogClient,

    pub fn list(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/api-secrets", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn create(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/api-secrets", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn revoke(self: @This(), tenant_id: []const u8, environment_id: []const u8, secret_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/api-secrets/{s}/revoke", .{ tenant_id, environment_id, secret_id }, &.{}, null);
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

pub const MockHttp = struct {
    allocator: std.mem.Allocator,
    io_impl: *std.Io.Threaded,
    server: std.Io.net.Server,
    port: u16,
    status: std.http.Status,
    body: []const u8,
    expected_authorization: ?[]const u8,
    seen_authorization: ?[]u8 = null,
    seen_method: ?std.http.Method = null,
    seen_target: ?[]u8 = null,
    seen_body: ?[]u8 = null,
    thread: std.Thread,

    pub fn start(
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

    pub fn baseUrl(self: *MockHttp) ![]u8 {
        return std.fmt.allocPrint(self.allocator, "http://127.0.0.1:{d}", .{self.port});
    }

    pub fn deinit(self: *MockHttp) void {
        self.thread.join();
        const io = self.io_impl.io();
        self.server.deinit(io);
        self.io_impl.deinit();
        self.allocator.destroy(self.io_impl);
        if (self.seen_authorization) |value| self.allocator.free(value);
        if (self.seen_target) |value| self.allocator.free(value);
        if (self.seen_body) |value| self.allocator.free(value);
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

        self.seen_method = request.head.method;
        self.seen_target = self.allocator.dupe(u8, request.head.target) catch null;

        var headers = request.iterateHeaders();
        while (headers.next()) |header| {
            if (std.ascii.eqlIgnoreCase(header.name, "authorization")) {
                self.seen_authorization = self.allocator.dupe(u8, header.value) catch null;
            }
        }

        if (request.head.method.requestHasBody() and (request.head.content_length orelse 0) > 0) {
            var read_buf: [4096]u8 = undefined;
            const body_reader = request.readerExpectNone(&read_buf);
            self.seen_body = body_reader.allocRemaining(self.allocator, .unlimited) catch null;
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

test "health is public and returns probe" {
    const mock = try MockHttp.start(std.testing.allocator, .ok, "{\"ok\":true}", null);
    defer mock.deinit();

    const base_url = try mock.baseUrl();
    defer std.testing.allocator.free(base_url);

    var client = try expectClient(std.testing.allocator, base_url, null);
    defer client.deinit();

    const probe = try client.health();
    try std.testing.expect(probe.ok);
    try std.testing.expectEqual(std.http.Method.GET, mock.seen_method.?);
    try std.testing.expectEqualStrings("/v1/health", mock.seen_target.?);
    try std.testing.expectEqual(@as(?[]u8, null), mock.seen_authorization);
}

test "health sends constructor api key when present" {
    const mock = try MockHttp.start(std.testing.allocator, .ok, "{\"ok\":true}", "Bearer key-1");
    defer mock.deinit();

    const base_url = try mock.baseUrl();
    defer std.testing.allocator.free(base_url);

    var client = try expectClient(std.testing.allocator, base_url, "key-1");
    defer client.deinit();

    const probe = try client.health();
    try std.testing.expect(probe.ok);
    try std.testing.expectEqualStrings("Bearer key-1", mock.seen_authorization.?);
}

test "management 401 maps to authentication error" {
    const mock = try MockHttp.start(std.testing.allocator, .unauthorized, "Unauthorized", null);
    defer mock.deinit();

    const base_url = try mock.baseUrl();
    defer std.testing.allocator.free(base_url);

    var client = try expectClient(std.testing.allocator, base_url, "key-1");
    defer client.deinit();

    try std.testing.expectError(error.AuthenticationFailed, client.organizations().list());
    try std.testing.expectEqualStrings(errors.authentication_message, client.lastErrorMessage());
}
