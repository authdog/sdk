import { AuthdogError, AuthenticationError, APIError } from '../src/exceptions';

describe('Exception Classes', () => {
  describe('AuthdogError', () => {
    it('should create an instance with correct name and message', () => {
      const error = new AuthdogError('Test error message');
      
      expect(error).toBeInstanceOf(Error);
      expect(error).toBeInstanceOf(AuthdogError);
      expect(error.name).toBe('AuthdogError');
      expect(error.message).toBe('Test error message');
    });

    it('should be throwable and catchable', () => {
      const errorMessage = 'Something went wrong';
      
      expect(() => {
        throw new AuthdogError(errorMessage);
      }).toThrow(AuthdogError);
      
      expect(() => {
        throw new AuthdogError(errorMessage);
      }).toThrow(errorMessage);
    });

    it('should have proper inheritance chain', () => {
      const error = new AuthdogError('Test error');
      
      expect(error instanceof Error).toBe(true);
      expect(error instanceof AuthdogError).toBe(true);
    });
  });

  describe('AuthenticationError', () => {
    it('should create an instance with correct name and message', () => {
      const error = new AuthenticationError('Authentication failed');
      
      expect(error).toBeInstanceOf(Error);
      expect(error).toBeInstanceOf(AuthdogError);
      expect(error).toBeInstanceOf(AuthenticationError);
      expect(error.name).toBe('AuthenticationError');
      expect(error.message).toBe('Authentication failed');
    });

    it('should be throwable and catchable', () => {
      const errorMessage = 'Invalid credentials';
      
      expect(() => {
        throw new AuthenticationError(errorMessage);
      }).toThrow(AuthenticationError);
      
      expect(() => {
        throw new AuthenticationError(errorMessage);
      }).toThrow(AuthdogError);
      
      expect(() => {
        throw new AuthenticationError(errorMessage);
      }).toThrow(errorMessage);
    });

    it('should have proper inheritance chain', () => {
      const error = new AuthenticationError('Auth error');
      
      expect(error instanceof Error).toBe(true);
      expect(error instanceof AuthdogError).toBe(true);
      expect(error instanceof AuthenticationError).toBe(true);
    });

    it('should handle empty message', () => {
      const error = new AuthenticationError('');
      
      expect(error.message).toBe('');
      expect(error.name).toBe('AuthenticationError');
    });
  });

  describe('APIError', () => {
    it('should create an instance with correct name and message', () => {
      const error = new APIError('API request failed');
      
      expect(error).toBeInstanceOf(Error);
      expect(error).toBeInstanceOf(AuthdogError);
      expect(error).toBeInstanceOf(APIError);
      expect(error.name).toBe('APIError');
      expect(error.message).toBe('API request failed');
    });

    it('should be throwable and catchable', () => {
      const errorMessage = 'Server error occurred';
      
      expect(() => {
        throw new APIError(errorMessage);
      }).toThrow(APIError);
      
      expect(() => {
        throw new APIError(errorMessage);
      }).toThrow(AuthdogError);
      
      expect(() => {
        throw new APIError(errorMessage);
      }).toThrow(errorMessage);
    });

    it('should have proper inheritance chain', () => {
      const error = new APIError('API error');
      
      expect(error instanceof Error).toBe(true);
      expect(error instanceof AuthdogError).toBe(true);
      expect(error instanceof APIError).toBe(true);
    });

    it('should handle complex error messages', () => {
      const complexMessage = 'HTTP error 500: {"error": "Internal server error", "details": "Database connection failed"}';
      const error = new APIError(complexMessage);
      
      expect(error.message).toBe(complexMessage);
      expect(error.name).toBe('APIError');
    });

    it('should handle empty message', () => {
      const error = new APIError('');
      
      expect(error.message).toBe('');
      expect(error.name).toBe('APIError');
    });
  });

  describe('Error handling scenarios', () => {
    it('should allow catching specific error types', () => {
      const authError = new AuthenticationError('Auth failed');
      const apiError = new APIError('API failed');
      
      try {
        throw authError;
      } catch (error) {
        expect(error).toBeInstanceOf(AuthenticationError);
        expect(error).not.toBeInstanceOf(APIError);
      }
      
      try {
        throw apiError;
      } catch (error) {
        expect(error).toBeInstanceOf(APIError);
        expect(error).not.toBeInstanceOf(AuthenticationError);
      }
    });

    it('should allow catching base AuthdogError for all derived errors', () => {
      const authError = new AuthenticationError('Auth failed');
      const apiError = new APIError('API failed');
      
      try {
        throw authError;
      } catch (error) {
        expect(error).toBeInstanceOf(AuthdogError);
      }
      
      try {
        throw apiError;
      } catch (error) {
        expect(error).toBeInstanceOf(AuthdogError);
      }
    });

    it('should preserve error stack traces', () => {
      const error = new APIError('Test error');
      
      expect(error.stack).toBeDefined();
      expect(typeof error.stack).toBe('string');
      expect(error.stack).toContain('APIError');
    });
  });
});
