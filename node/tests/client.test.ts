import axios from 'axios';
import { AuthdogClient } from '../src/client';
import { AuthenticationError, APIError } from '../src/exceptions';
import { UserInfoResponse } from '../src/types';
import { vi } from 'vitest';

// Mock axios
vi.mock('axios');
const mockedAxios = axios as any;

describe('AuthdogClient', () => {
  let client: AuthdogClient;
  let mockAxiosInstance: any;

  beforeEach(() => {
    // Create a mock axios instance
    mockAxiosInstance = {
      get: vi.fn(),
      post: vi.fn(),
      put: vi.fn(),
      delete: vi.fn(),
    };

    // Mock axios.create to return our mock instance
    mockedAxios.create.mockReturnValue(mockAxiosInstance);

    // Create client instance
    client = new AuthdogClient({
      baseUrl: 'https://api.authdog.com',
      apiKey: 'test-api-key',
      timeout: 5000,
    });
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  describe('constructor', () => {
    it('should create axios instance with correct configuration', () => {
      expect(mockedAxios.create).toHaveBeenCalledWith({
        baseURL: 'https://api.authdog.com',
        timeout: 5000,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'authdog-node-sdk/0.1.0',
          'Authorization': 'Bearer test-api-key',
        },
      });
    });

    it('should create axios instance without apiKey when not provided', () => {
      const clientWithoutKey = new AuthdogClient({
        baseUrl: 'https://api.authdog.com',
        timeout: 10000,
      });

      expect(mockedAxios.create).toHaveBeenCalledWith({
        baseURL: 'https://api.authdog.com',
        timeout: 10000,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'authdog-node-sdk/0.1.0',
        },
      });
    });

    it('should use default timeout when not provided', () => {
      const clientWithDefaultTimeout = new AuthdogClient({
        baseUrl: 'https://api.authdog.com',
      });

      expect(mockedAxios.create).toHaveBeenCalledWith({
        baseURL: 'https://api.authdog.com',
        timeout: 10000,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'authdog-node-sdk/0.1.0',
        },
      });
    });
  });

  describe('getUserInfo', () => {
    const mockUserInfoResponse: UserInfoResponse = {
      meta: {
        code: 200,
        message: 'Success',
      },
      session: {
        remainingSeconds: 3600,
      },
      user: {
        id: 'user-123',
        externalId: 'ext-123',
        userName: 'testuser',
        displayName: 'Test User',
        nickName: null,
        profileUrl: null,
        title: null,
        userType: null,
        preferredLanguage: null,
        locale: 'en-US',
        timezone: null,
        active: true,
        names: {
          id: 'name-123',
          formatted: 'Test User',
          familyName: 'User',
          givenName: 'Test',
          middleName: null,
          honorificPrefix: null,
          honorificSuffix: null,
        },
        photos: [],
        phoneNumbers: [],
        addresses: [],
        emails: [
          {
            id: 'email-123',
            value: 'test@example.com',
            type: 'primary',
          },
        ],
        verifications: [
          {
            id: 'verification-123',
            email: 'test@example.com',
            verified: true,
            createdAt: '2023-01-01T00:00:00Z',
            updatedAt: '2023-01-01T00:00:00Z',
          },
        ],
        provider: 'authdog',
        createdAt: '2023-01-01T00:00:00Z',
        updatedAt: '2023-01-01T00:00:00Z',
        environmentId: 'env-123',
      },
    };

    it('should successfully get user info', async () => {
      mockAxiosInstance.get.mockResolvedValue({
        data: mockUserInfoResponse,
      });

      const result = await client.getUserInfo('test-access-token');

      expect(mockAxiosInstance.get).toHaveBeenCalledWith('/v1/userinfo', {
        headers: {
          'Authorization': 'Bearer test-access-token',
        },
      });
      expect(result).toEqual(mockUserInfoResponse);
    });

    it('should throw AuthenticationError for 401 status', async () => {
      const axiosError = {
        isAxiosError: true,
        response: {
          status: 401,
          data: { error: 'Unauthorized' },
        },
        message: 'Request failed with status code 401',
      };

      // Mock axios.isAxiosError to return true for our mock error
      mockedAxios.isAxiosError.mockReturnValue(true);
      mockAxiosInstance.get.mockRejectedValue(axiosError);

      await expect(client.getUserInfo('invalid-token')).rejects.toThrow(AuthenticationError);
      await expect(client.getUserInfo('invalid-token')).rejects.toThrow('Unauthorized - invalid or expired token');
    });

    it('should throw APIError for GraphQL query failed', async () => {
      const axiosError = {
        isAxiosError: true,
        response: {
          status: 500,
          data: { error: 'GraphQL query failed' },
        },
        message: 'Request failed with status code 500',
      };

      mockedAxios.isAxiosError.mockReturnValue(true);
      mockAxiosInstance.get.mockRejectedValue(axiosError);

      await expect(client.getUserInfo('test-token')).rejects.toThrow(APIError);
      await expect(client.getUserInfo('test-token')).rejects.toThrow('GraphQL query failed');
    });

    it('should throw APIError for failed to fetch user info', async () => {
      const axiosError = {
        isAxiosError: true,
        response: {
          status: 500,
          data: { error: 'Failed to fetch user info' },
        },
        message: 'Request failed with status code 500',
      };

      mockedAxios.isAxiosError.mockReturnValue(true);
      mockAxiosInstance.get.mockRejectedValue(axiosError);

      await expect(client.getUserInfo('test-token')).rejects.toThrow(APIError);
      await expect(client.getUserInfo('test-token')).rejects.toThrow('Failed to fetch user info');
    });

    it('should throw APIError for other HTTP errors', async () => {
      const axiosError = {
        isAxiosError: true,
        response: {
          status: 404,
          data: { error: 'Not found' },
        },
        message: 'Request failed with status code 404',
      };

      mockedAxios.isAxiosError.mockReturnValue(true);
      mockAxiosInstance.get.mockRejectedValue(axiosError);

      await expect(client.getUserInfo('test-token')).rejects.toThrow(APIError);
      await expect(client.getUserInfo('test-token')).rejects.toThrow('HTTP error 404: [object Object]');
    });

    it('should throw APIError for network errors', async () => {
      const networkError = {
        isAxiosError: true,
        message: 'Network Error',
        response: undefined,
      };

      mockedAxios.isAxiosError.mockReturnValue(true);
      mockAxiosInstance.get.mockRejectedValue(networkError);

      await expect(client.getUserInfo('test-token')).rejects.toThrow(APIError);
      await expect(client.getUserInfo('test-token')).rejects.toThrow('HTTP error undefined: Network Error');
    });

    it('should throw APIError for non-axios errors', async () => {
      const genericError = new Error('Generic error');
      
      mockedAxios.isAxiosError.mockReturnValue(false);
      mockAxiosInstance.get.mockRejectedValue(genericError);

      await expect(client.getUserInfo('test-token')).rejects.toThrow(APIError);
      await expect(client.getUserInfo('test-token')).rejects.toThrow('Request failed: Generic error');
    });

    it('should throw APIError for unknown error types', async () => {
      const unknownError = 'string error';
      
      mockedAxios.isAxiosError.mockReturnValue(false);
      mockAxiosInstance.get.mockRejectedValue(unknownError);

      await expect(client.getUserInfo('test-token')).rejects.toThrow(APIError);
      await expect(client.getUserInfo('test-token')).rejects.toThrow('Request failed: Unknown error');
    });
  });

  describe('close', () => {
    it('should not throw any errors', () => {
      expect(() => client.close()).not.toThrow();
    });
  });
});
