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
    /// Optional `adenv_` secret for AuthZEN evaluate/search and MCP runtime.
    environment_secret: ?[]const u8 = null,
    /// Optional `adscim_` token for `/v1/scim/v2`.
    scim_token: ?[]const u8 = null,
    /// Optional `adhris_` token for `/v1/hris/v1`.
    hris_token: ?[]const u8 = null,
    /// Optional caller-owned I/O implementation. When omitted, the client
    /// creates and owns a threaded I/O runtime.
    io: ?std.Io = null,
};

pub const AuthdogClient = struct {
    allocator: std.mem.Allocator,
    base_url: []u8,
    api_key: ?[]u8,
    environment_secret: ?[]u8,
    scim_token: ?[]u8,
    hris_token: ?[]u8,
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

        const environment_secret = if (config.environment_secret) |value| try allocator.dupe(u8, value) else null;
        errdefer if (environment_secret) |value| allocator.free(value);

        const scim_token = if (config.scim_token) |value| try allocator.dupe(u8, value) else null;
        errdefer if (scim_token) |value| allocator.free(value);

        const hris_token = if (config.hris_token) |value| try allocator.dupe(u8, value) else null;
        errdefer if (hris_token) |value| allocator.free(value);

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
            .environment_secret = environment_secret,
            .scim_token = scim_token,
            .hris_token = hris_token,
            .timeout_ms = config.timeout_ms,
            .owned_io = owned_io,
            .io = io,
            .last_error_message = null,
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.base_url);
        if (self.api_key) |key| self.allocator.free(key);
        if (self.environment_secret) |value| self.allocator.free(value);
        if (self.scim_token) |value| self.allocator.free(value);
        if (self.hris_token) |value| self.allocator.free(value);
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

    pub const RequestAuth = struct {
        /// When set, Authorization is this Bearer token (wins over `api_key`).
        access_token: ?[]const u8 = null,
        /// When true and `access_token` is null, send constructor `api_key` if present.
        use_api_key: bool = true,
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
        return self.requestAuth(method, path, query, payload, .{});
    }

    /// Management JSON request with explicit Authorization routing.
    pub fn requestAuth(
        self: *Self,
        method: std.http.Method,
        path: []const u8,
        query: []const QueryParam,
        payload: ?[]const u8,
        auth: RequestAuth,
    ) AuthdogError![]u8 {
        const result = try self.exchange(.{
            .method = method,
            .path = path,
            .query = query,
            .payload = payload,
            .access_token = auth.access_token,
            .use_api_key = auth.use_api_key,
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
        return self.requestValueAuth(method, path, query, payload, .{});
    }

    fn requestValueAuth(
        self: *Self,
        method: std.http.Method,
        path: []const u8,
        query: []const QueryParam,
        payload: ?[]const u8,
        auth: RequestAuth,
    ) AuthdogError!std.json.Parsed(std.json.Value) {
        const body = try self.requestAuth(method, path, query, payload, auth);
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
        return self.requestValuePathAuth(method, path_fmt, path_args, query, payload, .{});
    }

    fn requestValuePathAuth(
        self: *Self,
        method: std.http.Method,
        comptime path_fmt: []const u8,
        path_args: anytype,
        query: []const QueryParam,
        payload: ?[]const u8,
        auth: RequestAuth,
    ) AuthdogError!std.json.Parsed(std.json.Value) {
        const path = std.fmt.allocPrint(self.allocator, path_fmt, path_args) catch {
            return self.fail(error.ApiError, errors.request_failed_message);
        };
        defer self.allocator.free(path);
        return self.requestValueAuth(method, path, query, payload, auth);
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

    pub fn authzen(self: *Self) AuthzenResource {
        return .{ .client = self };
    }

    pub fn scim(self: *Self) ScimResource {
        return .{ .client = self };
    }

    pub fn hris(self: *Self) HrisResource {
        return .{ .client = self };
    }

    pub fn mcp(self: *Self) McpResource {
        return .{ .client = self };
    }

    pub fn otel(self: *Self) OtelResource {
        return .{ .client = self };
    }

    pub fn oidcClients(self: *Self) OidcClientsResource {
        return .{ .client = self };
    }

    pub fn actions(self: *Self) ActionsResource {
        return .{ .client = self };
    }

    pub fn addons(self: *Self) AddonsResource {
        return .{ .client = self };
    }

    pub fn billing(self: *Self) BillingResource {
        return .{ .client = self };
    }

    pub fn settings(self: *Self) SettingsResource {
        return .{ .client = self };
    }

    pub fn elevate(self: *Self) ElevateResource {
        return .{ .client = self };
    }

    pub fn emailProviders(self: *Self) EmailProvidersResource {
        return .{ .client = self };
    }

    pub fn featureFlags(self: *Self) FeatureFlagsResource {
        return .{ .client = self };
    }

    pub fn forms(self: *Self) FormsResource {
        return .{ .client = self };
    }

    pub fn provisioningTokens(self: *Self) ProvisioningTokensResource {
        return .{ .client = self };
    }

    pub fn impersonation(self: *Self) ImpersonationResource {
        return .{ .client = self };
    }

    pub fn portal(self: *Self) PortalResource {
        return .{ .client = self };
    }

    pub fn security(self: *Self) SecurityResource {
        return .{ .client = self };
    }

    pub fn threats(self: *Self) ThreatsResource {
        return .{ .client = self };
    }

    pub fn vanityDomains(self: *Self) VanityDomainsResource {
        return .{ .client = self };
    }

    pub fn widgets(self: *Self) WidgetsResource {
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

    pub fn listConnections(self: @This(), tenant_id: []const u8, application_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/applications/{s}/environments/{s}/connections", .{ tenant_id, application_id, environment_id }, &.{}, null);
    }

    pub fn listRedirectUris(self: @This(), tenant_id: []const u8, application_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/applications/{s}/environments/{s}/redirect-uris", .{ tenant_id, application_id, environment_id }, &.{}, null);
    }

    pub fn saveConnection(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/connections", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn resolveSamlMetadata(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/connections/resolve-saml-metadata", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn getSsoMetadata(self: @This(), tenant_id: []const u8, environment_id: []const u8, query: []const AuthdogClient.QueryParam) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/connections/sso-metadata", .{ tenant_id, environment_id }, query, null);
    }

    pub fn deleteConnection(self: @This(), tenant_id: []const u8, environment_id: []const u8, connection_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/connections/{s}", .{ tenant_id, environment_id, connection_id }, &.{}, null);
    }

    pub fn saveRedirectUris(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.PUT, "/v1/tenants/{s}/environments/{s}/redirect-uris", .{ tenant_id, environment_id }, &.{}, body);
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

    pub fn revokeSession(self: @This(), environment_id: []const u8, session_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/environments/{s}/sessions/{s}", .{ environment_id, session_id }, &.{}, null);
    }

    pub fn totpStatus(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/me/mfa/totp", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn bulkDelete(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/users/bulk/delete", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn bulkSetActive(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/users/bulk/set-active", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn importUsers(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/users/import", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn disableMfa(self: @This(), tenant_id: []const u8, environment_id: []const u8, user_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/users/{s}/mfa", .{ tenant_id, environment_id, user_id }, &.{}, null);
    }

    pub fn listSessions(self: @This(), tenant_id: []const u8, environment_id: []const u8, user_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/users/{s}/sessions", .{ tenant_id, environment_id, user_id }, &.{}, null);
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

fn tokenOr(override: ?[]const u8, stored: ?[]const u8) ?[]const u8 {
    return override orelse stored;
}

fn specializedAuth(override: ?[]const u8, stored: ?[]const u8) AuthdogClient.RequestAuth {
    return .{
        .access_token = tokenOr(override, stored),
        .use_api_key = tokenOr(override, stored) == null,
    };
}

pub const AuthzenResource = struct {
    client: *AuthdogClient,

    pub fn configuration(self: @This()) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.GET, "/.well-known/authzen-configuration", &.{}, null, .{
            .use_api_key = false,
        });
    }

    pub fn evaluate(self: @This(), body: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.POST, "/access/v1/evaluation", &.{}, body, specializedAuth(token, self.client.environment_secret));
    }

    pub fn evaluateBatch(self: @This(), body: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.POST, "/access/v1/evaluations", &.{}, body, specializedAuth(token, self.client.environment_secret));
    }

    pub fn searchAction(self: @This(), body: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.POST, "/access/v1/search/action", &.{}, body, specializedAuth(token, self.client.environment_secret));
    }

    pub fn searchResource(self: @This(), body: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.POST, "/access/v1/search/resource", &.{}, body, specializedAuth(token, self.client.environment_secret));
    }

    pub fn searchSubject(self: @This(), body: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.POST, "/access/v1/search/subject", &.{}, body, specializedAuth(token, self.client.environment_secret));
    }
};

