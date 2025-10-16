/**
 * Base exception for all Authdog SDK errors
 */
export class AuthdogError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'AuthdogError';
  }
}

/**
 * Raised when authentication fails
 */
export class AuthenticationError extends AuthdogError {
  constructor(message: string) {
    super(message);
    this.name = 'AuthenticationError';
  }
}

/**
 * Raised when API requests fail
 */
export class APIError extends AuthdogError {
  constructor(message: string) {
    super(message);
    this.name = 'APIError';
  }
}
