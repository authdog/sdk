import {
  EnvGroupsResponse,
  EnvUserResponse,
  EnvUsersResponse,
  OrganizationsList,
  TenantsList,
} from './types';

type Json = Record<string, unknown>;

export interface RequestOptions {
  data?: unknown;
  params?: unknown;
  headers?: Record<string, string>;
  omitAuth?: boolean;
  accessToken?: string;
}

export interface ManagementRequester {
  environmentSecret?: string;
  scimToken?: string;
  hrisToken?: string;
  request<T = Record<string, unknown>>(
    method: string,
    path: string,
    options?: RequestOptions
  ): Promise<T>;
}

function compactParams(params: Record<string, unknown>): Record<string, unknown> | undefined {
  const values = Object.fromEntries(
    Object.entries(params).filter(([, value]) => value !== undefined)
  );
  return Object.keys(values).length > 0 ? values : undefined;
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

  listConnections(tenantId: string, applicationId: string, environmentId: string): Promise<Json> {
    return this.client.request(
      'GET',
      `/v1/tenants/${tenantId}/applications/${applicationId}/environments/${environmentId}/connections`
    );
  }

  listRedirectUris(tenantId: string, applicationId: string, environmentId: string): Promise<Json> {
    return this.client.request(
      'GET',
      `/v1/tenants/${tenantId}/applications/${applicationId}/environments/${environmentId}/redirect-uris`
    );
  }

  saveConnection(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/connections`, {
      data: body,
    });
  }

  resolveSamlMetadata(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/connections/resolve-saml-metadata`,
      { data: body }
    );
  }

  getSsoMetadata(
    tenantId: string,
    environmentId: string,
    connectionId?: string,
    providerId?: string
  ): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/connections/sso-metadata`, {
      params: compactParams({ connectionId, providerId }),
    });
  }

  deleteConnection(tenantId: string, environmentId: string, connectionId: string): Promise<Json> {
    return this.client.request(
      'DELETE',
      `${envPath(tenantId, environmentId)}/connections/${connectionId}`
    );
  }

  saveRedirectUris(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('PUT', `${envPath(tenantId, environmentId)}/redirect-uris`, {
      data: body,
    });
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

  revokeSession(environmentId: string, sessionId: string): Promise<Json> {
    return this.client.request('DELETE', `/v1/environments/${environmentId}/sessions/${sessionId}`);
  }

  totpStatus(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/me/mfa/totp`);
  }

  bulkDelete(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/users/bulk/delete`, {
      data: body,
    });
  }

  bulkSetActive(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/users/bulk/set-active`, {
      data: body,
    });
  }

  importUsers(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/users/import`, {
      data: body,
    });
  }

  disableMfa(tenantId: string, environmentId: string, userId: string): Promise<Json> {
    return this.client.request('DELETE', `${envPath(tenantId, environmentId)}/users/${userId}/mfa`);
  }

  listSessions(tenantId: string, environmentId: string, userId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/users/${userId}/sessions`);
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

export class AuthzenResource {
  constructor(private readonly client: ManagementRequester) {}

  configuration(): Promise<Json> {
    return this.client.request('GET', '/.well-known/authzen-configuration', { omitAuth: true });
  }

  evaluate(body: Json, token?: string): Promise<Json> {
    return this.client.request('POST', '/access/v1/evaluation', {
      data: body,
      accessToken: token ?? this.client.environmentSecret,
    });
  }

  evaluateBatch(body: Json, token?: string): Promise<Json> {
    return this.client.request('POST', '/access/v1/evaluations', {
      data: body,
      accessToken: token ?? this.client.environmentSecret,
    });
  }

  searchAction(body: Json, token?: string): Promise<Json> {
    return this.client.request('POST', '/access/v1/search/action', {
      data: body,
      accessToken: token ?? this.client.environmentSecret,
    });
  }

  searchResource(body: Json, token?: string): Promise<Json> {
    return this.client.request('POST', '/access/v1/search/resource', {
      data: body,
      accessToken: token ?? this.client.environmentSecret,
    });
  }

  searchSubject(body: Json, token?: string): Promise<Json> {
    return this.client.request('POST', '/access/v1/search/subject', {
      data: body,
      accessToken: token ?? this.client.environmentSecret,
    });
  }
}

export class ScimResource {
  constructor(private readonly client: ManagementRequester) {}

  private token(token?: string): string | undefined {
    return token ?? this.client.scimToken;
  }

