using System;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Authdog;
using Authdog.Exceptions;
using Authdog.Types;
using FluentAssertions;
using Moq;
using Moq.Protected;
using Newtonsoft.Json;
using Xunit;

namespace Authdog.Sdk.Tests
{
    public class AuthdogClientTests : IDisposable
    {
        private readonly Mock<HttpMessageHandler> _mockHttpMessageHandler;
        private readonly HttpClient _httpClient;
        private readonly AuthdogClient _client;

        public AuthdogClientTests()
        {
            _mockHttpMessageHandler = new Mock<HttpMessageHandler>();
            _httpClient = new HttpClient(_mockHttpMessageHandler.Object);
            _client = new AuthdogClient("https://api.authdog.com", null, _httpClient);
        }

        [Fact]
        public void Constructor_WithBaseUrl_SetsCorrectBaseUrl()
        {
            // Arrange & Act
            var client = new AuthdogClient("https://api.authdog.com");

            // Assert
            client.Should().NotBeNull();
        }

        [Fact]
        public void Constructor_WithTrailingSlash_RemovesTrailingSlash()
        {
            // Arrange & Act
            var client = new AuthdogClient("https://api.authdog.com/");

            // Assert
            client.Should().NotBeNull();
        }

        [Fact]
        public void Constructor_WithApiKey_SetsApiKey()
        {
            // Arrange & Act
            var client = new AuthdogClient("https://api.authdog.com", "test-api-key");

            // Assert
            client.Should().NotBeNull();
        }

        [Fact]
        public void Constructor_WithCustomHttpClient_UsesProvidedClient()
        {
            // Arrange
            var customHttpClient = new HttpClient();

            // Act
            var client = new AuthdogClient("https://api.authdog.com", null, customHttpClient);

            // Assert
            client.Should().NotBeNull();
        }

        [Fact]
        public async Task GetUserInfoAsync_WithValidToken_ReturnsUserInfo()
        {
            // Arrange
            var mockResponse = new UserInfoResponse
            {
                Meta = new Meta { Code = 200, Message = "OK" },
                User = new User { Id = "123", DisplayName = "Test User" }
            };

            var jsonResponse = JsonConvert.SerializeObject(mockResponse);
            var httpResponse = new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(jsonResponse, Encoding.UTF8, "application/json")
            };

            _mockHttpMessageHandler
                .Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(httpResponse);

            // Act
            var result = await _client.GetUserInfoAsync("valid-token");

            // Assert
            result.Should().NotBeNull();
            result.User.Id.Should().Be("123");
            result.User.DisplayName.Should().Be("Test User");
            result.Meta.Code.Should().Be(200);
        }

        [Fact]
        public async Task GetUserInfoAsync_WithApiKey_UsesApiKeyInsteadOfToken()
        {
            // Arrange
            var clientWithApiKey = new AuthdogClient("https://api.authdog.com", "test-api-key", _httpClient);
            var mockResponse = new UserInfoResponse
            {
                Meta = new Meta { Code = 200, Message = "OK" },
                User = new User { Id = "123", DisplayName = "Test User" }
            };

            var jsonResponse = JsonConvert.SerializeObject(mockResponse);
            var httpResponse = new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(jsonResponse, Encoding.UTF8, "application/json")
            };

