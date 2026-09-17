import {
  EnvGroupsResponse,
  EnvUserResponse,
  EnvUsersResponse,
  OrganizationsList,
  TenantsList,
} from './types';

type Json = Record<string, unknown>;

export interface ManagementRequester {
  request<T = Record<string, unknown>>(
    method: string,
    path: string,
    options?: { data?: unknown; params?: unknown; headers?: Record<string, string> }
  ): Promise<T>;
}

export class OrganizationsResource {
  constructor(private readonly client: ManagementRequester) {}

  list(): Promise<OrganizationsList> {
    return this.client.request<OrganizationsList>('GET', '/v1/organizations');
  }

  create(body: Json): Promise<Json> {
    return this.client.request('POST', '/v1/organizations', { data: body });
  }

  get(id: string): Promise<Json> {
    return this.client.request('GET', `/v1/organizations/${id}`);
  }

  update(id: string, body: Json): Promise<Json> {
    return this.client.request('PATCH', `/v1/organizations/${id}`, { data: body });
  }

  delete(id: string): Promise<Json> {
    return this.client.request('DELETE', `/v1/organizations/${id}`);
  }

  acceptInvitation(body: Json): Promise<Json> {
    return this.client.request('POST', '/v1/organizations/invitations/accept', { data: body });
  }

  join(body: Json): Promise<Json> {
    return this.client.request('POST', '/v1/organizations/join', { data: body });
  }

  listInvitations(id: string): Promise<Json> {
    return this.client.request('GET', `/v1/organizations/${id}/invitations`);
  }

  createInvitation(id: string, body: Json): Promise<Json> {
    return this.client.request('POST', `/v1/organizations/${id}/invitations`, { data: body });
  }

  cancelInvitation(id: string, invitationId: string): Promise<Json> {
    return this.client.request('POST', `/v1/organizations/${id}/invitations/${invitationId}/cancel`);
  }

  sendInvite(id: string, body: Json): Promise<Json> {
    return this.client.request('POST', `/v1/organizations/${id}/invites`, { data: body });
  }

  listMembers(id: string): Promise<Json> {
    return this.client.request('GET', `/v1/organizations/${id}/members`);
  }

  removeMember(id: string, memberId: string): Promise<Json> {
    return this.client.request('DELETE', `/v1/organizations/${id}/members/${memberId}`);
  }

  setMemberActive(id: string, memberId: string, body: Json): Promise<Json> {
    return this.client.request('PATCH', `/v1/organizations/${id}/members/${memberId}/active`, {
      data: body,
    });
  }

  linkTenant(id: string, body: Json): Promise<Json> {
    return this.client.request('POST', `/v1/organizations/${id}/tenants`, { data: body });
  }

  unlinkTenant(id: string, tenantId: string): Promise<Json> {
    return this.client.request('DELETE', `/v1/organizations/${id}/tenants/${tenantId}`);
  }
}

export class TenantsResource {
  constructor(private readonly client: ManagementRequester) {}

  list(organizationId?: string): Promise<TenantsList> {
    return this.client.request<TenantsList>('GET', '/v1/tenants', {
      params: organizationId ? { organization_id: organizationId } : undefined,
    });
  }

  create(body: Json): Promise<Json> {
    return this.client.request('POST', '/v1/tenants', { data: body });
  }

  join(body: Json): Promise<Json> {
    return this.client.request('POST', '/v1/tenants/join', { data: body });
  }

  get(id: string, organizationId?: string): Promise<Json> {
    return this.client.request('GET', `/v1/tenants/${id}`, {
      params: organizationId ? { organization_id: organizationId } : undefined,
    });
  }

  update(id: string, body: Json): Promise<Json> {
    return this.client.request('PATCH', `/v1/tenants/${id}`, { data: body });
  }

  delete(id: string): Promise<Json> {
    return this.client.request('DELETE', `/v1/tenants/${id}`);
  }

  listDomains(id: string): Promise<Json> {
    return this.client.request('GET', `/v1/tenants/${id}/domains`);
  }

  createDomain(id: string, body: Json): Promise<Json> {
    return this.client.request('POST', `/v1/tenants/${id}/domains`, { data: body });
  }

  deleteDomain(id: string, domainId: string): Promise<Json> {
    return this.client.request('DELETE', `/v1/tenants/${id}/domains/${domainId}`);
  }

  retryDomain(id: string, domainId: string): Promise<Json> {
    return this.client.request('POST', `/v1/tenants/${id}/domains/${domainId}/retry`);
  }

  sendInvite(id: string, body: Json): Promise<Json> {
    return this.client.request('POST', `/v1/tenants/${id}/invites`, { data: body });
  }

  listProjects(id: string): Promise<Json> {
    return this.client.request('GET', `/v1/tenants/${id}/projects`);
  }

  listSeats(id: string): Promise<Json> {
    return this.client.request('GET', `/v1/tenants/${id}/seats`);
  }

  updateSeat(id: string, seatId: string, body: Json): Promise<Json> {
    return this.client.request('PATCH', `/v1/tenants/${id}/seats/${seatId}`, { data: body });
  }

  deleteSeat(id: string, seatId: string): Promise<Json> {
    return this.client.request('DELETE', `/v1/tenants/${id}/seats/${seatId}`);
  }
}