pub const ScimResource = struct {
    client: *AuthdogClient,

    fn auth(self: @This(), token: ?[]const u8) AuthdogClient.RequestAuth {
        return specializedAuth(token, self.client.scim_token);
    }

    pub fn listUsers(self: @This(), token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.GET, "/v1/scim/v2/Users", &.{}, null, self.auth(token));
    }

    pub fn createUser(self: @This(), body: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.POST, "/v1/scim/v2/Users", &.{}, body, self.auth(token));
    }

    pub fn getUser(self: @This(), user_id: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePathAuth(.GET, "/v1/scim/v2/Users/{s}", .{user_id}, &.{}, null, self.auth(token));
    }

    pub fn replaceUser(self: @This(), user_id: []const u8, body: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePathAuth(.PUT, "/v1/scim/v2/Users/{s}", .{user_id}, &.{}, body, self.auth(token));
    }

    pub fn patchUser(self: @This(), user_id: []const u8, body: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePathAuth(.PATCH, "/v1/scim/v2/Users/{s}", .{user_id}, &.{}, body, self.auth(token));
    }

    pub fn deleteUser(self: @This(), user_id: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePathAuth(.DELETE, "/v1/scim/v2/Users/{s}", .{user_id}, &.{}, null, self.auth(token));
    }

    pub fn listGroups(self: @This(), token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.GET, "/v1/scim/v2/Groups", &.{}, null, self.auth(token));
    }

    pub fn createGroup(self: @This(), body: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.POST, "/v1/scim/v2/Groups", &.{}, body, self.auth(token));
    }

    pub fn getGroup(self: @This(), group_id: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePathAuth(.GET, "/v1/scim/v2/Groups/{s}", .{group_id}, &.{}, null, self.auth(token));
    }

    pub fn replaceGroup(self: @This(), group_id: []const u8, body: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePathAuth(.PUT, "/v1/scim/v2/Groups/{s}", .{group_id}, &.{}, body, self.auth(token));
    }

    pub fn patchGroup(self: @This(), group_id: []const u8, body: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePathAuth(.PATCH, "/v1/scim/v2/Groups/{s}", .{group_id}, &.{}, body, self.auth(token));
    }

    pub fn deleteGroup(self: @This(), group_id: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePathAuth(.DELETE, "/v1/scim/v2/Groups/{s}", .{group_id}, &.{}, null, self.auth(token));
    }

    pub fn resourceTypes(self: @This(), token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.GET, "/v1/scim/v2/ResourceTypes", &.{}, null, self.auth(token));
    }

    pub fn resourceType(self: @This(), type_id: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePathAuth(.GET, "/v1/scim/v2/ResourceTypes/{s}", .{type_id}, &.{}, null, self.auth(token));
    }

    pub fn schemas(self: @This(), token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.GET, "/v1/scim/v2/Schemas", &.{}, null, self.auth(token));
    }

    pub fn schema(self: @This(), schema_id: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePathAuth(.GET, "/v1/scim/v2/Schemas/{s}", .{schema_id}, &.{}, null, self.auth(token));
    }

    pub fn serviceProviderConfig(self: @This(), token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.GET, "/v1/scim/v2/ServiceProviderConfig", &.{}, null, self.auth(token));
    }
};

