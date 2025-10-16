using System;
using System.Net.Http;
using System.Threading.Tasks;
using Authdog.Exceptions;
using Authdog.Types;
using Newtonsoft.Json;

namespace Authdog
{
    /// <summary>
    /// Main client for interacting with Authdog API
    /// </summary>
    public class AuthdogClient : IDisposable
    {
        private readonly HttpClient _httpClient;
        private readonly string _baseUrl;
        private readonly string? _apiKey;
        private bool _disposed = false;

        /// <summary>
        /// Initialize the Authdog client
        /// </summary>
        /// <param name="baseUrl">The base URL of the Authdog API</param>
        /// <param name="apiKey">Optional API key for authentication</param>
        /// <param name="httpClient">Optional custom HttpClient instance</param>
        public AuthdogClient(string baseUrl, string? apiKey = null, HttpClient? httpClient = null)
        {
            _baseUrl = baseUrl.TrimEnd('/');
            _apiKey = apiKey;
            _httpClient = httpClient ?? new HttpClient();

            // Set default headers
            _httpClient.DefaultRequestHeaders.Add("Content-Type", "application/json");
            _httpClient.DefaultRequestHeaders.Add("User-Agent", "authdog-csharp-sdk/0.1.0");

            if (!string.IsNullOrEmpty(_apiKey))
            {
                _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {_apiKey}");
            }
        }

        /// <summary>
        /// Get user information using an access token
        /// </summary>
        /// <param name="accessToken">The access token for authentication</param>
        /// <returns>UserInfoResponse containing user information</returns>
        /// <exception cref="AuthenticationException">When authentication fails</exception>
        /// <exception cref="ApiException">When API request fails</exception>
        public async Task<UserInfoResponse> GetUserInfoAsync(string accessToken)
        {
            if (_disposed)
                throw new ObjectDisposedException(nameof(AuthdogClient));

            var request = new HttpRequestMessage(HttpMethod.Get, $"{_baseUrl}/v1/userinfo");
            request.Headers.Add("Authorization", $"Bearer {accessToken}");

            try
            {
                var response = await _httpClient.SendAsync(request);
                var content = await response.Content.ReadAsStringAsync();

                if (response.IsSuccessStatusCode)
                {
                    return JsonConvert.DeserializeObject<UserInfoResponse>(content) ?? new UserInfoResponse();
                }

                if (response.StatusCode == System.Net.HttpStatusCode.Unauthorized)
                {
                    throw new AuthenticationException("Unauthorized - invalid or expired token");
                }

                if (response.StatusCode == System.Net.HttpStatusCode.InternalServerError)
                {
                    try
                    {
                        var errorData = JsonConvert.DeserializeObject<dynamic>(content);
                        if (errorData?.error != null)
                        {
                            string errorMessage = errorData.error.ToString();
                            if (errorMessage == "GraphQL query failed")
                            {
                                throw new ApiException("GraphQL query failed");
                            }
                            else if (errorMessage == "Failed to fetch user info")
                            {
                                throw new ApiException("Failed to fetch user info");
                            }
                        }
                    }
                    catch (JsonException)
                    {
                        // Ignore JSON parsing errors for error responses
                    }
                }

                throw new ApiException($"HTTP error {(int)response.StatusCode}: {content}");
            }
            catch (HttpRequestException ex)
            {
                throw new ApiException($"Request failed: {ex.Message}", ex);
            }
            catch (TaskCanceledException ex)
            {
                throw new ApiException($"Request timeout: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Synchronous version of GetUserInfoAsync
        /// </summary>
        /// <param name="accessToken">The access token for authentication</param>
        /// <returns>UserInfoResponse containing user information</returns>
        public UserInfoResponse GetUserInfo(string accessToken)
        {
            return GetUserInfoAsync(accessToken).GetAwaiter().GetResult();
        }

        /// <summary>
        /// Dispose the HTTP client
        /// </summary>
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!_disposed && disposing)
            {
                _httpClient?.Dispose();
                _disposed = true;
            }
        }
    }
}
