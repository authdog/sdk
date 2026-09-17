# Platform API operation inventory

**Source**: `openapi.snapshot.json` (Authdog API 1.0.0, fetched 2026-09-17 from `https://api.authdog.com/v1/openapi`)

Wave assignment follows `spec.md` FR-004–FR-006. Environment connections/redirects and directory bulk/MFA/session ops are Wave 3 even though they share a tag with Wave 1 families.

| Wave | Operations |
|------|------------|
| 1 | 56 |
| 2 | 58 |
| 3 | 152 |
| **Total** | **266** |

## Wave 1

| Tag | Method | Path | operationId | Summary |
|-----|--------|------|-------------|---------|
| Directory | POST | `/v1/groups` | `envGroupCreate` | Create a group |
| Health | GET | `/v1/health` | `healthCheck` | Health check |
| Organizations | GET | `/v1/organizations` | `organizationsList` | List organizations |
| Organizations | POST | `/v1/organizations` | `organizationCreate` | Create organization |
| Organizations | POST | `/v1/organizations/invitations/accept` | `organizationInvitationAccept` | Accept an organization invitation |
| Organizations | POST | `/v1/organizations/join` | `joinOrganizationWithCode` | Join organization |
| Organizations | GET | `/v1/organizations/{id}` | `organizationGet` | Get organization |
| Organizations | PATCH | `/v1/organizations/{id}` | `organizationUpdate` | Update organization |
| Organizations | DELETE | `/v1/organizations/{id}` | `organizationDelete` | Delete organization |
| Organizations | GET | `/v1/organizations/{id}/invitations` | `organizationInvitations` | List organization invitations |
| Organizations | POST | `/v1/organizations/{id}/invitations` | `organizationInvitationCreate` | Create an organization invitation |
| Organizations | POST | `/v1/organizations/{id}/invitations/{invitationId}/cancel` | `organizationInvitationCancel` | Cancel an organization invitation |
| Organizations | POST | `/v1/organizations/{id}/invites` | `sendOrganizationInvite` | Send organization invite |
| Organizations | GET | `/v1/organizations/{id}/members` | `organizationMembers` | List organization members |
| Organizations | DELETE | `/v1/organizations/{id}/members/{memberId}` | `organizationMemberRemove` | Remove an organization member |
| Organizations | PATCH | `/v1/organizations/{id}/members/{memberId}/active` | `organizationMemberSetActive` | Enable or disable an organization member |
| Organizations | POST | `/v1/organizations/{id}/tenants` | `organizationTenantLink` | Link a tenant to the organization |
| Organizations | DELETE | `/v1/organizations/{id}/tenants/{tenantId}` | `organizationTenantUnlink` | Unlink a tenant from the organization |
| Tenants | GET | `/v1/tenants` | `tenantsList` | List tenants |
| Tenants | POST | `/v1/tenants` | `tenantCreate` | Create tenant |
| Tenants | POST | `/v1/tenants/join` | `tenantJoinWithCode` | Join a tenant with an invitation code |
| Tenants | GET | `/v1/tenants/{id}` | `tenantGet` | Get tenant |
| Tenants | PATCH | `/v1/tenants/{id}` | `tenantUpdate` | Update tenant |
| Tenants | DELETE | `/v1/tenants/{id}` | `tenantDelete` | Delete tenant |
| Tenants | GET | `/v1/tenants/{id}/domains` | `tenantDomains` | List tenant domains |
| Tenants | POST | `/v1/tenants/{id}/domains` | `tenantDomainCreate` | Create tenant domain |
| Tenants | DELETE | `/v1/tenants/{id}/domains/{domainId}` | `tenantDomainDelete` | Delete tenant domain |
| Tenants | POST | `/v1/tenants/{id}/domains/{domainId}/retry` | `tenantDomainRetryVerification` | Retry tenant domain verification |
| Tenants | POST | `/v1/tenants/{id}/invites` | `tenantInviteSend` | Invite a user to the tenant |
| Tenants | GET | `/v1/tenants/{id}/projects` | `tenantProjects` | List tenant projects |
| Tenants | GET | `/v1/tenants/{id}/seats` | `tenantSeatsList` | List tenant seats |
| Tenants | PATCH | `/v1/tenants/{id}/seats/{seatId}` | `tenantSeatUpdate` | Update a tenant seat |
| Tenants | DELETE | `/v1/tenants/{id}/seats/{seatId}` | `tenantSeatDelete` | Delete a tenant seat |
| Projects | POST | `/v1/tenants/{tenantId}/applications` | `applicationSave` | Create or update a project (application) |
| Projects | GET | `/v1/tenants/{tenantId}/applications/{applicationId}` | `projectDetails` | Get a project (application) with its environments |
| Projects | DELETE | `/v1/tenants/{tenantId}/applications/{applicationId}` | `applicationDelete` | Delete a project (application) |
| Projects | PUT | `/v1/tenants/{tenantId}/applications/{applicationId}/default-environment` | `applicationSetDefaultEnvironment` | Set a project's default environment |
| Environments | GET | `/v1/tenants/{tenantId}/applications/{applicationId}/environments` | `applicationEnvironmentsList` | List environments for a project |
| Environments | POST | `/v1/tenants/{tenantId}/applications/{applicationId}/environments` | `environmentCreate` | Create environment |
| Environments | PATCH | `/v1/tenants/{tenantId}/environments/{environmentId}` | `environmentUpdate` | Update environment |
| Environments | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}` | `environmentDelete` | Delete environment |
| Directory | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/groups` | `envGroupsList` | List groups |
| Directory | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/groups/{groupId}` | `envGroupDelete` | Delete a group |
| Directory | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/groups/{groupId}/members` | `groupMembersList` | List members of a group |
| Directory | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/groups/{groupId}/members` | `groupMemberAdd` | Add a user to a group |
| Directory | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/groups/{groupId}/members/{userId}` | `groupMemberRemove` | Remove a user from a group |
| Directory | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/users` | `envUsersList` | List users in an environment |
| Directory | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/users` | `envUserCreate` | Create a user |
| Directory | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/users/count` | `envUsersCount` | Count users in an environment |
| Directory | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/users/search` | `envUsersSearch` | Search users in an environment |
| Directory | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/users/{userId}` | `envUserGet` | Get a user |
| Directory | PUT | `/v1/tenants/{tenantId}/environments/{environmentId}/users/{userId}` | `envUserUpdate` | Update a user's profile |
| Directory | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/users/{userId}` | `envUserDelete` | Delete a user from the environment |
| Directory | PATCH | `/v1/tenants/{tenantId}/environments/{environmentId}/users/{userId}/active` | `envUserSetActive` | Enable or disable a user |
| Directory | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/users/{userId}/groups` | `userGroupsList` | List groups a user belongs to |
| User info | GET | `/v1/userinfo` | `getUserInfo` | User info |

## Wave 2

| Tag | Method | Path | operationId | Summary |
|-----|--------|------|-------------|---------|
| Audit | GET | `/v1/organizations/{id}/audit/logs` | `organizationAuditLogs` | List organization audit logs |
| Organization keys | GET | `/v1/organizations/{id}/keys` | `organizationKeysList` | List organization API keys |
| Organization keys | POST | `/v1/organizations/{id}/keys` | `organizationKeyCreate` | Create an organization API key |
| Organization keys | POST | `/v1/organizations/{id}/keys/{keyId}/revoke` | `organizationKeyRevoke` | Revoke an organization API key |
| Organization keys | POST | `/v1/organizations/{id}/keys/{keyId}/rotate` | `organizationKeyRotate` | Rotate an organization API key |
| Organization keys | PUT | `/v1/organizations/{id}/keys/{keyId}/tenants` | `organizationKeyTenantsUpdate` | Replace the tenants an organization key can access |
| Personal access tokens | GET | `/v1/personal-access-tokens` | `personalAccessTokensList` | List personal access tokens |
| Personal access tokens | POST | `/v1/personal-access-tokens` | `personalAccessTokenCreate` | Create personal access token |
| Personal access tokens | POST | `/v1/personal-access-tokens/{id}/revoke` | `personalAccessTokenRevoke` | Revoke personal access token |
| Service accounts | GET | `/v1/service-accounts` | `serviceAccountsList` | List service accounts |
| Service accounts | POST | `/v1/service-accounts` | `serviceAccountCreate` | Create service account |
| Service accounts | GET | `/v1/service-accounts/{id}` | `serviceAccountGet` | Get service account |
| Service accounts | DELETE | `/v1/service-accounts/{id}` | `serviceAccountDelete` | Delete service account |
| RBAC | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/abac-policies` | `abacPoliciesList` | List ABAC policies |
| RBAC | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/abac-policies` | `abacPolicySave` | Create or update an ABAC policy |
| RBAC | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/abac-policies/validate` | `abacPolicyValidate` | Validate an ABAC policy's Rego source |
| RBAC | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/abac-policies/{policyId}` | `abacPolicyDelete` | Delete an ABAC policy |
| API secrets | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/api-secrets` | `environmentApiSecretsList` | List API secrets for an environment |
| API secrets | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/api-secrets` | `environmentApiSecretCreate` | Create an API secret |
| API secrets | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/api-secrets/{secretId}/revoke` | `environmentApiSecretRevoke` | Revoke an API secret |
| Audit | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/audit/event-metadata` | `envAuditEventMetadata` | Get environment audit event metadata |
| Audit | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/audit/event-types` | `envAuditEventTypes` | Get grouped environment audit event types |
| Audit | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/audit/event-types/catalog` | `envAuditEventTypesCatalog` | Get audit event type catalog |
| Audit | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/audit/logs` | `envAuditLogs` | List environment audit logs |
| Events | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/events` | `listEvents` | List events |
| Events | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/events/ingest` | `ingestSecurityEvents` | Ingest security events |
| Events | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/events/types` | `listEventTypes` | List event types |
| RBAC | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/group-role-mappings` | `groupRoleMappingsList` | List group-to-role mappings |
| RBAC | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/group-role-mappings` | `groupRoleMappingCreate` | Create a group-to-role mapping |
| RBAC | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/group-role-mappings/apply` | `groupRoleMappingsApply` | Apply group-to-role mappings to existing groups |
| RBAC | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/group-role-mappings/{mappingId}` | `groupRoleMappingDelete` | Delete a group-to-role mapping |
| RBAC | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/groups/{groupId}/roles` | `groupRolesList` | List roles assigned to a group |
| RBAC | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/groups/{groupId}/roles` | `groupRoleAdd` | Assign a role to a group |
| RBAC | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/groups/{groupId}/roles/{roleId}` | `groupRoleRemove` | Remove a role from a group |
| RBAC | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/me/permissions` | `myPermissions` | List the caller's effective permissions |
| Notification channels | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/notification-channels` | `listNotificationChannels` | List notification channels |
| Notification channels | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/notification-channels` | `createNotificationChannel` | Create notification channel |
| Notification channels | PUT | `/v1/tenants/{tenantId}/environments/{environmentId}/notification-channels/{channelId}` | `updateNotificationChannel` | Update notification channel |
| Notification channels | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/notification-channels/{channelId}` | `deleteNotificationChannel` | Delete notification channel |
| Notification channels | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/notification-channels/{channelId}/test` | `testNotificationChannel` | Test notification channel |
| RBAC | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/permissions` | `envPermissionsList` | List permissions in an environment |
| RBAC | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/permissions` | `envPermissionCreate` | Create or update a permission |
| RBAC | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/permissions/{permissionId}` | `envPermissionDelete` | Delete a permission |
| RBAC | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/resources` | `envResourcesList` | List resources in an environment |
| RBAC | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/resources` | `envResourceCreate` | Create or update a resource |
| RBAC | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/resources/{resourceId}` | `envResourceDelete` | Delete a resource |
| RBAC | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/roles` | `envRolesList` | List roles in an environment |
| RBAC | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/roles` | `envRoleCreate` | Create or update a role |
| RBAC | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/roles/{roleId}` | `envRoleDelete` | Delete a role |
| RBAC | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/roles/{roleId}/permissions` | `rolePermissionsList` | List permissions assigned to a role |
| RBAC | PUT | `/v1/tenants/{tenantId}/environments/{environmentId}/roles/{roleId}/permissions` | `rolePermissionsSet` | Set permissions for a role |
| Webhooks | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/webhooks` | `listWebhookEndpoints` | List webhook endpoints |
| Webhooks | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/webhooks` | `createWebhookEndpoint` | Create a webhook endpoint |
| Webhooks | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/webhooks/deliveries` | `listWebhookDeliveries` | List webhook deliveries |
| Webhooks | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/webhooks/deliveries/{deliveryId}/redeliver` | `redeliverWebhook` | Redeliver a webhook |
| Webhooks | PUT | `/v1/tenants/{tenantId}/environments/{environmentId}/webhooks/{channelId}` | `updateWebhookEndpoint` | Update a webhook endpoint |
| Webhooks | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/webhooks/{channelId}` | `deleteWebhookEndpoint` | Delete a webhook endpoint |
| Webhooks | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/webhooks/{channelId}/rotate-secret` | `rotateWebhookSigningSecret` | Rotate a webhook signing secret |

## Wave 3

| Tag | Method | Path | operationId | Summary |
|-----|--------|------|-------------|---------|
| AuthZEN | GET | `/.well-known/authzen-configuration` | `authzenConfiguration` | AuthZEN discovery document |
| AuthZEN | POST | `/access/v1/evaluation` | `authzenEvaluation` | Evaluate one access request |
| AuthZEN | POST | `/access/v1/evaluations` | `authzenEvaluations` | Evaluate a batch of access requests |
| AuthZEN | POST | `/access/v1/search/action` | `authzenSearchAction` | Search actions |
| AuthZEN | POST | `/access/v1/search/resource` | `authzenSearchResource` | Search resources |
| AuthZEN | POST | `/access/v1/search/subject` | `authzenSearchSubject` | Search subjects |
| Directory | DELETE | `/v1/environments/{environmentId}/sessions/{sessionId}` | `userSessionRevoke` | Revoke a user session |
| HRIS | GET | `/v1/hris/v1/Departments` | `hrisListDepartments` | List HRIS Departments |
| HRIS | POST | `/v1/hris/v1/Departments` | `hrisCreateDepartment` | Create an HRIS Department |
| HRIS | GET | `/v1/hris/v1/Departments/{id}` | `hrisGetDepartment` | Get an HRIS Department |
| HRIS | PUT | `/v1/hris/v1/Departments/{id}` | `hrisReplaceDepartment` | Replace an HRIS Department |
| HRIS | PATCH | `/v1/hris/v1/Departments/{id}` | `hrisPatchDepartment` | Patch an HRIS Department |
| HRIS | DELETE | `/v1/hris/v1/Departments/{id}` | `hrisDeleteDepartment` | Delete an HRIS Department |
| HRIS | GET | `/v1/hris/v1/Employees` | `hrisListEmployees` | List HRIS Employees |
| HRIS | POST | `/v1/hris/v1/Employees` | `hrisCreateEmployee` | Create an HRIS Employee |
| HRIS | GET | `/v1/hris/v1/Employees/{id}` | `hrisGetEmployee` | Get an HRIS Employee |
| HRIS | PUT | `/v1/hris/v1/Employees/{id}` | `hrisReplaceEmployee` | Replace an HRIS Employee |
| HRIS | PATCH | `/v1/hris/v1/Employees/{id}` | `hrisPatchEmployee` | Patch an HRIS Employee |
| HRIS | DELETE | `/v1/hris/v1/Employees/{id}` | `hrisDeleteEmployee` | Delete an HRIS Employee |
| HRIS | GET | `/v1/hris/v1/ServiceConfig` | `hrisServiceConfig` | HRIS ServiceConfig |
| OpenTelemetry | POST | `/v1/logs` | `otelExportLogs` | Export OTLP logs |
| MCP Trust Store | POST | `/v1/mcp/events` | `mcpEventsIngest` | Ingest MCP tool-call telemetry (SDK runtime) |
| MCP Trust Store | GET | `/v1/mcp/trust-store/resolve` | `mcpTrustStoreResolve` | Resolve a trust store entry by subject (SDK runtime) |
| OpenTelemetry | POST | `/v1/metrics` | `otelExportMetrics` | Export OTLP metrics |
| OpenTelemetry | POST | `/v1/otel/v1/logs` | `otelExportLogsPrefixed` | Export OTLP logs |
| OpenTelemetry | POST | `/v1/otel/v1/metrics` | `otelExportMetricsPrefixed` | Export OTLP metrics |
| OpenTelemetry | POST | `/v1/otel/v1/traces` | `otelExportTracesPrefixed` | Export OTLP traces |
| SCIM | GET | `/v1/scim/v2/Groups` | `scimListGroups` | List SCIM Groups |
| SCIM | POST | `/v1/scim/v2/Groups` | `scimCreateGroup` | Create a SCIM Group |
| SCIM | GET | `/v1/scim/v2/Groups/{id}` | `scimGetGroup` | Get a SCIM Group |
| SCIM | PUT | `/v1/scim/v2/Groups/{id}` | `scimReplaceGroup` | Replace a SCIM Group |
| SCIM | PATCH | `/v1/scim/v2/Groups/{id}` | `scimPatchGroup` | Patch a SCIM Group |
| SCIM | DELETE | `/v1/scim/v2/Groups/{id}` | `scimDeleteGroup` | Delete a SCIM Group |
| SCIM | GET | `/v1/scim/v2/ResourceTypes` | `scimResourceTypes` | List SCIM ResourceTypes |
| SCIM | GET | `/v1/scim/v2/ResourceTypes/{id}` | `scimResourceTypeById` | Get a SCIM ResourceType |
| SCIM | GET | `/v1/scim/v2/Schemas` | `scimSchemas` | List SCIM Schemas |
| SCIM | GET | `/v1/scim/v2/Schemas/{id}` | `scimSchemaById` | Get a SCIM Schema |
| SCIM | GET | `/v1/scim/v2/ServiceProviderConfig` | `scimServiceProviderConfig` | SCIM ServiceProviderConfig |
| SCIM | GET | `/v1/scim/v2/Users` | `scimListUsers` | List SCIM Users |
| SCIM | POST | `/v1/scim/v2/Users` | `scimCreateUser` | Create a SCIM User |
| SCIM | GET | `/v1/scim/v2/Users/{id}` | `scimGetUser` | Get a SCIM User |
| SCIM | PUT | `/v1/scim/v2/Users/{id}` | `scimReplaceUser` | Replace a SCIM User |
| SCIM | PATCH | `/v1/scim/v2/Users/{id}` | `scimPatchUser` | Patch a SCIM User |
| SCIM | DELETE | `/v1/scim/v2/Users/{id}` | `scimDeleteUser` | Delete a SCIM User |
| Environments | GET | `/v1/tenants/{tenantId}/applications/{applicationId}/environments/{environmentId}/connections` | `applicationEnvironmentConnections` | List IdP connections for an environment |
| OIDC clients | GET | `/v1/tenants/{tenantId}/applications/{applicationId}/environments/{environmentId}/oidc-clients` | `oidcClientsList` | List OIDC clients for an environment |
| OIDC clients | POST | `/v1/tenants/{tenantId}/applications/{applicationId}/environments/{environmentId}/oidc-clients` | `oidcClientRegister` | Register an OIDC client |
| OIDC clients | PATCH | `/v1/tenants/{tenantId}/applications/{applicationId}/environments/{environmentId}/oidc-clients/{clientId}` | `oidcClientUpdate` | Update an OIDC client |
| OIDC clients | DELETE | `/v1/tenants/{tenantId}/applications/{applicationId}/environments/{environmentId}/oidc-clients/{clientId}` | `oidcClientDelete` | Delete an OIDC client |
| Environments | GET | `/v1/tenants/{tenantId}/applications/{applicationId}/environments/{environmentId}/redirect-uris` | `applicationEnvironmentRedirectUris` | Get redirect URI configuration |
| Actions | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/actions` | `actionsList` | List auth action hooks |
| Actions | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/actions` | `actionSave` | Create or update an auth action hook |
| Actions | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/actions/executions` | `actionExecutions` | List recent action invocations (logs) |
| Actions | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/actions/test` | `actionTest` | Fire a sample payload at a hook URL |
| Actions | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/actions/{id}` | `actionDelete` | Delete an auth action hook |
| Add-ons | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/addons` | `addonsList` | List add-on configurations |
| Add-ons | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/addons` | `addonSave` | Create or update an add-on configuration |
| Add-ons | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/addons/{provider}` | `addonDelete` | Delete an add-on configuration |
| Billing | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/billing/features` | `billingFeaturesList` | List billing features |
| Billing | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/billing/features` | `billingFeatureSave` | Create or update a billing feature |
| Billing | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/billing/features/{featureId}` | `billingFeatureDelete` | Delete a billing feature |
| Billing | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/billing/plans` | `billingPlansList` | List billing plans |
| Billing | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/billing/plans` | `billingPlanSave` | Create or update a billing plan |
| Billing | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/billing/plans/{planId}` | `billingPlanDelete` | Delete a billing plan |
| Billing | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/billing/plans/{planId}/sync-stripe` | `billingPlanSyncStripe` | Sync a billing plan to Stripe |
| Environment settings | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/bot-detection-policy` | `botDetectionPolicyGet` | Get bot detection policy |
| Environment settings | PUT | `/v1/tenants/{tenantId}/environments/{environmentId}/bot-detection-policy` | `botDetectionPolicyUpdate` | Update bot detection policy |
| Environment settings | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/breached-password-policy` | `breachedPasswordPolicyGet` | Get breached password policy |
| Environment settings | PUT | `/v1/tenants/{tenantId}/environments/{environmentId}/breached-password-policy` | `breachedPasswordPolicyUpdate` | Update breached password policy |
| Environment settings | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/brute-force-policy` | `bruteForcePolicyGet` | Get brute force policy |
| Environment settings | PUT | `/v1/tenants/{tenantId}/environments/{environmentId}/brute-force-policy` | `bruteForcePolicyUpdate` | Update brute force policy |
| Environments | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/connections` | `environmentConnectionSave` | Create or update an IdP connection |
| Environments | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/connections/resolve-saml-metadata` | `samlIdpMetadataResolve` | Resolve SAML IdP metadata |
| Environments | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/connections/sso-metadata` | `enterpriseSsoMetadataGet` | Get the SP metadata for an enterprise SSO connection |
| Environments | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/connections/{connectionId}` | `environmentConnectionDelete` | Delete an IdP connection |
| Environment settings | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/device-risk-policy` | `deviceRiskPolicyGet` | Get device risk policy |
| Environment settings | PUT | `/v1/tenants/{tenantId}/environments/{environmentId}/device-risk-policy` | `deviceRiskPolicyUpdate` | Update device risk policy |
| Elevate | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/elevate/access-grants/{grantId}/activate` | `elevateGrantActivate` |  |
| Elevate | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/elevate/access-grants/{grantId}/revoke` | `elevateGrantRevoke` |  |
| Elevate | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/elevate/access-requests` | `elevateRequestsList` |  |
| Elevate | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/elevate/access-requests` | `elevateRequestCreate` |  |
| Elevate | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/elevate/access-requests/{requestId}` | `elevateRequestGet` |  |
| Elevate | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/elevate/access-requests/{requestId}/approve` | `elevateRequestApprove` |  |
| Elevate | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/elevate/access-requests/{requestId}/cancel` | `elevateRequestCancel` |  |
| Elevate | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/elevate/access-requests/{requestId}/deny` | `elevateRequestDeny` |  |
| Elevate | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/elevate/policy` | `elevatePolicyGet` |  |
| Elevate | PUT | `/v1/tenants/{tenantId}/environments/{environmentId}/elevate/policy` | `elevatePolicyUpdate` |  |
| Email providers | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/email-providers` | `emailProvidersList` | List email delivery providers |
| Email providers | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/email-providers` | `emailProviderSave` | Create or update an email provider |
| Email providers | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/email-providers/test` | `emailProviderTest` | Send a test email through a configured provider |
| Email providers | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/email-providers/{provider}` | `emailProviderDelete` | Delete an email provider |
| Email providers | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/email-providers/{provider}/activate` | `emailProviderActivate` | Set the active email provider |
| Feature flags | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/feature-flags` | `featureFlagsList` | List feature flags |
| Feature flags | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/feature-flags` | `featureFlagSave` | Create or update a feature flag |
| Feature flags | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/feature-flags/{id}` | `featureFlagDelete` | Delete a feature flag |
| Forms | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/form-attachments` | `formAttachmentsList` | List flow-point attachments configured for an environment |
| Forms | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/forms` | `formsList` | List forms configured for an environment |
| Forms | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/forms` | `formSave` | Create or update a form |
| Forms | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/forms/{formId}` | `formDelete` | Delete a form |
| Provisioning tokens | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/hris-tokens` | `hrisTokensList` | List HRIS tokens |
| Provisioning tokens | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/hris-tokens` | `hrisTokenCreate` | Create a HRIS token |
| Provisioning tokens | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/hris-tokens/{tokenId}/revoke` | `hrisTokenRevoke` | Revoke a HRIS token |
| Provisioning tokens | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/hris-tokens/{tokenId}/rotate` | `hrisTokenRotate` | Rotate a HRIS token |
| Impersonation | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/impersonation-grants` | `impersonationGrantsList` | List impersonation grants |
| Impersonation | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/impersonation-grants` | `impersonationGrantCreate` | Create an impersonation grant |
| Impersonation | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/impersonation-grants/{grantId}/revoke` | `impersonationGrantRevoke` | Revoke an impersonation grant |
| Environment settings | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/jwt-claim-mappings` | `jwtClaimMappingsList` | List custom JWT claim mappings |
| Environment settings | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/jwt-claim-mappings` | `jwtClaimMappingSave` | Create or update a JWT claim mapping |
| Environment settings | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/jwt-claim-mappings/{mappingId}` | `jwtClaimMappingDelete` | Delete a JWT claim mapping |
| MCP Trust Store | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/mcp/trust-store` | `mcpTrustStoreEntriesList` | List trust store entries in an environment |
| MCP Trust Store | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/mcp/trust-store` | `mcpTrustStoreEntryCreate` | Register a trust store entry |
| MCP Trust Store | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/mcp/trust-store/{entryId}` | `mcpTrustStoreEntryGet` | Get a trust store entry |
| MCP Trust Store | PATCH | `/v1/tenants/{tenantId}/environments/{environmentId}/mcp/trust-store/{entryId}` | `mcpTrustStoreEntryUpdate` | Update a trust store entry |
| MCP Trust Store | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/mcp/trust-store/{entryId}` | `mcpTrustStoreEntryDelete` | Delete a trust store entry |
| MCP Trust Store | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/mcp/trust-store/{entryId}/keys` | `mcpTrustStoreKeyAdd` | Add a key to a trust store entry |
| MCP Trust Store | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/mcp/trust-store/{entryId}/keys/{keyId}` | `mcpTrustStoreKeyRevoke` | Revoke a single key |
| MCP Trust Store | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/mcp/trust-store/{entryId}/keys/{keyId}/rotate` | `mcpTrustStoreKeyRotate` | Rotate a key with an optional overlap window |
| MCP Trust Store | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/mcp/trust-store/{entryId}/revoke` | `mcpTrustStoreEntryRevoke` | Revoke (distrust) a trust store entry |
| MCP Trust Store | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/mcp/trust-store/{entryId}/verify` | `mcpTrustStoreEntryVerify` | Verify or unverify a trust store entry |
| Directory | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/me/mfa/totp` | `myTotpStatus` | Get the caller's TOTP status |
| Environment settings | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/password-policy` | `passwordPolicyGet` | Get password policy |
| Environment settings | PUT | `/v1/tenants/{tenantId}/environments/{environmentId}/password-policy` | `passwordPolicyUpdate` | Update password policy |
| Admin Portal | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/portal/generate-link` | `generatePortalLink` | Generate an admin portal link |
| Environment settings | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/rate-limit-policy` | `rateLimitPolicyGet` | Get rate limit policy |
| Environment settings | PUT | `/v1/tenants/{tenantId}/environments/{environmentId}/rate-limit-policy` | `rateLimitPolicyUpdate` | Update rate limit policy |
| Environments | PUT | `/v1/tenants/{tenantId}/environments/{environmentId}/redirect-uris` | `environmentRedirectUrisSave` | Update redirect URIs |
| Environment settings | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/restrictions` | `environmentRestrictionsGet` | Get signup/signin restrictions |
| Environment settings | PUT | `/v1/tenants/{tenantId}/environments/{environmentId}/restrictions` | `environmentRestrictionsUpdate` | Update signup/signin restrictions |
| Provisioning tokens | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/scim-tokens` | `scimTokensList` | List SCIM tokens |
| Provisioning tokens | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/scim-tokens` | `scimTokenCreate` | Create a SCIM token |
| Provisioning tokens | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/scim-tokens/{tokenId}/revoke` | `scimTokenRevoke` | Revoke a SCIM token |
| Provisioning tokens | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/scim-tokens/{tokenId}/rotate` | `scimTokenRotate` | Rotate a SCIM token |
| Security Posture | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/security/posture` | `securityPostureOverview` | Get the environment's cloud security posture score and findings |
| Environment settings | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/session-config` | `sessionConfigGet` | Get session configuration |
| Environment settings | PUT | `/v1/tenants/{tenantId}/environments/{environmentId}/session-config` | `sessionConfigUpdate` | Update session configuration |
| Threats | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/threats` | `threatsList` | List threats |
| Threats | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/threats` | `threatCreate` | Create a threat |
| Threats | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/threats/{threatId}` | `threatDetails` | Get a threat |
| Threats | PATCH | `/v1/tenants/{tenantId}/environments/{environmentId}/threats/{threatId}` | `threatUpdate` | Update a threat's status, severity, or assignee |
| Threats | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/threats/{threatId}` | `threatDelete` | Delete a threat |
| Threats | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/threats/{threatId}/resolve` | `threatResolve` | Resolve or dismiss a threat |
| Directory | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/users/bulk/delete` | `envUsersBulkDelete` | Delete multiple users |
| Directory | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/users/bulk/set-active` | `envUsersBulkSetActive` | Enable or disable multiple users |
| Directory | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/users/import` | `envUsersImport` | Bulk import users |
| Directory | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/users/{userId}/mfa` | `envUserDisableMfa` | Disable a user's MFA factors |
| Directory | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/users/{userId}/sessions` | `userSessionsList` | List sessions for a user |
| Vanity domains | GET | `/v1/tenants/{tenantId}/environments/{environmentId}/vanity-domains` | `vanityDomainsList` | List vanity domains |
| Vanity domains | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/vanity-domains` | `vanityDomainCreate` | Register a vanity domain |
| Vanity domains | DELETE | `/v1/tenants/{tenantId}/environments/{environmentId}/vanity-domains/{domainId}` | `vanityDomainDelete` | Delete a vanity domain |
| Vanity domains | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/vanity-domains/{domainId}/check` | `vanityDomainCheck` | Re-check a vanity domain's DNS/TLS status |
| Widgets | POST | `/v1/tenants/{tenantId}/environments/{environmentId}/widgets/token` | `createWidgetToken` | Create a widget token |
| OpenTelemetry | POST | `/v1/traces` | `otelExportTraces` | Export OTLP traces |

