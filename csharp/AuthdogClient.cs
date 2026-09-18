using System;
using System.Collections;
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
        private readonly string? _environmentSecret;
        private readonly string? _scimToken;
        private readonly string? _hrisToken;
        private bool _disposed = false;

        /// <summary>
        /// Timeout applied to the owned HTTP client. Injected clients keep their own timeout.
        /// </summary>
        public TimeSpan Timeout { get; }

        /// <summary>
        /// Optional management Bearer credential. Userinfo still uses the access-token argument.
        /// </summary>
        public string? ApiKey => _apiKey;

        /// <summary>
        /// Optional <c>adenv_</c> secret for AuthZEN evaluation/search and MCP runtime.
        /// </summary>
        public string? EnvironmentSecret => _environmentSecret;

        /// <summary>
        /// Optional <c>adscim_</c> token for <c>/v1/scim/v2</c>.
        /// </summary>
        public string? ScimToken => _scimToken;

        /// <summary>
        /// Optional <c>adhris_</c> token for <c>/v1/hris/v1</c>.
        /// </summary>
        public string? HrisToken => _hrisToken;

        public OrganizationsResource Organizations { get; }

        public TenantsResource Tenants { get; }

        public ProjectsResource Projects { get; }

        public EnvironmentsResource Environments { get; }

        public UsersResource Users { get; }

        public GroupsResource Groups { get; }

        public RbacResource Rbac { get; }

        public AuditResource Audit { get; }

        public EventsResource Events { get; }

        public WebhooksResource Webhooks { get; }

        public NotificationChannelsResource NotificationChannels { get; }

        public ServiceAccountsResource ServiceAccounts { get; }

        public PersonalAccessTokensResource PersonalAccessTokens { get; }

        public ApiSecretsResource ApiSecrets { get; }

        public AuthzenResource Authzen { get; }

        public ScimResource Scim { get; }

        public HrisResource Hris { get; }

        public McpResource Mcp { get; }

        public OtelResource Otel { get; }

        public OidcClientsResource OidcClients { get; }

        public ActionsResource Actions { get; }

        public AddonsResource Addons { get; }

        public BillingResource Billing { get; }

        public SettingsResource Settings { get; }

        public ElevateResource Elevate { get; }

        public EmailProvidersResource EmailProviders { get; }

        public FeatureFlagsResource FeatureFlags { get; }

        public FormsResource Forms { get; }

        public ProvisioningTokensResource ProvisioningTokens { get; }

        public ImpersonationResource Impersonation { get; }

        public PortalResource Portal { get; }

        public SecurityResource Security { get; }

        public ThreatsResource Threats { get; }

        public VanityDomainsResource VanityDomains { get; }

        public WidgetsResource Widgets { get; }

        /// <summary>
        /// Initialize the Authdog client
        /// </summary>
        /// <param name="baseUrl">The base URL of the Authdog API</param>
        /// <param name="apiKey">Optional management Bearer credential; unused on userinfo</param>
        /// <param name="httpClient">Optional custom HttpClient instance</param>
        /// <param name="timeout">Timeout for an owned HttpClient (default 10 seconds)</param>
        /// <param name="environmentSecret">Optional <c>adenv_</c> secret for AuthZEN and MCP runtime</param>
        /// <param name="scimToken">Optional <c>adscim_</c> token for SCIM</param>
        /// <param name="hrisToken">Optional <c>adhris_</c> token for HRIS</param>
        public AuthdogClient(
            string baseUrl,
            string? apiKey = null,
            HttpClient? httpClient = null,
            TimeSpan? timeout = null,
            string? environmentSecret = null,
            string? scimToken = null,
            string? hrisToken = null)
        {
            _baseUrl = baseUrl.TrimEnd('/');
            _apiKey = apiKey;
            _environmentSecret = environmentSecret;
            _scimToken = scimToken;
            _hrisToken = hrisToken;
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
            Rbac = new RbacResource(this);
            Audit = new AuditResource(this);
            Events = new EventsResource(this);
            Webhooks = new WebhooksResource(this);
            NotificationChannels = new NotificationChannelsResource(this);
            ServiceAccounts = new ServiceAccountsResource(this);
            PersonalAccessTokens = new PersonalAccessTokensResource(this);
            ApiSecrets = new ApiSecretsResource(this);
            Authzen = new AuthzenResource(this);
            Scim = new ScimResource(this);
            Hris = new HrisResource(this);
            Mcp = new McpResource(this);
            Otel = new OtelResource(this);
            OidcClients = new OidcClientsResource(this);
            Actions = new ActionsResource(this);
            Addons = new AddonsResource(this);
            Billing = new BillingResource(this);
            Settings = new SettingsResource(this);
            Elevate = new ElevateResource(this);
            EmailProviders = new EmailProvidersResource(this);
            FeatureFlags = new FeatureFlagsResource(this);
            Forms = new FormsResource(this);
            ProvisioningTokens = new ProvisioningTokensResource(this);
            Impersonation = new ImpersonationResource(this);
            Portal = new PortalResource(this);
            Security = new SecurityResource(this);
            Threats = new ThreatsResource(this);
            VanityDomains = new VanityDomainsResource(this);
            Widgets = new WidgetsResource(this);
        }

        /// <summary>
        /// Environment-scoped management path prefix.
        /// </summary>
        internal static string Env(string tenantId, string environmentId) =>
            $"/v1/tenants/{tenantId}/environments/{environmentId}";

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
        /// Convert a Dictionary or object into query parameters, dropping null values.
        /// </summary>
        internal static IDictionary<string, string?>? QueryFrom(object? query)
        {
            if (query == null)
            {
                return null;
            }

            if (query is IDictionary<string, string?> typedNullable)
            {
                var copy = new Dictionary<string, string?>();
                foreach (var pair in typedNullable)
                {
                    if (pair.Value != null)
                    {
                        copy[pair.Key] = pair.Value;
                    }
                }

                return copy.Count == 0 ? null : copy;
            }

            if (query is IDictionary dictionary)
            {
                var copy = new Dictionary<string, string?>();
                foreach (DictionaryEntry entry in dictionary)
                {
                    if (entry.Key is null || entry.Value is null)
                    {
                        continue;
                    }

                    var key = Convert.ToString(entry.Key, CultureInfo.InvariantCulture);
                    if (string.IsNullOrEmpty(key))
                    {
                        continue;
                    }

                    copy[key] = Convert.ToString(entry.Value, CultureInfo.InvariantCulture);
                }

                return copy.Count == 0 ? null : copy;
            }

            var obj = query as JObject ?? JObject.FromObject(query);
            var result = new Dictionary<string, string?>();
            foreach (var property in obj.Properties())
            {
                if (property.Value.Type is JTokenType.Null or JTokenType.Undefined)
                {
                    continue;
                }

                result[property.Name] = property.Value.Type == JTokenType.String
                    ? property.Value.Value<string>()
                    : property.Value.ToString(Formatting.None);
            }

            return result.Count == 0 ? null : result;
        }

        /// <summary>
        /// Send a JSON management request. Constructor apiKey is sent as Bearer unless
        /// <paramref name="accessToken"/> is provided. <paramref name="omitAuth"/> skips
        /// Authorization even when ApiKey is set. Does not set DefaultRequestHeaders.
        /// </summary>
        public async Task<T> RequestAsync<T>(
            HttpMethod method,
            string path,
            object? body = null,
            IDictionary<string, string?>? query = null,
            string? accessToken = null,
            bool omitAuth = false)
        {
            if (_disposed)
                throw new ObjectDisposedException(nameof(AuthdogClient));

            var request = new HttpRequestMessage(method, BuildRequestUri(path, query));
            if (!omitAuth)
            {
                var token = accessToken ?? _apiKey;
                if (token != null)
                {
                    request.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
                }
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
            string? accessToken = null,
            bool omitAuth = false)
        {
            return RequestAsync<T>(method, path, body, query, accessToken, omitAuth).GetAwaiter().GetResult();
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