  listUsers(token?: string): Promise<Json> {
    return this.client.request('GET', '/v1/scim/v2/Users', { accessToken: this.token(token) });
  }

  createUser(body: Json, token?: string): Promise<Json> {
    return this.client.request('POST', '/v1/scim/v2/Users', {
      data: body,
      accessToken: this.token(token),
    });
  }

  getUser(userId: string, token?: string): Promise<Json> {
    return this.client.request('GET', `/v1/scim/v2/Users/${userId}`, {
      accessToken: this.token(token),
    });
  }

  replaceUser(userId: string, body: Json, token?: string): Promise<Json> {
    return this.client.request('PUT', `/v1/scim/v2/Users/${userId}`, {
      data: body,
      accessToken: this.token(token),
    });
  }

  patchUser(userId: string, body: Json, token?: string): Promise<Json> {
    return this.client.request('PATCH', `/v1/scim/v2/Users/${userId}`, {
      data: body,
      accessToken: this.token(token),
    });
  }

  deleteUser(userId: string, token?: string): Promise<Json> {
    return this.client.request('DELETE', `/v1/scim/v2/Users/${userId}`, {
      accessToken: this.token(token),
    });
  }

  listGroups(token?: string): Promise<Json> {
    return this.client.request('GET', '/v1/scim/v2/Groups', { accessToken: this.token(token) });
  }

  createGroup(body: Json, token?: string): Promise<Json> {
    return this.client.request('POST', '/v1/scim/v2/Groups', {
      data: body,
      accessToken: this.token(token),
    });
  }

  getGroup(groupId: string, token?: string): Promise<Json> {
    return this.client.request('GET', `/v1/scim/v2/Groups/${groupId}`, {
      accessToken: this.token(token),
    });
  }

  replaceGroup(groupId: string, body: Json, token?: string): Promise<Json> {
    return this.client.request('PUT', `/v1/scim/v2/Groups/${groupId}`, {
      data: body,
      accessToken: this.token(token),
    });
  }

  patchGroup(groupId: string, body: Json, token?: string): Promise<Json> {
    return this.client.request('PATCH', `/v1/scim/v2/Groups/${groupId}`, {
      data: body,
      accessToken: this.token(token),
    });
  }

  deleteGroup(groupId: string, token?: string): Promise<Json> {
    return this.client.request('DELETE', `/v1/scim/v2/Groups/${groupId}`, {
      accessToken: this.token(token),
    });
  }

  resourceTypes(token?: string): Promise<Json> {
    return this.client.request('GET', '/v1/scim/v2/ResourceTypes', {
      accessToken: this.token(token),
    });
  }

  resourceType(typeId: string, token?: string): Promise<Json> {
    return this.client.request('GET', `/v1/scim/v2/ResourceTypes/${typeId}`, {
      accessToken: this.token(token),
    });
  }

  schemas(token?: string): Promise<Json> {
    return this.client.request('GET', '/v1/scim/v2/Schemas', { accessToken: this.token(token) });
  }

  schema(schemaId: string, token?: string): Promise<Json> {
    return this.client.request('GET', `/v1/scim/v2/Schemas/${schemaId}`, {
      accessToken: this.token(token),
    });
  }

  serviceProviderConfig(token?: string): Promise<Json> {
    return this.client.request('GET', '/v1/scim/v2/ServiceProviderConfig', {
      accessToken: this.token(token),
    });
  }
}

export class HrisResource {
  constructor(private readonly client: ManagementRequester) {}

  private token(token?: string): string | undefined {
    return token ?? this.client.hrisToken;
  }

  listDepartments(token?: string): Promise<Json> {
    return this.client.request('GET', '/v1/hris/v1/Departments', { accessToken: this.token(token) });
  }

  createDepartment(body: Json, token?: string): Promise<Json> {
    return this.client.request('POST', '/v1/hris/v1/Departments', {
      data: body,
      accessToken: this.token(token),
    });
  }

  getDepartment(departmentId: string, token?: string): Promise<Json> {
    return this.client.request('GET', `/v1/hris/v1/Departments/${departmentId}`, {
      accessToken: this.token(token),
    });
  }

  replaceDepartment(departmentId: string, body: Json, token?: string): Promise<Json> {
    return this.client.request('PUT', `/v1/hris/v1/Departments/${departmentId}`, {
      data: body,
      accessToken: this.token(token),
    });
  }

  patchDepartment(departmentId: string, body: Json, token?: string): Promise<Json> {
    return this.client.request('PATCH', `/v1/hris/v1/Departments/${departmentId}`, {
      data: body,
      accessToken: this.token(token),
    });
  }

