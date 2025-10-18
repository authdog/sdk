import { UserInfoResponse } from '../src/types';

describe('Type Definitions', () => {
  describe('UserInfoResponse', () => {
    const validUserInfoResponse: UserInfoResponse = {
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

    it('should accept valid UserInfoResponse structure', () => {
      // This test ensures the type definition accepts valid data
      expect(validUserInfoResponse).toBeDefined();
      expect(validUserInfoResponse.meta).toBeDefined();
      expect(validUserInfoResponse.session).toBeDefined();
      expect(validUserInfoResponse.user).toBeDefined();
    });

    it('should have correct meta structure', () => {
      expect(typeof validUserInfoResponse.meta.code).toBe('number');
      expect(typeof validUserInfoResponse.meta.message).toBe('string');
      expect(validUserInfoResponse.meta.code).toBe(200);
      expect(validUserInfoResponse.meta.message).toBe('Success');
    });

    it('should have correct session structure', () => {
      expect(typeof validUserInfoResponse.session.remainingSeconds).toBe('number');
      expect(validUserInfoResponse.session.remainingSeconds).toBe(3600);
    });

    it('should have correct user structure', () => {
      const user = validUserInfoResponse.user;
      
      expect(typeof user.id).toBe('string');
      expect(typeof user.externalId).toBe('string');
      expect(typeof user.userName).toBe('string');
      expect(typeof user.displayName).toBe('string');
      expect(typeof user.locale).toBe('string');
      expect(typeof user.active).toBe('boolean');
      expect(typeof user.provider).toBe('string');
      expect(typeof user.createdAt).toBe('string');
      expect(typeof user.updatedAt).toBe('string');
      expect(typeof user.environmentId).toBe('string');
    });

    it('should handle nullable fields correctly', () => {
      const user = validUserInfoResponse.user;
      
      expect(user.nickName).toBeNull();
      expect(user.profileUrl).toBeNull();
      expect(user.title).toBeNull();
      expect(user.userType).toBeNull();
      expect(user.preferredLanguage).toBeNull();
      expect(user.timezone).toBeNull();
      expect(user.names.middleName).toBeNull();
      expect(user.names.honorificPrefix).toBeNull();
      expect(user.names.honorificSuffix).toBeNull();
    });

    it('should have correct names structure', () => {
      const names = validUserInfoResponse.user.names;
      
      expect(typeof names.id).toBe('string');
      expect(typeof names.familyName).toBe('string');
      expect(typeof names.givenName).toBe('string');
      expect(names.formatted).toBe('Test User');
      expect(names.middleName).toBeNull();
      expect(names.honorificPrefix).toBeNull();
      expect(names.honorificSuffix).toBeNull();
    });

    it('should handle arrays correctly', () => {
      const user = validUserInfoResponse.user;
      
      expect(Array.isArray(user.photos)).toBe(true);
      expect(Array.isArray(user.phoneNumbers)).toBe(true);
      expect(Array.isArray(user.addresses)).toBe(true);
      expect(Array.isArray(user.emails)).toBe(true);
      expect(Array.isArray(user.verifications)).toBe(true);
    });

    it('should have correct email structure', () => {
      const email = validUserInfoResponse.user.emails[0];
      
      expect(typeof email.id).toBe('string');
      expect(typeof email.value).toBe('string');
      expect(email.type).toBe('primary');
    });

    it('should have correct verification structure', () => {
      const verification = validUserInfoResponse.user.verifications[0];
      
      expect(typeof verification.id).toBe('string');
      expect(typeof verification.email).toBe('string');
      expect(typeof verification.verified).toBe('boolean');
      expect(typeof verification.createdAt).toBe('string');
      expect(typeof verification.updatedAt).toBe('string');
      
      expect(verification.verified).toBe(true);
    });

    it('should handle minimal valid response', () => {
      const minimalResponse: UserInfoResponse = {
        meta: {
          code: 200,
          message: 'OK',
        },
        session: {
          remainingSeconds: 0,
        },
        user: {
          id: 'minimal-user',
          externalId: 'minimal-ext',
          userName: 'minimal',
          displayName: 'Minimal User',
          nickName: null,
          profileUrl: null,
          title: null,
          userType: null,
          preferredLanguage: null,
          locale: 'en',
          timezone: null,
          active: false,
          names: {
            id: 'minimal-name',
            formatted: null,
            familyName: 'User',
            givenName: 'Minimal',
            middleName: null,
            honorificPrefix: null,
            honorificSuffix: null,
          },
          photos: [],
          phoneNumbers: [],
          addresses: [],
          emails: [],
          verifications: [],
          provider: 'minimal',
          createdAt: '2023-01-01T00:00:00Z',
          updatedAt: '2023-01-01T00:00:00Z',
          environmentId: 'minimal-env',
        },
      };

      expect(minimalResponse).toBeDefined();
      expect(minimalResponse.user.emails).toHaveLength(0);
      expect(minimalResponse.user.verifications).toHaveLength(0);
      expect(minimalResponse.user.photos).toHaveLength(0);
    });

    it('should handle email with null type', () => {
      const responseWithNullEmailType: UserInfoResponse = {
        ...validUserInfoResponse,
        user: {
          ...validUserInfoResponse.user,
          emails: [
            {
              id: 'email-123',
              value: 'test@example.com',
              type: null,
            },
          ],
        },
      };

      expect(responseWithNullEmailType.user.emails[0].type).toBeNull();
    });
  });
});
