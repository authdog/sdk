const std = @import("std");

pub const version = @import("client.zig").version;
pub const user_agent = @import("client.zig").user_agent;

pub const AuthdogError = @import("error.zig").AuthdogError;
pub const isAuthenticationError = @import("error.zig").isAuthenticationError;
pub const isApiError = @import("error.zig").isApiError;

pub const AuthdogClient = @import("client.zig").AuthdogClient;
pub const AuthdogClientConfig = @import("client.zig").AuthdogClientConfig;

pub const Meta = @import("types.zig").Meta;
pub const Session = @import("types.zig").Session;
pub const Names = @import("types.zig").Names;
pub const Photo = @import("types.zig").Photo;
pub const Email = @import("types.zig").Email;
pub const Verification = @import("types.zig").Verification;
pub const User = @import("types.zig").User;
pub const UserInfoResponse = @import("types.zig").UserInfoResponse;

pub const Probe = @import("types.zig").Probe;
pub const Organization = @import("types.zig").Organization;
pub const OrganizationsList = @import("types.zig").OrganizationsList;
pub const Tenant = @import("types.zig").Tenant;
pub const TenantsList = @import("types.zig").TenantsList;
pub const EnvUserEmail = @import("types.zig").EnvUserEmail;
pub const EnvUser = @import("types.zig").EnvUser;
pub const EnvUsersResponse = @import("types.zig").EnvUsersResponse;
pub const EnvGroup = @import("types.zig").EnvGroup;
pub const EnvGroupsResponse = @import("types.zig").EnvGroupsResponse;

pub const OrganizationsResource = @import("client.zig").OrganizationsResource;
pub const TenantsResource = @import("client.zig").TenantsResource;
pub const ProjectsResource = @import("client.zig").ProjectsResource;
pub const EnvironmentsResource = @import("client.zig").EnvironmentsResource;
pub const UsersResource = @import("client.zig").UsersResource;
pub const GroupsResource = @import("client.zig").GroupsResource;
pub const RbacResource = @import("client.zig").RbacResource;
pub const AuditResource = @import("client.zig").AuditResource;
pub const EventsResource = @import("client.zig").EventsResource;
pub const WebhooksResource = @import("client.zig").WebhooksResource;
pub const NotificationChannelsResource = @import("client.zig").NotificationChannelsResource;
pub const ServiceAccountsResource = @import("client.zig").ServiceAccountsResource;
pub const PersonalAccessTokensResource = @import("client.zig").PersonalAccessTokensResource;
pub const ApiSecretsResource = @import("client.zig").ApiSecretsResource;
pub const AuthzenResource = @import("client.zig").AuthzenResource;
pub const ScimResource = @import("client.zig").ScimResource;
pub const HrisResource = @import("client.zig").HrisResource;
pub const McpResource = @import("client.zig").McpResource;
pub const OtelResource = @import("client.zig").OtelResource;
pub const OidcClientsResource = @import("client.zig").OidcClientsResource;
pub const ActionsResource = @import("client.zig").ActionsResource;
pub const AddonsResource = @import("client.zig").AddonsResource;
pub const BillingResource = @import("client.zig").BillingResource;
pub const SettingsResource = @import("client.zig").SettingsResource;
pub const ElevateResource = @import("client.zig").ElevateResource;
pub const EmailProvidersResource = @import("client.zig").EmailProvidersResource;
pub const FeatureFlagsResource = @import("client.zig").FeatureFlagsResource;
pub const FormsResource = @import("client.zig").FormsResource;
pub const ProvisioningTokensResource = @import("client.zig").ProvisioningTokensResource;
pub const ImpersonationResource = @import("client.zig").ImpersonationResource;
pub const PortalResource = @import("client.zig").PortalResource;
pub const SecurityResource = @import("client.zig").SecurityResource;
pub const ThreatsResource = @import("client.zig").ThreatsResource;
pub const VanityDomainsResource = @import("client.zig").VanityDomainsResource;
pub const WidgetsResource = @import("client.zig").WidgetsResource;

test {
    std.testing.refAllDecls(@This());
    _ = @import("error.zig");
    _ = @import("types.zig");
    _ = @import("client.zig");
    _ = @import("management_test.zig");
}