  deleteDepartment(departmentId: string, token?: string): Promise<Json> {
    return this.client.request('DELETE', `/v1/hris/v1/Departments/${departmentId}`, {
      accessToken: this.token(token),
    });
  }

  listEmployees(token?: string): Promise<Json> {
    return this.client.request('GET', '/v1/hris/v1/Employees', { accessToken: this.token(token) });
  }

  createEmployee(body: Json, token?: string): Promise<Json> {
    return this.client.request('POST', '/v1/hris/v1/Employees', {
      data: body,
      accessToken: this.token(token),
    });
  }

  getEmployee(employeeId: string, token?: string): Promise<Json> {
    return this.client.request('GET', `/v1/hris/v1/Employees/${employeeId}`, {
      accessToken: this.token(token),
    });
  }

  replaceEmployee(employeeId: string, body: Json, token?: string): Promise<Json> {
    return this.client.request('PUT', `/v1/hris/v1/Employees/${employeeId}`, {
      data: body,
      accessToken: this.token(token),
    });
  }

  patchEmployee(employeeId: string, body: Json, token?: string): Promise<Json> {
    return this.client.request('PATCH', `/v1/hris/v1/Employees/${employeeId}`, {
      data: body,
      accessToken: this.token(token),
    });
  }

  deleteEmployee(employeeId: string, token?: string): Promise<Json> {
    return this.client.request('DELETE', `/v1/hris/v1/Employees/${employeeId}`, {
      accessToken: this.token(token),
    });
  }

  serviceConfig(token?: string): Promise<Json> {
    return this.client.request('GET', '/v1/hris/v1/ServiceConfig', {
      accessToken: this.token(token),
    });
  }
}

export class McpResource {
  constructor(private readonly client: ManagementRequester) {}

  private runtime(token?: string): string | undefined {
    return token ?? this.client.environmentSecret;
  }

  ingestEvents(body: Json, token?: string): Promise<Json> {
    return this.client.request('POST', '/v1/mcp/events', {
      data: body,
      accessToken: this.runtime(token),
    });
  }

  resolve(subject: string, token?: string): Promise<Json> {
    return this.client.request('GET', '/v1/mcp/trust-store/resolve', {
      params: { subject },
      accessToken: this.runtime(token),
    });
  }

  listEntries(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/mcp/trust-store`);
  }

  createEntry(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/mcp/trust-store`, {
      data: body,
    });
  }

  getEntry(tenantId: string, environmentId: string, entryId: string): Promise<Json> {
    return this.client.request(
      'GET',
      `${envPath(tenantId, environmentId)}/mcp/trust-store/${entryId}`
    );
  }

  updateEntry(tenantId: string, environmentId: string, entryId: string, body: Json): Promise<Json> {
    return this.client.request(
      'PATCH',
      `${envPath(tenantId, environmentId)}/mcp/trust-store/${entryId}`,
      { data: body }
    );
  }

  deleteEntry(tenantId: string, environmentId: string, entryId: string): Promise<Json> {
    return this.client.request(
      'DELETE',
      `${envPath(tenantId, environmentId)}/mcp/trust-store/${entryId}`
    );
  }

  addKey(tenantId: string, environmentId: string, entryId: string, body: Json): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/mcp/trust-store/${entryId}/keys`,
      { data: body }
    );
  }

  revokeKey(tenantId: string, environmentId: string, entryId: string, keyId: string): Promise<Json> {
    return this.client.request(
      'DELETE',
      `${envPath(tenantId, environmentId)}/mcp/trust-store/${entryId}/keys/${keyId}`
    );
  }

  rotateKey(
    tenantId: string,
    environmentId: string,
    entryId: string,
    keyId: string,
    body?: Json
  ): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/mcp/trust-store/${entryId}/keys/${keyId}/rotate`,
      body !== undefined ? { data: body } : undefined
    );
  }

  revokeEntry(tenantId: string, environmentId: string, entryId: string): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/mcp/trust-store/${entryId}/revoke`
    );
  }

  verifyEntry(tenantId: string, environmentId: string, entryId: string, body: Json): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/mcp/trust-store/${entryId}/verify`,
      { data: body }
    );
  }
}

export class OtelResource {
  constructor(private readonly client: ManagementRequester) {}

  exportLogs(body: Json): Promise<Json> {
    return this.client.request('POST', '/v1/logs', { data: body });
  }

