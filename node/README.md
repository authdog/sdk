# Authdog Node.js SDK

Node.js SDK for Authdog authentication and user management.

## Installation

```bash
npm install @authdog/node-sdk
```

## Usage

### Basic Usage

```typescript
import { AuthdogClient, AuthenticationError, APIError } from '@authdog/node-sdk';

// Initialize the client
const client = new AuthdogClient({
  baseUrl: 'https://api.authdog.com',
  apiKey: 'your-api-key', // Optional
  timeout: 10000, // Optional, defaults to 10 seconds
});

// Get user information
try {
  const userInfo = await client.getUserInfo('your-access-token');
  console.log(`User: ${userInfo.user.displayName}`);
  console.log(`Email: ${userInfo.user.emails[0].value}`);
} catch (error) {
  if (error instanceof AuthenticationError) {
    console.error('Authentication failed:', error.message);
  } else if (error instanceof APIError) {
    console.error('API error:', error.message);
  } else {
    console.error('Unexpected error:', error);
  }
}
```

### Using with Async/Await

```typescript
import { AuthdogClient } from '@authdog/node-sdk';

async function getUserData(accessToken: string) {
  const client = new AuthdogClient({
    baseUrl: 'https://api.authdog.com',
  });

  try {
    const userInfo = await client.getUserInfo(accessToken);
    return {
      id: userInfo.user.id,
      name: userInfo.user.displayName,
      email: userInfo.user.emails[0]?.value,
      provider: userInfo.user.provider,
    };
  } finally {
    client.close();
  }
}
```

## API Reference

### AuthdogClient

#### Constructor

```typescript
new AuthdogClient(config: AuthdogClientConfig)
```

**Config Options:**
- `baseUrl` (string): The base URL of the Authdog API
- `apiKey` (string, optional): API key for authentication
- `timeout` (number, optional): Request timeout in milliseconds (default: 10000)

#### Methods

##### `getUserInfo(accessToken: string): Promise<UserInfoResponse>`

Get user information using an access token.

**Parameters:**
- `accessToken` (string): The access token for authentication

**Returns:** Promise<UserInfoResponse> - User information with the following structure:

```typescript
interface UserInfoResponse {
  meta: {
    code: number;
    message: string;
  };
  session: {
    remainingSeconds: number;
  };
  user: {
    id: string;
    externalId: string;
    userName: string;
    displayName: string;
    nickName: string | null;
    profileUrl: string | null;
    title: string | null;
    userType: string | null;
    preferredLanguage: string | null;
    locale: string;
    timezone: string | null;
    active: boolean;
    names: {
      id: string;
      formatted: string | null;
      familyName: string;
      givenName: string;
      middleName: string | null;
      honorificPrefix: string | null;
      honorificSuffix: string | null;
    };
    photos: Array<{
      id: string;
      value: string;
      type: string;
    }>;
    phoneNumbers: Array<any>;
    addresses: Array<any>;
    emails: Array<{
      id: string;
      value: string;
      type: string | null;
    }>;
    verifications: Array<{
      id: string;
      email: string;
      verified: boolean;
      createdAt: string;
      updatedAt: string;
    }>;
    provider: string;
    createdAt: string;
    updatedAt: string;
    environmentId: string;
  };
}
```

##### `close(): void`

Close the HTTP client (useful for cleanup).

## Exceptions

- `AuthdogError`: Base exception for all Authdog SDK errors
- `AuthenticationError`: Raised when authentication fails (401 responses)
- `APIError`: Raised when API requests fail

## Development

```bash
# Install dependencies
npm install

# Build the project
npm run build

# Run tests
npm test

# Run tests in watch mode
npm run test:watch

# Lint code
npm run lint

# Fix linting issues
npm run lint:fix

# Format code
npm run format
```

## TypeScript Support

This SDK is written in TypeScript and provides full type definitions. Import types as needed:

```typescript
import { UserInfoResponse, AuthdogClientConfig } from '@authdog/node-sdk';
```
