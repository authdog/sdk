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