  exportMetrics(body: Json): Promise<Json> {
    return this.client.request('POST', '/v1/metrics', { data: body });
  }

  exportTraces(body: Json): Promise<Json> {
    return this.client.request('POST', '/v1/traces', { data: body });
  }

  exportLogsPrefixed(body: Json): Promise<Json> {
    return this.client.request('POST', '/v1/otel/v1/logs', { data: body });
  }

  exportMetricsPrefixed(body: Json): Promise<Json> {
    return this.client.request('POST', '/v1/otel/v1/metrics', { data: body });
  }

  exportTracesPrefixed(body: Json): Promise<Json> {
    return this.client.request('POST', '/v1/otel/v1/traces', { data: body });
  }
}

export class OidcClientsResource {
  constructor(private readonly client: ManagementRequester) {}

  private path(tenantId: string, applicationId: string, environmentId: string): string {
    return `/v1/tenants/${tenantId}/applications/${applicationId}/environments/${environmentId}/oidc-clients`;
  }

  list(tenantId: string, applicationId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', this.path(tenantId, applicationId, environmentId));
  }

  register(
    tenantId: string,
    applicationId: string,
    environmentId: string,
    body: Json
  ): Promise<Json> {
    return this.client.request('POST', this.path(tenantId, applicationId, environmentId), {
      data: body,
    });
  }

  update(
    tenantId: string,
    applicationId: string,
    environmentId: string,
    clientId: string,
    body: Json
  ): Promise<Json> {
    return this.client.request(
      'PATCH',
      `${this.path(tenantId, applicationId, environmentId)}/${clientId}`,
      { data: body }
    );
  }

  delete(
    tenantId: string,
    applicationId: string,
    environmentId: string,
    clientId: string
  ): Promise<Json> {
    return this.client.request(
      'DELETE',
      `${this.path(tenantId, applicationId, environmentId)}/${clientId}`
    );
  }
}

export class ActionsResource {
  constructor(private readonly client: ManagementRequester) {}

  list(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/actions`);
  }

  save(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/actions`, {
      data: body,
    });
  }

  executions(
    tenantId: string,
    environmentId: string,
    actionId?: string,
    limit?: number
  ): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/actions/executions`, {
      params: compactParams({ actionId, limit }),
    });
  }

  test(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/actions/test`, {
      data: body,
    });
  }

  delete(tenantId: string, environmentId: string, actionId: string): Promise<Json> {
    return this.client.request('DELETE', `${envPath(tenantId, environmentId)}/actions/${actionId}`);
  }
}

export class AddonsResource {
  constructor(private readonly client: ManagementRequester) {}

  list(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/addons`);
  }

  save(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/addons`, {
      data: body,
    });
  }

  delete(tenantId: string, environmentId: string, provider: string): Promise<Json> {
    return this.client.request('DELETE', `${envPath(tenantId, environmentId)}/addons/${provider}`);
  }
}

export class BillingResource {
  constructor(private readonly client: ManagementRequester) {}