pub const HrisResource = struct {
    client: *AuthdogClient,

    fn auth(self: @This(), token: ?[]const u8) AuthdogClient.RequestAuth {
        return specializedAuth(token, self.client.hris_token);
    }

    pub fn listDepartments(self: @This(), token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.GET, "/v1/hris/v1/Departments", &.{}, null, self.auth(token));
    }

    pub fn createDepartment(self: @This(), body: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.POST, "/v1/hris/v1/Departments", &.{}, body, self.auth(token));
    }

    pub fn getDepartment(self: @This(), department_id: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePathAuth(.GET, "/v1/hris/v1/Departments/{s}", .{department_id}, &.{}, null, self.auth(token));
    }

    pub fn replaceDepartment(self: @This(), department_id: []const u8, body: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePathAuth(.PUT, "/v1/hris/v1/Departments/{s}", .{department_id}, &.{}, body, self.auth(token));
    }

    pub fn patchDepartment(self: @This(), department_id: []const u8, body: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePathAuth(.PATCH, "/v1/hris/v1/Departments/{s}", .{department_id}, &.{}, body, self.auth(token));
    }

    pub fn deleteDepartment(self: @This(), department_id: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePathAuth(.DELETE, "/v1/hris/v1/Departments/{s}", .{department_id}, &.{}, null, self.auth(token));
    }

    pub fn listEmployees(self: @This(), token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.GET, "/v1/hris/v1/Employees", &.{}, null, self.auth(token));
    }

    pub fn createEmployee(self: @This(), body: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.POST, "/v1/hris/v1/Employees", &.{}, body, self.auth(token));
    }

    pub fn getEmployee(self: @This(), employee_id: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePathAuth(.GET, "/v1/hris/v1/Employees/{s}", .{employee_id}, &.{}, null, self.auth(token));
    }

    pub fn replaceEmployee(self: @This(), employee_id: []const u8, body: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePathAuth(.PUT, "/v1/hris/v1/Employees/{s}", .{employee_id}, &.{}, body, self.auth(token));
    }

    pub fn patchEmployee(self: @This(), employee_id: []const u8, body: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePathAuth(.PATCH, "/v1/hris/v1/Employees/{s}", .{employee_id}, &.{}, body, self.auth(token));
    }

    pub fn deleteEmployee(self: @This(), employee_id: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePathAuth(.DELETE, "/v1/hris/v1/Employees/{s}", .{employee_id}, &.{}, null, self.auth(token));
    }

    pub fn serviceConfig(self: @This(), token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.GET, "/v1/hris/v1/ServiceConfig", &.{}, null, self.auth(token));
    }
};

