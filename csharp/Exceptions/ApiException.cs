using System;

namespace Authdog.Exceptions
{
    /// <summary>
    /// Exception thrown when API requests fail
    /// </summary>
    public class ApiException : AuthdogException
    {
        public int? StatusCode { get; }

        public ApiException(string message = "API request failed") : base(message)
        {
        }

        public ApiException(string message, Exception innerException) : base(message, innerException)
        {
        }

        public ApiException(string message, int statusCode) : base(message)
        {
            StatusCode = statusCode;
        }
    }
}
