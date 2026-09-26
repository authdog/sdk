// MIT License
//
// Copyright (c) 2025 Authdog
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
