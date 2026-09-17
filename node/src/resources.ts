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

  listKeys(id: string): Promise<Json> {
    return this.client.request('GET', `/v1/organizations/${id}/keys`);
  }

  createKey(id: string, body: Json): Promise<Json> {
    return this.client.request('POST', `/v1/organizations/${id}/keys`, { data: body });
  }

  revokeKey(id: string, keyId: string): Promise<Json> {
    return this.client.request('POST', `/v1/organizations/${id}/keys/${keyId}/revoke`);
  }

  rotateKey(id: string, keyId: string): Promise<Json> {
    return this.client.request('POST', `/v1/organizations/${id}/keys/${keyId}/rotate`);
  }

  updateKeyTenants(id: string, keyId: string, body: Json): Promise<Json> {
    return this.client.request('PUT', `/v1/organizations/${id}/keys/${keyId}/tenants`, {
      data: body,
    });
  }

  listAuditLogs(id: string, params?: Json): Promise<Json> {
    return this.client.request('GET', `/v1/organizations/${id}/audit/logs`, { params });
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

function envPath(tenantId: string, environmentId: string): string {
  return `/v1/tenants/${tenantId}/environments/${environmentId}`;
}

export class RbacResource {
  constructor(private readonly client: ManagementRequester) {}

  listRoles(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/roles`);
  }

  createRole(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/roles`, {
      data: body,
    });
  }

  deleteRole(tenantId: string, environmentId: string, roleId: string): Promise<Json> {
    return this.client.request(
      'DELETE',
      `${envPath(tenantId, environmentId)}/roles/${roleId}`
    );
  }

  listRolePermissions(
    tenantId: string,
    environmentId: string,
    roleId: string
  ): Promise<Json> {
    return this.client.request(
      'GET',
      `${envPath(tenantId, environmentId)}/roles/${roleId}/permissions`
    );
  }

  setRolePermissions(
    tenantId: string,
    environmentId: string,
    roleId: string,
    body: Json
  ): Promise<Json> {
    return this.client.request(
      'PUT',
      `${envPath(tenantId, environmentId)}/roles/${roleId}/permissions`,
      { data: body }
    );
  }

  listPermissions(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/permissions`);
  }

  createPermission(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/permissions`, {
      data: body,
    });
  }

  deletePermission(
    tenantId: string,
    environmentId: string,
    permissionId: string
  ): Promise<Json> {
    return this.client.request(
      'DELETE',
      `${envPath(tenantId, environmentId)}/permissions/${permissionId}`
    );
  }

  listResources(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/resources`);
  }

  createResource(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/resources`, {
      data: body,
    });
  }

  deleteResource(
    tenantId: string,
    environmentId: string,
    resourceId: string
  ): Promise<Json> {
    return this.client.request(
      'DELETE',
      `${envPath(tenantId, environmentId)}/resources/${resourceId}`
    );
  }

  listGroupRoles(tenantId: string, environmentId: string, groupId: string): Promise<Json> {
    return this.client.request(
      'GET',
      `${envPath(tenantId, environmentId)}/groups/${groupId}/roles`
    );
  }

  addGroupRole(
    tenantId: string,
    environmentId: string,
    groupId: string,
    body: Json
  ): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/groups/${groupId}/roles`,
      { data: body }
    );
  }

  removeGroupRole(
    tenantId: string,
    environmentId: string,
    groupId: string,
    roleId: string
  ): Promise<Json> {
    return this.client.request(
      'DELETE',
      `${envPath(tenantId, environmentId)}/groups/${groupId}/roles/${roleId}`
    );
  }

  listGroupRoleMappings(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request(
      'GET',
      `${envPath(tenantId, environmentId)}/group-role-mappings`
    );
  }

  createGroupRoleMapping(
    tenantId: string,
    environmentId: string,
    body: Json
  ): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/group-role-mappings`,
      { data: body }
    );
  }

  applyGroupRoleMappings(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/group-role-mappings/apply`
    );
  }

  deleteGroupRoleMapping(
    tenantId: string,
    environmentId: string,
    mappingId: string
  ): Promise<Json> {
    return this.client.request(
      'DELETE',
      `${envPath(tenantId, environmentId)}/group-role-mappings/${mappingId}`
    );
  }

  listAbacPolicies(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/abac-policies`);
  }

  saveAbacPolicy(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/abac-policies`, {
      data: body,
    });
  }

  validateAbacPolicy(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/abac-policies/validate`,
      { data: body }
    );
  }

  deleteAbacPolicy(
    tenantId: string,
    environmentId: string,
    policyId: string
  ): Promise<Json> {
    return this.client.request(
      'DELETE',
      `${envPath(tenantId, environmentId)}/abac-policies/${policyId}`
    );
  }

  myPermissions(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/me/permissions`);
  }
}

export class AuditResource {
  constructor(private readonly client: ManagementRequester) {}

  listLogs(tenantId: string, environmentId: string, params?: Json): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/audit/logs`, {
      params,
    });
  }

  eventMetadata(tenantId: string, environmentId: string, params?: Json): Promise<Json> {
    return this.client.request(
      'GET',
      `${envPath(tenantId, environmentId)}/audit/event-metadata`,
      { params }
    );
  }

  eventTypes(tenantId: string, environmentId: string, params?: Json): Promise<Json> {
    return this.client.request(
      'GET',
      `${envPath(tenantId, environmentId)}/audit/event-types`,
      { params }
    );
  }

  eventTypesCatalog(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request(
      'GET',
      `${envPath(tenantId, environmentId)}/audit/event-types/catalog`
    );
  }
}