  listFeatures(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/billing/features`);
  }

  saveFeature(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/billing/features`, {
      data: body,
    });
  }

  deleteFeature(tenantId: string, environmentId: string, featureId: string): Promise<Json> {
    return this.client.request(
      'DELETE',
      `${envPath(tenantId, environmentId)}/billing/features/${featureId}`
    );
  }

  listPlans(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/billing/plans`);
  }

  savePlan(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/billing/plans`, {
      data: body,
    });
  }

  deletePlan(tenantId: string, environmentId: string, planId: string): Promise<Json> {
    return this.client.request(
      'DELETE',
      `${envPath(tenantId, environmentId)}/billing/plans/${planId}`
    );
  }

  syncStripe(tenantId: string, environmentId: string, planId: string): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/billing/plans/${planId}/sync-stripe`
    );
  }
}

export class SettingsResource {
  constructor(private readonly client: ManagementRequester) {}

  private get(tenantId: string, environmentId: string, suffix: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/${suffix}`);
  }

  private put(tenantId: string, environmentId: string, suffix: string, body: Json): Promise<Json> {
    return this.client.request('PUT', `${envPath(tenantId, environmentId)}/${suffix}`, {
      data: body,
    });
  }

  getBotDetectionPolicy(tenantId: string, environmentId: string): Promise<Json> {
    return this.get(tenantId, environmentId, 'bot-detection-policy');
  }

  updateBotDetectionPolicy(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.put(tenantId, environmentId, 'bot-detection-policy', body);
  }

  getBreachedPasswordPolicy(tenantId: string, environmentId: string): Promise<Json> {
    return this.get(tenantId, environmentId, 'breached-password-policy');
  }

  updateBreachedPasswordPolicy(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.put(tenantId, environmentId, 'breached-password-policy', body);
  }

  getBruteForcePolicy(tenantId: string, environmentId: string): Promise<Json> {
    return this.get(tenantId, environmentId, 'brute-force-policy');
  }

  updateBruteForcePolicy(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.put(tenantId, environmentId, 'brute-force-policy', body);
  }

  getDeviceRiskPolicy(tenantId: string, environmentId: string): Promise<Json> {
    return this.get(tenantId, environmentId, 'device-risk-policy');
  }

  updateDeviceRiskPolicy(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.put(tenantId, environmentId, 'device-risk-policy', body);
  }

  listJwtClaimMappings(tenantId: string, environmentId: string): Promise<Json> {
    return this.get(tenantId, environmentId, 'jwt-claim-mappings');
  }

  saveJwtClaimMapping(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/jwt-claim-mappings`, {
      data: body,
    });
  }

  deleteJwtClaimMapping(tenantId: string, environmentId: string, mappingId: string): Promise<Json> {
    return this.client.request(
      'DELETE',
      `${envPath(tenantId, environmentId)}/jwt-claim-mappings/${mappingId}`
    );
  }

  getPasswordPolicy(tenantId: string, environmentId: string): Promise<Json> {
    return this.get(tenantId, environmentId, 'password-policy');
  }

  updatePasswordPolicy(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.put(tenantId, environmentId, 'password-policy', body);
  }

  getRateLimitPolicy(tenantId: string, environmentId: string): Promise<Json> {
    return this.get(tenantId, environmentId, 'rate-limit-policy');
  }

  updateRateLimitPolicy(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.put(tenantId, environmentId, 'rate-limit-policy', body);
  }

  getRestrictions(tenantId: string, environmentId: string): Promise<Json> {
    return this.get(tenantId, environmentId, 'restrictions');
  }

  updateRestrictions(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.put(tenantId, environmentId, 'restrictions', body);
  }

  getSessionConfig(tenantId: string, environmentId: string): Promise<Json> {
    return this.get(tenantId, environmentId, 'session-config');
  }

  updateSessionConfig(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.put(tenantId, environmentId, 'session-config', body);
  }
}

export class ElevateResource {
  constructor(private readonly client: ManagementRequester) {}

  activateGrant(
    tenantId: string,
    environmentId: string,
    grantId: string,
    body: Json
  ): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/elevate/access-grants/${grantId}/activate`,
      { data: body }
    );
  }

  revokeGrant(tenantId: string, environmentId: string, grantId: string, body: Json): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/elevate/access-grants/${grantId}/revoke`,
      { data: body }
    );
  }

  listRequests(tenantId: string, environmentId: string, status?: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/elevate/access-requests`, {
      params: compactParams({ status }),
    });
  }

  createRequest(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/elevate/access-requests`, {
      data: body,
    });
  }

  getRequest(tenantId: string, environmentId: string, requestId: string): Promise<Json> {
    return this.client.request(
      'GET',
      `${envPath(tenantId, environmentId)}/elevate/access-requests/${requestId}`
    );
  }

  approveRequest(
    tenantId: string,
    environmentId: string,
    requestId: string,
    body: Json
  ): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/elevate/access-requests/${requestId}/approve`,
      { data: body }
    );
  }

  cancelRequest(tenantId: string, environmentId: string, requestId: string): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/elevate/access-requests/${requestId}/cancel`
    );
  }

  denyRequest(
    tenantId: string,
    environmentId: string,
    requestId: string,
    body: Json
  ): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/elevate/access-requests/${requestId}/deny`,
      { data: body }
    );
  }

  getPolicy(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/elevate/policy`);
  }

  updatePolicy(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('PUT', `${envPath(tenantId, environmentId)}/elevate/policy`, {
      data: body,
    });
  }
}

export class EmailProvidersResource {
  constructor(private readonly client: ManagementRequester) {}

  list(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/email-providers`);
  }

  save(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/email-providers`, {
      data: body,
    });
  }

  test(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/email-providers/test`, {
      data: body,
    });
  }

  delete(tenantId: string, environmentId: string, provider: string): Promise<Json> {
    return this.client.request(
      'DELETE',
      `${envPath(tenantId, environmentId)}/email-providers/${provider}`
    );
  }

  activate(tenantId: string, environmentId: string, provider: string): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/email-providers/${provider}/activate`
    );
  }
}

export class FeatureFlagsResource {
  constructor(private readonly client: ManagementRequester) {}

  list(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/feature-flags`);
  }

  save(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/feature-flags`, {
      data: body,
    });
  }

  delete(tenantId: string, environmentId: string, flagId: string): Promise<Json> {
    return this.client.request(
      'DELETE',
      `${envPath(tenantId, environmentId)}/feature-flags/${flagId}`
    );
  }
}

export class FormsResource {
  constructor(private readonly client: ManagementRequester) {}

  listAttachments(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/form-attachments`);
  }

  list(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/forms`);
  }

  save(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/forms`, { data: body });
  }

  delete(tenantId: string, environmentId: string, formId: string): Promise<Json> {
    return this.client.request('DELETE', `${envPath(tenantId, environmentId)}/forms/${formId}`);
  }
}