export class ProjectsResource {
  constructor(private readonly client: ManagementRequester) {}

  save(tenantId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `/v1/tenants/${tenantId}/applications`, { data: body });
  }

  get(tenantId: string, applicationId: string): Promise<Json> {
    return this.client.request('GET', `/v1/tenants/${tenantId}/applications/${applicationId}`);
  }

  delete(tenantId: string, applicationId: string): Promise<Json> {
    return this.client.request('DELETE', `/v1/tenants/${tenantId}/applications/${applicationId}`);
  }

  setDefaultEnvironment(tenantId: string, applicationId: string, body: Json): Promise<Json> {
    return this.client.request(
      'PUT',
      `/v1/tenants/${tenantId}/applications/${applicationId}/default-environment`,
      { data: body }
    );
  }
}

export class EnvironmentsResource {
  constructor(private readonly client: ManagementRequester) {}

  list(tenantId: string, applicationId: string): Promise<Json> {
    return this.client.request(
      'GET',
      `/v1/tenants/${tenantId}/applications/${applicationId}/environments`
    );
  }

  create(tenantId: string, applicationId: string, body: Json): Promise<Json> {
    return this.client.request(
      'POST',
      `/v1/tenants/${tenantId}/applications/${applicationId}/environments`,
      { data: body }
    );
  }

  update(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('PATCH', `/v1/tenants/${tenantId}/environments/${environmentId}`, {
      data: body,
    });
  }

  delete(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('DELETE', `/v1/tenants/${tenantId}/environments/${environmentId}`);
  }
}

export class UsersResource {
  constructor(private readonly client: ManagementRequester) {}

  list(
    tenantId: string,
    environmentId: string,
    query?: { offset?: number; limit?: number; searchQuery?: string }
  ): Promise<EnvUsersResponse> {
    return this.client.request(
      'GET',
      `/v1/tenants/${tenantId}/environments/${environmentId}/users`,
      {
        params: query
          ? {
              offset: query.offset,
              limit: query.limit,
              searchQuery: query.searchQuery,
            }
          : undefined,
      }
    );
  }

  create(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request(
      'POST',
      `/v1/tenants/${tenantId}/environments/${environmentId}/users`,
      { data: body }
    );
  }

  search(
    tenantId: string,
    environmentId: string,
    query?: { q?: string; offset?: number; limit?: number }
  ): Promise<EnvUsersResponse> {
    return this.client.request(
      'GET',
      `/v1/tenants/${tenantId}/environments/${environmentId}/users/search`,
      { params: query }
    );
  }

  count(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request(
      'GET',
      `/v1/tenants/${tenantId}/environments/${environmentId}/users/count`
    );
  }

  get(tenantId: string, environmentId: string, userId: string): Promise<EnvUserResponse> {
    return this.client.request(
      'GET',
      `/v1/tenants/${tenantId}/environments/${environmentId}/users/${userId}`
    );
  }

  update(tenantId: string, environmentId: string, userId: string, body: Json): Promise<Json> {
    return this.client.request(
      'PUT',
      `/v1/tenants/${tenantId}/environments/${environmentId}/users/${userId}`,
      { data: body }
    );
  }

  delete(tenantId: string, environmentId: string, userId: string): Promise<Json> {
    return this.client.request(
      'DELETE',
      `/v1/tenants/${tenantId}/environments/${environmentId}/users/${userId}`
    );
  }

  setActive(tenantId: string, environmentId: string, userId: string, body: Json): Promise<Json> {
    return this.client.request(
      'PATCH',
      `/v1/tenants/${tenantId}/environments/${environmentId}/users/${userId}/active`,
      { data: body }
    );
  }

  listGroups(tenantId: string, environmentId: string, userId: string): Promise<Json> {
    return this.client.request(
      'GET',
      `/v1/tenants/${tenantId}/environments/${environmentId}/users/${userId}/groups`
    );
  }
}

export class GroupsResource {
  constructor(private readonly client: ManagementRequester) {}

  create(body: Json): Promise<Json> {
    return this.client.request('POST', '/v1/groups', { data: body });
  }

  list(tenantId: string, environmentId: string): Promise<EnvGroupsResponse> {
    return this.client.request(
      'GET',
      `/v1/tenants/${tenantId}/environments/${environmentId}/groups`
    );
  }

  delete(tenantId: string, environmentId: string, groupId: string): Promise<Json> {
    return this.client.request(
      'DELETE',
      `/v1/tenants/${tenantId}/environments/${environmentId}/groups/${groupId}`
    );
  }

  listMembers(tenantId: string, environmentId: string, groupId: string): Promise<Json> {
    return this.client.request(
      'GET',
      `/v1/tenants/${tenantId}/environments/${environmentId}/groups/${groupId}/members`
    );
  }

  addMember(tenantId: string, environmentId: string, groupId: string, body: Json): Promise<Json> {
    return this.client.request(
      'POST',
      `/v1/tenants/${tenantId}/environments/${environmentId}/groups/${groupId}/members`,
      { data: body }
    );
  }

  removeMember(
    tenantId: string,
    environmentId: string,
    groupId: string,
    userId: string
  ): Promise<Json> {
    return this.client.request(
      'DELETE',
      `/v1/tenants/${tenantId}/environments/${environmentId}/groups/${groupId}/members/${userId}`
    );
  }
}
