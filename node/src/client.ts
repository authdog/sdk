import axios, { AxiosInstance, AxiosResponse } from 'axios';
import { AuthenticationError, APIError } from './exceptions';
import { UserInfoResponse } from './types';

export interface AuthdogClientConfig {
  baseUrl: string;
  apiKey?: string;
  timeout?: number;
}

export class AuthdogClient {
  private client: AxiosInstance;
  private config: AuthdogClientConfig;

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