export class ProvisioningTokensResource {
  constructor(private readonly client: ManagementRequester) {}

  listHris(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/hris-tokens`);
  }

  createHris(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/hris-tokens`, {
      data: body,
    });
  }

  revokeHris(tenantId: string, environmentId: string, tokenId: string): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/hris-tokens/${tokenId}/revoke`
    );
  }

  rotateHris(tenantId: string, environmentId: string, tokenId: string): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/hris-tokens/${tokenId}/rotate`
    );
  }

  listScim(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/scim-tokens`);
  }

  createScim(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/scim-tokens`, {
      data: body,
    });
  }

  revokeScim(tenantId: string, environmentId: string, tokenId: string): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/scim-tokens/${tokenId}/revoke`
    );
  }

  rotateScim(tenantId: string, environmentId: string, tokenId: string): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/scim-tokens/${tokenId}/rotate`
    );
  }
}

export class ImpersonationResource {
  constructor(private readonly client: ManagementRequester) {}

  list(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/impersonation-grants`);
  }

  create(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/impersonation-grants`, {
      data: body,
    });
  }

  revoke(tenantId: string, environmentId: string, grantId: string): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/impersonation-grants/${grantId}/revoke`
    );
  }
}

export class PortalResource {
  constructor(private readonly client: ManagementRequester) {}

  generateLink(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/portal/generate-link`, {
      data: body,
    });
  }
}

export class SecurityResource {
  constructor(private readonly client: ManagementRequester) {}

  posture(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/security/posture`);
  }
}

export class ThreatsResource {
  constructor(private readonly client: ManagementRequester) {}

  list(tenantId: string, environmentId: string, params?: Json): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/threats`, { params });
  }

  create(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/threats`, { data: body });
  }

  get(tenantId: string, environmentId: string, threatId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/threats/${threatId}`);
  }

  update(tenantId: string, environmentId: string, threatId: string, body: Json): Promise<Json> {
    return this.client.request('PATCH', `${envPath(tenantId, environmentId)}/threats/${threatId}`, {
      data: body,
    });
  }

  delete(tenantId: string, environmentId: string, threatId: string): Promise<Json> {
    return this.client.request('DELETE', `${envPath(tenantId, environmentId)}/threats/${threatId}`);
  }

  resolve(tenantId: string, environmentId: string, threatId: string, body: Json): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/threats/${threatId}/resolve`,
      { data: body }
    );
  }
}

export class VanityDomainsResource {
  constructor(private readonly client: ManagementRequester) {}

  list(tenantId: string, environmentId: string): Promise<Json> {
    return this.client.request('GET', `${envPath(tenantId, environmentId)}/vanity-domains`);
  }

  create(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/vanity-domains`, {
      data: body,
    });
  }

  delete(tenantId: string, environmentId: string, domainId: string): Promise<Json> {
    return this.client.request(
      'DELETE',
      `${envPath(tenantId, environmentId)}/vanity-domains/${domainId}`
    );
  }

  check(tenantId: string, environmentId: string, domainId: string): Promise<Json> {
    return this.client.request(
      'POST',
      `${envPath(tenantId, environmentId)}/vanity-domains/${domainId}/check`
    );
  }
}

export class WidgetsResource {
  constructor(private readonly client: ManagementRequester) {}

  createToken(tenantId: string, environmentId: string, body: Json): Promise<Json> {
    return this.client.request('POST', `${envPath(tenantId, environmentId)}/widgets/token`, {
      data: body,
    });
  }
}
