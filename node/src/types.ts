/**
 * User information response from the /userinfo endpoint
 */
export interface UserInfoResponse {
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
    phoneNumbers: Array<unknown>;
    addresses: Array<unknown>;
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
