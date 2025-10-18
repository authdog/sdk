using System;
using System.Net.Http;
using Authdog.Exceptions;
using FluentAssertions;
using Xunit;

namespace Authdog.Sdk.Tests
{
    public class ExceptionTests
    {
        [Fact]
        public void AuthdogException_WithMessage_CreatesException()
        {
            // Arrange
            const string message = "Test error message";

            // Act
            var exception = new AuthdogException(message);

            // Assert
            exception.Should().NotBeNull();
            exception.Message.Should().Be(message);
            exception.InnerException.Should().BeNull();
        }

        [Fact]
        public void AuthdogException_WithMessageAndInnerException_CreatesException()
        {
            // Arrange
            const string message = "Test error message";
            var innerException = new InvalidOperationException("Inner exception");

            // Act
            var exception = new AuthdogException(message, innerException);

            // Assert
            exception.Should().NotBeNull();
            exception.Message.Should().Be(message);
            exception.InnerException.Should().Be(innerException);
        }

        [Fact]
        public void AuthdogException_InheritsFromException()
        {
            // Arrange & Act
            var exception = new AuthdogException("Test message");

            // Assert
            exception.Should().BeAssignableTo<Exception>();
        }

        [Fact]
        public void AuthenticationException_WithMessage_CreatesException()
        {
            // Arrange
            const string message = "Authentication failed";

            // Act
            var exception = new AuthenticationException(message);

            // Assert
            exception.Should().NotBeNull();
            exception.Message.Should().Be(message);
            exception.InnerException.Should().BeNull();
        }

        [Fact]
        public void AuthenticationException_WithMessageAndInnerException_CreatesException()
        {
            // Arrange
            const string message = "Authentication failed";
            var innerException = new UnauthorizedAccessException("Access denied");

            // Act
            var exception = new AuthenticationException(message, innerException);

            // Assert
            exception.Should().NotBeNull();
            exception.Message.Should().Be(message);
            exception.InnerException.Should().Be(innerException);
        }

        [Fact]
        public void AuthenticationException_InheritsFromAuthdogException()
        {
            // Arrange & Act
            var exception = new AuthenticationException("Test message");

            // Assert
            exception.Should().BeAssignableTo<AuthdogException>();
            exception.Should().BeAssignableTo<Exception>();
        }

        [Fact]
        public void ApiException_WithMessage_CreatesException()
        {
            // Arrange
            const string message = "API request failed";

            // Act
            var exception = new ApiException(message);

            // Assert
            exception.Should().NotBeNull();
            exception.Message.Should().Be(message);
            exception.InnerException.Should().BeNull();
        }

        [Fact]
        public void ApiException_WithMessageAndInnerException_CreatesException()
        {
            // Arrange
            const string message = "API request failed";
            var innerException = new HttpRequestException("Network error");

            // Act
            var exception = new ApiException(message, innerException);

            // Assert
            exception.Should().NotBeNull();
            exception.Message.Should().Be(message);
            exception.InnerException.Should().Be(innerException);
        }

        [Fact]
        public void ApiException_InheritsFromAuthdogException()
        {
            // Arrange & Act
            var exception = new ApiException("Test message");

            // Assert
            exception.Should().BeAssignableTo<AuthdogException>();
            exception.Should().BeAssignableTo<Exception>();
        }

        [Fact]
        public void Exceptions_CanBeThrownAndCaught()
        {
            // Arrange
            const string message = "Test exception";

            // Act & Assert
            Action throwAuthdogException = () => throw new AuthdogException(message);
            throwAuthdogException.Should().Throw<AuthdogException>().WithMessage(message);

            Action throwAuthenticationException = () => throw new AuthenticationException(message);
            throwAuthenticationException.Should().Throw<AuthenticationException>().WithMessage(message);

            Action throwApiException = () => throw new ApiException(message);
            throwApiException.Should().Throw<ApiException>().WithMessage(message);
        }

        [Fact]
        public void Exceptions_CanBeCaughtAsBaseException()
        {
            // Arrange
            const string message = "Test exception";

            // Act & Assert
            try
            {
                throw new AuthenticationException(message);
            }
            catch (AuthdogException ex)
            {
                ex.Message.Should().Be(message);
                ex.Should().BeOfType<AuthenticationException>();
            }
        }

        [Fact]
        public void Exceptions_CanBeCaughtAsSystemException()
        {
            // Arrange
            const string message = "Test exception";

            // Act & Assert
            try
            {
                throw new ApiException(message);
            }
            catch (Exception ex)
            {
                ex.Message.Should().Be(message);
                ex.Should().BeOfType<ApiException>();
            }
        }
    }
}
