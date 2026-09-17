import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import { AuthenticationError, APIError } from './exceptions';
import {
  ApiSecretsResource,
  AuditResource,
  EnvironmentsResource,
  EventsResource,
  GroupsResource,
  NotificationChannelsResource,
  OrganizationsResource,
  PersonalAccessTokensResource,
  ProjectsResource,
  RbacResource,
  ServiceAccountsResource,
  TenantsResource,
  UsersResource,
  WebhooksResource,
} from './resources';
import { Probe, UserInfoResponse } from './types';

export interface AuthdogClientConfig {
  baseUrl: string;
  apiKey?: string;
  timeout?: number;
}

export class AuthdogClient {
  private client: AxiosInstance;
  private config: AuthdogClientConfig;
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

  constructor(config: AuthdogClientConfig) {
    this.config = config;
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
  }

  async request<T = Record<string, unknown>>(
    method: string,
    path: string,
    options: Pick<AxiosRequestConfig, 'data' | 'params' | 'headers'> = {}
  ): Promise<T> {
    try {
      const response = await this.client.request<T>({
        method,
        url: path,
        ...options,
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
