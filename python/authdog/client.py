"""Main client for Authdog SDK."""

from typing import Any, Dict, Optional

import httpx

from .exceptions import APIError, AuthenticationError
from .resources import (
    ActionsResource,
    AddonsResource,
    ApiSecretsResource,
    AuditResource,
    AuthzenResource,
    BillingResource,
    ElevateResource,
    EmailProvidersResource,
    EnvironmentsResource,
    EventsResource,
    FeatureFlagsResource,
    FormsResource,
    GroupsResource,
    HrisResource,
    ImpersonationResource,
    McpResource,
    NotificationChannelsResource,
    OidcClientsResource,
    OrganizationsResource,
    OtelResource,
    PersonalAccessTokensResource,
    PortalResource,
    ProjectsResource,
    ProvisioningTokensResource,
    RbacResource,
    ScimResource,
    SecurityResource,
    ServiceAccountsResource,
    SettingsResource,
    TenantsResource,
    ThreatsResource,
    UsersResource,
    VanityDomainsResource,
    WebhooksResource,
    WidgetsResource,
)
from .types import Probe, UserInfoResponse


class AuthdogClient:
    """Main client for interacting with Authdog API."""

    def __init__(
        self,
        base_url: str,
        api_key: Optional[str] = None,
        timeout: float = 10.0,
        environment_secret: Optional[str] = None,
        scim_token: Optional[str] = None,
        hris_token: Optional[str] = None,
    ):
        """
        Initialize the Authdog client.

        Args:
            base_url: The base URL of the Authdog API
            api_key: Optional management Bearer credential
            timeout: Request timeout in seconds (default 10)
            environment_secret: Optional `adenv_` secret for AuthZEN and MCP runtime
            scim_token: Optional `adscim_` token for `/v1/scim/v2`
            hris_token: Optional `adhris_` token for `/v1/hris/v1`
        """
        self.base_url = base_url.rstrip("/")
        self.api_key = api_key
        self.timeout = timeout
        self.environment_secret = environment_secret
        self.scim_token = scim_token
        self.hris_token = hris_token
        self._client = httpx.Client(
            base_url=self.base_url,
            headers=self._get_default_headers(),
            timeout=timeout,
        )
        self.organizations = OrganizationsResource(self)
        self.tenants = TenantsResource(self)
        self.projects = ProjectsResource(self)
        self.environments = EnvironmentsResource(self)
        self.users = UsersResource(self)
        self.groups = GroupsResource(self)
        self.rbac = RbacResource(self)
        self.audit = AuditResource(self)
        self.events = EventsResource(self)
        self.webhooks = WebhooksResource(self)
        self.notification_channels = NotificationChannelsResource(self)
        self.service_accounts = ServiceAccountsResource(self)
        self.personal_access_tokens = PersonalAccessTokensResource(self)
        self.api_secrets = ApiSecretsResource(self)
        self.authzen = AuthzenResource(self)
        self.scim = ScimResource(self)
        self.hris = HrisResource(self)
        self.mcp = McpResource(self)
        self.otel = OtelResource(self)
        self.oidc_clients = OidcClientsResource(self)
        self.actions = ActionsResource(self)
        self.addons = AddonsResource(self)
        self.billing = BillingResource(self)
        self.settings = SettingsResource(self)
        self.elevate = ElevateResource(self)
        self.email_providers = EmailProvidersResource(self)
        self.feature_flags = FeatureFlagsResource(self)
        self.forms = FormsResource(self)
        self.provisioning_tokens = ProvisioningTokensResource(self)
        self.impersonation = ImpersonationResource(self)
        self.portal = PortalResource(self)
        self.security = SecurityResource(self)
        self.threats = ThreatsResource(self)
        self.vanity_domains = VanityDomainsResource(self)
        self.widgets = WidgetsResource(self)

    def _get_default_headers(self) -> Dict[str, str]:
        """Get default headers for API requests."""
        headers = {
            "Content-Type": "application/json",
            "User-Agent": "authdog-python-sdk/0.1.1",
        }
        if self.api_key:
            headers["Authorization"] = f"Bearer {self.api_key}"
        return headers

    def request(
        self,
        method: str,
        path: str,
        json: Optional[Dict[str, Any]] = None,
        params: Optional[Dict[str, Any]] = None,
        access_token: Optional[str] = None,
        omit_auth: bool = False,
    ) -> Any:
        """Send a JSON request and map HTTP failures onto the error taxonomy."""
        headers: Dict[str, str] = {}
        if omit_auth:
            headers["Authorization"] = ""
        elif access_token is not None:
            headers["Authorization"] = f"Bearer {access_token}"

        try:
            response = self._client.request(
                method,
                path,
                json=json,
                params=params,
                headers=headers,
            )
        except httpx.RequestError as exc:
            raise APIError(f"Request failed: {str(exc)}") from exc

        if response.status_code == 401:
            raise AuthenticationError("Unauthorized - invalid or expired token")

        if response.status_code >= 400:
            error_text = response.text
            try:
                payload = response.json()
                if isinstance(payload, dict) and payload.get("error"):
                    error_text = str(payload["error"])
            except ValueError:
                pass
            raise APIError(
                f"HTTP error {response.status_code}: {error_text}",
                status_code=response.status_code,
            )

        if not response.content:
            return {}

        try:
            return response.json()
        except ValueError as exc:
            raise APIError("Failed to parse response: invalid JSON") from exc

    def health(self) -> Probe:
        """Liveness probe. Public; works without a management credential."""
        return Probe.from_dict(self.request("GET", "/v1/health"))

    def get_userinfo(self, access_token: str) -> UserInfoResponse:
        """
        Get user information using an access token.

        Args:
            access_token: The access token for authentication

        Returns:
            UserInfoResponse containing user information

        Raises:
            AuthenticationError: If authentication fails
            APIError: If API request fails
        """
        headers = {"Authorization": f"Bearer {access_token}"}

        try:
            response = self._client.get("/v1/userinfo", headers=headers)

            if response.status_code == 401:
                raise AuthenticationError("Unauthorized - invalid or expired token")

            if response.status_code == 500:
                error_data = response.json()
                if "error" in error_data:
                    if error_data["error"] == "GraphQL query failed":
                        raise APIError("GraphQL query failed")
                    elif error_data["error"] == "Failed to fetch user info":
                        raise APIError("Failed to fetch user info")

            response.raise_for_status()
            return UserInfoResponse.from_dict(response.json())

        except httpx.HTTPStatusError as e:
            raise APIError(f"HTTP error {e.response.status_code}: {e.response.text}")
        except httpx.RequestError as e:
            raise APIError(f"Request failed: {str(e)}")

    def close(self):
        """Close the HTTP client."""
        self._client.close()

    def __enter__(self):
        """Context manager entry."""
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit."""
        self.close()
