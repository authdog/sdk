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

export interface Probe {
  ok?: boolean;
}

export interface Organization {
  id?: string;
  name?: string;
  description?: string | null;
  billingEmail?: string | null;
  logoUri?: string | null;
  active?: boolean;
  createdAt?: string;
  updatedAt?: string;
}

export interface OrganizationsList {
  organizations: Organization[];
  total: number;
}

export interface Tenant {
  id?: string;
  name?: string;
  description?: string | null;
  company?: string | null;
  active?: boolean;
  createdAt?: string;
  updatedAt?: string;
  organizationIds?: string[];
}

export interface TenantsList {
  tenants: Tenant[];
  total: number;
}

export interface EnvUserEmail {
  id?: string;
  value?: string;
  type?: string | null;
}

export interface EnvUser {
  id?: string;
  environmentId?: string | null;
  externalId?: string | null;
  userName?: string | null;
  displayName?: string | null;
  nickName?: string | null;
  profileUrl?: string | null;
  active?: boolean | null;
  emails?: EnvUserEmail[];
  lastLogin?: string | null;
  createdAt?: string | null;
  updatedAt?: string | null;
}

export interface EnvUsersResponse {
  users: EnvUser[];
}

export interface EnvUserResponse {
  user?: EnvUser;
}

export interface EnvGroup {
  id?: string;
  environmentId?: string;
  name?: string;
  slug?: string;
  description?: string | null;
  memberCount?: number;
  createdAt?: string;
  updatedAt?: string;
}

export interface EnvGroupsResponse {
  groups: EnvGroup[];
}

export interface Environment {
  id?: string;
  name?: string;
  description?: string | null;
  weight?: number | null;
  isLive?: boolean | null;
  isDefault?: boolean | null;
  createdAt?: string | null;
  updatedAt?: string | null;
}

export interface Project {
  id?: string;
  name?: string;
  description?: string | null;
}