pub const McpResource = struct {
    client: *AuthdogClient,

    fn runtimeAuth(self: @This(), token: ?[]const u8) AuthdogClient.RequestAuth {
        return specializedAuth(token, self.client.environment_secret);
    }

    pub fn ingestEvents(self: @This(), body: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValueAuth(.POST, "/v1/mcp/events", &.{}, body, self.runtimeAuth(token));
    }

    pub fn resolve(self: @This(), subject: []const u8, token: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        const query = [_]AuthdogClient.QueryParam{.{ .name = "subject", .value = subject }};
        return self.client.requestValueAuth(.GET, "/v1/mcp/trust-store/resolve", &query, null, self.runtimeAuth(token));
    }

    pub fn listEntries(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/mcp/trust-store", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn createEntry(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/mcp/trust-store", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn getEntry(self: @This(), tenant_id: []const u8, environment_id: []const u8, entry_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/mcp/trust-store/{s}", .{ tenant_id, environment_id, entry_id }, &.{}, null);
    }

    pub fn updateEntry(self: @This(), tenant_id: []const u8, environment_id: []const u8, entry_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.PATCH, "/v1/tenants/{s}/environments/{s}/mcp/trust-store/{s}", .{ tenant_id, environment_id, entry_id }, &.{}, body);
    }

    pub fn deleteEntry(self: @This(), tenant_id: []const u8, environment_id: []const u8, entry_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/mcp/trust-store/{s}", .{ tenant_id, environment_id, entry_id }, &.{}, null);
    }

    pub fn addKey(self: @This(), tenant_id: []const u8, environment_id: []const u8, entry_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/mcp/trust-store/{s}/keys", .{ tenant_id, environment_id, entry_id }, &.{}, body);
    }

    pub fn revokeKey(self: @This(), tenant_id: []const u8, environment_id: []const u8, entry_id: []const u8, key_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/mcp/trust-store/{s}/keys/{s}", .{ tenant_id, environment_id, entry_id, key_id }, &.{}, null);
    }

    pub fn rotateKey(self: @This(), tenant_id: []const u8, environment_id: []const u8, entry_id: []const u8, key_id: []const u8, body: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/mcp/trust-store/{s}/keys/{s}/rotate", .{ tenant_id, environment_id, entry_id, key_id }, &.{}, body);
    }

    pub fn revokeEntry(self: @This(), tenant_id: []const u8, environment_id: []const u8, entry_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/mcp/trust-store/{s}/revoke", .{ tenant_id, environment_id, entry_id }, &.{}, null);
    }

    pub fn verifyEntry(self: @This(), tenant_id: []const u8, environment_id: []const u8, entry_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/mcp/trust-store/{s}/verify", .{ tenant_id, environment_id, entry_id }, &.{}, body);
    }
};

