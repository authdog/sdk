using System;
using System.Collections.Generic;
using System.Globalization;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Authdog.Exceptions;
using Authdog.Types;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

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
        /// Timeout applied to the owned HTTP client. Injected clients keep their own timeout.
        /// </summary>
        public TimeSpan Timeout { get; }

        /// <summary>
        /// Optional management Bearer credential. Userinfo still uses the access-token argument.
        /// </summary>
        public string? ApiKey => _apiKey;

        public OrganizationsResource Organizations { get; }

        public TenantsResource Tenants { get; }

        public ProjectsResource Projects { get; }

        public EnvironmentsResource Environments { get; }

        public UsersResource Users { get; }

        public GroupsResource Groups { get; }

        /// <summary>
        /// Initialize the Authdog client
        /// </summary>
        /// <param name="baseUrl">The base URL of the Authdog API</param>
        /// <param name="apiKey">Optional management Bearer credential; unused on userinfo</param>
        /// <param name="httpClient">Optional custom HttpClient instance</param>
        /// <param name="timeout">Timeout for an owned HttpClient (default 10 seconds)</param>
        public AuthdogClient(string baseUrl, string? apiKey = null, HttpClient? httpClient = null, TimeSpan? timeout = null)
        {
            _baseUrl = baseUrl.TrimEnd('/');
            _apiKey = apiKey;
            Timeout = timeout ?? TimeSpan.FromSeconds(10);
            _httpClient = httpClient ?? new HttpClient { Timeout = Timeout };

            if (!_httpClient.DefaultRequestHeaders.Contains("User-Agent"))
            {
                _httpClient.DefaultRequestHeaders.Add("User-Agent", "authdog-csharp-sdk/0.1.0");
            }

            Organizations = new OrganizationsResource(this);
            Tenants = new TenantsResource(this);
            Projects = new ProjectsResource(this);
            Environments = new EnvironmentsResource(this);
            Users = new UsersResource(this);
            Groups = new GroupsResource(this);
        }

        /// <summary>
        /// Build a query map, dropping null values.
        /// </summary>
        internal static IDictionary<string, string?>? Params(params (string Key, object? Value)[] pairs)
        {
            var query = new Dictionary<string, string?>();
            foreach (var (key, value) in pairs)
            {
                if (value is null)
                {
                    continue;
                }

                query[key] = Convert.ToString(value, CultureInfo.InvariantCulture);
            }

            return query.Count == 0 ? null : query;
        }

        /// <summary>
        /// Send a JSON management request. Constructor apiKey is sent as Bearer unless
        /// <paramref name="accessToken"/> is provided. Does not set DefaultRequestHeaders.
        /// </summary>
        public async Task<T> RequestAsync<T>(
            HttpMethod method,
            string path,
            object? body = null,
            IDictionary<string, string?>? query = null,
            string? accessToken = null)
        {
            if (_disposed)
                throw new ObjectDisposedException(nameof(AuthdogClient));

            var request = new HttpRequestMessage(method, BuildRequestUri(path, query));
            var token = accessToken ?? _apiKey;
            if (token != null)
            {
                request.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
            }

            if (body != null)
            {
                var json = JsonConvert.SerializeObject(body);
                request.Content = new StringContent(json, Encoding.UTF8, "application/json");
            }

            try
            {
                var response = await _httpClient.SendAsync(request);
                var content = await response.Content.ReadAsStringAsync();

                if (response.StatusCode == System.Net.HttpStatusCode.Unauthorized)
                {
                    throw new AuthenticationException("Unauthorized - invalid or expired token");
                }

                if (!response.IsSuccessStatusCode)
                {
                    var errorText = content;
                    try
                    {
                        var payload = JsonConvert.DeserializeObject<JObject>(content);
                        var error = payload?["error"];
                        if (error != null && error.Type != JTokenType.Null)
                        {
                            errorText = error.Type == JTokenType.String ? error.ToString() : error.ToString();
                        }
                    }
                    catch (JsonException)
                    {
                    }

                    throw new ApiException($"HTTP error {(int)response.StatusCode}: {errorText}", (int)response.StatusCode);
                }

                if (string.IsNullOrWhiteSpace(content))
                {
                    if (typeof(T) == typeof(JObject))
                    {
                        return (T)(object)new JObject();
                    }

                    return JsonConvert.DeserializeObject<T>("{}")
                        ?? throw new ApiException("Failed to parse response: invalid JSON");
                }

                try
                {
                    return JsonConvert.DeserializeObject<T>(content)
                        ?? throw new ApiException("Failed to parse response: invalid JSON");
                }
                catch (JsonException ex)
                {
                    throw new ApiException("Failed to parse response: invalid JSON", ex);
                }
            }
            catch (AuthenticationException)
            {
                throw;
            }
            catch (ApiException)
            {
                throw;
            }
            catch (HttpRequestException ex)
            {
                throw new ApiException($"Request failed: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Synchronous version of RequestAsync
        /// </summary>
        public T Request<T>(
            HttpMethod method,
            string path,
            object? body = null,
            IDictionary<string, string?>? query = null,
            string? accessToken = null)
        {
            return RequestAsync<T>(method, path, body, query, accessToken).GetAwaiter().GetResult();
        }

        /// <summary>
        /// Liveness probe. Public; works without a management credential.
        /// </summary>
        public Task<Probe> HealthAsync() => RequestAsync<Probe>(HttpMethod.Get, "/v1/health");

        /// <summary>
        /// Synchronous version of HealthAsync
        /// </summary>
        public Probe Health() => HealthAsync().GetAwaiter().GetResult();

        private string BuildRequestUri(string path, IDictionary<string, string?>? query)
        {
            if (!path.StartsWith("/"))
            {
                path = "/" + path;
            }

            var url = $"{_baseUrl}{path}";
            if (query == null || query.Count == 0)
            {
                return url;
            }

            var parts = new List<string>();
            foreach (var pair in query)
            {
                if (pair.Value == null)
                {
                    continue;
                }

                parts.Add($"{Uri.EscapeDataString(pair.Key)}={Uri.EscapeDataString(pair.Value)}");
            }

            return parts.Count == 0 ? url : $"{url}?{string.Join("&", parts)}";
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
            request.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", accessToken);

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
