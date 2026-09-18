import axios from 'axios';
import { AuthdogClient } from '../src/client';
import { APIError, AuthenticationError } from '../src/exceptions';
import { vi } from 'vitest';

vi.mock('axios');
const mockedAxios = axios as any;

describe('Wave 1 management', () => {
  let client: AuthdogClient;
  let mockAxiosInstance: any;

  beforeEach(() => {
    mockAxiosInstance = {
      get: vi.fn(),
      post: vi.fn(),
      put: vi.fn(),
      patch: vi.fn(),
      delete: vi.fn(),
      request: vi.fn(),
    };
    mockedAxios.create.mockReturnValue(mockAxiosInstance);
    mockedAxios.isAxiosError.mockReturnValue(false);
    client = new AuthdogClient({
      baseUrl: 'https://api.authdog.com',
      apiKey: 'key-1',
    });
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it('health returns probe', async () => {
    mockAxiosInstance.request.mockResolvedValue({ data: { ok: true } });
    const probe = await client.health();
    expect(probe.ok).toBe(true);
    expect(mockAxiosInstance.request).toHaveBeenCalledWith({
      method: 'GET',
      url: '/v1/health',
    });
  });

  it('organizations.list uses constructor api key defaults and empty list', async () => {
    mockAxiosInstance.request.mockResolvedValue({
      data: { organizations: [], total: 0 },
    });
    const result = await client.organizations.list();
    expect(result.organizations).toEqual([]);
    expect(result.total).toBe(0);
    expect(mockedAxios.create).toHaveBeenCalledWith(
      expect.objectContaining({
        headers: expect.objectContaining({
          Authorization: 'Bearer key-1',
        }),
      })
    );
  });

  it('management 401 is AuthenticationError', async () => {
    mockedAxios.isAxiosError.mockReturnValue(true);
    mockAxiosInstance.request.mockRejectedValue({
      isAxiosError: true,
      response: { status: 401, data: { error: 'Unauthorized' } },
    });
    await expect(client.organizations.list()).rejects.toThrow(AuthenticationError);
  });

  it('management 404 includes status and error', async () => {
    mockedAxios.isAxiosError.mockReturnValue(true);
    mockAxiosInstance.request.mockRejectedValue({
      isAxiosError: true,
      response: { status: 404, data: { error: 'not found' } },
    });
    await expect(client.organizations.get('missing')).rejects.toMatchObject({
      name: 'APIError',
      statusCode: 404,
      message: expect.stringContaining('HTTP error 404'),
    });
  });

  it('transport failure is APIError', async () => {
    mockedAxios.isAxiosError.mockReturnValue(false);
    mockAxiosInstance.request.mockRejectedValue(new Error('Connection failed'));
    await expect(client.tenants.list()).rejects.toThrow(APIError);
    await expect(client.tenants.list()).rejects.toThrow('Request failed: Connection failed');
  });

  it('users.list parses empty and item', async () => {
    mockAxiosInstance.request.mockResolvedValueOnce({
      data: {
        users: [{ id: 'usr_1', displayName: 'Ada', emails: [{ value: 'ada@example.com' }] }],
      },
    });
    const listed = await client.users.list('ten_1', 'env_1');
    expect(listed.users[0].id).toBe('usr_1');
    expect(listed.users[0].displayName).toBe('Ada');

    mockAxiosInstance.request.mockResolvedValueOnce({ data: { users: [] } });
    const empty = await client.users.list('ten_1', 'env_1');
    expect(empty.users).toEqual([]);
  });

  const cases: Array<[string, () => Promise<unknown>, string, string, unknown]> = [
    ['orgs list', () => client.organizations.list(), 'GET', '/v1/organizations', undefined],
    ['orgs create', () => client.organizations.create({ name: 'Acme' }), 'POST', '/v1/organizations', { name: 'Acme' }],
    ['orgs get', () => client.organizations.get('org_1'), 'GET', '/v1/organizations/org_1', undefined],
    ['orgs update', () => client.organizations.update('org_1', { name: 'New' }), 'PATCH', '/v1/organizations/org_1', { name: 'New' }],
    ['orgs delete', () => client.organizations.delete('org_1'), 'DELETE', '/v1/organizations/org_1', undefined],
    ['orgs accept', () => client.organizations.acceptInvitation({ token: 't' }), 'POST', '/v1/organizations/invitations/accept', { token: 't' }],
    ['orgs join', () => client.organizations.join({ invitationCode: 'c' }), 'POST', '/v1/organizations/join', { invitationCode: 'c' }],
    ['orgs invitations', () => client.organizations.listInvitations('org_1'), 'GET', '/v1/organizations/org_1/invitations', undefined],
    ['orgs create invitation', () => client.organizations.createInvitation('org_1', { email: 'a@b.c' }), 'POST', '/v1/organizations/org_1/invitations', { email: 'a@b.c' }],
    ['orgs cancel invitation', () => client.organizations.cancelInvitation('org_1', 'inv_1'), 'POST', '/v1/organizations/org_1/invitations/inv_1/cancel', undefined],
    ['orgs send invite', () => client.organizations.sendInvite('org_1', { email: 'a@b.c' }), 'POST', '/v1/organizations/org_1/invites', { email: 'a@b.c' }],
    ['orgs members', () => client.organizations.listMembers('org_1'), 'GET', '/v1/organizations/org_1/members', undefined],
    ['orgs remove member', () => client.organizations.removeMember('org_1', 'mem_1'), 'DELETE', '/v1/organizations/org_1/members/mem_1', undefined],
    ['orgs set member active', () => client.organizations.setMemberActive('org_1', 'mem_1', { active: false }), 'PATCH', '/v1/organizations/org_1/members/mem_1/active', { active: false }],
    ['orgs link tenant', () => client.organizations.linkTenant('org_1', { tenantId: 'ten_1' }), 'POST', '/v1/organizations/org_1/tenants', { tenantId: 'ten_1' }],
    ['orgs unlink tenant', () => client.organizations.unlinkTenant('org_1', 'ten_1'), 'DELETE', '/v1/organizations/org_1/tenants/ten_1', undefined],
    ['tenants list', () => client.tenants.list(), 'GET', '/v1/tenants', undefined],
    ['tenants create', () => client.tenants.create({ name: 'T' }), 'POST', '/v1/tenants', { name: 'T' }],
    ['tenants join', () => client.tenants.join({ invitationCode: 'c' }), 'POST', '/v1/tenants/join', { invitationCode: 'c' }],
    ['tenants get', () => client.tenants.get('ten_1'), 'GET', '/v1/tenants/ten_1', undefined],
    ['tenants update', () => client.tenants.update('ten_1', { name: 'N' }), 'PATCH', '/v1/tenants/ten_1', { name: 'N' }],
    ['tenants delete', () => client.tenants.delete('ten_1'), 'DELETE', '/v1/tenants/ten_1', undefined],
    ['tenants domains', () => client.tenants.listDomains('ten_1'), 'GET', '/v1/tenants/ten_1/domains', undefined],
    ['tenants create domain', () => client.tenants.createDomain('ten_1', { domain: 'a.com', validationMethod: 'dns' }), 'POST', '/v1/tenants/ten_1/domains', { domain: 'a.com', validationMethod: 'dns' }],
    ['tenants delete domain', () => client.tenants.deleteDomain('ten_1', 'dom_1'), 'DELETE', '/v1/tenants/ten_1/domains/dom_1', undefined],
    ['tenants retry domain', () => client.tenants.retryDomain('ten_1', 'dom_1'), 'POST', '/v1/tenants/ten_1/domains/dom_1/retry', undefined],
    ['tenants invite', () => client.tenants.sendInvite('ten_1', { email: 'a@b.c' }), 'POST', '/v1/tenants/ten_1/invites', { email: 'a@b.c' }],
    ['tenants projects', () => client.tenants.listProjects('ten_1'), 'GET', '/v1/tenants/ten_1/projects', undefined],
    ['tenants seats', () => client.tenants.listSeats('ten_1'), 'GET', '/v1/tenants/ten_1/seats', undefined],
    ['tenants update seat', () => client.tenants.updateSeat('ten_1', 'seat_1', { active: true }), 'PATCH', '/v1/tenants/ten_1/seats/seat_1', { active: true }],
    ['tenants delete seat', () => client.tenants.deleteSeat('ten_1', 'seat_1'), 'DELETE', '/v1/tenants/ten_1/seats/seat_1', undefined],
    ['projects save', () => client.projects.save('ten_1', { name: 'App' }), 'POST', '/v1/tenants/ten_1/applications', { name: 'App' }],
    ['projects get', () => client.projects.get('ten_1', 'app_1'), 'GET', '/v1/tenants/ten_1/applications/app_1', undefined],
    ['projects delete', () => client.projects.delete('ten_1', 'app_1'), 'DELETE', '/v1/tenants/ten_1/applications/app_1', undefined],
    ['projects default env', () => client.projects.setDefaultEnvironment('ten_1', 'app_1', { environmentId: 'env_1' }), 'PUT', '/v1/tenants/ten_1/applications/app_1/default-environment', { environmentId: 'env_1' }],
    ['envs list', () => client.environments.list('ten_1', 'app_1'), 'GET', '/v1/tenants/ten_1/applications/app_1/environments', undefined],
    ['envs create', () => client.environments.create('ten_1', 'app_1', { name: 'prod' }), 'POST', '/v1/tenants/ten_1/applications/app_1/environments', { name: 'prod' }],
    ['envs update', () => client.environments.update('ten_1', 'env_1', { name: 'prod' }), 'PATCH', '/v1/tenants/ten_1/environments/env_1', { name: 'prod' }],
    ['envs delete', () => client.environments.delete('ten_1', 'env_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1', undefined],
    ['users list', () => client.users.list('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/users', undefined],
    ['users create', () => client.users.create('ten_1', 'env_1', { email: 'a@b.c', password: 'x' }), 'POST', '/v1/tenants/ten_1/environments/env_1/users', { email: 'a@b.c', password: 'x' }],
    ['users search', () => client.users.search('ten_1', 'env_1', { q: 'ada' }), 'GET', '/v1/tenants/ten_1/environments/env_1/users/search', undefined],
    ['users count', () => client.users.count('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/users/count', undefined],
    ['users get', () => client.users.get('ten_1', 'env_1', 'usr_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/users/usr_1', undefined],
    ['users update', () => client.users.update('ten_1', 'env_1', 'usr_1', { displayName: 'Ada' }), 'PUT', '/v1/tenants/ten_1/environments/env_1/users/usr_1', { displayName: 'Ada' }],
    ['users delete', () => client.users.delete('ten_1', 'env_1', 'usr_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/users/usr_1', undefined],
    ['users set active', () => client.users.setActive('ten_1', 'env_1', 'usr_1', { active: false }), 'PATCH', '/v1/tenants/ten_1/environments/env_1/users/usr_1/active', { active: false }],
    ['users groups', () => client.users.listGroups('ten_1', 'env_1', 'usr_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/users/usr_1/groups', undefined],
    ['groups create', () => client.groups.create({ environmentId: 'env_1', name: 'Admins' }), 'POST', '/v1/groups', { environmentId: 'env_1', name: 'Admins' }],
    ['groups list', () => client.groups.list('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/groups', undefined],
    ['groups delete', () => client.groups.delete('ten_1', 'env_1', 'grp_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/groups/grp_1', undefined],
    ['groups members', () => client.groups.listMembers('ten_1', 'env_1', 'grp_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/groups/grp_1/members', undefined],
    ['groups add member', () => client.groups.addMember('ten_1', 'env_1', 'grp_1', { userId: 'usr_1' }), 'POST', '/v1/tenants/ten_1/environments/env_1/groups/grp_1/members', { userId: 'usr_1' }],
    ['groups remove member', () => client.groups.removeMember('ten_1', 'env_1', 'grp_1', 'usr_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/groups/grp_1/members/usr_1', undefined],
  ];

  it.each(cases)('%s hits %s %s', async (_name, call, method, url, data) => {
    mockAxiosInstance.request.mockResolvedValue({ data: {} });
    await call();
    expect(mockAxiosInstance.request).toHaveBeenCalledWith(
      expect.objectContaining({
        method,
        url,
        ...(data !== undefined ? { data } : {}),
      })
    );
  });
});

describe('Wave 2 management', () => {
  let client: AuthdogClient;
  let mockAxiosInstance: any;

  beforeEach(() => {
    mockAxiosInstance = {
      get: vi.fn(),
      post: vi.fn(),
      put: vi.fn(),
      patch: vi.fn(),
      delete: vi.fn(),
      request: vi.fn(),
    };
    mockedAxios.create.mockReturnValue(mockAxiosInstance);
    mockedAxios.isAxiosError.mockReturnValue(false);
    client = new AuthdogClient({
      baseUrl: 'https://api.authdog.com',
      apiKey: 'key-1',
    });
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  const wave2Cases: Array<[string, () => Promise<unknown>, string, string, unknown]> = [
    ['orgs list keys', () => client.organizations.listKeys('org_1'), 'GET', '/v1/organizations/org_1/keys', undefined],
    ['orgs create key', () => client.organizations.createKey('org_1', { name: 'ci' }), 'POST', '/v1/organizations/org_1/keys', { name: 'ci' }],
    ['orgs revoke key', () => client.organizations.revokeKey('org_1', 'key_1'), 'POST', '/v1/organizations/org_1/keys/key_1/revoke', undefined],
    ['orgs rotate key', () => client.organizations.rotateKey('org_1', 'key_1'), 'POST', '/v1/organizations/org_1/keys/key_1/rotate', undefined],
    ['orgs update key tenants', () => client.organizations.updateKeyTenants('org_1', 'key_1', { tenantIds: ['ten_1'] }), 'PUT', '/v1/organizations/org_1/keys/key_1/tenants', { tenantIds: ['ten_1'] }],
    ['orgs list audit logs', () => client.organizations.listAuditLogs('org_1'), 'GET', '/v1/organizations/org_1/audit/logs', undefined],
    ['service accounts list', () => client.serviceAccounts.list(), 'GET', '/v1/service-accounts', undefined],
    ['service accounts create', () => client.serviceAccounts.create({ name: 'bot' }), 'POST', '/v1/service-accounts', { name: 'bot' }],
    ['service accounts get', () => client.serviceAccounts.get('sa_1'), 'GET', '/v1/service-accounts/sa_1', undefined],
    ['service accounts delete', () => client.serviceAccounts.delete('sa_1'), 'DELETE', '/v1/service-accounts/sa_1', undefined],
    ['pats list', () => client.personalAccessTokens.list(), 'GET', '/v1/personal-access-tokens', undefined],
    ['pats create', () => client.personalAccessTokens.create({ name: 'cli' }), 'POST', '/v1/personal-access-tokens', { name: 'cli' }],
    ['pats revoke', () => client.personalAccessTokens.revoke('pat_1'), 'POST', '/v1/personal-access-tokens/pat_1/revoke', undefined],
    ['api secrets list', () => client.apiSecrets.list('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/api-secrets', undefined],
    ['api secrets create', () => client.apiSecrets.create('ten_1', 'env_1', { name: 'runtime' }), 'POST', '/v1/tenants/ten_1/environments/env_1/api-secrets', { name: 'runtime' }],
    ['api secrets revoke', () => client.apiSecrets.revoke('ten_1', 'env_1', 'sec_1'), 'POST', '/v1/tenants/ten_1/environments/env_1/api-secrets/sec_1/revoke', undefined],
    ['audit list logs', () => client.audit.listLogs('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/audit/logs', undefined],
    ['audit event metadata', () => client.audit.eventMetadata('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/audit/event-metadata', undefined],
    ['audit event types', () => client.audit.eventTypes('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/audit/event-types', undefined],
    ['audit event types catalog', () => client.audit.eventTypesCatalog('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/audit/event-types/catalog', undefined],
    ['events list', () => client.events.list('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/events', undefined],
    ['events list types', () => client.events.listTypes('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/events/types', undefined],
    ['events ingest', () => client.events.ingest('ten_1', 'env_1', { events: [] }), 'POST', '/v1/tenants/ten_1/environments/env_1/events/ingest', { events: [] }],
    ['webhooks list', () => client.webhooks.list('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/webhooks', undefined],
    ['webhooks create', () => client.webhooks.create('ten_1', 'env_1', { url: 'https://ex' }), 'POST', '/v1/tenants/ten_1/environments/env_1/webhooks', { url: 'https://ex' }],
    ['webhooks update', () => client.webhooks.update('ten_1', 'env_1', 'ch_1', { url: 'https://ex' }), 'PUT', '/v1/tenants/ten_1/environments/env_1/webhooks/ch_1', { url: 'https://ex' }],
    ['webhooks delete', () => client.webhooks.delete('ten_1', 'env_1', 'ch_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/webhooks/ch_1', undefined],
    ['webhooks rotate secret', () => client.webhooks.rotateSecret('ten_1', 'env_1', 'ch_1'), 'POST', '/v1/tenants/ten_1/environments/env_1/webhooks/ch_1/rotate-secret', undefined],
    ['webhooks deliveries', () => client.webhooks.listDeliveries('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/webhooks/deliveries', undefined],
    ['webhooks redeliver', () => client.webhooks.redeliver('ten_1', 'env_1', 'del_1'), 'POST', '/v1/tenants/ten_1/environments/env_1/webhooks/deliveries/del_1/redeliver', undefined],
    ['notification channels list', () => client.notificationChannels.list('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/notification-channels', undefined],
    ['notification channels create', () => client.notificationChannels.create('ten_1', 'env_1', { type: 'webhook' }), 'POST', '/v1/tenants/ten_1/environments/env_1/notification-channels', { type: 'webhook' }],
    ['notification channels update', () => client.notificationChannels.update('ten_1', 'env_1', 'ch_1', { name: 'n' }), 'PUT', '/v1/tenants/ten_1/environments/env_1/notification-channels/ch_1', { name: 'n' }],
    ['notification channels delete', () => client.notificationChannels.delete('ten_1', 'env_1', 'ch_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/notification-channels/ch_1', undefined],
    ['notification channels test', () => client.notificationChannels.test('ten_1', 'env_1', 'ch_1'), 'POST', '/v1/tenants/ten_1/environments/env_1/notification-channels/ch_1/test', undefined],
    ['rbac list roles', () => client.rbac.listRoles('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/roles', undefined],
    ['rbac create role', () => client.rbac.createRole('ten_1', 'env_1', { name: 'admin' }), 'POST', '/v1/tenants/ten_1/environments/env_1/roles', { name: 'admin' }],
    ['rbac delete role', () => client.rbac.deleteRole('ten_1', 'env_1', 'role_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/roles/role_1', undefined],
    ['rbac list role permissions', () => client.rbac.listRolePermissions('ten_1', 'env_1', 'role_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/roles/role_1/permissions', undefined],
    ['rbac set role permissions', () => client.rbac.setRolePermissions('ten_1', 'env_1', 'role_1', { permissionIds: [] }), 'PUT', '/v1/tenants/ten_1/environments/env_1/roles/role_1/permissions', { permissionIds: [] }],
    ['rbac list permissions', () => client.rbac.listPermissions('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/permissions', undefined],
    ['rbac create permission', () => client.rbac.createPermission('ten_1', 'env_1', { name: 'read' }), 'POST', '/v1/tenants/ten_1/environments/env_1/permissions', { name: 'read' }],
    ['rbac delete permission', () => client.rbac.deletePermission('ten_1', 'env_1', 'perm_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/permissions/perm_1', undefined],
    ['rbac list resources', () => client.rbac.listResources('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/resources', undefined],
    ['rbac create resource', () => client.rbac.createResource('ten_1', 'env_1', { name: 'doc' }), 'POST', '/v1/tenants/ten_1/environments/env_1/resources', { name: 'doc' }],
    ['rbac delete resource', () => client.rbac.deleteResource('ten_1', 'env_1', 'res_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/resources/res_1', undefined],
    ['rbac list group roles', () => client.rbac.listGroupRoles('ten_1', 'env_1', 'grp_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/groups/grp_1/roles', undefined],
    ['rbac add group role', () => client.rbac.addGroupRole('ten_1', 'env_1', 'grp_1', { roleId: 'role_1' }), 'POST', '/v1/tenants/ten_1/environments/env_1/groups/grp_1/roles', { roleId: 'role_1' }],
    ['rbac remove group role', () => client.rbac.removeGroupRole('ten_1', 'env_1', 'grp_1', 'role_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/groups/grp_1/roles/role_1', undefined],
    ['rbac list group role mappings', () => client.rbac.listGroupRoleMappings('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/group-role-mappings', undefined],
    ['rbac create group role mapping', () => client.rbac.createGroupRoleMapping('ten_1', 'env_1', { groupId: 'grp_1' }), 'POST', '/v1/tenants/ten_1/environments/env_1/group-role-mappings', { groupId: 'grp_1' }],
    ['rbac apply group role mappings', () => client.rbac.applyGroupRoleMappings('ten_1', 'env_1'), 'POST', '/v1/tenants/ten_1/environments/env_1/group-role-mappings/apply', undefined],
    ['rbac delete group role mapping', () => client.rbac.deleteGroupRoleMapping('ten_1', 'env_1', 'map_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/group-role-mappings/map_1', undefined],
    ['rbac list abac policies', () => client.rbac.listAbacPolicies('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/abac-policies', undefined],
    ['rbac save abac policy', () => client.rbac.saveAbacPolicy('ten_1', 'env_1', { name: 'p' }), 'POST', '/v1/tenants/ten_1/environments/env_1/abac-policies', { name: 'p' }],
    ['rbac validate abac policy', () => client.rbac.validateAbacPolicy('ten_1', 'env_1', { rego: 'x' }), 'POST', '/v1/tenants/ten_1/environments/env_1/abac-policies/validate', { rego: 'x' }],
    ['rbac delete abac policy', () => client.rbac.deleteAbacPolicy('ten_1', 'env_1', 'pol_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/abac-policies/pol_1', undefined],
    ['rbac my permissions', () => client.rbac.myPermissions('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/me/permissions', undefined],
  ];

  it.each(wave2Cases)('%s hits %s %s', async (_name, call, method, url, data) => {
    mockAxiosInstance.request.mockResolvedValue({ data: {} });
    await call();
    expect(mockAxiosInstance.request).toHaveBeenCalledWith(
      expect.objectContaining({
        method,
        url,
        ...(data !== undefined ? { data } : {}),
      })
    );
  });

  it('createKey exposes one-time secret', async () => {
    mockAxiosInstance.request.mockResolvedValue({
      data: { token: 'orgk_secret_once', key: { id: 'key_1' } },
    });
    const created = await client.organizations.createKey('org_1', { name: 'ci' });
    expect(created.token).toBe('orgk_secret_once');
  });

  it('events.list forwards query params', async () => {
    mockAxiosInstance.request.mockResolvedValue({ data: {} });
    await client.events.list('ten_1', 'env_1', { limit: 50, after: 'cur_1' });
    expect(mockAxiosInstance.request).toHaveBeenCalledWith(
      expect.objectContaining({
        method: 'GET',
        url: '/v1/tenants/ten_1/environments/env_1/events',
        params: { limit: 50, after: 'cur_1' },
      })
    );
  });
});

describe('Wave 3 management', () => {
  let client: AuthdogClient;
  let mockAxiosInstance: any;

  beforeEach(() => {
    mockAxiosInstance = {
      get: vi.fn(),
      post: vi.fn(),
      put: vi.fn(),
      patch: vi.fn(),
      delete: vi.fn(),
      request: vi.fn(),
    };
    mockedAxios.create.mockReturnValue(mockAxiosInstance);
    mockedAxios.isAxiosError.mockReturnValue(false);
    client = new AuthdogClient({
      baseUrl: 'https://api.authdog.com',
      apiKey: 'key-1',
    });
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  const wave3Cases: Array<[string, () => Promise<unknown>, string, string, unknown]> = [
    ['authzen configuration', () => client.authzen.configuration(), 'GET', '/.well-known/authzen-configuration', undefined],
    ['authzen evaluate', () => client.authzen.evaluate({ subject: {} }), 'POST', '/access/v1/evaluation', { subject: {} }],
    ['authzen evaluate batch', () => client.authzen.evaluateBatch({ evaluations: [] }), 'POST', '/access/v1/evaluations', { evaluations: [] }],
    ['authzen search action', () => client.authzen.searchAction({ subject: {} }), 'POST', '/access/v1/search/action', { subject: {} }],
    ['authzen search resource', () => client.authzen.searchResource({ subject: {} }), 'POST', '/access/v1/search/resource', { subject: {} }],
    ['authzen search subject', () => client.authzen.searchSubject({ resource: {} }), 'POST', '/access/v1/search/subject', { resource: {} }],
    ['users revoke session', () => client.users.revokeSession('env_1', 'sess_1'), 'DELETE', '/v1/environments/env_1/sessions/sess_1', undefined],
    ['hris list departments', () => client.hris.listDepartments(), 'GET', '/v1/hris/v1/Departments', undefined],
    ['hris create department', () => client.hris.createDepartment({ name: 'Eng' }), 'POST', '/v1/hris/v1/Departments', { name: 'Eng' }],
    ['hris get department', () => client.hris.getDepartment('dep_1'), 'GET', '/v1/hris/v1/Departments/dep_1', undefined],
    ['hris replace department', () => client.hris.replaceDepartment('dep_1', { name: 'Eng' }), 'PUT', '/v1/hris/v1/Departments/dep_1', { name: 'Eng' }],
    ['hris patch department', () => client.hris.patchDepartment('dep_1', { name: 'E' }), 'PATCH', '/v1/hris/v1/Departments/dep_1', { name: 'E' }],
    ['hris delete department', () => client.hris.deleteDepartment('dep_1'), 'DELETE', '/v1/hris/v1/Departments/dep_1', undefined],
    ['hris list employees', () => client.hris.listEmployees(), 'GET', '/v1/hris/v1/Employees', undefined],
    ['hris create employee', () => client.hris.createEmployee({ name: 'Ada' }), 'POST', '/v1/hris/v1/Employees', { name: 'Ada' }],
    ['hris get employee', () => client.hris.getEmployee('emp_1'), 'GET', '/v1/hris/v1/Employees/emp_1', undefined],
    ['hris replace employee', () => client.hris.replaceEmployee('emp_1', { name: 'Ada' }), 'PUT', '/v1/hris/v1/Employees/emp_1', { name: 'Ada' }],
    ['hris patch employee', () => client.hris.patchEmployee('emp_1', { name: 'A' }), 'PATCH', '/v1/hris/v1/Employees/emp_1', { name: 'A' }],
    ['hris delete employee', () => client.hris.deleteEmployee('emp_1'), 'DELETE', '/v1/hris/v1/Employees/emp_1', undefined],
    ['hris service config', () => client.hris.serviceConfig(), 'GET', '/v1/hris/v1/ServiceConfig', undefined],
    ['otel export logs', () => client.otel.exportLogs({ resourceLogs: [] }), 'POST', '/v1/logs', { resourceLogs: [] }],
    ['mcp ingest events', () => client.mcp.ingestEvents({ events: [] }), 'POST', '/v1/mcp/events', { events: [] }],
    ['mcp resolve', () => client.mcp.resolve('agent-1'), 'GET', '/v1/mcp/trust-store/resolve', undefined],
    ['otel export metrics', () => client.otel.exportMetrics({ resourceMetrics: [] }), 'POST', '/v1/metrics', { resourceMetrics: [] }],
    ['otel export logs prefixed', () => client.otel.exportLogsPrefixed({ resourceLogs: [] }), 'POST', '/v1/otel/v1/logs', { resourceLogs: [] }],
    ['otel export metrics prefixed', () => client.otel.exportMetricsPrefixed({ resourceMetrics: [] }), 'POST', '/v1/otel/v1/metrics', { resourceMetrics: [] }],
    ['otel export traces prefixed', () => client.otel.exportTracesPrefixed({ resourceSpans: [] }), 'POST', '/v1/otel/v1/traces', { resourceSpans: [] }],
    ['scim list groups', () => client.scim.listGroups(), 'GET', '/v1/scim/v2/Groups', undefined],
    ['scim create group', () => client.scim.createGroup({ displayName: 'G' }), 'POST', '/v1/scim/v2/Groups', { displayName: 'G' }],
    ['scim get group', () => client.scim.getGroup('g_1'), 'GET', '/v1/scim/v2/Groups/g_1', undefined],
    ['scim replace group', () => client.scim.replaceGroup('g_1', { displayName: 'G' }), 'PUT', '/v1/scim/v2/Groups/g_1', { displayName: 'G' }],
    ['scim patch group', () => client.scim.patchGroup('g_1', { Operations: [] }), 'PATCH', '/v1/scim/v2/Groups/g_1', { Operations: [] }],
    ['scim delete group', () => client.scim.deleteGroup('g_1'), 'DELETE', '/v1/scim/v2/Groups/g_1', undefined],
    ['scim resource types', () => client.scim.resourceTypes(), 'GET', '/v1/scim/v2/ResourceTypes', undefined],
    ['scim resource type', () => client.scim.resourceType('User'), 'GET', '/v1/scim/v2/ResourceTypes/User', undefined],
    ['scim schemas', () => client.scim.schemas(), 'GET', '/v1/scim/v2/Schemas', undefined],
    ['scim schema', () => client.scim.schema('urn:ietf:params:scim:schemas:core:2.0:User'), 'GET', '/v1/scim/v2/Schemas/urn:ietf:params:scim:schemas:core:2.0:User', undefined],
    ['scim service provider config', () => client.scim.serviceProviderConfig(), 'GET', '/v1/scim/v2/ServiceProviderConfig', undefined],
    ['scim list users', () => client.scim.listUsers(), 'GET', '/v1/scim/v2/Users', undefined],
    ['scim create user', () => client.scim.createUser({ userName: 'ada' }), 'POST', '/v1/scim/v2/Users', { userName: 'ada' }],
    ['scim get user', () => client.scim.getUser('u_1'), 'GET', '/v1/scim/v2/Users/u_1', undefined],
    ['scim replace user', () => client.scim.replaceUser('u_1', { userName: 'ada' }), 'PUT', '/v1/scim/v2/Users/u_1', { userName: 'ada' }],
    ['scim patch user', () => client.scim.patchUser('u_1', { Operations: [] }), 'PATCH', '/v1/scim/v2/Users/u_1', { Operations: [] }],
    ['scim delete user', () => client.scim.deleteUser('u_1'), 'DELETE', '/v1/scim/v2/Users/u_1', undefined],
    ['envs list connections', () => client.environments.listConnections('ten_1', 'app_1', 'env_1'), 'GET', '/v1/tenants/ten_1/applications/app_1/environments/env_1/connections', undefined],
    ['oidc clients list', () => client.oidcClients.list('ten_1', 'app_1', 'env_1'), 'GET', '/v1/tenants/ten_1/applications/app_1/environments/env_1/oidc-clients', undefined],
    ['oidc clients register', () => client.oidcClients.register('ten_1', 'app_1', 'env_1', { name: 'cli' }), 'POST', '/v1/tenants/ten_1/applications/app_1/environments/env_1/oidc-clients', { name: 'cli' }],
    ['oidc clients update', () => client.oidcClients.update('ten_1', 'app_1', 'env_1', 'cid_1', { name: 'n' }), 'PATCH', '/v1/tenants/ten_1/applications/app_1/environments/env_1/oidc-clients/cid_1', { name: 'n' }],
    ['oidc clients delete', () => client.oidcClients.delete('ten_1', 'app_1', 'env_1', 'cid_1'), 'DELETE', '/v1/tenants/ten_1/applications/app_1/environments/env_1/oidc-clients/cid_1', undefined],
    ['envs list redirect uris', () => client.environments.listRedirectUris('ten_1', 'app_1', 'env_1'), 'GET', '/v1/tenants/ten_1/applications/app_1/environments/env_1/redirect-uris', undefined],
    ['actions list', () => client.actions.list('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/actions', undefined],
    ['actions save', () => client.actions.save('ten_1', 'env_1', { url: 'https://ex' }), 'POST', '/v1/tenants/ten_1/environments/env_1/actions', { url: 'https://ex' }],
    ['actions executions', () => client.actions.executions('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/actions/executions', undefined],
    ['actions test', () => client.actions.test('ten_1', 'env_1', { url: 'https://ex' }), 'POST', '/v1/tenants/ten_1/environments/env_1/actions/test', { url: 'https://ex' }],
    ['actions delete', () => client.actions.delete('ten_1', 'env_1', 'act_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/actions/act_1', undefined],
    ['addons list', () => client.addons.list('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/addons', undefined],
    ['addons save', () => client.addons.save('ten_1', 'env_1', { provider: 'slack' }), 'POST', '/v1/tenants/ten_1/environments/env_1/addons', { provider: 'slack' }],
    ['addons delete', () => client.addons.delete('ten_1', 'env_1', 'slack'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/addons/slack', undefined],
    ['billing list features', () => client.billing.listFeatures('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/billing/features', undefined],
    ['billing save feature', () => client.billing.saveFeature('ten_1', 'env_1', { name: 'pro' }), 'POST', '/v1/tenants/ten_1/environments/env_1/billing/features', { name: 'pro' }],
    ['billing delete feature', () => client.billing.deleteFeature('ten_1', 'env_1', 'feat_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/billing/features/feat_1', undefined],
    ['billing list plans', () => client.billing.listPlans('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/billing/plans', undefined],
    ['billing save plan', () => client.billing.savePlan('ten_1', 'env_1', { name: 'pro' }), 'POST', '/v1/tenants/ten_1/environments/env_1/billing/plans', { name: 'pro' }],
    ['billing delete plan', () => client.billing.deletePlan('ten_1', 'env_1', 'plan_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/billing/plans/plan_1', undefined],
    ['billing sync stripe', () => client.billing.syncStripe('ten_1', 'env_1', 'plan_1'), 'POST', '/v1/tenants/ten_1/environments/env_1/billing/plans/plan_1/sync-stripe', undefined],
    ['settings get bot detection policy', () => client.settings.getBotDetectionPolicy('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/bot-detection-policy', undefined],
    ['settings update bot detection policy', () => client.settings.updateBotDetectionPolicy('ten_1', 'env_1', { enabled: true }), 'PUT', '/v1/tenants/ten_1/environments/env_1/bot-detection-policy', { enabled: true }],
    ['settings get breached password policy', () => client.settings.getBreachedPasswordPolicy('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/breached-password-policy', undefined],
    ['settings update breached password policy', () => client.settings.updateBreachedPasswordPolicy('ten_1', 'env_1', { enabled: true }), 'PUT', '/v1/tenants/ten_1/environments/env_1/breached-password-policy', { enabled: true }],
    ['settings get brute force policy', () => client.settings.getBruteForcePolicy('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/brute-force-policy', undefined],
    ['settings update brute force policy', () => client.settings.updateBruteForcePolicy('ten_1', 'env_1', { enabled: true }), 'PUT', '/v1/tenants/ten_1/environments/env_1/brute-force-policy', { enabled: true }],
    ['envs save connection', () => client.environments.saveConnection('ten_1', 'env_1', { provider: 'okta' }), 'POST', '/v1/tenants/ten_1/environments/env_1/connections', { provider: 'okta' }],
    ['envs resolve saml metadata', () => client.environments.resolveSamlMetadata('ten_1', 'env_1', { url: 'https://ex' }), 'POST', '/v1/tenants/ten_1/environments/env_1/connections/resolve-saml-metadata', { url: 'https://ex' }],
    ['envs get sso metadata', () => client.environments.getSsoMetadata('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/connections/sso-metadata', undefined],
    ['envs delete connection', () => client.environments.deleteConnection('ten_1', 'env_1', 'con_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/connections/con_1', undefined],
    ['settings get device risk policy', () => client.settings.getDeviceRiskPolicy('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/device-risk-policy', undefined],
    ['settings update device risk policy', () => client.settings.updateDeviceRiskPolicy('ten_1', 'env_1', { enabled: true }), 'PUT', '/v1/tenants/ten_1/environments/env_1/device-risk-policy', { enabled: true }],
    ['elevate activate grant', () => client.elevate.activateGrant('ten_1', 'env_1', 'gr_1', { reason: 'x' }), 'POST', '/v1/tenants/ten_1/environments/env_1/elevate/access-grants/gr_1/activate', { reason: 'x' }],
    ['elevate revoke grant', () => client.elevate.revokeGrant('ten_1', 'env_1', 'gr_1', { reason: 'x' }), 'POST', '/v1/tenants/ten_1/environments/env_1/elevate/access-grants/gr_1/revoke', { reason: 'x' }],
    ['elevate list requests', () => client.elevate.listRequests('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/elevate/access-requests', undefined],
    ['elevate create request', () => client.elevate.createRequest('ten_1', 'env_1', { reason: 'x' }), 'POST', '/v1/tenants/ten_1/environments/env_1/elevate/access-requests', { reason: 'x' }],
    ['elevate get request', () => client.elevate.getRequest('ten_1', 'env_1', 'req_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/elevate/access-requests/req_1', undefined],
    ['elevate approve request', () => client.elevate.approveRequest('ten_1', 'env_1', 'req_1', { note: 'ok' }), 'POST', '/v1/tenants/ten_1/environments/env_1/elevate/access-requests/req_1/approve', { note: 'ok' }],
    ['elevate cancel request', () => client.elevate.cancelRequest('ten_1', 'env_1', 'req_1'), 'POST', '/v1/tenants/ten_1/environments/env_1/elevate/access-requests/req_1/cancel', undefined],
    ['elevate deny request', () => client.elevate.denyRequest('ten_1', 'env_1', 'req_1', { note: 'no' }), 'POST', '/v1/tenants/ten_1/environments/env_1/elevate/access-requests/req_1/deny', { note: 'no' }],
    ['elevate get policy', () => client.elevate.getPolicy('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/elevate/policy', undefined],
    ['elevate update policy', () => client.elevate.updatePolicy('ten_1', 'env_1', { enabled: true }), 'PUT', '/v1/tenants/ten_1/environments/env_1/elevate/policy', { enabled: true }],
    ['email providers list', () => client.emailProviders.list('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/email-providers', undefined],
    ['email providers save', () => client.emailProviders.save('ten_1', 'env_1', { provider: 'ses' }), 'POST', '/v1/tenants/ten_1/environments/env_1/email-providers', { provider: 'ses' }],
    ['email providers test', () => client.emailProviders.test('ten_1', 'env_1', { to: 'a@b.c' }), 'POST', '/v1/tenants/ten_1/environments/env_1/email-providers/test', { to: 'a@b.c' }],
    ['email providers delete', () => client.emailProviders.delete('ten_1', 'env_1', 'ses'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/email-providers/ses', undefined],
    ['email providers activate', () => client.emailProviders.activate('ten_1', 'env_1', 'ses'), 'POST', '/v1/tenants/ten_1/environments/env_1/email-providers/ses/activate', undefined],
    ['feature flags list', () => client.featureFlags.list('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/feature-flags', undefined],
    ['feature flags save', () => client.featureFlags.save('ten_1', 'env_1', { key: 'x' }), 'POST', '/v1/tenants/ten_1/environments/env_1/feature-flags', { key: 'x' }],
    ['feature flags delete', () => client.featureFlags.delete('ten_1', 'env_1', 'flag_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/feature-flags/flag_1', undefined],
    ['forms list attachments', () => client.forms.listAttachments('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/form-attachments', undefined],
    ['forms list', () => client.forms.list('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/forms', undefined],
    ['forms save', () => client.forms.save('ten_1', 'env_1', { name: 'login' }), 'POST', '/v1/tenants/ten_1/environments/env_1/forms', { name: 'login' }],
    ['forms delete', () => client.forms.delete('ten_1', 'env_1', 'form_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/forms/form_1', undefined],
    ['provisioning tokens list hris', () => client.provisioningTokens.listHris('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/hris-tokens', undefined],
    ['provisioning tokens create hris', () => client.provisioningTokens.createHris('ten_1', 'env_1', { name: 'hr' }), 'POST', '/v1/tenants/ten_1/environments/env_1/hris-tokens', { name: 'hr' }],
    ['provisioning tokens revoke hris', () => client.provisioningTokens.revokeHris('ten_1', 'env_1', 'tok_1'), 'POST', '/v1/tenants/ten_1/environments/env_1/hris-tokens/tok_1/revoke', undefined],
    ['provisioning tokens rotate hris', () => client.provisioningTokens.rotateHris('ten_1', 'env_1', 'tok_1'), 'POST', '/v1/tenants/ten_1/environments/env_1/hris-tokens/tok_1/rotate', undefined],
    ['impersonation list', () => client.impersonation.list('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/impersonation-grants', undefined],
    ['impersonation create', () => client.impersonation.create('ten_1', 'env_1', { userId: 'usr_1' }), 'POST', '/v1/tenants/ten_1/environments/env_1/impersonation-grants', { userId: 'usr_1' }],
    ['impersonation revoke', () => client.impersonation.revoke('ten_1', 'env_1', 'gr_1'), 'POST', '/v1/tenants/ten_1/environments/env_1/impersonation-grants/gr_1/revoke', undefined],
    ['settings list jwt claim mappings', () => client.settings.listJwtClaimMappings('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/jwt-claim-mappings', undefined],
    ['settings save jwt claim mapping', () => client.settings.saveJwtClaimMapping('ten_1', 'env_1', { claim: 'role' }), 'POST', '/v1/tenants/ten_1/environments/env_1/jwt-claim-mappings', { claim: 'role' }],
    ['settings delete jwt claim mapping', () => client.settings.deleteJwtClaimMapping('ten_1', 'env_1', 'map_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/jwt-claim-mappings/map_1', undefined],
    ['mcp list entries', () => client.mcp.listEntries('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/mcp/trust-store', undefined],
    ['mcp create entry', () => client.mcp.createEntry('ten_1', 'env_1', { subject: 'a' }), 'POST', '/v1/tenants/ten_1/environments/env_1/mcp/trust-store', { subject: 'a' }],
    ['mcp get entry', () => client.mcp.getEntry('ten_1', 'env_1', 'ent_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1', undefined],
    ['mcp update entry', () => client.mcp.updateEntry('ten_1', 'env_1', 'ent_1', { name: 'n' }), 'PATCH', '/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1', { name: 'n' }],
    ['mcp delete entry', () => client.mcp.deleteEntry('ten_1', 'env_1', 'ent_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1', undefined],
    ['mcp add key', () => client.mcp.addKey('ten_1', 'env_1', 'ent_1', { jwk: {} }), 'POST', '/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/keys', { jwk: {} }],
    ['mcp revoke key', () => client.mcp.revokeKey('ten_1', 'env_1', 'ent_1', 'key_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/keys/key_1', undefined],
    ['mcp rotate key', () => client.mcp.rotateKey('ten_1', 'env_1', 'ent_1', 'key_1'), 'POST', '/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/keys/key_1/rotate', undefined],
    ['mcp revoke entry', () => client.mcp.revokeEntry('ten_1', 'env_1', 'ent_1'), 'POST', '/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/revoke', undefined],
    ['mcp verify entry', () => client.mcp.verifyEntry('ten_1', 'env_1', 'ent_1', { verified: true }), 'POST', '/v1/tenants/ten_1/environments/env_1/mcp/trust-store/ent_1/verify', { verified: true }],
    ['users totp status', () => client.users.totpStatus('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/me/mfa/totp', undefined],
    ['settings get password policy', () => client.settings.getPasswordPolicy('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/password-policy', undefined],
    ['settings update password policy', () => client.settings.updatePasswordPolicy('ten_1', 'env_1', { minLength: 8 }), 'PUT', '/v1/tenants/ten_1/environments/env_1/password-policy', { minLength: 8 }],
    ['portal generate link', () => client.portal.generateLink('ten_1', 'env_1', { email: 'a@b.c' }), 'POST', '/v1/tenants/ten_1/environments/env_1/portal/generate-link', { email: 'a@b.c' }],
    ['settings get rate limit policy', () => client.settings.getRateLimitPolicy('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/rate-limit-policy', undefined],
    ['settings update rate limit policy', () => client.settings.updateRateLimitPolicy('ten_1', 'env_1', { limit: 10 }), 'PUT', '/v1/tenants/ten_1/environments/env_1/rate-limit-policy', { limit: 10 }],
    ['envs save redirect uris', () => client.environments.saveRedirectUris('ten_1', 'env_1', { uris: [] }), 'PUT', '/v1/tenants/ten_1/environments/env_1/redirect-uris', { uris: [] }],
    ['settings get restrictions', () => client.settings.getRestrictions('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/restrictions', undefined],
    ['settings update restrictions', () => client.settings.updateRestrictions('ten_1', 'env_1', { signup: false }), 'PUT', '/v1/tenants/ten_1/environments/env_1/restrictions', { signup: false }],
    ['provisioning tokens list scim', () => client.provisioningTokens.listScim('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/scim-tokens', undefined],
    ['provisioning tokens create scim', () => client.provisioningTokens.createScim('ten_1', 'env_1', { name: 'scim' }), 'POST', '/v1/tenants/ten_1/environments/env_1/scim-tokens', { name: 'scim' }],
    ['provisioning tokens revoke scim', () => client.provisioningTokens.revokeScim('ten_1', 'env_1', 'tok_1'), 'POST', '/v1/tenants/ten_1/environments/env_1/scim-tokens/tok_1/revoke', undefined],
    ['provisioning tokens rotate scim', () => client.provisioningTokens.rotateScim('ten_1', 'env_1', 'tok_1'), 'POST', '/v1/tenants/ten_1/environments/env_1/scim-tokens/tok_1/rotate', undefined],
    ['security posture', () => client.security.posture('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/security/posture', undefined],
    ['settings get session config', () => client.settings.getSessionConfig('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/session-config', undefined],
    ['settings update session config', () => client.settings.updateSessionConfig('ten_1', 'env_1', { ttl: 3600 }), 'PUT', '/v1/tenants/ten_1/environments/env_1/session-config', { ttl: 3600 }],
    ['threats list', () => client.threats.list('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/threats', undefined],
    ['threats create', () => client.threats.create('ten_1', 'env_1', { type: 'bot' }), 'POST', '/v1/tenants/ten_1/environments/env_1/threats', { type: 'bot' }],
    ['threats get', () => client.threats.get('ten_1', 'env_1', 'th_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/threats/th_1', undefined],
    ['threats update', () => client.threats.update('ten_1', 'env_1', 'th_1', { status: 'open' }), 'PATCH', '/v1/tenants/ten_1/environments/env_1/threats/th_1', { status: 'open' }],
    ['threats delete', () => client.threats.delete('ten_1', 'env_1', 'th_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/threats/th_1', undefined],
    ['threats resolve', () => client.threats.resolve('ten_1', 'env_1', 'th_1', { status: 'resolved' }), 'POST', '/v1/tenants/ten_1/environments/env_1/threats/th_1/resolve', { status: 'resolved' }],
    ['users bulk delete', () => client.users.bulkDelete('ten_1', 'env_1', { userIds: ['usr_1'] }), 'POST', '/v1/tenants/ten_1/environments/env_1/users/bulk/delete', { userIds: ['usr_1'] }],
    ['users bulk set active', () => client.users.bulkSetActive('ten_1', 'env_1', { userIds: ['usr_1'], active: false }), 'POST', '/v1/tenants/ten_1/environments/env_1/users/bulk/set-active', { userIds: ['usr_1'], active: false }],
    ['users import', () => client.users.importUsers('ten_1', 'env_1', { users: [] }), 'POST', '/v1/tenants/ten_1/environments/env_1/users/import', { users: [] }],
    ['users disable mfa', () => client.users.disableMfa('ten_1', 'env_1', 'usr_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/users/usr_1/mfa', undefined],
    ['users list sessions', () => client.users.listSessions('ten_1', 'env_1', 'usr_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/users/usr_1/sessions', undefined],
    ['vanity domains list', () => client.vanityDomains.list('ten_1', 'env_1'), 'GET', '/v1/tenants/ten_1/environments/env_1/vanity-domains', undefined],
    ['vanity domains create', () => client.vanityDomains.create('ten_1', 'env_1', { domain: 'a.com' }), 'POST', '/v1/tenants/ten_1/environments/env_1/vanity-domains', { domain: 'a.com' }],
    ['vanity domains delete', () => client.vanityDomains.delete('ten_1', 'env_1', 'dom_1'), 'DELETE', '/v1/tenants/ten_1/environments/env_1/vanity-domains/dom_1', undefined],
    ['vanity domains check', () => client.vanityDomains.check('ten_1', 'env_1', 'dom_1'), 'POST', '/v1/tenants/ten_1/environments/env_1/vanity-domains/dom_1/check', undefined],
    ['widgets create token', () => client.widgets.createToken('ten_1', 'env_1', { ttl: 60 }), 'POST', '/v1/tenants/ten_1/environments/env_1/widgets/token', { ttl: 60 }],
    ['otel export traces', () => client.otel.exportTraces({ resourceSpans: [] }), 'POST', '/v1/traces', { resourceSpans: [] }],
  ];

  it('covers all inventory operations', () => {
    expect(wave3Cases).toHaveLength(152);
  });

  it.each(wave3Cases)('%s hits %s %s', async (_name, call, method, url, data) => {
    mockAxiosInstance.request.mockResolvedValue({ data: {} });
    await call();
    expect(mockAxiosInstance.request).toHaveBeenCalledWith(
      expect.objectContaining({
        method,
        url,
        ...(data !== undefined ? { data } : {}),
      })
    );
  });

  it('authzen discovery omits bearer', async () => {
    mockAxiosInstance.request.mockResolvedValue({ data: {} });
    await client.authzen.configuration();
    expect(mockAxiosInstance.request).toHaveBeenCalledWith(
      expect.objectContaining({
        method: 'GET',
        url: '/.well-known/authzen-configuration',
        headers: expect.objectContaining({ Authorization: '' }),
      })
    );
  });

  it('authzen evaluate uses environmentSecret', async () => {
    const secretClient = new AuthdogClient({
      baseUrl: 'https://api.authdog.com',
      apiKey: 'key-1',
      environmentSecret: 'adenv_secret',
    });
    mockAxiosInstance.request.mockResolvedValue({ data: { decision: 'Permit' } });
    const result = await secretClient.authzen.evaluate({ subject: { id: 'u' } });
    expect(result.decision).toBe('Permit');
    expect(mockAxiosInstance.request).toHaveBeenCalledWith(
      expect.objectContaining({
        method: 'POST',
        url: '/access/v1/evaluation',
        headers: expect.objectContaining({ Authorization: 'Bearer adenv_secret' }),
      })
    );
  });

  it('scim and hris use specialized tokens', async () => {
    const tokenClient = new AuthdogClient({
      baseUrl: 'https://api.authdog.com',
      apiKey: 'key-1',
      scimToken: 'adscim_token',
      hrisToken: 'adhris_token',
    });
    mockAxiosInstance.request.mockResolvedValue({ data: {} });
    await tokenClient.scim.listUsers();
    expect(mockAxiosInstance.request).toHaveBeenCalledWith(
      expect.objectContaining({
        url: '/v1/scim/v2/Users',
        headers: expect.objectContaining({ Authorization: 'Bearer adscim_token' }),
      })
    );
    await tokenClient.hris.listEmployees();
    expect(mockAxiosInstance.request).toHaveBeenCalledWith(
      expect.objectContaining({
        url: '/v1/hris/v1/Employees',
        headers: expect.objectContaining({ Authorization: 'Bearer adhris_token' }),
      })
    );
  });

  it('createScim token response exposes one-time token', async () => {
    mockAxiosInstance.request.mockResolvedValue({
      data: { token: 'adscim_once', id: 'tok_1' },
    });
    const created = await client.provisioningTokens.createScim('ten_1', 'env_1', { name: 'scim' });
    expect(created.token).toBe('adscim_once');
  });

  it('forwards query params', async () => {
    mockAxiosInstance.request.mockResolvedValue({ data: {} });
    await client.mcp.resolve('agent-1');
    expect(mockAxiosInstance.request).toHaveBeenCalledWith(
      expect.objectContaining({
        method: 'GET',
        url: '/v1/mcp/trust-store/resolve',
        params: { subject: 'agent-1' },
      })
    );
    await client.threats.list('ten_1', 'env_1', { status: 'open', limit: 10 });
    expect(mockAxiosInstance.request).toHaveBeenCalledWith(
      expect.objectContaining({
        method: 'GET',
        url: '/v1/tenants/ten_1/environments/env_1/threats',
        params: { status: 'open', limit: 10 },
      })
    );
    await client.elevate.listRequests('ten_1', 'env_1', 'pending');
    expect(mockAxiosInstance.request).toHaveBeenCalledWith(
      expect.objectContaining({
        method: 'GET',
        url: '/v1/tenants/ten_1/environments/env_1/elevate/access-requests',
        params: { status: 'pending' },
      })
    );
  });
});