pub const OtelResource = struct {
    client: *AuthdogClient,

    pub fn exportLogs(self: @This(), body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValue(.POST, "/v1/logs", &.{}, body);
    }

    pub fn exportMetrics(self: @This(), body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValue(.POST, "/v1/metrics", &.{}, body);
    }

    pub fn exportTraces(self: @This(), body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValue(.POST, "/v1/traces", &.{}, body);
    }

    pub fn exportLogsPrefixed(self: @This(), body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValue(.POST, "/v1/otel/v1/logs", &.{}, body);
    }

    pub fn exportMetricsPrefixed(self: @This(), body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValue(.POST, "/v1/otel/v1/metrics", &.{}, body);
    }

    pub fn exportTracesPrefixed(self: @This(), body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValue(.POST, "/v1/otel/v1/traces", &.{}, body);
    }
};

pub const OidcClientsResource = struct {
    client: *AuthdogClient,

    pub fn list(self: @This(), tenant_id: []const u8, application_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/applications/{s}/environments/{s}/oidc-clients", .{ tenant_id, application_id, environment_id }, &.{}, null);
    }

    pub fn register(self: @This(), tenant_id: []const u8, application_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/applications/{s}/environments/{s}/oidc-clients", .{ tenant_id, application_id, environment_id }, &.{}, body);
    }

    pub fn update(self: @This(), tenant_id: []const u8, application_id: []const u8, environment_id: []const u8, client_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.PATCH, "/v1/tenants/{s}/applications/{s}/environments/{s}/oidc-clients/{s}", .{ tenant_id, application_id, environment_id, client_id }, &.{}, body);
    }

    pub fn delete(self: @This(), tenant_id: []const u8, application_id: []const u8, environment_id: []const u8, client_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/applications/{s}/environments/{s}/oidc-clients/{s}", .{ tenant_id, application_id, environment_id, client_id }, &.{}, null);
    }
};

