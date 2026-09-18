import axios, { AxiosInstance, AxiosResponse } from 'axios';
import { AuthenticationError, APIError } from './exceptions';
import {
  ActionsResource,
  AddonsResource,
  ApiSecretsResource,
  AuditResource,
  AuthzenResource,
  BillingResource,
  ElevateResource,
  EmailProvidersResource,
  EnvironmentsResource,
  EventsResource,
  FeatureFlagsResource,
  FormsResource,
  GroupsResource,
  HrisResource,
  ImpersonationResource,
  McpResource,
  NotificationChannelsResource,
  OidcClientsResource,
  OrganizationsResource,
  OtelResource,
  PersonalAccessTokensResource,
  PortalResource,
  ProjectsResource,
  ProvisioningTokensResource,
  RbacResource,
  RequestOptions,
  ScimResource,
  SecurityResource,
  ServiceAccountsResource,
  SettingsResource,
  TenantsResource,
  ThreatsResource,
  UsersResource,
  VanityDomainsResource,
  WebhooksResource,
  WidgetsResource,
} from './resources';
import { Probe, UserInfoResponse } from './types';

export interface AuthdogClientConfig {
  baseUrl: string;
  apiKey?: string;
  timeout?: number;
  environmentSecret?: string;
  scimToken?: string;
  hrisToken?: string;
}

export class AuthdogClient {
  private client: AxiosInstance;
  private config: AuthdogClientConfig;
  readonly environmentSecret?: string;
  readonly scimToken?: string;
  readonly hrisToken?: string;
  readonly organizations: OrganizationsResource;
  readonly tenants: TenantsResource;
  readonly projects: ProjectsResource;
  readonly environments: EnvironmentsResource;
  readonly users: UsersResource;
  readonly groups: GroupsResource;
  readonly rbac: RbacResource;
  readonly audit: AuditResource;
  readonly events: EventsResource;
  readonly webhooks: WebhooksResource;
  readonly notificationChannels: NotificationChannelsResource;
  readonly serviceAccounts: ServiceAccountsResource;
  readonly personalAccessTokens: PersonalAccessTokensResource;
  readonly apiSecrets: ApiSecretsResource;
  readonly authzen: AuthzenResource;
  readonly scim: ScimResource;
  readonly hris: HrisResource;
  readonly mcp: McpResource;
  readonly otel: OtelResource;
  readonly oidcClients: OidcClientsResource;
  readonly actions: ActionsResource;
  readonly addons: AddonsResource;
  readonly billing: BillingResource;
  readonly settings: SettingsResource;
  readonly elevate: ElevateResource;
  readonly emailProviders: EmailProvidersResource;
  readonly featureFlags: FeatureFlagsResource;
  readonly forms: FormsResource;
  readonly provisioningTokens: ProvisioningTokensResource;
  readonly impersonation: ImpersonationResource;
  readonly portal: PortalResource;
  readonly security: SecurityResource;
  readonly threats: ThreatsResource;
  readonly vanityDomains: VanityDomainsResource;
  readonly widgets: WidgetsResource;

  constructor(config: AuthdogClientConfig) {
    this.config = config;
    this.environmentSecret = config.environmentSecret;
    this.scimToken = config.scimToken;
    this.hrisToken = config.hrisToken;
    this.client = axios.create({
      baseURL: config.baseUrl,
      timeout: config.timeout || 10000,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'authdog-node-sdk/0.1.0',
        ...(config.apiKey && { 'Authorization': `Bearer ${config.apiKey}` }),
      },
    });
    this.organizations = new OrganizationsResource(this);
    this.tenants = new TenantsResource(this);
    this.projects = new ProjectsResource(this);
    this.environments = new EnvironmentsResource(this);
    this.users = new UsersResource(this);
    this.groups = new GroupsResource(this);
    this.rbac = new RbacResource(this);
    this.audit = new AuditResource(this);
    this.events = new EventsResource(this);
    this.webhooks = new WebhooksResource(this);
    this.notificationChannels = new NotificationChannelsResource(this);
    this.serviceAccounts = new ServiceAccountsResource(this);
    this.personalAccessTokens = new PersonalAccessTokensResource(this);
    this.apiSecrets = new ApiSecretsResource(this);
    this.authzen = new AuthzenResource(this);
    this.scim = new ScimResource(this);
    this.hris = new HrisResource(this);
    this.mcp = new McpResource(this);
    this.otel = new OtelResource(this);
    this.oidcClients = new OidcClientsResource(this);
    this.actions = new ActionsResource(this);
    this.addons = new AddonsResource(this);
    this.billing = new BillingResource(this);
    this.settings = new SettingsResource(this);
    this.elevate = new ElevateResource(this);
    this.emailProviders = new EmailProvidersResource(this);
    this.featureFlags = new FeatureFlagsResource(this);
    this.forms = new FormsResource(this);
    this.provisioningTokens = new ProvisioningTokensResource(this);
    this.impersonation = new ImpersonationResource(this);
    this.portal = new PortalResource(this);
    this.security = new SecurityResource(this);
    this.threats = new ThreatsResource(this);
    this.vanityDomains = new VanityDomainsResource(this);
    this.widgets = new WidgetsResource(this);
  }

  async request<T = Record<string, unknown>>(
    method: string,
    path: string,
    options: RequestOptions = {}
  ): Promise<T> {
    const { omitAuth, accessToken, headers: extraHeaders, ...rest } = options;
    const headers: Record<string, string> = { ...extraHeaders };
    if (omitAuth) {
      headers.Authorization = '';
    } else if (accessToken != null) {
      headers.Authorization = `Bearer ${accessToken}`;
    }

    try {
      const response = await this.client.request<T>({
        method,
        url: path,
        ...rest,
        ...(Object.keys(headers).length > 0 ? { headers } : {}),
      });
      return response.data;
    } catch (error) {
      if (axios.isAxiosError(error)) {
        if (error.response?.status === 401) {
          throw new AuthenticationError('Unauthorized - invalid or expired token');
        }
        const status = error.response?.status;
        const payload = error.response?.data as { error?: string } | undefined;
        const detail = payload?.error || error.response?.data || error.message;
        throw new APIError(`HTTP error ${status}: ${detail}`, status);
      }
      throw new APIError(`Request failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  async health(): Promise<Probe> {
    return this.request<Probe>('GET', '/v1/health');
  }

  /**
   * Get user information using an access token
   * @param accessToken The access token for authentication
   * @returns Promise<UserInfoResponse> User information
   * @throws {AuthenticationError} When authentication fails
   * @throws {APIError} When API request fails
   */
  async getUserInfo(accessToken: string): Promise<UserInfoResponse> {
    try {
      const response: AxiosResponse<UserInfoResponse> = await this.client.get('/v1/userinfo', {
        headers: {
          'Authorization': `Bearer ${accessToken}`,
        },
      });

      return response.data;
    } catch (error) {
      if (axios.isAxiosError(error)) {
        if (error.response?.status === 401) {
          throw new AuthenticationError('Unauthorized - invalid or expired token');
        }

        if (error.response?.status === 500) {
          const errorData = error.response.data;
          if (errorData?.error === 'GraphQL query failed') {
            throw new APIError('GraphQL query failed');
          } else if (errorData?.error === 'Failed to fetch user info') {
            throw new APIError('Failed to fetch user info');
          }
        }

        throw new APIError(`HTTP error ${error.response?.status}: ${error.response?.data || error.message}`);
      }

      throw new APIError(`Request failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  /**
   * Close the HTTP client (useful for cleanup)
   */
  close(): void {
    // Axios doesn't require explicit cleanup, but this method is provided for consistency
  }
}