export class EventsResource {
  constructor(private readonly client: ManagementRequester) {}

  list(tenantId: string, environmentId: string, params?: Json): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/events`, {
      params,
    });
  }

  listTypes(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/events/types`);
  }

  ingest(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/events/ingest`, {
      data: body,
    });
  }
}

export class WebhooksResource {
  constructor(private readonly client: ManagementRequester) {}

  list(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/webhooks`);
  }

  create(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/webhooks`, {
      data: body,
    });
  }

  update(
    tenantId: string,
    environmentId: string,
    channelId: string,
    body: Json
  ): Promise<Json> {
    return this.client.request(
      'PUT',
      `${envPath(tenantId, environmentId)}/webhooks/${channelId}`,
      { data: body }
    );
  }

  delete(tenantId: string, environmentId: string, channelId: string): Promise<Json> {
    return this.client.request(
      'DELETE',
      `${envPath(tenantId, environmentId)}/webhooks/${channelId}`
    );
  }

  rotateSecret(tenantId: string, environmentId: string, channelId: string): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/webhooks/${channelId}/rotate-secret`
    );
  }

  listDeliveries(tenantId: string, environmentId: string, params?: Json): Promise<Json> {
    return this.client.request(
      'GET',
      `${envPath(tenantId, environmentId)}/webhooks/deliveries`,
      { params }
    );
  }

  redeliver(tenantId: string, environmentId: string, deliveryId: string): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/webhooks/deliveries/${deliveryId}/redeliver`
    );
  }
}

export class NotificationChannelsResource {
  constructor(private readonly client: ManagementRequester) {}

  list(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request(
      'GET',
      `${envPath(tenantId, environmentId)}/notification-channels`
    );
  }

  create(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/notification-channels`,
      { data: body }
    );
  }

  update(
    tenantId: string,
    environmentId: string,
    channelId: string,
    body: Json
  ): Promise<Json> {
    return this.client.request(
      'PUT',
      `${envPath(tenantId, environmentId)}/notification-channels/${channelId}`,
      { data: body }
    );
  }

  delete(tenantId: string, environmentId: string, channelId: string): Promise<Json> {
    return this.client.request(
      'DELETE',
      `${envPath(tenantId, environmentId)}/notification-channels/${channelId}`
    );
  }

  test(
    tenantId: string,
    environmentId: string,
    channelId: string,
    body?: Json
  ): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/notification-channels/${channelId}/test`,
      body !== undefined ? { data: body } : undefined
    );
  }
}

export class ServiceAccountsResource {
  constructor(private readonly client: ManagementRequester) {}

  list(): Promise<Json> {
    return this.client.request('GET', '/v1/service-accounts');
  }

  create(body: Json): Promise<Json> {
    return this.client.request('POST', '/v1/service-accounts', { data: body });
  }

  get(serviceAccountId: string): Promise<Json> {
    return this.client.request('GET', `/v1/service-accounts/${serviceAccountId}`);
  }

  delete(serviceAccountId: string): Promise<Json> {
    return this.client.request('DELETE', `/v1/service-accounts/${serviceAccountId}`);
  }
}

export class PersonalAccessTokensResource {
  constructor(private readonly client: ManagementRequester) {}

  list(): Promise<Json> {
    return this.client.request('GET', '/v1/personal-access-tokens');
  }

  create(body: Json): Promise<Json> {
    return this.client.request('POST', '/v1/personal-access-tokens', { data: body });
  }

  revoke(tokenId: string): Promise<Json> {
    return this.client.request('POST', `/v1/personal-access-tokens/${tokenId}/revoke`);
  }
}

export class ApiSecretsResource {
  constructor(private readonly client: ManagementRequester) {}

  list(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/api-secrets`);
  }

  create(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/api-secrets`, {
      data: body,
    });
  }

  revoke(tenantId: string, environmentId: string, secretId: string): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/api-secrets/${secretId}/revoke`
    );
  }
}