pub const ActionsResource = struct {
    client: *AuthdogClient,

    pub fn list(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/actions", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn save(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/actions", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn executions(self: @This(), tenant_id: []const u8, environment_id: []const u8, query: []const AuthdogClient.QueryParam) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/actions/executions", .{ tenant_id, environment_id }, query, null);
    }

    pub fn @"test"(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/actions/test", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn delete(self: @This(), tenant_id: []const u8, environment_id: []const u8, action_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/actions/{s}", .{ tenant_id, environment_id, action_id }, &.{}, null);
    }
};

pub const AddonsResource = struct {
    client: *AuthdogClient,

    pub fn list(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/addons", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn save(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/addons", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn delete(self: @This(), tenant_id: []const u8, environment_id: []const u8, provider: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/addons/{s}", .{ tenant_id, environment_id, provider }, &.{}, null);
    }
};

pub const BillingResource = struct {
    client: *AuthdogClient,

    pub fn listFeatures(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/billing/features", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn saveFeature(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/billing/features", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn deleteFeature(self: @This(), tenant_id: []const u8, environment_id: []const u8, feature_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/billing/features/{s}", .{ tenant_id, environment_id, feature_id }, &.{}, null);
    }

    pub fn listPlans(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/billing/plans", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn savePlan(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/billing/plans", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn deletePlan(self: @This(), tenant_id: []const u8, environment_id: []const u8, plan_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/billing/plans/{s}", .{ tenant_id, environment_id, plan_id }, &.{}, null);
    }

    pub fn syncStripe(self: @This(), tenant_id: []const u8, environment_id: []const u8, plan_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/billing/plans/{s}/sync-stripe", .{ tenant_id, environment_id, plan_id }, &.{}, null);
    }
};

pub const SettingsResource = struct {
    client: *AuthdogClient,

    fn getPolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8, comptime suffix: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/" ++ suffix, .{ tenant_id, environment_id }, &.{}, null);
    }

    fn putPolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8, comptime suffix: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.PUT, "/v1/tenants/{s}/environments/{s}/" ++ suffix, .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn getBotDetectionPolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.getPolicy(tenant_id, environment_id, "bot-detection-policy");
    }

    pub fn updateBotDetectionPolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.putPolicy(tenant_id, environment_id, "bot-detection-policy", body);
    }

    pub fn getBreachedPasswordPolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.getPolicy(tenant_id, environment_id, "breached-password-policy");
    }

    pub fn updateBreachedPasswordPolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.putPolicy(tenant_id, environment_id, "breached-password-policy", body);
    }

    pub fn getBruteForcePolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.getPolicy(tenant_id, environment_id, "brute-force-policy");
    }

    pub fn updateBruteForcePolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.putPolicy(tenant_id, environment_id, "brute-force-policy", body);
    }

    pub fn getDeviceRiskPolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.getPolicy(tenant_id, environment_id, "device-risk-policy");
    }

    pub fn updateDeviceRiskPolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.putPolicy(tenant_id, environment_id, "device-risk-policy", body);
    }

    pub fn listJwtClaimMappings(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.getPolicy(tenant_id, environment_id, "jwt-claim-mappings");
    }

    pub fn saveJwtClaimMapping(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/jwt-claim-mappings", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn deleteJwtClaimMapping(self: @This(), tenant_id: []const u8, environment_id: []const u8, mapping_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/jwt-claim-mappings/{s}", .{ tenant_id, environment_id, mapping_id }, &.{}, null);
    }

    pub fn getPasswordPolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.getPolicy(tenant_id, environment_id, "password-policy");
    }

    pub fn updatePasswordPolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.putPolicy(tenant_id, environment_id, "password-policy", body);
    }

    pub fn getRateLimitPolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.getPolicy(tenant_id, environment_id, "rate-limit-policy");
    }

    pub fn updateRateLimitPolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.putPolicy(tenant_id, environment_id, "rate-limit-policy", body);
    }

    pub fn getRestrictions(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.getPolicy(tenant_id, environment_id, "restrictions");
    }

    pub fn updateRestrictions(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.putPolicy(tenant_id, environment_id, "restrictions", body);
    }

    pub fn getSessionConfig(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.getPolicy(tenant_id, environment_id, "session-config");
    }

    pub fn updateSessionConfig(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.putPolicy(tenant_id, environment_id, "session-config", body);
    }
};