            HttpRequestMessage? capturedRequest = null;
            _mockHttpMessageHandler
                .Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>())
                .Callback<HttpRequestMessage, CancellationToken>((request, ct) => capturedRequest = request)
                .ReturnsAsync(httpResponse);

            // Act
            await clientWithApiKey.GetUserInfoAsync("access-token");

            // Assert
            capturedRequest.Should().NotBeNull();
            capturedRequest!.Headers.Authorization.Should().NotBeNull();
            capturedRequest.Headers.Authorization!.ToString().Should().Be("Bearer test-api-key");
        }

        [Fact]
        public async Task GetUserInfoAsync_WithUnauthorizedResponse_ThrowsAuthenticationException()
        {
            // Arrange
            var httpResponse = new HttpResponseMessage(HttpStatusCode.Unauthorized)
            {
                Content = new StringContent("Unauthorized", Encoding.UTF8, "application/json")
            };

            _mockHttpMessageHandler
                .Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(httpResponse);

            // Act & Assert
            var exception = await Assert.ThrowsAsync<AuthenticationException>(
                () => _client.GetUserInfoAsync("invalid-token"));
            
            exception.Message.Should().Be("Unauthorized - invalid or expired token");
        }

        [Fact]
        public async Task GetUserInfoAsync_WithGraphQLError_ThrowsApiException()
        {
            // Arrange
            var errorResponse = new { error = "GraphQL query failed" };
            var jsonResponse = JsonConvert.SerializeObject(errorResponse);
            var httpResponse = new HttpResponseMessage(HttpStatusCode.InternalServerError)
            {
                Content = new StringContent(jsonResponse, Encoding.UTF8, "application/json")
            };

            _mockHttpMessageHandler
                .Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(httpResponse);

            // Act & Assert
            var exception = await Assert.ThrowsAsync<ApiException>(
                () => _client.GetUserInfoAsync("token"));
            
            exception.Message.Should().Be("GraphQL query failed");
        }

        [Fact]
        public async Task GetUserInfoAsync_WithFetchError_ThrowsApiException()
        {
            // Arrange
            var errorResponse = new { error = "Failed to fetch user info" };
            var jsonResponse = JsonConvert.SerializeObject(errorResponse);
            var httpResponse = new HttpResponseMessage(HttpStatusCode.InternalServerError)
            {
                Content = new StringContent(jsonResponse, Encoding.UTF8, "application/json")
            };

            _mockHttpMessageHandler
                .Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(httpResponse);

            // Act & Assert
            var exception = await Assert.ThrowsAsync<ApiException>(
                () => _client.GetUserInfoAsync("token"));
            
            exception.Message.Should().Be("Failed to fetch user info");
        }

        [Fact]
        public async Task GetUserInfoAsync_WithHttpRequestException_ThrowsApiException()
        {
            // Arrange
            _mockHttpMessageHandler
                .Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>())
                .ThrowsAsync(new HttpRequestException("Network error"));

            // Act & Assert
            var exception = await Assert.ThrowsAsync<ApiException>(
                () => _client.GetUserInfoAsync("token"));
            
            exception.Message.Should().Be("Request failed: Network error");
            exception.InnerException.Should().BeOfType<HttpRequestException>();
        }

        [Fact]
        public async Task GetUserInfoAsync_WithTimeout_ThrowsApiException()
        {
            // Arrange
            _mockHttpMessageHandler
                .Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>())
                .ThrowsAsync(new TaskCanceledException("Request timeout"));

            // Act & Assert
            var exception = await Assert.ThrowsAsync<ApiException>(
                () => _client.GetUserInfoAsync("token"));
            
            exception.Message.Should().Be("Request timeout: Request timeout");
            exception.InnerException.Should().BeOfType<TaskCanceledException>();
        }

        [Fact]
        public async Task GetUserInfoAsync_WithNonSuccessStatusCode_ThrowsApiException()
        {
            // Arrange
            var httpResponse = new HttpResponseMessage(HttpStatusCode.BadRequest)
            {
                Content = new StringContent("Bad Request", Encoding.UTF8, "application/json")
            };

            _mockHttpMessageHandler
                .Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(httpResponse);

            // Act & Assert
            var exception = await Assert.ThrowsAsync<ApiException>(
                () => _client.GetUserInfoAsync("token"));
            
            exception.Message.Should().Be("HTTP error 400: Bad Request");
        }

        [Fact]
        public void GetUserInfo_SynchronousVersion_ReturnsSameResult()
        {
            // Arrange
            var mockResponse = new UserInfoResponse
            {
                Meta = new Meta { Code = 200, Message = "OK" },
                User = new User { Id = "123", DisplayName = "Test User" }
            };

            var jsonResponse = JsonConvert.SerializeObject(mockResponse);
            var httpResponse = new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(jsonResponse, Encoding.UTF8, "application/json")
            };

            _mockHttpMessageHandler
                .Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(httpResponse);

            // Act
            var result = _client.GetUserInfo("valid-token");

            // Assert
            result.Should().NotBeNull();
            result.User.Id.Should().Be("123");
            result.User.DisplayName.Should().Be("Test User");
        }

        [Fact]
        public void Dispose_DisposesHttpClient()
        {
            // Arrange
            var mockHttpClient = new Mock<HttpClient>();
            var client = new AuthdogClient("https://api.authdog.com", null, mockHttpClient.Object);

            // Act
            client.Dispose();

            // Assert
            mockHttpClient.Verify(hc => hc.Dispose(), Times.Once);
        }

        [Fact]
        public async Task GetUserInfoAsync_AfterDisposal_ThrowsObjectDisposedException()
        {
            // Arrange
            _client.Dispose();

            // Act & Assert
            var exception = await Assert.ThrowsAsync<ObjectDisposedException>(
                () => _client.GetUserInfoAsync("token"));
            
            exception.ObjectName.Should().Be(nameof(AuthdogClient));
        }

        public void Dispose()
        {
            _client?.Dispose();
            _httpClient?.Dispose();
        }
    }
}
