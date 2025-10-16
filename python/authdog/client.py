"""Main client for Authdog SDK."""

import httpx
from typing import Dict, Any, Optional
from .exceptions import AuthdogError, AuthenticationError, APIError


class AuthdogClient:
    """Main client for interacting with Authdog API."""
    
    def __init__(self, base_url: str, api_key: Optional[str] = None):
        """
        Initialize the Authdog client.
        
        Args:
            base_url: The base URL of the Authdog API
            api_key: Optional API key for authentication
        """
        self.base_url = base_url.rstrip('/')
        self.api_key = api_key
        self._client = httpx.Client(
            base_url=self.base_url,
            headers=self._get_default_headers()
        )
    
    def _get_default_headers(self) -> Dict[str, str]:
        """Get default headers for API requests."""
        headers = {
            "Content-Type": "application/json",
            "User-Agent": "authdog-python-sdk/0.1.0"
        }
        if self.api_key:
            headers["Authorization"] = f"Bearer {self.api_key}"
        return headers
    
    def get_userinfo(self, access_token: str) -> Dict[str, Any]:
        """
        Get user information using an access token.
        
        Args:
            access_token: The access token for authentication
            
        Returns:
            Dict containing user information
            
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
            return response.json()
            
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