pub const ElevateResource = struct {
    client: *AuthdogClient,

    pub fn activateGrant(self: @This(), tenant_id: []const u8, environment_id: []const u8, grant_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/elevate/access-grants/{s}/activate", .{ tenant_id, environment_id, grant_id }, &.{}, body);
    }

    pub fn revokeGrant(self: @This(), tenant_id: []const u8, environment_id: []const u8, grant_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/elevate/access-grants/{s}/revoke", .{ tenant_id, environment_id, grant_id }, &.{}, body);
    }

    pub fn listRequests(self: @This(), tenant_id: []const u8, environment_id: []const u8, status: ?[]const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        const query = [_]AuthdogClient.QueryParam{.{ .name = "status", .value = status }};
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/elevate/access-requests", .{ tenant_id, environment_id }, &query, null);
    }

    pub fn createRequest(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/elevate/access-requests", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn getRequest(self: @This(), tenant_id: []const u8, environment_id: []const u8, request_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/elevate/access-requests/{s}", .{ tenant_id, environment_id, request_id }, &.{}, null);
    }

    pub fn approveRequest(self: @This(), tenant_id: []const u8, environment_id: []const u8, request_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/elevate/access-requests/{s}/approve", .{ tenant_id, environment_id, request_id }, &.{}, body);
    }

    pub fn cancelRequest(self: @This(), tenant_id: []const u8, environment_id: []const u8, request_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/elevate/access-requests/{s}/cancel", .{ tenant_id, environment_id, request_id }, &.{}, null);
    }

    pub fn denyRequest(self: @This(), tenant_id: []const u8, environment_id: []const u8, request_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/elevate/access-requests/{s}/deny", .{ tenant_id, environment_id, request_id }, &.{}, body);
    }

    pub fn getPolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/elevate/policy", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn updatePolicy(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.PUT, "/v1/tenants/{s}/environments/{s}/elevate/policy", .{ tenant_id, environment_id }, &.{}, body);
    }
};

pub const EmailProvidersResource = struct {
    client: *AuthdogClient,

    pub fn list(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/email-providers", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn save(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/email-providers", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn @"test"(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/email-providers/test", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn delete(self: @This(), tenant_id: []const u8, environment_id: []const u8, provider: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/email-providers/{s}", .{ tenant_id, environment_id, provider }, &.{}, null);
    }

    pub fn activate(self: @This(), tenant_id: []const u8, environment_id: []const u8, provider: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/email-providers/{s}/activate", .{ tenant_id, environment_id, provider }, &.{}, null);
    }
};

pub const FeatureFlagsResource = struct {
    client: *AuthdogClient,

    pub fn list(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/feature-flags", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn save(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/feature-flags", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn delete(self: @This(), tenant_id: []const u8, environment_id: []const u8, flag_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/feature-flags/{s}", .{ tenant_id, environment_id, flag_id }, &.{}, null);
    }
};

pub const FormsResource = struct {
    client: *AuthdogClient,

    pub fn listAttachments(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/form-attachments", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn list(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/forms", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn save(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/forms", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn delete(self: @This(), tenant_id: []const u8, environment_id: []const u8, form_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/forms/{s}", .{ tenant_id, environment_id, form_id }, &.{}, null);
    }
};

pub const ProvisioningTokensResource = struct {
    client: *AuthdogClient,

    pub fn listHris(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/hris-tokens", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn createHris(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/hris-tokens", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn revokeHris(self: @This(), tenant_id: []const u8, environment_id: []const u8, token_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/hris-tokens/{s}/revoke", .{ tenant_id, environment_id, token_id }, &.{}, null);
    }

    pub fn rotateHris(self: @This(), tenant_id: []const u8, environment_id: []const u8, token_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/hris-tokens/{s}/rotate", .{ tenant_id, environment_id, token_id }, &.{}, null);
    }

    pub fn listScim(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/scim-tokens", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn createScim(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/scim-tokens", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn revokeScim(self: @This(), tenant_id: []const u8, environment_id: []const u8, token_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/scim-tokens/{s}/revoke", .{ tenant_id, environment_id, token_id }, &.{}, null);
    }

    pub fn rotateScim(self: @This(), tenant_id: []const u8, environment_id: []const u8, token_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/scim-tokens/{s}/rotate", .{ tenant_id, environment_id, token_id }, &.{}, null);
    }
};

pub const ImpersonationResource = struct {
    client: *AuthdogClient,

    pub fn list(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/impersonation-grants", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn create(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/impersonation-grants", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn revoke(self: @This(), tenant_id: []const u8, environment_id: []const u8, grant_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/impersonation-grants/{s}/revoke", .{ tenant_id, environment_id, grant_id }, &.{}, null);
    }
};

pub const PortalResource = struct {
    client: *AuthdogClient,

    pub fn generateLink(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/portal/generate-link", .{ tenant_id, environment_id }, &.{}, body);
    }
};

pub const SecurityResource = struct {
    client: *AuthdogClient,

    pub fn posture(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/security/posture", .{ tenant_id, environment_id }, &.{}, null);
    }
};

pub const ThreatsResource = struct {
    client: *AuthdogClient,

    pub fn list(self: @This(), tenant_id: []const u8, environment_id: []const u8, query: []const AuthdogClient.QueryParam) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/threats", .{ tenant_id, environment_id }, query, null);
    }

    pub fn create(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/threats", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn get(self: @This(), tenant_id: []const u8, environment_id: []const u8, threat_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/threats/{s}", .{ tenant_id, environment_id, threat_id }, &.{}, null);
    }

    pub fn update(self: @This(), tenant_id: []const u8, environment_id: []const u8, threat_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.PATCH, "/v1/tenants/{s}/environments/{s}/threats/{s}", .{ tenant_id, environment_id, threat_id }, &.{}, body);
    }

    pub fn delete(self: @This(), tenant_id: []const u8, environment_id: []const u8, threat_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/threats/{s}", .{ tenant_id, environment_id, threat_id }, &.{}, null);
    }

    pub fn resolve(self: @This(), tenant_id: []const u8, environment_id: []const u8, threat_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/threats/{s}/resolve", .{ tenant_id, environment_id, threat_id }, &.{}, body);
    }
};

pub const VanityDomainsResource = struct {
    client: *AuthdogClient,

    pub fn list(self: @This(), tenant_id: []const u8, environment_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.GET, "/v1/tenants/{s}/environments/{s}/vanity-domains", .{ tenant_id, environment_id }, &.{}, null);
    }

    pub fn create(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/vanity-domains", .{ tenant_id, environment_id }, &.{}, body);
    }

    pub fn delete(self: @This(), tenant_id: []const u8, environment_id: []const u8, domain_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.DELETE, "/v1/tenants/{s}/environments/{s}/vanity-domains/{s}", .{ tenant_id, environment_id, domain_id }, &.{}, null);
    }

    pub fn check(self: @This(), tenant_id: []const u8, environment_id: []const u8, domain_id: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/vanity-domains/{s}/check", .{ tenant_id, environment_id, domain_id }, &.{}, null);
    }
};

pub const WidgetsResource = struct {
    client: *AuthdogClient,

    pub fn createToken(self: @This(), tenant_id: []const u8, environment_id: []const u8, body: []const u8) AuthdogError!std.json.Parsed(std.json.Value) {
        return self.client.requestValuePath(.POST, "/v1/tenants/{s}/environments/{s}/widgets/token", .{ tenant_id, environment_id }, &.{}, body);
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
    try std.testing.expectEqual(@as(?[]u8, null), client.environment_secret);
    try std.testing.expectEqual(@as(?[]u8, null), client.scim_token);
    try std.testing.expectEqual(@as(?[]u8, null), client.hris_token);
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
